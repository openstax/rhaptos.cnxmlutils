# -*- coding: utf-8 -*-
import glob
import os
import subprocess
import unittest

from lxml import etree

version = 'v0.test'

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


class CnxmlToHtmlTestCase(unittest.TestCase):
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
        kwargs['version'] = etree.XSLT.strparam(version)
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
        self.assertEqual(elm.attrib['data-type'], 'media')
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
        self.assertEqual(elm.attrib['data-type'], 'media')
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
            elm = html.xpath("//*[@id='idm1802560']/h:a",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the download->a tag transform: " + transformed_html)
        self.assertEqual(elm.attrib['data-type'], 'download')
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
            elm = html.xpath("//*[@id='other-media']/h:a",
                             namespaces={'h': html.nsmap[None]})[0]
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
            elm = html.xpath("//*[@id='id1169537615277_media']/h:img",
                             namespaces={'h': html.nsmap[None]})[0]
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
            elm = html.xpath(
                "//*[@id='test_media_image_w_optional_attrs']/h:a",
                namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the image->img tag transform: " + transformed_html)

        # Link to the actual image
        self.assertEqual(elm.attrib['href'], 'Picture 2.jpg')
        elm = elm.xpath('h:img', namespaces={'h': html.nsmap[None]})[0]
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
        default_elm, online_elm, pdf_elm = html.xpath(
            "//*[@id='test_media_image_for_attribute']/*")

        # - 'default'
        self.assertNotIn('data-print', default_elm.attrib)
        # - 'online'
        self.assertEqual(online_elm.attrib['data-print'], 'false')
        # - 'pdf' (aka print)
        self.assertEqual(pdf_elm.attrib['data-print'], 'true')

        # @for should not be found an any of the results.
        for elm in (default_elm, pdf_elm, online_elm,):
            self.assertNotIn('for', elm.attrib)

    def test_media_image_alt(self):
        # Ensure @alt pass through.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        elm = html.xpath("//h:img[@id='test_media_image_alt']",
                         namespaces={'h': html.nsmap[None]})[0]
        self.assertEqual(elm.attrib['alt'], "alternative text")

    def test_media_image_parent_alt(self):
        # Use the parent @alt when @alt do not exist.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        elm = html.xpath("//h:img[@id='test_media_image_parent_alt']",
                         namespaces={'h': html.nsmap[None]})[0]
        self.assertEqual(elm.attrib['alt'], "media alt")

    def test_media_image_with_print_width(self):
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-image.cnxml'))
        html = self.call_target(cnxml).getroot()

        elm = html.xpath("//h:img[@id='test_media_image_with_print_width']",
                         namespaces={'h': html.nsmap[None]})[0]
        self.assertEqual(elm.attrib['data-print-width'], "6.5in")

    def test_media_flash(self):
        # Case to test the conversion of c:media/c:flash transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-flash.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_flash']/h:object",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the flash->object tag transform: " + transformed_html)
        self.assertEqual(elm.attrib['data'], 'Subtopic2-Sc_3_static.swf')
        self.assertEqual(elm.attrib['type'], 'application/x-shockwave-flash')
        self.assertEqual(elm.attrib['height'], '380')
        self.assertEqual(elm.attrib['width'], '580')

        try:
            embed_elm = elm.xpath(
                "h:embed", namespaces={'h': html.nsmap[None]})[0]
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
            param_elm = elm.xpath(
                'h:param', namespaces={'h': html.nsmap[None]})[0]
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

        elm = html.xpath("//*[@id='test_media_flash_generic_attrs']/h:object",
                         namespaces={'h': html.nsmap[None]})[0]
        self.assertEqual(elm.attrib['id'], '123abc')
        self.assertEqual(elm.attrib['data-longdesc'], 'flash long description')

    def test_media_param(self):
        # Case to test the conversion of c:media/*/c:param transformation.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-param.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_param']/h:img",
                             namespaces={'h': html.nsmap[None]})[0]
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
            elm = html.xpath("//*[@id='test_media_audio']/h:audio",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the audio->audio tag transform: " \
                      + transformed_html)
        self.assertTrue('src' not in elm.attrib)
        self.assertEqual(elm.attrib['id'], "mus_shost")
        self.assertEqual(elm.attrib['data-media-type'], "audio/mpeg")
        self.assertEqual(elm.attrib['controls'], 'controls')
        elm = elm.xpath('h:source', namespaces={'h': html.nsmap[None]})[0]
        self.assertEqual(elm.attrib['src'],
                         "http://music.cnx.rice.edu/Brandt/times_effect/shostakovich_quartet.mp3")
        self.assertEqual(elm.attrib['type'], 'audio/mpeg')

    def test_media_audio_embedded(self):
        # Case for audio that needs to be embedded as a player.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-audio.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_audio_embedded']/h:audio",
                             namespaces={'h': html.nsmap[None]})[0]
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
        elm = elm.xpath('h:source', namespaces={'h': html.nsmap[None]})[0]
        self.assertEqual(elm.attrib['src'],
                         "http://music.cnx.rice.edu/Brandt/times_effect/shostakovich_quartet.mp3")
        self.assertEqual(elm.attrib['type'], 'audio/mpeg')

    def test_media_video(self):
        # Case for video that needs to be embedded as a player.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_video']/h:video",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the video->video tag transform: " \
                      + transformed_html)
        self.assertTrue('src' not in elm.attrib)
        self.assertEqual(elm.attrib['controls'], 'controls')
        elm = elm.xpath('h:source', namespaces={'h': html.nsmap[None]})[0]
        self.assertEqual(elm.attrib['src'],
                         "http://www.archive.org/download/CollaborativeStatistics_Lecture_Videos/CollaborativeStatistics_Chap09.mp4")
        self.assertEqual(elm.attrib['type'], 'video/mp4')

    def test_media_video_w_optional_attrs(self):
        # Case for video that needs to be embedded as a player.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath(
                "//*[@id='test_media_video_w_optional_attrs']/h:video",
                namespaces={'h': html.nsmap[None]})[0]
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

    def test_media_video_youtube(self):
        # Case for embedding youtube videos
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_video_youtube']/h:iframe",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the video->iframe tag transform: " \
                      + transformed_html)

        self.assertEqual(elm.attrib['src'], 'http://www.youtube.com/v/k9oSQNTHUZM')
        self.assertEqual(elm.attrib['type'], 'text/html')
        self.assertEqual(int(elm.attrib['width']), 640)
        self.assertEqual(int(elm.attrib['height']), 390)

        try:
            elm = html.xpath("//*[@id='test_media_video_youtube_2']/h:iframe",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the video->iframe tag transform: " \
                      + transformed_html)

        self.assertEqual(elm.attrib['src'], 'http://www.youtube.com/embed/r-FonWBEb0o')
        self.assertEqual(elm.attrib['type'], 'text/html')
        self.assertEqual(int(elm.attrib['width']), 320)
        self.assertEqual(int(elm.attrib['height']), 260)

    def test_media_video_embed(self):
        # Case for video types not supported by the video tag
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_video_quicktime']/h:object",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the video->object tag transform: " \
                      + transformed_html)

        self.assertEqual(int(elm.attrib['height']), 300)
        self.assertEqual(int(elm.attrib['width']), 640)
        param, embed = elm.getchildren()
        self.assertEqual(param.attrib['name'], 'src')
        self.assertEqual(param.attrib['value'],
                'http://dev.cnx.org/resources/659920df8c48f27d0f46b14c1f495dea')
        self.assertEqual(embed.attrib['src'],
                'http://dev.cnx.org/resources/659920df8c48f27d0f46b14c1f495dea')
        self.assertEqual(embed.attrib['type'], 'video/quicktime')
        self.assertEqual(int(embed.attrib['height']), 300)
        self.assertEqual(int(embed.attrib['width']), 640)

    def test_media_java_applet(self):
        # Case for java-applet that needs to be object embedded.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-java-applet.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_java_applet']/h:object",
                             namespaces={'h': html.nsmap[None]})[0]
        except IndexError:
            transformed_html = etree.tostring(html)
            self.fail("Failed to pass through media@id and/or "
                      "the java-applet->object tag transform: " \
                      + transformed_html)
        self.assertEqual(elm.attrib['type'], 'application/x-java-applet')
        self.assertEqual(elm.attrib['height'], '200')
        self.assertEqual(elm.attrib['width'], '600')
        elms = elm.xpath('h:param', namespaces={'h': html.nsmap[None]})
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
            elm = html.xpath("//*[@id='test_media_object']/h:object",
                             namespaces={'h': html.nsmap[None]})[0]
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
        elm = elm.xpath('h:param', namespaces={'h': html.nsmap[None]})[1]
        self.assertEqual(elm.attrib['name'], 'faux2')
        self.assertEqual(elm.attrib['value'], 'faux-value')

    def test_media_labview(self):
        # Case for labview to object transform.
        cnxml = etree.parse(os.path.join(TEST_DATA_DIR, 'media-labview.cnxml'))
        html = self.call_target(cnxml).getroot()

        try:
            elm = html.xpath("//*[@id='test_media_labview']/h:object",
                             namespaces={'h': html.nsmap[None]})[0]
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


