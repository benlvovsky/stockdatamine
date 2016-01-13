#!/bin/bash
source ./common.sh
source ./libsvmcommon.sh
OLDIFS=$IFS
IFS=,

while read stockName tail
do
	echo "Building predictions for $stockName."
	excludeAttrList=$(psql -h localhost -U postgres -d postgres -c "COPY (select excludedattributes from dataminestocks where stockname='$stockName') to STDOUT")
	date=$(extractLastDate ${stockName})
	sql="COPY (select $(attributeList) FROM datamining_stocks_view where stockName='${stockName}' offset 0 limit 1) TO STDOUT DELIMITER ',' CSV HEADER"
	lsPredict $stockName "$excludeAttrList" < <(psql -h localhost -U postgres -d postgres -c "${sql}")

	psql -h localhost -U postgres -d postgres -c "update dataminestocks set prediction=${prediction}, preddate='$date'::date where stockname='${stockName}'"
	echo "------------    $stockName,$date,$prediction"
done < <(dmStocksToPredict)
IFS=$OLDIFS
