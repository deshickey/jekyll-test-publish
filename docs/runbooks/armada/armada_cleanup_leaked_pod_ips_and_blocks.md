---
layout: default
title: Cleanup leaked Pod IPs/Blocks
type: Troubleshooting
runbook-name: Cleanup leaked Pod IPs/Blocks
description: Cleanup leaked Pod IPs/Blocks
service: armada
link: /armada/armada-cleanup-leaked-pod-ips-and-blocks.html
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview (Required)

This runbook describes the steps to build [jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-calico-ipam-cleanup/) with specific paramerters to cleanup leaked IPs/Blocks on customer clusters.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

If the container won't start or is stuck in `ContainerCreating` state due to any IP address related messges, your containers might not start because the IP Address Manager (IPAM) for the Calico plug-in incorrectly detects that all pod IP addresses in the cluster are in use. Because the Calico IPAM detects no available IP addresses, it does not assign IP addresses to new pods in the cluster, and pods can't start. Please check the [Why don't my containers start?](https://cloud.ibm.com/docs/containers?topic=containers-ts-app-container-start#regitry-quota) doc for more information.

Run this [jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-calico-ipam-cleanup/) with the parameters specified below to fix IP address issues with a cluster. For example, if the individual worker has run out of pod IPs or full free IP blocks. To run this we need to have the customer's permission.

### Jenkins Job Build Parameters

#### CLUSTER

Customer Cluster ID

#### CLUSTER_REGION

Region the cluster is in

#### PROD_TRAIN_REQUEST_ID:

Approved prod train number

#### SAFETY_OFF

Check this (just indicates we are doing something more than read-only commands)

#### REALEASE_IPS 

Check this to indicate you want to clean up all individual pod IPs that are no longer in use (leaked)

#### REALEASE_BLOCKS

Check this to indicate you want to clean up any empty full pod IP blocks (CIDR)

### Additional Troubleshooting

If the job fails with the parameters specified above, make sure to run it again. If it fails again, then run it a third time with the following changes:

#### REALEASE_IPS

Uncheck this

#### REALEASE_BLOCKS

Uncheck this

#### UNLOCK_DATASTORE

Check this (to ensure the calico datastore is unlocked)

This will at least ensure that the Calico datastore is unlocked so pods can be created (unless of course the underlying problem is also preventing pods from being created).

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