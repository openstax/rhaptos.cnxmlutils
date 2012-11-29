# -*- coding: utf-8 -*-
"""\
Validates a CNXML document using one of the avialble validation processes.

Available validators:

- lxml
- jing

"""
import os
import subprocess
import argparse
from tempfile import NamedTemporaryFile
from lxml import etree


HERE = os.path.dirname(__file__)
SCHEMA = os.path.join(HERE, 'schema/cnxml/rng/0.7/cnxml.rng')

LXML_VALIDATOR = 'lxml'
JING_VALIDATOR = 'jing'


def lxml_validator(cnxml):
    """Validates a CNXML document using lxml."""
    with open(SCHEMA) as schema:
        relaxng_doc = etree.parse(schema)
    relaxng = etree.RelaxNG(relaxng_doc)
    cnxmldoc = etree.fromstring(cnxml)
    valid = relaxng.validate(cnxmldoc)
    if valid:
        print("Document validates against cnxml 0.7")
    else:
        print(relaxng.error_log)
    return valid, str(relaxng.error_log)


def jing_validator(cnxml):
    """Validates a CNXML document using jing."""
    tmpfile = NamedTemporaryFile() # doesn't take stdin, so make a file
    tmpfile.write(cnxml)
    tmpfile.flush()
    tmploc = tmpfile.name
    cmdargs = ["jing", SCHEMA, tmploc]
    process = subprocess.Popen(cmdargs,
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE)
    stdout, stderr = process.communicate()
    valid = not stdout
    msg = ''
    if valid:
        return valid, msg

    cnxmlstr = cnxmlstr.split('\n')
    for line in stdout.split('\n'):
        if not line:
            continue
        parts = line.split(':')
        line = parts[1]
        column = parts[2]

        try:
            line = int(line)
            column = int(column)
            msg += 'On line %s, column %s: %s\n' % (line, column,
                                                    ''.join(parts[3:]))
            msg += '\tcontext: %s\n\n' % cnxmlstr[line-1][column-50:column+50]
        except ValueError:
            # not a line number, so use the whole thing
            line = 0
            column = 0

            # known specific exceptions
            java_io_exception = 'fatal: exception "java.io.IOException" ' \
                                'thrown: Stream closed.'
            if line == java_io_exception:
                msg += "DOCTYPE declaration not allowed."
    return valid, msg


def validate(cnxmlstr, validator='lxml'):
    if validator == LXML_VALIDATOR:
        return lxml_validator(cnxmlstr)
    elif validator == JING_VALIDATOR:
        return jing_validator(cnxmlstr)
    else:
        raise RuntimeError("Unknown validator: %s" % validator)


def main():
    parser = argparse.ArgumentParser(description='Validate CNXML')
    parser.add_argument('cnxmlfile', help='/path/to/cnxmlfile', type=file)
    args = parser.parse_args()

    validate(args.cnxmlfile.read())


if __name__ == '__main__':
    main()
