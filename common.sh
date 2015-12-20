#!/bin/bash
export PGPASSWORD='postgres'
export WEKA_PATH=/media/bigdrive/dev/weka-3-7-13/*.jar
export CP=$WEKA_PATH:/home/ben/wekafiles/packages/LibSVM/LibSVM.jar:/home/ben/wekafiles/packages/LibSVM/lib/libsvm.jar:/media/bigdrive/dev/weka-3-7-13/weka.jar:$CLASSPATH

function maxDatePlusOne() {
	maxdate=`psql -t -h localhost -U postgres -d postgres -c "select max(date + interval '1 day') from stocks where stock='$1';"`
	echo "maxdate + 1 day from DB='$maxdate'"
	maxdate=${maxdate//[[:blank:]]/} #trim
	if [ -z "$maxdate" ]; then
		maxdate="2014-01-01"
		echo "defaulted as was empty"
	fi
	#echo "maxdate in use: $maxdate"
	year=${maxdate:0:4}
	month=${maxdate:5:2}
	monthfixed=$((month-1))
	#printf "monthfixed=${monthfixed}\n"
	day=${maxdate:8:2}
	echo "Day=${day}, Month=${month}, Month fixed=${monthfixed}, Year=${year}"
}

function importIntoDB() {
	echo "Importing $1 into DB from downloads/${1}_fixed.csv"
	sql="COPY stocks (stock,date,open,high,low,close,volume,\"Adj Close\") FROM '$(pwd)/downloads/${1}_fixed.csv' WITH CSV delimiter as ','"
	printf "${sql}\n"
	#	psql -h localhost -U postgres -d postgres -c "delete from stocks where stock='$1'"
	psql -h localhost -U postgres -d postgres -c "${sql}"
	echo "Importing $1 into DB finished"
}

function arAsCommaSep() {
	local IFS=",";echo "$*"
}
#cat dataminestocklist.csv | psql -h localhost -U postgres -d postgres -c "TRUNCATE dataminestocks;COPY dataminestocks FROM STDIN WITH CSV delimiter as ','"
#cat downloadstocklist.csv | psql -h localhost -U postgres -d postgres -c "TRUNCATE downloadinstruments;COPY downloadinstruments (instrument) FROM STDIN WITH CSV delimiter as ','"
#cat downloadfxlist.csv | psql -h localhost -U postgres -d postgres -c "COPY downloadinstruments (instrument) FROM STDIN WITH CSV delimiter as ','"

function dmStocks() {
	psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks order by stockname asc) to STDOUT WITH CSV delimiter as ','"
}

function dmStocksOrd() {
	psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks order by correlation desc) to STDOUT WITH CSV delimiter as ','"
}

function dmStocksPredOrd() {
	psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks order by prediction desc) to STDOUT WITH CSV delimiter as ','"
}

function dmStocksAbsPredOrd() {
	psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks order by abs(prediction) desc) to STDOUT WITH CSV delimiter as ','"
}

function downloadInstruments() {
	psql -h localhost -U postgres -d postgres -c "COPY (select instrument from downloadinstruments where type='$1') to STDOUT WITH CSV delimiter as ','"
}

function attributeList() {
	OLDIFS=$IFS
	IFS=,
	local filename="attributelist.csv"
	local delim='' # no comma at start
	cat $filename | while read attr alias tail
	do
		printf "${delim}${attr} as ${alias}"
		delim=", " #ecerysubsequest attribute has to have comma in front
	done
	IFS=$OLDIFS
}
