---
layout: default
description: armada-credential sending high percentage of non-2xx responses
title: armada-credential failures
service: armada
runbook-name: "armada-credential trouble shooting"
tags: armada, credential
link: /armada/armada-credential-high-error-rate.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Credential troubleshooting

## Overview

Microservices are experiencing HTTP failures when communicating with armada-credential. If armada-credential is failing users will not be able to retrieve admin certs and keys, also most of the administrative requests for clusters will fail.

## Example alert
{% capture example_alert %}
- `ArmadaCredentialHighErrorRate`
{% endcapture %}
{{ example_alert }}

## Action to take
As this is a relatively new service we don't have troubleshooting steps yet, please follow the escalation policy

## Escalation Policy
Please notify {{ site.data.teams.armada-api.comm.name }}.

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

## Automation
None
