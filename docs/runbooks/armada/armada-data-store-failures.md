---
layout: default
description: How to resolve the armada etcd keyprotect related alerts
title: armada-ballast-store-failures - How to resolve the armada etcd keyprotect related alerts
service: armada-etcd
runbook-name: "armada-ballast-store-failures armada keyprotect failures"
tags:  armada, etcd, keyprotect, store, armada-etcd, armada-data, armada-soyuz
link: /armada/armada-ballast-store-failures.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `KeyProtectCreateRootKeyFailure`| Armada etcd Key Protect failure with root key creation for armada etcd model data encryption. threshold over 2 for the last 10 min. | [Etcd kp failure](#actions-to-take) |
| `KeyProtectWrapDekFailure`| Armada etcd Key Protect failure with getting wrap dek for armada etcd model data encryption threshold over 2 for the last 10 min.| [Etcd kp failure](#actions-to-take) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~text
Labels:
 - alertname = armada-ballast/Key_protect_create_root_key_failure
 - alert_situation = Key_protect_create_root_key_failure
 - service = armada-etcd
 - severity = critical
Annotations:
 - namespace = armada
~~~~

## Actions to take

1. Lets go to prometheus to review the keyprotect service information

  More info on how to get to prometheus can be found in [armada-general-debugging-info --> general-prometheus-usage](.//armada-general-debugging-info.html#general-prometheus-usage)

  Check for the following in the prometheus instance for the region's armada etcd hub tugboat:

  - Review the armada keyprotect status.

  This query will show count of increase in the root key creation failure for the keyprotect service.
  `sum(increase(serviceDependencies_http_req_error_count{method="root_key_create", service="keyprotect"}[5m]))`

  This query will show count of increase in getting wrap dek for armada etcd model data encryption.
  `sum(increase(serviceDependencies_http_req_error_count{method="dek_wrap", service="keyprotect"}[5m]))`

  This alert will mention the micro service from where the http failure was from. Check if the specified micro service pods checked any issues.

2. This is not the runbook for this. Check the Key Protect backend service for any outages or issues. 
  
  In this scenario, the SRE squad need to go check the KeyProtect service itself for having any issues that could be the cause of the http failures in the graph.

  If that does not resolve the alert, see [escalation policy](#escalation-policy) below to page out the Ballast squad.

## Escalation Policy

First open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.