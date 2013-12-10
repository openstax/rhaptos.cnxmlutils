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

    def call_target(self, *args, **kwargs):
        target = getattr(self, '_target', None)
        if target is None:
            import rhaptos.cnxmlutils
            xsl_dir = os.path.join(os.path.dirname(rhaptos.cnxmlutils.__file__),
                                   'xsl')
            xsl = etree.parse(os.path.join(xsl_dir, 'cnxml-to-html5.xsl'))
            target = etree.XSLT(xsl)
            setattr(self, '_target', target)
        return target(*args, **kwargs)

    def test_media(self):
        # Case to test the conversion of c:media transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = self.call_target(cnxml).getroot()

        # Test the required attributes have been transformed: id and alt
        try:
            elm = html.xpath("//*[@id='idm1802560']")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id: " + transformed_html)
        self.assertEqual(elm.attrib['class'], 'media')
        self.assertEqual(elm.attrib['alt'], '')

    def test_media_w_optional_attrs(self):
        # Case to test the conversion of c:media transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = self.call_target(cnxml).getroot()

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
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = self.call_target(cnxml).getroot()

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
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-download.cnxml'))
        html = self.call_target(cnxml).getroot()

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

    def test_media_image(self):
        # Case to test the conversion of c:media/c:image transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='id1169537615277_media']/img")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the image->img tag transform: " + transformed_html)
        
        self.assertEqual(elm.attrib['src'], 'graphics1.jpg')
        self.assertEqual(elm.attrib['data-media-type'], 'image/jpg')
        
    def test_media_image_w_optional_attrs(self):
        # Case to test the conversion of c:media/c:image transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_image_w_optional_attrs']/img")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the image->img tag transform: " + transformed_html)
        
        # Optional attributes...
        self.assertEqual(elm.attrib['height'], '302')
        self.assertEqual(elm.attrib['width'], '502')
        # This comes from the parent c:media@alt
        self.assertEqual(elm.attrib['alt'],
                         'alternative text')
        self.assertEqual(elm.attrib['id'], 'id2204878__onlineimage')
        self.assertEqual(elm.attrib['data-longdesc'], 'image long description')
        self.assertEqual(elm.attrib['data-print-width'], '700')
        self.assertEqual(elm.attrib['data-thumbnail'], 'Picture 2 tumbnail.jpg')

    def test_media_image_for_attribute(self):
        # Case to test the conversion of c:media/c:image transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR,
                                         'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        # @for (default, pdf and online)
        default_elm, online_elm, pdf_elm = html.xpath("//*[@id='test_media_image_for_attribute']/*")

        # - 'default' translates to 'online'
        self.assertNotIn('data-print', default_elm.attrib)
        # - 'online'
        self.assertNotIn('data-print', online_elm.attrib)
        # - 'pdf' (aka print)
        self.assertEqual(pdf_elm.attrib['data-print'], 'true')

        # @for should not be found an any of the results.
        for elm in (default_elm, pdf_elm, online_elm,):
            self.assertNotIn('for', elm.attrib)

    def test_media_image_alt(self):
        # Ensure @alt pass through.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        elm = html.xpath("//img[@id='test_media_image_alt']")[0]
        self.assertEqual(elm.attrib['alt'], "from the image tag")

    def test_media_image_parent_alt(self):
        # Use the parent @alt when @alt do not exist.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        elm = html.xpath("//img[@id='test_media_image_parent_alt']")[0]
        self.assertEqual(elm.attrib['alt'], "media alt")
