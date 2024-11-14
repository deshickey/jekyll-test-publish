---
layout: default
description: How to resolve Satellite-Link "Connector Deploy Cannot Reach IAM Server"
title: satellite-link-connector-deploy-cannot-reach-iam-server - How to resolve 
service: satellite-link
runbook-name: "satellite-link-connector-deploy-cannot-reach-iam-server"
tags:  satellite-link, iam, configmap
link: /satellite-link/satellite-link-connector-deploy-cannot-reach-iam-server
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Link
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `SatelliteLinkConnectorDeployCannotGetIAMKeyFromConfigmap`| Satellite-Link Connector is not able to communicate with IAM server. This will produce a pod restart
 | [Steps to debug Satellite-Link Connector is not able to get IAM key from ConfigMap](#steps-to-debug-satellite-link-connector-is-not-able-to-reach-iam-server) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = SatelliteLinkConnectorDeployCannotReachIAMServer
 - alert_situation = SatelliteLinkConnectorDeployCannotReachIAMServer
 - service = satellite-link
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = satellite-link
Annotations:
 - summary = "Link connector is rebooting : unable to reach IAM server"
 - description = "Satlink Connector is not able to reach IAM server. This will produce a pod restart"
~~~~

## Actions to take

### Steps to debug Satellite-Link Connector is not able to reach IAM server

This means that the ConfigMap is missing, or does not have the appropriate IAM key for the Connector to pull. Alternatively, there may be a network problem between the location and the IAM server.

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
    * If the key isn't there, jump to [resolving-missing-configMap](#resolving-missing-configmap)
1. In the artifacts look for `connector_pod_logs_{env}.log` e.g. `connector_pod_logs_prod.log`
    * Look for errors related to IAM
    * The string `getToken` will be the key to look for
    * If the error is an HTTP/S 4XX, proceed to the next step.
    * If the IAM server is unreachable, escalate using the [Escalation Policy](#escalation-policy) and provide the logs surrounding `getToken error` or `getToken response`
1. If this step has been reached, without issue, the IAM key itself is likely bad and needs to be replaced.
    * Jump to [resolving bad iam key](#resolving-bad-iam-key)

### Resolving Missing ConfigMap
1. This configMap is provided to the cluster by the service `cluster-updater` in the location control plane. If the ConfigMap is not present it is likely due to an issue with `cluster-updater`.
1. If unable to determine the issue, escalate with the Razee team [{{ site.data.teams.razee.comm.name }}]({{ site.data.teams.razee.comm.link }})

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
