# -*- coding: utf-8 -*-
"""Converts a piece of HTML5 (just the body tag element) and an existing
CNXML document into a CNXML document. The existing CNXML Document is necessary
to preserve the previously document's metadata.
The results are sent to standard out.
"""
import sys
try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO
import pkg_resources
from lxml import etree
from rhaptos.cnxmlutils.xml2xhtml import MODULE_BODY_XPATH


def _to_io_object(s):
    """If necessary it will convert the string to an io object
    (e.g. with read and write methods).
    """
    if not hasattr(s, 'read'):
        s = StringIO(s)
    return s

# These functions have been copied...
# from Products.RhaptosModuleEditor.utils. See that source as
# the most recent up-to-date and in use copy.

def _make_xsl(filename):
    """Helper that creates a XSLT stylesheet """
    package = 'rhaptos.cnxmlutils'
    sub_package = 'xsl'

    if package != '':
        pkg = package + '.' + sub_package
        path = pkg_resources.resource_filename(pkg, filename)
        xml = etree.parse(path)
        return etree.XSLT(xml)

def _transform(xml, xsl_filename):
    """Transforms the xml using the specifiec xsl file."""
    xslt = _make_xsl(xsl_filename)
    xml = xslt(xml)
    return xml

def cnxml_to_html(cnxml_source):
    """Transform the CNXML source to HTML"""
    source = StringIO(cnxml_source)
    xml = etree.parse(source)
    # Run the CNXML to HTML transform
    xml = _transform(xml, 'cnxml-to-html5.xsl')
    xml = MODULE_BODY_XPATH(xml)
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
    try:
        import argparse
    except ImportError:
        print("The 'argparse' distribution is needed "
              "to run from the commandline")
        print("Recommendation: Use the 'cmdline_support'' requirement extra.")
        return 2

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('document', nargs=1,
                        type=argparse.FileType('r'),
                        default=sys.stdin,
                        help="the filesystem location of the html document")
    parser.add_argument('cnxml_document', nargs=1,
                        type=argparse.FileType('r'),
                        help="the existing CNXML document")
    args = parser.parse_args()

    result = html_to_cnxml(args.document[0], args.cnxml_document[0])

    print(result)

    return 0

if __name__ == '__main__':
    sys.exit(main())
