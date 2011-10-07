import os
import sys
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

def transform(odtfile, debug=False, outputdir=None):
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
            strMathPath = strMathPath + '/content.xml'
            strMath = zip.read(strMathPath)
            
            parser = etree.XMLParser(encoding='utf-8')
            parser.feed(strMath)
            math = parser.close()
            # Replace the reference to the Math with the actual MathML
            obj.getparent().replace(obj, math)
        return xml

    def imagePuller(xml):
        for i, obj in enumerate(IMAGE_XPATH(xml)):
            strPath = IMAGE_HREF_XPATH(obj)[0]
            strName = IMAGE_NAME_XPATH(obj)[0]

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

    # Reparse after XSL because the RED-escape pass injects arbitrary XML
    def redParser(xml):
        xsl = makeXsl('pass1_odt2red-escape.xsl')
        result = xsl(xml)
        appendLog(xsl)
        try:
            xml = etree.fromstring(etree.tostring(result))
        except etree.XMLSyntaxError, e:
            xml = makeXsl('pass1_odt2red-failed.xsl')(xml)
            xml = xml.getroot()
        return xml

    def replaceSymbols(xml):
        xmlstr = etree.tostring(xml)
        xmlstr = symbols.replace(xmlstr)
        return etree.fromstring(xmlstr)

    PIPELINE = [
      replaceSymbols,
      injectStyles, # include the styles.xml file because it contains list numbering info
      makeXsl('pass2_odt-normalize.xsl'), # In the worst case all headings are 9 
                            # and need to be 1. See (testbed) southwood__Lesson_2.doc
      makeXsl('pass2_odt-collapse-spans.xsl'), # This needs to be done 2x to fix headings.
      redParser, # makeXsl('pass1_odt2red-escape.xsl'),
      makeXsl('pass4_odt-headers.xsl'),
      imagePuller, # Need to run before math because both have a <draw:image> (see xpath)
      mathIncluder,
      makeXsl('pass7_odt2cnxml.xsl'),
      makeXsl('pass8_cnxml-cleanup.xsl'),
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
      parser.add_argument('odtfile', help='/path/to/odtfile', type=file)
      parser.add_argument('outputdir', help='/path/to/outputdir', nargs='?')
      args = parser.parse_args()
  
      if args.verbose: print >> sys.stderr, "Transforming..."
      xml, files, errors = transform(args.odtfile, debug=args.verbose, outputdir=args.outputdir)
  
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
