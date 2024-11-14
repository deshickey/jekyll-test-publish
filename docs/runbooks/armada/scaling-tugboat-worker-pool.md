---
layout: default
description: Procedure for scaling tugboat worker pool
title: Scaling tugboat worker pool
runbook-name: "Procedure for scaling tugboat worker pool"
tags: tugboat scale scaling
link: /scaling-tugboat-worker-pool.html
type: Informational
service: Conductors
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook includes information on how to order scale tugboat worker-pools in pre-prod and prod

## Purpose

This runbook describes how to scale a tugboat worker pool

## Detailed Information

## Scaling the worker pool:
1. Prepare an approved new-environments issue following the tugboat scale parameters issue template [here](https://github.ibm.com/alchemy-conductors/new-environments/issues/new/choose).
    
   - `ClusterName` and `ClusterCreateIssue` are mandatory fields.
   - `ClusterName` is the name of the tugboat found in the alert e.g. prod-dal10-carrier100
   - `ClusterCreateIssue` can be found in the closed issues: [https://github.ibm.com/alchemy-conductors/new-environments/issues?q=is%3Aissue+is%3Aclosed](https://github.ibm.com/alchemy-conductors/new-environments/issues?q=is%3Aissue+is%3Aclosed)
      - The `ClusterCreateIssue` contains all of the creation parameters used to create the tugboat.  e.g. [https://github.ibm.com/alchemy-conductors/new-environments/issues/79](https://github.ibm.com/alchemy-conductors/new-environments/issues/79)

   - `Type` MZR or SZR
   - At least one worker pool you want resized is necessary. List the current size and the desired size. Worker pools can be found in the cluster create issue as well as the most recent scaling issue.  You can also use ibmcloud CLI to get the current worker-pool size.  Details on logging into ibmcloud can be found [here](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/README.MD#deploying)
    
   You can find the current size information by running one of the following commands (check [maps.json](https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/maps.json) to find the cluster_id):
        
   ```
   "ic ks worker-pools -c prod-us-south-carrier100"
   OR
   "ic ks worker-pools -c bkp1imtd0ojc71qrifr0"
   
   Name                   ID                             Flavor                Workers
   customer-workload      bkp1imtd0ojc71qrifr0-0881c9c   b3c.16x64.encrypted   80 
   dedicated-armada       bkp1imtd0ojc71qrifr0-0ec0a5d   b3c.8x32.encrypted    1
   edge                   bkp1imtd0ojc71qrifr0-3f8e934   b3c.8x32.encrypted    2
   dedicated-prometheus   bkp1imtd0ojc71qrifr0-91251d3   b3c.16x64.encrypted   1
   kube-resources         bkp1imtd0ojc71qrifr0-b66260d   b3c.8x32.encrypted    1
   ```

   If adding any extra information to the issue, it must follow the following format:  
   `AdditionalNotes: "<extra information>"`. Quotes around the extra information is mandatory.

   At a minimum, please add the PD alert URL that brought you to this runbook.

   Example scale up issue:

   ```
    Type: MZR

    WorkerPools:
      - name: customer-workload
        machineType: b3c.16x64.encrypted
        workersPerZone: 40

    CurrentWorkerPools:
      - name: customer-workload
        machineType: b3c.16x64.encrypted
        workersPerZone: 32


    ClusterName: prodfr2-par04-carrier101

    ClusterCreateIssue: https://github.ibm.com/alchemy-conductors/new-environments/issues/409

    AdditionalNotes: "https://github.ibm.com/alchemy-conductors/team/issues/20300"
   ```
               
1. Add the `LEADS_APPROVAL_NEEDED` label and get a lead's approval before scaling the tugboat.
                
2. Create an Ops train if the tugboat is in the prod env.

   Example Ops train:

   ```
   Squad: sre
   Service: Armada
   Title: scale prod-dal10-carrier100
   Environment: us-south
   Details: Deploy MZR Tugboat in dal10 https://github.ibm.com/alchemy-conductors/new-environments/issues/556
   Risk: low
   Ops: true
   OutageDuration: 0s
   OutageReason: none
   PlannedStartTime: now
   PlannedEndTime: now +30m
   BackoutPlan: cordon nodes
   ```
    
3. Run the jenkins job [bootstrap-minimal-tugboat](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/bootstrap-minimal-tugboat/)
    - `CLUSTER_ID` is the cluster_id of the tugboat to target; can find the cluster_id here: [https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/maps.json](https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/maps.json)
    - `REGION` is one of `us-south`, `us-east`, `uk-south`, `eu-central`, `eu-fr2`, `ap-north`, `ap-south`
    - `PIPELINE_ENV` is one of `dev`, `prestage`, `stage`, `prod`. For performance it will be the carrier hub number, for example `stage2`, `stage5`
    - `KUBE_VERSION` leave blank unless using other than the default
    - `CUSTOM_PLAYBOOK` use the playbook `resize_workerpool.yaml`
    - `NEW_ENV_GITHUB_ISSUE` needs to be the approved new-environments issue link from above
    - `CFS_TRAIN_ID` is the train ID

4. The Jenkins job will add updates to the scale up issue as it progresses, and will resolve the GHE once successfully completed.  
   - There is a possibility of the resize job failing due to IaaS or firewall issues.  If this occurs, the resize job will need to be re-run once the issue has been resolved.
   - For example, if this is seen in the jenkins output then there is insufficient capacity in SoftLayer: `FAILED - RETRYING: wait for all workers to be up (1 retries left)`

