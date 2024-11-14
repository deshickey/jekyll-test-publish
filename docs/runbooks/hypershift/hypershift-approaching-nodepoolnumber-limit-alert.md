---
layout: default
title: Hypershift approaches node pool limit. How to resolve the alert.
type: Alert
runbook-name: "hypershift-approaching-nodepoolnumber-limit-alert"
description: How to resolve ApproachingNodePoolNumberLimit alert
service: hypershift
link: /hypershift/hypershift-approaching-nodepoolnumber-limit-alert.html
tags:  hypershift, ApproachingNodePoolNumberLimit
grand_parent: Armada Runbooks
parent: Hypershift
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `ApproachingNodePoolNumberLimit` | Hypershift konnectivity server pod is down | [Actions to take](#actions-to-take) |
{:.table .table-bordered .table-striped}

These alerts fire when Hypershift approaches 4000 nodepool limit per satellite location tugboat. 

## Customer impact

Users are still able to use existing location clusters and create new locations, no immediate customer impact.

## Example Alert(s)

~~~~
Labels:
 - alertname = ApproachingNodePoolNumberLimit
 - alert_situation = approaching_nodepool_number_limit
 - service = armada-hypershift
 - severity = warning
 - cluster_id = <CLUSTER-ID>
 - namespace = master-<CLUSTER-ID>
Annotations:
 - summary = "When we get past 4000 nodepools the scaling process should be started."
 - description = "Approaching the upper threshold on the amount of nodepools."
~~~~

## Automation

None

## Actions to take

Order new tugboat. See [here](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/#raise-order-with-shepherd) for the ordering process. Before raising the order, we need to check if one is in flight already. This should be listed in the handover already, but it is good to double check. Search for the tugboat type you wish to order in [#shepherds-channel](https://ibm-argonauts.slack.com/archives/G7NGEV2GY). i.e. if ROKS is hitting capacity search "tugboatMzrSpokeRoks" or "tugboatSzrSpokeRoks". Check the status of the most recent same region order. If it is live already, then a new order needs to be placed. If it is not live, continue the deploy process for that tugboat.

## Escalation Policy

This is owned by the conductors squad. These alerts should not get escalated to a dev team during off hours. If you need support please ask in [{{ site.data.teams.armada-hypershift.comm.name }}]({{ site.data.teams.armada-hypershift.comm.link }}) Slack channel (private channel) and wait till the team is available during normal hours.