---
layout: default
description: Runbook for pagerduty incidents raised by the Event Notifications service healthcheck failures.
service: "Event Notifications"
title: Event Notifications Healthcheck PagerDuty Guide
runbook-name: Event Notifications Healthcheck PagerDuty Guide
link: /event-notifications/en-healthcheck-alert.html
type: Alert
grand_parent: Armada Runbooks
parent: Event Notifications
---

Alert
{: .label .label-purple}

## Overview

This runbook is to explain how to take an action on `Event Notifications health check failure` alert.  

It is a Event Notifications health check runs every 1 minute and takes appropriate actions in case of failure. 

## Example alert(s)

There would be 2 type of alert from the [Synthetics](https://synthetics.cloud.ibm.com/)

- When synthetics detects potential health check failures in Event Notifications service
```
event-notification-synlab.ping.en_prod_ca-tor_private.health_overall failure
```

## Automation

Synthetics runs health check pings for every 1 minute
Link: https://synthetics.cloud.ibm.com

## Actions to take 
Confirm the health end points of the region displays as Live.  To confirm this, access the health end point of the region mentioned below. 

End points of various regions are - 
* Sydney (au-syd) - https://au-syd.event-notifications.cloud.ibm.com/api-gateway/status
* Dallas (us-south) - https://us-south.event-notifications.cloud.ibm.com/api-gateway/status
* London (eu-gb) - https://eu-gb.event-notifications.cloud.ibm.com/api-gateway/status
* Frankfurt (eu-de) - https://eu-de.event-notifications.cloud.ibm.com/api-gateway/status
* Madrid (eu-es) - https://eu-es.event-notifications.cloud.ibm.com/api-gateway/status
* BNPP (eu-fr2) - https://eu-fr2.event-notifications.cloud.ibm.com/api-gateway/status
* Toronto (ca-tor) - https://ca-tor.event-notifications.cloud.ibm.com/api-gateway/status
* Osaka (jp-osa) - https://jp-osa.event-notifications.cloud.ibm.com/api-gateway/status
* Tokyo (jp-tok) - https://jp-tok.event-notifications.cloud.ibm.com/api-gateway/status


Verify the overall_health is Up by clicking on the above link

## Escalation Policy

If the overall Health is not Live, then please follow the [escalation steps](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-escalation-policy.html) to engage the service team.
