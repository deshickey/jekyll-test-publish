---
layout: default
description: An overview of the armada-master-resource-monitor microservice and alert debugging tips.
title: Armada Master Resource Monitor
service: armada-master-resource-monitor
runbook-name: "Armada Master Resource Monitor"
tags: armada-master-resource-monitor, resource-monitor, master
link: /armada/armada-master-resource-monitor.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook provides an overview of the [Armada-master-resource-monitor](https://github.ibm.com/alchemy-containers/armada-master-resource-monitor) microservice, including alert troubleshooting tips.

## Detailed Information
Our master pods today currently have default resource request sizes.  They are set on initial deployment of the cluster, and never changed after that.  The problem here is that all masters are different.  Some may use more than that default amount, some may use less.  For example, if a master requests 450MB of memory, but is really using 1GB, is is "lying" to kube by 550MB.  When the kube scheduler comes along and schedules this pod, it is looking for 450MB worth of space on a worker node, when really it should be looking for 1GB.  Take this one example, and multiply it by all the clusters on a carrier, and this results in very inaccurate scheduling.  The scheduling issues can then result in innocent master pods being evicted from a node because of resource deprivation due to other masters using more than their requested resource amounts.  The same idea applies to masters that are using less than their requested amounts.  In this case, there are leftover resources that kube thinks are being used by that pod, but really are not.

Our solution to these issues is the armada-master-resource-monitor.  It runs on every carrier (spoke and hub) and monitors the master pods on that carrier for changes in resource (memory/cpu) usages.  If a master starts using more or less resources than it has requested from kubernetes, the resource monitor will perform a "patch" of that master's deployment to raise or lower the requested resource.  The monitor performs a monitoring run to check all master resources automatically at a configured interval.  It keeps a resource usage history for all masters in ETCD.  It will only make resource patching decisions once there has been enough history collected for that master.  More information can be found in the project's README.

The microservice is configurable via [configmaps](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/armada-master-resource-monitor.yaml) hosted in armada-secure.

## Alerts
Potential PD alerts for this microservice include:
- `ArmadaMasterResourceMonitorPatchFailures` - too many master patch request failures in the last 1 hour
- `ArmadaMasterResourceMonitorRunFailures` - too many monitor run failures in the last 1 hour

## Actions to take
Upon receiving a PD for this microservice, please begin your investigation by following the steps below:

1. Review the `#armada-monitor-alerts` channel
   - Search the channel for the carrier_name (like prod-syd04-carrier4).
   - Look for recent `COMPLETED` messages.
     - This means that monitor is still working and the alert should resolve itself in about an hour.
   - Look for recent `FAILED` messages and expand (Show more) to see the `Reason:`.
     - If it's `Unable to retrieve any master container resource usage information from the metrics server.  Error running kube command. exit status 1`,
     then this indicates an issue with the carrier, not the monitor.  The alert should resolve itself
     when the carrier is healthy.
     - If it's anything else see step 2.
1. Escalate to the dev squad.  Follow the `Escalation Policy` section below.

## Escalation Policy
If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.

## Metrics and Dashboards
Metrics exposed by this service can be viewed through the Grafana dashboard `Armada Master Resource Monitor` on each carrier. You can find and explore these dashboards via the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/).
