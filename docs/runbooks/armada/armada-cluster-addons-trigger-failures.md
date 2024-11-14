---
layout: default
description: Tips for investigating addon enable or disable trigger failures from the armada-cluster-addons microservice.
title: Armada-Cluster-Addons Trigger Failures
service: armada-deploy
runbook-name: "Armada-Cluster-Addons Trigger Failures"
tags: armada-cluster-addons, addons
link: /armada/armada-cluster-addons-trigger-failures.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describe the process for debugging cluster-addon enable or disable failures from the *armada-cluster-addons* microservice.

The armada-cluster-addons microservice runs in the armada namespace on hub carrier masters. It creates or updates a ConfigMap for clusters that choose to enable addons called master-<CLUSTER_ID>-custom-info. If anything fails during the updating of the ConfigMap, a PagerDuty alert is raised.

## Example Alert

[Trigger Failure](https://ibm.pagerduty.com/alerts/PQNVGV3)

## Automation

None

## Actions to take

Follow these steps to investigate the failure.

### 1) Locate the FAILED - ConfigMap operation slack message 

1. Make note of the Request ID in the PD alert details. It will look similar to this example:

   ~~~
   - reqID = ffa52190-a17d-461c-a218-1ea1fa0f048f
   ~~~

1. Navigate to the [#cluster-addon-alerts](https://ibm-argonauts.slack.com/messages/CFLG05ZBP) slack channel.

1. Locate the slack message with the same request ID (ReqID) as found in the first step. The message will look something like this:

~~~
*FAILED* - ConfigMap CREATE for ClusterID: 68bb81cda2e34aa69883197f35c03159 on prestage-mon01.carrier1, ReqID: 055dd287-30df-4bef-92f0-69ca1b3a84ef
Addon: addon-istio, Data: {"version":"1.0.5"}
~~~

### 2) Retrieve and post error messages

1. SSH to the carrier noted in the slack message.

1. Investigate the logs for the armada-cluster-addons microservice and look for the reqID:

~~~
kubectl -n armada logs -l app=armada-cluster-addons | grep <reqID>
~~~

1. Find and note any error messages in the logs

1. Check to see if there is a custom-info ConfigMap for that cluster. Using the ClusterID from the slack message:

~~~
CLUSTER_ID=<cluster>
kubectl -n kubx-masters get cm master-$CLUSTER_ID-custom-info -o yaml
~~~

1. Use the `Start a thread` option on the slack message found earlier to post any error message(s) and the contents of the ConfigMap, if it exists.

### 3) Attempt to retrigger the operation

You can attempt to retrigger the addon operation it the error found above was determined to be temporary.

1. Use the armada-data CLI, along with the ClusterID from the slack message, to attempt to retrigger the addon request:

~~~
CLUSTERID=<CLUSTER_ID>

armada-data delete addons.AddonUpdateOperation -field InProgress -pathvar Service=armada-cluster-addons -pathvar ClusterID=$CLUSTERID
armada-data set Cluster -field UpdateAddons -value update -pathvar ClusterID=$CLUSTERID
~~~

1. Monitor the [#cluster-addon-alerts](https://ibm-argonauts.slack.com/messages/CFLG05ZBP) slack channel for another message from that cluster.

1. If the operation was successful, you are done, the page may be resolved.

1. Otherwise, proceed to the [Escalation Policy](#escalation-policy) section.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
