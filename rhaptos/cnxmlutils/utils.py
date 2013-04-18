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
from xml.sax.saxutils import unescape # for unescaping math from Mathjax script tag
from copy import deepcopy
from xhtmlpremailer import xhtmlPremailer

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
            # do not tidy all MathML elements! List of MathML 3.0 elements from http://www.w3.org/TR/MathML3/appendixi.html#index.elem
            'new-inline-tags': 'abs, and, annotation, annotation-xml, apply, approx, arccos, arccosh, arccot, arccoth, arccsc, arccsch, arcsec, arcsech, arcsin, arcsinh, arctan, arctanh, arg, bind, bvar, card, cartesianproduct, cbytes, ceiling, cerror, ci, cn, codomain, complexes, compose, condition, conjugate, cos, cosh, cot, coth, cs, csc, csch, csymbol, curl, declare, degree, determinant, diff, divergence, divide, domain, domainofapplication, el, emptyset, eq, equivalent, eulergamma, exists, exp, exponentiale, factorial, factorof, false, floor, fn, forall, gcd, geq, grad, gt, ident, image, imaginary, imaginaryi, implies, in, infinity, int, integers, intersect, interval, inverse, lambda, laplacian, lcm, leq, limit, list, ln, log, logbase, lowlimit, lt, maction, malign, maligngroup, malignmark, malignscope, math, matrix, matrixrow, max, mean, median, menclose, merror, mfenced, mfrac, mfraction, mglyph, mi, min, minus, mlabeledtr, mlongdiv, mmultiscripts, mn, mo, mode, moment, momentabout, mover, mpadded, mphantom, mprescripts, mroot, mrow, ms, mscarries, mscarry, msgroup, msline, mspace, msqrt, msrow, mstack, mstyle, msub, msubsup, msup, mtable, mtd, mtext, mtr, munder, munderover, naturalnumbers, neq, none, not, notanumber, note, notin, notprsubset, notsubset, or, otherwise, outerproduct, partialdiff, pi, piece, piecewise, plus, power, primes, product, prsubset, quotient, rationals, real, reals, reln, rem, root, scalarproduct, sdev, sec, sech, selector, semantics, sep, set, setdiff, share, sin, sinh, subset, sum, tan, tanh, tendsto, times, transpose, true, union, uplimit, variance, vector, vectorproduct, xor',
            'doctype': 'html5',
            })
    # print xhtml5
    return xhtml5

# Move CSS from stylesheet inside the tags with. BTW: Premailer does this usually for old email clients.
# Use a special XHTML Premailer which does not destroy the XML structure.
def _premail(xhtml):
    premailer = xhtmlPremailer(xhtml)
    premailed_xhtml = premailer.transform()
    return premailed_xhtml

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

def _unescape_math(xml):
    """Unescapes Math from Mathjax to MathML."""
    xpath_math_script = etree.XPath('//x:script[@type="math/mml"]', namespaces={'x':'http://www.w3.org/1999/xhtml'})
    math_script_list = xpath_math_script(xml)
    for mathscript in math_script_list:
        math = mathscript.text
        math = unescape(unescape(math)) # some browsers double escape like e.g. Firefox
        mathscript.clear()
        mathscript.set('type', 'math/mml')
        new_math = etree.fromstring(math)
        mathscript.append( new_math )
    return xml

def cnxml_to_html(cnxml_source):
    """Transform the CNXML source to HTML"""
    source = _string2io(cnxml_source)
    xml = etree.parse(source)
    # Run the CNXML to HTML transform
    xml = _transform('cnxml-to-html5.xsl', xml)
    xml = XHTML_MODULE_BODY_XPATH(xml)
    return etree.tostring(xml[0])


ALOHA2HTML_TRANSFORM_PIPELINE = [
    partial(_transform, 'aloha-to-html5-pass01-leveled-headers.xsl'),
    partial(_transform, 'aloha-to-html5-pass02-new-min-header-level.xsl'),
    partial(_transform, 'aloha-to-html5-pass03-nested-headers.xsl'),
    partial(_transform, 'aloha-to-html5-pass04-headers2sections.xsl'),
    _unescape_math,
    partial(_transform, 'aloha-to-html5-pass05-mathjax2mathml.xsl'),
    partial(_transform, 'aloha-to-html5-pass06-postprocessing.xsl'),
]

def aloha_to_html(html_source):
    """Converts HTML5 from Aloha to a more structured HTML5"""
    tidy_xhtml5 = _tidy2xhtml5(html_source) # make from a html4/5 soup a XHTML5 string
    premailed_xhtml5 = _premail(tidy_xhtml5) # move css from classes to attributes
    # print premailed_xhtml5
    source = _string2io(premailed_xhtml5)
    xml = etree.parse(source)
    for i, transform in enumerate(ALOHA2HTML_TRANSFORM_PIPELINE):
        xml = transform(xml)
    return etree.tostring(xml, pretty_print=True)

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

HTML2VALID_CNXML_TRANSFORM_PIPELINE = [
    partial(_transform, 'html5-to-cnxml-pass01-cleanup.xsl'),
    partial(_transform, 'html5-to-cnxml-pass02-enclose-para.xsl'),
    partial(_transform, 'html5-to-cnxml-pass03-xhtml2cnxml.xsl'),
    # TODO: Recognize mime type of images here!
    partial(_transform, 'html5-to-cnxml-pass04-postprocessing.xsl'),
    partial(_transform, 'html5-to-cnxml-pass05-cnxml-id-generation.xsl'),
    partial(_transform, 'html5-to-cnxml-pass06-cnxml-postprocessing.xsl'),
]

def html_to_valid_cnxml(html_source):
    """Transform the HTML to valid CNXML (used for OERPUB). No original CNXML is needed.
    If HTML is from Aloha please use aloha_to_html before using this method
    """
    source = _string2io(html_source)
    xml = etree.parse(source)
    for i, transform in enumerate(HTML2VALID_CNXML_TRANSFORM_PIPELINE):
        xml = transform(xml)
    return etree.tostring(xml, pretty_print=True)
