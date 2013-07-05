"""
Copyright (C) 2013 Rice University

This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
See LICENSE.txt for details.
"""

import os
import sys
import tempfile
from copy import deepcopy
import shutil
import zipfile
import urllib
import pkg_resources
from cStringIO import StringIO
from lxml import etree, html

try:
    import json
except ImportError:
    import simplejson as json

import symbols

dirname = os.path.dirname(__file__)

NAMESPACES = {
  'office':'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
  'draw':'urn:oasis:names:tc:opendocument:xmlns:drawing:1.0',
  'xlink':'http://www.w3.org/1999/xlink',
  }

MATH_XPATH = etree.XPath('//draw:object[@xlink:href]', namespaces=NAMESPACES)
MATH_HREF_XPATH = etree.XPath('@xlink:href', namespaces=NAMESPACES)

IMAGE_XPATH = etree.XPath('//draw:frame[not(draw:object or draw:object-ole) and @draw:name and draw:image[@xlink:href and @xlink:type="simple"]]', namespaces=NAMESPACES)
IMAGE_HREF_XPATH = etree.XPath('draw:image/@xlink:href', namespaces=NAMESPACES)
IMAGE_NAME_XPATH = etree.XPath('@draw:name', namespaces=NAMESPACES)
STYLES_XPATH = etree.XPath('//office:styles', namespaces=NAMESPACES)
DRAW_XPATH = etree.XPath('//draw:g[not(parent::draw:*)]', namespaces=NAMESPACES)
DRAW_STYLES_XPATH = etree.XPath('/office:document-content/office:automatic-styles/*', namespaces=NAMESPACES)

DRAW_FILENAME_PREFIX = "draw_odg"

def makeXsl(filename):
  """ Helper that creates a XSLT stylesheet """
  pkg = 'xsl'
  package = ''.join(['.' + x for x in __name__.split('.')[:-1]])[1:]
  if package != '':
      pkg = package + '.' + pkg
  path = pkg_resources.resource_filename(pkg, filename)
  xml = etree.parse(path)
  return etree.XSLT(xml)

def writeXMLFile(filename, content):
    """ Used only for debugging to write out intermediate files"""
    xmlfile = open(filename, 'w')
    # pretty print
    content = etree.tostring(content, pretty_print=True)
    xmlfile.write(content)
    xmlfile.close()

