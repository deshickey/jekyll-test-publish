---
layout: default
description: Troubleshooting increased Hypersync API latency in armada-sync
title: Troubleshooting increased Hypersync API latency in armada-sync
service: armada-sync
runbook-name: "Troubleshooting increased Hypersync API latency in armada-sync"
link: /armada/armada-sync-hypersync-latency.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Troubleshooting increased Hypersync API latency in armada-sync

## Overview

Armada-sync emits events about the lifecycle of certain resources (such as clusters) to be synced from ETCD to GhoST. Failing to do so results in clusters not being created.
This runbook describes how to deal with increased latency to the BSS Hyperwarp Hypersync API. The goal is to identify the root cause and, if necessary, escalate the issue.

## Example Alerts

- `staging.containers-kubernetes.stage-dal10-carrier103.armada_sync_hypersync_latency_critical.us-south` (see [example](https://ibm.pagerduty.com/alerts/Q38YKILPPF3XBW))

## Actions to take
### Verify Hypersync API

1. Check the exact latency of the slowest requests going to the Hypersync API by running the following prometheus query:
```
histogram_quantile(0.9, sum by(le)(rate(serviceDependencies_http_req_duration_seconds_bucket{service_name="armada-sync",method="send_event"}[10m])))
```
2. Keep monitoring for a few minutes to see if it continues to increase or starts decreasing. If it's decreasing, open an issue for dev to investigate (see GitHub URL under Escalation Policy).
3. If the latency is not decreasing:
   1. Check [#bss-issues](https://ibm.enterprise.slack.com/archives/C2FCRK99V) and [#hyperwarp-on-duty](https://ibm.enterprise.slack.com/archives/CD464Q9AA) to see if there is any issue with BSS/Hyperwarp. Reach out to them if others have not. 
   2. If the issue is still not identified or cannot be resolved, proceed to escalate the page.

## Escalation Policy
Escalate the issue to the armada-api squad as per their [escalation policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada_pagerduty_escalation_policies.html)

Slack Channel: https://ibm-argonauts.slack.com/archives/C53NQCME0 (#armada-ironsides)
GitHub Issues: https://github.ibm.com/alchemy-containers/armada-ironsides/issues