---
layout: default
description: How to resolve Satellite Link Tunnel Health (Consumption)
title: Satellite Link Tunnel Health (Consumption) - How to resolve 
service: satellite-link
runbook-name: "Satellite Link Tunnel Health (Consumption)"
tags:  satellite-link, tunnel, health consumption 
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
| `SatelliteLinkTunnelHealthConsumption`| The tunnel health metric ( the ability for the tunnel to be consumed) is below 1, 1 meaning success or -1 for failure. If the metric is below 0.99 for more than 4 minutes then alert will be triggered. This will produce a pod restart
 | [Steps to debug Satellite Link Tunnel Health Consumption](#steps-to-debug-satellite-link-tunnel-health-consumption) |
{:.table .table-bordered .table-striped}


 Based on failure (NLB or ALB) 2 different alerts are produced

## Example Alert(s)

~~~~
Labels:
 - alertname = SatelliteLinkTunnelHealthConsumption
 - alert_situation = satellite_link_tunnel_health_consumption
 - service = satellite-link
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = satellite-link
Annotations:
 - summary = "Consumption check failed for cluster"
 - description = "Consumption check failed for cluster {% raw %}{{ $labels.cluster }}{% endraw %}"
~~~~

## Actions to take

## Steps to debug Satellite Link Tunnel Health Consumption

### Steps to verify tunnel is working

## To verify

#### 1 - Check tunnel status using curl

Then run curl test api to check tunnel status

For PRODUCTION these are tunnel endpoint web socket URL to be tested:

- US-EAST:

```
https://c-xx-ws.us-east.link.satellite.cloud.ibm.com
```

- EU-GB:

```
https://c-xx-ws.eu-gb.link.satellite.cloud.ibm.com
```

For STAGING these are tunnel endpoint web socket URL to be tested:

- US-SOUTH:

```
https://c-xx-ws.us-south.link.satellite.test.cloud.ibm.com
```

- EU-GB:

```
https://c-xx-ws.eu-gb.link.satellite.test.cloud.ibm.com
```

where `xx` is the cluster number that is provided in both message

If returned status is

```
{"status":"UP"}
```

then keep an eye on slack channel to see if the issue will appear again, but basically it was a connectivity spike and you can close the alert.
If status is not up then you need to debug tunnel cluster status. PROBLEM IS CONFIRMED

If you find the following return status:

```
Unable to fetch upstream endpoints from svc!
```

OR

```
<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

It means that tunnel's POD are no longer responding to web socket creation! You need to check tunnel's POD status by following instructions in the following.

1. Check Endpoints 
- run `curl https://c-01-ws.{MZR}.link.satellite.test.cloud.ibm.com`
- example of good output:  ( here needs better response #560 ) 
curl -m 10 https://c-01-ws.eu-gb.link.satellite.test.cloud.ibm.com/
curl: (28) Operation timed out after 10001 milliseconds with 0 bytes received

- example of error output: 
`Unable to fetch upstream endpoints from svc!`

2. Check the pod status by 

- Logging into IBM Cloud CLI 
- run `ibmcloud ks cluster ls` , to find the offending tunnel cluster
- run `ibmcloud ks cluster config -c [offending tunnel cluster]` 
- run `kubectl get pods`, anything other then Running, is a cause for concern. 

 Example of an error with the tunnels. 
<img width="1167" alt="Screen Shot 2020-07-27 at 9 50 05 AM" src="https://media.github.ibm.com/user/85899/files/64e53680-cff2-11ea-85c3-ef0fb571c88f">

3. Check the logs of the offending component 
- run `kubectl logs [pod name] -n satellite-link`
- Example output: 
`{"level":30,"time":1595855432576,"pid":9,"hostname":"hybrid-link-tunnel-hl-tunnel-5f77476b46-hb9jr","msg":"Created logger for cert_manager_api at level info"}
{"level":60,"time":1595855432707,"pid":9,"hostname":"hybrid-link-tunnel-hl-tunnel-5f77476b46-hb9jr","module":"cert_manager_api","msg":"getCertMgrIAMToken status code: 400"}
{"level":30,"time":1595855432774,"pid":9,"hostname":"hybrid-link-tunnel-hl-tunnel-5f77476b46-hb9jr","module":"satellitelink_tunnel_main","msg":"Host document exists for c-01.us-south.link.satellite.test.cloud.ibm.com"}
{"level":30,"time":1595855432775,"pid":9,"hostname":"…`
- Offending logs will likely have a "level" value higher then 30, check these logs for a better understanding on what the issue entails. 

## How to Fix/Debug? 

1. Most of the times, restarting the tunnel server may fix the issue. Follow the steps below
   ```
   1) Login in with appropriate credentials
         `ibmcloud login -sso`
   2) Select the region  
       `3. Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928`
       `4. Satellite Stage (a8fd5d2f57b240f9b276a254c0fcb8a1) <-> 2146126`
   3) First list clusters in the appropriate account:
        `ibmcloud ks cluster ls`
   4) Find the appropriate cluster for tunnel server and use:
        `ibmcloud ks cluster config -c $CLUSTER_NAME`
   5) Restart the Tunnel Server
        `kubectl rollout restart deployment satellite-link-tunnel -n satellite-link`
   6) Check the logs of each pod.
        `kubectl logs [pod name] -n satellite-link`
   ``` 

2. If the logs are not actionable on your part or if the tunnel cluster still has issues, use your best judgement to determine whether to contact the pipeline team: @Sangeetha or the core team: @Yongchang-Cui  @cchoi. Checking commit/deployment times usually helps. 


#### 2 -  Check the pod from the IBM Cloud Portal

1. Acknowledge the alert by clicking in bot message. Verify the alert on the Alert title, you will see the tunnel cluster region and env, for example below alert you see us-south-2 as the region for the tunnel cluster and EZDUS showing it’s the dev environment (2007606 sysdig instance for us-south). If you click on view notification you will be directed to the sysdig instance events section.

<img width="990" alt="Screen Shot 2022-06-21 at 12 02 50 PM" src="https://media.github.ibm.com/user/348396/files/23b41d80-f15a-11ec-98d5-dcd68b59d373">

2. here  you can acknowledge, check the scope and trigger criteria, also to check the graph you can click on “explore” tab.

<img width="1056" alt="Screen Shot 2022-06-21 at 12 03 41 PM" src="https://media.github.ibm.com/user/348396/files/3cbcce80-f15a-11ec-8693-4a847aa12c96">

3. Check the Satellite Link Health and infrastructure status dashboard into Sysdig and check if Tunnel Health (Consumption) is going up & down, or it is completely down.

<img width="1413" alt="Screen Shot 2022-06-21 at 4 54 28 PM" src="https://media.github.ibm.com/user/348396/files/d26c5400-f182-11ec-9370-89563c453538">

4. Click on Explore tab on the bottom right next to Acknowledge . This will bring up the "Hosts & Container" section which will provide evidence of failures in location creation in time. Pick up 6 hours at least and check if the issue is persistent or if it is a single spike.

To be uploaded !!

5. There is also satellite link health and infrastructure sysdig dashboard where you can verify if we have the issue persistent.

To be uploaded !!

6. You can also check the alert definition in the Sysdig alert section for us-south instance in dev SL account 2007606, observability section.
<https://cloud.ibm.com/observe/monitoring>

To be uploaded !!

#### 3 -  Actions

1. If curl testing keeps on returning a bad status and monitor is confirming that tunnel web socket is not consumable you need to login into logDNA and check tunnel cluster logs for any issue. You can refer to the following runbooks to check logs:

<https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/blob/master/HL-Docs/Runbooks/Satellite%20Link%20Logging.md>

2. Check tunnel PODs status

You need to check if not working tunnel cluster's PODs are in good shape. To achieve this please follow this runbook:

# Satellite Link Pod Not Ready 

## What does this PD mean? 
At least one of the pods deployed on our cluster or the dataplane is not functioning as expected. 

## How to Verify? 
### Check the pod from the IBM Cloud Portal : 

1. Sign into https://cloud.ibm.com/kubernetes/clusters 
Check if you are in the correct account for the cluster: "Hybrid Link Dev" or "Hybrid Link Prod" 

<img width="1059" alt="Screen Shot 2022-07-20 at 1 37 18 AM" src="https://media.github.ibm.com/user/348396/files/80900b80-07cc-11ed-853e-7e18d07bf459">

2. Select The Cluster denoted in the PD Alert.

3. In the top right corner of the dashboard, click on Kubernetes Dashboard. 

<img width="1060" alt="Screen Shot 2022-07-20 at 1 37 51 AM" src="https://media.github.ibm.com/user/348396/files/930a4500-07cc-11ed-8342-929c6c8176bd">

4. Ensure that in the left panel you are in the correct namespace specified in the PD. We can verify which pods are running from this screen. 

<img width="247" alt="Screen Shot 2022-07-20 at 1 38 18 AM" src="https://media.github.ibm.com/user/348396/files/a4535180-07cc-11ed-9870-0c717b5b18cc">

5. Check the pods in the overview section and see if they have a green checkmark or not. 

## How to Fix/Debug? 

### Items In the namespace "satellite-link": 

1. Get Logs for the pod: Click on the pod of interest and select LOGS in the top right menu bar. Check the logs to see if there are any obvious issues that can be addressed by restarting a particular component or simply waiting. 

<img width="1032" alt="Screen Shot 2022-07-20 at 1 38 51 AM" src="https://media.github.ibm.com/user/348396/files/b7662180-07cc-11ed-8214-5c9e818016a2">


2. Check Razeedash Updater Messages for any deployment errors. To check the messages, follow the steps below:
   1) Get the cluster ID of the problem POD either by logging in IBMCLoud through command line or UI with appropriate credentials.
   
     <img width="1010" alt="Screen Shot 2022-07-20 at 1 39 19 AM" src="https://media.github.ibm.com/user/348396/files/c8169780-07cc-11ed-8d2a-279851809a18">
   
   2) Go to RazeeDash: https://razeedash.containers.cloud.ibm.com/v2/alchemy-containers/clusters.
   
     <img width="1023" alt="Screen Shot 2022-07-20 at 1 39 54 AM" src="https://media.github.ibm.com/user/348396/files/dd8bc180-07cc-11ed-8e22-c8ebc477c039">
   
   3) Enter the cluster ID of the problem POD in the search box, the link to the cluster will be displayed below.
     <img width="968" alt="Screen Shot 2022-07-20 at 1 40 34 AM" src="https://media.github.ibm.com/user/348396/files/f4321880-07cc-11ed-88d1-276429b6e1df">
   
   4) Once you click on Cluster Name, a new Window opens. From here, go to Updater messages tab and check for the messages in the "messages" section below.
      <img width="965" alt="Screen Shot 2022-07-20 at 1 40 45 AM" src="https://media.github.ibm.com/user/348396/files/fac09000-07cc-11ed-81f0-ffd7817bacf5">
   
   5) Check if there are any deployment errors. If errors exist, then contact the pipeline team (Sangeetha Kamatkar) to get these resolved.
   
   6) If there are no errors, then proceed to Step (3) below.

