#!/bin/sh

if [ $# -ne 1 ]
then
	echo "Usage: ${0##*/} <trials>"
	echo "       Run timing experiment specified number of times returning the average time"
	exit 1
else
	TRIALS=$1
fi
if [ -n "$TRIALS" ] && [ "$TRIALS" -eq "$TRIALS" ] 2>/dev/null; then
  echo "Running $TRIALS trials"
else
  echo "Not a number: $TRIALS"
  exit 1
fi

ENDPOINT="http://35.230.128.155:31080/"
SEQ=/usr/bin/seq
CURL=/usr/bin/curl
CURL_ARGS="-s -o /dev/null"
TIME_LOG="times.log"

> $TIME_LOG

for counter in $($SEQ 1 $TRIALS)
do
	$CURL $ENDPOINT $CURL_ARGS -w "%{time_total}\n" >> $TIME_LOG
done

awk '{t+=$1;ts+=$1^2} END{printf "Average Time: %f\nStandard Deviation: %f\n",t/'$TRIALS',sqrt(ts/NR-(t/NR)^2)}' $TIME_LOG
exit 0
