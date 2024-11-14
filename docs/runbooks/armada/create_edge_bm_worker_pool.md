---
layout: default
description: General information for replacing edge pool with edge-bm
title: How to replace edge worker-pool with edge-bm
service: Conductors
runbook-name: "General information info for replacing edge pool with edge-bm"
tags:  armada, carrier, general, tugboat
link: /armada/create_new_worker_pool.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

General information for adding worker pools to tugboats

## Detailed Information

### Prepare scale up ghe

example: https://github.ibm.com/alchemy-conductors/new-environments/issues/1029

Note the similarity to a traditional scale up issue. The only difference here is that the current size is set to 0, and machine type must be defined

### Create edge-bm pool and workers

Run the jenkins job [create-edge-bm-workerpool](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/create-edge-bm-workerpool/)

1. `BRANCH`: master
1. `WORKER_INFO_BRANCH`: master
1. `CLUSTER_ID`: the cluster_id of the tugboat to target can find cluster_id here: https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/maps.json
1. `REGION`: one of us-south, br-sao, us-east, ca-tor, uk-south, eu-central, eu-fr2, ap-north, jp-osa, ap-south
1. `PIPELINE_ENV`: is one of dev, prestage, stage, prod. For performance, append the carrier hub number, for example stage2, stage5
1. `NEW_ENV_GITHUB_ISSUE`: needs to be the approved new-environments issue link from above
1. `CFS_TRAIN_ID`: leave blank

### Post job actions

1. The jenkins job will have tainted and labeled the new nodes appropriately. Now the old edge bm nodes must be cordoned:
   ```
   $ kubectl get nodes -l ibm-cloud.kubernetes.io/worker-pool-name=edge | awk '{print $1}' | xargs kubectl cordon 
   ```
1. After cordoning, drain the nodes zone by zone first checking ibm-cloud-provider pods
   ```
   $ kubectl get po -n ibm-system -o wide | grep ibm-cloud-provider
   $ armada-drain-node --reason "decomm edge vsi node" $NODE_IP   
   ```
1. Delete workers 1 zone at a time and again check the ibm-cloud-providers pods in between
   ```
   $ ibmcloud ks workers -c $CLUSTER_ID --worker-pool edge | grep $ZONE_1 | awk '{print $1}' | xargs -L1 ibmcloud ks worker rm -c $CLUSTER_ID -f -w
   ```
1. Once all workers are deleted, and ibm-cloud-providers are confirmed to be running still, delete the pool
   ```
   $ ibmcloud ks worker-pool rm -c $CLUSTER_ID --worker-pool edge
   ```
