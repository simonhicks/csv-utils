#!/bin/bash

DIST_NAME=./csv-utils.zip
[ -f $DIST_NAME ] && rm $DIST_NAME
zip -r $DIST_NAME bin/ README.md
