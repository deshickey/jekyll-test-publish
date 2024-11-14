---
layout: default
description: How to reorder a tugboat node
title: How to reorder a tugboat node
service: armada-infra
runbook-name: "How to reorder a tugboat node"
tags:  armada, carrier, reorder, tugboat
link: /armada/armada-tugboats-reorder-node.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This information runbook explains how to reorder a tugboat node

## Detailed Information

### Setup

1. Raise prod train:
```
Squad: armada-infra
Title: delete then rebalance faulty worker node in <<CARRIER>>
Environment: <<REGION>>
Details:  Pd alert, ghe issues, etc..
Risk: low
Ops: true
OutageDuration: 0s
OutageReason: none
PlannedStartTime:  now
PlannedEndTime: now + 20m
BackoutPlan: add new node
```

1. DM @netmax the ip of the worker node you wish to reorder. He will tell you the account it lives in.

1. Login to the account using appropriate creds found here: https://pim.sos.ibm.com
```
$ ibmcloud login --apikey $APIKEY
```

1. Find the target cluster.
```
$ ibmcloud ks clusters
$ export $CLUSTER_ID=<<CLUSTER_ID>>
```

1. Find the node to cancel.
```
$ ibmcloud ks workers --cluster $CLUSTER_ID | grep critical
kube-bknls91t0bjak3uaisag-prodapnorth-custome-0000580d   161.202.232.206   10.129.78.46    b3c.16x64.encrypted   critical   Unknown   tok02   1.15.4_1518*
$ export WORKER_ID=kube-bknls91t0bjak3uaisag-prodapnorth-custome-0000580d
```

1. Find the worker-pool that the node is in.
```
$ POOL_ID=$(ibmcloud ks worker-get $WORKER_ID --cluster $CLUSTER_ID | grep "Pool ID" | awk '{print $3}')
$ echo $POOL_ID
bknls91t0bjak3uaisag-dd39e44
```


### Method 1 Cancel Then Rebalance

note: Since we are canceling the node then rebalancing we may end up getting the same VSI we just canceled. If you are ok with potentially getting the same vsi, proceed with Method 1. If you want to ensure that you get a new vsi, proceed to [method 2](./armada-tugboats-reorder-node.html#method-2-scale-up-cancel-then-scale-down)

1. Cancel the worker.
```
$ ibmcloud ks worker-rm --workers $WORKER_ID --cluster $CLUSTER_ID
Remove worker? [kube-bknls91t0bjak3uaisag-prodapnorth-custome-0000580d] [y/N]> y
Removing worker kube-bknls91t0bjak3uaisag-prodapnorth-custome-0000580d...
OK
```

1. Rebalance the worker pool.
```
$ ibmcloud ks worker-pool rebalance --worker-pool $POOL_ID --cluster $CLUSTER_ID
Rebalancing pool bknls91t0bjak3uaisag-dd39e44 in cluster prod-ap-north-carrier100...
OK
```
note: you do not need to wait until worker is deleted to execute the rebalance cmd

### Method 2 Scale Up, Cancel, then Scale Down

1. Follow instructions [here](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/README.MD#scaling-the-worker-pool) to increase the worker-pool capacity by 1.

1. Cancel the worker.
```
$ ibmcloud ks worker-rm --workers $WORKER_ID --cluster $CLUSTER_ID
Remove worker? [kube-bknls91t0bjak3uaisag-prodapnorth-custome-0000580d] [y/N]> y
Removing worker kube-bknls91t0bjak3uaisag-prodapnorth-custome-0000580d...
OK
```

1. Follow instructions [here](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/README.MD#scaling-the-worker-pool) to decrease the worker-pool capacity by 1. This will return worker-pool to original capacity.

## Escalation Policy

oncall in #conductors
