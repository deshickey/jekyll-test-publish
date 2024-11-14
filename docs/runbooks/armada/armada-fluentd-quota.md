---
layout: default
description: Determining if quota for IBM Logging service has been reached and how to request a quota increase. 
title: armada-fluentd - Quota Troubleshooting
service: armada-fluentd
runbook-name: "armada-fluentd - quota troubleshooting"
tags: wanda, fluentd, armada-fluentd
link: /armada/armada-fluentd-quota.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains information on how to figure out if you've gone over quota with the IBM Logging service and
how to increase your quota. 

## Example alert
None

## Investigation and Action 

## What going over quota looks like

You will not see any logs when you log in to kibana


## Determining if you've gone over quota

To determine if you've gone over quota you can follow the directions here: [{{ site.data.teams.logging-service.troubleshooting.quota.name }}]({{ site.data.teams.logging-service.troubleshooting.quota.link }})

If you're logged in to Kibana, switch the space you want to check, then go to 

    `https://LOGGING_SERVICE_URL/quota/usage`.
   

### Requesting a larger quota:

To request a larger quota, open a issue with the logging service team: [{{ site.data.teams.logging-service.name }}]({{ site.data.teams.logging-service.issue }})

## Automation 
None

## Escalation Policy
For more help in troubleshooting quota issues during business hours go to [{{ site.data.teams.logging-service.comm.name }}]({{ site.data.teams.logging-service.comm.link }}).

Escalation for quota issues can be sent to the [{{ site.data.teams.logging-service.escalate.name }}]({{ site.data.teams.logging-service.escalate.link }}) escalation policy.
