---
layout: default
title: Build Service Down
type: Troubleshooting
runbook-name: 'Build Service Down'
description: How to handle pages about the registry build service being down
service: Registry
link: registry/build-service-down.html
grand_parent: Armada Runbooks
parent: Registry
---

Troubleshooting
{: .label .label-red}

# Build Service Down
How to handle pages about the registry build service being down

## Overview
The build service does docker build in the cloud, builds run on another cluster next to the registry clusters. In each region there are normally three registry clusters (one per zone) and one build cluster which is MZR.

The build's are initiated by customers talking to the normal registry API which then starts the build by talking to the build cluster's kube master.

## Example Alerts
Example:
    - `bx-Build-Check-on-prod-dal09-registry-health-01`
    - `Builds failing in prod-us-south-az2`


## Investigation and Action
### Determine that the registry API is up.
The registry API is required to run builds, first check for PDs relating to the registry service or any of the following registry microservices and deal with them first:
* bouncer
* registry-authorizer
* bob

### Determine that build cluster's kube master is up
The build service depends on the kube master of the build cluster to be available, if there is disruption to the master then this should be dealt with first. Check for armada pages or CIEs.

## Further Debugging/Monitoring
Pages relating to this error will auto-resolve.

## RCA and pCIEs
This page would be a pCIE.

## Escalation Policy
 * PagerDuty Escalation Policy: [Alchemy - Containers - Registry and Build (High Priority)
](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)
  * Slack channel: [Argonauts - registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE)
  * GHE repo link for issues with runbook or PD: [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)
