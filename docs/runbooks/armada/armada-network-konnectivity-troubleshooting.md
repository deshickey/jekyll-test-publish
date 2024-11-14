---
layout: default
description: "[Troubleshooting] Armada - in-cluster network connection (Konnectivity)"
title: "[Troubleshooting] Armada - in-cluster network connection (Konnectivity)"
runbook-name: "[Troubleshooting] Armada - in-cluster network Connection (Konnectivity)"
service: armada
tags: alchemy, armada, armada-network, connect, containers, kubernetes, kube, kubectl, network,, bird, webhook, konnectivity, konnectivity-server, konnectivity-agent
link: /armada/armada-network-konnectivity-troubleshooting.html
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
- `webhooks` that call into a cluster service (which can impact everything in the cluster including updates, even the Konnectivity agent pods)

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

## Investigation and Action: Konnectivity based solution

1. On IKS, there is one Konnectivity server deployment per cluster in the control plane (`kubx-masters` namespace) with 1 replica. Check if this component has the state `READY` and `RUNNING`.

1. On ROKS, the `kube-apiserver` deployment has the Konnectivity-server container (`master-<clusterID>` namespace). This also means that there are 3 replicas of the konnectivity server. Check if all these components are `READY` and `RUNNING`.

1. On ROKS, the `openshift-apiserver` deployment has a socks5-proxy container (`master-<clusterID>` namespace). Check if all these components are `READY` and `RUNNING . These containers are required for extension apiserver functionalities such as `ImageStreams`, `Security Context Constraints (SCC)`, `Openshift Routes`, `Webhooks` etc.

1. Both IKS and ROKS have Konnectivity agents in customer cluster, running in a daemonset (`kube-system` namespace). Check if all these components have the state "running".

1. As Konnectivity agents are running in daemonset, every worker node has an instance. This means when one of the agent is down, other could relay the connection. If the problem is worker node specific, a generic step could be to restart the agent on that particular node.

    *Tip*: to restart all the Konnectivity agents pods on the customer cluster: `kubectl rollout restart daemonset -n kube-system konnectivity-agent`.

    *Note*: if there are no Konnectivity agent pods on the customer cluster there might be an issue with a webhook blocking pod creation (perhaps because the missing pods prevent the Kubernetes API server from communicating with a validating or mutating webhook). To resolve this dependency circle (webhook needs Konnectivity agent, Konnectivity agent start needs webhook), customer needs to disable the webhook which prevents the Konnectivity agent pod start.

1. In case of classic infrastructure, if the customer has a multizone cluster or using multiple subnets even in one zone, ensure the customer has either VLAN spanning or VRF enabled in their account (instructions for the customer to do this are here: https://cloud.ibm.com/docs/containers?topic=containers-plan_clusters under Worker node communication across subnets and VLANs). For SREs or developers investigating the customer account, check [get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job's output under `BIRD LOGS:` Each of the POD: `calico-node-` sections lists that node's BGP connections to the other nodes in the cluster. In healthy clusters all these connections should be `Established` If some connections to other workers are not `Established`, this can sometimes indicate that `VRF` and `VLAN spanning` are not enabled, preventing workers in different subnets from being able to communicate with each other - which also prevents Konnectivity agents to proxy properly the traffic.

1. If the problem is not worker specific and nothing is working (`cp/exec/logs/dashboard/webhooks/top`), then check the cluster settings: if the Private Service Endpoint is enabled for the cluster, Konnectivity agents will try to use that for connecting to the Konnectivity server(s). In case of classic infrastructure, the Private Service Endpoint requires VRF and Service Endpoints Enabled in the IBM Cloud account. Please ask the customer to validate the account settings using `ibmcloud account show` from the account the cluster is in, to see if VRF and Service Endpoints Enabled are both true.

1. If customer has the Private Service Endpoint, but does not have the required settings, there are two options:
    - Enable VRF and Service Endpoints in the account. Once it is done, Konnnectivity agents will connect to the Konnectivity server and it shall start working.
    - Disable the Private Service Endpoint for the cluster (via armada-data or CLI) and than a master-refresh will resolve the issue

    *Tip*: to see what kind of service endpoint is used by the Konnectivity agent, check the following command and look for `--proxy-server-host` parameter: `kubectl get ds -n kube-system konnectivity-agent -o yaml`

1. Check the Konnectivity server logs and grep for `"Connect request from agent"`.
    For example: `kubectl logs -n kubx-masters konnectivity-server-c5asq9320s6h458rnecg-665c7fbcf7-9vm68 | grep "Connect request from agent"`
    If there is no such logs, agent cannot connect to the Konnectivity server. Possible causes:
    - there is some network policy which makes the connection impossible. To see that, run get-master-info and examine the Calico network policies of the cluster
    - there are other problems with the agents, ask the customer or SRE to try to SSH to one of the nodes: https://cloud.ibm.com/docs/containers?topic=containers-cs_ssh_worker and check `crictl ps | grep -i konnectivity-agent` and `crictl logs <KONNECTIVITY_CONTAINER_ID_FROM_THE_EARLIER_COMMAND>`

1. If the log from the Konnectivity agent container shows connection issues, there is probably a problem with the routing from the customer workers to the master. Konnectivity is using TCP with a `nodePort`, so customer needs to check their `Vyatta`/`Juniper`/`pfSense`/other network appliance or the already mentioned `Calico policy`), and check if they allow this traffic or not.

    *Tip*: to see what kind of port is used by the Konnectivity agent, check the following command and look for `--proxy-server-port` parameter: `kubectl get ds -n kube-system konnectivity-agent -o yaml`

1. If the cluster is using Private Service Endpoint and the Private Service Endpoint ACL is also enabled, then need to check if the Konnectivity port is allowed or not on the cluster. To check this, use the XO bo: `@xo cse.cluster <CLUSTER_ID>`

1. If Konnectivity agents are looking good - they could connect, but it is still not working, restart the Konnectivity server. Customer could do this using master refresh: `ibmcloud ks cluster master refresh -c <cluster_id>`. Moreover, SREs can also perform this action by manually deleting the `konnectivity-server` (`kubx-masters` namespace) pod on the carrier or the tugboat and let it restart.

1. Wait for the cluster refresh to complete (can take 30 minutes or more) and check the functionality again.

1. If everything is fine, but there are still issues with webhooks, please follow this [guide](https://pages.github.ibm.com/alchemy-containers/armada-deploy/common-instructions/webhook-troubleshooting-runbook.html)
## Escalation Policy

If unable to resolve problems with in-cluster connection to the master, involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References
  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [kubectl commands time out](https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot#exec_logs_fail)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
