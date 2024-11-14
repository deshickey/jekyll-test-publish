---
layout: default
title: One or more Hypershift konnectivity agent instances are down. How to resolve the alerts.
type: Alert
runbook-name: "hypershift-konnectivity-agent-alerts"
description: How to resolve KonnectivityAgentInstanceDown, SingleKonnectivityAgentInstanceAvailable and KonnectivityAgentUnavailable alerts
service: armada-network
link: /hypershift/hypershift-konnectivity-agent-alerts.html
tags:  hypershift, KonnectivityAgentInstanceDown, SingleKonnectivityAgentInstanceAvailable, KonnectivityAgentUnavailable
grand_parent: Armada Runbooks
parent: Hypershift
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `KonnectivityAgentInstanceDown` `SingleKonnectivityAgentInstanceAvailable` `KonnectivityAgentUnavailable` `KonnectivityServerUnavailable` | One or more Hypershift konnectivity agent or server instance pods are down | [Actions to take](#actions-to-take) |
{:.table .table-bordered .table-striped}

These alerts fire when one or more Hypershift konnectivity agent pod instances are down. The agent normally should have three pod replicas running in different availability zones.

## Customer impact

- KonnectivityAgentUnavailable and KonnectivityServerUnavailable alerts: users may not be able to create new clusters in this satellite location or attach new worker nodes to the existing clusters in this location. A critical error message is displayed to the users.
- KonnectivityAgentInstanceDown and SingleKonnectivityAgentInstanceAvailable should not have customer impact.

## Example Alert(s)

~~~~
Labels:
 - alertname = KonnectivityAgentUnavailable
 - alert_situation = konnectivity_agent_unavailable
 - service = armada-network
 - severity = critical
 - cluster_id = <CLUSTER-ID>
 - namespace = master-<CLUSTER-ID>
Annotations:
 - summary = "Konnectivity agent is unavailable."
 - description = "Konnectivity agent is unavailable for the cluster."
~~~~

## Automation

None

## Actions to take

1. Find and login into the tugboat of the satellite location having issues
   More info on how to do this step can be found [here](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)  
2. Find the failing konnectivity agent pods: `kubectl get po -n master-<CLUSTER-ID> -l app=konnectivity-agent`
```
NAME                                 READY   STATUS        RESTARTS   AGE
konnectivity-agent-65dff5468-5f87v   0/1     Pending       0          19h
konnectivity-agent-65dff5468-hrn7k   0/1     Pending       0          125m
konnectivity-agent-65dff5468-tjqlx   0/1     Pending       0          19h
```
3. Describe failed pod found from above. `kubectl -n master-<CLUSTER-ID> describe pod <FAILED-POD-NAME>`
```
Name:                      konnectivity-agent-65dff5468-62wzg
Namespace:                 master-topmike-1
Priority:                  100000000
Priority Class Name:       hypershift-control-plane
Node:                      10.177.180.252/10.177.180.252
Start Time:                Wed, 02 Feb 2022 18:09:28 -0500
Labels:                    app=konnectivity-agent
                           hypershift.openshift.io/control-plane-component=konnectivity-agent
...
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     hypershift.openshift.io/cluster=master-topmike-1:NoSchedule
                 hypershift.openshift.io/control-plane=true:NoSchedule
                 node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason        Age   From             Message
  ----     ------        ----  ----             -------
  Warning  NodeNotReady  132m  node-controller  Node is not ready
```
4. Look at the `Events` section. If a pod is down due to affinity/anti-affinity rules, then one of the cluster nodes is likely down. Replace the failing node with a healthy one and then force-delete the failed pod `kubectl delete po -n master-<CLUSTER-ID> <FAILED-POD-NAME> --force --grace-period 0` and the alert will be cleared. The process of replacing worker node can be found [here](../ibmcloud_replace_worker.html)
5. View the logs of the failing pod. `kubectl logs -n master-<CLUSTER-ID> <FAILED-POD-NAME>`. If the cause of the failure is not clear, then please [escalate](#escalation-policy) 

## Escalation Policy

If you need assistance, please reach out to the developers using the [{{ site.data.teams.armada-hypershift.comm.name }}]({{ site.data.teams.armada-hypershift.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-hypershift.name }}]({{ site.data.teams.armada-hypershift.issue }}) Github repository with all the debugging steps and information done to get to this point.
