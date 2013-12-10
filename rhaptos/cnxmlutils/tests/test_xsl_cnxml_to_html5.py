# -*- coding: utf-8 -*-
import os
import unittest
from lxml import etree


here = os.path.abspath(os.path.dirname(__file__))
TEST_DATA_DIR = os.path.join(here, 'data')

CNXML_SHELL = """\
<document xmlns="http://cnx.rice.edu/cnxml" xmlns:cnxorg="http://cnx.rice.edu/system-info" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:md="http://cnx.rice.edu/mdml" xmlns:q="http://cnx.rice.edu/qml/1.0" xmlns:bib="http://bibtexml.sf.net/" id="new" module-id="" cnxml-version="0.7">
  <title></title>
  <metadata mdml-version="0.5"></metadata>
  <content>
    {}
  </content>
</document>
"""



class CxnmlToHtmlTestCase(unittest.TestCase):
    # c:media/c:download cases also test general c:media transformation.

    def test_media(self):
        # Case to test the conversion of c:media transformation.
        import rhaptos.cnxmlutils
        xsl_dir = os.path.join(os.path.dirname(rhaptos.cnxmlutils.__file__),
                               'xsl')
        xsl = etree.parse(os.path.join(xsl_dir, 'cnxml-to-html5.xsl'))
        target = etree.XSLT(xsl)

        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = target(cnxml).getroot()

        # Test the required attributes have been transformed: id and alt
        try:
            elm = html.xpath("//*[@id='idm1802560']")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id: " + transformed_html)
        self.assertEqual(elm.attrib['class'], 'media')
        self.assertEqual(elm.attrib['data-alt'], '')

    def test_media_w_optional_attrs(self):
        # Case to test the conversion of c:media transformation.
        import rhaptos.cnxmlutils
        xsl_dir = os.path.join(os.path.dirname(rhaptos.cnxmlutils.__file__),
                               'xsl')
        xsl = etree.parse(os.path.join(xsl_dir, 'cnxml-to-html5.xsl'))
        target = etree.XSLT(xsl)

        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = target(cnxml).getroot()

        # Test the required attributes have been transformed: id and alt
        try:
            elm = html.xpath("//*[@id='other-media']")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id: " + transformed_html)
        # Check concatenation of media@display.
        self.assertEqual(elm.attrib['class'], 'media block')
        # Check media@longdesc attribute name change.
        self.assertEqual(elm.attrib['data-longdesc'],
                         'Long media description')

    def test_media_download(self):
        # Case to test the conversion of c:media/c:download transformation.
        import rhaptos.cnxmlutils
        xsl_dir = os.path.join(os.path.dirname(rhaptos.cnxmlutils.__file__),
                               'xsl')
        xsl = etree.parse(os.path.join(xsl_dir, 'cnxml-to-html5.xsl'))
        target = etree.XSLT(xsl)

        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = target(cnxml).getroot()

        # Test the required attributes have been transformed: id and alt
        try:
            elm = html.xpath("//*[@id='idm1802560']/a")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the download->a tag transform: " + transformed_html)
        self.assertEqual(elm.attrib['href'], 'oralPresentGuide.ppt')
        # Check download@mime-type attribute name change.
        self.assertEqual(elm.attrib['data-mime-type'],
                         'application/vnd.ms-powerpoint')
        self.assertEqual(elm.text, 'oralPresentGuide.ppt')

    def test_media_download_w_optional_attrs(self):
        # Case to test the conversion of c:media/c:download transformation.
        import rhaptos.cnxmlutils
        xsl_dir = os.path.join(os.path.dirname(rhaptos.cnxmlutils.__file__),
                               'xsl')
        xsl = etree.parse(os.path.join(xsl_dir, 'cnxml-to-html5.xsl'))
        target = etree.XSLT(xsl)

        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = target(cnxml).getroot()

        # Test the required attributes have been transformed: id and alt
        try:
            elm = html.xpath("//*[@id='other-media']/a")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the download->a tag transform: " + transformed_html)
        # Check download@longdesc -> @alt
        self.assertEqual(elm.attrib['alt'], 'Long download description')
        # Check download@for -> @data-for
        self.assertEqual(elm.attrib['data-for'], 'pdf')
