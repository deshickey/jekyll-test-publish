---
layout: default
title: armada-cluster - Insufficient resources for patrol workers
type: Alert
runbook-name: "armada-cluster - Insufficient resources for patrol workers"
description: Armada cluster - Insufficient resources for patrol workers
service: armada-cluster
link: /cluster/cluster-squad-insufficient-patrol-resources.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

  This alert will trigger when a patrol worker has failed to provision due to an insufficient resources exception from IBM Cloud classic infrastructure (Softlayer).

## Example Alert

  Example PD title:

  - `#3533816: bluemix.containers-kubernetes.armada-cluster_patrol_error_insufficient_resources_lon04.uk-south`

  Example Body:

## Actions to Take

This alert indicates that IBM Cloud classic infrastructure (Softlayer) are no longer able to accept virtual machine orders in the location where our patrol workers are based for this region. The affected zone can be found within the alert.

### Request additional capacity

1. Join the [sl-compute-sre](https://ibm-argonauts.slack.com/archives/C5WRPN2HE) slack channel
1. Request the infrastructure team make more capacity available in the affected zone

Once IBM Cloud classic infrastructure have made more capacity available, the alerts will autoresolve 1 hour after the last instance of the error. If the alerts do not clear, proceed to the next section

### Check if patrol VLANs are full

1. Open the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier)
1. Select Grafana for the affected region and open the charts for a HUB carrier within the region
1. Open the `Armada Cluster` view
1. Scroll down the page to find and expand the `Patrol VLAN Subnets` section
1. The `Patrol VLAN Subnet Counts` chart will display the number of subnets we currently have in the VLANs we're using for patrols
1. The following limits apply worldwide.
    - US-South has a limit of 70 subnets per VLAN
    - All other regions have a limit of 50 subnets per VLAN
1. If the count of subnets is at the limit, new VLANs will be required within the region

Proceed to the `Next Steps` section and relay the result of the above diagnosis

### Next steps

1. Notify the technical leadership team (Jake Kitchener, Ralph Bateman and Jeff Sloyer)
1. Pass on the following information
    - Were IBM Cloud classic infrastructure able to add capacity?
    - Did alerts continue after IBM Cloud classic infrastructure added capacity?
    - Are the selected VLANs at the limit of subnets they can contain?
1. The leadership team will need to decide how best to handle the situation. Options are...
    - Disable patrols in that region
    - Add a new VLAN pair to that zone
    - Select a new zone to house patrols for the region

## Resolution

This is not a simple issue to resolve, and several workers may hit this issue while the resolution is being worked. The situation can be considered resolved under any of the following circumstances

1. IBM Cloud classic infrastructure (SoftLayer) increase the availability of capacity in the configured zone and alerts resolve
1. The IKS technical team configure a new VLAN or zone to contain the patrols

## Escalation Policy

For any other issues, or if the error message does not make it clear how to resolve, or if it is not listed in the above messages, then escalate to [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98)
