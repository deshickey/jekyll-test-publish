---
layout: default
description: How to resolve Satellite Link Task manager network query (HTTP Status Check Failed)
title: Satellite Link Network Query - How to resolve 
service: satellite-link
runbook-name: "Satellite Link Health HTTPS status"
tags:  satellite-link, health, https status 
link: /satellite-link/Sattelite Link Tunnel Health (Consumption)
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Link
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `SatelliteLinkHealthHTTPStatusCheckFailed`| Connection error in network availability
 | [Steps to debug Satellite-Link network query](#steps-to-debug-satellite-link-network-query) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = SatelliteLinkHealthHTTPStatusCheckFailed
 - alert_situation = SatelliteLinkHealthHTTPStatusCheckFailed
 - service = satellite-link
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = satellite-link
Annotations:
 - summary = "HTTP Status check failed for {% raw %}{{ $labels.exported_instance }}{% endraw %}"
 - description = "HTTP Status check failed for {% raw %}{{ $labels.exported_instance }}{% endraw %}"
~~~~

## Steps to debug Satellite-Link network query

## Actions to take

# What does this PD means?

Satellite link task manager checks network availability of API server in Production or Staging.
If network query returns a connection error then a PD alert is triggered.

These are API server urls that Satellite Link task checks each 3 minutes:

Global API For DEV:

https://api.link.satellite.test.cloud.ibm.com/

Global API For PROD:

https://api.link.satellite.cloud.ibm.com/

Reginal API For Prod:

https://api.mzr.link.satellite.cloud.ibm.com where mzr is replaced with the definitions of MZRs; currently they are:
- Production `au-syd, br-sao, ca-tor, jp-osa, us-south, eu-de, eu-gb, us-east, jp-tok`
- Staging `us-south`

# Alert Definition 

The code for the api healthcheck in this case (health httpstatus monitoring) is `code="$(curl -s -w "%{http_code}" -o /dev/null $URL)"` where URL is global link api https://api.link.satellite.cloud.ibm.com, or regional link api https://api.`mzr`link.satellite.cloud.ibm.com.

The logic for that test is "is the api endpoint reachable and producing a return code 200?"

The test is running on all envs and it is testing Global API and Regional API on all known envs; this means that the environments are cross checking among themselves and network issues are easily detected.

<img width="836" alt="http_health_status" src="https://media.github.ibm.com/user/348396/files/b1076a00-f17a-11ec-9036-adc41af7a55d">

Do not confuse the env that is raising the alert with the env that is not responding.
Satellite Link Health Httpstatus is Triggered/Resolved for region api.us-south.link.satellite.cloud.ibm.com envSATPROD ca-tor
means that "ca-tor" is complaining about "us-south" not responding.

Regarding the alert the threshold to 0.1. Two failures in last three minutes (avg=-0.3333) will be needed to detect a real problem, so we get the alarm two minutes later than the occurrence of the problem .

## How to verify if API is really down or it has been a spike in connectivity?  
### Do a quick curl test to check first

If alerts is on PROD API run:

``` 
curl https://api.link.satellite.cloud.ibm.com/datastore_status 
```

If alert is on DEV API run:

``` 
curl https://api.link.satellite.test.cloud.ibm.com/datastore_status 
```
### Steps for troubleshooting run healthcheck script from the task pods in any region and view results

You can verify the Satellite Link Health and infrastructure status Dashboard, make sure its only a spike and if issue auto resolves.

You can also verify if the envs are healthy, we can run healthcheck script from the task pods in any region and view results.
Below is an example on how to run the command:
```
kubectl exec -n satellite-link -it satellite-link-tasks-XXXXXX /sretools/envhealthcheck.sh REGIONNAME
```
source code for this script https://github.ibm.com/IBM-Cloud-Platform-Networking/satellite-link-tasks/blob/master/sretools/envhealthcheck.sh
please note all the EP status should show as {"status":"UP"}

- Login via IBM Cloud CLI to `Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928` account with no region specified (Command `ibmcloud login -sso -a https://cloud.ibm.com -c e3feec44d9b8445690b354c493aa3e89 --no-region`).
<img width="930" alt="Screen Shot 2022-06-21 at 3 59 12 PM" src="https://media.github.ibm.com/user/348396/files/75b96b00-f17b-11ec-9840-ccc9718e01a2">

- Find what is the name of the tugboat named "sla" for the region from where you want to run the healthcheck test (Command `ibmcloud ks cluster ls`), and connect to it (Command `ibmcloud ks cluster config --cluster "<tugboat-name>"`).
<img width="930" alt="Screen Shot 2022-06-21 at 3 59 12 PM" src="https://media.github.ibm.com/user/348396/files/75b96b00-f17b-11ec-9840-ccc9718e01a2"><img width="1106" alt="Screen Shot 2022-06-21 at 3 59 38 PM" src="https://media.github.ibm.com/user/348396/files/a39eaf80-f17b-11ec-9e8e-79014f04b319">


- Find the name of the "task" pod (usually the second in the list shown) where the healthcheck script will run, and remember it (Command `kubectl -n satellite-link get pods`).
<img width="824" alt="Screen Shot 2022-06-21 at 3 59 44 PM" src="https://media.github.ibm.com/user/348396/files/c7fa8c00-f17b-11ec-9c1f-ce6b0982915e">

- Run the script on the "task" pod against the region you want to test and look at the result (Command `kubectl exec -n satellite-link -it "<satellite-link-tasks-name>" /tasks/envhealthcheck.sh "<region to be tested>"`).
<img width="1029" alt="Screen Shot 2022-06-21 at 4 06 01 PM" src="https://media.github.ibm.com/user/348396/files/0ee88180-f17c-11ec-8580-6895d8430275">

### Steps for troubleshooting: how to read and manage error message

1. If you get a 404 error, that normally something wrong with API deployment, maybe IKS ingress is not configured corretly or not deployed. 

```
curl https://api.link.satellite.test.cloud.ibm.com/datastore_status
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
``` 
* Do another check to see if ingress is configured or not, below normally means IKS ingress not deployed.
```
curl https://api.link.satellite.test.cloud.ibm.com/
<!DOCTYPE html>
<html>
   <head>
      <title id="titleElement">Host not found</title>
      <meta charset="utf-8">
....
``` 
* A good ingress deployment curl like this 
```
 curl https://api.link.satellite.test.cloud.ibm.com/
{"status":"UP"}
```


2. Akamai error or 5xx error
If there is a 5xx error or an error string is returned as below, that normally means something wrong related to Akamai Edge DNS/Global Load Balancer/CDN property configuration or availability. 
```
curl https://api.link.satellite.cloud.ibm.com/datastore_status
<HTML><HEAD><TITLE>Error</TITLE></HEAD><BODY>
An error occurred while processing your request. <p>
Reference&#32;&#35;30&#46;74c47b68&#46;1626182696&#46;201415a4
</BODY></HTML>
...
```
**In case there is an issue with Akamai contact satellite-link team**

3. If you get a 200 response and something like this, that means the API is actually deployed and configured, 
```
curl https://api.link.satellite.test.cloud.ibm.com/datastore_status
{"service":"Hybrid Link","service_health_version":"1","health":[{"status":"up","service_input":"DB connection check","service_output":"8 of 8 DB connections are good","response_time":616,"response_time_unit":"ms"}]}
```
* Check the **service_output** field, if not all connections are good, that means DB connection problem. You may login to cloud.ibm.com to check the service status https://cloud.ibm.com/status, you may see something event like this that confirms a db problem. 
<img width="1022" alt="Screen Shot 2022-06-21 at 4 08 52 PM" src="https://media.github.ibm.com/user/348396/files/73a3dc00-f17c-11ec-977e-cb615197288b">

You can also check logDNA to see if API is reporting database error. 
<img width="1020" alt="Screen Shot 2022-06-21 at 4 09 38 PM" src="https://media.github.ibm.com/user/348396/files/8f0ee700-f17c-11ec-9fb4-b94eb1f08d9d">


* Check one previous Database outage record to see what DB problem like https://github.ibm.com/IBM-Cloud-Platform-Networking/hybrid-link/issues/267. 


## How to fix? 
### 404
If 404 like a ingress problem, you can login to cloud and navigate to the cluster, open 'Kubernetes Dashboard' and check if there is Ingress deployed,
<img width="1065" alt="Screen Shot 2022-06-21 at 4 10 13 PM" src="https://media.github.ibm.com/user/348396/files/a3eb7a80-f17c-11ec-8c06-d6352dec932a">

Example of deployment with errors.

<img width="1058" alt="Screen Shot 2022-06-21 at 4 11 09 PM" src="https://media.github.ibm.com/user/348396/files/c5e4fd00-f17c-11ec-8801-726c8cedb7de">

Example of good deployment (warnings can be ignored). 
<img width="1035" alt="Screen Shot 2022-06-21 at 4 11 36 PM" src="https://media.github.ibm.com/user/348396/files/d6957300-f17c-11ec-9113-b45a20579bdf">


Deployment is done using razee flags and the status can be check in Razeedash: check the link for the process: https://ibm.ent.box.com/notes/777833592630

Deployment Steps:
1) Travis: This is used to create the build images to be deployed.
   - Build with errors
     <img width="979" alt="Screen Shot 2022-06-21 at 4 12 03 PM" src="https://media.github.ibm.com/user/348396/files/e4e38f00-f17c-11ec-8b86-605f0913ad40">

   - Successful Build
     <img width="993" alt="Screen Shot 2022-06-21 at 4 12 34 PM" src="https://media.github.ibm.com/user/348396/files/f7f65f00-f17c-11ec-8d16-f2bb977f7b70">

