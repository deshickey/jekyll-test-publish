---
layout: default
description: Actions to take when tugboat resource limits are being reached.
title: armada-infra - Actions to take when tugboat resource limits are being reached.
service: armada
runbook-name: "armada-infra - Actions to take when tugboat resource limits are being reached"
tags: alchemy, armada, disk, CPU, resource limits
link: /armada/armada-infra-tugboat-resource-limits.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to handle both warning and critical alerts for approaching resource limits for a tugboat.

## Example Alerts

### Critical alerts which would have brought you here are:

These will trigger if a limit is exceeded for over 1 hour.

- `reached_master_pod_cluster_limit_tugboat`

### Warning alerts that would have brought you here are:

These will trigger if we exceed this limit but do not exceed the critical limits.

- `approaching_master_pod_cluster_limit_tugboat`

## Actions to take

Follow one of the below options to alleviate the load on the tugboat(s) that is alerting

### Scale existing tugboats

All same type, same DC tugboats, that are live should be the same size. This is so that the loadbalancer can properly balance deploys amongst all available tugboats. The max size for the ROKS customer-workload pool is 116 per zone. The max size for the IKS customer-workload pool is 85. For SZR and MZR clusters the limits are the same, except there are 3 pools to update (customer-workload-a, customer-workload-b, customer-workload-c) for SZRs.

The customer-workload pools should all be the same size. e.g. The following are a few of the MZR ROKS clusters in `us-south`
```
$ ibmcloud ks worker-pools -c prod-us-south-o-carrier114 | grep customer
customer-workload      bsor74dd05ivbo29rpgg-4f2ee99   b3c.16x64.encrypted   116
$ ibmcloud ks worker-pools -c prod-us-south-o-carrier115 | grep customer
customer-workload      btpslnod0b4c2c9nbl60-67cdd59   b3c.16x64.encrypted   116   
$ ibmcloud ks worker-pools -c prod-us-south-o-carrier116 | grep customer
customer-workload      bubi1cad0ilnlsd7e3t0-e237ce7   b3c.16x64.encrypted   116   
$ ibmcloud ks worker-pools -c prod-us-south-o-carrier117 | grep customer
customer-workload      bv95os8d094vi6mmv2ag-0c826a7   b3c.16x64.encrypted    116   
```

If there is a live tugboat that is not at the max size, follow these steps to scale it: https://github.ibm.com/alchemy-containers/tugboat-bootstrap/#scaling-the-worker-pool

### Order new tugboat

See [here](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/#raise-order-with-shepherd) for the ordering process. Before raising the order, we need to check if one is in flight already. This should be listed in the handover already, but it is good to double check. Search for the tugboat type you wish to order in [#shepherds-channel](https://ibm-argonauts.slack.com/archives/G7NGEV2GY). i.e. if ROKS is hitting capacity search "tugboatMzrSpokeRoks" or "tugboatSzrSpokeRoks". Check the status of the most recent same region order. If it is live already, then a new order needs to be placed. If it is not live, continue the deploy process for that tugboat.

### Turn off the carrier from new cluster creations

This option should only be used as a last resort. Reasons to use this option:
1. The load balancer is broken - If all same type, same region tugboats are already fully scaled and the loadbalancer is still putting an uneven amount of deploys on a single tugboat, then that tugboat should be disabled while armada-deploy investigates the load balancer (this has never happened before. The load balancer works)
1. The tugboat is being decommissioned. This is not an alert driven process. See [here](../decomission_legacy_carrier.html) for tugboat decomm steps

Steps to disable:

1. If we are reaching close to our absolute limits 850 we will need to turn off this carrier to prevent new clusters from going to it
1. There first needs to be another tugboat in the region of the same type (MZR/SZR) to accept new clusters
   - to determine if there is another cluster to accept workload go here [https://github.ibm.com/alchemy-containers/armada-config-pusher/blob/master/json-templates/](https://github.ibm.com/alchemy-containers/armada-config-pusher/blob/master/json-templates/), then go into the region where capacity has been reached.
   - open `datacenters.json` and search for the carrier that has hit capacity and look for its "type". The following mapping below will determine its purpose
     - No Type or "type": "" = regular IKS workload
     - "type": "openshift" = Openshift workload
     - "type": "multishift" = Satellite location workload  
   - verify there is another carrier that is the same type and `"enabled": "true"`
1. Create armada-config-pusher PR to turn off the carrier, for example: [https://github.ibm.com/alchemy-containers/armada-config-pusher/pull/723](https://github.ibm.com/alchemy-containers/armada-config-pusher/pull/723)

## Automation
No automation is currently provided

## Investigation and Action
- Create a [GHE Issue](https://github.ibm.com/alchemy-conductors/team/issues) and include the following information
    - Link to PagerDuty
    - Tugboat with the capacity information
    - Number of clusters currently on the Tugboat

## Escalation Policy
This is owned by the conductors squad. These alerts should not get escalated to a dev team during off hours. If you need support please ask in #iks-carrier-tugboat (private channel) and wait till the team is available during normal hours.
