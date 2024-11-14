---
layout: default
title: "Remove region from CIS load balancer"
runbook-name: "Remove region from CIS load balancer"
description: "How to escalate to Platform SRE."
category: Partner Center Sell
service: Partner Center Sell
tags: region down, partner-center-sell
link: /partner-center-sell/region-down.html
type: Informational
grand_parent: Armada Runbooks
parent: Partner Center Sell
---

Informational
{: .label }

## Overview
This describes the process for platform SRE how to disable a region from CIS global load balancer.

## Detailed Information

## How to take out region from Global Load Balancer
CIS load balancer can be adjusted by CPUX SRE team. You have to create a PagerDuty incident for CPUX to help you disable selected origin pools.

For this there are 2 options:
1. Create an incident in [CPUX PagerDuty](https://ibm.pagerduty.com/incidents/create?service_id=PW441KB)
2. New Incident via email. Sending an email will automatically trigger a PagerDuty incident creation.
  - cpux@ibm.pagerduty.com

## Further Information

N/A