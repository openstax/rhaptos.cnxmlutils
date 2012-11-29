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

    def test_invalid_using_lxml(self):
        # Test for an invalid cnxml file.
        document_path = os.path.join(TEST_DATA, 'module-invalid',
                                     'index.cnxml')
        with open(document_path, 'r') as doc:
            document = doc.read()

        from rhaptos.cnxmlutils.validate import (
            LXML_VALIDATOR, validate,
            )
        valid, err = validate(document, LXML_VALIDATOR)

        self.assertTrue(not valid)
        self.assertIn('<string>:67:0:ERROR:RELAXNGV:RELAXNG_ERR_ATTRVALID: '
                      'Element para failed to validate attributes',
                      err.split('\n'))
