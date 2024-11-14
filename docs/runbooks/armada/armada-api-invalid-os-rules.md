---
layout: default
description: How to deal with invalid OS rules alert
title: armada - How to deal with invalid OS rules alert
service: armada-api
runbook-name: "Dealing with invalid OS rules alert"
tags: alchemy, armada, os-rules
link: /armada/armada-api-invalid-os-rules.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with invalid OS rules alert. A pCIE is not required, but action is, as new armada-api pods will refuse to start up leaving the deployment in an unstable state if anything were to happen.

## Example Alerts

- `bluemix.containers-kubernetes.prod-dal10-carrier1.invalid_os_rules.us-south`


## Investigation and Action
More than likely this alert is caused by a recent `armada-secure` promotion.
Check what the latest armada-secure promotion contains, if this file was changed: [secure/armada/supported-oses.yaml](https://github.ibm.com/alchemy-containers/armada-secure/commits/HEAD/secure/armada/supported-oses.yaml) it is likely the problem.

The secure promotion should be reverted/prevented to continue in more regions. 
Notify the bootstrap team at #armada-bootstrap about secure promotions being blocked due to an invalid OS rules yaml.

As this event triggers only once and `armada-api` gets stuck in this state, the alert is set to be active for at least 3 hours, so it can't be ignored easily. To see if the problem was resolved, check if `armada-api` pods are all healthy in the region (like 10/10 ready).   

## Escalation Policy
If there were no recent `armada-secure` promotion or the revert did not solve the problem escalate the page to the [armada-api](./armada_pagerduty_escalation_policies.html) escalation policy so the squad can help figure out what happened.
