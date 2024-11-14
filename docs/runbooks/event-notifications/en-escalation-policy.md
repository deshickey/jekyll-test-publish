---
layout: default
title: "Escalation policy for Event Notifications"
runbook-name: "Escalation policy for Event Notifications"
description: "Escalation policy for Event Notifications."
category: Event Notifications
service: Event Notifications
tags: event-notifications
link: /event-notifications/en-escalation-policy.html
type: Informational
grand_parent: Armada Runbooks
parent: Event Notifications
---

Informational
{: .label }

## Overview
This describes the process for service teams to escalate the Event Notifications team via both Service Now and PagerDuty.

## Detailed Information

#### Service Now Incident/CIE

1. Create a new incident in [ServiceNow](https://watson.service-now.com/now/nav/ui/classic/params/target/incident.do)
2. Fill in the mandatory fields:
  - `Detection Source`
  - `Configuration Item` = `event-notifications`
  - `Severity`
    - Sev-1: For Critical customer impacting issues
    - Sev-2: For time sensitive important issues
  - `Short Description`


#### PagerDuty direct call out (High Priority Only)
Escalate to the tribe EventNotificationsOps-High-Support-Escalations by selecting the Configuration Item: EventNotificaitons, Assignment Group: EventNotificationsOps-Support-EscalationPolicy and PagerDuty Service: EventNotificationsOps-High-Support-Escalations.

In addition, you can reach out to the Service team on Slack channel #event-notifications-svc

## Further Information

N/A
