---
layout: default
title: How to check if the registry is having trouble
type: Troubleshooting
runbook-name: 'Check if the registry is having trouble'
description: Where to look for clues if users are reporting issues with the registry
category: IBM Cloud Container Registry
service: Registry
link: registry/check_if_the_registry_is_having_trouble.html
grand_parent: Armada Runbooks
parent: Registry
---

Troubleshooting
{: .label .label-red}

# How to check if the registry is having trouble

## Overview

This runbook is intended to be used by the SRE team, when users are reporting issues with IBM Cloud Container Registry (ICCR), to determine whether the service is troubled.
First, check the [#containers-cie](https://ibm-argonauts.slack.com/archives/C4SN1JNG5) channel to see if a CIE has been raised. You can also see any CIEs we have https://cloud.ibm.com/status?selected=status

## Example alert

NA

## Investigation and Action

### Check IBM Cloud Container Registry's cloud scorecard status

You can see the availability of each region of the registry with the following:

- [Availability Metric](https://cloud.ibm.com/scorecard/availabilities/Developer%20Services/Foundation%20Services/container-registry) Go to the `Consumption` tab. This reports as down if all of our AZs in a given region are down.

  - An AZ is considered to be down if the cluster's internal availability check fails. In this case it is taken out of the load balancer pool. If all of the clusters for an AZ are considered to be down, traffic is sent to all clusters.

- [Image Push Metric](https://cloud.ibm.com/scorecard/availabilities/Developer%20Services/Foundation%20Services/container-registry) Go to the `Provision` tab. This reports as down if our push health check fails for 3 minutes in a row for a given region.

  - The push health check pushes an image to the registry once every minute and reports unhealthy if the push fails.

If either of the above metrics report as down, then the on-call engineer should have already been paged out, you can check this in the section below. However, if the on-call engineer has not been paged out, please do so using [Alchemy - Containers - Registry and Build (High Priority)](https://ibm.pagerduty.com/escalation_policies#PVHCBN9) including information about which metric reported as down, and a link to it.

### See if there is an open high priority page for IBM Cloud Container Registry

You can see the Registry's high priority pages in the [#registry-status](https://ibm-argonauts.slack.com/archives/C53RNSFPE) channel.

If there are any high priority pages that have not resolved after 5 minutes:

- This could indicate a problem.
- The registry on-call engineer will have been paged already and will be working to resolve the issue.
- If the on-call engineer has put a message in [#registry-status](https://ibm-argonauts.slack.com/archives/C53RNSFPE) saying that the AZ affected by the high priority page is disabled, then it will not receive any customer traffic, and means that the issue is under control, and will be looked into during office hours.
- If the on-call engineer is not online, please page out the registry-squad using [Alchemy - Containers - Registry and Build (High Priority)](https://ibm.pagerduty.com/escalation_policies#PVHCBN9). Please be clear about what the issue is in the page and include as much information as you can.

### What to do if none of the status checks appear to be showing the registry down

If the Registry scorecard is showing a healthy status, and there are no high priority pages, it is possible that the issue is at the user's end. Please consult the [Registry troubleshooting docs](https://cloud.ibm.com/docs/services/Registry?topic=registry-ts_index#ts_index) or the [IKS image pull troubleshooting docs](https://cloud.ibm.com/docs/containers?topic=containers-ts-app-image-pull).

If there are multiple users reporting similar problems, and you want to engage the on-call engineer, please page them out using the [Alchemy - Containers - Registry and Build (High Priority)](https://ibm.pagerduty.com/escalation_policies#PVHCBN9) escalation policy.

## Escalation Policy

- PagerDuty Escalation Policy: [Alchemy - Containers - Registry and Build (High Priority)
](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)
  - Slack channel: [#registry](https://ibm-argonauts.slack.com/archives/C51A6BYRM)
  - GHE repo link for issues with runbook or PD: [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)

## Automation

None
