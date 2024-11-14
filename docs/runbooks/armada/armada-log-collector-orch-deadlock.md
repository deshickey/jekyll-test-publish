---
layout: default
description: armada-log-collector has deadlocked
title: armada-log-collector orchestrator deadlock
service: armada
runbook-name: "armada-log-collector orchestrator deadlock"
tags: armada, log-collector, logging, carrier, wanda, metrics
link: /armada/armada-log-collector-orch-deadlock.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Log-Collector orchestrator deadlock troubleshooting

## Overview

Armada-Log-Collector has deadlocked.

## Example alert
{% capture example_alert %}
- `LogCollectorOrchestratorDeadlock`
{% endcapture %}
{{ example_alert }}

## Action to take

### Restart armada-log-collector on the affected carrier

1. ssh into the master for the triggered carrier. The list of carriers with their masters can be found in the [{{ site.data.monitoring.cfs-inventory.name }}]({{ site.data.monitoring.cfs-inventory.link }})
2. Delete the armada-log-collector pod to resolve the deadlock. `kubectl -n armada delete pods -l app=armada-log-collector`. Note, there is another
deployment where the pods are called armada-log-collector-ds, you don't need to restart these pods.
3. If the deadlock alert doesn't resolve after 5 minutes; follow escalation policy.

## Escalation Policy
Please notify {{ site.data.teams.armada-api.comm.name }} and create an issue here {{ site.data.teams.armada-api.link }}.  

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

## Automation
None