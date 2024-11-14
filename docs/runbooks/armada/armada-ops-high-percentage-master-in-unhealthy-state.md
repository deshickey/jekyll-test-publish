---
layout: default
description: How to handle high percentage masters are in unhealthy state.
title: armada-ops - How to handle high percentage masters are in unhealthy state.
service: armada-ops
runbook-name: "armada-ops - How to handle high percentage masters are in unhealthy state."
tags: armada-ops, master, health
link: /armada/armada-ops-high-percentage-master-in-unhealthy-state.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle alert which reports high percentage masters are in critical state.

## Example alerts

The alert you received should look similar to:

{% capture example_alert %}
~~~
Labels:
- alertname = HighPercentageMasterInUnhealthyState
- alert_situation = high_percentage_master_in_unhealthy_state
- environment = prod-dal12-carrier2
- service = armada-ops
- severity = warning
~~~
{% endcapture %}
{{ example_alert }}

## Actions to take

### Understanding the impact

If, in a production environment, this alert is triggering, then a [pCIE may be required](#discussions-to-have-in-the-cie-channel).

When this alert triggers, we have to monitor the situation in more detail as kubernetes may well be working to resolve the issue automatically.

### Review other alerts 

Check if there are any infrastructure issues, like network or IAM issue. 

### Discussions to have in the cie channel

First, start a discussion in the `#containers-cie` channel stating this alert has triggered and investigation is under way.

Key information we are after to understand if this is a CIE is;

- The percentage of cruiser masters unavailable
- The number of cruiser masters unavailable
- The trend of these figures - are they increasing or decreasing and what is the rate of the increase/decrease.

If the numbers have plateaued above 1% and over 50 cruiser masters are affected, or the numbers are increasing then invoke the CIE process.  The pCIE process is [documented here](../clm-incidents.html) - CIEs are not required for staging environments.

If the numbers are decreasing then discuss further in the CIE channel as a CIE may not be required.  Try and work out the rate of decrease and how long it is estimated to be until the figures reach under 50 masters being unhealthy.

### Recover one by one

If there are no broad infrastructure issues detected, follow the steps in [masters in unhealthy state runbook](armada-ops-master-in-unhealthy-state.html) to recover the masters one by one.

## Automation
None

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
