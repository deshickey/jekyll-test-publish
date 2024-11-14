---
layout: default
title: IKS/ROKS Cluster Master VPE Gateway Troubleshooting
runbook-name: "IKS/ROKS Cluster Master VPE Gateway Troubleshooting"
tags: network troubleshooting vpe gateway
description: "IKS/ROKS Cluster Master VPE Gateway Troubleshooting"
service: armada-network
link: /armada/armada-network-vpe-gateway-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}


## Overview

This runbook describes how to troubleshoot the VPE Gateway for the IKS/ROKS cluster master.  Note that VPE Gateway is only used for VPC.  This runbook does not apply to Classic clusters.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

The following sections describe how to check whether the VPE Gateway for the VPC cluster master is functioning properly.

## Verify VPE Gateway Functioning Properly

When VPC workers fail to deploy and are reporting the error `Worker unable to talk to IBM Cloud Kubernetes Service servers. Please verify your firewall setup is allowing traffic from this worker`, there are a few things to check related to the VPE Gateway for the cluster master.

### Check VPE Gateway is OK/Stable State

Right now the best way to do this is to look this up via the VPC Operations Dashboard.  Here are the steps to do this:

1. Connect to the GlobalProtect VPN (requires YubiKey): [https://opsdashboard.w3.cloud.ibm.com/](https://opsdashboard.w3.cloud.ibm.com/)
2. Search for the cluster ID, and select the IKS cluster (or just use the URL: https://opsdashboard.w3.cloud.ibm.com/ops/iksClusters/<CLUSTERID>)
3. Scroll to the bottom of the IKS Cluster and click on the VPC that this cluster is in
4. Scroll to the bottom of the VPC and find the VPE Gateway and make sure it is in `Health State: OK` and `Lifecycle State: Stable`.  Make sure to find the one for this cluster which is named `iks-<CLUSTERID>`

If you can not access the VPC Ops Dashboard, then ask someone else to check this.  All VPC and IKS/ROKS developers should have access.  Or if you are in close contact with the customer you can ask them to check their own VPE Gateway by asking them to go to https://cloud.ibm.com/vpc-ext/network/endpointGateways, select the region their cluster is in from the dropdown box, and click on the VPE Gateway that matches `iks-<CLUSTERID>`.  Check that the status is Stable, and that there is a ReservedIP in each zone in which the cluster has workers.

### Check Private DNS Name for the VPE Gateway

Right now there is not a good way to check the entries in the customer's VPC private DNS for the VPE Gateway, but there are plans to improve the visibility, see [https://ibm-cloudplatform.slack.com/archives/CL3TZLJRH/p1675883295003619?thread_ts=1675652852.254129&cid=CL3TZLJRH](https://ibm-cloudplatform.slack.com/archives/CL3TZLJRH/p1675883295003619?thread_ts=1675652852.254129&cid=CL3TZLJRH) for details.

So until then, ask in [#ibmcloud-private-dns](https://ibm-cloudplatform.slack.com/archives/CL3TZLJRH) what entries (if any) are in private DNS for the VPE Gateway.  Provide the gateway DNS name of the form `<CLUSTER-ID>.vpe.private.<REGION>.containers.cloud.ibm.com` and ask that team which IPs are registered for that name.  There should be one IP for each VPC zone that has cluster workers in it, and that IP should be from one of the customer's VPC subnets in that zone.

## Escalation Policy

If the above steps don't resolve the issue, and the problem appears to be network related, use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

  * [#ibmcloud-private-dns Slack Channel](https://ibm-cloudplatform.slack.com/archives/CL3TZLJRH)
