#!/bin/bash
./downloadall.sh
./predictOnBestAttributes.sh | grep -v "UPDATE" | mail -s "svm" ben@lvovsky.com
echo "integr8it" | sudo -S shutdown -P now
