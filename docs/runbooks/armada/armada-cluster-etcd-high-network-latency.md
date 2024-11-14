---
layout: default
title: Handling alert for customer etcd cluster experiencing a high network latency between members
description: How to handle PD alert for managed customer etcd cluster experiencing a high network latency between members.
service: armada-deploy
runbook-name: "armada-cluster-etcd-high-network-latency"
tags:  armada, armada-deploy, etcd
link: /armada/armada-cluster-etcd-high-network-latency.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

High network latency in an etcd cluster is problematic as it can cause delays in critical processes like heartbeats, data replication, and leader elections. This delay leads to increased response times, compromises data consistency, and hampers the efficiency of the Raft consensus algorithm. Ensuring that the member-to-member round-trip communication times are low is crucial to the overall performance and reliability of the etcd cluster.

This runbook contains troubleshooting steps to take when handling an alert for a managed customer etcd cluster experiencing a high network latency between members.

## Example Alert(s)

~~~~
Labels:
 - alertname = etcd_high_network_latency
 - alert_situation = etcd_high_network_latency
 - service = armada-deploy
 - severity = critical
 - cluster_id = xxxxxxxxxxx
Annotations:
 - summary = "An etcd cluster member pod is experiencing high network latency."
 - description =
    The etcd member pod <pod> for cluster <cluster_id> is experiencing a high network round-trip time (RTT) to another member.
    The pod is currently running on node <node>.
~~~~

## Actions to Take

1. Run the [armada-deploy-get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job to obtain current cluster state information.
    - Make sure to check the boxes for `ETCD_BACKUP_INFO` and `DETAILED_ETCD_INFO` to ensure all relevant etcd cluster information is gathered.
2. When the job is finished, open the grafana master control plane link for the cluster.
    - `Build Artifacts` --> `GMISplit` --> `GMI_DIGEST_AND_POTENTIAL_PROBLEMS.log` --> `Grafana Master Control Plane URL`
3. Look for any abnormalities in the metrics that may indicate network related issues in the etcd cluster.
    - The etcd specific panels are under the `Etcd` section.
    - The `Etcd Peer Network Round Trip` panel is showing the same metrics used in this alert.
    - Things to look for:
        - Signs of a "troubled" node.  Dig into the worker nodes hosting the etcd member pods to look for any unusual resource/network/disk activity that may be cause for concern.  Use the member pod and worker node specified in the alert description to narrow the scope of your investigation.  In this case, [rebooting](./armada-carrier-node-troubled.html#rebooting-tugboat-worker-node) or [reloading](./armada-carrier-node-troubled.html#reloading-worker-node) the node may alleviate the issues.
4. If after conducting this initial investigation you are unable to resolve the alert yourself, proceed with the instructions in the [Escalation Policy](#escalation-policy) section.

## Escalation Policy

If a CIE has been raised and you need immediate assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE:
- Create an issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository.
- Post the issue in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel.
- Silence the alert for 24 hours.
