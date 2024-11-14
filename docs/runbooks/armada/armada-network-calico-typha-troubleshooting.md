---
layout: default
title: IKS Network - calico-typha Troubleshooting
runbook-name: "IKS Network - calico-typha Troubleshooting"
tags: calico calico-typha network networking troubleshooting
description: "IKS Network - calico-typha Troubleshooting"
service: armada-network
link: /armada/armada-network-calico-typha-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}


## Overview
calico-typha is a deployment that should be running several pods in every IKS/ROKS cluster.  For IKS clusters we hardcode the deployment to 3 replicas, so no matter how many nodes are in the cluster, there will be 3 Typha pods and if there are only 1 or 2 working nodes in the cluster, there will be 2 or 1 Typha pods in Pending state (which is fine).  For ROKS clusters, the Calico Operator autoscales the Typha deployment based on the number of nodes.

When an IKS/ROKS cluster is first deployed, and again when its master is updated, calico-typha and other calico components are deployed and configured specifically to work with IBM Cloud and IKS/ROKS components.  In most cases this configuration should not be changed at all.  There are a few specific settings, such as Calico's MTU, which can be modified if needed to handle specific situations, but only Calico settings that are specifically described in the IKS/ROKS documentation should be changed.  Changing other Calico settings is not supported.  Also Calico is updated to new versions as part of IKS/ROKS master updates.  Do NOT attempt to update Calico yourself.

The calico-typha pods are host network pods that act as a proxy to the apiserver and listen on port 5473.  The calico-typha pods register for k8s events and cache k8s data, to reduce the load on the apiserver from all the Calico pods.  calico-node and calico-kube-controllers pods connect to the calico-typha pods (via the k8s service) to get notified of k8s events and data changes.  

More details can be found at https://docs.projectcalico.org/reference/typha/configuration.

This runbook covers steps to take when calico-typha is not working correctly in either a customer cluster, tugboat, or carrier

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

### If none of the calico-typha Pods Are Running At All

If calico-typha is not running, not even in CrashLoopBackOff or Pending state, then most likely the deployment was deleted or scaled down, or a custom webhook is preventing the pods from starting.  To recover, run: `ibmcloud ks cluster-refresh --cluster <CLUSTER_NAME>`  It will take up to 45 minutes for the master to completely refresh and for the calico-typha deployment to be recreated.  If this still doesn't fix the problem, search for "webhook" in the [Armada-Deploy Operations Failure](armada-deploy-operation-failures.html) runbook for more options.

### If one calico-typha pod isn't in Running state

If one of the calico-typha pods isn't in Running state on a given worker, the first thing is to check if the worker is ready and healthy.  Sometimes the calico-typha pod having problems is simply caused by the worker node it is running on not being healthy.  So first check that the worker node the pod is on is in Ready state.  If it is not, cordon, drain, and reload that node, which should move that calico-typha pod to a different node and most likely solve the problem.

Even if the node appears healthy, cordon the node and then use `kubectl delete pod -n <kube-system/calico-system> calico-typha-YYYYYYYYYY-XXXXX` to delete the pod which will reschedule it to a different node.

### calico-typha in CrashLoopBackOff or Restarting Often

Assuming you have already tried to move the calico-typha pods to several different nodes and that has not helped, the problem is most likely something in the Calico configuration, or possibly in the Calico/Kubernetes Datastore.

Gather the output and logs listed in the "Logs and Data to Gather For Calico Issues" section below, and examine that output for an indication of what the problem is.  One thing to check for is whether the pod is crashing/restarting due to hitting memory limits.  Also, examine what changes have been made to the cluster recently that might be directly or indirectly causing the problem, such as:
  - Calico configuration changes
  - Calico or Kubernetes network policy changes
  - Firewall/Gateway device configuration changes
  - Static routes added/changed
  - VPN connection/configuration added/changed
  - Master or worker updates

### Logs and Data to Gather For Calico Issues

Gather the following output and logs, especially if the customer wants any analysis of the problem after it is resolved via a master refresh or worker reload/replace.  Note that calico-node pods are in the `kube-system` (IKS 1.28 or lower) or `calico-system` (IKS 1.29 and above) namespace for IKS, and the `calico-system` namespace for ROKS.

1. `kubectl describe pod -n <kube-system/calico-system> calico-typha-YYYYYYYYYY-XXXXX`
2. `kubectl describe node <worker_node_name>` (for the node the calico-typha pod is on)
3. `kubectl logs -n <kube-system/calico-system> calico-typha-YYYYYYYYYY-XXXXX > calico-typha-YYYYYYYYYY-XXXXX.log`

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
