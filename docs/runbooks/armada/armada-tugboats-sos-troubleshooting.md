---
layout: default
description: General debugging info for sos reporting on armada tugboat carriers
title: General debugging info for sos reporting on armada tugboat carriers
service: armada-infra
runbook-name: "General debugging info for armada tugboat sos reports"
tags:  armada, carrier, debugging, tugboat, sos
link: /armada/armada-tugboats-sos-troubleshooting.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This information runbook is used to detail information the infrastructure tugboats.

## Detailed Information

### Access the Sos dashboard

Tugboats are part or the `armada` ccode. The sos dashboard for `armada` machines can be found [here](https://w3.sos.ibm.com/inventory.nsf/compliance_portal.xsp?c_code=armada).
- to view all tugboats, Filters -> Application -> containers-kubernetes-tugboat
- to view a single tuboat, type `%CLUSTERID%` into search bar

### possible issues causing errors

#### Patch has failed to be installed

Symptoms: There is a single (or a few) node(s) in a carrier that are reporting <100% health. note: if there are many nodes that are reporting this it could be a bigger issue with the patching rollout across the whole carrier.

Resolution:

1. Double click the entry in the table.
1. Scroll down to section "Patching history"
1. Do you see a patch listed with a "Due date" and no "Applied date"? If so, [reload the node](./armada-carrier-node-troubled.html#reloading-worker-node). The reload will use the latest worker image which should have the patch included.

#### Extra IPs attached to node

Symptoms: Mad validation failed

Resolution:

1. Click on the drop down for the machine in question and take note of the "vulnerability" folder
1. Are there >1 address? If so continue below.
1. Expand the vulneraiblity folder to display the private ips. Type each private ip into @netmax. Is one of them of the form prod-<DC>-tugboat1##-loadbalancer-private-vip ? If so, this is a false positive. The private loadbalancer ip is a floating ip and sometimes it can be incorrectly attached to a node. This does not signify any underlying issues in performance or security. However this does need to be corrected.
1. Provide the following information to the sos team in #iks-carrier-tugboats and ask them to investigate
- netmax output for worker node, including node name and private ip
- ip of the private loadbalancer that is incorrectly attached to the worker node above

#### Last log report date is several days old
Symptoms: column "last log report" is red

Resolution:

1. Follow [these steps](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI/blob/master/troubleshooting.md#qradar-lastlog-report-old)

#### Machine is not being scanned by Nessus
Symptoms: Column `Scanned date` is empty

Resolution:

1. Check if the public ips are listed in the [armada scan zone](https://w3.sos.ibm.com/inventory.nsf/scan_zone.xsp?c_code=armada&name=Armada_Public_SZ) note: IPs can be listed in ranges (eg 150.238.202.34-150.238.202.62), so you may not find the ip if you search the exact match
1. [Raise sos ticket](https://ibm.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D45ef56a7db7c4c10c717e9ec0b96193a%26sysparm_link_parent%3D109f0438c6112276003ae8ac13e7009d%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default%26sysparm_view%3Dcatalog_default) against `SOS Vulnerability Scanning`. Provide a list of the public ips and whether or not they exist in the scan zone.
1. Follow up in ticket and/or #sos-securitycenter depending on urgency

## Escalation Policy

SOS team in #iks-carrier-tugboats
