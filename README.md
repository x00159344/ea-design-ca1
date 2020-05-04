Enterprise Architecture Design CA1 Code Submission

Part 1.
The code for the sync and async microservices applications is based on the course labs, particularly Lab 3.
The G service is implemented under the Seccon name. The A and B services are implemented under the Door1
and Door 2 names respectively. These microservices applications are deployed on a Kubernetes cluster on
the Google Cloud Platform.
The scripts in the clusters/ directory create and destroy the Kubernetes cluster and associated pods and
services.

Part 2.
1/
For the purposes of creating the graphs for this assignment, the Python graphing function supplied was 
adapted and installed as a Cloud Function (FaaS) at the endpoint: -
	https://europe-west2-ea-design-ca1.cloudfunctions.net/ead-ca1-graph

The script part2.1.sh in the metrics/ directory runs a specified number of times against the endpoint and calculates
the average time taken for access for both the sync and async applications. It then generates a graph by
calling the above Cloud Function to draw a bar chart comparing the performance of the two applications.

2/

3/


Notes:
When the graphing code was committed to Github, an alert was e-mailed to the Repo owner warning of a 
security vulnerability in the version of the requests package (2.13.0) in the requirements.txt file. The
recommended version of the requests package was 2.20.0. The requirements.txt was updated to use the
newer version.
