---
layout: default
description: Procedure for creating barge worker pool
title: Creating barge worker pool
runbook-name: "Procedure for creating barge worker pool"
tags: barge create creating
link: /barge_worker_pool_create.html
type: Informational
service: Conductors
parent: Barge
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook includes information on how to create barge worker-pools in pre-prod and prod

## Purpose

This runbook describes how to create barge worker pools. If you need to scale an existing worker pool, refer to [barge scale worker pool](barge_worker_pool_scale.html) runbook.

## Detailed Information

1. Prepare a new-environments issue following the barge worker-pool create parameters issue template [here](https://github.ibm.com/alchemy-conductors/new-environments/issues/new?assignees=&labels=LEADS_APPROVAL_NEEDED&projects=&template=barge-worker-pool-create.md&title=Barge+%3Cname%3E+create+worker-pool)
   - `BargeName` and `TotalDesiredWorkers` are mandatory fields.
   - At least one worker pool you want to create is necessary.

   Example worker-pool create issue:

   ```
   TotalDesiredWorkers: 33
   BargeName: dev-us-east-barge-microservice-101
   WorkerPools:
   - name: hypershift
     machineType: bx2-16x64
     workersPerZone: 6
   - name: dedicated-prometheus
     machineType: bx2-16x64
     workersPerZone: 0
   - name: dedicated-edge
     machineType: bx2-8x32
     workersPerZone: 2
   - name: dedicated-armada
     machineType: bx2-8x32
     workersPerZone: 2
   - name: generic
     machineType: cx2-16x32
     workersPerZone: 1
   ```

1. `LEADS_APPROVAL_NEEDED` label should be added to the issue, add label if not done automatically. 
1. Seek approval from leads and get issue approved.
1. Create an ops train if barge is in the prod env.

   Example ops train:

   ```
   Squad: sre
   Service: Armada
   Title: Create worker-pools on barge <barge name>
   Environment: us-south
   Details: Create barge worker pools https://github.ibm.com/alchemy-conductors/new-environments/issues/<issue number>
   Risk: low
   Ops: true
   OutageDuration: 0s
   OutageReason: none
   PlannedStartTime: now
   PlannedEndTime: now +30m
   BackoutPlan: cordon nodes
   ```

1. Run the jenkins job [barge-worker-pool-automation](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/barge-worker-pool-automation/)
   - `BRANCH` is the branch to build the job from. Leave this to `main` unless you are testing your PR.
   - `ARMADA_REGION` is the armada region where barge is deployed.
   - `BARGE_NAME` is barge name.
   - `VPC_PREFIX` is prefix of VPC where barge is deployed.
   - `GITHUB_ISSUE` is the approved issue raised earlier above.

1. The Jenkins job will add updates to the scale up issue as it progresses, and will resolve the GHE once successfully completed.
