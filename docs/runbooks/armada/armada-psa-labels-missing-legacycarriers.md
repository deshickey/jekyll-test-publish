---
layout: default
description: How to troubleshoot missing PSA labels on Legacy Carrier namespaces
title: troubleshoot missing PSA labels on Legacy Carrier namespaces
service: armada
runbook-name: "troubleshoot missing PSA labels on Legacy Carrier namespaces"
tags: alchemy, armada, psa, podsecurityadmission
link: /armada/armada-psa-labels-missing-legacycarriers.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to troubleshoot missing PSA labels on Legacy carriers namespaces .

## When are these alerts triggered

We receive notifications when namespaces lack the necessary PSA labels.

## Investigation and Action

Check if cluster-updater pod is running fine . 
  `kubectl get pods -A  | grep cluster-updater`

Verify that the necessary files for PSA configuration are present in the secure Git folder.
For ex , for ap-south Carriers [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/ap-south/hubs/prod-syd01-carrier1/armada-psa-resources.yaml) .

Create a GHE issue against [armada-carrier](https://github.ibm.com/alchemy-containers/armada-carrier/issues).

This is high priority Incident , so immediately Escalate PD incident to Carrier India Team / India SRE Team.

## Escalation Policy

Esclation policy for [Carrier Team](https://ibm.pagerduty.com/escalation_policies#PDJ7N4P)

