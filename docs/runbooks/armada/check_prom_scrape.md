---
layout: default
description: Runbook for fixing prometheus can't scrape metrics
service: "Infrastructure"
title: Check Prometheus Scraping Issue
runbook-name: Check Prometheus Scraping Issue
failure: [" check-prom-scrape DOWN "]
link: /armada/check_prom_scrape.html
type: Troubleshooting
playbooks:  [<add Ansible-playbook command to automate Runbook. Separate each Playbook with a comma and surround with inverted commas>]
ownership-details:
- owner: <replace with squad that owns the service/group that owns this pager. Surround with inverted commas>
  owner-link: <replace with link to access the owner. Surround with inverted commas>
  corehours: <replace with core hours, e.g. US. Surround with inverted commas>
  escalation: <replace with details of which group to escalate issue to. Surround with inverted commas>
  owner-approval: <Mark as 'true' if owner approval is required for runbook/ansible-playbook actions. Otherwise mark as 'false'>
  owner-notification: <Mark as 'true' if owner should be notified of runbook/ansible-playbook results. Otherwise mark as 'false'>
  group-for-rtc-ticket: <replace with group for RTC ticket info. Surround with inverted commas>
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

The alert is triggered from sensu

Config is [here](https://github.ibm.com/alchemy-conductors/sensu-uptime/tree/master/docker/sensu-prom)

## PagerDuty Alert Examples

Example PD alerts

```
 check-prom-scrape-prod-dal10 DOWN: Error: Prometheus failed to scrape metrics
```

From the service_url in the pagerduty details, you could get the `<WORKER-IP>, <TARGET_ENV>, <CARRIER_NAME>` which would be used later. For example:

```
service_url   http://10.130.231.176:30900/dev-mex01/carrier5/prometheus
<WORKER-IP>:       10.130.231.176
<TARGET_ENV>:      dev-mex01
<CARRIER_NAME>:    carrier5
```

# Purpose

This check queries `prometheus_target_interval_length_seconds` to check whether prometheus is successfully scraping metrics. If `prometheus_target_interval_length_seconds` is zero, then an alert is triggered.


## Error 1: Failed to query prometheus URL

This alert indicates the check failed to query prometheus. Please check the `response_body` first.

If it is `CRITICAL: Failed to query prometheus URL with error: context deadline exceeded`, it always caused by prometheus performance issue which can't return the query in time. In this case, the PD should auto-resolve few minutes later.

If it doesn't auto-resolve within 30 minutes, please see [escalation](#escalation) details section.

If it includes `dial tcp <WORKER-IP>:30900: i/o timeout`, it indicates the prometheus is down.

Other sensu alerts described [here](./armada-ops-sensu-uptime-prometheus-down.html) will be triggering - follow this runbook to resolve the issues.  


## Error 2: Prometheus failed to scrape metrics

This alert indicates prometheus is failing to scrape metrics.

It is likely that prometheus is down and other sensu alerts described [here](./armada-ops-sensu-uptime-prometheus-down.html) will be triggering.  

Follow the linked runbook for instructions on verifying prometheus is up and fixing prometheus if it is down.

If you are unable to resolve the issue, please see [escalation](#escalation) details section.

# Escalation

Armada-ops is the responsibility of the SRE team so in the first instance, work with the members of the local SRE team to investigate the issue in more detail.

If you are unable to resolve, then post in the notification in #armada-ops slack channel and create issue in [armada-ops](https://github.ibm.com/alchemy-containers/armada-ops) and the UK team will assist.
