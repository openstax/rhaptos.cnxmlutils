import os
import re
import unittest
from lxml import etree

from rhaptos.cnxmlutils.odt2cnxml import transform

dirname = os.path.abspath(os.path.dirname(__file__))


class TestTransform(unittest.TestCase):

    def test_bolditalic(self):
        odtfile = os.path.join(dirname, 'data', 'bolditalic.odt')
        valid_cnxmlfile = os.path.join(dirname, 'data', 'bolditalic.cnxml')
        with open(valid_cnxmlfile) as f:
            validcnxml = f.read()
        # remove newlines and indentation and ids
        validcnxml = validcnxml.replace('\n', '')
        validcnxml = re.sub('>\s+<', '><', validcnxml)
        validcnxml = re.sub('id=\".*?\"', '', validcnxml)
        validcnxml = validcnxml.encode('utf-8')

        cnxml, images, errors = transform(odtfile)
        cnxml = etree.tostring(cnxml)
        # strip ids
        cnxml = re.sub(b'id=\".*?\"', b'', cnxml)
        self.assertEqual(cnxml, validcnxml)
