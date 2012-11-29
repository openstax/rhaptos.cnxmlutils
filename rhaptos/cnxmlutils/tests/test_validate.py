# -*- coding: utf-8 -*-
import os
import unittest


HERE = os.path.abspath(os.path.dirname(__file__))
TEST_DATA = os.path.join(HERE, 'data')


class ValidationTest(unittest.TestCase):

    def test_validates_using_lxml(self):
        # Basic test for complete validation.
        document_path = os.path.join(TEST_DATA, 'module-without-resources',
                                     'index.cnxml')
        with open(document_path, 'r') as doc:
            document = doc.read()

        from rhaptos.cnxmlutils.validate import (
            LXML_VALIDATOR, validate,
            )
        valid, err = validate(document, LXML_VALIDATOR)

        self.assertTrue(valid)
        self.assertEqual('', err)
