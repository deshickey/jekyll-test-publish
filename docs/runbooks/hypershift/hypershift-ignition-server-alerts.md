---
layout: default
title: One or more Hypershift ignition server instances are down. How to resolve the alerts.
type: Alert
runbook-name: "hypershift-ignition-server-alerts"
description: How to resolve IgnitionServerUnhealthy and IgnitionServerCritical alerts
service: armada-hypershift
link: /hypershift/hypershift-ignition-server-alerts.html
tags:  hypershift, IgnitionServerUnhealthy, IgnitionServerCritical
grand_parent: Armada Runbooks
parent: Hypershift
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `IgnitionServerUnhealthy` `IgnitionServerCritical` | one or more Hypershift ignition server instance pods are down | [Actions to take](#actions-to-take) |
{:.table .table-bordered .table-striped}

These alerts fire when one or more Hypershift ignition server pod instances are down. The hypershift ignition server normally should have three pod replicas running in different availability zones.

## Customer impact

Users may not be able to attach worker nodes to this satellite location clusters. A critical error message is displayed to the users. The ignition server provides the ignition payload to workers looking to bootstrap  the worker node.

## Example Alert(s)

~~~~
Labels:
 - alertname = IgnitionServerCritical
 - alert_situation = ignition_server_critical
 - service = armada-hypershift
 - severity = critical
 - cluster_id = <CLUSTER-ID>
 - namespace = master-<CLUSTER-ID>
Annotations:
 - summary = "Ignition server is unavailable."
 - description = "Ignition server is unavailable for the cluster."
~~~~

## Automation

None

## Actions to take

1. Find and login into the tugboat of the satellite location having issues
   More info on how to do this step can be found [here](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)  
2. Find the failing ignition server pods: `kubectl get po -n master-<CLUSTER-ID> -l app=ignition-server`
```
NAME                               READY   STATUS    RESTARTS   AGE
ignition-server-7b9656cccc-czdqc   1/1     Running   0          35m
ignition-server-7b9656cccc-k255k   0/1     Pending   0          35m
ignition-server-7b9656cccc-qpzb8   0/1     Pending   0          35m
```
3. Describe failed pod found from above. `kubectl -n master-<CLUSTER-ID> describe pod <FAILED-POD-NAME>`
```
Name:                 ignition-server-7b9656cccc-k255k
Namespace:            master-topmike-1
Priority:             100000000
Priority Class Name:  hypershift-control-plane
Node:                 10.208.51.12/10.208.51.12
Start Time:           Wed, 02 Feb 2022 18:08:55 -0500
Labels:               app=ignition-server
                      hypershift.openshift.io/control-plane-component=ignition-server
                      hypershift.openshift.io/hosted-control-plane=master-topmike-1
                      pod-template-hash=7b9656cccc
...
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 hypershift.openshift.io/control-plane op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age                    From               Message
  ----     ------            ----                   ----               -------
  Warning  FailedScheduling  36s (x184 over 3h21m)  default-scheduler  0/2 nodes are available: 2 node(s) didn't match pod affinity/anti-affinity rules, 2 node(s) didn't match pod anti-affinity rules.
```
4. Look at the `Events` section. If a pod is down due to affinity/anti-affinity rules, then one of the cluster nodes is likely down. Replace the failing node with a healthy one and then force-delete the failed pod `kubectl delete po -n master-<CLUSTER-ID> <FAILED-POD-NAME> --force --grace-period 0` and the alert will be cleared. The process of replacing worker node can be found [here](../ibmcloud_replace_worker.html) 
5. View the logs of the failing pod. `kubectl logs -n master-<CLUSTER-ID> <FAILED-POD-NAME>`. If the cause of the failure is not clear, then please [escalate](#escalation-policy) 

## Escalation Policy

If you need assistance, please reach out to the developers using the [{{ site.data.teams.armada-hypershift.comm.name }}]({{ site.data.teams.armada-hypershift.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-hypershift.name }}]({{ site.data.teams.armada-hypershift.issue }}) Github repository with all the debugging steps and information done to get to this point.
