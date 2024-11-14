---
layout: default
title: Unusual Activity Policy
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

# Policy: Unusual Activity

## Purpose

This document defines the policy for actions to be taken in response to detecting unusual activity in IBM Cloud.

## Scope

This policy applies to infrastructure required to support the development and operations of IBM Cloud.

## Definitions

### Unusual activity

Unusual Activity is activity on IBM Cloud infrastructure that might indicate malicious intent either by IBM employees or by external actors.

Specifically, unusual activity covered by this policy is:
* DDoS attacks on any part of the network
* for traffic coming from the internet via Akamai:
  * Malformed requests for common protocols
  * Patterns of behaviour that match known malware signatures
* Suspicious VPN activity events
* Suspicious login events on servers
* SSH root login on any system
* Unauthorized Kube Operator Access attempt
* Privilege escalations on servers, both successful and failed.
* Modifications to server system configuration
* Changes of file permissions, both successful and failed.
* File access operations that result in a permission denied error
* Running suspicious applications:
  * /bin/nc
  * /bin/netcat
  * /usr/bin/base64
  * /usr/bin/curl
  * /usr/bin/ncat
  * /usr/bin/rawshark
  * /usr/bin/rdesktop
  * /usr/bin/socat
  * /usr/bin/ssh
  * /usr/bin/wget
  * /usr/bin/wireshark

## Policy

### Action

When unusual activity is detected, a ServiceNow ticket will be raised for the attention of the machine owner.

That team shall respond within the specified time having either resolved the issue or indicating that the activity can be accounted for.

#### Unauthorized Kube Operator Access attempt

* Get the user's email and what he/she is doing from the PD incident details. The contents of PD incident might look like this:
   ~~~
   "requestURI":"/api/v1/namespaces/iqa/configmaps","verb":"list", user":{"username":"IAM#xxxxx@xx.ibm.com","groups":["xxxxx","system:authenticated"]},"sourceIPs":["xx.xx.xx.xx"],"
   ~~~
* Get the caller's name from the PD incident details, which might look like this:
   ~~~
   - Caller : Saad Faiz
   ~~~
* Notify the user that what he/she did is prohibited. See the contact information in [BluePages](https://w3.ibm.com/bluepages/).
* Ask the user to stop the access, then if the user do have business requirement to access it, let him/her do one of the following:
    - Ask your team leader to assign permission
    - Ask how to get the access permission in SOC channel [#soc-notify](https://ibm-cloudplatform.slack.com/messages/C4BHPCX89/) 
* Get the reason why he or she did the operation, and enter your findings into the ServiceNow ticket
* Confirm with the caller if the user has stopped his/her action, 
* Manually `Resolve` the PD alert, your work is complete.

[useful information](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI/blob/master/troubleshooting.md#receiving-service-nowpager-duty-alerts-for-exec-actions-on-containers)
### Response time

Issues which require immediate attention will be raised as a severity 1 ticket and will be actioned within 24 hours.

Issues which do not require immediate attention will be raised as a severity 2 ticket and will be actioned within 1 week.

## Reviews

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14

