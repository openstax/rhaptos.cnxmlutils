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
        self.assertEqual(elm.attrib['data-alt'], '')

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
        self.assertEqual(elm.attrib['data-display'], 'block')
        self.assertEqual(elm.attrib['class'], 'media')
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
        self.assertEqual(elm.attrib['class'], 'download')
        self.assertEqual(elm.attrib['href'], 'oralPresentGuide.ppt')
        # Check download@mime-type attribute name change.
        self.assertEqual(elm.attrib['data-media-type'],
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
        # Check download@longdesc -> @data-longdesc
        self.assertEqual(elm.attrib['data-longdesc'],
                         'Long download description')
        # Check download@for -> @data-print
        self.assertEqual(elm.attrib['data-print'], 'true')

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
            elm = html.xpath("//*[@id='test_media_image_w_optional_attrs']/a")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the image->img tag transform: " + transformed_html)

        # Link to the actual image
        self.assertEqual(elm.attrib['href'], 'Picture 2.jpg')
        elm = elm.xpath('img')[0]
        # Optional attributes...
        self.assertEqual(elm.attrib['height'], '302')
        self.assertEqual(elm.attrib['width'], '502')
        # This comes from the parent c:media@alt
        self.assertEqual(elm.attrib['alt'],
                         'alternative text')
        self.assertEqual(elm.attrib['id'], 'id2204878__onlineimage')
        self.assertEqual(elm.attrib['data-longdesc'], 'image long description')
        self.assertEqual(elm.attrib['data-print-width'], '700')
        self.assertEqual(elm.attrib['src'], 'Picture 2 tumbnail.jpg')

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
        self.assertEqual(elm.attrib['alt'], "alternative text")

    def test_media_image_parent_alt(self):
        # Use the parent @alt when @alt do not exist.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        elm = html.xpath("//img[@id='test_media_image_parent_alt']")[0]
        self.assertEqual(elm.attrib['alt'], "media alt")

    def test_media_flash(self):
        # Case to test the conversion of c:media/c:flash transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-flash.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_flash']/object")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the flash->object tag transform: " + transformed_html)
        self.assertEqual(elm.attrib['data'], 'Subtopic2-Sc_3_static.swf')
        self.assertEqual(elm.attrib['type'], 'application/x-shockwave-flash')
        self.assertEqual(elm.attrib['height'], '380')
        self.assertEqual(elm.attrib['width'], '580')

        try:
            embed_elm = elm.xpath("embed")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to transform flash->object/embed tag: " \
                      + transformed_html)
        self.assertEqual(embed_elm.attrib['src'], 'Subtopic2-Sc_3_static.swf')
        self.assertEqual(embed_elm.attrib['type'],
                         'application/x-shockwave-flash')
        self.assertEqual(embed_elm.attrib['height'], '380')
        self.assertEqual(embed_elm.attrib['width'], '580')
        try:
            param_elm = elm.xpath('param')[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to transform flash/param->object/param tag: " \
                      + transformed_html)
        self.assertEqual(param_elm.attrib['name'], 'faux')
        self.assertEqual(param_elm.attrib['value'], 'faux-value')

    def test_media_flash_generic_attrs(self):
        # Generic attributes tests.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-flash.cnxml'))
        html = self.call_target(cnxml).getroot()

        elm = html.xpath("//*[@id='test_media_flash_generic_attrs']/object")[0]
        self.assertEqual(elm.attrib['id'], '123abc')
        self.assertEqual(elm.attrib['data-longdesc'], 'flash long description')

    def test_media_param(self):
        # Case to test the conversion of c:media/*/c:param transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-param.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_param']/img")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the param-> parent attributes transform: " \
                      + transformed_html)

        # c:param/@name to img@*
        self.assertEqual(elm.attrib['onclick'],
                         "window.open('http://rup.rice.edu/flowering-light.html','','');")
        self.assertEqual(elm.attrib['onmouseover'],
                         "document.body.style.cursor = 'hand';")
        self.assertEqual(elm.attrib['onmouseout'],
                         "document.body.style.cursor = 'default';")

    def test_media_audio(self):
        # Case to test the conversion of c:media/*/c:audio transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-audio.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_audio']/audio")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the audio->audio tag transform: " \
                      + transformed_html)
        self.assertTrue('src' not in elm.attrib)
        self.assertEqual(elm.attrib['id'], "mus_shost")
        self.assertEqual(elm.attrib['data-media-type'], "audio/mpeg")
        self.assertEqual(elm.attrib['controls'], 'controls')
        elm = elm.xpath('source')[0]
        self.assertEqual(elm.attrib['src'],
                         "http://music.cnx.rice.edu/Brandt/times_effect/shostakovich_quartet.mp3")
        self.assertEqual(elm.attrib['type'], 'audio/mpeg')

    def test_media_audio_embedded(self):
        # Case for audio that needs to be embedded as a player.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-audio.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_audio_embedded']/audio")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the audio->audio tag transform: " \
                      + transformed_html)
        self.assertTrue('src' not in elm.attrib)
        self.assertEqual(elm.attrib['data-standby'], 'standby message')
        self.assertEqual(elm.attrib['controller'], 'true')
        self.assertEqual(elm.attrib['loop'], 'false')
        self.assertEqual(elm.attrib['autoplay'], 'autoplay')
        elm = elm.xpath('source')[0]
        self.assertEqual(elm.attrib['src'],
                         "http://music.cnx.rice.edu/Brandt/times_effect/shostakovich_quartet.mp3")
        self.assertEqual(elm.attrib['type'], 'audio/mpeg')

    def test_media_video(self):
        # Case for video that needs to be embedded as a player.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_video']/video")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the video->video tag transform: " \
                      + transformed_html)
        self.assertTrue('src' not in elm.attrib)
        self.assertEqual(elm.attrib['controls'], 'controls')
        elm = elm.xpath('source')[0]
        self.assertEqual(elm.attrib['src'],
                         "http://www.archive.org/download/CollaborativeStatistics_Lecture_Videos/CollaborativeStatistics_Chap09.mp4")
        self.assertEqual(elm.attrib['type'], 'video/mp4')

    def test_media_video_w_optional_attrs(self):
        # Case for video that needs to be embedded as a player.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_video_w_optional_attrs']/video")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the video->video tag transform: " \
                      + transformed_html)
        self.assertTrue('src' not in elm.attrib)
        self.assertEqual(elm.attrib['controls'], 'controls')
        self.assertEqual(elm.attrib['data-standby'], 'message')
        self.assertEqual(elm.attrib['controller'], 'true')
        self.assertEqual(elm.attrib['loop'], 'true')
        self.assertTrue('autoplay' not in elm.attrib)

    def test_media_java_applet(self):
        # Case for java-applet that needs to be object embedded.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-java-applet.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_java_applet']/object")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the java-applet->object tag transform: " \
                      + transformed_html)
        self.assertEqual(elm.attrib['type'], 'application/x-java-applet')
        self.assertEqual(elm.attrib['height'], '200')
        self.assertEqual(elm.attrib['width'], '600')
        elms = elm.xpath('param')
        elm_code, elm_codebase, elm_archive, elm_name, elm_src = elms
        self.assertEqual(elm_code.attrib,
                         {'name': 'code', 'value': 'AliasingDemo.class'})
        self.assertEqual(elm_codebase.attrib,
                         {'name': 'codebase', 'value': 'codebase.class'})
        self.assertEqual(elm_archive.attrib,
                         {'name': 'archive', 'value': 'Aliasing.jar'})
        self.assertEqual(elm_name.attrib,
                         {'name': 'name', 'value': 'Aliasing demo'})
        self.assertEqual(elm_src.attrib,
                         {'name': 'src', 'value': 'AliasingDemo.class'})

    def test_media_object(self):
        # Case for object pass-through.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-object.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_object']/object")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the object->object tag transform: " \
                      + transformed_html)
        self.assertEqual(elm.attrib['type'], 'application/vnd.wolfram.cdf')
        self.assertEqual(elm.attrib['data'], 'TimeshifterDrill_display.cdf')
        self.assertEqual(elm.attrib['width'], '400')
        self.assertEqual(elm.attrib['height'], '400')
        # And ensure param pass through.
        elm = elm.xpath('param')[1]
        self.assertEqual(elm.attrib['name'], 'faux2')
        self.assertEqual(elm.attrib['value'], 'faux-value')

    def test_media_labview(self):
        # Case for labview to object transform.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-labview.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_labview']/object")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the labview->object tag transform: " \
                      + transformed_html)
        self.assertEqual(elm.attrib['type'], 'application/x-labviewrpvi80')
        self.assertEqual(elm.attrib['data'], 'DFD_Utility.llb')
        self.assertEqual(elm.attrib['width'], '840')
        self.assertEqual(elm.attrib['height'], '540')
        # And ensure param pass through.
        pass


    def test_list_w_title_2_section(self):
        """Verify conversion of //c:list[c:title] to sections."""
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'titles.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='listed-section-list']")[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to transform: \n" + transformed_html)
        title_elm, list_elm = elm.getchildren()
        # This list becomes a section inside the current section,
        # giving it a depth of 2, which creates an h2 tag.
        self.assertEqual(title_elm.tag, 'h2')
        self.assertEqual(list_elm.tag, 'ul')
