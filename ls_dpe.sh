#!/bin/bash
. ./common.sh

./downloadall.sh
./ls_predictOnBestAttributes.sh
dmPredictions | mail -s "predictions" ben@lvovsky.com
if [ "$1" != "-s" ]
	then
	echo "integr8it" | sudo -S shutdown -P now
fi
