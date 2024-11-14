---
layout: default
description: How to resolve Satellite-Link "Cannot Get IAM token from IAM server"
title: satellite-link-connector-deploy-cannot-get-iam-token-from-iam-server - How to resolve 
service: satellite-link
runbook-name: "satellite-link-connector-deploy-cannot-get-iam-token-from-iam-server"
tags:  satellite-link, iam, token
link: /satellite-link/satellite-link-connector-deploy-cannot-get-iam-token-from-iam-server
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Link
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `SatelliteLinkConnectorDeployCannotgetIAMTokenFromIAMServer`| Satellite-Link Connector is not able to get IAM token from IAM Server. This will produce a pod restart
 | [Steps to debug Satellite-Link Connector is not able to get IAM token from server](#steps-to-debug-satellite-link-connector-is-not-able-to-get-iam-token-from-server) |
{:.table .table-bordered .table-striped}


## Example Alert(s)

~~~~
Labels:
 - alertname = SatelliteLinkConnectorDeployCannotgetIAMTokenFromIAMServer
 - alert_situation = SatelliteLinkConnectorDeployCannotgetIAMTokenFromIAMServer
 - service = satellite-link
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = satellite-link
Annotations:
 - summary = "Link connector is rebooting : no IAM Token can be retrieved from IAM Server"
 - description = "Satellite-link Connector is not able to get IAM token from IAM Server. This will produce a pod restart"
~~~~

## Actions to take

### Steps to debug Satellite-Link Connector is not able to get IAM token from server

This means either the ConfigMap containing the API key isn't there, the key itself is invalid, or that the IAM operation is failing due to other circumstances

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
1. In the artifacts look for `connector_getConnectorAPIKey.log`
    * Decode the base64 string for key `slclient.toml`
        * E.g. `echo "<base64_string>"|base64 -d`
    * Verify that the decoded string contains an IAM API key under field `iam_api_key`
    * If the key isn't there, jump to [Resolving missing configMap](#resolving-missing-configmap)
1. In the artifacts look for `connector_sl_configMap.log`
    * Verify that the `region` key has the correct value for the region of the tugboat
    * If the key is not correct, jump to [resolving improper region config](#resolving-improper-region-config)
1. If this step has been reached, without issue, the IAM key itself is likely bad and needs to be replaced.
    * Jump to [resolving bad iam key](#resolving-bad-iam-key)

### Resolving Missing ConfigMap
1. This configMap is provided to the cluster by the service `cluster-updater` in the location control plane. If the ConfigMap is not present it is likely due to an issue with `cluster-updater`.
1. If unable to determine the issue, escalate with the Razee team [{{ site.data.teams.satellite-config.comm.name }}]({{ site.data.teams.satellite-config.comm.link }})

### Resolving improper region config
This configMap is provided to the cluster by the services `cluster-updater`, and `autoresolver-server`.
1. Verify the above services are working correctly, if not escalate to the team in charge.
2. If unable to determine the issue, escalate: 
    * `cluster-updater`: Escalate with the Razee team [{{ site.data.teams.satellite-config.comm.name }}]({{ site.data.teams.satellite-config.comm.link }})
    * `satellite-alert-autoresolver-serve`: Escalate with the armada-bootstrap [{{ site.data.teams.armada-bootstrap.comm.name }}]({{ site.data.teams.armada-bootstrap.comm.link }})

### Resolving bad IAM key
1. The customer, which may be an IBM service team, needs to rotate their IAM API key for the Satellite Location in question.
    * `ibmcloud target -r <REGION>`
    * `ibmcloud target -g <RESOURCE_GROUP>`
    * `ibmcloud ks api-key reset --region <REGION>`
2. We then need to issue a `master refresh`. This will cause the ConfigMap to update on the affected location with the newly refreshed API key

### Additional Information

More information on the satellite-link-connector can be found [here](https://github.ibm.com/IBM-Cloud-Platform-Networking/satellite-link-connector)

## Escalation Policy
If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.satellite-link.escalate.name }}]({{ site.data.teams.satellite-link.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.satellite-link.comm.name }}]({{ site.data.teams.satellite-link.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.satellite-link.name }}]({{ site.data.teams.satellite-link.issue }}) Github repository with all the debugging steps and information done to get to this point.
