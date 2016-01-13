#!/bin/bash
#Expects extract being done. Looks for files in extrcts folder
source ./common.sh
source ./libsvmcommon.sh

OLDIFS=$IFS
IFS=,
offset=8
limit=480
wkCost=100
wkNu=0.556

if [ -z "$1" ]
then
	cv=""
else
	cv="$1"
fi

OLDIFS=$IFS
IFS=,
while read stockName tail
do
	echo "Building model for $stockName."
	excludeAttrList=$(psql -h localhost -U postgres -d postgres -c "COPY (select excludedattributes from dataminestocks where stockname='$stockName') to STDOUT")
	date=$(extractLastDate ${stockName})
	sql="COPY (select $(attributeList) FROM datamining_stocks_view where stockName='${stockName}' offset ${offset} limit ${limit}) TO STDOUT DELIMITER ',' CSV HEADER"
	lsCalcModel $stockName "$excludeAttrList" $cv < <(psql -h localhost -U postgres -d postgres -c "${sql}")

	if [ ! -z "$1" ]
	then
		echo " correlation=${correlation}. Error=$error"
		psql -h localhost -U postgres -d postgres -c "update dataminestocks set correlation=${correlation}, corrdate='$date'::date where stockname='${stockName}'"
	fi

	echo "Done"
done < <(dmStocksToPredict)
IFS=OLDIFS

#<(printf "TLS.AX\n")
#"^AXJO\nBHP.AX\nCBA.AX\nWOW.AX\n"
#<(dmTheStocks "^AXJO")
#(dmStocks)
IFS=$OLDIFS
