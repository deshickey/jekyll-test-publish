---
layout: default
description: Armada-Fluentd-Cartographer is unable failing to communicate with customer API servers
title: armada-fluentd-cartographer - Cruiser communication failure
service: armada
runbook-name: "armada-fluentd-cartographer - Cruiser communication failure"
tags: wanda, armada, fluentd, cartographer, logging, cruiser, patrol
link: /armada/armada-fluentd-cartographer-cruiser-request-fail.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Fluentd-Cartographer Unable to communicate with customer clusters

## Overview

Armada-Fluentd-Cartographer is experiencing a high failure rate when communicating with customer API servers.

## Example alerts
{% capture example_alert %}
Following pages are associated with this error
- `CartographerCustomerApiserverRequestErrors`
{% endcapture %}
{{ example_alert }}

## Action to take

### Verify network stablity

This will verify that the carrier's network is healthy and can reach customer clusters.

1. Log onto carrier master
1. Get a couple active customer clusters by running:
`kubectl -n kubx-masters get pods -o wide | grep Running`
the cluster ID is the longest hex string (after `master-`)
1. Pick an active customer cluster in the carrier, note the cluster ID.
1. Confirm that the customer's API server is reachable by performing `kubx-kubectl <clusterid> get pods --all-namespaces`
1. If the command succeeds multiple times with multiple active clusters, then we have verified that the network is healthy.


## How to get an active customer cluster

These are the instructions for getting an active cluster.

1. Go to the prometheus dashboard for the given environment. [{{ site.data.monitoring.dashboard.name }}]({{ site.data.monitoring.dashboard.link }})
1. Use this query to list the active cluster IDs `sum(armada_master{desired_or_actual="actual", state="deployed"}) by (cluster_id)`

## Automation
None

## Escalation Policy

- If you have verified that the network between the carrier and customer clusters is healthy. Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})
- If it appears that the network is not healthy, escalate page to [{{ site.data.teams.armada-network.escalate.name }}]({{ site.data.teams.armada-network.escalate.link }})
