#!/bin/sh
set -u
if [ $# -ne 0 ]
then
        echo "Usage: ${0##*/}"
        echo "       Run timing experiment for recovery of each service"
        exit 1
fi


SERVICES=$(kubectl get services | grep -v -e ^NAME -e ^kubernetes | awk '{print $1}')

APP_ENDPOINT="http://35.242.179.25:31080/"
GRAPH_FUNCTION="https://europe-west2-ea-design-ca1.cloudfunctions.net/ead-ca1-graph"
SEQ=/usr/bin/seq
CURL=/usr/bin/curl
CURL_ARGS="-s"
GRAPH_FILE="ea-design-graph-3.png"
POLL_LOG="polling.log"
PAYLOAD="data.json"
TRIALS=100

YLABEL="Event Frequency"
> $POLL_LOG

for service in $SERVICES
do
    kubectl delete $service
    
done

AVG_TIME=$(awk '{t+=$1} END{printf "%lf\n",t/'$TRIALS'}' $POLL_LOG)
printf "{\"filename\":\"%s\", \"plottype\":\"line\",\"x\":[\"%s\",\"%s\"], \"y\":[\"%f\",\"%f\"], \"ylab\":\"%s\"}\n" "$GRAPH_FILE" "Sync" "ASync" $SYNC_TIME $ASYNC_TIME "$YLABEL" > $PAYLOAD
GRAPH_URL=$(curl $CURL_ARGS -X POST -H "Content-Type: application/json" -d  @$PAYLOAD $GRAPH_FUNCTION)
echo <<EOF
<HTML>
<HEAD>
<TITLE>Enterprise Architecture Design CA1 - Graph 3</TITLE>
</HEAD>
<BODY>
<H1>Client Response Time</H1>
<P>Graph comparing recovery time after killing a given service</P>
<BR>
<IMG SRC="$GRAPH_URL">
</BODY>
</HTML>
EOF

exit 0