3. If the pod has not updated its age, you may need to manually restart it. Start by deleting one pod with `kubectl delete pod [POD NAME]`. After it comes back ensure it is running correctly.  

4. If the pod is not starting up, restarting the server itself may fix the issue.Follow the steps below [Note: Steps provided below are the tunnel server. Change the deployment to the approriate component name]
API: satellite-link-api
Tunnel: satellite-link-tunnel
LB: satellite-link-lb
Tasks: satellite-link-tasks
Connector: satellite-link-connector

  ```
   1) Login in with appropriate credentials
         `ibmcloud login -sso`
   2) Select the region  
       `3. Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928`
       `4. Satellite Stage (a8fd5d2f57b240f9b276a254c0fcb8a1) <-> 2146126`
   3) First list clusters in the appropriate account:
        `ibmcloud ks cluster ls`
   4) Find the appropriate cluster for tunnel server and use:
        `ibmcloud ks cluster config -c $CLUSTER_NAME`
   5) Restart the Tunnel Server
        `kubectl rollout restart deployment satellite-link-tunnel -n satellite-link`
   6) Check the logs of each pod.
        `kubectl logs [pod name] -n satellite-link`
   ``` 

5. If the logs are not actionable on your part, forward the issue to a team member responsible for that component. Check the owner of the component causing the issue via the readme.md of this repo and contact them on Slack. 

