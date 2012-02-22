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
                if line == 'fatal: exception "java.io.IOException" thrown: Stream closed.':
                    msg += "DOCTYPE declaration not allowed."

        return valid, msg
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
