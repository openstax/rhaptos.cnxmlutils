import os
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
        print relaxng.error_log
    return valid, relaxng.error_log

def main():
    try:
        import argparse
        parser = argparse.ArgumentParser(description='Validate CNXML')
        parser.add_argument('cnxmlfile', help='/path/to/cnxmlfile', type=file)
        args = parser.parse_args()

        validate(args.cnxmlfile.read())
    except ImportError:
        print "argparse is needed for commandline"

if __name__ == '__main__':
    main()
