---
layout: default
title: "Dreadnought - CPU High Alert"
runbook-name: "Dreadnought - CPU High Alert"
description: "How to handle a CPU High Alert."
category: Dreadnought
service: dreadnought
tags: dreadnought, host, cpu high, cpu, worker
link: /dreadnought/dn-worker-cpu-high.html
type: Alert
grand_parent: Armada Runbooks
parent: Dreadnought
---

Alert
{: .label .label-purple}

## Overview

- One of workers in a cluster has a high CPU utilization.  If the worker is constantly above 66% usage, the process is to scale out the workers in the worker pool.

## Example alerts

Alert Titles
~~~~
- CPU usage >= 95% over 30 minute in dn-prod-s-cpapi-extended (au-syd) is Triggered
- CPU usage > 66% over 30 minute in dn-prod-s-cpapi-extended (eu-de) is Triggered
~~~~

- Alert in Slack Channel [#dreadnought-prod-monitoring](https://ibm.enterprise.slack.com/archives/C059HL4RC92){:target="_blank"}:

~~~~
CPU usage > 66% over 30 minute in dn-prod-s-cpapi-extended (eu-de) is Triggered

Severity: medium
Metric: sysdig_host_cpu_used_percent = 67.908 % 
   
Segment:
agent_tag_cluster = 'cpapi-eu-de-fra02-0001-cluster' and host_hostname = 'kube-ckjnb0vf07igegg86a1g-cpapieudefr-default-00007bbd'

Scope:
   Everywhere

Time: 05/05/2024 07:38 PM UTC
State: Triggered
More info: View notification
Triggered by Alert:
Name: CPU usage > 66% over 30 minute in dn-prod-s-cpapi-extended (eu-de)
Description: Very High CPU usage (> 66%) on host for a long period (> 30 minutes)
Team: Monitor Operations
Scope:
   Everywhere
Segment by:
agent_tag_cluster, host_hostname
Alert When:
rate(avg(sysdig_host_cpu_used_percent)) > 50.0
For at least: 30 m
More info: View alert
~~~~

## Automation

- None

## Actions to take

- Check if a Cluster or Worker update is in progress for the Cluster (`kube_cluster_name`)

  - Look for the following in the associated [Dreadnought monitoring channel](https://pages.github.ibm.com/dreadnought/dreadnought-docs/#/Runbooks/Dreadnought/Auditree/Auditree_Setup?id=monitoring-channels){:target="_blank"}

  > dn-ops APP Cluster Update Scheduled -> 4.12.46 
  >
  > - prefix-au-syd-syd01-0001-cluster cluster of dn-prod-s-dreadnought-name account
  > - prefix-us-east-wdc06-0001-cluster cluster of dn-prod-s-dreadnought-name account
  > - prefix-eu-de-fra02-0001-cluster cluster of dn-prod-s-dreadnought-name account

  - Issue should resolve within a few minutes of a new worker startup.


- If the cluster is NOT being updated, look into Sysdig at other events related to the cluster.

  1. Connect to the [IBM Cloud console monitoring](https://cloud.ibm.com/observe/monitoring) console
  1. Make sure you the correct account select
  1. Open dashboard for the correct monitoring instance
  1. Click `Events` in the left menu
  1. Copy the cluster name/ID into the search
  1. Review other events

- If persisted, look into Sysdig to view the Dashboard `Node Status & Performance` and check if other workers in the same cluster also have high CPU usage.  If so and they are not all in the same pool there maybe an issue with VPC VSI workers.  This has happen during a VPC CIE and the characteristics is seeing consistently high CPU utilization without resolution.
  - Also check the Dashboard `Pod Status & Performance` and see how much CPU is used by Pod.
  - CPU high for particular pods the next step is to scale out the number of workers in the pool to help spread out the workload.  The pool name is in the worker name of the alert (i.e. `kube-ckjnb0vf07igegg86a1g-cpapieudefr-default-00007bbd` is in the **default** worker pool, `kube-ckjnb0vf07igegg86a1g-cpapieudefr-edge-000078d8` is in the **edge** worker pool, etc.)
- If the issue is limited to a single pool of workers, or 1 worker in a pool, you might consider either of the following:
  - Replace the worker following the [worker replace](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/dreadnought/dn-worker-replace.html) runbook.
  - Follow the [Scale out the worker pool](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/dreadnought/dn-worker-pool-scale.html) instructions.

- <mark>DO NOT resolve the alert manually.</mark>

## Escalation Policy

- [Escalate to other Dreadnought SRE members for help](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/dreadnought/dn-escalation.html)

## Reference

- None
