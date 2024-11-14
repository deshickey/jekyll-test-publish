---
layout: default
description: How to scale an armada carrier
title: armada-infra - How to scale an armada carrier
service: armada
runbook-name: "armada-infra - How to scale an armada carrier"
tags: armada, node, scale, carrier, worker, capacity
link: /armada/armada-scale-carrier-up.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to scale up an armada carrier

## Detailed Information

### Actions to take
1. Follow [this runbook](../sl_provisioning.html#provisioning-machines-needed-for-a-carrier) to add more workers to the carrier
    - Ordering workers and conductors bootstrap/smith patching is managed by the conductors
1. Run the [armada-carrier-deploy](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/build?delay=0sec) jenkins job
    - Keep defaults for everything except for the fields below
    - Environment: select the desired environment from the drop down
    - Carrier: select the desired carrier number from the drop down
    - WORKERS: worker private IPs ordered from the previous step, comma-separated.
    - RUN_CARRIER_POSTCHECK: `checked`
1. Wait for job to complete.
    - If the job fails, look at the console output to see what the error is, follow the table below for common issues,
    if this is not high urgency, do not page out, create an issue with the respective teams and follow up with them during their working hours.

| Error | Info | Escalatation |
| --------------- | ---- | ----- |
| Unable to SSH to node(s) | Usually indicates conductors bootstrap did not work. Conductors should work to resolve | Conductors |
| Unable to reach the internet | Usually indicates the vlan was not setup properly, work with netint/conductors to resolve.<br>SSH to the node and attempt to run the same commands the job was trying to run if it works, rerun the job. | Netint |
| All other errors | Other errors not mentioned above | [Carrier](#escalation-policy) |


## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.
