---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: 'Satellite Config MongoDB connections failure'
type: Alert
runbook-name: 'Satellite Config MongoDB connections failure'
description: 'Satellite Config MongoDB connections failure'
service: Satellite Config
tags: satellite-config
link: /satellite-config/satellite-config-mongodb-connections-failure.html
failure: ''
grand_parent: Armada Runbooks
parent: Satellite Config
---

Alert
{: .label .label-purple}

## Overview

This alert will trigger when an average connections count for the MongoDB goes to zero.


**Permission required**: Please follow [Satellite Config access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/satellite-config/Introduction_to_SatelliteConfig_Infrastructure.html) to get the required permission to access Satellite config Environment.

---

## Example Alert

- **Source**: Sysdig
- **Alert Name**: `"**<service name>** MongoDB connections failure"`

- **Alert condition**: `avg(avg(ibm_databases_for_mongodb_connections)) <= 0`

- **Trigger duration**: For the last 2 minutes


---

## Actions to take

#### Collect the debug data.

Login to Sysdig portal and gather details-

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select 2094928 account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Monitoring`
	- Select `Razee-Hosted-Sysdig-Prod-us-east` for *US-East*  
	- Select `View Sysdig`
  - Select `Event` (on left hand side)
  - Select `High` at the top of the window
  - View all the recent `High` severity Events
  - Locate the latest alert `MongoDB connections failure`
  - Click on the alert and a new sub-window (with details) will
    open up on the right hand side
  - Gather the required debug data

---

## Automation

None

---

## Escalation Policy

* Please contact the Satellite Config squad in the [#satellite-config](https://ibm-argonauts.slack.com/archives/CPPG4CX3N) slack channel for further information
* PD escalation policy : Escalate to [Alchemy - Satellite - Config](https://ibm.pagerduty.com/escalation_policies#P42GAQ1)

---
