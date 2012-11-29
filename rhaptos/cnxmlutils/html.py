# -*- coding: utf-8 -*-
"""Converts a piece of HTML5 (just the body tag element) and an existing
CNXML document into a CNXML document. The existing CNXML Document is necessary
to preserve the previously document's metadata.
The results are sent to standard out.

"""
import sys
import argparse
from io import StringIO

import pkg_resources
from lxml import etree
from .utils import transform


__all__ = (
    'NAMESPACES', 'XHTML_INCLUDE_XPATH', 'XHTML_MODULE_BODY_XPATH',
    'cnxml_to_html', 'html_to_cnxml',
    )

NAMESPACES = {
    'xhtml':'http://www.w3.org/1999/xhtml',
    }
XHTML_INCLUDE_XPATH = etree.XPath('//xhtml:a[@class="include"]',
                                  namespaces=NAMESPACES)
XHTML_MODULE_BODY_XPATH = etree.XPath('//xhtml:body', namespaces=NAMESPACES)


def _to_io_object(s):
    """If necessary it will convert the string to an io object
    (e.g. with read and write methods).
    """
    if not hasattr(s, 'read'):
        s = StringIO(s)
    return s


def cnxml_to_html(cnxml_source):
    """Transform the CNXML source to HTML"""
    source = _to_io_object(cnxml_source)
    xml = etree.parse(source)
    # Run the CNXML to HTML transform
    xml = transform(xml, 'cnxml-to-html5.xsl')
    xml = XHTML_MODULE_BODY_XPATH(xml)
    return etree.tostring(xml[0])


def html_to_cnxml(html_source, cnxml_source):
    """Transform the HTML to CNXML. We need the original CNXML content in
    order to preserve the metadata in the CNXML document.
    """
    source = _to_io_object(html_source)
    xml = etree.parse(source)
    cnxml = etree.parse(_to_io_object(cnxml_source))
    # Run the HTML to CNXML transform on it
    xml = _transform(xml, 'html5-to-cnxml.xsl')
    # Replace the original content element with the transformed one.
    namespaces = {'c': 'http://cnx.rice.edu/cnxml'}
    xpath = etree.XPath('//c:content', namespaces=namespaces)
    replaceable_node = xpath(cnxml)[0]
    replaceable_node.getparent().replace(replaceable_node, xml.getroot())
    # Set the content into the existing cnxml source
    return etree.tostring(cnxml)


def main():
    """Commandline utility for transforming an html document to cnxml."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('document',
                        type=argparse.FileType('r'),
                        default=sys.stdin,
                        help="the filesystem location of the html document")
    parser.add_argument('cnxml_document',
                        type=argparse.FileType('r'),
                        help="the existing CNXML document")
    args = parser.parse_args()

    result = html_to_cnxml(args.document, args.cnxml_document)
    print(result)

    sys.exit(0)


if __name__ == '__main__':
    main()
