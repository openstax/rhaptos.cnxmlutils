import os
import sys
import zipfile
import argparse
import urllib
from cStringIO import StringIO
from lxml import etree, html

dirname = os.path.dirname(__file__)

def transform(odtfile, outfile=sys.stdout):
    zipfileob = zipfile.ZipFile(odtfile, 'r')
    odtxml = zipfileob.read('content.xml')

    doc = etree.fromstring(odtxml)

    xslfile = open(os.path.join(dirname, 'xsl/oo2cnxml.xsl'))
    xslt_root = etree.XML(xslfile.read())
    transform = etree.XSLT(xslt_root)
    result_tree = transform(doc)
    cnxml = etree.tostring(result_tree)

    outfile.write(cnxml)

def main():
    parser = argparse.ArgumentParser(description='Convert odt file to CNXML')
    parser.add_argument('odtfile', help='/path/to/odtfile', type=file)
    args = parser.parse_args()

    transform(args.odtfile)

if __name__ == '__main__':
    main()
