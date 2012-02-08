import os
import subprocess
from tempfile import NamedTemporaryFile
from lxml import etree

dirname = os.path.dirname(__file__)

def validate(cnxmlstr, validator='lxml'):
    schemafn = os.path.join(dirname, 'schema/cnxml/rng/0.7/cnxml.rng')
    if validator == 'lxml':
        schemafile = open(schemafn)
        relaxng_doc = etree.parse(schemafile)
        relaxng = etree.RelaxNG(relaxng_doc)
        cnxmldoc= etree.fromstring(cnxmlstr)
        valid = relaxng.validate(cnxmldoc)
        if valid:
            print "Document validates against cnxml 0.7"
        else:
            print relaxng.error_log
        return valid, relaxng.error_log
    elif validator == 'jing':
        tmpfile = NamedTemporaryFile() # doesn't take stdin, so make a file
        tmpfile.write(cnxmlstr)
        tmpfile.flush()
        tmploc = tmpfile.name
        cmdargs = ["jing", schemafn, tmploc]
        process = subprocess.Popen(cmdargs,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        stdout, stderr = process.communicate(cnxmlstr)
        valid = stdout is None
        return valid, stdout
    else:
        raise RuntimeError("Unknown validator: %s" % validator)
        

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
