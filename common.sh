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

function dmStocksNoAttr() {
	psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks where bestattributes is null or bestattributes ='') to STDOUT WITH CSV delimiter as ','"
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

function calcModel() {
#	echo "param1='$1', param2='$2', param3='$3'"
	if [ -z "$3" ]
	then
		cv=10
	else
		cv=$3
	fi
	
	if [ "$2" != "-" ]
	then
		OIFS=$IFS
		IFS=
		#echo "::::::::::"$(echo $2)
		echo -n "Remove attribute indexes $2. "
		#'cat extracts/${1}.csv | cut --complement -d, -f $2 > extracts/${1}_currtrialattr.csv' "
		cat extracts/${1}.csv | cut --complement -d, -f $(echo $2) > extracts/${1}_currtrialattr.csv
		IFS=$OIFS
	else
		echo -n "copy no index removal.       "
		cat extracts/${1}.csv > extracts/${1}_currtrialattr.csv
	fi
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${1}_currtrialattr.csv > models/${1}_currtrialattr.arff;
	correlation=$(java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 \
			-R 0.0 -N 0.74 -M 40.0 -C 5.0 -E 0.001 -P 0.1 \
			-seed 1 \
			-x $cv \
			-t "models/${1}_currtrialattr.arff" \
			-d "models/${1}_currtrialattr.model" | tee "models/${1}_currtrialattr.model.output" \
				| grep "Correlation coefficient" | tail -1 | tr -s ' ' | cut -d " " -f 3)
}
