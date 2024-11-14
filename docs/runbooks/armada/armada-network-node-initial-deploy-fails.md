---
layout: default
title: IKS/ROKS Node Deploy Fails Network Troubleshooting
runbook-name: "IKS/ROKS Node Deploy Fails Network Troubleshooting"
tags: network node deploy failure fail network troubleshooting critical
description: "IKS/ROKS Node Deploy Fails Network Troubleshooting"
service: armada-network
link: /armada/armada-network-node-initial-deploy-fails.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes the troubleshooting steps when a worker node fails to deploy and the error indicates it might be network related.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

The following sections describe different scenarios and how to troubleshoot each one

## Workers Are Failing to Deploy

1. If the VPC workers are reporting "Pending Endpoint Gateway Creation" for 40 minutes or more after the master has successfully deployed, follow the [Worker Stuck in Pending Endpoint Gateway Creation](./armada-network-pending-endpoint-gateway.html) runbook.

1. If cluster workers fail to deploy and are reporting the error "Worker unable to talk to IBM Cloud Kubernetes Service servers. Please verify your firewall setup is allowing traffic from this worker", then follow the following steps in order until the problem is resolved:
    * Follow the [IKS/ROKS Cluster Master Health Checks](./armada-master-health-checks.html) runbook
    * **(VPC Clusters Only)** Follow the [IKS/ROKS Cluster Master VPE Gateway Troubleshooting](./armada-network-vpe-gateway-troubleshooting.html) runbook
    * Follow the [IKS/ROKS Control Plane Network Troubleshooting](./armada-network-control-plane-network-troubleshooting.html) runbook
    * **(VPC Clusters Only)** Follow the [IKS/ROKS Check VPC Cluster Security Groups](./armada-network-check-cluster-security-groups.html) runbook
    * If no problems are found in those sections above, we should do two things:
         * Put the following in the ticket: `@support  Please tell the customer the following.  We have investigate this and do not see any issues with our control plane or your cluster master.  We recommend to check your firewall/gateway configuration, security groups, ACLs, custom routes, custom DNS, and anything else that might have a custom configuration or that might have changed in your account recently.  If you still can't find a problem with your configuration or account, please provide the following information: <Paste in the questions from https://github.ibm.com/ACS-PaaS-Core/MustGathers/blob/master/Kubernetes/Networking/networking.md>   <If the cluster has some normal workers, then also add the following, otherwise do not ask for this since it will just frustrate the customer since the debug tool will fail with no functioning workers> Also please deploy the the Diagnostics and Debug Tool (using https://cloud.ibm.com/docs/containers?topic=containers-debug-tool) and export the Network and Kube test results.`
         * Follow the [IKS/ROKS Retrieve and Analyze Bootstrap Logs](./armada-bootstrap-retrieve-analyze-bootstrap-logs.html) runbook to collect as much information as possible for the bootstrap and network teams

1. If workers are failing to provision with any other error, then refer to these docs to troubleshoot:
    * IKS: [https://cloud.ibm.com/docs/containers?topic=containers-common\_worker\_nodes\_issues](https://cloud.ibm.com/docs/containers?topic=containers-common_worker_nodes_issues)
    * ROKS: [https://cloud.ibm.com/docs/openshift?topic=openshift-common\_worker\_nodes\_issues](https://cloud.ibm.com/docs/openshift?topic=openshift-common_worker_nodes_issues)

## Escalation Policy

If the above steps don't resolve the issue, and the problem appears to be network related, use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

  * IKS: [IKS Common Worker Node Issues](https://cloud.ibm.com/docs/containers?topic=containers-common_worker_nodes_issues)
  * ROKS: [ROKS Common Worker Node Issues](https://cloud.ibm.com/docs/openshift?topic=openshift-common_worker_nodes_issues)
