---
layout: default
description: Tainting and labelling carrier workers for customer or tugboat clusters
title: How to taint and label carrier workers for customer or tugboat clusters
service: armada-conductors
runbook-name: "How to taint and label carrier workers for customer or tugboat clusters"
tags: alchemy, armada, kubernetes, armada-deploy
link: /armada/armada-taint-and-label-worker.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

How to taint and label carrier workers for customer or tugboat clusters

## Detailed Information

Create an Ops train if the tugboat is in the prod env.

Example Ops train:
```
Squad: SRE
Title: cordon/drain/taint new workers for <cluster name> cluster
Environment: us-south
Details: https://github.ibm.com/alchemy-conductors/team/issues/1234
Risk: low
PlannedStartTime: now
PlannedEndTime: now+60m
Ops: true
BackoutPlan: Further restorative actions with SRE
```

Jenkins Job:

Run [armada-taint-label-worker](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-taint-label-worker/)

The Jenkins job will:
  - cordon and drain 
  - taint and label 
  - uncordon workers
  - restart the masters
  
The etcd pods will need to be manually restarted.  This needs to be done one pod at a time.  
**NEVER** delete an etcd pod until the previously deleted pod is up and running.   

BRANCH master  
ENV_BRANCH master  
CLUSTER_ID cluster id to be used  
NODE_IPS 6 node ips, space delimited (job requires 6 ips)  
CARRIER_NAME Hub in same region as your cluster (ex: prod-dal10-carrier2) 

Manual instructions:

To manually taint a carrier worker node for a specific cluster, set the NODE and CLUSTER:

Export the IP and cluster id:

export NODE=192.168.10.3  
export CLUSTER=cruiser1

Apply the taint and label to the node:

kubectl taint nodes --overwrite ${NODE} dedicated=master-${CLUSTER}:NoSchedule  
kubectl label nodes --overwrite ${NODE} dedicated=master-${CLUSTER}
