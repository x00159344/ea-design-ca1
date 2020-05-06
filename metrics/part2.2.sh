#!/bin/sh
set -u
if [ $# -ne 1 ]
then
        echo "Usage: ${0##*/} <Polling Frequency>"
        echo "       Run timing experiment with the specified polling frequency in seconds for G"
        exit 1
else
        POLL_FREQ=$1
fi
if [ -n "$POLL_FREQ" ] && [ "$POLL_FREQ" -eq "$POLL_FREQ" ] 2>/dev/null; then
  echo "Setting Polling Frequency to be $POLL_FREQ"
else
  echo "Not a number: $POLL_FREQ"
  exit 1
fi

APP_ENDPOINT="http://35.242.179.25:31080/"
GRAPH_FUNCTION="https://europe-west2-ea-design-ca1.cloudfunctions.net/ead-ca1-graph"
SEQ=/usr/bin/seq
CURL=/usr/bin/curl
CURL_ARGS="-s"
GRAPH_FILE="ea-design-graph-2.png"
POLL_LOG="polling.log"
PAYLOAD="data.json"
TRIALS=100

YLABEL="Event Frequency"
> $POLL_LOG

for counter in $($SEQ 1 $TRIALS)
do
    $CURL $APP_ENDPOINT $CURL_ARGS -w "%{time_total}\n" >> $POLL_LOG
    sleep $POLL_FREQ
done

AVG_TIME=$(awk '{t+=$1} END{printf "%lf\n",t/'$TRIALS'}' $POLL_LOG)
printf "{\"filename\":\"%s\", \"plottype\":\"line\",\"x\":[\"%s\",\"%s\"], \"y\":[\"%f\",\"%f\"], \"ylab\":\"%s\"}\n" "$GRAPH_FILE" "Sync" "ASync" $SYNC_TIME $ASYNC_TIME "$YLABEL" > $PAYLOAD
GRAPH_URL=$(curl $CURL_ARGS -X POST -H "Content-Type: application/json" -d  @$PAYLOAD $GRAPH_FUNCTION)
echo <<EOF
<HTML>
<HEAD>
<TITLE>Enterprise Architecture Design CA1 - Graph 2</TITLE>
</HEAD>
<BODY>
<H1>Client Response Time</H1>
<P>Graph comparing client response time for synchronous and asynchronous call averaged of $TRIALS calls</P>
<BR>
<IMG SRC="$GRAPH_URL">
</BODY>
</HTML>
EOF

exit 0
