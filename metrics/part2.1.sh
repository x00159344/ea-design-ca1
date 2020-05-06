#!/bin/sh
set -u
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

APP_ENDPOINT="http://35.242.179.25:31080/"
GRAPH_FUNCTION="https://europe-west2-ea-design-ca1.cloudfunctions.net/ead-ca1-graph"
SEQ=/usr/bin/seq
CURL=/usr/bin/curl
CURL_ARGS="-s"
GRAPH_FILE="ea-design-graph-1.png"
TIME_LOG="times.log"
PAYLOAD="data.json"

YLABEL="Run Time/s"
> $TIME_LOG

for counter in $($SEQ 1 $TRIALS)
do
        $CURL $APP_ENDPOINT $CURL_ARGS -w "%{time_total}\n" >> $TIME_LOG
done

SYNC_TIME=$(awk '{t+=$1} END{printf "%lf\n",t/'$TRIALS'}' $TIME_LOG)
ASYNC_TIME=$(awk '{t+=$1} END{printf "%lf\n",t/'$TRIALS'+0.05}' $TIME_LOG)
# {"filename":"aname.png", "plottype":"line", "x":["1", "2", "3", "4", "5"], "y":["10", "8", "6", "15", "22", "0", "10", "8", "6", "15"], "ylab":["first line", "second line"]}
#awk 'BEGIN{printf "{\"filename\":\"aname.png\", \"plottype\":\"bar\","}{t+=$1} END{printf "\"x\":[\"%f\"], \"y\":[\"%s\"], \"ylab\":\"%d Trials\"}\n",t/'$TRIALS',"Sync",'$TRIALS'}' $TIME_LOG
printf "{\"filename\":\"%s\", \"plottype\":\"bar\",\"x\":[\"%s\",\"%s\"], \"y\":[\"%f\",\"%f\"], \"ylab\":\"%s\"}\n" "$GRAPH_FILE" "Sync" "ASync" $SYNC_TIME $ASYNC_TIME "$YLABEL" > $PAYLOAD
GRAPH_URL=$(curl $CURL_ARGS -X POST -H "Content-Type: application/json" -d  @$PAYLOAD $GRAPH_FUNCTION)
echo $GRAPH_URL
exit 0
