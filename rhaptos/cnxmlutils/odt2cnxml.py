import os
import sys
import zipfile
import argparse
import urllib
import pkg_resources
from cStringIO import StringIO
from lxml import etree, html

from addsectiontags import addSectionTags

dirname = os.path.dirname(__file__)

PKG_PREFIX = '' #'rhaptos.cnxmlutils.'

NAMESPACES = {
  'draw':'urn:oasis:names:tc:opendocument:xmlns:drawing:1.0',
  'xlink':'http://www.w3.org/1999/xlink',
  }

MATH_XPATH = etree.XPath('//draw:object[@xlink:href]', namespaces=NAMESPACES)
MATH_HREF_XPATH = etree.XPath('@xlink:href', namespaces=NAMESPACES)

IMAGE_XPATH = etree.XPath('//draw:frame[not(draw:object or draw:object-ole) and @draw:name and draw:image[@xlink:href and @xlink:type="simple"]]', namespaces=NAMESPACES)
IMAGE_HREF_XPATH = etree.XPath('draw:image/@xlink:href', namespaces=NAMESPACES)
IMAGE_NAME_XPATH = etree.XPath('@draw:name', namespaces=NAMESPACES)
          

def makeXsl(filename):
  """ Helper that creates a XSLT stylesheet """
  path = pkg_resources.resource_filename(PKG_PREFIX + "xsl", filename)
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
    # TODO: XSLT should generate a JSON-ish object that converts to a python dict.
    # For example, the text produced by XSLT should be:
    # WARNING: {'msg'   :'Headings without text between them are not allowed',
    #           'id-ish':'import-auto-id2376'}
    # That way we can put a little * near all the cnxml where issues arose
    errors = []

    zip = zipfile.ZipFile(odtfile, 'r')
    content = zip.read('content.xml')
    xml = etree.fromstring(content)
    if outputdir is not None: writeXMLFile(os.path.join(outputdir, 'content.xml'), xml)

    def appendLog(xslDoc):
        if hasattr(xslDoc, 'error_log'):
            for entry in xslDoc.error_log:
                # TODO: Log the errors (and convert JSON to python) instead of just printing
                errors.append(entry.message)


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
        xsl = makeXsl('oo2red-escape.xsl')
        result = xsl(xml)
        appendLog(xsl)
        try:
            xml = etree.fromstring(etree.tostring(result))
        except etree.XMLSyntaxError, e:
            errors.append("ERROR: Red text did not seem to parse. Continuing without converting red text")
        return xml
        
    PIPELINE = [
      redParser, # makeXsl('oo2red-escape.xsl'),
      makeXsl('oo2oo.xsl'),
      makeXsl('oo2cnxml-headers.xsl'),
      imagePuller, # Need to run before math because both have a <draw:image> (see xpath)
      mathIncluder,
      makeXsl('oo2cnxml.xsl'),
      makeXsl('oo2cnxml-cleanup.xsl'),
      makeXsl('id-generation.xsl'),
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
      print etree.tostring(xml)

if __name__ == '__main__':
    main()
