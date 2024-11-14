---
layout: default
title: IKS/ROKS Check VPC Cluster Security Groups
runbook-name: "IKS/ROKS Check VPC Cluster Security Groups"
tags: network troubleshooting vpc check security group
description: "IKS/ROKS Check VPC Cluster Security Groups"
service: armada-network
link: /armada/armada-network-check-cluster-security-groups.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook only applies to VPC IKS/ROKS clusters.  Classic clusters do not use security groups.

This runbook describes how to check a VPC cluster's security groups to see if:

1. The default security groups we provide have been altered by the customer?
    - If so, are the required connections still allowed
2. Is the customer using their own security groups for their workers, LBaaS, or VPE Gateways?

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

The following sections provide an overview of what VPC security groups are created when a customer creates a new VPC IKS/ROKS cluster, as well as how to check if changes to or replacements of those default security groups might be causing a problem.

## Overview of Default VPC Security Groups

Here are our external docs that describe our default VPC security groups and what customers need to allow if they want to change these or not use them:

**Secure by default configuration**
- [IKS 1.30+](https://cloud.ibm.com/docs/containers?topic=containers-vpc-security-group-reference)
- [ROKS 4.15+](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group-reference)

**Legacy configuration** 
- [IKS 1.29 and earlier](https://cloud.ibm.com/docs/containers?topic=containers-vpc-security-group&interface=ui)
- [ROKS 4.14 and earlier](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group&interface=ui)

Ideally between these docs and the function we provide, like the security group reset and sync functions, customers should be able to solve most of their own security group issues.  So the goal should be to improve our code as well as those documents whenever possible, and only put things in this runbook if the information does not make sense to share with customers.

## When a Customer Ticket Reports Problem With Security Groups

When a customer ticket comes in with a question about IKS/ROKS VPC clusters and security groups, or that reports a problem that might be related to security groups, we should first do the following:

1. Refer the customer to the documentation linked above (for either IKS or ROKS depending on what they are using)
2. Ask if they have modified the rules in the security groups we deploy or are using their own security groups.  If so, we should suggest they revert all their changes to see if the problem is resolved by running a `reset` or `sync` if applicable (see below).
3. If that still doesn't fix their problem, or if they can't do that for some reason, make sure they provide all the Network MustGather answers and debug tool data, and clearly state the problem they are having.
4. At that point a network team member can look at the problem and the data they provided using the guides below.

## Reset and Sync Security Groups

A customer can attempt to [reset](https://cloud.ibm.com/docs/containers?topic=containers-kubernetes-service-cli#security_group_reset) or [sync](https://cloud.ibm.com/docs/containers?topic=containers-kubernetes-service-cli#security_group_sync) their security groups to fix any potential problems.  A `reset` operation puts their security group back into its default state.  **Resetting will delete all existing rules, and network traffic to their cluster may temporarily be blocked.**  After the rules are deleted, the default rules are re-added back onto the security group.  A `sync` operation analyzes their existing security group rules, and identifies any default rules that may be missing.  If a rule is missing it is re-added back onto the security group.  **Syncing will not delete any rules a customer may have added.** 

We will never reset or sync a customer managed security group.  We also do not reset or sync the default VPC security group (`FOUR-RANDOMLY-GENERATED-WORDS`).  The following IKS managed security groups support the reset and sync operation:

**Secure by default configuration**
- Cluster worker: `kube-<CLUSTER ID>`
- Master VPE gateway: `kube-vpegw-<CLUSTER ID>`
- Shared VPE gateway: `kube-vpegw-<VPC ID>`
- Load balancer: `kube-lbaas-<CLUSTER ID>`

**Legacy configuration** 
- Cluster worker: `kube-<CLUSTER ID>`
- Master VPE gateway/Load balancer: `kube-<VPC ID>`
- Shared VPE gateway (if exists): `kube-vpegw-<VPC ID>`

## Check Security Groups for Changes

GMI gathers security group, endpoint gateway, VPC, and VPC subnet information as long as it is run with the `KUBX_LOAD_BALANCER_INFO` option checked.  The best way to get this is to label the customer ticket with `squad-network` and then remove the `analysis-report` tag.  GMI is re-run with the `KUBX_LOAD_BALANCER_INFO` option checked. When `analyze-cluster` runs it will check if our security groups might have been changed.

The first thing to look for is if the cluster has the `secure by default` security group configuration.  This tells you which set of security groups are being analyzed.  The `analyze-cluster` output will indicate this with one of the following statements:
- This cluster uses the `secure by default` security group configuration.
- This cluster uses the `secure by default` security group configuration.  Outbound traffic protection is disabled.

The IKS managed security groups are then analyzed to check 3 things.
1. If the number of expected rules equals the number of actual rules.
2. If any of the expected rules are missing.  The missing rules (along with a description) are listed.
3. If any unexpected rules exist.  These are rules added by the customer, and are listed.

The presence or absense of rules or security groups does not necessarily indicate a problem.  Please keep the following in mind.
1. The cluster worker security group `kube-<CLUSTER ID>` has underwent several changes over different release levels.  We do not update security group rules following a cluster upgrade.  Therefore, rules that are missing may not be missing because they were deleted.  They are missing because the cluster was upgraded.  If ALL the missing rules are due to an upgrade, `analyze-cluster` will tell you this.
2. The shared VPE gateway security group contains a remote rule between it and ALL cluster worker security groups in the VPC.  `Analyze-cluster` only checks for the rule of the cluster under analysis.  It does not look for the rules for every cluster in the VPC.
3. Customers may replace our security groups with theirs.  In this case `Analyze-cluster` will show an error saying a security group is missing.  The GMI output should be inspected, and will show the customer's security group(s) if they exist.
4. The rules on the secure by default load balancer security group, `kube-lbaas-<CLUSTER ID>`, are complex and are not analyzed.  We will show an error if there are no rules or the security group itself is missing.  The network squad can inspect the GMI output to verify the rules are allowing the correct traffic.
5. The default VPC security group, `FOUR-RANDOMLY-GENERATED-WORDS`, is not analyzed.

Note: The IKS Debug Tool has a Security Groups test that exports a "listSecurityGroups.txt" file for VPC clusters which contains the security group data that we can review to see if the customer has modified the rules we have in our default security groups.  This feature is unsupported, out-of-date and will eventually be removed.  We do not recommend using this.  Instead, use GMI/analyze-cluster.

## Escalation Policy

If the above steps don't resolve the issue, and the problem appears to be network related, use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

**Secure by default configuration (IKS 1.30/ROKS 4.15 and later)**
  * Understanding secure by default: [IKS](https://cloud.ibm.com/docs/containers?topic=containers-vpc-security-group-reference), [ROKS](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group-reference)
  * Managing outbound traffic protection: [IKS](https://cloud.ibm.com/docs/containers?topic=containers-sbd-allow-outbound), [ROKS](https://cloud.ibm.com/docs/openshift?topic=openshift-sbd-allow-outbound)
  * Handling quota errors: [IKS](https://cloud.ibm.com/docs/containers?topic=containers-ts-sbd-cluster-create-quota), [ROKS](https://cloud.ibm.com/docs/openshift?topic=openshift-ts-sbd-cluster-create-quota)
  * Applications no longer work: [IKS](https://cloud.ibm.com/docs/containers?topic=containers-ts-sbd-app-not-working), [ROKS](https://cloud.ibm.com/docs/openshift?topic=openshift-ts-sbd-app-not-working)
  * DNS resolver issues: [IKS](https://cloud.ibm.com/docs/containers?topic=containers-ts-sbd-custom-dns), [ROKS](https://cloud.ibm.com/docs/openshift?topic=openshift-ts-sbd-custom-dns)

**Legacy configuration (IKS 1.29/ROKS 4.14 or earlier)**
  * Understanding security groups: [IKS](https://cloud.ibm.com/docs/containers?topic=containers-vpc-security-group&interface=ui), [ROKS](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group&interface=ui)
