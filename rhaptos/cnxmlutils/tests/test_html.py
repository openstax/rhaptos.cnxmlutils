# -*- coding: utf-8 -*-
import os
import unittest


HERE = os.path.abspath(os.path.dirname(__file__))
TEST_DATA = os.path.join(HERE, 'data')


class CnxmlConversionTest(unittest.TestCase):

    def test_conversion_wo_resources(self):
        # Test the conversion to html without any resources.
        data_dir = os.path.join(TEST_DATA, 'module-without-resources')
        document_path = os.path.join(data_dir, 'index.cnxml')
        expected_results_path = os.path.join(data_dir, 'index.html')
        with open(document_path, 'r') as doc:
            document = doc.read()
        with open(expected_results_path, 'r') as f:
            expected_results = f.read()

        # Do the conversion.
        from rhaptos.cnxmlutils.html import cnxml_to_html
        results = cnxml_to_html(document)

        # Verify the results.
        self.assertEqual(expected_results, results)
