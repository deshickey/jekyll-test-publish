---
layout: default
description: How to deal increasing API response time.
title: armada - dealing with increasing API response time.
service: armada
runbook-name: "Dealing with increasing API response time"
tags: alchemy, armada, response, time
link: /armada/armada-api-response_time_increasing.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with increasing API response times and how to determine the cause.

## Example Alerts

- `bluemix.containers-kubernetes.prod-dal10-carrier1.response_time_increasing.us-south`


## Investigation and Action
1. Run the Prometheus query for the average response time for all APIs:
`sum(armada_api_response_seconds_sum) / sum(armada_api_response_seconds_count)`

    Monitor it for a few minutes to see if continue to increase or starts decreasing. If they are leveling back off, open an issue for dev to investigate (See bottom of this page). If they are increasing, they should continue with the runbook below.

2. Identify if the majority of the APIs are increasing, or just a subset. Run the Prometheus query to show the average for each API:
`sum(armada_api_response_seconds_sum) by (action, path) / sum(armada_api_response_seconds_count) by (action, path)`

    If the increase is specific to only a few APIs, look for alerts that may be related which indicate the underlying issue. For example, if it's only 'Get Kube Config' related calls, there is an issue with communication with customer masters taking a long. Look for alerts relating to that.

    If it's not only a small subset of APIs then is most likely caused by an issue with a dependency, continue with the runbook below.

3. Check for degraded network performance alerts and follow its runbook if found.

4. Check for degraded etcd performance alerts.

    Check if there are current events for either:
  - `armada_etcd_traffic_over_threshold_critical` if so follow its [runbook](https://pages.github.ibm.com/alchemy-conductors/-documentation-pages/docs/runbooks/armada/etcd-traffic-over-threshold.html )
  - `armada_etcd_degraded_performance` - this is warning with no runbook. Check if when this warning goes away the API response time alert in question also goes away. 

If the above does not apply, proceed to escalate the page (see below).

## Escalation Policy

### Is it a pCIE?
If any of the above alerts apply follow the pCIE advice in its runbook. If not and there are incoming reports of API requests timing out for users, then a pCIE is required. Otherwise a pCIE is not required at this time.

### For all issues

Escalate the page to the [armada-api](./armada_pagerduty_escalation_policies.html) escalation policy so the squad can start working the issue.

Raise a [GHE issue](https://github.ibm.com/alchemy-containers/armada-ironsides/issues/new/choose) to document the analysis and investigation. 
