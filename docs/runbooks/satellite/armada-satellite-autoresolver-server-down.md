---
layout: default
title: "Customers satellite autoresolver server pod is down"
type: Troubleshooting
runbook-name: "Customers satellite autoresolver server pod is down"
description: "Customers satellite autoresolver server pod is down. The satellite location will not be able to properly manage/monitor the location with the pod down."
service: Armada-bootstrap
tags: satellite, armada, autoresolver, autoresolver-server
link: /satellite/armada-satellite-autoresolver-server-down.html
grand_parent: Armada Runbooks
parent: Satellite
---

Troubleshooting
{: .label .label-red}

## Overview

There is a satellite-autoresolver-server deployment pod that runs in the kubx-master namespace for every satellite location master. If the satellite-autoresolver-server
pod is down or not responding, satellite location will not be able to properly manage/monitor the location. [General Satellite runbook](./armada-satellite.html)

## Example Alerts

~~~~
Labels:
 - alertname = master_satellite_autoresolver_server_down
 - alert_situation = "master_satellite_autoresolver_server_down"
 - service = armada-bootstrap
 - severity = warning
 - clusterID = <clusterID>
Annotations:
 - summary: Customers satellite autoresolver server pod is down for cluster <clusterID>. The satellite location will not be able to properly manage/monitor the location with the pod down.
 - description: Customers satellite autoresolver server pod is down for cluster <clusterID>
~~~~

## Investigation and Action
1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region.
    * More info on how to do this step can be found [here](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
    * Export variables. Replace the `<>` values with what is in the alert
      ```sh
      export CLUSTER_ID=<cluster_id>
      export TROUBLED_POD_ID=$(kubectl get pod -n kubx-masters -l app=satellite-alert-autoresolver-server-$CLUSTER_ID --no-headers|awk '{print $1}')
      ```
1. Ensure satellite-alert-autoresolver-server should be running:
    * if the master does not exist, delete the associated cluster updater deployment and resolve incident.  
    `kubectl delete deployment -n kubx-masters satellite-alert-autoresolver-server-$CLUSTER_ID`
1. Delete the pod to see if it comes up...  
`kubectl delete pod -n kubx-masters $TROUBLED_POD_ID`  
If not, continue diagnosis!
1. Pod is stuck in state 'Unknown' (usually characterized in the inability to run any action against the pod)
    1. The Kubernetes Worker Node is in a bad state. [runbook to debug troubled node](../armada/armada-carrier-node-troubled.html#debugging-the-troubled-node)
1. Else follow [escalation policy](#escalation-policy).

## Escalation Policy

First open an issue against [armada-satellite-alert-autoresolver-server](https://github.ibm.com/alchemy-containers/armada-satellite-alert-autoresolver-server/issues/new) with all the debugging steps and information done to get to this point.

Contact the @bootstrap team in the [#armada-bootstrap](https://ibm-argonauts.slack.com/archives/C531WT4AC) channel for help.
