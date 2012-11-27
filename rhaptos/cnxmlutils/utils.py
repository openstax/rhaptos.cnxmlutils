# -*- coding: utf-8 -*-
"""Various utility/helper functions...
Some of thses are used to tranform from one source format to another.

"""
try:
    from io import StringIO
except ImportError:
    from io import StringIO
import pkg_resources
from lxml import etree


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
    source = _to_io_object(cnxml_source)
    xml = etree.parse(source)
    # Run the CNXML to HTML transform
    xml = _transform(xml, 'cnxml-to-html5.xsl')
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
