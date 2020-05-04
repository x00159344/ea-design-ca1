#!/bin/sh
set -u
HOMEDIR="$HOME/ea-design-ca1"
CA1_PROJECT="ea-design-ca1"
K8S_CLUSTER="ea-design-ca1"
K8S_ZONE="europe-west2-a"
FIREWALL_RULE="ead-ca1-node-port"


for pod in $HOMEDIR/manifests/*.yaml 
do
	kubectl delete -f $pod
done

ALLOW_ACCESS="$(gcloud compute firewall-rules list | fgrep $FIREWALL_RULE)"
if [ "$ALLOW_ACCESS" != "" ]
then
	gcloud compute firewall-rules delete "$FIREWALL_RULE" --quiet
fi
gcloud container clusters delete "$K8S_CLUSTER" --quiet --region europe-west2-a
exit 0
