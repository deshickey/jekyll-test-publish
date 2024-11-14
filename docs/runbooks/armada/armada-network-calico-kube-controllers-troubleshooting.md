---
layout: default
title: IKS Network - calico-kube-controllers Troubleshooting
runbook-name: "IKS Network - calico-kube-controllers Troubleshooting"
tags: calico calico-kube-controllers network networking troubleshooting
description: "IKS Network - calico-kube-controllers Troubleshooting"
service: armada-network
link: /armada/armada-network-calico-kube-controllers-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook covers steps to take when calico-kube-controllers is not working correctly in either a customer cluster, tugboat, or carrier.

calico-kube-controllers is a deployment that should be running in every IKS/ROKS cluster, with a single calico-kube-controllers pod running on the cluster.  When an IKS/ROKS cluster is first deployed, and again when its master is updated, calico-node, calico-kube-controllers, and other calico components are deployed and configured specifically to work with IBM Cloud and IKS/ROKS components.  In most cases this configuration should not be changed at all.  There are a few specific settings, such as Calico's MTU, which can be modified if needed to handle specific situations, but only Calico settings that are specifically described in the IKS/ROKS documentation should be changed.  Changing other Calico settings is not supported.  Also Calico is updated to new versions as part of IKS/ROKS master updates.  Do NOT attempt to update Calico yourself.

The calico-kube-controllers pod has several components, that are described here: https://docs.projectcalico.org/reference/kube-controllers/configuration.  Once IKS 1.18 is unsupported at the end of October, 2021, all our supported clusters will be using Calico KDD (Kubernetes Datastore Driver), and so the calico-kube-controllers pod will only be running the node controller, which just cleans up Calico resources when a node is deleted.  All the other controllers are not used for Calico KDD

Note that calico-kube-controllers only adds/removes data from the Calico datastore.  And with Calico KDD it just handles node deletes and leaked pod IP cleanup.  It is calico-node that does all the programming of pod routes via BGP as well as the policy and profile implementation via iptables rules.  This means that calico-kube-controllers pod is not essential to be running constantly, and it being down for short periods of time should have little to no affect on the cluster.  The worst that would happen is that any nodes that were deleted/replaced during that time the pod was down wouldn't have its Calico data cleaned up.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

### If the calico-kube-controllers Pod is Not Running At All

If calico-kube-controllers is not running, not even in CrashLoopBackOff or Pending state, then most likely the deployment was deleted or scaled down, or a custom webhook is preventing the pods from starting.  To recover, run: `ibmcloud ks cluster-refresh --cluster <CLUSTER_NAME>`  It will take up to 45 minutes for the master to completely refresh and for the calico-kube-controllers daemonset to be recreated.  If this still doesn't fix the problem, search for "webhook" in the [Armada-Deploy Operations Failure](armada-deploy-operation-failures.html) runbook for more options.

### Check If Worker Is Ready and Healthy

Sometimes the calico-kube-controllers pod having problems is simply caused by the worker node it is running on not being healthy.  So first check that the worker node the pod is on is in Ready state.  If it is not, cordon, drain, and reload that node, which should move the calico-kube-controllers pod to a different node and most likely solve the problem.

Even if the node appears healthy, cordon the node the calico-kube-controllers pod is on and then use `kubectl delete pod -n <kube-system/calico-system> calico-kube-controllers-YYYYYYYYYY-XXXXX` to delete the pod which will reschedule it to a different node.

### calico-kube-controllers in CrashLoopBackOff or Restarting Often

Assuming you have already tried to move the calico-kube-controllers pod to several different nodes in different zones (if this is a multizone cluster) and that has not helped, the problem is most likely something in the Calico configuration, or possibly in the Calico/Kubernetes Datastore.

Gather the output and logs listed in the "Logs and Data to Gather For Calico Issues" section below, and examine that output for an indication of what the problem is.  There have been memory leaks in calico-kube-controllers in the past, so one thing to check for is whether the pod is crashing/restarting due to hitting memory limits.  Also, examine what changes have been made to the cluster recently that might be directly or indirectly causing the problem, such as:
  - Calico configuration changes
  - Calico or Kubernetes network policy changes
  - Firewall/Gateway device configuration changes
  - Static routes added/changed
  - VPN connection/configuration added/changed
  - Master or worker updates

### Logs and Data to Gather For Calico Issues

Gather the following output and logs, especially if the customer wants any analysis of the problem after it is resolved via a master refresh or worker reload/replace.  Note that calico-node pods are in the `kube-system` (IKS 1.28 or lower) or `calico-system` (IKS 1.29 and above) namespace for IKS, and the `calico-system` namespace for ROKS.

1. `kubectl describe pod -n <kube-system/calico-system> calico-kube-controllers-YYYYYYYYYY-XXXXX`
2. `kubectl describe node <worker_node_name>` (for the node the calico-kube-controllers pod is on)
3. `kubectl logs -n <kube-system/calico-system> calico-kube-controllers-YYYYYYYYYY-XXXXX > calico-kube-controllers-YYYYYYYYYY-XXXXX.log`

## Escalation Policy

Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)


## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [Calico Architecture](https://docs.projectcalico.org/reference/architecture/)
  * [Connecting Applications with Services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