Note: Posting in the Hybrid-Link-Dev Slack channel and tagging the correct people is the best way to keep the entire team in the loop. 

### Items in other namespaces: 

Other namespaces are used for other tools and services we need but don't work on ourselves. If you know something is wrong with the service then there is likely nothing wrong on our end. If however this is not the case contact the pipeline team (Clayton Leach and Sangeetha Kamatkar), to get this resolved. 

3. Check if there is a certificate issue on tunnel:

You can check if there is a certificate issue preventing web socket to be consumed. In order to test this, rerun the curl testing with a `-v` option like the following:

```
curl -v https://c-02-ws.eu-gb.link.satellite.cloud.ibm.com
```

and check tunnel's certificate status in the provided command output. A valid certificate will be reported like the following output:

```
* Server certificate:
*  subject: C=US; ST=New York; L=Armonk; O=International Business Machines Corporation; CN=*.eu-gb.link.satellite.cloud.ibm.com
*  start date: Jun 23 00:00:00 2020 GMT
*  expire date: Jun 28 12:00:00 2022 GMT
*  subjectAltName: host "c-02-ws.eu-gb.link.satellite.cloud.ibm.com" matched cert's "*.eu-gb.link.satellite.cloud.ibm.com"
*  issuer: C=US; O=DigiCert Inc; CN=DigiCert SHA2 Secure Server CA
*  SSL certificate verify ok.
```

