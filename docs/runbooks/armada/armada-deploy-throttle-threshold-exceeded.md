---
layout: default
description: How to deal with a high number of master operations throttled
title: How to deal with a high number of master operations throttled
service: armada-deploy
runbook-name: "How to deal with a high number of master operations throttled"
tags: alchemy, armada, kubernetes, armada-deploy, throttle, threshold, cruiser, master
link: /armada/armada-deploy-throttle-threshold-exceeded.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This runbook describes how to deal with a high number of master operations throttled.

## Detailed Information

When more than 25 of any master operation are requested in a short time-period, the master operation hits a throttle threshold.
This causes the operations to be skipped and retried later in order to allow the operations which have already begun to finish.
There is also a cumulative threshold of 100 after which all master operations will be throttled.
Seeing a large number of master operations exceeding the threshold may indicate a problem such as an accidental order of many clusters.
A very high volume of cluster-create operations could lead to the carrier reaching capacity, causing master operations to begin failing.

## Example alert(s)

1.  High number of master operations throttled - when over 50 master operations have been skipped and set to retry the operation within the past 1 hour.

## Actions to take

### Checking details of clusters involved.

1. Focus on determining the cause of the large number of operations if it is the `deploy` operation exceeding the threshold.
    - This is the operation most likely to cause harm due to a high volume of master operations.
    - The throttled operation can be found in the alert details.

1. Go to the [Armada Deploy Master Operations Dashboard](http://169.61.107.27:30100/).
    - Go to the list of Master Operations Messages and query the master operations relevant to the alert (e.g. From: 1 hour ago, Until: Now, Operation: deploy, Region: us-south).
    - Determine if there are still a large number of master operations being triggered and not started due to the threshold.
    - Start by looking at the operation messages with more than one attempt.
    - Try to identify if the operations are being ordered by the same owner.
        1. Look up a few of the clusters using `XO` to determine if the owner is an IBMer.
            - Look at the `IsIBMer` field.
            - `OwnerEmail` will be `null`, but `IsIBMer` will tell you if the owner has an IBM email address.
        1. `IF` the owner is an IBMer, `THEN`
            - Run the [Get Master Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/build?delay=0sec) to determine if it is one IBMer doing the ordering.
            - `IF` a single IBMer is found to be the owner of a large number of clusters, reach out to them through Slack to ask if they are aware of the large number of clusters being ordered.

        1. `IF` the owner is not an IBMer, `THEN`
            - Run the [Get Master Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/build?delay=0sec) to determine if it is one owner doing the ordering.
            - `IF` a single external user is found to be the owner of a large number of clusters, reach out to Chris Rosen (Slack handle: @crosen) to contact the customer.


## Escalation Policy

Assuming none of the troubleshooting tips above worked for you to resolve the alert, you will need to just escalate the alert to the dev squad for them to investigate.

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
