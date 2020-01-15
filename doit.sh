#!/bin/bash

FILENAME=`grep value main.md | head -1 | cut -d'"' -f2`

mmark main.md > $FILENAME.xml
xml2rfc --v3 --html $FILENAME.xml
xml2rfc --v3 --text $FILENAME.xml

