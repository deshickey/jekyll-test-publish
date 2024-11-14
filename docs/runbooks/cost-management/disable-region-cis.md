---
service: Cost Management
title: "Remove a Region from CIS Load Balancer"
runbook-name: "Remove a Region from CIS Load Balancer"
description: "Instructions for escalating to CPUX for removing a region from CIS"
category: Cost Management
type: Operations # Alert, Troubleshooting, Operations, Informational
tags: cost, cost management, cost-management, dreadnought, service team, service, escalation, incident, pagerduty, cpux
link: /cost-management/cost-region-down.html
failure: []
playbooks: []
layout: default
grand_parent: Armada Runbooks
parent: Cost Management
---

Ops
{: .label .label-green}

## Overview

This runbook describes the process to disable a region from the CPUX-managed CIS global load balancer.

## Detailed Information

Any CIS load balancer modifications must be done by a member of the CPUX SRE team. To reach them, a PagerDuty incident must be created. There are two ways to achieve this.

## Detailed Procedure

## Direct Incident Creation on PagerDuty

Create an incident in [CPUX PagerDuty](https://ibm.pagerduty.com/incidents/create?service_id=PW441KB){:target="_blank"}.

## E-mail Incident Creation

Send an e-mail to `cpux@ibm.pagerduty.com`. This will automatically trigger a PagerDuty incident creation.

## Further Information

* [Cost Management internal team documentation](https://github.ibm.com/dataops/cost-management-docs-internal){:target="_blank"}
* [CPUX docs on Disabling and Enabling an Origin in CIS](https://pages.github.ibm.com/ibmcloud/CPUX-DevOps-Docs/content/runbooks/origin-CIS/){:target="_blank"}
