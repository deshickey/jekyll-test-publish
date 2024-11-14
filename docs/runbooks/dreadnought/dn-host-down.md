---
layout: default
title: "Dreadnought - What to do if a node is down"
runbook-name: "Dreadnought - What to do if a node is down"
description: "."
category: Dreadnought
service: dreadnought
tags: dreadnought, host, worker, node, down
link: /dreadnought/dn-host-down.html
type: Alert
grand_parent: Armada Runbooks
parent: Dreadnought
---

Alert
{: .label .label-purple}

## Overview

- One of workers in a cluster has gone offline

## Example alerts

Alert Titles
~~~~
- Host Down in dn-prod-s-cpapi-extended (au-syd) is Triggered
- Host Down in dn-prod-s-cpapi-extended (eu-de) is Triggered
~~~~

- Alert in Slack Channel [#dreadnought-prod-monitoring](https://ibm.enterprise.slack.com/archives/C059HL4RC92){:target="_blank"}:

~~~~
Host Down in dn-prod-s-cpapi-extended (eu-de) is Triggered

Severity: High
Metric:
   
sysdig_host_up = 0  
Segment:
   
agent_tag_cluster = 'ckjnav8f02b8qjl537sg' and host_hostname = 'kube-ckjnav8f02b8qjl537sg-cpapieudefr-default-00002999'
Scope:
   Everywhere
Time: 05/05/2024 07:38 PM UTC
State: Triggered
More info: View notification
Triggered by Alert:
Name: Host Down in dn-prod-s-cpapi (eu-de)
Description: value
Team: Monitor Operations
Scope:
   Everywhere
Segment by:
agent_tag_cluster, host_hostname
Alert When:
avg(timeAvg(sysdig_host_up)) <= 0.0
For at least: 5 m
More info: View alert
~~~~

- [PagerDuty Sample](https://ibm.pagerduty.com/incidents/Q1Q04WU1WREKEZ){:target="_blank"}

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

  - Issue should resolve on after 1 hour if the worker was replaced.


- If the cluster is NOT being updated, look into Sysdig at other events related to the cluster.

  1. Connect to the [IBM Cloud console monitoring](https://cloud.ibm.com/observe/monitoring) console
  1. Make sure you the correct account select
  1. Open dashboard for the correct monitoring instance
  1. Click `Events` in the left menu
  1. Copy the cluster name/ID into the search
  1. Review other events

  - If persisted, escalate the Cabin team to check if the cluster needs to be removed the load balancer in CIS/Akamai.

- <mark>DO NOT resolve the alert manually.</mark>

## Escalation Policy

- Escalate to other Dreadnought SRE members for help

## Reference

- None
