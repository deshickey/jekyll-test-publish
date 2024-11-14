---
layout: default
description: How to handle a PD for a Prometheus probe failure on armada-api service.
title: armada-api - Prometheus probe failure on armada-api service.
service: Containers-Kube
runbook-name: "armada-api - Prometheus probe failure on armada-api service."
tags: alchemy, armada-api, prometheus, probe
link: /armada/armada-api-probe_failure_service_down.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
The alert triggers when blackbox exporter cannot probe the armada-api service.

Blackbox exporter docs are available [here](https://github.com/prometheus/blackbox_exporter)

Blackbox exporter is performing a probe against the service, and expecting a HTTP 200 return code.

A general background is avaiable in the [global runbook on handling probe failure PDs](./armada-global-probe_failure_service_down.html) runbook.

## Example Alerts

PD alert for `#3575995: bluemix.containers-kubernetes.kubernetes-services_armada-api_probe_failure_service_down.us-south`

## Investigation and Action

1. Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment.

2. In LogDNA run the following query message:":6969/v1" AND message:"Connection timed out"

3. Look for pattern of host in the string upstream: "http://:6969/v1

4. Find the armada-api pod in kubernetes matching the problem host IP. See [How to access the Kubernetes dashboard](./armada-kube-dashboard-access.html) runbook

4. Delete the offending pod

## Escalation Policy

It's likely that you'll need to include the armada-api squad when the actions taken do not resolve this issue.

Review the [escalation policy](./armada_pagerduty_escalation_policies.html) document for full details of which squad to escalate to.
