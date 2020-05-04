#!/bin/sh
set -u
HOMEDIR="$HOME/ea-design-ca1"
CA1_PROJECT="ea-design-ca1"
K8S_CLUSTER="ea-design-ca1"
K8S_ZONE="europe-west2-a"
FIREWALL_RULE="ead-ca1-node-port"

#gcloud init --console-only
gcloud config set project ea-design-ca1
gcloud container clusters create "$K8S_CLUSTER" --zone $K8S_ZONE
echo "Connecting to Kubernetes Cluster $K8S_CLUSTER"

gcloud container clusters get-credentials $K8S_CLUSTER --zone $K8S_ZONE --project $CA1_PROJECT

for pod in $HOMEDIR/async/manifests/*.yaml 
do
	kubectl apply -f $pod
done

echo -n "External Endpoint IPs: "
kubectl describe nodes |grep ExternalIP | awk '{printf "%s ",$NF} END{printf "\n"}'
ALLOW_ACCESS="$(gcloud compute firewall-rules list | fgrep $FIREWALL_RULE)"
if [ "$ALLOW_ACCESS" = "" ]
then
	gcloud compute firewall-rules create "$FIREWALL_RULE" --allow tcp:31080
fi
exit 0
