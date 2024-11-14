---
layout: default
description: Troubleshooting Monitoring Graph Snapshots PDs
service: Network Intelligence
title: Network Intelligence Monitoring Graph Snapshots
runbook-name: Network Intelligence Monitoring Graph Snapshots
playbooks: ["NoPlaybooksSpecified"]
failure: ["NoFailuresSpecified"]
ownership-details:
  escalation: "Alchemy - Network Intel 24x7"
  owner-link: "https://ibm-cloudplatform.slack.com/messages/netint"
  corehours: "UK"
  owner-notification: False
  group-for-rtc-ticket: Runbook needs to be Updated with group-for-rtc-ticket
  owner: "Network Intelligence [#netint]"
  owner-approval: False
link: /netint_monitoring_graph_snapshots.html
type: Troubleshooting
category: Armada
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview


---

## Example alerts

None

---

## Investigation and Action

Check that <https://alchemy-dashboard.containers.cloud.ibm.com/> is up.
Check that you can see the images: <https://alchemy-dashboard.containers.cloud.ibm.com/stage-dal09/stage/network/prometheus/render/dashboard/db/vyatta-dashboard?orgId=1&var-target=stage-dal09-firewall-vyattaha1-01&var-target=stage-dal09-firewall-vyattaha1-02&var-pair=stage-dal09-firewall-vyattaha1&from=now-35d&to=now&width=1900>
Check that <https://github.ibm.com/alchemy-conductors/compliance-networkmonitoring-records> has been updated once in the last month
Else reassign to netint.

---

## Escalation Policy

Alchemy - Network Intel 24x7

---

## Automation

None

---