If certificate has issues please send a message in #hybrid-link-dev slack channel asking to check certificate on not working cluster

If no one of above actions is addressing the issue, contact Sat Link dev team into #hybrid-link-dev channel

4. Check if there is a mongoDb Outage

First of all login into HL PROD or DEV account depending on where outage is reported.

In both accounts, open Sysdig US-SOUTH monitoring instance, because mongoDB is monitored always in US-SOUTH. Picture below is an example for PROD of where you need to go to open US-SOUTH sysdig instance:

![Sysdig USSouth Instance](https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/blob/master/diagrams/SysdigUsSouth.png)

Then you need to reach out `Databases for MongoDB - Overview` dashboard. In order to find it you can type `mongodb` into dashboard search option like in the picture below:

![Sysdig USSouth Instance search ](https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/blob/master/diagrams/MongoDbDashFinder.png)

In the dashboard check if Memory Utilization is above 90% like in the picture below:

![Sysdig memory leak](https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/blob/master/diagrams/MongoDbMemoryUtilizationIssue.png)

If this is the case you need to increase memory available to mongoDb instance

5. If you are not able to bring back tunnel yet, please reach out developers into #hybrid-link-dev channel

### Steps to verify Load Balancer is working (ingress)

Run the test to see if load balancer is working or not , if it does not returnint UP then monotoring trigeers an alert

```
kubectl exec $TASKPOD -- curl -s https://c-04.eu-gb.link.satellite.cloud.ibm.com:52768/

```

#### 1 - Check Load Balancer status using curl

1 - Login into tugboat where failure is reported

2 - On tugboat you need to enter a query command to CSE url exeuting it directly from the api pod. In order to do this you have to:

```
export TASKPOD=`kubectl get pods -n satellite-link | grep api | tail -n 1 | awk '{print $1}'`
```

