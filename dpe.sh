#!/bin/bash
./downloadall.sh
./predictOnBestAttributes.sh | grep -v "UPDATE" | mail -s "predictions" ben@lvovsky.com