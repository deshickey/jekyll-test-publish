---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Satellite Config razeecd pod is down"
type: Troubleshooting
runbook-name: "Satellite Config razeecd pod is down"
description: "The razeecd pod for a satellite config service cluster is down."
service: Razee
tags: razee, armada
link: /satellite/satellite-razeecd-pod-down.html
failure: ""
grand_parent: Armada Runbooks
parent: Satellite
---

Troubleshooting
{: .label .label-red}

## Overview
The razeecd pods run in the `master-<LOCATION_CRUISER_CLUSTER_ID>` namespaces in the satellite location control plane cluster. If a
razeecd pod is down, having errors, or not responding, resources may not be properly deployed on the corresponding location cruiser.

## Example Alerts
~~~~
Labels:
 - alertname = SatelliteRazeecdDown
 - alert_situation = "satellite_razeecd_down"
 - service = satellite
 - severity = critical
 - clusterID = <clusterID>
Annotations:
 - summary = "Razeecd pod is down."
 - description = "Razeecd pod is down for cluster  <clusterID>"
~~~~

## Investigation and Action
1. Find and login into the carrier having issues.
    * More info on how to do this step is available [here](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
1. Identify if pod is stuck in state 'ContainerCreating' > 3m
    1. Export variables.
    ~~~~
    EXPORT CLUSTER_ID="cluster_id"
    kubectl get pod -n "master-$CLUSTER_ID" -l "app=razeecd-$CLUSTER_ID"
    export POD_NAME=<pod name from previous command>
    ~~~~
    1. Verify the pod has everything needed to fully start up. See [README.md](https://github.com/razee-io/razeedeploy-delta/blob/master/README.md#ensure-exist-resources).
    _`kubectl describe pod -n "master-$CLUSTER_ID" $POD_NAME`
    can also help point to a missing resource when starting up._
    1. If everything is in place, deleting the pod to force a restart may solve the issue. If restarting doesn't work, follow [razee escalation policy](#escalation-policy).
    1. If everything is not in place, follow [razee escalation policy](#escalation-policy).
1. Pod is stuck in state 'Unknown' (usually charactarized in inability to run any action against the pod)
    1. The Kubernetes Worker Node is in a bad state. Follow the [runbook to debug a troubled node](../armada/armada-carrier-node-troubled.html#debugging-the-troubled-node)
1. Else follow [razee escalation policy](#escalation-policy).

## Escalation Policy
Contact the @razee-pipeline team in the [#razee](https://ibm-argonauts.slack.com/messages/C5X987RU0/) channel for help.
Reassigned the PD incident to `Alchemy - Containers Tribe - Pipeline`
