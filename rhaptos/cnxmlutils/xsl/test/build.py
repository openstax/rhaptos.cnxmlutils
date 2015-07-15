#!/bin/env python
# -*- coding: utf-8 -*-
"""\
Rebuilds the transformed files.

This is useful when making a fairly large
change that effects one than one file.
You might at first think it a bad idea to mass change all the files,
but keep in mind that you still need to commit the changes,
so you'll be able to verify the difference.
"""
import os
import glob
import argparse
import subprocess


here = os.path.abspath(os.path.dirname(__file__))
XSL_DIR = os.path.abspath(os.path.join(here, '..'))
XMLPP_DIR = os.path.abspath(os.path.join(here, '../..', 'tests', 'xml_utils'))
HTML2CNXML = 'html5-to-cnxml'
CNXML2HTML = 'cnxml-to-html5'


def transform(type_, input_):
    xsl_filepath = os.path.join(XSL_DIR, "{}.xsl".format(type_))
    proc = subprocess.Popen(['xsltproc', xsl_filepath, '-'],
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            )
    output, error = proc.communicate(input_)
    return output


def xmlpp(input_):
    """Pretty Print XML"""
    proc = subprocess.Popen(['./xmlpp.pl', '-sSten'],
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            cwd=XMLPP_DIR)
    output, _ = proc.communicate(input_)
    return output


def html_to_cnxml():
    for filename in glob.glob(os.path.join(here, '*.html')):
        if '.cnxml.html' in filename:
            # it's probably a file for cnxml-to-html5 transformation
            # e.g. media.cnxml.html
            continue
        filename_wo_ext = filename.rsplit('.html', 1)[0]
        trans_filename = '{}.html.cnxml'.format(filename_wo_ext)

        with open(filename, 'r') as input_, \
             open(trans_filename, 'w') as output:
            output.write(xmlpp(transform(HTML2CNXML, xmlpp(input_.read()))))


def cnxml_to_html():
    for filename in glob.glob(os.path.join(here, '*.cnxml')):
        if '.html.cnxml' in filename:
            continue
        filename_wo_ext = filename.rsplit('.cnxml', 1)[0]
        trans_filename = '{}.cnxml.html'.format(filename_wo_ext)

        with open(filename, 'r') as input_, \
             open(trans_filename, 'w') as output:
            output.write(xmlpp(transform(CNXML2HTML, xmlpp(input_.read()))))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cnxml-only', action='store_true')
    parser.add_argument('--html-only', action='store_true')
    args = parser.parse_args(argv)

    flagged = args.cnxml_only or args.html_only
    if flagged and args.html_only:
        html_to_cnxml()
    elif flagged and args.cnxml_only:
        cnxml_to_html()
    else:
        html_to_cnxml()
        cnxml_to_html()


if __name__ == '__main__':
    main()
