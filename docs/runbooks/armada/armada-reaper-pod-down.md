---
layout: default
title: "Armada Reaper pod is down"
description: "The Armada Reaper pod is down"
type: Alert
runbook-name: "Armada Reaper pod is down"
service: armada-ballast
tags: armada-reaper, armada-ballast
link: /armada/armada-reaper-pod-down.html
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

The Armada Reaper pod is down.
The Armada Reaper pod is responsible for ETCD database field pruning and cloud resource cleanup and syncing.

## Example Alerts

~~~text
Labels:
 - alertname = armada_reaper_restarting
 - alert_situation = "armada_reaper_restarting"
 - service = armada-ballast
 - severity = warning
 - namespace = armada
Annotations:
 - summary = "Armada Reaper pod is restarting."
 - description = "Armada Reaper pod has restarted more than 3 times in the past 15 minutes"
~~~

## Automation

None

## Actions to take

1. Find and login into the carrier master having issues.  Identification differs depending on whether a tugboat is involved. Look at the `carrier_name` field in the alert.
   - If the `...-carrier` number is 100 or great then log onto the hub in the region
_More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_
   - Else, logon to the `...-carrierX-master-xx`
   _e.g. `prod-ams03-carrier1-master-03`_

1. Determine the state of the pod

   ~~~sh
   kubectl get pod -n armada -l app=armada-reaper -o wide
   ~~~

   Should be a single pod running.

1. Can try to delete the pod to see if it comes back up

   ~~~sh
   kubectl delete pod -n armada -l app=armada-reaper
   ~~~

    if stays running for 15 minutes, PD will resolve automatically.

1. If pod is stuck in state `Unknown` the Kubernetes Worker Node may be in a bad state
_usually charactarized by the inability to run any action against the pod_
   - Follow [runbook to debug troubled node](./armada-carrier-node-troubled.html#debugging-the-troubled-node)

1. If none of the above steps resulted in a running cluster-health pod
   - Escalate [escalation policy](#escalation-policy).

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-ballast.comm.name }}]({{ site.data.teams.armada-ballast.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-ballast.name }}]({{ site.data.teams.armada-ballast.issue }}) Github repository for later follow-up.
