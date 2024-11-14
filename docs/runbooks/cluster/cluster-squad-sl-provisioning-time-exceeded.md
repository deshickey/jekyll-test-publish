---
layout: default
title: armada-cluster - How to Handle IBM Cloud infrastructure (SoftLayer) Provisioning Time Limit (90 minutes) Exceeded
type: Alert
runbook-name: "armada-cluster - How to Handle IBM Cloud infrastructure (SoftLayer) Provisioning Time Limit (90 minutes) Exceeded"
description: Armada cluster - How to handle worker provisioning in IBM Cloud infrastructure that has exceeded the time limit (90 minutes)
service: armada-cluster
link: /cluster/cluster-squad-sl-provisioning-time-exceeded.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

  This alert will trigger when the 90th percentile provisioning time for the period of one hour has exceeded the imposed time limit of 90 minutes. This can occur if IBM Cloud infrastructure is taking a long time to provision a machine or as a result of increased crawler run times and watcher errors.

  This runbook will take you through the steps required to determine if this alert is due to an armada or IBM Cloud Infrastructure issue and what action to take.

## Example Alert

  Example PD title:

  - `#3533816: bluemix.containers-kubernetes.prod-dal12-carrier2.armada-cluster_patrol_provisioning_time_12000_seconds.us-south`

## Actions to Take
  
  Diagnose the issue by first assessing whether this is an armada issue or an IBM Cloud infrastructure issue. First look to see if this is an armada issue by searching in the logs for:

  ```
  "msg":"Watcher error"
  ```

  Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment.

  Typically, these errors occur infrequently and you should see less than 10 per hour. If the occurence of these watcher errors seems high then also search the logs for:

  ```
  "msg":"Crawler run complete"
  ```

  Typically, there should be on the order of 1000 of these log messages per hour. If the number of these log messages is significantly lower than this coupled with high numbers of watcher errors then it is likely that this is an issue with armada. In this situation the alert should be escalated to the troutbridge squad as detailed in the Escalation section. 
  
  If the watcher errors and crawler runs are as expected then this might be an IBM Cloud infrastructure issue. You can search the logs to find out which workers are exceeding the provisioning time limit using the following query:

  ```
  app:armada-cluster action:pollWorkerProvisioning elapsedSeconds:>=5400
  ```

  This searches armada-cluster logs for a worker that has been provisioning for 90 minutes or more. To search using a different time limit change `5400` to the desired time period. Note that this value is specified in seconds.

  When one or more worker(s) has been found use armada-xo to check the `Status` and `ErrorMessage` of the worker. This can be done in the #armada-xo slack channel with the following request:

  ```
  @xo worker <worker-id>
  ```
  The armada-xo slack channel is private. If you do not have access please request it in the #conductors channel.

  Issues relating to IBM Cloud infrastructure will often have status messages, such as `"Infrastructure operation: Setup provision configuration"`, or more generally related to waiting for transactions or other status. 
  
  If the issue is related to IBM Cloud infrastructure then the Conductors need to raise a ticket - for more information see the [troutbridge squad troubleshooting runbook](cluster-squad-common-troubleshooting-issues.html#infrastructure-operation-xxx).
  
  The alert will continue to fire until the ticket has been resolved by IBM Cloud Infrastructure. At this point the alert should auto resolve once the system recovers.

## Escalation Policy

  If the issue is not a IBM Cloud infrastructure or permissions issue then escalate to the troutbridge squad.

  PagerDuty:
  Escalate the issue via the [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) PD escalation policy

  Slack Channel:
  You can contact the dev squad in the #armada-cluster channel

  GHE Issues Queue:
  You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
