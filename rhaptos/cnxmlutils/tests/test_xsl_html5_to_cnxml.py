# -*- coding: utf-8 -*-
import glob
import os.path
import subprocess
import unittest

from lxml import etree

import rhaptos.cnxmlutils


here = os.path.abspath(os.path.dirname(__file__))
TEST_DATA_DIR = os.path.join(here, 'data')
base_dir = os.path.join(os.path.dirname(rhaptos.cnxmlutils.__file__))



class HtmlToCnxmlTestCase(unittest.TestCase):
    def call_target(self, *args, **kwargs):
        xsl = etree.parse(os.path.join(base_dir, 'xsl', 'html5-to-cnxml.xsl'))
        target = etree.XSLT(xsl)
        return target(*args, **kwargs)

    def test_abstract_unwrapped(self):
        # The key thing here is
        #   to dispose of the div[@data-type='abstract-wrapper']
        html = """\
<div xmlns="http://www.w3.org/1999/xhtml" xmlns:md="http://cnx.rice.edu/mdml" xmlns:c="http://cnx.rice.edu/cnxml" xmlns:qml="http://cnx.rice.edu/qml/1.0" xmlns:data="http://dev.w3.org/html5/spec/#custom" xmlns:bib="http://bibtexml.sf.net/" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:mod="http://cnx.rice.edu/#moduleIds" data-type="abstract-wrapper">A number list: <ul class="list"><li class="item">one</li><li class="item">two</li><li class="item">three</li></ul></div>"""
        html = etree.fromstring(html)
        cnxml = self.call_target(html)
        cnxml = etree.tostring(cnxml)
        expected = """\
<wrapper xmlns="http://cnx.rice.edu/cnxml" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:q="http://cnx.rice.edu/qml/1.0" xmlns:bib="http://bibtexml.sf.net/">A number list: <list list-type="bulleted"><item>one</item><item>two</item><item>three</item></list></wrapper>"""
        self.assertEqual(cnxml, expected)

        # And again when the unwrap would make invalid xml.
        html = """\
<div xmlns="http://www.w3.org/1999/xhtml" xmlns:md="http://cnx.rice.edu/mdml" xmlns:c="http://cnx.rice.edu/cnxml" xmlns:qml="http://cnx.rice.edu/qml/1.0" xmlns:data="http://dev.w3.org/html5/spec/#custom" xmlns:bib="http://bibtexml.sf.net/" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:mod="http://cnx.rice.edu/#moduleIds" data-type="abstract-wrapper">A link to an <a href="/contents/d395b566-5fe3-4428-bcb2-19016e3aa3ce@1.4">interal document</a>.</div>"""
        html = etree.fromstring(html)
        cnxml = self.call_target(html)
        cnxml = etree.tostring(cnxml)
        expected = """\
<wrapper xmlns="http://cnx.rice.edu/cnxml" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:q="http://cnx.rice.edu/qml/1.0" xmlns:bib="http://bibtexml.sf.net/">A link to an <link url="/contents/d395b566-5fe3-4428-bcb2-19016e3aa3ce@1.4">interal document</link>.</wrapper>"""
        self.assertEqual(cnxml, expected)

    @unittest.expectedFailure  # FIXME
    def test_media_video(self):
        html = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.html'))
        cnxml = self.call_target(html).getroot()

        try:
            elm = cnxml.xpath('//*[@id="test_media_video"]')[0]
        except IndexError:
            transformed_cnxml = etree.tostring(cnxml)
            self.fail('Failed to pass through media@id and/or '
                      'the video->video tag transform: '
                      + transformed_cnxml)

        self.assertEqual(elm.tag, '{http://cnx.rice.edu/cnxml}media')
        self.assertEqual(elm.attrib['alt'], 'alt text')
        (video,) = elm.getchildren()
        self.assertEqual(video.tag, '{http://cnx.rice.edu/cnxml}video')
        self.assertEqual(video.attrib['src'],
                'http://www.archive.org/download/CollaborativeStatistics_'
                'Lecture_Videos/CollaborativeStatistics_Chap09.mp4')
        self.assertEqual(video.attrib['mime-type'], 'video/mp4')
        self.assertTrue('autoplay' not in video.attrib)

    @unittest.expectedFailure  # FIXME
    def test_media_video_w_optional_attrs(self):
        html = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.html'))
        cnxml = self.call_target(html).getroot()

        try:
            elm = cnxml.xpath('//*[@id="test_media_video_w_optional_attrs"]'
                             )[0]
        except IndexError:
            transformed_cnxml = etree.tostring(cnxml)
            self.fail('Failed to pass through media@id and/or '
                      'the video->video tag transform: '
                      + transformed_cnxml)

        self.assertEqual(elm.tag, '{http://cnx.rice.edu/cnxml}media')
        self.assertEqual(elm.attrib['alt'], 'alt text')
        (video,) = elm.getchildren()
        self.assertEqual(video.tag, '{http://cnx.rice.edu/cnxml}video')
        self.assertEqual(video.attrib['height'], '500')
        self.assertEqual(video.attrib['width'], '500')
        self.assertEqual(video.attrib['src'],
                'http://www.archive.org/download/CollaborativeStatistics_'
                'Lecture_Videos/CollaborativeStatistics_Chap09.mp4')
        self.assertEqual(video.attrib['mime-type'], 'video/mp4')
        self.assertTrue('autoplay' not in video.attrib)
        self.assertEqual(video.attrib['volume'], '0')
        self.assertEqual(video.attrib['loop'], 'true')
        self.assertEqual(video.attrib['standby'], 'message')

    @unittest.expectedFailure  # FIXME
    def test_iframe_youtube(self):
        html = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.html'))
        cnxml = self.call_target(html).getroot()

        try:
            elm = cnxml.xpath('//*[@id="test_media_video_youtube"]')[0]
        except IndexError:
            transformed_cnxml = etree.tostring(cnxml)
            self.fail('Failed to pass through media@id and/or '
                      'the iframe->iframe tag transform: '
                      + transformed_cnxml)

        self.assertEqual(elm.tag, '{http://cnx.rice.edu/cnxml}media')
        (iframe,) = elm.getchildren()
        self.assertEqual(iframe.tag, '{http://cnx.rice.edu/cnxml}iframe')
        self.assertEqual(iframe.attrib['src'],
                         'http://www.youtube.com/v/k9oSQNTHUZM')

        try:
            elm = cnxml.xpath('//*[@id="test_media_video_youtube_2"]')[0]
        except IndexError:
            transformed_cnxml = etree.tostring(cnxml)
            self.fail('Failed to pass through media@id and/or '
                      'the iframe->iframe tag transform: '
                      + transformed_cnxml)

        self.assertEqual(elm.tag, '{http://cnx.rice.edu/cnxml}media')
        (iframe,) = elm.getchildren()
        self.assertEqual(iframe.tag, '{http://cnx.rice.edu/cnxml}iframe')
        self.assertEqual(iframe.attrib['src'],
                         'http://www.youtube.com/embed/r-FonWBEb0o')

    @unittest.expectedFailure  # FIXME
    def test_media_video_embed(self):
        html = etree.parse(os.path.join(TEST_DATA_DIR, 'media-video.html'))
        cnxml = self.call_target(html).getroot()

        try:
            elm = cnxml.xpath('//*[@id="test_media_video_quicktime"]')[0]
        except IndexError:
            transformed_cnxml = etree.tostring(cnxml)
            self.fail('Failed to pass through media@id and/or '
                      'the object->video tag transform: '
                      + transformed_cnxml)

        self.assertEqual(elm.tag, '{http://cnx.rice.edu/cnxml}media')
        self.assertEqual(elm.attrib['alt'], 'alt text')
        (video,) = elm.getchildren()
        self.assertEqual(video.tag, '{http://cnx.rice.edu/cnxml}video')
        self.assertEqual(video.attrib['width'], '640')
        self.assertEqual(video.attrib['height'], '300')
        self.assertEqual(video.attrib['mime-type'], 'video/quicktime')
        self.assertEqual(video.attrib['src'],
            'http://dev.cnx.org/resources/659920df8c48f27d0f46b14c1f495dea')




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

    Use xsltproc to transform *.html files with html5-to-cnxml.xsl and compare
    with *.cnxml files
    """

    xslt = os.path.join(here, '..', 'xsl', 'html5-to-cnxml.xsl')
    maxDiff = None

    @classmethod
    def generate_tests(cls):
        for html_filename in glob.glob(os.path.join(here, '..', 'xsl', 'test',
                                            '*.html')):
            filename_no_ext = html_filename.rsplit('.html', 1)[0]
            test_name = os.path.basename(filename_no_ext)
            with open('{}.cnxml'.format(filename_no_ext)) as f:
                cnxml = xmlpp(f.read())

            setattr(cls, 'test_{}'.format(test_name),
                    # FIXME html5 to cnxml is not fully implemented yet
                    unittest.expectedFailure(
                        cls.create_test(html_filename, cnxml)))

    @classmethod
    def create_test(cls, html, cnxml):
        def run_test(self):
            output = subprocess.check_output(['xsltproc', self.xslt, html])
            output = xmlpp(output)
            self.assertMultiLineEqual(output, cnxml)
        return run_test


XsltprocTestCase.generate_tests()
