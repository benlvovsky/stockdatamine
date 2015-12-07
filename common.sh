#!/bin/bash
export PGPASSWORD='postgres'

function maxDatePlusOne() {
	maxdate=`psql -t -h localhost -U postgres -d postgres -c "select max(date + interval '1 day') from stocks where stock='$1';"`
	echo "maxdate read from DB='$maxdate'"
	maxdate=${maxdate//[[:blank:]]/} #trim
	if [ -z "$maxdate" ]; then
		maxdate="2014-01-01"
		echo "defaulted as was empty"
	fi
	echo "maxdate in use: $maxdate"
	year=${maxdate:0:4}
	month=${maxdate:5:2}
	monthfixed=$((month-1))
	printf "monthfixed=${monthfixed}\n"
	day=${maxdate:8:2}
	echo "Day=${day}, Month=${month}, Month fixed=${monthfixed}, Year=${year}"
}

function importIntoDB() {
	echo "Importing $1 into DB from models/${1}_fixed.csv"
	sql="COPY stocks (stock,date,open,high,low,close,\"Adj Close\") FROM '$(pwd)/models/${1}_fixed.csv' WITH CSV delimiter as ','"
	printf "${sql}\n"
	#	psql -h localhost -U postgres -d postgres -c "delete from stocks where stock='$1'"
	psql -h localhost -U postgres -d postgres -c "${sql}"
	echo "Importing $1 into DB finished"
}
