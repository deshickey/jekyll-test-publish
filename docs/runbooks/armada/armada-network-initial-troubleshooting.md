---
layout: default
title: IKS/ROKS Initial Network Troubleshooting
runbook-name: "IKS/ROKS Initial Network Troubleshooting"
tags: calico network troubleshooting pod networking
description: "IKS/ROKS Initial Network Troubleshooting"
service: armada-network
link: /armada/armada-network-initial-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}


## Overview

This initial network troubleshooting runbook is the starting point for IKS in-cluster networking issues (customer clusters, Carriers, and Tugboats).  If the issue is with something outside of an IKS cluster, for instance a haproxy machine, Vyatta, Fortigate, or a network or routing issue in the IBM Cloud infrastructure, then this runbook should NOT be used, and the appropriate runbook or team responsible for the affected component should be consulted.
 - haproxy (IPVS) machine - Netint team
 - Vyatta (VRA), Fortigate, Juniper, or other network firewall/gateway
    - If it is a Vyatta in an IBM service account (for our IKS Control Plane carriers/tugboats), consult the Netint team
    - If the firewall/gateway is in the customer account, then the customer is responsible for it.  The IKS network teams do NOT manage or troubleshoot these, nor do we consult on how to properly set them up or fix them when they are misconfigured
 - IBM Cloud Infrastructure network issues
    - For customer tickets where general cloud network issues are suspected (outside of the customer cluster), transfer the to the appropriate network team within IBM Cloud/Infrastructure
    - For CIEs/problems with cloud networking affecting carriers or tugboats, ask in #conductors or #containers-cie slack that someone with access into the private #network_response_team channel page the network Infra team via the pinned post in this channel

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

### PD Alert - Scrape Failure for armada-network

For armada-network_endpoint_scrape_failure PD alerts, use the [How to handle a scrape failure pagerduty alert](./armada-global-scrape-failure.html) runbook.

### PD Alert - Customer OpenVPN Server is down

For armada-network-openvpnserver PD alerts, use the [HA Master OpenVPN Server is down troubleshooting](./armada-network-openvpn-server-troubleshooting.html) runbook.

### PD Alert - Customer Konnectivity Server is down

For armada-network-konnectivityserver PD alerts, use the [Konnectivity Server is down troubleshooting](./armada-network-konnectivity-server-troubleshooting.html) runbook.

### Worker Deploy Failures

1. For VPC workers stuck in **provisioning** state for a new cluster with the Status **Pending endpoint gateway creation**, if that message has been there for more than 20 minutes, use the [Worker Pending Endpoint Gateway Creation](./armada-network-pending-endpoint-gateway.html) runbook to investigate and resolve the issue.

2. For VPC workers stuck in **provisioning** state for a new cluster with the Status **Pending security group creation**, if that message has been there for more than 20 minutes, use the [Worker Pending Security Group Creation](./armada-network-security-group-pending.html) runbook to investigate and resolve the issue.

### armada-network-microservice issues

Follow the [How to troubleshoot errors thrown by armada-network microservice](./armada-network-error.html) runbook

### Openshift Console is Not Accessible

See the [Openshift Console](./armada-network-openshift-console.html) runbook.


### Problems with calico-node

See the [calico-node Troubleshooting](./armada-network-calico-node-troubleshooting.html) runbook.


### Problems with calico-kube-controllers

See the [calico-kube-controllers Troubleshooting](./armada-network-calico-kube-controllers-troubleshooting.html) runbook.


### IKS Loadbalancer Issue

