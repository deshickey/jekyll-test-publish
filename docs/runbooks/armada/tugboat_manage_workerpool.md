---
layout: default
description: General information for managing tugboat worker pools
title: General info for managing tugboat worker pools
service: Conductors
runbook-name: "General information for managing tugboat worker pools"
tags:  armada, carrier, general, tugboat, worker-pool
link: /armada/manage_tugboat_workerpool.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

General information for managing tugboat worker-pools

## Pre Reqs

1. Create train for any changes. All pipeline level tugboat's masters live on prod legacy carriers
1. Connect to Global Protect vpn
1. Login to the ibmcloud infra account where the tugboat lives. See [here](../armada/armada-tugboats.html#access-the-tugboats) for details.

## Detailed Information

### Create new worker pool

1. Determine the ID of the cluster you wish to add a pool to and save as `$CLUSTER_ID`
1. Determine the name for your new pool and save as `POOL_NAME`
1. Determine how many workers per zone you wish to have in the new pool and save as `$SIZE_PER_ZONE`
1. Decide which zones to use `ibmcloud ks zones --provider classic` and save as `$ZONE[1-3]` (zone 2 and 3 are optional and only needed for MZRs)
1. Find desired flavor for new worker pool `ibmcloud ks flavors --zone $ZONE` and save as `$FLAVOR`
1. Create new worker-pool `ibmcloud ks worker-pool create classic --name $POOL_NAME --cluster $CLUSTER_ID --size-per-zone $SIZE_PER_ZONE --hardware dedicated --flavor $FLAVOR --label ibm-cloud.kubernetes.io/node-local-dns-enabled=true`
1. Decide which VLANS to use `ibmcloud ks vlans --zone $ZONE[1-3]`. Chose the vlans that the existing workers use. @netmax can give you this info. Save the `ID` column value as `$VLAN_PRIVATE_[1-3]` and `$VLAN_PUBLIC_[1-3]`
1. [Upgrade worker pool to RedHat](#upgrade-worker-pools-to-redhat)
1. Add zone to worker pool `ibmcloud ks zone add classic --cluster $CLUSTER_ID --worker-pool $POOL_NAME --private-vlan $VLAN_PRIVATE_[1-3] --public-vlan $VLAN_PUBLIC_[1-3] --zone $ZONE[1-3]`
1. Nodes should now begin to provision for your new worker pool

### Upgrade worker pools to RedHat

All IKS worker-pools default to Ubuntu. There is an issue [here](https://github.ibm.com/alchemy-containers/armada-ironsides/issues/6571) to allow for Red Hat specification, but for the time being we use the following process as a workaround:

1. run the following job https://www.jajaldoang.com/post/how-to-update-golang/, After first updating the following params:
`CLUSTER_ID` Cluster ID to update
`CARRIER_NAME` Chose hub in same region as tugboat masters are in

This job will scan the cluster for all worker-pools attached to it, then update each pools to the RedHat OS. Any new workers provisioned in these pools, and any workers that are replaced, will be provisioned as RedHat. See [ibmcloud_replace_worker](../ibmcloud_replace_worker.html) for how to replace tugboat workers.

### Change flavor for existing worker pool
Changing the flavor of a worker-pool is not supported on IKS or ROKS, so if desired, must be done via `armada-data`

#### Automation

1. go to [armada-tugboat-change-wp-flavor](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-tugboat-change-wp-flavor/)
1. Find cluster id, set as `CLUSTER_ID`
1. Find worker-pool id to update and save as `POOL_ID`
1. Find a zone that the worker pool is in `ibmcloud ks worker-pool get -c $CLUSTER_ID --worker-pool $POOL_ID` and save as `$ZONE`
1. Find flavor you would like to update to `ibmcloud ks flavors --zone $ZONE` and set as `FLAVOR`
1. Run job

#### Manual

1. Find cluster id, save as `$CLUSTER_ID`
1. Find worker-pool id to update and save as `$POOL_ID`
1. Find a zone that the worker pool is in `ibmcloud worker-pool get -c $CLUSTER_ID --worker-pool $POOL_ID` and save as `$ZONE`
1. Find flavor you would like to update to `ibmcloud ks flavors --zone $ZONE`
1. Login to a master for one of the hubs that is in the same region as the tugboat. Hubs for each region can be found on [alchemy-dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier)
1. Set new flavor `armada-data set WorkerPool -field Flavor -value "$FLAVOR.encrypted" -pathvar ClusterID="$CLUSTER_ID" -pathvar ID="$POOL_ID"`

#### Common steps
1. After completing one of the above processes, ensure the worker pool is now set to desired flavor `armada-data get WorkerPool -pathvar ClusterID="$CLUSTER_ID" -pathvar ID="$POOL_ID" -field Flavor`
1. Find workers that need to be updated `ibmcloud ks worker-pool get -c $CLUSTER_ID --worker-pool $POOL_ID`
1. Replace each worker one at a time `ibmcloud ks worker replace -c $CLUSTER_ID -w $WORKER_ID`
