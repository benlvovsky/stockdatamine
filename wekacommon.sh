#!/bin/bash
export CP=$WEKA_PATH:/home/ben/wekafiles/packages/LibSVM/LibSVM.jar:/home/ben/wekafiles/packages/LibSVM/lib/libsvm.jar:/media/bigdrive/dev/weka-3-7-13/weka.jar:$CLASSPATH

if [ -z "$wkCost" ]
then
	wkCost=100
fi
if [ -z "$wkNu" ]
then
	wkNu=0.55
fi

#calculates mode with crossvalidating, saves into models/${1}_currtrialattr.model
#used for building models mostly for calculation of best attributes and other parameters
function wkCalcModel() {
#	echo "stockname='$1', exclude Fields='$2', cross validation folds='$3'"
	if [ -z "$3" ]
	then
#		cv=0
		cvOption="-no-cv"
	else
#		cv=$3
		cvOption="-x $3"
	fi
	
	if [ "$2" != "-" ]
	then
		OIFS=$IFS
		IFS=
#		echo -n "Remove attribute indexes $2. "
		cat extracts/${1}.csv | cut --complement -d, -f $(echo $2) > extracts/${1}_currtrialattr.csv
		IFS=$OIFS
	else
		echo -n "copy no index removal.       "
		cat extracts/${1}.csv > extracts/${1}_currtrialattr.csv
	fi
	rm -f models/${1}_currtrialattr.arff
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${1}_currtrialattr.csv > models/${1}_currtrialattr.arff
	rm -f models/${1}_currtrialattr.model
	rm -f models/${1}_currtrialattr.model.output
	wkCmd="java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 \
			-Z \
			-R 0.0 \
			-N $wkNu \
			-M 100.0 \
			-C $wkCost \
			-E 0.001 -P 0.1 -H \
			-seed 1 \
			${cvOption} \
			-t \"models/${1}_currtrialattr.arff\" \
			-d \"models/${1}_currtrialattr.model\" | tee \"models/${1}_currtrialattr.model.output\" \
				| grep \"Correlation coefficient\" | tail -1 | tr -s ' ' | cut -d \" \" -f 3"
#set -x
	correlation=$(eval $wkCmd)
#	echo "Correlation=$correlation"
}

#calculates model without crossvalidating, saves into models/${1}_bestattr.model
#used for building models with known best attributes and other parameters
function wkBuildModel() {
#	echo "stockname='$1', exclude Fields='$2'
	
	if [ "$2" != "-" ]
	then
		OIFS=$IFS
		IFS=
		echo -n "Remove attribute indexes $2. "
		cat extracts/${1}.csv | cut --complement -d, -f $(echo $2) > extracts/${1}_currtrialattr.csv
		IFS=$OIFS
	else
		echo -n "copy no index removal.       "
		cat extracts/${1}.csv > extracts/${1}_currtrialattr.csv
	fi
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${1}_currtrialattr.csv > models/${1}_currtrialattr.arff;
	correlation=$(java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 \
			-Z \
			-R 0.0 \
			-N $wkNu \
			-M 40.0 \
			-C $wkCost \
			-E 0.001 -P 0.1 \
			-seed 1 \
			-no-cv
			-t "models/${1}_currtrialattr.arff" \
			-d "models/${1}_bestattr.model" | tee "models/${1}.model.output" \
				| grep "Correlation coefficient" | tail -1 | tr -s ' ' | cut -d " " -f 3)
}
