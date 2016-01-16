#!/bin/bash
./downloadall.sh
./predictOnBestAttributes.sh | grep -v "UPDATE" | mail -s "svm" ben@lvovsky.com
