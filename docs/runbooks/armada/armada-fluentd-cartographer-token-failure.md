---
layout: default
description: Armada-Fluentd-Cartographer is unable to generate tokens for customer clusters
title: armada-fluentd-cartographer - Token Generation Failure
service: armada
runbook-name: "armada-fluentd-cartographer - Token Generation Failure"
tags: wanda, armada, fluentd, cartographer, logging, carrier, metrics, cruiser, customer
link: /armada/armada-fluentd-cartographer-token-failure.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Fluentd-Cartographer Token Generation Failure

## Overview
Armada-Fluentd-Cartographer is unable to generate tokens for customer clusters.

## Example alerts

Following pages are associated with this error
{% capture example_alert %}
  - `CartographerIAMTokenExchangeErrors`

  - `CartographerMetricsServiceTokenExchangeErrors`

  - `CartographerLoggingServiceTokenExchangeErrors`
{% endcapture %}
{{ example_alert }}
## Action to take

## Check the armada-api dashboard for the triggered carrier

To get insight into what service is causing us problems navigate to the [{{ site.data.monitoring.dashboard.name }}]({{ site.data.monitoring.dashboard.link }}).

View Grafana for the triggered carrier, the dashboard is named `Armada ICE`. The graph is named `Token Exchange Errors`.

The graph should give you a good idea of which service IAM, logging, or metrics is in trouble.


## Verify that the IAM servers are up

To perform token exchange, IAM must be up and functioning

1. Check IAM status:
- monitoring: {{ site.data.monitoring.iam.link }}
- cies: {{ site.data.monitoring.iam.cie }}

## Verify that the logging servers are up

To generate logging tokens, the logging service must up and functioning.

1. Check the [{{ site.data.monitoring.logging-service.name }}]({{ site.data.monitoring.logging-service.link }}) for the logging service status


## Verify that the metric servers are up

1. Check the [{{ site.data.monitoring.metrics-service.name }}]({{ site.data.monitoring.metrics-service.link }}) for the metric service status

## Automation
None

## Escalation Policy

Please notify {{ site.data.teams.armada-api.comm.name }} on Argonauts and create an issue [here]({{ site.data.teams.armada-api.link }})

- If IAM is down, then escalate / generate a page against [{{ site.data.teams.IAM.escalate.name }}]({{ site.data.teams.IAM.escalate.link }})
- If the logging servers are down, then escalate generate a page against logging. [{{ site.data.teams.logging-service.escalate.name }}]({{ site.data.teams.logging-service.escalate.link }})
- If the metric servers are down, then escalate generate a page against the metrics. [{{ site.data.teams.metrics-service.escalate.name }}]({{ site.data.teams.metrics-service.escalate.link }})
- If none of the services are down, then escalate the page against armada ICE. [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})
