#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""\
Rebuilds the transformed files.

This is useful when making a fairly large
change that effects more than one file.
You might at first think it a bad idea to mass change all the files,
but keep in mind that you still need to commit the changes,
so you'll be able to verify the difference.
"""
import os
import glob
import argparse
import subprocess


here = os.path.abspath(os.path.dirname(__file__))
XSL_DIR = os.path.abspath(os.path.join(here, '../..'))
XMLPP_DIR = os.path.abspath(os.path.join(here, '../../..', 'tests', 'xml_utils'))
MML2TEX = 'mml-to-tex'


def transform(type_, input_):
    xsl_filepath = os.path.join(XSL_DIR, "{}.xsl".format(type_))
    proc = subprocess.Popen(['saxonb-xslt',  '-s:-', '-xsl:{}'.format(xsl_filepath)],
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
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


def mml_to_tex():
    for filename in glob.glob(os.path.join(here, '*_raw.xhtml')):
        filename_wo_ext = filename.rsplit('_raw.xhtml', 1)[0]
        trans_filename = '{}_tex.xhtml'.format(filename_wo_ext)

        with open(filename, 'r') as input_, \
             open(trans_filename, 'w') as output:
            output.write(xmlpp(transform(MML2TEX, xmlpp(input_.read()))))


def main():
    mml_to_tex()


if __name__ == '__main__':
    main()
