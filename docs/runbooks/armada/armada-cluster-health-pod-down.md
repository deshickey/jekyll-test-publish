---
layout: default
title: "Customers cluster health pod is down"
description: "The sidecar cluster-health for a kubx master is down"
type: Alert
runbook-name: "Customers cluster health pod is down"
service: armada-network
tags: armada-cluster-health, armada-deploy, armada-network
link: /armada/armada-cluster-health-pod-down.html
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

There is a pod that runs in the kubx-master namespace for every master named `cluster-health-<cluster_id>`.
This pod collects health information about the cluster's master and nodes and reports them back to the armada-health microservice.
If this pod goes down, the reported health seen by us and the customer may not be up to date with the actual health of the cluster.

## Example Alerts

~~~
Labels:
 - alertname = master_cluster_health_down
 - alert_situation = "master_cluster_health_down"
 - service = armada-network
 - severity = critical
 - clusterID = <clusterID>
Annotations:
 - summary = "Customers cluster health pod is down."
 - description = "Customers cluster health pod is down for cluster <clusterID>"
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
_Replace the `<cluster_id>` with value from the alert_
   ```sh
   export CLUSTER_ID=<cluster_id>
   kubectl get pod -n kubx-masters -l app=cluster-health-$CLUSTER_ID
   export TROUBLED_POD_ID=<ID of running pod from previous command>
   ```
1. Determine whether a **cluster-health** deployment needs to be running  
_Sometimes a master has been deleted but fails to clean up **cluster-health**_  
   _[Commands use previously exported `CLUSTER_ID`]_

   Get details about the deployment  
   `kubectl get deployment -n kubx-masters master-${CLUSTER_ID}`

   If the master doesn't exist, delete the associated **cluster-health** deployment and resolve incident  
   `kubectl -n kubx-masters delete deploy -l app=cluster-health-$CLUSTER_ID`
    
1. As the deployment should be there, delete the pod to see if it comes (back) up  
`kubectl -n kubx-masters delete pod $TROUBLED_POD_ID`  
if found, **STOP HERE**, otherwise continue

1. If pod is stuck in state `Unknown` the Kubernetes Worker Node may be in a bad state  
_usually charactarized by the inability to run any action against the pod_
   - Follow [runbook to debug troubled node](./armada-carrier-node-troubled.html#debugging-the-troubled-node)
    
1. If none of the above steps resulted in a running cluster-health pod  
   - Escalate [escalation policy](#escalation-policy).

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-network.escalate.name }}]({{ site.data.teams.armada-network.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-network.comm.name }}]({{ site.data.teams.armada-network.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-network.name }}]({{ site.data.teams.armada-network.issue }}) Github repository for later follow-up.

