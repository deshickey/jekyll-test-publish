---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Carrier's cluster updater pod is down"
type: Troubleshooting
runbook-name: "Carrier's cluster updater pod is down"
description: "The  cluster-updater for a kube-system is down."
service: Razee
tags: razee, armada
link: /armada/armada-carrier-cluster-updater-down.html
failure: ""
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
There is one cluster-updater deployment pod that runs in the kube-system namespace of every carrier. If the
cluster updater pod is down or not responding, the carrier can't get updates.
## Example Alerts
~~~~
Labels:
 - alertname = carrier_cluster_updater_down
 - alert_situation = "carrier_cluster_updater_down"
 - service = cluster-updater
 - severity = critical
 - clusterID = <clusterID>
Annotations:
 - summary = "Carrier cluster updater pod is down."
 - description = "Carrier cluster updater pod is down for cluster <clusterID>"
~~~~
## Investigation and Action
1. Find and login into the carrier having issues.
    * More info on how to do this step is available [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
1. Identify if pod is stuck in state 'ContainerCreating' > 3m
    1. Note: if running on a tugboat (carrier100+), cluster-updater will be running in namespace `armada` instead of `kube-system`
    1. Export variables.
    ~~~~
    kubectl get pod -n kube-system -l app=cluster-updater
    export POD_NAME=<pod name from previous command>
    ~~~~
    1. Verify the pod has everything needed to fully start up. See [README.md](https://github.ibm.com/alchemy-containers/cluster-updater/blob/master/README.md#requirements-to-run).  
    _`kubectl describe pod -n kube-system $POD_NAME`
    can also help point to a missing resource when starting up._
    1. If everything is in place, deleting the pod to force a restart may solve the issue. If restarting doesn't work, follow [razee escalation policy](#escalation-policy).
    1. If everything is not in place, follow [razee escalation policy](#escalation-policy).
1. Pod is stuck in state 'Unknown' (usually charactarized in inability to run any action against the pod)
    1. The Kubernetes Worker Node is in a bad state. Follow the [runbook to debug a troubled node](./armada-carrier-node-troubled.html#debugging-the-troubled-node)
1. Else follow [razee escalation policy](#escalation-policy).
## Escalation Policy
Contact the @razee-pipeline team in the [#razee](https://ibm-argonauts.slack.com/messages/C5X987RU0/) channel for help.
Reassigned the PD incident to `Alchemy - Containers Tribe - Pipeline`
