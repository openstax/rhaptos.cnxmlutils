# -*- coding: utf-8 -*-
"""
Copyright (C) 2013 Rice University

This software is subject to the provisions of the
GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).
See LICENSE.txt for details.

Various utility/helper functions...
Some of thses are used to tranform from one source format to another.

"""
import pkg_resources
from lxml import etree
from lxml.html import tostring as tohtml
from functools import partial
# requires tidy-html5 from https://github.com/w3c/tidy-html5
# Installation: http://goo.gl/FG27n
from tidylib import tidy_document
# for unescaping math from Mathjax script tag
from xml.sax.saxutils import unescape

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO

from . import __version__ as version

__all__ = (
    'NAMESPACES', 'XHTML_INCLUDE_XPATH', 'XHTML_MODULE_BODY_XPATH',
    'cnxml_to_html', 'html_to_cnxml',
    )

NAMESPACES = {
    'xhtml': 'http://www.w3.org/1999/xhtml',
    }
XHTML_INCLUDE_XPATH = etree.XPath('//xhtml:a[@class="include"]',
                                  namespaces=NAMESPACES)
XHTML_MODULE_BODY_XPATH = etree.XPath('//xhtml:body', namespaces=NAMESPACES)


def _pre_tidy(html):
    """ This method transforms a few things before tidy runs. When we get rid
        of tidy, this can go away. """
    tree = etree.fromstring(html, etree.HTMLParser())
    for el in tree.xpath('//u'):
        el.tag = 'em'
        c = el.attrib.get('class', '').split()
        if 'underline' not in c:
            c.append('underline')
            el.attrib['class'] = ' '.join(c)

    return tohtml(tree)


def _post_tidy(html):
    """ This method transforms post tidy. Will go away when tidy goes away. """
    tree = etree.fromstring(html)
    ems = tree.xpath(
        "//xh:em[@class='underline']|//xh:em[contains(@class, ' underline ')]",
        namespaces={'xh': 'http://www.w3.org/1999/xhtml'})
    for el in ems:
        c = el.attrib.get('class', '').split()
        c.remove('underline')
        el.tag = '{http://www.w3.org/1999/xhtml}u'
        if c:
            el.attrib['class'] = ' '.join(c)
        elif 'class' in el.attrib:
            del(el.attrib['class'])

    return tree


