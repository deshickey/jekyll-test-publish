---
layout: default
title: IKS/ROKS Worker NotReady or Critical Troubleshooting
runbook-name: "IKS/ROKS Worker NotReady or Critical Troubleshooting"
tags: network node notready not ready troubleshooting critical
description: "IKS/ROKS Worker NotReady or Critical Troubleshooting"
service: armada-network
link: /armada/armada-network-node-not-ready-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes the troubleshooting steps when a customer cluster has one or more worker nodes reporting a bad state.  This includes:

- When `kubectl get nodes` shows one or more workers in "NotReady" state
- When `ibmcloud ks workers...` shows one or more workers in "Critical" state
- When `@xo clusterWorkers <CLUSTERID>` shows one or more workers in critical state

This runbook is only meant for a case where the cluster and its workers deployed successfully initially, but then after some time some nodes are now in a bad state.  If all nodes in a cluster won't deploy at all, even the first time when the cluster is first being created, then use the [IKS/ROKS Node Deploy Fails Network Troubleshooting](./armada-network-node-initial-deploy-fails.html) runbook instead of this one.

From now on in this runbook I'll just use the term "critical" to refer to workers that are showing either NotReady or Critical

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

How to investigate these depend on the situation.

### One or a Few Workers are Currently in Critical

Tell the customer to follow the documentation that is being added/updated as part of doc issue: https://github.ibm.com/alchemy-containers/documentation/issues/10641

### All Workers in a Cluster or in a Zone Are Currently Critical

Tell the customer to follow the documentation that is being added/updated as part of doc issue: https://github.ibm.com/alchemy-containers/documentation/issues/10641.  If they do that and still don't find a problem, then they should follow the instructions to gather the data we need and create a support ticket.  If they have done this, then continue on with the following troubleshooting steps.

If all nodes in a cluster or in a zone go critical at the same time then problem is most likely not with the individual workers.  Possible problems could be:

- Cluster master
- (VPC Clusters Only) - VPE Gateway
- IKS Control Plane VIPs, Edge Nodes, or haproxy VSIs
- Cloud Service Endpoints (CSEs)
- Customer Security Groups, ACLs, Network Policy, Firewalls/Gateways, custom DNS, custom routing, or webhooks
- Calico-node failing to start due to a bug or one of the above items

Follow these steps in order until the problem is resolved:

1. Follow the [IKS/ROKS Cluster Master Health Checks](./armada-master-health-checks.html) runbook
2. **(VPC Clusters Only)** Follow the [IKS/ROKS Cluster Master VPE Gateway Troubleshooting](./armada-network-vpe-gateway-troubleshooting.html) runbook
3. Follow the [IKS/ROKS Control Plane Network Troubleshooting](./armada-network-control-plane-network-troubleshooting.html) runbook
4. **(VPC Clusters Only)** Follow the [IKS/ROKS Check VPC Cluster Security Groups](./armada-network-check-cluster-security-groups.html) runbook
5. If no problems are found in those sections above, we should let the customer know that our control plane and the cluster master look fine, and ask the customer again to check their firewall/gateway configuration, security groups, ACLs, custom routes, custom DNS, and anything else they can think of that they might have configured, or that might have changed in their account recently.

### All Workers in a Cluster or in a Zone Went Critical for a Time in the Past and then Recovered on Their Own

Use the **All Workers in a Cluster or in a Zone Are Currently Critical** steps, including asking the customer to follow the documentation (as much as they can given that the problem isn't happening currently).  If they still want us to look at this, then follow the steps above but just focus on what you can find from logs, incidents, and prometheus data to try to explain the outage.

### One or a Few Workers in a Cluster Went Critical for a Time in the Past and then Recovered on Their Own

Similar to the above, but less clear if the problem was widespread and possibly master or control plane related, or just a problem with individual nodes and/or customer workload, so don't spend a lot of effort trying to get to an RCA for this since it is more likely it was an issue with customer configuration or customer workload.

## Escalation Policy

If the above steps don't resolve the issue, and the problem appears to be network related, use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

  * [Troubleshooting IKS Worker Nodes](https://cloud.ibm.com/docs/containers?topic=containers-debug-kube-nodes)
  * [Troubleshooting ROKS Worker Nodes](https://cloud.ibm.com/docs/openshift?topic=openshift-debug-kube-nodes)
