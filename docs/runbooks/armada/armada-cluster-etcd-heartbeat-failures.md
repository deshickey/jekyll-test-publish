---
layout: default
title: Handling alert for customer etcd cluster experiencing a high percentage of leader heartbeat send failures
description: How to handle PD alert for managed customer etcd cluster experiencing a high percentage of leader heartbeat failures.
service: armada-deploy
runbook-name: "armada-cluster-etcd-heartbeat-failures"
tags:  armada, armada-deploy, etcd
link: /armada/armada-cluster-etcd-heartbeat-failures.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

To maintain its leadership status, the etcd leader periodically sends heartbeat messages to the followers. These heartbeats serve as a signal to followers that the leader is still active and operational.  If a significant percentage of leader heartbeats are failing to send, it can indicate potential issues with the communication between the leader and its followers that may result in degraded database performance.

This runbook contains troubleshooting steps to take when handling an alert for a managed customer etcd cluster that is experiencing a high percentage of leader heartbeat send failures.

## Example Alert(s)

~~~~
Labels:
 - alertname = etcd_heartbeat_send_failure
 - alert_situation = etcd_heartbeat_send_failure
 - service = armada-deploy
 - severity = critical
 - cluster_id = xxxxxxxxxxx
Annotations:
 - summary = "This etcd cluster has been found to have a high leader heartbeat send failure percentage, which could indicate degraded database performance."
 - description = "The etcd database for cluster <cluster_id> is experiencing a high leader heartbeat send failure percentage."
~~~~

## Actions to Take

1. Run the [armada-deploy-get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job to obtain current cluster state information.
    - Make sure to check the boxes for `ETCD_BACKUP_INFO` and `DETAILED_ETCD_INFO` to ensure all relevant etcd cluster information is gathered.
2. When the job is finished, open the grafana master control plane link for the cluster.
    - `Build Artifacts` --> `GMISplit` --> `GMI_DIGEST_AND_POTENTIAL_PROBLEMS.log` --> `Grafana Master Control Plane URL`
3. Look for any abnormalities in the metrics that may indicate why the current etcd leader member may be having troubles sending heartbeats to its followers.
    - The etcd specific panels are under the `Etcd` section.
    - The `Etcd Heartbeat Send Failures` panel is showing the same metrics used in this alert.
    - Things to look for:
        - Signs of a "troubled" node.  Dig into the worker nodes hosting the etcd member pods to look for any unusual resource/network/disk activity that may be cause for concern.  In this case, [rebooting](./armada-carrier-node-troubled.html#rebooting-tugboat-worker-node) or [reloading](./armada-carrier-node-troubled.html#reloading-worker-node) the node may alleviate the issues.
4. If after conducting this initial investigation you are unable to resolve the alert yourself, proceed with the instructions in the [Escalation Policy](#escalation-policy) section.

## Escalation Policy

If a CIE has been raised and you need immediate assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE:
- Create an issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository.
- Post the issue in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel.
- Silence the alert for 24 hours.