def transform(odtfile, debug=False, parsable=False, outputdir=None):
    """ Given an ODT file this returns a tuple containing
        the cnxml, a dictionary of filename -> data, and a list of errors """
    # Store mapping of images extracted from the ODT file (and their bits)
    images = {}
    # Log of Errors and Warnings generated
    # For example, the text produced by XSLT should be:
    # {'level':'WARNING',
    #  'msg'  :'Headings without text between them are not allowed',
    #  'id'   :'import-auto-id2376'}
    # That way we can put a little * near all the cnxml where issues arose
    errors = []

    zip = zipfile.ZipFile(odtfile, 'r')
    content = zip.read('content.xml')
    xml = etree.fromstring(content)

    def appendLog(xslDoc):
        if hasattr(xslDoc, 'error_log'):
            for entry in xslDoc.error_log:
                # Entries are of the form:
                # {'level':'ERROR','id':'id1234','msg':'Descriptive message'}
                text = entry.message
                try:
                    dict = json.loads(text)
                    errors.append(dict)
                except ValueError:
                    errors.append({
                      u'level':u'CRITICAL',
                      u'id'   :u'(none)',
                      u'msg'  :unicode(text) })
                    
    def injectStyles(xml):
        # HACK - need to find the object location from the manifest ...
        strStyles = zip.read('styles.xml')
        
        parser = etree.XMLParser()
        parser.feed(strStyles)
        stylesXml = parser.close()
        
        for i, obj in enumerate(STYLES_XPATH(stylesXml)):
          xml.append(obj)

        return xml


    # All MathML is stored in separate files "Object #/content.xml"
    # This converter includes the MathML by looking up the file in the zip
    def mathIncluder(xml):
        for i, obj in enumerate(MATH_XPATH(xml)):
            strMathPath = MATH_HREF_XPATH(obj)[0] # Or obj.get('{%s}href' % XLINK_NS)
            if strMathPath[0] == '#':
                strMathPath = strMathPath[1:]
            # Remove leading './' Zip doesn't like it
            if strMathPath[0] == '.':
                strMathPath = strMathPath[2:]

            # HACK - need to find the object location from the manifest ...
            strMathPath = os.path.join(strMathPath, 'content.xml')
            strMath = zip.read(strMathPath)
            
            #parser = etree.XMLParser(encoding='utf-8')
            #parser.feed(strMath)
            #math = parser.close()
            math = etree.parse(StringIO(strMath)).getroot()
            
            # Replace the reference to the Math with the actual MathML
            obj.getparent().replace(obj, math)
        return xml

    def imagePuller(xml):
        for i, obj in enumerate(IMAGE_XPATH(xml)):
            strPath = IMAGE_HREF_XPATH(obj)[0]
            strName = IMAGE_NAME_XPATH(obj)[0]

            fileNeedEnding = ( strName.find('.') == -1 )
            if fileNeedEnding:
                strName = strName + strPath[strPath.index('.'):]

            if strPath[0] == '#':
                strPath = strPath[1:]
            # Remove leading './' Zip doesn't like it
            if strPath[0] == '.':
                strPath = strPath[2:]

            image = zip.read(strPath)
            images[strName] = image
            
            # Later on, an XSL pass will convert the draw:frame to a c:image and 
            # set the @src correctly

        return xml
        
    def drawPuller(xml):
        styles = DRAW_STYLES_XPATH(xml)
                       
        empty_odg_dirname = os.path.join(dirname, 'empty_odg_template')
        
        temp_dirname = tempfile.mkdtemp()
            
        for i, obj in enumerate(DRAW_XPATH(xml)):
            # Copy everything except content.xml from the empty ODG (OOo Draw) template into a new zipfile
            
            odg_filename = DRAW_FILENAME_PREFIX + str(i) + '.odg'
            png_filename = DRAW_FILENAME_PREFIX + str(i) + '.png'

            # add PNG filename as attribute to parent node. The good thing is: The child (obj) will get lost! :-)
            parent = obj.getparent()
            parent.attrib['ooo_drawing'] = png_filename
            
            odg_zip = zipfile.ZipFile(os.path.join(temp_dirname, odg_filename), 'w', zipfile.ZIP_DEFLATED)
            for root, dirs, files in os.walk(empty_odg_dirname):
                for name in files:
                    if name not in ('content.xml', 'styles.xml'):   # copy everything inside ZIP except content.xml or styles.xml
                        sourcename = os.path.join(root, name)
                        # http://stackoverflow.com/a/1193171/756056                        
                        arcname = os.path.join(root[len(empty_odg_dirname):], name)  # Path name inside the ZIP file, empty_odg_template is the root folder
                        odg_zip.write(sourcename, arcname)
            
            content = etree.parse(os.path.join(empty_odg_dirname, 'content.xml'))
                           
            # Inject content styles in empty OOo Draw content.xml
            content_style_xpath = etree.XPath('/office:document-content/office:automatic-styles', namespaces=NAMESPACES)
            content_styles = content_style_xpath(content)                                
            for style in styles:
                content_styles[0].append(deepcopy(style))
            
            # Inject drawing in empty OOo Draw content.xml
            content_page_xpath = etree.XPath('/office:document-content/office:body/office:drawing/draw:page', namespaces=NAMESPACES)
            content_page = content_page_xpath(content)
            content_page[0].append(obj)
            
            # write modified content.xml
            odg_zip.writestr('content.xml', etree.tostring(content, xml_declaration=True, encoding='UTF-8'))
            
            # copy styles.xml from odt to odg without modification
            styles_xml = zip.read('styles.xml')
            odg_zip.writestr('styles.xml', styles_xml)

            odg_zip.close()
            
            # TODO: Better error handling in the future.
            try:
                # convert every odg to png
                command = '/usr/bin/soffice -headless -nologo -nofirststartwizard "macro:///Standard.Module1.SaveAsPNG(%s,%s)"' % (os.path.join(temp_dirname, odg_filename),os.path.join(temp_dirname, png_filename))
                os.system(command)

                # save every image to memory            
                image = open(os.path.join(temp_dirname, png_filename), 'r').read()
                images[png_filename] = image
                
                if outputdir is not None:
                    shutil.copy (os.path.join(temp_dirname, odg_filename), os.path.join(outputdir, odg_filename))
                    shutil.copy (os.path.join(temp_dirname, png_filename), os.path.join(outputdir, png_filename))
            except:
                pass
                
        # delete temporary directory
        shutil.rmtree(temp_dirname)
        
        return xml

    # Reparse after XSL because the RED-escape pass injects arbitrary XML
    def redParser(xml):
        xsl = makeXsl('pass1_odt2red-escape.xsl')
        result = xsl(xml)
        appendLog(xsl)
        try:
            xml = etree.fromstring(etree.tostring(result))
        except etree.XMLSyntaxError, e:
            msg = str(e)
            xml = makeXsl('pass1_odt2red-failed.xsl')(xml, message="'%s'" % msg.replace("'", '"'))
            xml = xml.getroot()
        return xml

    def replaceSymbols(xml):
        xmlstr = etree.tostring(xml)
        xmlstr = symbols.replace(xmlstr)
        return etree.fromstring(xmlstr)

    PIPELINE = [
      drawPuller, # gets OOo Draw objects out of odt and generate odg (OOo Draw) files
      replaceSymbols,
      injectStyles, # include the styles.xml file because it contains list numbering info
      makeXsl('pass2_odt-normalize.xsl'), # This needs to be done 2x to fix headings       
      makeXsl('pass2_odt-normalize.xsl'), # In the worst case all headings are 9 
                            # and need to be 1. See (testbed) southwood__Lesson_2.doc
      makeXsl('pass2_odt-collapse-spans.xsl'), # Collapse adjacent spans (for RED)
      redParser, # makeXsl('pass1_odt2red-escape.xsl'),
      makeXsl('pass4_odt-headers.xsl'),
      imagePuller, # Need to run before math because both have a <draw:image> (see xpath)
      mathIncluder,
      makeXsl('pass7_odt2cnxml.xsl'),
      makeXsl('pass8_cnxml-cleanup.xsl'),
      makeXsl('pass8.5_cnxml-cleanup.xsl'),
      makeXsl('pass9_id-generation.xsl'),
      makeXsl('pass10_processing-instruction-logger.xsl'),
      ]

    # "xml" variable gets replaced during each iteration
    passNum = 0
    for xslDoc in PIPELINE:
        if debug: errors.append("DEBUG: Starting pass %d" % passNum)
        xml = xslDoc(xml)

        appendLog(xslDoc)
        if outputdir is not None: writeXMLFile(os.path.join(outputdir, 'pass%d.xml' % passNum), xml)
        passNum += 1

    # In most cases (EIP) Invalid XML is preferable over valid but Escaped XML
    if not parsable:
      xml = (makeXsl('pass11_red-unescape.xsl'))(xml)

    return (xml, images, errors)

