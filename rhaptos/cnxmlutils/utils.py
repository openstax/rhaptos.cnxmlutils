# -*- coding: utf-8 -*-
"""Various utility/helper functions...
Some of thses are used to tranform from one source format to another.

"""
try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO
import pkg_resources
from lxml import etree
from functools import partial
from tidylib import tidy_document # requires tidy-html5 from https://github.com/w3c/tidy-html5 Installation: http://goo.gl/FG27n

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

# Tidy up the Google Docs HTML Soup
def _tidy2xhtml5(html):
    """Tidy up a html4/5 soup to a parsable valid XHTML5.
    Requires tidy-html5 from https://github.com/w3c/tidy-html5 Installation: http://goo.gl/FG27n
    """
    #import pdb;pdb.set_trace()
    html = _io2string(html)
    xhtml5, errors = tidy_document(html,
        options={
            'output-xml': 1,       # create xml output
            'indent': 0,           # Don't use indent, add's extra linespace or linefeeds which are big problems
            'tidy-mark': 0,        # No tidy meta tag in output
            'wrap': 0,             # No wrapping
            'alt-text': '',        # Help ensure validation
            'doctype': 'strict',   # Little sense in transitional for tool-generated markup...
            'force-output': 1,     # May not get what you expect but you will get something
            'numeric-entities': 1, # remove HTML entities like e.g. nbsp
            'clean': 1,            # remove
            'bare': 1,
            'word-2000': 1,
            'drop-proprietary-attributes': 1,
            'enclose-text': 1,     # enclose text in body always with <p>...</p>
            'logical-emphasis': 1, # transforms <i> and <b> text to <em> and <strong> text
            'doctype': 'html5',
            })
    #print errors # for debugging
    return xhtml5

def _io2string(s):
    """If necessary it will convert the io object to an string
    """
    if hasattr(s, 'read'):
        s = s.read()
    return s

def _string2io(s):
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

def _transform(xsl_filename, xml):
    """Transforms the xml using the specifiec xsl file."""
    xslt = _make_xsl(xsl_filename)
    xml = xslt(xml)
    return xml

def _transform_string(xsl_filename, xml_string):
    source = _string2io(xml_string)
    xml = etree.parse(source)
    return etree.tostring(_transform(xsl_filename, xml))

def cnxml_to_html(cnxml_source):
    """Transform the CNXML source to HTML"""
    source = _string2io(cnxml_source)
    xml = etree.parse(source)
    # Run the CNXML to HTML transform
    xml = _transform('cnxml-to-html5.xsl', xml)
    xml = XHTML_MODULE_BODY_XPATH(xml)
    return etree.tostring(xml[0])


ALOHA2HTML_TRANSFORM_PIPELINE = [
    _tidy2xhtml5,
    partial(_transform_string, 'aloha-to-html5-pass01-leveled-headers.xsl'),
    partial(_transform_string, 'aloha-to-html5-pass02-new-min-header-level.xsl'),
    partial(_transform_string, 'aloha-to-html5-pass03-nested-headers.xsl'),
    partial(_transform_string, 'aloha-to-html5-pass04-headers2sections.xsl'),
]

def aloha_to_html(html_source):
    """Converts HTML5 from Aloha to a more structured HTML5"""
    xml = html_source
    for i, transform in enumerate(ALOHA2HTML_TRANSFORM_PIPELINE):
        xml = transform(xml)
    return xml

def html_to_cnxml(html_source, cnxml_source):
    """Transform the HTML to CNXML. We need the original CNXML content in
    order to preserve the metadata in the CNXML document.
    """
    source = _string2io(html_source)
    xml = etree.parse(source)
    cnxml = etree.parse(_string2io(cnxml_source))
    # Run the HTML to CNXML transform on it
    xml = _transform('html5-to-cnxml.xsl', xml)
    # Replace the original content element with the transformed one.
    namespaces = {'c': 'http://cnx.rice.edu/cnxml'}
    xpath = etree.XPath('//c:content', namespaces=namespaces)
    replaceable_node = xpath(cnxml)[0]
    replaceable_node.getparent().replace(replaceable_node, xml.getroot())
    # Set the content into the existing cnxml source
    return etree.tostring(cnxml)
