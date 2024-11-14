---
layout: default
description: "[Troubleshooting] Armada - in-cluster network connection (VPN)"
title: "[Troubleshooting] Armada - in-cluster network connection (VPN)"
runbook-name: "[Troubleshooting] Armada - in-cluster network Connection (VPN)"
service: armada
tags: alchemy, armada, armada-network, connect, containers, kubernetes, kube, kubectl, network, vpn, openVPN, bird, webhook, openvpnserver
link: /armada/armada-network-vpn-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook covers detailed steps on troubleshooting of in-cluster connection.
When the connection between the cluster and its master doesn't work, it can cause problems with:

- `kubectl exec`, `kubectl logs`, `kubectl cp`
- `kubernetes dashboard`
- `kubectl top` (and anything that uses the `metrics-service`)
- `webhooks` that call into a cluster service (which can impact everything in the cluster including updates, and even the VPN pod)

The solution which makes the in-cluster connection differs per IKS/ROKS version:
OpenVPN is used by the following clusters (so use this runbook):
- Non-satellite Commercial cloud ROKS clusters
- ROKS Satellite cruiser clusters that do not use hypershift

Konnectivity is used by the following clusters, so use runbook [In-Cluster Konnectivity Connection Troubleshooting](./armada-network-konnectivity-troubleshooting.html) for these):
- All supported IKS customer clusters
- All IKS/ROKS control plane clusters
- All Satellite Location clusters
- All Fedramp Clusters
- ROKS Satellite cruiser clusters that use hypershift
- ROKS cruiser clusters on version 4.14 or above

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action: Troubleshooting Steps for clusters using our openVPN solution

1. There is one OpenVPN server inside the control plane and several OpenVPN clients: one in the master deployment (next to Kubernetes API server), one for the Openshift API server (in case of ROKS), one in the cruiser (customer cluster)

1. In case of classic infrastructure, if the customer has a multizone cluster or using multiple subnets even in one zone, ensure the customer has either VLAN spanning or VRF enabled in their account (instructions for the customer to do this are here: https://cloud.ibm.com/docs/containers?topic=containers-plan_clusters under Worker node communication across subnets and VLANs). For SREs or developers investigating the customer account, check [get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job's output under `BIRD LOGS:` Each of the POD: `calico-node-` sections lists that node's BGP connections to the other nodes in the cluster. In healthy clusters all these connections should be `Established` If some connections to other workers are not `Established`, this can sometimes indicate that `VRF` and `VLAN spanning` are not enabled, preventing workers in different subnets from being able to communicate with each other.

1. Check if the `vpn client` pod in the `kube-system` namespace in the customer cluster is in any state other than `"Running"`. If so,  then run a `kubectl describe pod <pod-name>` on that pod to see if there are problems scheduling this pod (due to taints, nodes being at their limits, etc), contact the customer and let them know their configuration is preventing the vpn pod from being scheduled/run.

1. If there are no `vpn client` pods on the customer cluster there might be an issue with a webhook blocking pod creation (perhaps because the missing pods prevent the Kubenetes API server from communicating with a validating or mutating webhook). To resolve this dependency circle (webhook needs `vpn-client`, `vpn client` start needs webhook), customer needs to disable the webhook which prevents the pod start. Note that if the vpn client pod is not on the customer cluster, double check the Overview section, to make sure this cluster should be running OpenVPN, and not Konnectivity.  If you find this cluster is using Konnectivity, then use runbook [In-Cluster Konnectivity Connection Troubleshooting](./armada-network-konnectivity-troubleshooting.html)

1. If the `vpn client` pod is not in `"Running"` state (or in any other bad state), or even if it is in `"Running"` state, but `kubectl describe pod <vpn-xxx>` on this pod shows the Liveness probe failing every 5-10 minutes, then restart it using: `kubectl delete pod -n kube-system -l app=vpn`.

1. Wait at least `10 minutes` for the `vpn client` pod to restart and connect. If that still doesn't fix the problem, then try to restart the `openvpnserver` pod in the customer master. Customers can do this via: `ibmcloud ks cluster master refresh -c <cluster_id>`. Moreover, SREs can also perform this action by manually deleting the `openvpnserver` pod on the carrier or the tugboat and let it restart. For IKS clusters, the `openvpnserver` pod will be in `kubx-masters` namespace. However, for ROKS clusters, the `openvpnserver` pod is named `openvpnserver-managed-ovpn-...` and will be in `master-<CLUSTER_ID>` namespace. Here are examples for each:
    1. For IKS Clusters: `kubectl delete pod openvpnserver-brhs643003qj61o0uf8g-859d6c9cff-vsllb -n kubx-masters`
    2. For ROKS Clusters: `kubectl delete pod openvpnserver-managed-ovpn-654fd7588d-rsfdv -n master-brhs6ji00ma77nii2cc0`

1. Wait for the cluster refresh to complete (can take 30 minutes or more).

1. If this does not fix the problem, try cordoning the worker node that the `vpn client` pod is on and then deleting the `vpn client` pod again so it is rescheduled on a different node. If this fixes the problem, then it is most likely a problem with that specific worker node, and that node should be restarted.

1. If none of this works, there is probably a problem with the routing from the customer workers to the master. A common cause of this is a customer not allowing `UDP` traffic from workers to master (either via a `Vyatta`/`Juniper`/`pfSense`/other network appliance or via a `Calico policy`). Ask the customer if they are using a firewall appliance, and if they have made any changes recently, and if they are allowing `UDP` to the customer masters.

1. Less common causes are network infrastructure issues preventing the proper routing of UDP traffic (due to BCR malfunctions, etc) to our masters.

## Escalation Policy

If unable to resolve problems with in-cluster connection to the master, involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References
  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [kubectl commands time out](https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot#exec_logs_fail)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