If customers are having a problem with an IKS LoadBalancer service they created, please first refer them to our customer docs here:

 - [IKS Classic and "Gateway Enabled" Clusters:](https://cloud.ibm.com/docs/containers?topic=containers-cs_network_planning)
 - [Openshift Classic Clusters:](https://cloud.ibm.com/docs/openshift?topic=openshift-cs_network_planning)
 - [IKS VPC Clusters:](https://cloud.ibm.com/docs/containers?topic=containers-vpc-lbaas)
 - [Openshift VPC Clusters:](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-lbaas)

 We have extensively documented how to use LoadBalancer objects in all our Kubernetes environments, including prerequisites, how to set them up, and many common issues and how to solve them.  Have the customer go through these documents, identify exactly what kind of Loadbalancer they have (the lists are in these docs), and then go through the prerequisites for the specific loadbalancer type they have (i.e. LBv1 vs LBv2 vs VPC LB vs Ingress ALB, single zone vs multizone).  Then get the Loadbalancer service yaml so you can determine what annotations they have set, and compare that to what the documentation recommends.

 There is also customer documentation on setting up Calico policies to protect these Loadbalancers here: 
 - [For IKS Classic Clusters:](https://cloud.ibm.com/docs/containers?topic=containers-network_policies#block_ingress)
 - [For VPC Clusters:](https://cloud.ibm.com/docs/containers?topic=containers-vpc-network-policy)
 - [For Openshift Clusters:](https://cloud.ibm.com/docs/openshift?topic=openshift-network_policies)
 Mention this to the customer and ask if they have any Calico policies for this cluster, and if so, if they followed the examples in our documentation.

 If none of this solves the problem for the customer, use the following runbooks to further troubleshoot the problem:

 - IKS, Openshift, and Gateway Enabled Classic Clusters: [Armada - Load balancer service](./armada-network-load-balancer-troubleshooting.html) runbook
 - IKS and Openshift VPC Clusters: [Armada - VPC Load balancer service](./armada-network-vpc-load-balancer-troubleshooting.html) runbook


### Customer Reports DNS Issues

The following customer documentation should be used to troubleshoot any DNS issues inside the cluster.
 - [General DNS troubleshooting for IKS clusters](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
 - [Specific coreDNS troubleshooting for IKS:](https://cloud.ibm.com/docs/containers?topic=containers-coredns_lameduck)
 - [General DNS troubleshooting for Openshift clusters](https://access.redhat.com/solutions/3804501)

### Customer Reports Nodes Going into NetworkUnavailable State

Nodes will go into `NetworkUnavailable` state whenever its `calico-node` pod has been shutdown.  This is a normal part of patching Calico and should not impact application availability.  When Calico is updated it adds the `node.kubernetes.io/network-unavailable:NoSchedule` taint and the `NetworkUnavailable` condition becomes `True` as part of the Calico shutdown process.  Both of these will be cleared when Calico restarts.

Normally, this takes only a few seconds.  In some cases it takes longer.  In nearly all cases, the restart is fast enough to avoid any node network troubles.  However, there are situations where a Calico restart is delayed and thus, there could be network interruptions.  For these cases, the node network unavailable taint and condition are designed to keep new apps from being deployed to the new node until Calico and/or the node are fixed.  Calico updates are rolled out in a very controlled manner so as to minimize overall application impact should there be a node problem.

**Monitoring NetworkUnavailable state with sysdig**

Monitoring applications, such as Sysdig, may include monitors when a node goes into `NetworkUnavailable` state, and count each time this happens.  A customer has the option to be alerted each time this monitor is triggered.  If the customer reports `NetworkUnavailable` alerts from Sysdig (or other monitoring apps), it's possible their alert is firing during a routine update cycle, and may need to be fine-tuned to ignore this situation.

See this [troubleshooting](https://cloud.ibm.com/docs/containers?topic=containers-ts-network-calico-node) document for additional information.

A `NetworkUnavailable` alert may become a problem when:
 - A calico-node pod fails to achieve a `Running` state, and its container restart count continues to increase.
 - A node remains in `NetworkUnavailable` state for an inordinate amount of time

If either of these situations are true, see the [calico-node troubleshooting](./armada-network-calico-node-troubleshooting.html) runbook.

### Customer Reports Intermittent Issues Connecting to External Service from VPC Cluster

There is a limit to the number of connections that can exist at once from a given zone in a VPC, and if a customer is doing heavy load testing or is just making a very large number of connection attempts from a large number of nodes in the same zone in a VPC, they might hit this limit.  If a customer reports intermittent connection issues to/from applications in their VPC cluster, they might be hitting this, and we should ask in the customer ticket for the VPC IPOps team can check this using runbook: [https://pages.github.ibm.com/cloudlab/internal-docs/sdnCheckSgwPorts.html](https://pages.github.ibm.com/cloudlab/internal-docs/sdnCheckSgwPorts.html).  There is also https://jiracloud.swg.usma.ibm.com:8443/browse/FAB-12421 which is to implement monitoring for this condition so the VPC team can be more proactive.  This was last discussed in slack here: [https://ibm-cloudplatform.slack.com/archives/C06162QGJNM/p1699453356670909?thread_ts=1697141651.329649&cid=C06162QGJNM](https://ibm-cloudplatform.slack.com/archives/C06162QGJNM/p1699453356670909?thread_ts=1697141651.329649&cid=C06162QGJNM)


### After Worker Update/Replace, `calico-node` Pod Does not Start on ROKS VPC Cluster

The `calico_node` pod _may_ get stuck in a state where it is unable to start on a ROKS VPC cluster.  This is not an issue on IKS or Classic clusters.  This can occur when a customer has the `sysdig-admission-controller-webhook` installed and attempts to do a worker update or replace.  To understand why this happens.
1. The VPN client pod gets moved to the new worker as it is coming up.
2. `calico-node` on the new worker starts up, but gets stuck because it makes an apiserver call and times out after 2 seconds.
3. The apiserver call then tries to call the webhook which fails because the VPN client pod was trying to start up on the new node.  The VPN node cannot successfully do so because `calico-node` hasn't started up yet.

In a nutshell the `calico-node` pod startup depended on the webhook working, the webhook depended on the VPN client pod, and the VPN client pod depended on calico-node starting up.  We are stuck in a circular dependency.  If you are able to gather logs from a successfully deployed `calico-node` pod, you may see an error like this.
```
2022-09-08 07:13:19.719 [WARNING][9] startup/utils.go 228: Failed to set NetworkUnavailable; will retry error=Patch "https://172.21.0.1:443/api/v1/nodes/10.242.64.17/status?timeout=2s": net/http: request canceled (Client.Timeout exceeded while awaiting headers)
```
**Workarounds**

One of the following methods can be used to workaround the issue, and get the `calico-node` pod running again.
1. Remove the `sysdig-admission-controller-webhook` from the system.  - OR -
2. Modify the `sysdig-admission-controller-webhook` and change the timeout to be less than 2 seconds.  - OR -
3. Modify the `sysdig-admission-controller-webhook` to scope it to the appropriate namespace(s), and avoid system-critical namespaces such as `calico-system`.  - OR -
4. Cordon the new node (you shouldn't need to drain it).  Delete the VPN pod, and wait for it to start on another worker.  Uncordon the node.

After performing any one the previous steps the `calico-node` pod should start.

### Pods Not Starting due to Network errors/events in `kubectl describe pod ...`

First check that calico-node is healthy on the node(s) that the pod(s) are having trouble starting on (using the instructions above to fix the issue), and make sure calico-kube-controllers is running on exactly one node in the cluster.  Once calico-node and calico-kube-controllers are both healthy, try to restart the problem pods.

If `kubectl describe pod ...` shows an error like:

```
Failed to create pod sandbox: rpc error: code = Unknown desc = failed to setup network for sandbox ... failed to request 1 IPv4 addresses. IPAM allocated only 0
```

or

```
Warning  FailedCreatePodSandBox  22s (x7 over 21m)  kubelet (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_vpn-89998f945-w9r9r_kube-system_643f26cb-ada1-4b7a-8590-83afa1f5a4e5_0(1dfae862ac2b6c3920957d89405e40ee5ac2a1e3e6bfbeeea1d9e52000dc47de): error adding pod XXXXXXXXXXX to CNI network ...: error adding container to network "k8s-pod-network": cannot allocate new block due to per host block limit
```

then the problem is that the cluster or maybe just the individual worker has run out of pod IPs or full free IP blocks.  The solution for customers is to run the steps in the [Why don't my containers start](https://cloud.ibm.com/docs/containers?topic=containers-ts-app-container-start#calico-ips) doc to clean up leaked pod IPs and blocks.  We also have a [Runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada_cleanup_leaked_pod_ips_and_blocks.html) that explains how to run these steps using a [Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-calico-ipam-cleanup/), so with the customer's permission (or on our own tugboats) we can use that instead, but it does require an approved prod train.

If it is some other error, then the issue is most likely something with the specific node or nodes that the problem pods are on.  If calico-node on the worker is having problems, look follow the instructions above for calico-node.  Otherwise follow the Troubleshooting IKS/ROKS Workers section in the [Network Must-Gather Doc](https://github.ibm.com/ACS-PaaS-Core/MustGathers/blob/master/Kubernetes/Networking/networking.md)


### General Customer Complaints about "Network Errors"

Customers often complain about vague "network issues" and find all sorts of reasons to claim it must be a problem with IKS (and not with their own applications).  When this occurs, follow the [Network Must-Gather Doc](https://github.ibm.com/ACS-PaaS-Core/MustGathers/blob/master/Kubernetes/Networking/networking.md) to gather more information from the customer about the specific problem including answering the questions in there.

If the customer is not able to reproduce this, if it only happens within the customer's application, or the customer does not have specifics then we will not be able to provide assistance.  The next section includes suggestions to help the customer debug the issue on their own and try to narrow down the problem to a recreatable case


### Suggestions Customers Can Use To Troubleshoot Their Own Networking Issues

1. [General troubleshooting for Kubernetes services:](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/)
2. If it related to Loadbalancers at all, point to our customer docs for Loadbalancers in the above `IKS Loadbalancer Issue` section
3. Reload/Replace the workers
4. Try adding worker nodes in their problem cluster in a new VLAN (unless they are using a Vyatta or other firewall/gateway, because that firewall/gateway wouldn't be configured to support a new VLAN) and using those workers and temporarily cordon and drain the troubled worker(s). There is a small chance that something strange is going on with the existing workers they have in their existing VLAN (maybe noisy neighbors, a bad router, etc). If the problem goes away, then they can either switch to only use those workers, or troubleshoot more with the IBM Cloud infrastructure team
5. Run tcpdump on their worker to see the packet flow from the worker's perspective. tcpdump instructions can be found here: https://www.ibm.com/cloud/blog/troubleshooting-load-balancers-in-ibm-cloud-kubernetes-service-using-tcpdump


### Gateway Enabled Cluster - Private-only workers cannot access external services on public network

We have extended Gateway Enabled Cluster support for a single customer, Qualtrics (Clarabridge), until 6/30/24 (so through IKS 1.27), so we will need to continue to provide them support.  For all other customers, they can not create new Gateway Enabled clusters, and for existing clusters:

GEC are only supported through IKS 1.23 (which goes unsupported on 5/8/23)
    - Customers can not create GE clusters, and can't update their cluster masters to 1.24
        - https://cloud.ibm.com/docs/containers?topic=containers-cs_versions_124
        - These docs state: "The end of support dates are linked directly to the end of support of IBM Cloud Kubernetes Service version 1.23. Gateway-enabled clusters are not supported on version 1.24 and later. If your cluster is gateway-enabled, plan to create a new cluster before support ends. If you need similar functionality, consider creating a cluster on VPC infrastructure."

GEC are only supported through 4.9 (which goes unsupported on 7/26/23)
    - Customers can not create GE clusters, and can't update their cluster masters to 4.10
        - https://cloud.ibm.com/docs/openshift?topic=openshift-cs_versions_410
        - These docs state: "The end of support dates are linked directly to the end of support of Red Hat OpenShift on IBM Cloud version 4.9. Gateway-enabled clusters are not supported on version 4.10 and later"

Follow the [Gateway Enabled Cluster Troubleshooting](./armada-network-gateway-enabled-cluster-troubleshooting.html) runbook.


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
