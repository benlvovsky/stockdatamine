#!/bin/bash
./go.py v2Predict ^AORD,^AXDJ,^AXSJ,^AXEJ,^AXFJ,^AXXJ,^AXHJ,^AXNJ,^AXIJ,^AXMJ,^AXJR,^AXUJ $1 | grep -vE '\.\.\.|Using|PGHOST|Done|Expecting|Preferably|Features request' | ./csv2html.sh
