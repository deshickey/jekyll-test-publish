---
layout: default
description: armada-fluentd-cartographer has deadlocked
title: armada-fluentd-cartographer orchestrator deadlock
service: armada
runbook-name: "armada-fluentd-cartographer orchestrator deadlock"
tags: armada, fluentd, cartographer, logging, carrier, wanda, metrics
link: /armada/armada-fluentd-cartographer-orch-deadlock.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Fluentd-Cartographer orchestrator deadlock troubleshooting

## Overview

Armada-Fluentd-Cartographer has deadlocked.

## Example alert
{% capture example_alert %}
- `CartographerOrchestratorDeadlock`
{% endcapture %}
{{ example_alert }}

## Action to take

### Restart armada-fluentd-cartographer on the affected carrier

1. ssh into the master for the triggered carrier. The list of carriers with their masters can be found in the [{{ site.data.monitoring.cfs-inventory.name }}]({{ site.data.monitoring.cfs-inventory.link }})
2. Delete the cartographer pod to resolve the deadlock. `kubectl -n armada delete pods -l app=armada-fluentd-cartographer`.
3. If the deadlock alert doesn't resolve after 5 minutes; follow escalation policy.

## Escalation Policy
Please notify {{ site.data.teams.armada-api.comm.name }} and create an issue here {{ site.data.teams.armada-api.link }}.  

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

## Automation
None