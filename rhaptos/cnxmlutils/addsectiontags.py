#!/usr/bin/env python
#
# addsectiontags - parse OpenOffice XML and add section tags based on
# headings
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
        self.document = []
        self.header_stack = []
        self.tableLevel = 0
        self.listLevel = 0
        self.deletion = 0
        self.handlers = {
            'table:table':self.handleTable,
            'text:ordered-list':self.handleList,
            'text:deletion':self.handleDeletion,
            'text:h':self.handleHeader,
            'text:section':self.handleSection,
            'office:body':self.handleBody
        }

    def handleTable(self, name, end_tag, attrs={}):
        if end_tag:
            self.tableLevel -= 1
            self.outputEndElement(name)
        else:
            self.tableLevel += 1
            self.outputStartElement(name, attrs)

    def handleList(self, name, end_tag, attrs={}):
        if end_tag:
            self.listLevel -= 1
            self.outputEndElement(name)
        else:
            self.listLevel += 1
            self.outputStartElement(name, attrs)

    def handleDeletion(self, name, end_tag, attrs={}):
        if end_tag:
            self.deletion -= 1
            self.outputEndElement(name)
        else:
            self.deletion += 1
            self.outputStartElement(name, attrs)

    def handleSection(self, name, end_tag, attrs={}):
        # text:section is hierarchical while text:h is not
 
        if not end_tag:
            self.document.append("<!-- close all open sections -->\n")
            self.endSections()
            self.outputStartElement(name, attrs)
        else:
            self.document.append("<!-- close all open sections -->\n")
            self.endSections()
            self.outputEndElement(name)

    def handleHeader(self, name, end_tag, attrs={}):
        if self.tableLevel or self.listLevel or self.deletion:
            return

        level = attrs.get(u'text:level')

        if not end_tag:
            self.endSections(level)

            id = attrs.get('id',self.generateId())
            self.document.append("<section id='%s'>\n" %id)
            self.document.append("<title>")
        else:
            self.document.append("</title>")

    def handleBody(self, name, end_tag, attrs={}):
        #head-> name
        if not end_tag:
            self.document.append('<office:body')
            if attrs:
                for attr, value in attrs.items():
                    self.document.append(' %s=%s' % (attr,quoteattr(value)))
            self.document.append('>')
        else:
            self.endSections()
            self.document.append('</office:body>')

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
                self.document.append(' %s=%s' % (attr,quoteattr(value)))
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

    def storeSectionState(self, level):
        """
        Takes a header tagname (e.g. 'h1') and adjusts the 
        stack that remembers the headers seen.
        """

        # self.document.append("<!-- storeSectionState(): " + str(len(self.header_stack)) + " open section tags. " + str(self.header_stack) + "-->\n")

        try:
            # special case.  we are not processing an OOo XML start tag which we
            # are going to insert <section> before.  we have reached a point
            # where all sections need to be closed. EG </office:body> or </text:section>,
            # both of which are hierarchical => scope closure for all open <section> tags
            bClosedAllSections = ( level == u'0' )
            if bClosedAllSections:
                # have reached a point where all sections need to be closed
                iSectionsClosed = len(self.header_stack)
                while len(self.header_stack) > 0:
                    del(self.header_stack[-1])
                return iSectionsClosed

            if len(self.header_stack) == 0:
                # no open section tags
                iSectionsClosed = 0
                self.header_stack.append(level)
            else:
                iLastLevel = self.header_stack[-1]
                if level > iLastLevel:
                    # open sections tags AND no sections need closing
                    iSectionsClosed = 0
                    self.header_stack.append(level)
                elif level == iLastLevel:
                    # open sections tags AND need to closed one of the sections
                    iSectionsClosed = 1
                    # imagine deleting the last level and then re-adding it
                elif level < iLastLevel:
                    # open sections tags AND need to closed some of the sections
                    del(self.header_stack[-1])
                    iSectionsClosed = 1
                    iSectionsClosed += self.storeSectionState(level)

            return iSectionsClosed

        except IndexError:
            print level
            raise

    def endSections(self, level=u'0'):
        """Closes all sections of level >= sectnum. Defaults to closing all open sections"""

        iSectionsClosed = self.storeSectionState(level)
        self.document.append("</section>\n" * iSectionsClosed)

    def generateId(self):
        return 'id-' + str(random.random())[2:]

class EntityResolver:

    def resolveEntity(self,publicId,systemId):
        return "file:///dev/null"

def addSectionTags(s):

    # Create an instance of the handler classes
    dh = docHandler()

    # Create an XML parser
    parser = make_parser()

    # Tell the parser to use your handler instance
    parser.setContentHandler(dh)
    er = EntityResolver()
    parser.setEntityResolver(er)

    # Parse the file; your handler's methods will get called
    parser.parse(s)

    return u''.join(dh.document).encode('UTF-8')

if __name__ == "__main__":
    file = sys.argv[1]
    f = open(file)
    print addSectionTags(f)

