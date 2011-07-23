#!/usr/bin/env python
#
# addmathml - parse OpenOffice XML and add mathml after draw elements
#
# Author: Adan Galvan, Brent Hendricks, Ross Reedstrom
# (C) 2005-2010 Rice University
#
# This software is subject to the provisions of the GNU Lesser General
# Public License Version 2.1 (LGPL).  See LICENSE.txt for details.

import sys
from xml.sax import make_parser
from xml.sax import ContentHandler
from xml.sax.saxutils import escape
from xml.sax.saxutils import quoteattr
from xml.sax.handler import EntityResolver
from StringIO import StringIO
import random


class docHandler(ContentHandler):

    def __init__(self):
        #  on init, create links dictionary
        self.objOOoZipFile = u''
        self.document = []
        self.header_stack = []
        self.tableLevel = 0
        self.listLevel = 0
        self.deletion = 0
        self.handlers = {
            'draw:object':self.handleDrawObject
        }

    def handleDrawObject(self, name, end_tag, attrs={}):
        if end_tag:
            # can't get there from here ...
            # self.outputEndElement(name)
            deleteme = 0
        else:
            self.outputStartElement(name, attrs)

            strMathMLObjectName = attrs["xlink:href"]
            if strMathMLObjectName[0] == '#':
                strMathMLObjectName = strMathMLObjectName[1:len(strMathMLObjectName)]

            # HACK - need to find the object location from the manifest ...
            strMathMLObjectLocation = strMathMLObjectName + '/content.xml'

            if strMathMLObjectName:
                self.document.append("<!-- embedded MathML for object: \'" + strMathMLObjectName + "\'. -->\n")
                #self.document.append("<!-- embedded MathML here from location: \'" + strMathMLObjectLocation + "\'. -->\n")
                try:
                    strOOoMathML = self.objOOoZipFile.read(strMathMLObjectLocation)
                    if strOOoMathML:
                        iXmlStart = strOOoMathML.find('<math ')
                        if iXmlStart > 0:
                            strOOoMathMLWithoutHeader = strOOoMathML[iXmlStart:].decode('utf-8')
                            try:
                                self.document.append(strOOoMathMLWithoutHeader)
                            except:
                                self.document.append("<!-- adding to self.document failed. -->")
                        else:
                            self.document.append("<!-- strOOoMathML.find(\'<math \') returns 0. -->\n")
                    else:
                        self.document.append("<!-- self.objOOoZipFile.read(" + strMathMLObjectLocation + ") returns nothing. -->\n")
                except:
                    self.document.append("<!-- self.objOOoZipFile.read(" + strMathMLObjectLocation + ") is unhappy. -->\n")

            self.outputEndElement(name)

    def startElement(self, name, attrs):
        handler = self.handlers.get(name, None)
        if handler:
            handler(name, end_tag=False, attrs=attrs)
        else:
            self.outputStartElement(name, attrs)

    def outputStartElement(self, name, attrs):
        self.document.append('<%s' % name)
        if attrs:
            for attr, value in attrs.items():
                self.document.append(" " + attr + '=%s' % quoteattr(value))
        self.document.append('>')

    def characters(self, ch):
        self.document.append(escape(ch))

    def endElement(self, name):
        handler = self.handlers.get(name, None)
        if handler:
            handler(name, end_tag=True)
        else:
            self.outputEndElement(name)

    def outputEndElement(self, name):
        self.document += '</%s>' % name


class EntityResolver:

    def resolveEntity(self,publicId,systemId):
        return "file:///dev/null"


def addMathML(fileXml, objOOoZipFile):

    # Create an instance of the handler classes
    dh = docHandler()
    dh.objOOoZipFile = objOOoZipFile

    # Create an XML parser
    parser = make_parser()

    # Tell the parser to use your handler instance
    parser.setContentHandler(dh)
    er = EntityResolver()
    parser.setEntityResolver(er)

    # Parse the file; your handler's methods will get called
    parser.parse(fileXml)

    return u''.join(dh.document).encode('UTF-8')


if __name__ == "__main__":
    import zipfile
    file = sys.argv[1]
    f = open(file)
    z = zipfile.ZipFile(sys.argv[2])
    print addMathML(f,z)

