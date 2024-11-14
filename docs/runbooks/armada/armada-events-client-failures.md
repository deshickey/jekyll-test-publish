---
layout: default
description: How to deal with armada-events-client failures.
title: armada - dealing with armada-events-client failures.
service: armada
runbook-name: "Dealing with armada-events-client failures."
tags: alchemy, armada, audit, events, events-client
link: /armada/armada-events-client-failures.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with events-client failures

## Example Alerts

{% capture example_alert %}
- `ArmadaEventsClientATWriteFailures`
{% endcapture %}
{{ example_alert }}

## Investigation and Action
### Determine the type of error

If you came from a PagerDuty alert, you should have received the `error` label.

Otherwise, determine the type of error for the alert via Prometheus

1) Begin by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `Prometheus` icon in the alerted environment.

2) Click on the `Alerts` tab in Prometheus, and find `ArmadaEventsClientATWriteFailures`

3) You should see at least one firing alert. Take a note of the `error` label.

### Action to take

If `error` label indicates some kind of disk error (e.g. `write /var/log/at/containers-kubernetes-api-audit-logs-501/audit-57AtlFXdft.log: no space left on device`), then most likely the disk is full. Follow the [runbook for handling disk full errors](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-node-filesystem-space.html). You can find what pod produces this error by looking at the `kubernetes_pod_name` label on the alert.

Otherwise, create [create a GHE issue](#create-a-ghe-issue) and follow the escalation policy

### Create a GHE issue

Raise a [GHE](https://github.ibm.com/alchemy-containers/armada-ironsides/issues/new) issue against `ironsides` squad.

Add results from the Prometheus query to the GHE issue raised in the earlier steps.

## Escalation Policy

Please notify {{ site.data.teams.armada-api.comm.name }}.
- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

## Automation
None