2) After the builds is successful, the image is deployed using the razeeflags
   - Example: satellite-link-api: https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/satellite-link-api

3) After the image is deployed using razee flags, check Razeedash [https://razeedash.containers.cloud.ibm.com/v2/alchemy-containers/deployments/satellite-link-api] for the any error messages 

* Check latest deployment in Razeedash , if there is error showed.  
Below deployment encountered some error
<img width="1023" alt="Screen Shot 2022-06-21 at 4 13 01 PM" src="https://media.github.ibm.com/user/348396/files/080e3e80-f17d-11ec-9e6a-092e9ff26587">

and this is an example of good deployment. 
<img width="1063" alt="Screen Shot 2022-06-21 at 4 13 09 PM" src="https://media.github.ibm.com/user/348396/files/0ba1c580-f17d-11ec-9a2f-516edbb0c126">


## Who to contact? 
If need help for 404 error, may ask Pipeline team Sangeetha (Canada) for a check.  
and also can reach to YC (US), Cecilia (Taiwan) and Varun (Canada) for a check, too.

### Additional Information

More information on the satellite-link-tunnel can be found [here](https://github.ibm.com/IBM-Cloud-Platform-Networking/satellite-link-tasks)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.satellite-link.escalate.name }}]({{ site.data.teams.satellite-link.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.satellite-link.comm.name }}]({{ site.data.teams.satellite-link.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.satellite-link.name }}]({{ site.data.teams.satellite-link.issue }}) Github repository with all the debugging steps and information done to get to this point.