XMLPP_DIR = os.path.join(here, 'xml_utils')


def xmlpp(input_):
    """Pretty Print XML"""
    proc = subprocess.Popen(['./xmlpp.pl', '-sSten'],
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            cwd=XMLPP_DIR)
    output, _ = proc.communicate(input_)
    return output


class XsltprocTestCase(unittest.TestCase):
    """rhaptos/cnxmlutils/xsl/test test cases:

    Use xsltproc to transform *.cnxml files with cnxml-to-html5.xsl and compare
    with *.html files
    """

    xslt = os.path.join(here, '..', 'xsl', 'cnxml-to-html5.xsl')
    maxDiff = None

    @classmethod
    def generate_tests(cls):
        for cnxml_filename in glob.glob(os.path.join(here, '..', 'xsl', 'test',
                                                     '*.cnxml')):
            if '.html' in cnxml_filename:
                # it's probably a file for html5-to-cnxml transformation
                # e.g. media.html.cnxml
                continue
            filename_no_ext = cnxml_filename.rsplit('.cnxml', 1)[0]
            test_name = os.path.basename(filename_no_ext)
            html_filename = '{}.cnxml.html'.format(filename_no_ext)
            with open(html_filename, 'rb') as f:
                html = xmlpp(f.read())

            setattr(cls, 'test_{}'.format(test_name),
                    cls.create_test(cnxml_filename, html, html_filename))

    @classmethod
    def create_test(cls, cnxml, html, html_filename):
        def run_test(self):
            output = subprocess.check_output(
                ['xsltproc', '--stringparam', 'version', version,
                 self.xslt, cnxml])
            output = xmlpp(output)
            if os.environ.get('UPDATE_SNAPSHOTS') is not None:
                with open(html_filename, 'w') as f:
                    f.write(output.decode('utf-8'))
            else:
                # https://bugs.python.org/issue10164
                self.assertEqual(output.split(b'\n'), html.split(b'\n'))
        return run_test


XsltprocTestCase.generate_tests()
