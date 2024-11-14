---
layout: default
description: Checklist for confirming recovery after vyatta is down
service: Network Intelligence
title: Network Intelligence Recovery Checklist
runbook-name: Network Intelligence Recovery Checklist
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
link: /netint_recovery_checks.html
type: Troubleshooting
category: Armada
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

**This runbook is currently only for members of NetInt, if you have been paged with one of the following alerts and are not in NetInt please redirect the page to `Alchemy - Network Intel 24x7`**

## Overview
This runbook contains information on what checks should be performed as a part of the recovery of a Vyatta.

When a vyatta is recovered, the following items need to be confirmed before it can be asserted that it is functional again:

  - Tunnels
  - OSPF
---

## Example alerts

None
---

## Investigation and Action

## Issue: Confirming Tunnels are up

There are likely multiple checks that indicate that tunnels are down these checks should auto resolve.  Do the following to confirm tunnel status prior to checks auto resolving.

1. Check the below following section (tunnel groups) to understand which tunnels have gone down and what the problem is.

2. In the [#netint](https://ibm-argonauts.slack.com/messages/C53PUD2TE) channel there is a slack bot called netmax. Sending the following message should report a more detailed list of the tunnel status:

   >@netmax: tunnel status

   If netmax does not respond, or the tunnels are reported as being live, contact a member of the netint squad to further diagnose issues and ensure the uptime-check microservice is running (see Self-Check failed section)

#### Tunnel Groups

* **Bluemix**: If the Bluemix tunnel is down, page a member of the netint squad to restart the tunnel and diagnose further issues.

* **SOS_Alchemy**: If the SOS tunnel is down, raise a defect in [firewall-requests](https://github.ibm.com/alchemy-netint/firewall-requests/). **No page required**. These tunnels aren't critical so the netint team do not need to be paged out if they have gone down. 

---

## Confirm OSPF

To confirm that OSPF has recovered follow [this runbook.](./netint_alertmanager_checks.html#issue-no-tunnel-is-routing-to-bluemix-gorouter-ip-on-vyatta)

---

## Escalation Policy

None

---

## Automation

None

---
