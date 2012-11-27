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
    'make_xsl', 'transform',
    )

PACKAGE = ''.join(['.' + x for x in __name__.split('.')[:-1]])[1:]
NAMESPACES = {
    'xhtml':'http://www.w3.org/1999/xhtml',
    }
XHTML_INCLUDE_XPATH = etree.XPath('//xhtml:a[@class="include"]',
                                  namespaces=NAMESPACES)
XHTML_MODULE_BODY_XPATH = etree.XPath('//xhtml:body', namespaces=NAMESPACES)


def transform(xml, xsl_filename, xsl_package='rhatpos.cnxmlutils.xsl'):
    """Transforms the xml using the specifiec xsl file."""
    xslt = make_xsl(xsl_filename, xsl_package)
    xml = xslt(xml)
    return xml

def make_xsl(filename, package=PACKAGE):
    """Helper that creates a XSLT stylesheet."""
    path = pkg_resources.resource_filename(package, filename)
    xml = etree.parse(path)
    return etree.XSLT(xml)
