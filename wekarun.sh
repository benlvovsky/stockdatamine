#!/bin/bash
source ./common.sh

export WEKA_PATH=/media/bigdrive/dev/weka-3-7-13
export CP=$WEKA_PATH:$CLASSPATH:/home/ben/wekafiles/packages/LibSVM/LibSVM.jar:/home/ben/wekafiles/packages/LibSVM/lib/libsvm.jar:/media/bigdrive/dev/weka-3-7-13/weka.jar

#java -classpath $CP -Xmx1000m weka.jar
java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.74 -M 40.0 -C 5.0 -E 0.001 -P 0.1 \
-model /media/bigdrive/dev/weka-3-7-13 -seed 1 \
-t "extracts/CBA.AX.csv"

#Scheme:       weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.74 -M 40.0 -C 5.0 -E 0.001 -P 0.1 -model /media/bigdrive/dev/weka-3-7-13 -seed 1 weka.filters.unsupervised.attribute.Remove-R1-2
#Relation:     CBA.AX-weka.filters.unsupervised.attribute.Remove-R1-2
