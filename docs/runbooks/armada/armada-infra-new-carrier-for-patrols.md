---
layout: default
title: armada-infra - New carrier for patrols in existing region
type: Informational
runbook-name: "armada-infra - New carrier for patrols in existing region"
description: "List of steps to provision (including ordering the machines and setting up) a new carrier for patrols in existing region"
service: armada
playbooks: [<NoPlayBooksSpecified>]
link: /armada/armada-infra-new-carrier-for-patrols.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook details the list of steps to provision a new carrier for patrol masters in an existing region.

## Detailed Information

The provisioning of a new carrier involves several steps and several squads. This runbook explains how to raise issues for other squads and who has responsibility for each step. 

There are two types of carriers that can be created:

1. A carrier as another availability zone which has all the armada micro
services on it (for example, armada-api, armada-ui, armada-cluster).
*Do not use this runbook.*


1. A carrier for running the patrol masters. 
This is used to isolate the free cluster masters from the paid-for clusters. 
This carrier will have only a subset of the armada micro services running on it.
*This is the runbook you need.*

## Prequisite information

There is some information needed before starting to provision.

- Which account: For production use SL Account 531277.

- The SoftLayer data center: The data center to use. 
In the steps below this is represented as `{dal12}`. 
You will also need to choose a pod. This is represented as `{p1}`

  The only way to choose the data canter and pod is to know the SoftLayer 
  machine availability. 
  If you do not know this then ask Ralph for help.

- Name of the Carrier: In the steps below this is represented as `{Carrier4}`

## Networking resources

How: Raise a ticket for
[netint](https://github.ibm.com/alchemy-netint/firewall-requests/issues/new)
squad for all the following items.

### VLAN Label Prod/Carrier(n)

Add a portable /28 to each Public.

- Create Carrier Worker Public & Private {dal12} VLANs behind vyatta Label
`Prod/{Carrier4}`

### VIPs for haproxy(LVS) machines

Order two VIPs for haproxy(LVS) machines

### Machines

How: Raise a ticket for
[Conductors](https://github.ibm.com/alchemy-conductors/team/issues/new) squad
for all the following items.

All carrier machines as per template listed. Public and private networks. 
Private node.

Carrier Private VSI Nodes {DAL12(p1)} VLAN behind vyatta Prod/{Carrier4}:

- 2x haproxy nodes
  - template: `prod-dal10-carrier3-haproxy-01`
  - name: `prod-{dal12}-{carrier4}-haproxy-xx`

- 2x armada master 
  - template: `Carrier-Small-Private-VSI` 
  - name: `prod-{dal12}-{carrier4}-master-xx`
  
- 50x armada worker 
  - template: `Carrier-Small-Private-VSI`
  - name: `prod-{dal12}-{carrier4}-worker-xx`

### Storage

How: Raise one ticket for
[Conductors](https://github.ibm.com/alchemy-conductors/team/issues/new) squad
for all the following items.

ALL endurance NFS with highest IOPS (hopefully 10 IOPS/GB):

- Carrier etcd NFS in {DAL12}{p1} _250 GB_.  Authorize all carrier subnet Prod/{Carrier4}

- Kubx NFS (patrol) in {DAL12}{p1} _4000 GB_. Authorize all carrier subnet Prod/{Carrier4}

- Prometheus NFS in {DAL12}{p1} _1TB_. Authorize all carrier subnet Prod/{Carrier4}


Bootstrap endurance NFS (2 IOPS/GB):

- Carrier Bootstrap NFS in each {DAL12}{p1} _20GB_ Authorize all carrier subnets Env/Carrier.

## Setup of carrier

### Firewall rules

How: Raise one ticket for
[netint](https://github.ibm.com/alchemy-netint/firewall-requests/issues/new)
squad for all the following items.

- Carrier VLANs Allow access to 10250 only from control plane.
- Allow public inbound to all carrier-workers on port 443-32767 TCP and UDP
(except 10250)
- Allow outbound to internet for Carrier master and all workers

### Set up haproxy (LVS) machines

How: Raise a ticket for
[netint](https://github.ibm.com/alchemy-netint/firewall-requests/issues/new)
squad for all the following items.

- Set up and commission haproxy machines for this carrier.
Use VIPS ordered above.

### Set up carrier masters and workers by armada-carrier squad

How: Raise one ticket for
[armada-carrier](https://github.ibm.com/alchemy-containers/armada-carrier/issues/new)
squad for all the following items.

- Request to install kubernetes on master and workers

- Request to deploy the subset of armada micro services needed by this carrier:

  - armada-chief
  - armada-ops
  - armada-ops-prom2graphite
  - armada-fluentd
  
### Set up alerting for armada-ops

How: Raise one ticket for
[Conductors](https://github.ibm.com/alchemy-conductors/team/issues/new) squad.

- Use sensu-uptime to monitor prometheus and alertmanager on the new carrier. See existing [sensu-uptime](https://github.ibm.com/alchemy-conductors/sensu-uptime/tree/master/sensu/gen_sensu_check/config) configuration for examples.

### Set up alchemy-prod dashboard for armada-ops

How: Raise one ticket for
[Conductors](https://github.ibm.com/alchemy-conductors/team/issues/new) squad.

- Add the new carrier to the alchmey-prod dashboards. 
  The dashboard needs links to prometheus, alertmanager and grafana.
