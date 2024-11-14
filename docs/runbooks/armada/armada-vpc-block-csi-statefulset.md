---
layout: default
description: Understand why my controller pod is in Terminating state on a NotReady node
title:  armada-vpc-block-csi - Understand why my controller pod is in Terminating state on a NotReady node
service: armada-storage
category: vpc-block-csi-driver
runbook-name: "Understand why my controller pod is in Terminating state on a NotReady node"
tags: alchemy, armada, kubernetes, kube, kubectl, vpc-block-csi-driver, block-storage, block
link: /armada/armada-vpc-block-csi-statefulset.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes why controller pod remains in Terminating state when worker node is shut down or NotReady.

## Example Alert(s)
None


## Non graceful node shutdown and statefulset

vpc-block-csi-driver has controller and node driver pods. Controller pod is deployed as Statefulset and node driver pods are deployed as Daemonset. Unlike Deployment Sets, when a node fails, Stateful sets do not create a new set of replica to be scheduled on available nodes. Hence whenever your worker node where controller pod is deployed becomes NotReady, controller pod will move to 'Terminating' state but will not be evicted from the node and no new pods come up on healthy nodes.

Please refer below documents to understand recovery steps.

## Investigation and Action
 
- [Force Delete StatefulSet Pods](https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/)
- [Non graceful node shutdown](https://github.com/kubernetes/enhancements/tree/master/keps/sig-storage/2268-non-graceful-shutdown)


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
