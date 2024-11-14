---
layout: default
description: What to do with VrrpErrorState alert
service: Network Intelligence
title: Network Intelligence VrrpErrorState alert
runbook-name: Network Intelligence VrrpErrorState
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
link: /netint_vrrperrorstate.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

When vyattas get into a mismatched VRRP state, they will be dropping requests depending

This check should be going directly to the Network Intelligence squad.

---

## Detailed Information

---

### Solution

1. Log into both nodes of the vyatta pair, and issue `show vrrp`.

2. One of will be have an error state (2 or 3) for atleast one of the interfaces. If not, just check one node is master and the other backup and the page should automatically resolve.

3. Reboot the node that is in the error state. The other node should become the MASTER node if it wasn't already.

4. Ensure that the other node that was in the error state comes back, and goes into the BACKUP state.

---
