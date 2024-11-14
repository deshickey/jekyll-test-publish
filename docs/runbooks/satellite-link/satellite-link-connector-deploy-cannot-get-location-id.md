---
layout: default
description: How to resolve Satellite-Link "Cannot Get Location ID"
title: satellite-link-connector-deploy-cannot-get-location-id - How to resolve 
service: satellite-link
runbook-name: "satellite-link-connector-deploy-cannot-get-location-id"
tags:  satellite-link, location-id, configmap
link: /satellite-link/satellite-link-connector-deploy-cannot-get-location-id
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Link
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `SatelliteLinkConnectorDeployCannotGetLocationId`| Satellite-Link Connector is not able to get LocationId from configMap. This will produce a pod restart
 | [Steps to debug Satellite-Link Connector is not able to get Location ID](#steps-to-debug-satellite-link-connector-is-not-able-to-get-location-id) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = SatelliteLinkConnectorDeployCannotgetLocationId
 - alert_situation = SatelliteLinkConnectorDeployCannotgetLocationId
 - service = satellite-link
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = satellite-link
Annotations:
 - summary = "Link connector is rebooting : no LocationId found"
 - description = "Satlink Connector is not able to get LocationId from configMap. This will produce a pod restart"
~~~~

## Actions to take

### Steps to debug Satellite-Link Connector is not able to get Location ID

This means that the ConfigMap is missing, or does not have the appropriate value for the Connector to pull

To debug:

1. Get the tugboat name for the location by using [armada-xo](https://ibm-argonauts.slack.com/archives/G53AJ95TP) slack channel
    * For production use `@xo cluster <location-id>`
    * For staging use `@Armada Xo - Stage cluster <location_id>`
    * From the output, look at the field `ActualDatacenterCluster` to obtain the tugboat name. E.g. `prod-wdc04.carrier107`
1. Log into [alchemy-containers-jenkins](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-ha-master-get-info/build?delay=0sec)
1. Fill in the form:
    * BRANCH: Master
    * ENV_Branch: Master
    * CLUSTERID: <location_id>
    * TUGBOAT: <tugboat_name_from_step1> # Ensure you switch the tugboat name to kebab case e.g. `prod-wdc04-carrier107`
    * CARRIER_NAME: <first_available_carrier_in_dc_where_tugboat_resides>
1. Start the job and allow it to complete
1. In the artifacts look for `connector_ks_configMap.log`
    * Confirm the configMap is there
    * Check the configMap to ensure that the key `cluster_id` matches the expected location ID
    * If the `cluster_id` does not match, jump to [Fixing Cluster ID Key](#fixing-cluster-id-key)
1. If the key or the configMap aren't present, jump to [Resolving Missing Configmap](#resolving-missing-configmap)

### Resolving Missing ConfigMap
1. This configMap is provided to the cluster by the service `cluster-updater`.
2. Verify the above service is working correctly, if not escalate to the team in charge.
1. If unable to determine the issue, escalate: 
    * `cluster-updater`: Escalate with the Razee team [{{ site.data.teams.satellite-config.comm.name }}]({{ site.data.teams.satellite-config.comm.link }})

### Fixing Cluster ID Key
1. This configMap is provided to the cluster by the service `cluster-updater`, most likely scenario for the bad key is that the configMap isn't being regenerated properly
2. Verify the above service is working correctly, if not escalate to the team in charge.
1. If unable to determine the issue, escalate: 
    * `cluster-updater`: Escalate with the Razee team [{{ site.data.teams.satellite-config.comm.name }}]({{ site.data.teams.satellite-config.comm.link }})

### Additional Information

More information on the satellite-link-connector can be found [here](https://github.ibm.com/IBM-Cloud-Platform-Networking/satellite-link-connector)

## Escalation Policy
If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.satellite-link.escalate.name }}]({{ site.data.teams.satellite-link.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.satellite-link.comm.name }}]({{ site.data.teams.satellite-link.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.satellite-link.name }}]({{ site.data.teams.satellite-link.issue }}) Github repository with all the debugging steps and information done to get to this point.
