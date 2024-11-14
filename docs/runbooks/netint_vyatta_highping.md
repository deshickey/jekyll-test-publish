---
layout: default
description: Investigating Vyatta for High Ping/Conntrack
service: Network Intelligence
title: Network Intelligence Vyatta Performance Investigation
runbook-name: Network Intelligence Vyatta Performance Investigation
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
link: /netint_vyatta_highping.html
type: Troubleshooting
category: Armada
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

Updated: Vyattas are no longer sitting in front of Carriers/Tugboats anymore. Rebooting vyattas will do nothing for ping.

The only course of action is to raise a ticket with Softlayer.

---

## Example Alerts

https://ibm.pagerduty.com/incidents/P0QA5QT
https://ibm.pagerduty.com/incidents/PUZY2YZ

---

## Investigation and Action

Raise a SL ticket in the 531277 Account, stating that there is high ping between two environments. (This information will be in the PD alert). And ask them to investigate why that is.

They may be doing maintanance, or upgrades which could be legitimate reasons for high ping. However sometimes they've made routing mistakes and not known, so it is worth raising the question to them.

---

## Escalation Policy

Alchemy - Network Intel 24x7

Now the vyattas are not infront of the VLANs, there is no reason to page us out for any reboots of vyattas, or to raise a SL ticket. However if there is networking questions that they ask in response, and it's a production Carrier, you can page us out to help answer. Otherwise it can wait until office hours. (Mon-Fri 9-5 UK only).

---
