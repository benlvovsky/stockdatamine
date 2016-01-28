import os
import sys
import csv
import psycopg2
import subprocess
import cStringIO

svmCost="100"
svmNu="0.55"

LSLIB="libsvm-3.21"

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

def csv2libsvm(iStr, output_file, label_index, skip_headers):
	i = cStringIO.StringIO(iStr)
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

	o.close()
	i.close()

#calculates mode with crossvalidating, saves into models/${1}.model
#used for building models mostly for calculation of best attributes and other parameters
def lsCalcModel(stockname, exclude, cvNum, data):
	print "stockname='{0}', cross validation folds='{1}', cost='{2}'".format(stockname, exclude, cvNum)
	
	if (not cvNum) or (cvNum==""):
		cvOption=""
	else:
		cvOption=" -v {0} ".format(cvNum)

	print "cvOption="+cvOption

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
	csv2libsvm(extractdata, "extracts/{0}.ls".format(stockname), hlen-1, True)
	
	cmd=LSLIB+'/svm-scale -s "extracts/{0}.range"  "extracts/{0}.ls" > "extracts/{0}.ls.scaled"'.format(stockname)
	print "Scaling... "#command='+cmd+"'"
	proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	try:
		errdata = proc.communicate()[1]
		if errdata != None :
			print "		Error: " + errdata
	except:
		True
	print "...scaling finished"

	cmd=LSLIB+'/svm-train -s 4 -t 2 -c ' + svmCost + ' -n ' + svmNu + cvOption + ' extracts/{0}.ls.scaled models/{0}.ls.model'.format(stockname)
	print "Training... command='"+cmd+"'"
	proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	trainres= proc.communicate()[0]
	print "Stdout trainres: " + trainres
	try:
		errdata = proc.communicate()[1]
		if errdata != None :
			print "		Error: " + errdata
	except:
		True
	print "...training finished"

	error= trainres.splitlines()[-2].split(" = ")[1]
	corr = trainres.splitlines()[-1].split(" = ")[1]
	print "Mean Squared Error='" + error +"'"
	print "Correlation=       '" + corr  +"'"
	
	return (error, corr)

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
##	fixedClassOnlyNeededAttr=$(import cStringIOpaste -d '\0' <(printf "$extractdata") <(printf '\n-100'))
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
