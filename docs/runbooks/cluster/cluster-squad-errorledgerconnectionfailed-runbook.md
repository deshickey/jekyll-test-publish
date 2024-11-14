---
layout: default
title: armada-cluster - ErrorBillingLedgerConnectionFailed & ErrorLedgerUnclassified
type: Alert
runbook-name: "armada-cluster - ErrorBillingLedgerConnectionFailed & ErrorLedgerUnclassified"
description: Armada cluster - ErrorBillingLedgerConnectionFailed & ErrorLedgerUnclassified
service: armada-cluster
link: /cluster/cluster-squad-errorledgerconnectionfailed-runbook.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

These alerts will trigger when more than 20 occurrences of an error from the IKS Billing Ledger.

## Example Alerts

PD title:

`bluemix.containers-kubernetes.prod-dal12-carrier2.armada-cluster/worker_ledger_unclassified_errors/ErrorLedgerUnclassified.us-south`

## Actions to Take

The steps below describe the operations to perform to determine the appropriate action.

1. Restart the armada-cluster pods on the affected carrier for each alert received
1. Monitor the alert for 15-30 minutes to ensure it resolves
1. If the alert does not resolve - Follow the [escalation policy](#escalation-policy)

---

## Escalation Policy

If further assistance is required from the development squad, then escalate the alert via the [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) PD escalation policy.
