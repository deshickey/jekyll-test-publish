---
layout: default
title: One or more Hypershift operator instances are down. How to resolve the alerts
type: Alert
runbook-name: "hypershift-operator-alerts"
description: How to resolve HypershiftOperatorInstanceDown, SingleHypershiftOperatorInstanceAvailable and HypershiftOperatorUnavailable alerts
service: armada-deploy
link: /hypershift/hypershift-operator-alerts.html
tags:  hypershift, HypershiftOperatorInstanceDown, SingleHypershiftOperatorInstanceAvailable, HypershiftOperatorUnavailable
grand_parent: Armada Runbooks
parent: Hypershift
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `HypershiftOperatorInstanceDown` `SingleHypershiftOperatorInstanceAvailable` `HypershiftOperatorUnavailable` | one or more Hypershift operator instance pods are down | [Actions to take](#actions-to-take) |
{:.table .table-bordered .table-striped}

These alerts fire when one or more Hypershift operator pod instances are down. The hypershift operator handles core lifecycle events around HostedClusters and NodePools and is responsible for managing all other components of Hypershift and normally should have three pod replicas running in different availability zones. 

### Customer impact

Users may not be able to create new locations, create new clusters in a satellite location, attach new worker nodes to an existing location cluster, or create new hypershift ROKS clusters.

## Example Alert(s)

~~~~
Labels:
 - alertname = HypershiftOperatorUnavailable
 - alert_situation = hypershift_operator_unavailable
 - service = armada-deploy
 - severity = critical
 - cluster_id = <CLUSTER-ID>
 - namespace = hypershift
Annotations:
 - summary = "Hypershift operator is unavailable."
 - description = "Hypershift operator is unavailable."
~~~~

## Automation

None

## Actions to take

1. Find and login into the tugboat of the satellite location having issues
   More info on how to do this step can be found [here](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)  
2. Find the failing hypershift operator pods: `kubectl -n hypershift get pods`
```
NAME                        READY   STATUS    RESTARTS   AGE
operator-86f849cdff-brktx   1/1     Running   1          29h
operator-86f849cdff-d9k47   0/1     Pending   0          29h
operator-86f849cdff-lkjl7   1/1     Running   2          29h
```
3. Describe failed pod found from above. `kubectl -n hypershift describe pod <FAILED-POD-NAME>`
```
Name:           operator-86f849cdff-d9k47
Namespace:      hypershift
Priority:       0
Node:           <none>
Labels:         app=operator
                hypershift.openshift.io/operator-component=operator
                name=operator
                pod-template-hash=86f849cdff
Annotations:    openshift.io/scc: anyuid
Status:         Pending
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
4. Look at the `Events` section. If a pod is down due to affinity/anti-affinity rules, then one of the cluster nodes is likely down. Replace the failing node with a healthy one and then force-delete the failed pod `kubectl delete po -n hypershift <FAILED-POD-NAME> --force --grace-period 0` and the alert will be cleared. The process of replacing worker node can be found [here](../ibmcloud_replace_worker.html)
5. View the logs of the failing pod. `kubectl logs -n master <FAILED-POD-NAME>`. If the cause of the failure is not clear, then please [escalate](#escalation-policy) 

### Additional Information

More information about the implementation of the hypershift operator can be found [here](https://github.com/openshift/hypershift)

## Escalation Policy

If you need assistance, please reach out to the developers using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository with all the debugging steps and information done to get to this point.
