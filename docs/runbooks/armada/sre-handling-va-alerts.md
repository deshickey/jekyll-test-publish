---
layout: default
description: Handling VA cruiser alerts
title: Handling VA cruiser alerts
service: armada
runbook-name: Handling VA cruiser alerts
tags: alchemy, armada, VA, cruiser
link: /armada/sre-handling-va-alerts.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook details how to discover more info about the Vulnerability Advisor (VA) environment we are monitoring.

We are responsible for reacting to VA cruiser alerts, assisting the VA squad via posts in #conductors and handling and tickets they raise in GHE against our squad.

## Detailed Information

The following sections contain detailed information on how to support VA Clusters

## What clusters are we responsible for?

The VA Clusters are in the following IBM Cloud accounts.

- `00f409e2cf3b4aaae8d8ec764d8bb627   IBM - Vulnerability Advisor Dev (IBM Container Service)   PAYG           ACTIVE   Alchemy.VA-Dev@uk.ibm.com`     
- `ccf26ae29132f5a08ce4e012dbf34849   IBM - VA Prod                                             PAYG           ACTIVE   alchemy.vulnerability-advisor@uk.ibm.com`

Inside the accounts, there are clusters in various regions.

For example, for `US South` in `IBM - VA Prod` there are these clusters:

~~~shell
Name                ID                                 State    Created        Workers   Location   Version   
va-stage-zone1      e8cdcee2a7f84a8e8c3972e353b89c5f   normal   9 months ago   7         dal10      1.8.11_1509*   
va-stage-zone2      773988613fbe4fa7bb75ee537d9ba5a7   normal   9 months ago   7         dal12      1.8.11_1509*   
va-us-south-zone1   d5dc142d62ef4d23b44c10b9976c790d   normal   8 months ago   9         dal10      1.8.11_1509*   
va-us-south-zone2   4e13b43147c043e5ab00632b676f95d1   normal   8 months ago   9         dal12      1.8.11_1509* 
~~~

## Softlayer 

The VA clusters kube worker nodes reside in the follow accounts.

- Prod / Stage -> Acct531277
- Dev / Prestage -> Acct659397


## Slack channels

Slack channels to be aware of:

- [#va](https://ibm-argonauts.slack.com/messages/C535QV11P) -  internal channel where the VA Squad hang out.
- [#registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE) - linked/shared channel where users will be asking VA and Registry squad questions.


## Handling alerts

Use the runbook link in the alert you have received to work on the issue.

Each runbook has a link on what SRE should do to investigate and resolve the problem.

If any issues are hit, escalate the page to the VA Squad as detailed in the escalation details in this runbook.


## Accessing the clusters

The VA environments are built on top of armada, therefore, the machines by default, are not accessible via SSH, infact, recent armada-bootstrap changes have resulted in ssh lock down so our previous onboarding automation which would have given SRE ssh access, no longer works.

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
   pcullen@pcullen-VirtualBox:~$ ibmcloud ks cluster ls
   OK
   Name                ID                                 State    Created        Workers   Location   Version   
   va-us-south-zone1   d5dc142d62ef4d23b44c10b9976c790d   normal   8 months ago   9         dal10      1.8.11_1509*   
   va-us-south-zone2   4e13b43147c043e5ab00632b676f95d1   normal   8 months ago   9         dal12      1.8.11_1509* 
   ~~~

or 

- [IBM Cloud UI](https://console.bluemix.net)

- Interact with the cluster using regular `ibmcloud ks` commands.  

- Use `ibmcloud ks cluster config` to obtain the kubeconfig so kubectl commands can be executed.

Commands such as `worker reboot` can be tried to resolve issues.


## IBM Cloud Account access

Raise an issue with [VA team](https://github.ibm.com/alchemy-va/team/issues) stating you require access to the two accounts 
State whether you are an EU conductor as this will be needed as only EU conductors get access to `eu-central` clusters.

## Escaation policy

To engage the VA squad use these escalation policy

- [Alchemy - Vulnerability Advisor](https://ibm.pagerduty.com/escalation_policies#PR7NPYD) escalation policy.