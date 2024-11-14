---
layout: default
description: armada-log-collector carrier api server request failure rate
title: armada-log-collector high carrier api server request failure rate
service: armada
runbook-name: "armada-log-collector high carrier api server request failure rate"
tags: wanda, armada, log-collector, logging, carrier, api-server, metrics
link: /armada/armada-log-collector-carrier-apiserver-errors.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# armada-log-collector High carrier api server request failure rate

## Overview

armada-log-collector is unable to make requests to the carrier api server 

## Example alerts

Following pages are associated with this error
{% capture example_alert %}
  - `LogCollectorCarrierApiserverRequestErrors`
{% endcapture %}
{{ example_alert }}
## Action to take

This alert means that there were request failures when trying to communicate with the carrier 
kubernetes api server. Follow the [armada-carrier - How to handle an apiserver which is troubled](./armada-carrier-apiserver-troubled.html) runbook.

## Automation
None

## Escalation Policy

If the carrier kubernetes server is:
- **healthy**
  1. Open an issue against [{{ site.data.teams.armada-api.name }}]({{ site.data.teams.armada-api.issue }})
  1. Post in [{{ site.data.teams.armada-api.comm.name }}]({{ site.data.teams.armada-api.comm.link }})
  1. Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})
- **unhealthy**
  1. follow the escalation policy in the [armada-carrier - How to handle an apiserver which is troubled](./armada-carrier-apiserver-troubled.html) runbook.
