---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Carrier armada-cluster-store is down."
type: Troubleshooting
runbook-name: "Carrier armada-cluster-store is down"
description: "The carrier armada-cluster-store service is down, preventing the cluster-updater from deploying new, or enforcing existing, cruiser configuration."
service: Razee
tags: razee, armada
link: /armada/armada-cluster-store-down.html
failure: ""
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
Review the armada-cluster-store [overview](./armada-cluster-store.html#overview)

## Example Alerts
~~~~
Labels:
 - alertname = armada_cluster_store_down
 - alert_situation = "armada_cluster_store_down"
 - service = armada-cluster-store
 - severity = critical
 - clusterID = <clusterID>
Annotations:
 - summary = "Carrier armada-cluster-store is down."
 - description = "Carrier armada-cluster-store is down for cluster <clusterID>. This alert is triggered when the service has 0 running pods."
~~~~

## Investigation and Action
Follow these steps when all the armada-cluster-store pods are down.
1. Find and connect to the carrier having issues. [More info](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert).
1. Identify the pods and their state. By default there are two.
  ~~~~
  kubectl -n armada get pod -l app=armada-cluster-store
  export POD_NAME=<the more interesting pod from above>
  ~~~~
1. Verify the pod has everything needed to fully start up. See then env section of the [deployment.yaml](https://github.ibm.com/alchemy-containers/armada-cluster-store/blob/master/services/armada-cluster-store/deployment.yaml#L32).  
  _`kubectl -n armada describe pod $POD_NAME` can also help point to a missing resource when starting up._
  1. If everything is in place but the pod isn't running, deleting the pod to force a restart may solve the issue. If restarting doesn't work, [escalate](#escalation-policy).
  1. If some configuration is missing, determine when armada-secure was last deployed to the cluster. Roll back as appropriate. See the [armada-secure-configuration](./armada-secure-configuration.html) runbook for more information.
1. Pod is stuck in state 'Unknown' (usually charactarized in inability to run any action against the pod)
    1. The Kubernetes Worker Node is in a bad state, see the troubled node [runbook](./armada-carrier-node-troubled.html).
1. Pod is in state 'CrashLoopBackOff'
    1. run `kubectl -n armada describe pod  $POD_NAME`
    2. Ensure the registry is accessible from the carrier, and the image is present there.
1. Review the logs `kubectl -n armada logs $POD_NAME` for clues. Refer to [armada-cluster-store](./armada-cluster-store.html) for additional prerequisite information.
1. Else [escalate](./armada-cluster-store.html#escalation-policy).

## Escalation Policy
[Escalate](./armada-cluster-store.html#escalation-policy).
