---
layout: default
description: How to resolve Satellite-Link "Cannot Start TLS tunnel to Satellite-Link"
title: satellite-link-connector-cannot-start-tls-tunnel-to-satlink - How to resolve 
service: satellite-link
runbook-name: "satellite-link-connector-cannot-start-tls-tunnel-to-satlink"
tags:  satellite-link, iam, token
link: /satellite-link/satellite-link-connector-cannot-start-tls-tunnel-to-satlink
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Link
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `SatelliteLinkConnectorTunnelCannotStartTLSTunnelToSatLink`| Satlink Connector is not able to reach Satellite Link Tunnel.
 | [Steps to debug Satellite-Link Connector cannot start TLS tunnel to satellite-link](#steps-to-debug-satellite-link-connector-cannot-start-tls-tunnel-to-satellite-link) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = SatelliteLinkConnectorTunnelCannotStartTLSTunnelToSatLink
 - alert_situation = SatelliteLinkConnectorTunnelCannotStartTLSTunnelToSatLink
 - service = satellite-link
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = satellite-link
Annotations:
 - summary = "no tunnel connection between connector and satellite link tunnel"
 - description = "Satellite-Link Connector is not able to reach Satellite Link Tunnel."
~~~~

## Actions to take

### Steps to debug Satellite-Link Connector cannot start TLS tunnel to satellite-link

This means that the Satellite-Link Connector is unable to initiate the TLS tunnel to satellite-link tunnel clusters

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
1. In the artifacts look for `connector_pod_logs_{env}.log` e.g. `connector_pod_logs_prod.log`
    * Gather evidence of errors from the logs and [Escalate](#escalation-policy)

### Additional Information

More information on the satellite-link-connector can be found [here](https://github.ibm.com/IBM-Cloud-Platform-Networking/satellite-link-connector)

## Escalation Policy
If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.satellite-link.escalate.name }}]({{ site.data.teams.satellite-link.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.satellite-link.comm.name }}]({{ site.data.teams.satellite-link.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.satellite-link.name }}]({{ site.data.teams.satellite-link.issue }}) Github repository with all the debugging steps and information done to get to this point.
