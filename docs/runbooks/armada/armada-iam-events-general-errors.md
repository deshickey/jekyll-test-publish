---
layout: default
description: armada-iam-events is experiencing unrecognized errors
title: armada-iam-events general debugging
service: armada
runbook-name: "armada-iam-events trouble shooting"
tags: armada, iam, events
link: /armada/armada-iam-events-general-issues.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# armada-iam-events debugging

## Overview

armada-iam-events is experiencing unclassified errors. these errors may or may not be fatal to the health of clusters in the region.

## Example alert
{% capture example_alert %}
- `ArmadaIAMEventsUnknownError`
{% endcapture %}
{{ example_alert }}

## Action to take

### Diagnose regional issues

If there are ongoing compute / network issues in the region, fix those issues.

### Mitigation

If there are no on-going issues in the region, that means we have a bug in our code and will need to page out the oncall Ironsides
team member.


## Escalation Policy

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}).

## Automation
None