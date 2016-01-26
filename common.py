import os
import sys
import csv
import psycopg2
import common
import subprocess

cv=10

import sys
import csv
from collections import defaultdict

def construct_line( label, line ):
	new_line = []
	if float( label ) == 0.0:
		label = "0"
	new_line.append( label )

	for i, item in enumerate( line ):
		if item == '' or float( item ) == 0.0:
			continue
		new_item = "%s:%s" % ( i + 1, item )
		new_line.append( new_item )
	new_line = " ".join( new_line )
	new_line += "\n"
	return new_line

# ---
def csv2libsvm(input_file, output_file, label_index, skip_headers):

	i = open( input_file, 'rb' )
	o = open( output_file, 'wb' )

	reader = csv.reader( i )

	if skip_headers:
		headers = reader.next()

	for line in reader:
		if label_index == -1:
			label = '1'
		else:
			label = line.pop( label_index )

		new_line = construct_line( label, line )
		o.write( new_line )

#calculates mode with crossvalidating, saves into models/${1}.model
#used for building models mostly for calculation of best attributes and other parameters
def lsCalcModel(stockname, exclude, cvNum, data):
	print "stockname='{0}', cross validation folds='{1}', cost='{2}'".format(stockname, exclude, cvNum)
	
	if (not cvNum) or (cvNum==""):
		cvOption=""
	else:
		cvOption="-v ${2}"

	print "cvOption=${0}".format(cvOption)

	if (not exclude) or (exclude != "-") or (exclude == ""):
		cmd = "cut --complement -d, -f $(echo {0})".format(cvOption)
	else:
		cmd = "cat"

	print "cmd={0}".format(cmd)
	proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	extractdata = proc.communicate(input=data)[0]
	
	header=extractdata.splitlines()[0]
	hdrArray=header.split(",")
	hlen=len(hdrArray)
	print "array len={0}, class is last title={1}".format(hlen, hdrArray[hlen-1])
	os.system("./csv2libsvm.py extractdata lsdata hlen-1 1")
	print lsdata
##	lsCsvToLibsvm <(printf "$extractdata") "extracts/${1}.ls" 1
#	./csv2libsvm.py $1 $2 $classIndex0Based 1
#	echo "csv2libsvm finished"
#	echo -n "scaling..."
#	$LSLIB/svm-scale -s "extracts/${1}.range" "extracts/${1}.ls" > "extracts/${1}.ls.scaled" 2>/dev/null
#	echo "scaling finished"
#	IFS=
#	train_cmd="$LSLIB/svm-train -s 4 -t 2 -c $wkCost -n $wkNu $(echo "${cvOption}") extracts/${1}.ls.scaled models/${1}.ls.model"
#	echo -n "training..."
#	trainres=$(eval ${train_cmd})
#	echo "training finished"
#	error=$(cat <(printf "$trainres") | grep "Cross Validation Mean squared error = " | tr -s ' ' | cut -d " " -f 7)
#	correlation=$(cat <(printf "$trainres") | grep "Squared correlation coefficient = " | tr -s ' ' | cut -d " " -f 7)
#
#
#function lsPredict() {
#	echo "stockname='$1'"
#
#	if [ "$2" != "-" ]
#	then
#		IFS=
#		extractdata=$(cut --complement -d, -f $(echo $2))
#		echo "excluded not needed attributes"
#	else
#		echo "copy no index removal.       "
#		extractdata=$(cat)
#	fi
#	echo "csv2libsvm..."
#	#new view puts 0 in the unknown value
##	fixedClassOnlyNeededAttr=$(paste -d '\0' <(printf "$extractdata") <(printf '\n-100'))
#	fixedClassOnlyNeededAttr=$extractdata
#	echo "$fixedClassOnlyNeededAttr" > extracts/${1}.ls.excludedattrs.csv
##	echo "$extractdata" > extractdata_debug.txt
#	IFS=
#	lsCsvToLibsvm "extracts/${1}.ls.excludedattrs.csv" "extracts/${1}.ls.test"
#	$LSLIB/svm-scale -r "extracts/${1}.range" "extracts/${1}.ls.test" > "extracts/${1}.ls.test.scaled"
#
#	IFS=
#	cmd="$LSLIB/svm-predict extracts/${1}.ls.test.scaled models/${1}.ls.model models/${1}.ls.prediction"
##	set -x
#	eval ${cmd}
#	prediction=$(cat models/${1}.ls.prediction)
#	echo "prediction:$prediction"
#}
#
#function lsCsvToLibsvm() {
#	OLDIFS=IFS
#	IFS=,
#	allAttributes=$(head -1 $1)
#	read -r -a attrArray <<< "$allAttributes"
#	classAttribute=${attrArray[-1]}
#	classIndex=${#attrArray[@]}
#	classIndex0Based=$(( $classIndex-1 ))
#	echo "classAttribute='$classAttribute', Last index=$classIndex, Last index zero based=$classIndex0Based"
#	./csv2libsvm.py $1 $2 $classIndex0Based 1
#
#	IFS=OLDIFS
#}
#
