---
layout: default
title: "Dreadnought - Low Service (cabin) workload pod counts"
runbook-name: "Dreadnought - Cabin workload pod count is low"
description: "."
category: Dreadnought
service: dreadnought
tags: dreadnought, cabin, workload, service, pod
link: /dreadnought/dn-service-workload-pods-low.html
type: Alert
grand_parent: Armada Runbooks
parent: Dreadnought
---

Alert
{: .label .label-purple}

## Overview

- A cabin team workload pod count is low causing a potential decrease in performance of the cabin's service.

## Example alerts

Alert Titles Examples
~~~~
- Services workload <= 1 replica for 1 minute for dn-prod-s-cpapi-extended (us-east) is Triggered
- Services workload = 1 replica for 1 minute for dn-prod-s-bluefringe (au-syd) is Triggered
~~~~

- Alert in Slack Channel [#dreadnought-prod-monitoring](https://ibm-cloudplatform.slack.com/archives/C059HL4RC92/p1721069919233849){:target="_blank"}:

~~~~

Services workload <= 1 replica for 1 minute for dn-prod-s-cpapi-extended (us-east) is Triggered

Severity: Low
Metric:
   
kube_deployment_status_replicas = 1 
Segment:
   
kube_cluster_name = 'ckjnbd5w0u49fu6p3e6g' and kube_namespace_name = 'cost' and kube_workload_name = 'cloud-pricing-api'
Scope:
   
kube_namespace_name in ('cost', 'projects')
Time: 07/15/2024 06:56 PM UTC
State: Triggered
More info: View notification
Triggered by Alert:
Name: Services workload <= 1 replica for 1 minute for dn-prod-s-cpapi-extended (us-east)
  
~~~~

- [PagerDuty Sample](https://ibm.pagerduty.com/incidents/Q2HTW9ACRQ094A){:target="_blank"}

## Automation

None

## Actions to take

- Check if a Cluster or Worker update is in progress for the Cluster (`kube_cluster_name`)

  - Look for the following in the associated [Dreadnought monitoring channel](https://pages.github.ibm.com/dreadnought/dreadnought-docs/#/Runbooks/Dreadnought/Auditree/Auditree_Setup?id=monitoring-channels){:target="_blank"}

  > dn-ops APP Cluster Update Scheduled -> 4.12.46 
  >
  > - prefix-au-syd-syd01-0001-cluster cluster of dn-prod-s-dreadnought-name account
  > - prefix-us-east-wdc06-0001-cluster cluster of dn-prod-s-dreadnought-name account
  > - prefix-eu-de-fra02-0001-cluster cluster of dn-prod-s-dreadnought-name account

  - Issue should resolve in under 10 minutes once new pods start on a new worker.

- If the cluster is NOT being updated, look into Sysdig at other events related to the cluster (`kube_cluster_name`) or namespace (`kube_namespace_name`)

  1. Connect to the [IBM Cloud console monitoring](https://cloud.ibm.com/observe/monitoring) console
  1. Make sure the correct account select
  1. Open dashboard for the correct monitoring instance (region)
  1. Click `Events` in the left menu
  1. Copy the cluster name/ID (`kube_cluster_name`) into the filter
  1. Copy the namepsace (`kube_namespace_name`) into the next filter
  1. Review other events

  - If persisted, escalate the Cabin team to check if the cluster needs to be removed the load balancer in CIS/Akamai.

- <mark>DO NOT resolve the alert manually.</mark>

## Escalation Policy

- If having issues with the service, escalate to the cabin team using their escalation process by searching for "escalation" in the runbooks.

## Reference

- None
