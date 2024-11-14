---
layout: default
description: Actions to take when an abnormal diskio detected on device dm-0.
title: armada-infra - Actions to take when an abnormal diskio detected on device dm-0
service: armada
runbook-name: "armada-infra - Actions to take when an abnormal diskio detected on device dm-0"
tags: alchemy, armada, diskio, dm-0
link: /armada/armada-infra-abnormal-diskio-dm0.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to handle critical alert when abnormal diskio detected on device dm-0

## Example alerts

N/A

## Background information

The alerts were created as a follow up of [the GHE issue `Create an alert and possible auto-recovery for device dm-0 100% busy - armada-ops/issues/7573` ](https://github.ibm.com/alchemy-containers/armada-ops/issues/7573)

The purpose here is to notify oncall SREs about a critical situation of diskio, which could cause customer's master or etcd pods to be unhealthy.

## Investigation and actions to take

Go to the Prometheus link included in the alert, and check if there is any drop down of the diskIO.

- If the situation persists, _reboot_ the node via `chlorine`

- If the reboot did not clear the alert,
reload this worker node by following [this runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-reload-carrier-workers.html)

- If reload does not resolve the alert,
CPU and Memory usage continue to grow until reaching 100 %. Log into the troubled node and check CPU and memory usage by following [high CPU runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-infra-high-node-cpu.html)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.
