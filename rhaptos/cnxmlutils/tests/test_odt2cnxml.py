import os
import re
import unittest
from lxml import etree

from rhaptos.cnxmlutils.odt2cnxml import transform

dirname = os.path.dirname(__file__)

class TestTransform(unittest.TestCase):

    def setUp(self):
        self.cwd = os.getcwd()
        os.chdir(dirname)

    def tearDown(self):
        os.chdir(self.cwd)

    def test_bolditalic(self):
        odtfile = os.path.join(dirname, 'data', 'bolditalic.odt')
        validcnxml = open(
            os.path.join(dirname, 'data', 'bolditalic.cnxml')).read()
        # remove newlines and indentation and ids
        validcnxml = validcnxml.replace('\n', '')
        validcnxml = re.sub('>\s+<', '><', validcnxml)
        validcnxml = re.sub('id=\".*?\"', '', validcnxml)

        cnxml, images, errors = transform(odtfile)
        cnxml = etree.tostring(cnxml)
        # strip ids
        cnxml = re.sub('id=\".*?\"', '', cnxml)
        self.assertEqual(cnxml, validcnxml)

def test_suite():
    from unittest import TestSuite, makeSuite
    suite = TestSuite()
    suite.addTest(makeSuite(TestTransform))
    return suite

