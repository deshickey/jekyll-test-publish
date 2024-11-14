---
layout: default
title: IBM Cloud App Configuration Escalation Policy
type: Informational
runbook-name: "IBM Cloud App Configuration Escalation Policy"
description: "IBM Cloud App Configuration Escalation Policy"
service: App Configuration
tags: app-configurations
link: /app-configurations/escalation.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This describes the process for service teams to escalate the App Configurations team via both Service Now and PagerDuty.

## Detailed Information

1. Create a new incident in [ServiceNow](https://watson.service-now.com/now/nav/ui/classic/params/target/incident.do)
2. Fill in the mandatory fields:
  - `Detection Source`
  - `Configuration Item` = `apprapp`
  - `Severity`
    - Sev-1: For Critical customer impacting issues
    - Sev-2: For time sensitive important issues
  - `Short Description`

## PagerDuty direct call out (High Priority Only) 

Escalate to the tribe [AppRappOps-High-Support-Escalations](https://ibm.pagerduty.com/service-directory/PVZZI5V) by selecting the Configuration Item: AppRapp, Assignment Group: [AppRappOps-Support-EscalationPolicy](https://ibm.pagerduty.com/escalation_policies#POBMBN6) and PagerDuty Service: [AppRappOps-High-Support-Escalations](https://ibm.pagerduty.com/service-directory/PVZZI5V). 

In addition, you can reach out to the Service team on Slack channel #app-configuration-svc
