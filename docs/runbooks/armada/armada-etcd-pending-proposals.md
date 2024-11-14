---
layout: default
description: How to resolve high pending or failed proposals for etcd
title: armada-etcd - how to resolve high pending or failed proposals
service: armada-etcd
runbook-name: "armada-etcd - high pending or failed proposals"
tags: alchemy, armada, etcd, leader, proposals
link: /armada/armada-etcd-pending-proposals.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

This runbook describes how to handle a high number of pending or failed proposals for etcd.

## Detailed Information

High pending or failed proposals for the etcd cluster indicate the etcd cluster is having trouble keeping up with the load.
This could indicate the etcd cluster has excessive load on it caused by microservice clients or the etcd cluster leader is
unhealthy.

Example Alerts:

`ArmadaEtcdHighPendingProposals`
`ArmadaEtcdHighFailedProposals`

## Gathering ETCD Information

1. Run the [Get ETCD Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-info/build?delay=0sec) for the region.

- Review the job log for ETCD cluster or pod issues.

1. Bring up the `Microservice Etcd Metrics v2` Grafana dashboard for the region.

- Check the `Summary` view to see the `Microservice Etcd response times (non-crawler)` top panel, the response times should be below 1 second, if it is above that, need to use [escalation policy](#escalation-policy).

1. Bring up the `Carrier ETCD` Grafana dashboard for the region.

- Check the Carrier ETCD `Proposals pending` view (on left half way down), the counts should be below 100, if it is above that, need to use one of the following tasks:

  - Move the existing leader to another member:
    [Detailed Procedure to move the leader](#detailed-procedure-to-move-the-leader) below.
  - Restart all the etcd pods, leader last:
    [Detailed Procedure to restart etcd pods](#detailed-procedure-to-restart-etcd-pods) below.

## Detailed Procedure to move the leader

1. Use [escalation policy](#escalation-policy) below to page out the Ballast squad to help monitor this process.
1. Use the [etcd move leader jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-move-leader/build?delay=0sec) to move the etcd leader to another member.

- A Prod train is required to run the job
- Parameters
  - `Branch` = master
  - `ENV Branch` = master
  - `ARMADA_ETCD_REGION` = the region where issue is happening
  - `PROD_TRAIN_REQUEST_ID` = Prod train number
  - `FORCE` = NOT CHECKED, only needed when cluster has less then 5 members

## Detailed Procedure to restart etcd pods

1. Use [escalation policy](#escalation-policy) below to page out the Ballast squad to help monitor this process.
1. Use the [etcd pod restart jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-pod-restart/build?delay=0sec) to restart the etcd cluster pods in the region.

- A Prod train is required to run the job
- Parameters
  - `Branch` = master
  - `ENV Branch` = master
  - `ARMADA_ETCD_REGION` = the region where issue is happening
  - `PROD_TRAIN_REQUEST_ID` = Prod train number
  - `RESTART_ETCD_PODS` = Checked
  - `FORCE_RESTART_ETCD_PODS` = NOT CHECKED
  - `RESTART_ETCD_OPERATORS` = NOT CHECKED

## Escalation Policy

Reach out to the @ballast handle in #armada-ballast or escalate to [Alchemy - Containers Tribe - Ballast](https://ibm.pagerduty.com/schedules#PP1MP9Q)
