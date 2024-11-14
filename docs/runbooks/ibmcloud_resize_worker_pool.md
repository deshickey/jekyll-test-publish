---
layout: default
title: Change flavor for existing worker pool
type: Informational
runbook-name: "Change flavor for existing worker pool"
description: Instructions to change flavor for existing worker pool
category: armada
service: sre_operations
link: /ibmcloud_change_flavor_worker_pool.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes the process of change flavor for existing worker pool by deleting and recreate new worker-pool and approvel required by Ralph for this process. Note: This is only an acceptable process for pre-prod or pre-live tugboats.
## Pre Reqs
1.  Create train for any changes using templates.
      ~~~shell
      Squad: SRE
      Service: Armada
      Title: scale <tugboat name>
      Environment: <region name>
      Details: <GHE link>
      Risk: low
      Ops: true
      OutageDuration: 0s
      OutageReason: none
      PlannedStartTime: now
      PlannedEndTime: now +2h
      BackoutPlan: none
      ~~~

## Detailed Information
1. Find the tugboat creation parameters ticket. Search "$CARRIER_NAME Creation Parameters" in  [new-environments](https://github.ibm.com/alchemy-conductors/new-environments/issues/) issues. We required tugboat zone names, private and public VLAN e.g. [stage-dal10-carrier500](https://github.ibm.com/alchemy-conductors/new-environments/issues/111) creation parameters. The example of dedicated-prometheus worker pool flavor changed in this [ticket](https://github.ibm.com/alchemy-conductors/team/issues/17071).

1. Log into the associated IBM Cloud account
`ibmcloud login --sso`

1. Target the correct region
`ibmcloud target -r <region>`
_e.g. `ibmcloud target -r us-south`_

1. Identifiy the current size of worker pools of cluster
`ibmcloud ks worker-pools -c $CLUSTER`

   ~~~shell
   ➜ ibmcloud ks worker-pools -c <cluster id>
   OK
   Name                   ID                             Flavor                 Workers
   dedicated-armada       bli1u4od0huivb8tgos0-0eec926   b3c.8x32.encrypted     1
   customer-workload      bli1u4od0huivb8tgos0-5d89373   b3c.16x64.encrypted    45
   dedicated-prometheus   bli1u4od0huivb8tgos0-7183302   b3c.16x64.encrypted    1
   edge                   bli1u4od0huivb8tgos0-e1ac305   mb3c.16x64.encrypted   2
   kube-resources         bli1u4od0huivb8tgos0-f5f34fb   b3c.8x32.encrypted     1
   ~~~

1. IKS does not support resizing/change flavor of worker-pools post creation without removing existing one. Select which worker pool requireed to change the flavor. Remove the required worker pool and create new worker pool withe same name and desired flavor.
   ~~~shell
   ➜ ibmcloud ks worker-pool rm -c $CLUSTER --worker-pool dedicated-prometheus

   Remove worker pool dedicated-prometheus? [y/N]> y
   OK

   ~ took 6s
   ~~~

1. Verify the worker pool has been removed.
   ~~~shell
   ➜ ibmcloud ks worker-pools -c $CLUSTER
   OK
   Name                ID                             Flavor                 Workers
   dedicated-armada    bli1u4od0huivb8tgos0-0eec926   b3c.8x32.encrypted     1
   customer-workload   bli1u4od0huivb8tgos0-5d89373   b3c.16x64.encrypted    45
   edge                bli1u4od0huivb8tgos0-e1ac305   mb3c.16x64.encrypted   2
   kube-resources      bli1u4od0huivb8tgos0-f5f34fb   b3c.8x32.encrypted     1

   ~ took 3s
   ~~~

1. Create dedicated worker pool with desired flavor.
   `ibmcloud ks worker-pool create classic --hardware dedicated --name <item.name> --machine-type <item.machine> --cluster <CLUSTER_NAME> --size-per-zone <item.size> --label ibm-cloud.kubernetes.io/node-local-dns-enabled=true`

   item.name is the worker-pools name, item.size is the worker size per zone and item.machine is type of flavors given in the ticket can be get all flavors list.
   ~~~shell
   ibmcloud ks flavors --zone <zone>
   ~~~

   example:
   ~~~shell
   ➜ ibmcloud ks worker-pool create classic --hardware dedicated --name dedicated-prometheus --machine-type b3c.32x128 --cluster stage5-us-south-carrier500 --size-per-zone 1 --label ibm-cloud.kubernetes.io/node-local-dns-enabled=true
   OK

   ~ took 10s
   ~~~

1. If you get  error the same name already exists while creating new worker pool logout the ibmcloud and login back to ibmcloud account.
   ~~~shell
   ➜ ibmcloud ks worker-pool create classic --hardware dedicated --name dedicated-prometheus --machine-type b3c.32x128 --cluster stage5-us-south-carrier500 --size-per-zone 1 --label ibm-cloud.kubernetes.io/node-local-dns-enabled=true
   FAILED
    A worker pool with the same name already exists within the cluster. Choose another name. (E0d39)

   Incident ID: dcede6ee-4046-40c2-bf8a-d1f0a7676d0d


   ~ took 3s
   ~~~

1. Add each zones to workerpools, private, public VLAN and zone name where found in the tugboat creation parameters ticket.
`ibmcloud ks zone add classic --cluster <CLUSTER_NAME> --worker-pool <item.name> --private-vlan <item.private> --public-vlan <item.public> --zone <item.zone>`
   ~~~shell
   ➜ ibmcloud ks zone add classic --cluster stage5-us-south-carrier500 --worker-pool dedicated-prometheus --private-vlan 2684262 --public-vlan 2684260 --zone dal10
   OK

   ~ took 9s
   ➜ ibmcloud ks zone add classic --cluster stage5-us-south-carrier500 --worker-pool dedicated-prometheus --private-vlan 2684266 --public-vlan 2684264 --zone dal12
   OK

   ~ took 10s
   ➜ ibmcloud ks zone add classic --cluster stage5-us-south-carrier500 --worker-pool dedicated-prometheus --private-vlan 2684270 --public-vlan 2684268 --zone dal13

   OK

   ~ took 5s
   ➜
      ~~~

1. Verify the new worker pool is created, it will take few minutes to nodes become available.

   ~~~shell
   ➜ ibmcloud ks worker-pools -c $CLUSTER
   OK
   Name                   ID                             Flavor                 Workers
   dedicated-armada       bli1u4od0huivb8tgos0-0eec926   b3c.8x32.encrypted     1
   customer-workload      bli1u4od0huivb8tgos0-5d89373   b3c.16x64.encrypted    45
   edge                   bli1u4od0huivb8tgos0-e1ac305   mb3c.16x64.encrypted   2
   dedicated-prometheus   bli1u4od0huivb8tgos0-e41d803   b3c.32x128.encrypted   1
   kube-resources         bli1u4od0huivb8tgos0-f5f34fb   b3c.8x32.encrypted     1

   ~ took 2s
   ~~~

1. Verify the pods are running on new worker pools nodes.
`ibmcloud ks cluster config -c <cluster_name_or_ID>`
   ~~~shell
   ibmcloud ks cluster config -c $CLUSTER
   OK
   The configuration for bli1u4od0huivb8tgos0 was downloaded successfully.
   ~~~
   ~~~shell
   kubectl get pods -n monitoring -o=wide | grep prom
   armada-ops-prometheus-0                                     1/1     Running     0          25m     172.18.190.65    10.74.176.250    <none>           <none>
   armada-ops-prometheus-1                                     1/1     Running     0          31m     172.18.16.201    10.209.135.115   <none>           <none>
   armada-ops-prometheus-2                                     1/1     Running     0          25m     172.18.59.156    10.94.119.77     <none>           <none>
   ~~~