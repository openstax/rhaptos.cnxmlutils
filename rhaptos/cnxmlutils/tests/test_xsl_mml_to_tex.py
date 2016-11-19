# -*- coding: utf-8 -*-
import glob
import os
import subprocess
import unittest


here = os.path.abspath(os.path.dirname(__file__))
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


class SaxonTestCase(unittest.TestCase):
    """rhaptos/cnxmlutils/xsl/test/mml_to_tex test cases:

    Use saxon to transform *_raw.xhtml files with mml-to-tex.xsl and compare with *_tex.html files
    """

    xslt = os.path.join(here, '..', 'xsl', 'mml-to-tex.xsl')
    maxDiff = None

    @classmethod
    def generate_tests(cls):
        for xhtml_filename in glob.glob(os.path.join(here, '..', 'xsl', 'test',
                                                     'mml_to_tex', '*_raw.xhtml')):
            filename_no_ext = xhtml_filename.rsplit('_raw.xhtml', 1)[0]
            test_name = os.path.basename(filename_no_ext)
            with open('{}_tex.xhtml'.format(filename_no_ext), 'rb') as f:
                expected_xhtml = xmlpp(f.read())

            setattr(cls, 'test_{}'.format(test_name),
                    cls.create_test(xhtml_filename, expected_xhtml))

    @classmethod
    def create_test(cls, xhtml, expected_xhtml):
        def run_test(self):
            output = subprocess.check_output(['saxon',
                                              '-s:{}'.format(xhtml),
                                              '-xsl:{}'.format(self.xslt)])
            output = xmlpp(output)
            # https://bugs.python.org/issue10164
            self.assertEqual(output.split(b'\n'), expected_xhtml.split(b'\n'))
        return run_test


SaxonTestCase.generate_tests()
