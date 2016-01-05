#!/bin/bash
./predictOnBestAttributes.sh | grep -v "UPDATE" | mail -s "predictions" ben@lvovsky.com
