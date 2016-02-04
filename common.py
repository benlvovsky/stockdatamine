import os
import sys
import csv
import psycopg2
import subprocess
import cStringIO

svmCost="100"
svmNuDefault=0.556015

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
def lsCalcModel(stockname, exclude, cvNum, data, nu=svmNuDefault):
#	print "stockname='{0}', cv='{1}', cost='{2}', excludeAttrs={3}".format(stockname, cvNum, svmCost, exclude)
	print "stockname='{0}', cv='{1}', cost='{2}', nu={3}".format(stockname, cvNum, svmCost, nu)
	svmNu = "{0}".format(nu)
	
	if (not cvNum) or (cvNum==""):
		cvOption=""
	else:
		cvOption="-v {0}".format(cvNum)

	sys.stdout.write("cvOption="+cvOption+", len(data)={0}. ".format(len(data)))

	if (exclude is not None) and (exclude != "-") and (exclude != ""):
		cmd = "cut --complement -d, -f {0}".format(exclude)
	else:
		cmd = "cat"

	#sys.stdout.write(", cmd='{0}', ".format(cmd))
	proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	extractdata = proc.communicate(input=data)[0]
	
	header=extractdata.splitlines()[0]
	hdrArray=header.split(",")
	hlen=len(hdrArray)
	sys.stdout.write("array len={0}, class is last title={1}\n".format(hlen, hdrArray[hlen-1]))
	csv2libsvm(extractdata, "extracts/{0}.ls".format(stockname), hlen-1, True)
	
	cmd=LSLIB+'/svm-scale -s "extracts/{0}.range"  "extracts/{0}.ls" > "extracts/{0}.ls.scaled"'.format(stockname)
	sys.stdout.write("Scaling... ")#command='+cmd+"'"
	proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	try:
		errdata = proc.communicate()[1]
#		if errdata != None:
#			print "" + errdata
	except:
		True
#	sys.stdout.write("...scaling finished\n")

	cmd=LSLIB+'/svm-train -s 4 -t 2 -c ' + svmCost + ' -n ' + svmNu + ' ' + cvOption + ' extracts/{0}.ls.scaled models/{0}.ls.model'.format(stockname)
	sys.stdout.write("Training... command='"+cmd+"'\n")
	#sys.stdout.write("Training...")
	proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	trainres= proc.communicate()[0]
	#sys.stdout.write("Train output:\n" + trainres + '\n')
	try:
		errdata = proc.communicate()[1]
		if errdata != None :
			print "		Train error: " + errdata
	except:
		True
#	sys.stdout.write("...training finished\n")

	error= trainres.splitlines()[-2].split(" = ")[1]
	corr = trainres.splitlines()[-1].split(" = ")[1]
	print "Mean Squared Error='" + error +"'"
	print "Correlation=       '" + corr  +"'"
	
	return (float(error), float(corr), header)

def lsPredict(stockname, exclude, data, nu=svmNuDefault):
	cmd=LSLIB+"/svm-predict extracts/{0}.ls.scaled models/{0}.ls.model models/{0}.ls.prediction".format(stockname)
	print "Command:"+cmd
	extractScaleRunCmd(stockname, exclude, None, data, nu, cmd)
	f = open("models/{0}.ls.prediction".format(stockname),"r")
	prStr = f.read()
	prFloat = float(prStr)
	print "prFloat={0}".format(prFloat)
	#TODO get data from generated file predictions and return psql -h localhost -U postgres -d postgres -c "update dataminestocks set prediction=${prediction}, preddate='$date'::date where stockname='${stockName}'"
	sys.exit(99)
	return (0,0,"")

#./libsvm-3.21/svm-predict extracts/CBA.ls.scaled models/CBA.ls.model models/CBA.ls.prediction

def extractScaleRunCmd(stockname, exclude, cvNum, data, nu, cmdProc):
	svmNu = "{0}".format(nu)
	
	if (not cvNum) or (cvNum==""):
		cvOption=""
	else:
		cvOption="-v {0}".format(cvNum)

	sys.stdout.write("cvOption="+cvOption+", len(data)={0}. ".format(len(data)))

	if (exclude is not None) and (exclude != "-") and (exclude != ""):
		cmd = "cut --complement -d, -f {0}".format(exclude)
	else:
		cmd = "cat"

	#sys.stdout.write(", cmd='{0}', ".format(cmd))
	proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	extractdata = proc.communicate(input=data)[0]
	header=extractdata.splitlines()[0]
	hdrArray=header.split(",")
	hlen=len(hdrArray)
	sys.stdout.write("array len={0}, class is last title={1}\n".format(hlen, hdrArray[hlen-1]))
	csv2libsvm(extractdata, "extracts/{0}.ls".format(stockname), hlen-1, True)
	
	cmd=LSLIB+'/svm-scale -s "extracts/{0}.range"  "extracts/{0}.ls" > "extracts/{0}.ls.scaled"'.format(stockname)
	sys.stdout.write("Scaling... ")#command='+cmd+"'"
	proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	try:
		errdata = proc.communicate()[1]
#		if errdata != None:
#			print "" + errdata
	except:
		True
#	sys.stdout.write("...scaling finished\n")

	sys.stdout.write("Next command='"+cmdProc+"'\n")
	#sys.stdout.write("Training...")
	proc = subprocess.Popen(cmdProc, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	trainres= proc.communicate()[0]
	#sys.stdout.write("Train output:\n" + trainres + '\n')
	try:
		errdata = proc.communicate()[1]
		if errdata != None :
			print "Error: " + errdata
	except:
		True

#	sys.stdout.write("...training finished\n")

#	error= trainres.splitlines()[-2].split(" = ")[1]
#	corr = trainres.splitlines()[-1].split(" = ")[1]
#	print "Mean Squared Error='" + error +"'"
#	print "Correlation=       '" + corr  +"'"
	
#	return (float(error), float(corr), header)
	return (trainres, errdata)

#		extractdata=$(cut --complement -d, -f $(echo $2))
#		echo "excluded not needed attributes"
#	else
#		echo "copy no index removal.       "
#		extractdata=$(cat)
#	fi
#	echo "csv2libsvm..."
#	#new view puts 0 in the unknown value
#	fixedClassOnlyNeededAttr=$extractdata
#	echo "$fixedClassOnlyNeededAttr" > extracts/${1}.ls.excludedattrs.csv
#	IFS=
#	lsCsvToLibsvm "extracts/${1}.ls.excludedattrs.csv" "extracts/${1}.ls.test"
#	$LSLIB/svm-scale -r "extracts/${1}.range" "extracts/${1}.ls.test" > "extracts/${1}.ls.test.scaled"
#
#	IFS=
#	cmd="$LSLIB/svm-predict extracts/${1}.ls.test.scaled models/${1}.ls.model models/${1}.ls.prediction"
#	eval ${cmd}
#	prediction=$(cat models/${1}.ls.prediction)
#	echo "prediction:$prediction"