Then run the following command (example below is for us-east c01 cluster:

```
anaglier:Staging$ kubectl exec $TASKPOD -n satellite-link -- curl -s https://c-01.us-east.link.satellite.cloud.ibm.com:52768/
UP

```

If result is `UP` then it has been a spike connectivity issue that has automatically resolved. If result is a curl error you need to check [error code from internet](https://timi.eu/docs/anatella/5_1_8_1_list-of-curl-error-co.html) . Error codes 35, 51, 58 and 60 are related to certificate issues. In order to double check this, run again same curl command with a `-v` option and see if certificate has expired or is not valid. If this is the case report back certificate issue to slack channel #hybrid-link-dev.

Other curl errors need to be debugged by [checking API logs](https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/blob/master/HL-Docs/Runbooks/Satellite%20Link%20Logging.md)

If curl return code is 28 (OPERATION_TIMEDOUT) then you need to debug CSE status to see if both CSE endpoints and Load Balancer serives are working good

3 - Check CSE status
Using CSE token for PROD or STAGE (you can retreive it from SRE team leader) you can issue CSE API /endpoints to get status of CSE endpoints

3a - nslookup from your workstation CSE endpoint url like in the following example:

```
anaglier:~$ nslookup c-01.us-east.link.satellite.cloud.ibm.com
Server:  9.0.138.50
Address: 9.0.138.50#53

Non-authoritative answer:
c-01.us-east.link.satellite.cloud.ibm.com canonical name = satellite-link.us-east.serviceendpoint.cloud.ibm.com.
Name: satellite-link.us-east.serviceendpoint.cloud.ibm.com
Address: 166.9.22.49
Name: satellite-link.us-east.serviceendpoint.cloud.ibm.com
Address: 166.9.20.115
Name: satellite-link.us-east.serviceendpoint.cloud.ibm.com
Address: 166.9.24.42

```

A correct CSE behaviour will report 3 166.9 IPs. If there are only 2 CSE is still working but report this issue on #hybrid-link-dev slack channel

If there is just one, then CSE could be the cause of the issue. Ask CSE engineers to check endpoint status providing link url into #service-endpoint-sre channel

Try to ping endpoints from any vm on any IBM cloud account which is CSE enabled (Hybrid Link Prod and Hybrid Link Dev are CSE enabled). If endpoints are not reachble, then magic boxe has an issue and you need to ask to CSE engineers to check reporting issue into #service-endpoint-sre

3b - `ibmcloud login -a cloud.ibm.com --apikey XXXXXXXXX` where XXX is the SRE provided API key for CSE

3c - get IAM token and export it into `token` variable. To get token issue `ibmcloud iam oauth-tokens`

3d - run CSE /endpoints API in the following way:

`curl -H "Authorization: Bearer $token"  https://api.serviceendpoint.cloud.ibm.com/v2/serviceendpoints | jq .`
It would be good to redirect output to a txt file

3e - Check load balancer CSE endpoint status searching for tunnel cluster hostname `c-xx.yy-zz.link.satellite.cloud.ibm.com`

This is a typical output of a working CSE endpoint:

```
{
        "seid": "us-east-satellite-link-c-02us-eastlinksatellitetestcloudibmcom-dedi-st-1g-cd312392-wdc06",
        "srvid": "us-east-satellite-link-c-02us-eastlinksatellitetestcloudibmcom-dedi-st-1g-cd312392",
        "mbid": "wdc06-dedi-1g-fc32c30b",
        "crn": "crn:v1:bluemix:public:serviceendpoint:wdc06:a/f76e4b9f3bad41c0b0238b5dd9702765:us-east-satellite-link-c-02us-eastlinksatellitetestcloudibmcom-dedi-st-1g-cd312392-wdc06::",
        "staticAddress": "166.9.22.59",
        "netmask": "23",
        "dnsStatus": "Y",
        "region": "us-east",
        "dataCenter": "wdc06",
        "vlanid": 2466559,
        "status": "Ready",
        "serverGroup": "groupA",
        "serviceStatus": null,
        "statusDetails": [
          {
            "address": "10.148.212.218",
            "ping": 1,
            "estado": 1,
            "ports": [
              "443:0",
              "52768:1"
            ]
          },
          {
            "address": "10.189.3.60",
            "ping": 1,
            "estado": 1,
            "ports": [
              "443:0",
              "52768:1"
            ]
          },
          {
            "address": "10.190.41.42",
            "ping": 1,
            "estado": 1,
            "ports": [
              "443:0",
              "52768:1"
            ]
          }
        ],
        "heartbeatTime": "2020-09-08T13:57:42Z"
      }
    ],
```

You need to check under `StatusDetails` if services have a `1` next to 52768 like in the following case:

```
{
            "address": "10.148.212.218",
            "ping": 1,
            "estado": 1,
            "ports": [
              "443:0",
              "52768:1"
            ]
          
```

If you see a value of `0` this means that Load Balancer port of `0.148.212.218` is not reachble.
In this case you need to login into PODs and [check PODs availability](https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/blob/master/HL-Docs/Runbooks/Satellite%20Link%20Pod%20Not%20Ready.md)

### Additional Information

More information on the satellite-link-tunnel can be found [here](https://github.ibm.com/IBM-Cloud-Platform-Networking/satellite-link-tunnel)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.satellite-link.escalate.name }}]({{ site.data.teams.satellite-link.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.satellite-link.comm.name }}]({{ site.data.teams.satellite-link.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.satellite-link.name }}]({{ site.data.teams.satellite-link.issue }}) Github repository with all the debugging steps and information done to get to this point.
