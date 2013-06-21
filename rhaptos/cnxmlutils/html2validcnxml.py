# -*- coding: utf-8 -*-
"""
Copyright (C) 2013 Rice University

This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
See LICENSE.txt for details.
"""

"""
Converts HTML5 to valid CNXML
The results are sent to standard out.
"""
import sys
import pkg_resources
from rhaptos.cnxmlutils.utils import html_to_valid_cnxml

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
    args = parser.parse_args()

    result = html_to_valid_cnxml(args.document[0])

    print(result)

    return 0

if __name__ == '__main__':
    sys.exit(main())
