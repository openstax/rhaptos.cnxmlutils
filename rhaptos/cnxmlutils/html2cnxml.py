# -*- coding: utf-8 -*-
"""Converts a piece of HTML5 (just the body tag element) and an existing
CNXML document into a CNXML document. The existing CNXML Document is necessary
to preserve the previously document's metadata.
The results are sent to standard out.

"""
import sys
import argparse
from io import StringIO

import pkg_resources
from lxml import etree
from .utils import html_to_cnxml


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('document',
                        type=argparse.FileType('r'),
                        default=sys.stdin,
                        help="the filesystem location of the html document")
    parser.add_argument('cnxml_document',
                        type=argparse.FileType('r'),
                        help="the existing CNXML document")
    args = parser.parse_args()

    result = html_to_cnxml(args.document, args.cnxml_document)

    print(result)
    return 0


if __name__ == '__main__':
    sys.exit(main())