def validate(xml):
    # Validate against schema
    schemafile = open(os.path.join(dirname,
                              'schema/cnxml/rng/0.7/cnxml.rng'))
    relaxng_doc = etree.parse(schemafile)
    relaxng = etree.RelaxNG(relaxng_doc)
    if relaxng.validate(xml):
        return None
    else:
        return relaxng.error_log

def main():
    try:
      import argparse
      parser = argparse.ArgumentParser(description='Convert odt file to CNXML')
      parser.add_argument('-v', dest='verbose', help='Verbose printing to stderr', action='store_true')
      parser.add_argument('-p', dest='parsable', help='Ensure the output is Valid XML (ignore red text)', action='store_true')
      parser.add_argument('odtfile', help='/path/to/odtfile', type=file)
      parser.add_argument('outputdir', help='/path/to/outputdir', nargs='?')
      args = parser.parse_args()
  
      if args.verbose: print >> sys.stderr, "Transforming..."
      xml, files, errors = transform(args.odtfile, debug=args.verbose, parsable=args.parsable, outputdir=args.outputdir)
  
      if args.verbose:
          for name, bytes in files.items():
              print >> sys.stderr, "Extracted %s (%d)" % (name, len(bytes))
      for err in errors:
          print >> sys.stderr, err
      if xml is not None:
        if args.verbose: print >> sys.stderr, "Validating..."
        invalids = validate(xml)
        if invalids: print >> sys.stderr, invalids
        print etree.tostring(xml, pretty_print=True)
      
      if invalids:
        return 1
    except ImportError:
      print "argparse is needed for commandline"

if __name__ == '__main__':
    sys.exit(main())
