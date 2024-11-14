---
layout: default
title: Move cluster from one carrier to another
type: Informational
runbook-name: "Move cluster from one carrier to another"
description: "Move cluster from one carrier to another"
service: Conductors
link: /docs/runbooks/move_cluster.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Provides details on how to move a recently ordered cluster from one carrier to another

## Detailed Information

This runbook describes how to move a recently ordered from one carrier to another. This is NOT an appropriate process for moving already deployed clusters.

### Pre Reqs

1. Create a prod train
    Example: 
    
    ```
    Squad: SRE
    Service: Armada
    Title: Order test clusters in prod-dal10-carrier108
    Environment: us-south
    Details: follow this process here https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/README.MD#order-test-cluster-in-existing-zone
    Risk: low
    PlannedStartTime: now
    PlannedEndTime: now+4h
    Ops: true
    BackoutPlan: delete test clusters
    ```

### Move cluster

1. Create the cluster. [How to](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/sre-order-test-clusters.html)

1. Run [armada-tugboat-move-test-cluster](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-tugboat-move-test-cluster/).  If you do this immediately after the cluster is created there is a good chance that there will be no cleanup needed on the original target.

        CLUSTER_ID=test kubx cluster that you have just ordered
        HUB=must be hub in same region
        TARGET_CARRIER= this is the carrier you want to move your cluster to (use . to separate dc and carrier. ie prod-dal10.carrier100)
	
1. From #armada-xo run `@xo cluster $CLUSTER_ID` and check that ActualDataCenter now points to the new tugboat

### Check if cleanup is needed

1. Log into the original target cluster and check for any remnants.  You can find the original target by searching for `start_carrier` in the console output of the armada-tugboat-move-test-cluster Jenkins job.

```
	kubectl get all -A | grep CLUSTER_ID
```

### Check that cluster is ordered

1. log in to a worker in the closest HUB and invoke-tugboat and check that new cluster exists
```
	kubectl get po -A | grep CLUSTER_ID
```
1. check cluster status with:
```
        ic ks clusters | grep $CLUSTER_ID
        ic ks worker-pools -c $CLUSTER_ID
        ic ks workers -c $CLUSTER_ID
```
