---
layout: default
description: General debugging info for armada satellite locations
title: General debugging info for armada satellite locations
service: armada-bootstrap
runbook-name: "General debugging info for armada satellite locations"
tags:  armada, satellite, locations, debug, debugging, general
link: /satellite/armada-satellite.html
type: Informational
grand_parent: Armada Runbooks
parent: Satellite
---

Informational
{: .label }

## Overview

This runbook is a general case guide for how work and interact with satellite locations.

## Detailed Information

### Terminology

* LocationID - The ClusterID of the satellite location itself. This is found in the PD alert title and body under `location_clusterId`
* CruiserClusterID - The ClusterID of the Cruiser Cluster running inside the location itself. This is found in the PD alert body under `labels->cluster_id`

### Example alert
https://ibm.pagerduty.com/incidents/PXVK6UV

The title of the alert will contain the keywords `[Satellite]` and then LocationID right next to it. For example:
`[Satellite][br2iu7u20q06fnbt156g] armada-deploy/ha_deployment_down_critical_oc4/openshift-apiserver`

### Next steps

1. First verify that the Satellite Location is not deleted. Go to `#armada-xo` in slack, and type `@xo cluster $LocationID`. 
   - Make sure `"DesiredState" != "deleted"`
   - If `deleted` resolve the alert. 

2. Gain [access the satellite locations](#access-the-satellite-locations) 

3. Follow the runbook that is linked in the pagerduty alert, under `annotations->runbook`. (More tips below)
   - This is the runbook that is referenced for the specific alert. 

4. Whenever in the runbook it needs you to run `kubectl` commands do the following:
   - If wanting you to target the control plane of the openshift cluster, will need to do `kubx-kubectl $LocationID`
   - If wanting you to target the openshift cluster directly, will need to do `kubx-sat-kubectl $LocationID $CruiserClusterID`

5. Directly navigating to prometheus for satellite locations will not be supported
   - Whenever in the runbooks it gives you the option to use prometheus, skip those steps and check directly from the carrier
   
5. Additionally, if there is a jenkins job you need to run there will be an additional parameter where you will need to put in the LocationID

6. Once debugging is completed, and you are unable to solve, go to [support path for customer issues](#support-path-for-customer-issues) for next steps.

### Access the satellite locations

1. Look for `location_carrier_name` in the PagerDuty alert, and that will tell you what tugboat it is. 
    - For example: `location_carrier_name: dev-dal10.carrier107`

2. Now you will need to gain access to the tugboat. Instructions can be found here: [access the tugboats](../armada/armada-tugboats.html#access-the-tugboats)

3. Using the LocationID from the alert you can now run kubectl commands doing: `kubx-kubectl $LocationID`

4. Using the LocationID and CruiserClusterID from the alert you can run commands directly against the CruiserCluster by doing `kubx-sat-kubectl $LocationID $CruiserClusterID`

### Support path for customer issues

If during the investigations, it is detected there was an issue with a worker node, we will need to work with the customer to resolve. Steps are still TBA
on how that support path will look like, but once communication has been made with the customer, no more action will need to be taken.

For all other issues that are unrelated to worker nodes being broken, use the escalation policy found in the alert specific runbook. 