# Tidy up the Google Docs HTML Soup
def _tidy2xhtml5(html):
    """Tidy up a html4/5 soup to a parsable valid XHTML5.
    Requires tidy-html5 from https://github.com/w3c/tidy-html5
    Installation: http://goo.gl/FG27n
    """
    html = _io2string(html)
    html = _pre_tidy(html)  # Pre-process
    xhtml5, errors =\
        tidy_document(html,
                      options={
                          # do not merge nested div elements
                          # - preserve semantic block structrues
                          'merge-divs': 0,
                          # create xml output
                          'output-xml': 1,
                          # Don't use indent, adds extra linespace or linefeed
                          # which are big problems
                          'indent': 0,
                          # No tidy meta tag in output
                          'tidy-mark': 0,
                          # No wrapping
                          'wrap': 0,
                          # Help ensure validation
                          'alt-text': '',
                          # No sense in transitional for tool-generated markup
                          'doctype': 'strict',
                          # May not get what you expect,
                          # but you will get something
                          'force-output': 1,
                          # remove HTML entities like e.g. nbsp
                          'numeric-entities': 1,
                          # remove
                          'clean': 1,
                          'bare': 1,
                          'word-2000': 1,
                          'drop-proprietary-attributes': 1,
                          # enclose text in body always with <p>...</p>
                          'enclose-text': 1,
                          # transforms <i> and <b> to <em> and <strong>
                          'logical-emphasis': 1,
                          # do not tidy all MathML elements!
                          # List of MathML 3.0 elements from
                          # http://www.w3.org/TR/MathML3/appendixi.html#index.elem
                          'new-inline-tags': 'abs, and, annotation, '
                          'annotation-xml, apply, approx, arccos, arccosh, '
                          'arccot, arccoth, arccsc, arccsch, arcsec, arcsech, '
                          'arcsin, arcsinh, arctan, arctanh, arg, bind, bvar, '
                          'card, cartesianproduct, cbytes, ceiling, cerror, '
                          'ci, cn, codomain, complexes, compose, condition, '
                          'conjugate, cos, cosh, cot, coth, cs, csc, csch, '
                          'csymbol, curl, declare, degree, determinant, diff, '
                          'divergence, divide, domain, domainofapplication, '
                          'el, emptyset, eq, equivalent, eulergamma, exists, '
                          'exp, exponentiale, factorial, factorof, false, '
                          'floor, fn, forall, gcd, geq, grad, gt, ident, '
                          'image, imaginary, imaginaryi, implies, in, '
                          'infinity, int, integers, intersect, interval, '
                          'inverse, lambda, laplacian, lcm, leq, limit, list, '
                          'ln, log, logbase, lowlimit, lt, maction, malign, '
                          'maligngroup, malignmark, malignscope, math, '
                          'matrix, matrixrow, max, mean, median, menclose, '
                          'merror, mfenced, mfrac, mfraction, mglyph, mi, '
                          'min, minus, mlabeledtr, mlongdiv, mmultiscripts, '
                          'mn, mo, mode, moment, momentabout, mover, mpadded, '
                          'mphantom, mprescripts, mroot, mrow, ms, mscarries, '
                          'mscarry, msgroup, msline, mspace, msqrt, msrow, '
                          'mstack, mstyle, msub, msubsup, msup, mtable, mtd, '
                          'mtext, mtr, munder, munderover, naturalnumbers, '
                          'neq, none, not, notanumber, note, notin, '
                          'notprsubset, notsubset, or, otherwise, '
                          'outerproduct, partialdiff, pi, piece, piecewise, '
                          'plus, power, primes, product, prsubset, quotient, '
                          'rationals, real, reals, reln, rem, root, '
                          'scalarproduct, sdev, sec, sech, selector, '
                          'semantics, sep, set, setdiff, share, sin, sinh, '
                          'subset, sum, tan, tanh, tendsto, times, transpose, '
                          'true, union, uplimit, variance, vector, '
                          'vectorproduct, xor',
                          'doctype': 'html5',
                          })

    # return xhtml5
    # return the tree itself, there is another modification below to avoid
    # another parse
    return _post_tidy(xhtml5)


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
    path = pkg_resources.resource_filename('rhaptos.cnxmlutils.xsl', filename)
    xml = etree.parse(path)
    return etree.XSLT(xml)


def _transform(xsl_filename, xml, **kwargs):
    """Transforms the xml using the specifiec xsl file."""
    xslt = _make_xsl(xsl_filename)
    xml = xslt(xml, **kwargs)
    return xml


def _unescape_math(xml):
    """Unescapes Math from Mathjax to MathML."""
    xpath_math_script = etree.XPath(
            '//x:script[@type="math/mml"]',
            namespaces={'x': 'http://www.w3.org/1999/xhtml'})
    math_script_list = xpath_math_script(xml)
    for mathscript in math_script_list:
        math = mathscript.text
        # some browsers double escape like e.g. Firefox
        math = unescape(unescape(math))
        mathscript.clear()
        mathscript.set('type', 'math/mml')
        new_math = etree.fromstring(math)
        mathscript.append(new_math)
    return xml


def cnxml_to_html(cnxml_source):
    """Transform the CNXML source to HTML"""
    source = _string2io(cnxml_source)
    xml = etree.parse(source)
    # Run the CNXML to HTML transform
    xml = _transform('cnxml-to-html5.xsl', xml,
                     version='"{}"'.format(version))
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


def aloha_to_etree(html_source):
    """ Converts HTML5 from Aloha editor output to a lxml etree. """
    xml = _tidy2xhtml5(html_source)
    for i, transform in enumerate(ALOHA2HTML_TRANSFORM_PIPELINE):
        xml = transform(xml)
    return xml


def aloha_to_html(html_source):
    """Converts HTML5 from Aloha to a more structured HTML5"""
    xml = aloha_to_etree(html_source)
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


def etree_to_valid_cnxml(tree, **kwargs):
    for i, transform in enumerate(HTML2VALID_CNXML_TRANSFORM_PIPELINE):
        tree = transform(tree)
    return etree.tostring(tree, **kwargs)


def html_to_valid_cnxml(html_source):
    """Transform the HTML to valid CNXML (used for OERPUB).
    No original CNXML is needed.  If HTML is from Aloha please use
    aloha_to_html before using this method
    """
    source = _string2io(html_source)
    xml = etree.parse(source)
    return etree_to_valid_cnxml(xml, pretty_print=True)
