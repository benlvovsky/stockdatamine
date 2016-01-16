#!/bin/bash
. ./common.sh

./downloadall.sh
./ls_predictOnBestAttributes.sh
dmPredictions | mail -s "svm" ben@lvovsky.com
if [ "$1" = "-s" ]
	then
	echo "integr8it" | sudo -S shutdown -P +3
fi
