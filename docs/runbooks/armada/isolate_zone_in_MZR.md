---
layout: default
title: Armada - Isolate a zone in an MZR
type: Operations
runbook-name: "Armada - Isolate a zone in an MZR"
description: steps on how to isolate a zone in an MZR
category: armada
service: Containers
tags: armada, mzr, zone
link: armada/isolate_zone_in_MZR.html
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview 
- Purpose for this runbook is to document the steps needed to isolate a zone in a Multi-zone Region aka MZR.   This is typically needed in the situation where we have a large number of flapping nodes in one region.  With these instructions we can shut off traffic to a single zone forcing all masters off this region until the region is stable.



## Detailed Information 
### Overview of Steps
- identify if the zone is in an MZR.  You can query @victory carrier-list.  If the carrier is labled a 'Hub' it is an MZR
- identify the primary and secondary HA Proxy nodes in the zone
- power off the haproxy nodes

## Detailed Procedure
### Identify if the carrier is in an MZR 
- Go to the [armada-envs repo](https://github.ibm.com/alchemy-containers/armada-envs) and search for the carrier in question.
- View the carrier's hosts file and review all lines in the carrier's hosts file for `zone=` , if you see more than one data center referenced in the file, this carrier is an MZR carrier. Note the different zones are sometimes called prod-dal12a or prod-dal12b. 

### Identify the primary and secondary HA Proxy nodes
- log in to the zone's haproxy nodes and run this command `snmpwalk -v2c -c public 127.0.0.1 KEEPALIVED-MIB::vrrpSyncGroupState`
  - `KEEPALIVED-MIB::vrrpSyncGroupState.1 = INTEGER: master(2)` - shows this is the primary node of the HA Proxy pair
  - KEEPALIVED-MIB::vrrpSyncGroupState.1 = INTEGER: backup(1) - shows this is the secondary node of the HA Proxy pair
  - if the words master and backup do not show up in the results but the numbers `2` and `1` do, this only means the informational deb package `snmp-mibs-downloader` was not installed.

### Power off the haproxy nodes
When powering off the haproxy nodes, start with the **secondary** node **FIRST**. This will prevent the secondary attempting to grab the primary position and causing other problems. The command to power off the node in linux is `poweroff`

### Shutdown the services on the Carrier Master.
Now that we have added some insulation for the Carriers we should be able to survive by just shutting down the haproxies to the zone. 

**THESE ARE THE OLD INSTRUCTIONS FOR SHUTTING DOWN A CARRIER MASTER.  NO LONGER NECESSARY.**

On the carrier master in the zone to be isolated:

systemctl stop haproxy
systemctl stop kubelet
systemctl stop etcd

Run docker ps to get ids for apiserver, controller-manager, scheduler; then run docker kill ID to kill each of those containers.

## Further Information 

### Generate the full list 
- You can also generate the full list by cloning the GHE repo for armada-envs and running this command: `for i in prod*/carrier*hosts ; do grep -q -P 'zone=\D{3}\d{2}[abc]' $i && echo SZR: $i || echo MZR: $i ; done | sort | sed s/\.hosts//`

### Further information
For further information, reach out to the netint and armada-deploy team in that order
