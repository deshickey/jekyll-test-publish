---
layout: default
description: An overview of the armada-update microservice and alert debugging tips.
title: Armada Update Microservice
service: armada-update
runbook-name: "Armada Update Microservice"
tags: armada-update, patch-update, master, bom
link: /armada/armada-update-microservice.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook provides an overview of the [Armada-update](https://github.ibm.com/alchemy-containers/armada-update) microservice, including alert troubleshooting tips.

## Detailed Information
The armada-update microservice is responsible for triggering automatic patch updates for cluster masters in a region.
The microservice triggers off of setting the `UpdateState` of an `AnsibleBomVersion` to `update`.
It will then look at every cluster in the region to determine if it is a candidate for a patch update to the bom version.

The microservice could fail for a variety of reasons during execution. Follow the steps below to debug any failures.

## Alerts
Potential PD alerts for this microservice include:
- `ArmadaUpdateMicroserviceUnhealthy` - the microservice has encountered a problem while triggering patches

## Actions to take
Upon receiving a PD for this microservice, please begin your investigation by following the steps below:

1. Review the `#armada-deploy-alerts` channel
   - Look for recent `PROBLEM UPDATE` messages.
     - This means that microservice was unable to trigger master patch updates for a given bom.
     - Review the logs linked in the slack message.
1. Escalate to the dev squad.  Follow the `Escalation Policy` section below.

## Escalation Policy
If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-update.escalate.name }}]({{ site.data.teams.armada-update.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-update.comm.name }}]({{ site.data.teams.armada-update.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-update.name }}]({{ site.data.teams.armada-update.issue }}) Github repository for later follow-up.

## Metrics and Dashboards
Dashboards for patching in each region are available in grafana, and are linked [here](https://github.ibm.com/alchemy-containers/armada-update/tree/master/docs).