---
layout: default
description: Handling cloud functions cruiser alerts
title: Handling cloud functions cruiser alerts
service: armada
runbook-name: Handling cloud functions cruiser alerts
tags: alchemy, armada, cloud-functions, cruiser
link: /armada/sre-handling-cloud-functions-alerts.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook details how to discover more info about the Cloud Functions environment we are monitoring.

We are responsible for reacting to cloud functions cruiser alerts, assisting the cloud functions squad via posts in #conductors and handling and tickets they raise in GHE against our squad.

## Detailed Information

The following sections contain detailed information on how to support cloud functions Clusters

## What clusters are we responsible for?

The Cloud Functions Clusters are in the following IBM Cloud accounts.

- `Functions - Development (2b8994befbc8c242c4dfff276a2d0da2) <-> 1590019`
- `Functions Production (2c11ddee64d5e388d669af31be9b5949) <-> 1616923`


Inside the accounts, there are clusters in various regions.

For example:

~~~shell
$ ibmcloud ks cluster ls
OK
Name                         ID                                 State    Created      Workers   Location   Version   
functions-prod-us-south-01   31330786032045789210c81e62baef04   normal   1 week ago   101       dal10      1.10.1_1508   
functions-prod-us-south-02   490a9876244f43899590474bf0937960   normal   1 week ago   101       dal12      1.10.1_1508 
~~~


## IBM Infrastructure accounts (Softlayer) 

The Cloud Functions clusters kube worker nodes reside in the follow accounts.

- Prod / Stage -> Acct1616923
- Dev / Prestage -> Acct1590019


## Slack channels

Slack channels to be aware of:

- [#whisk-sre](https://ibm-argonauts.slack.com/messages/C535QV11P) -  internal channel where the Cloud Functions SRE work is discussed.
- [#whisk-cie](https://ibm-argonauts.slack.com/messages/C8W073D3K) -  public channel where the Cloud Functions CIEs are managed and discussed.

## Handling alerts

Use the runbook link in the alert you have received to work on the issue.

Each runbook has a link on what SRE should do to investigate and resolve the problem.

If any issues are hit, escalate the page to the cloud functions Squad as detailed in the escalation details in this runbook.


## Accessing the clusters

The cloud functions environments are built on top of armada, therefore, the machines by default, are not accessible via SSH, infact, recent armada-bootstrap changes have resulted in ssh lock down so our previous onboarding automation which would have given SRE ssh access, no longer works.

The clusters should be access via the following methods

1. Log into the associated IBM Cloud account  
`ibmcloud login --sso`  
_see above section to obtain account information_  

2. Target the correct region.  
`ibmcloud target -r <region>`  

3. List all clusters and find the correct one  
`ibmcloud ks cluster ls`  
 ___tip__ The cluster name is part of the alert title._
  
~~~shell
$ ibmcloud ks cluster ls
OK
Name                         ID                                 State    Created      Workers   Location   Version   
functions-prod-us-south-01   31330786032045789210c81e62baef04   normal   1 week ago   101       dal10      1.10.1_1508   
functions-prod-us-south-02   490a9876244f43899590474bf0937960   normal   1 week ago   101       dal12      1.10.1_1508 
~~~

or 

- [IBM Cloud UI](https://console.bluemix.net)

- Interact with the cluster using regular `ibmcloud ks` commands.  

- Use `ibmcloud ks cluster config` to obtain the kubeconfig so kubectl commands can be executed.

Commands such as `worker reboot` can be tried to resolve issues.

## How to check if kafka service is running on a worker

1. Log into the associated IBM Cloud account  
`ibmcloud login --sso`  
_see above section to obtain account information_  

2. Target the correct region.  
`ibmcloud target -r <region>`  

3. Export the cluster config for kubectl.  
`ibmcloud ks cluster config --cluster <cluster-name>`  
___Tip:__ The clustername is part of the alert title._

4. Search for kafka service  
`kubectl -n openwhisk get pods -o wide | grep <ip-address> | grep kafka`  
    - If nothing is returned, the worker node does not run kafka and you can reboot/reload as described in the runbook. Also, please post a message in slack channel [#whisk-sre](https://ibm-argonauts.slack.com/messages/C535QV11P)

    - If an entry is returned, the worker node runs a kafka service and you **CANNOT** proceed on your own. See Please check also in slack channel [#whisk-cie](https://ibm-argonauts.slack.com/messages/C8W073D3K) if there is an ongoing CIE and if yes engage the colleagues about how to proceed with this node.


## IBM Cloud Account access

To be determined - raise an issue with [Conductors](https://github.ibm.com/alchemy-conductors/team/issues/new) requesting access - this is likely to change when automation is created for this.

## Escaation policy

To engage the Cloud Functions squad use this escalation policy `Whisk - DevOps - Policy`

