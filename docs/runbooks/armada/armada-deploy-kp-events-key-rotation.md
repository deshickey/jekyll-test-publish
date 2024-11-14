---
layout: default
description: How to handle a armada-kp-events failures for rotation of the service IAM API key.
title: armada-deploy - How to handle failures for rotation of the service IAM API key.
service: armada-kp-events
runbook-name: "armada-deploy - How to handle failures for rotation of the service IAM API key"
tags: alchemy, armada-deploy, key-protect, kms
link: /armada/armada-deploy-kp-events-key-rotation.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle alerts which report that the microservice `armada-kp-events` is having an issue rotating the service IAM API key. When the microserivce detects a new API key, it attempts to update the key for all clusters.

## Example Alerts

~~~~
Labels:
 - alertname = armada-kp-events/armada_kp_events_key_rotation_failures
 - alert_situation = "armada-kp-events/armada_kp_events_key_rotation_failures"
 - service = armada-deploy
 - severity = critical
Annotations:
 - summary = "armada-kp-events is experiencing consistent failures while attempting to rotate the service api key for a cluster"
 - description = "armada-kp-events service has experienced failures processing the service api key rotation for resource crn:v1:bluemix:public:containers-kubernetes:us-south:a/c5c0dba4d5406e21164fb825760a7292:c23h5icd0sr2mu96rcig:: in the last 15 mins"
~~~~

## Actions to take

Review the microservice logs for `armada-kp-events` in LogDNA. The logs can also be viewed by going to the hub directly and looking for the `armada-kp-events` pod in the `armada` namespace. In the logs, you will see the rotation attempts listing out the rotation attempts. Example output from these logs can be viewed in the `armada-kp-events` [README.txt](https://github.ibm.com/alchemy-containers/armada-kp-events/blob/master/README.md).

In most cases, the appropriate action is to delete the `amrada-kp-events` pod so the rotation event will start again. This should only be done if there are no other ongoing issues in the environment.

Possible Failures and Actions:
* ETCD failure - Failure related to retrieving or setting ETCD data. Verify carrier ETCD is working correctly.
* Failed to create a Kube Client - Investigate if there are any other issues ongoing with the Carrier/Tugboat where the cluster's master is running.
* Failed to update WDEK Secret - Check the state of the cluster master to verify it is in a normal state.
* Rotation attempt failed - A single rotation attempt has failed. Continue to look for underlying issues in the log.
* Failure to rotate the service iam-api-key - Retry attempts to rotate the Service IAM API Key have been exhausted. This is the summary failure and the underlying failure will need to be identified from this list.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.