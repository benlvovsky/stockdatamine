#!/bin/bash
./predictOnBestAttributes.sh | grep -v "UPDATE" | mail -s "svm" ben@lvovsky.com
