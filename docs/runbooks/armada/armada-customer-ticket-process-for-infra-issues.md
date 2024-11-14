---
layout: default
title: Customer Ticket Process for IBM Cloud Infrastructure Issues
runbook-name: "Customer Ticket Process for IBM Cloud Infrastructure Issues"
tags: customer ticket infrastructure process
description: "Customer Ticket Process for IBM Cloud Infrastructure Issues"
service: armada
link: /armada/armada-customer-ticket-process-for-infra-issues.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes the process to follow when IKS/ROKS SREs or developers have worked on an IKS/ROKS customer ticket and think that it is a problem with the cloud infrastructure.  This process describes how to request that someone on those teams investigate the problem.

## Detailed Information

### For Classic Clusters

1. Add as much information to the GHE ticket as you can about what you have done to troubleshoot and your results.  Also include as much of the following information as possible:
    * Region and Zone(s) the cluster has affected workers in
    * Private VLAN and IP, public VLAN and IP (if the node is connected to a public VLAN), zone, and worker-id of the affected workers (can get all of this from get-master-info's "describe node" output)
    * Detailed description of the problem.  If it is a network connection issue, include as much of the following as you can:
        * Source and destination of the network connection that is failing, including the IP(s) and port of destination if possible
        * Exact error message that is being seen
        * Whether the problem is intermittent, or happens all the time
        * Instructions on how to recreate if possible
    * A note that describes how the cloud infrastructure teams can request more information.
        * For instance, if the IKS/ROKS network team looked into the ticket and is requesting help, include something like: "If you need more information from the IKS/ROKS network teams, post a request in the `#armada-network` slack channel and tag `@network`, and mention it is in reference to GHE ticket https://github.ibm.com/alchemy-containers/customer-tickets/issues/XXXXX" (with XXXXX replaced with the GHE issue number).
2. Ask in the GHE ticket that the ACS team transfer the ticket to a classic IaaS network team for further triage.

### For VPC Clusters

1. Add as much information to the GHE ticket as you can about what you have done to troubleshoot and your results.  Also include as much of the following information as possible:
    * Region and Zone(s) the cluster has affected workers in
    * Hostname, private IP, zone, and instance-id of the affected workers (can get from get-master-info's "describe node" output)
    * The VPC Subnet ID and VPC ID
        * You can get the VPC Subnet ID from get-master-info's "describe node" output
        * You can get the VPC ID by first getting the worker-pool-id from "describe node", then use `@xo workerPool <worker-pool-id>` to get the VPC ID of that worker pool
    * If it is a VPC LBaaS problem, the LBaaS ID and name (can get that either from IKS Debug Tool, or maybe get-master-info soon)
    * If the VPE Gateway is the suspected problem, then provide the VPE Gateway ID and name (can get it from the network microservice logs from cluster create time)
    * Detailed description of the problem.  If it is a network connection issue, include as much of the following as you can:
        * Source and destination of the network connection that is failing, including the IP(s) and port of destination if possible
        * Exact error message that is being seen
        * Whether the problem is intermittent, or happens all the time
        * Instructions on how to recreate if possible
    * A note that describes how the cloud infrastructure teams can request more information.
        * For instance, if the IKS/ROKS network team looked into the ticket and is requesting help, include something like: "If you need more information from the IKS/ROKS network teams, post a request in the `#armada-network` slack channel and tag `@network`, and mention it is in reference to GHE ticket https://github.ibm.com/alchemy-containers/customer-tickets/issues/XXXXX" (with XXXXX replaced with the GHE issue number).
2. Ask in the GHE ticket that it be transferred to the ACS-VPC team for further triage.  See https://github.ibm.com/alchemy-containers/customer-tickets/issues/11933 for an example of this.

### Make Sure to Keep the GHE Ticket Up To Date

If the infrastructure team(s) that look at the problems have questions, and/or if you work with those teams via slack, WebEx, etc, make sure to document what was done in the GHE ticket.  This way the next person to work on the ticket can see what was done and not have to repeat things that were already done.

### Reaching the IBM Cloud Infrastucture SRE's Directly

In the case of a Severity 1 customer issue or CIE and the IaaS SRE team needs to be engaged quickly, we can reach out to them in Slack directly with the case details:

For WorldWide IaaS SRE's:
[#sl-compute-sre](https://ibm-cloudplatform.slack.com/archives/C5WRPN2HE)
For Dedicated eu-fr2 IaaS SRE's:
[#sl-compute-sre-bnpp](https://ibm-cloudplatform.slack.com/archives/C016TA21P5X)

## Further Information
Please contact Brad Behle or Lewis Evans if you have questions or feedback about this process
