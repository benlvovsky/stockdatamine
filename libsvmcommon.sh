#!/bin/bash
export CP=$WEKA_PATH:/home/ben/wekafiles/packages/LibSVM/LibSVM.jar:/home/ben/wekafiles/packages/LibSVM/lib/libsvm.jar:/media/bigdrive/dev/weka-3-7-13/weka.jar:$CLASSPATH
export LSLIB=./libsvm-3.21
if [ -z "$wkCost" ]
then
	wkCost=100
fi
if [ -z "$wkNu" ]
then
	wkNu=0.55
fi

#rm -f range.fifo
#rm -f extract.fifo
#mkfifo range.fifo
#mkfifo extract.fifo

#calculates mode with crossvalidating, saves into models/${1}_currtrialattr.model
#used for building models mostly for calculation of best attributes and other parameters
function lsCalcModel() {
#	set -x
#	echo "stockname='$1', exclude Fields='$2', cross validation folds='$3'"
	echo "stockname='$1', cross validation folds='$3'"
	echo
	if [ -z "$3" ]
	then
		cvOption=""
	else
		cvOption="-v ${3}"
	fi
	#echo "cvOption=${cvOption}"

	if [ "$2" != "-" ]
	then
		OIFS=$IFS
		IFS=
		extractdata=$(cut --complement -d, -f $(echo $2))
		IFS=$OIFS
	else
		echo -n "copy no index removal.       "
		extractdata=$(cat)
	fi
	echo "csv2libsvm..."
	lsCsvToLibsvm <(printf "$extractdata") extracts/${1}.ls 1
	$LSLIB/svm-scale -s extracts/${1}.range extracts/${1}.ls > extracts/${1}.ls.scaled
	train_cmd="$LSLIB/svm-train -s 4 -t 2 -c $wkCost -n $wkNu $(echo "${cvOption}") extracts/${1}.ls.scaled models/${1}.ls.model"
	trainres=$(eval $train_cmd)
	error=$(cat <(printf "$trainres") | grep "Cross Validation Mean squared error = " | tr -s ' ' | cut -d " " -f 7)
	correlation=$(cat <(printf "$trainres") | grep "Squared correlation coefficient = " | tr -s ' ' | cut -d " " -f 7)
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

function lsCsvToLibsvm() {
	OLDIFS=IFS
	IFS=,
	allAttributes=$(head -1 $1)
	read -r -a attrArray <<< "$allAttributes"
	classAttribute=${attrArray[-1]}
	classIndex=${#attrArray[@]}
	classIndex0Based=$(( $classIndex-1 ))
	echo "classAttribute='$classAttribute', Last index=$classIndex, Last index zero based=$classIndex0Based"
	./csv2libsvm.py $1 $2 $classIndex0Based 1

	IFS=OLDIFS
}

function lsEasyCall() {
	cd ~/dev/stocks/datamine/libsvm-3.21/tools
	./easy.py ../../extracts/CBA.AX_libsvm_temptest1.txt ../../extracts/CBA.AX_test.txt
}
