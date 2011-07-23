import os
import sys
import zipfile
import argparse
import urllib
from cStringIO import StringIO
from lxml import etree, html

from addsectiontags import addSectionTags
from addmathml import addMathML

dirname = os.path.dirname(__file__)

def writeXMLFile(filename, content):
    xmlfile = open(filename, 'w')
    # pretty print
    content = etree.tostring(etree.fromstring(content), pretty_print=True)
    xmlfile.write(content)
    xmlfile.close()

def transform(odtfile, outputdir, outfile=sys.stdout):
    zipfileob = zipfile.ZipFile(odtfile, 'r')
    odtxml = zipfileob.read('content.xml')
    writeXMLFile(os.path.join(outputdir, 'content.xml'), odtxml)

    cnxmldoc = etree.fromstring(odtxml)

    # oo2oo
    xslfile = open(os.path.join(dirname, 'xsl/oo2oo.xsl'))
    xslt_root = etree.XML(xslfile.read())
    transform = etree.XSLT(xslt_root)
    cnxmldoc = transform(cnxmldoc)
    writeXMLFile(os.path.join(outputdir, 'oo2oo.xml'),
                 etree.tostring(cnxmldoc))

    # add section tags
    cnxmlstr = addSectionTags(StringIO(etree.tostring(cnxmldoc)))
    writeXMLFile(os.path.join(outputdir, 'sectiontags.xml'), cnxmlstr)

    # add MathML
    cnxmlstr = addMathML(StringIO(cnxmlstr), zipfileob)
    writeXMLFile(os.path.join(outputdir, 'mathml.xml'), cnxmlstr)

    # oo2cnxml
    xslfile = open(os.path.join(dirname, 'xsl/oo2cnxml.xsl'))
    xslt_root = etree.XML(xslfile.read())
    transform = etree.XSLT(xslt_root)

    cnxmldoc = etree.fromstring(cnxmlstr)
    cnxmldoc = transform(cnxmldoc)
    cnxmlstr = etree.tostring(cnxmldoc)
    writeXMLFile(os.path.join(outputdir, 'oo2cnxml.xml'), cnxmlstr)

    schemafile = open(os.path.join(dirname,
                              'schema/cnxml/rng/0.7/cnxml.rng'))
    relaxng_doc = etree.parse(schemafile)
    relaxng = etree.RelaxNG(relaxng_doc)
    if relaxng.validate(cnxmldoc):
        outfile.write(cnxmlstr)  
    else:
        print relaxng.error_log.last_error
        print cnxmlstr
       

def main():
    parser = argparse.ArgumentParser(description='Convert odt file to CNXML')
    parser.add_argument('odtfile', help='/path/to/odtfile', type=file)
    parser.add_argument('outputdir', help='/path/to/outputdir')
    args = parser.parse_args()

    transform(args.odtfile, args.outputdir)

if __name__ == '__main__':
    main()
