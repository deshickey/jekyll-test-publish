---
layout: default
description: How to resolve non-running pods in customer namespaces
title: armada-customer-bad-pod - How to resolve non-running pods in customer namespaces
service: armada-customer-non-running-pod
runbook-name: "armada-kubx-non-running-pod - How to resolve non-running pods in customer namespaces"
tags:  armada, unknown, armada-customer-non-running-pod
link: /armada/armada-deploy-customer-pod-in-non-running-state.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

 - alertname = ArmadaDeployMultiplePodInPendingStateOpenshift4
## Overview

| Alert_Situation | Info | Start |
|--
| `ArmadaDeployPodInUnknownState`| One or more customer pods in the customer namespaces are in Unknown state. Need cleaning up | [Recover Non-Running Pods](#recover-non-running-pods) |
| `ArmadaDeployMultiplePodInUnknownState`| Ten or more customer pods in the customer namespaces are in Unknown state. Need cleaning up | [Recover Non-Running Pods](#recover-non-running-pods) |
| `ArmadaDeployMultiplePodInContainerCreatingState`| One or more customer pods in the customer namespaces are in ContainerCreating state. Need cleaning up | [Recover Non-Running Pods in bad state](#recover-non-running-pods) |
| `ArmadaDeployMultiplePodInContainerCreatingState`| Ten or more customer pods in the customer namespaces are in ContainerCreating state. Need cleaning up | [Recover Non-Running Pods](#recover-non-running-pods) |
| `ArmadaDeployMultiplePodInPendingStateOpenshift4`| Ten or more customer pods in the customer namespaces are in Pending state. Need cleaning up | [Diagnosing many pods in pending state](#diagnosing-pending-pods) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = multiple_pod_in_unknown_state
 - alert_situation = "multiple_pod_in_unknown_state"
 - service = armada-deploy
 - severity = critical
Annotations:
 - summary = "Ten or more customer pods in the customer namespaces are in Unknown state. Need cleaning up"
 - description = "Ten or more customer pods in the customer namespaces are in Unknown state. Need cleaning up"
~~~~
~~~~
Labels:
 - alertname = multiple_pod_in_containercreating_state
 - alert_situation = "multiple_pod_in_containercreating_state"
 - service = armada-deploy
 - severity = critical
Annotations:
 - summary = "Fifteen or more customer pods in the customer namespaces are in ContainerCreating state. Need cleaning up"
 - description = "Fifteen or more customer pods in the customer namespaces are in ContainerCreating state. Need cleaning up"
~~~~

## Actions to take

The available actions, detailed immediately below, are:

- [Recover Non-Running Pods](./armada-deploy-kubx-pod-in-non-running-state.html#recover-non-running-pods)
- [Diagnosing Pending Pods](./armada-deploy-kubx-pod-in-non-running-state.html#diagnosing-pending-pods)

[Escalation Policy](./armada-deploy-kubx-pod-in-non-running-state.html#escalation-policy) is detailed at the bottom of the page

### Recover Non-Running Pods

There are `Unknown` or `ContainerCreating` pods in the `kubx-*` or `master-*` (for `Openshift4`) customer namespaces, these need to be cleaned up!

To debug:
1. Find and login into the master of the carrier having issues, or if it is a tugboat (ie. carrier100+) log onto the hub in the region  
_More info on how to do this step can be found [finding the carrier to log into from PD](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_

1. Find all `Unknown` and `ContainerCreating` pods  
`kubectl get po --all-namespaces -o wide | grep -E "^(kubx-|master-).* (Unknown|ContainerCreating)"`
   ~~~~sh
   kubectl get po --all-namespaces -o wide | grep -E "^(kubx-|master-).* (Unknown|ContainerCreating)"
   kubx-etcd-01    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                0/1       Unknown             0          7h        172.16.169.128   10.131.16.5
   kubx-etcd-02    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                0/1       Unknown             0          7h        172.16.133.153   10.131.16.5
   kubx-masters    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                0/1       Unknown             0          7h        172.16.171.4     10.131.16.5
   kubx-etcd-18    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                0/1       Unknown             0          5d        172.16.123.145   10.131.16.5
   ~~~~

1. If all the non-running pods are on the same node, something could be going on with that specific node. Cordon the node  
`armada-cordon-node --reason <reason> <node>`

1. Delete all non-running pods off the node  
**NB. Do not force delete pods!**  
`kubectl get po --all-namespaces -o wide | grep -E "^(kubx-|master-).* (Unknown|ContainerCreating)" | awk '{ printf "kubectl delete po --wait=false -n %s %s\n", $1, $2 }' | bash`

1. To recover failed node, follow the runbook [armada-carrier-node-troubled](./armada-carrier-node-troubled.html)

### Diagnosing Pending Pods

Identify whether there are Pending pods (and, if not Pending, then Terminating pods) on nodes which may be causing problems  
_ie. Look at Pending Pods first, then Terminating pods_

1. Identify whether there is a common node (or nodes) that are hosting the **Pending** pods  
`kubectl get po -A -o wide | grep Pending`

1. If the Pending pods have not been assigned any node (showing `<none>` instead), check for **Terminating** pods   
`kubectl get po -A -o wide | grep Terminating`

1. If there are many pods assigned to a single node (or nodes), consider reloading using the runbook [#reloading-worker-node](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-node-troubled.html#reloading-worker-node).

#### Current ongoing issue with Terminating pods
**_Aug 2022 - hopefully not a permanent fixture_**

We have been seeing issues recently with pods getting stuck in Terminating due to a possible bug in `containerd`.
The recovery is to do a hard reboot of the node, i.e.
```
@Chlorine bot (SRE) reboot 10.123.226.200 softlayer outage:0m
```

A reload typically fails due to drain failures.
A soft reboot also fails; the node goes NotReady and doesn't come back (we suspect the operating system `reboot` command is waiting for system services to stop).

The following prometheus queries can be useful for identifying Terminating pods and the nodes they are on:

Pods terminating longer then 10 minutes:
```
sum ((kube_pod_deletion_timestamp < (time() - 600)) * on(pod) group_left(node) kube_pod_info{pod!="manifests-bootstrapper",namespace=~"(master|kubx)-.*"}) by (node,namespace,pod)
```

Nodes with pods terminating > 10 minutes:
```
count(sum ((kube_pod_deletion_timestamp < (time() - 600)) * on(pod) group_left(node) kube_pod_info{pod!="manifests-bootstrapper",namespace=~"(master|kubx)-.*"}) by (node,namespace,pod)) by (node)
```

Note: You can remove `,namespace=~"(master|kubx)-.*"` filter if you want to see pods in all namespaces.

If you find a related pod stuck in Terminating (or more generally, nodes with cluster related pods stuck in Terminating), a hard reboot should work. For now I ignore csutil-ish pods and look for cluster related pods.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
