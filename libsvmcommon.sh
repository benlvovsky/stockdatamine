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

#calculates mode with crossvalidating, saves into models/${1}.model
#used for building models mostly for calculation of best attributes and other parameters
function lsCalcModel() {
#	set -x
#	echo "stockname='$1', exclude Fields='$2', cross validation folds='$3'"
	echo "stockname='$1', cross validation folds='$3', cost='$wkCost'"
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
	echo -n "csv2libsvm..."
	lsCsvToLibsvm <(printf "$extractdata") "extracts/${1}.ls" 1
	echo "csv2libsvm finished"
	echo -n "scaling..."
	$LSLIB/svm-scale -s "extracts/${1}.range" "extracts/${1}.ls" > "extracts/${1}.ls.scaled" 2>/dev/null
	echo "scaling finished"
#	set -x
	IFS=
	train_cmd="$LSLIB/svm-train -s 4 -t 2 -c $wkCost -n $wkNu $(echo "${cvOption}") extracts/${1}.ls.scaled models/${1}.ls.model"
	echo -n "training..."
	trainres=$(eval ${train_cmd})
	echo "training finished"
	error=$(cat <(printf "$trainres") | grep "Cross Validation Mean squared error = " | tr -s ' ' | cut -d " " -f 7)
	correlation=$(cat <(printf "$trainres") | grep "Squared correlation coefficient = " | tr -s ' ' | cut -d " " -f 7)
}

function lsPredict() {
	echo "stockname='$1'"

	if [ "$2" != "-" ]
	then
		IFS=
		extractdata=$(cut --complement -d, -f $(echo $2))
		echo "excluded not needed attributes"
	else
		echo "copy no index removal.       "
		extractdata=$(cat)
	fi
	echo "csv2libsvm..."
	fixedClassOnlyNeededAttr=$(paste -d '\0' <(printf "$extractdata") <(printf '\n-100'))
	echo "$fixedClassOnlyNeededAttr" > extracts/${1}.ls.excludedattrs.csv
	echo "$extractdata" > extractdata_debug.txt
	IFS=
	lsCsvToLibsvm "extracts/${1}.ls.excludedattrs.csv" "extracts/${1}.ls.test"
	$LSLIB/svm-scale -r "extracts/${1}.range" "extracts/${1}.ls.test" > "extracts/${1}.ls.test.scaled"

	IFS=
	cmd="$LSLIB/svm-predict extracts/${1}.ls.test.scaled models/${1}.ls.model models/${1}.ls.prediction"
#	set -x
	eval ${cmd}
	prediction=$(cat models/${1}.ls.prediction)
	echo "prediction:$prediction"
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
