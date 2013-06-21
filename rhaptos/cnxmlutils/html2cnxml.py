# -*- coding: utf-8 -*-
"""
Copyright (C) 2013 Rice University

This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
See LICENSE.txt for details.
"""

"""Converts a piece of HTML5 (just the body tag element) and an existing
CNXML document into a CNXML document. The existing CNXML Document is necessary
to preserve the previously document's metadata.
The results are sent to standard out.

"""
import sys
try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO
import pkg_resources
from lxml import etree
from rhaptos.cnxmlutils.utils import html_to_cnxml


def main():
    try:
        import argparse
    except ImportError:
        print("The 'argparse' distribution is needed "
              "to run from the commandline")
        print("Recommendation: Use the 'cmdline_support'' requirement extra.")
        return 2

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('document', nargs=1,
                        type=argparse.FileType('r'),
                        default=sys.stdin,
                        help="the filesystem location of the html document")
    parser.add_argument('cnxml_document', nargs=1,
                        type=argparse.FileType('r'),
                        help="the existing CNXML document")
    args = parser.parse_args()

    result = html_to_cnxml(args.document[0], args.cnxml_document[0])

    print(result)

    return 0

if __name__ == '__main__':
    sys.exit(main())
