import os
import argparse
from lxml import etree

dirname = os.path.dirname(__file__)

def validate(cnxmlstr):
    schemafile = open(os.path.join(dirname,
                      'schema/cnxml/rng/0.7/cnxml.rng'))
    relaxng_doc = etree.parse(schemafile)
    relaxng = etree.RelaxNG(relaxng_doc)
    cnxmldoc= etree.fromstring(cnxmlstr)
    valid = relaxng.validate(cnxmldoc)
    if valid:
        print "Document validates against cnxml 0.7"
    else:
        print relaxng.error_log.last_error
    return valid

def main():
    parser = argparse.ArgumentParser(description='Validate CNXML')
    parser.add_argument('cnxmlfile', help='/path/to/cnxmlfile', type=file)
    args = parser.parse_args()

    validate(args.cnxmlfile.read())

if __name__ == '__main__':
    main()
