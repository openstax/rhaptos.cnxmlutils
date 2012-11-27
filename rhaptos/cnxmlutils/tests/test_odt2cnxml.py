# -*- coding: utf-8 -*-
import os
import re
import unittest
from lxml import etree

HERE = os.path.abspath(os.path.dirname(__file__))


class TestTransform(unittest.TestCase):

    def test_bolditalic(self):
        odtfile = os.path.join(HERE, 'data', 'bolditalic.odt')
        valid_cnxmlfile = os.path.join(HERE, 'data', 'bolditalic.cnxml')
        with open(valid_cnxmlfile, 'r') as f:
            validcnxml = f.read()

        # Remove newlines and indentation and ids
        validcnxml = validcnxml.replace('\n', '')
        validcnxml = re.sub('>\s+<', '><', validcnxml)
        validcnxml = re.sub('id=\".*?\"', '', validcnxml)
        # Encode to utf-8 because that's what etree.tostring outputs.'
        validcnxml = validcnxml.encode('utf-8')

        from rhaptos.cnxmlutils.odt2cnxml import transform
        cnxml, images, errors = transform(odtfile)
        cnxml = etree.tostring(cnxml)
        # Strip ids, because (they differ each run?).
        cnxml = re.sub(b'id=\".*?\"', b'', cnxml)
        self.assertEqual(cnxml, validcnxml)
