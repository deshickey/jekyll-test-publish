---
layout: default
description: Runbook for pagerduty incidents raised by the App Configuration service healthcheck failures.
service: "App Configuration"
title: App Configuration Healthcheck PagerDuty Guide
runbook-name: App Configuration Healthcheck PagerDuty Guide
link: /app-configurations/healthcheck_alert.html
type: Alert
parent: App Configs
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook is to explain how to take an action on `App Configuration health check failure` alert.  

It is a App Configuration health check runs every 1 minute and takes appropriate actions in case of failure. 

## Example alert(s)

There would be 2 type of alert from the [Synthetics](https://synthetics.cloud.ibm.com/)

- When synthetics detects potential healthcheck failures in App Configuration service
```
app-config-synthetics.ping.prod-apprapp_tor.gateway_health failure
```

## Automation

Synthetics runs health check pings for every 1 minute
Link: https://synthetics.cloud.ibm.com

## Actions to take 
Confirm the health end points of the region displays as Live.  To confirm this, access the health end point of the region mentioned below. 

End points of various regions are - 
* Sydney (au-syd) - https://au-syd.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status
* Dallas (us-south) - https://us-south.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status
* London (eu-gb) - https://eu-gb.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status
* Washington (us-east) - https://us-east.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status
* Frankfurt (eu-de) - https://eu-de.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status
* Toronto (ca-tor) - https://ca-tor.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status
* Osaka (jp-osa) - https://jp-osa.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status
* Tokyo (jp-tok) - https://jp-tok.apprapp.cloud.ibm.com/apprapp/gateway/v1/health/status


Verify the overall_health is Up by clicking on the above link

## Escalation Policy

If the overall Health is not Live, then please follow the 
[Escalation Policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/escalation.html)