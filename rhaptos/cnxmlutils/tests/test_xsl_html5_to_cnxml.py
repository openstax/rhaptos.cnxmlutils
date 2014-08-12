# -*- coding: utf-8 -*-
import os.path
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
