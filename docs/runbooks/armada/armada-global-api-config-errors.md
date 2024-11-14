---
layout: default
title: armada-global-api is misconfigured
type: Alert
runbook-name: armada-global-api is misconfigured
description: armada-global-api is misconfigured
category: Armada
service: Containers
tags: armada, global-api, config, source
link: /armada/armada-global-api-config-errors.html
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Global-API Config Errors

## Overview

armada-global-api is misconfigured, which can lead to user-visible errors.

These alerts should only occur as a result of manual actions, so this runbook corrects the previous invalid action.

## Example alert
- `ArmadaGlobalAPIConfigFailure`

## Action to take

1. Identify the `issue` from the alert description to find the kind of config failure.
2. Check this table for next steps:

| Issue                | Action                                                                                                                                                                | Description                                                             |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `no_enabled_sources` | [Choose a source](#choosing-a-source-to-enable), then [enable](#enable-boolean-feature-flags) at least one of the `source-*` feature flags and monitor for 5 minutes. | All of the `armada-global-api.source-*` feature flags are set to false. |

3. If the above action does not resolve the issue within 5 minutes, escalate.
4. If resolved, notify `@ironsides` in Slack `#armada-api` about the change. Ironsides may take further action if needed.

### Choosing a source to enable

We have multiple sources of data in global-api: Ghost and regional API. In LaunchDarkly the flag names look like `armada-global-api.source-*`.
If you're selecting a flag to enable, use the below info to make that determination:

* If in doubt, enable `source-regional-api`. It's the best source 99% of the time. See other points for why this might not be a good idea for your alert.
* If Ghost has data integrity issues, `source-ghost` may be disabled to avoid returning invalid data.
* If Ghost has an outage, `source-ghost` may be disabled to avoid hammering their APIs and returning invalid results.
* If armada-api or etcd have issues, `source-regional-api` may be disabled to relieve strain on API calls to each region.

### Enable Boolean Feature Flags

To enable a boolean feature flag:

1. Start an ops train, using a template like this (replace `Ghost` with the flag you're changing):
```
Squad: ironsides
Service: Armada
Title: Enable data coming from Ghost
Environment: all
Details: Enable data coming from Ghost. Changes feature flag `armada-global-api.source-ghost` from `false` to `true`
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 30m
Ops: true
BackoutPlan: Disable data coming from Ghost by flipping the flag back to `false`
```
2. Visit the LaunchDarkly page for the flag, e.g. [`armada-global-api.source-ghost`][ghost], [`armada-global-api.source-regional-api`][regional-api]
3. Find all rules in the list equal to `false` and change their dropdowns to `true`. It's expected this could affect external users.
4. Click `Save Changes`


[regional-api]: https://app.launchdarkly.com/armada-users/production/features/armada-global-api.source-regional-api
[ghost]: https://app.launchdarkly.com/armada-users/production/features/armada-global-api.source-ghost

## Escalation Policy
Please notify {{ site.data.teams.armada-api.comm.name }} and create an issue here {{ site.data.teams.armada-api.link }}.  

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

## Automation
None
