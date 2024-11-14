---
layout: default
description: How to resolve alerts related to the rules engine
title: armada-etcd-rules-engine-unhealthy - How to resolve the armada etcd rules engine related alerts
service: armada-etcd-rules-engine
runbook-name: "armada-etcd-rules-engine - issues related to rules engine functionality"
tags:  armada, etcd, rules-engine, armada-etcd
link: /armada/armada-etcd-rules-engine.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `RulesEngineBufferNearCapacity`| A rules engine instance has a buffer near capacity. Metrics should be recorded for investigation. | [Buffer near capacity](#buffer-near-capacity) |
{:.table .table-bordered .table-striped}

### Buffer near capacity

This is an indication that the work buffer for the rules engine is full, and that the specific rules engine instance which triggered this alert is working over capacity. Recommended actions to take are:

1. Record [metrics](#relevant-metrics) of the timespan in which the alert was triggered
1. Investigate which rules appear to be triggering/processing at high rates and filling the buffer
1. Verify that the number of workers currently available is adequate to process the rules for the service
1. Reach out to the `#armada-ballast` channel on slack with details of the service usage and captured metrics from the alert


## Relevant Metrics

To view the current callback wait times for the service which triggered the alert:
`histogram_quantile(0.5, sum by(pattern, rule, le) (rate(rules_etcd_callback_wait_ms_bucket{service_name="ADD_SERVICE_NAME_HERE"}[30m]))) / 1000`

To view the current buffer capacity for the rules engine instance:
`rules_etcd_key_process_buffer_cap{service_name="ADD_SERVICE_NAME_HERE"}`

For existing graphs of rules engine metrics, go to the `Microservice Etcd Metrics v2` in Grafana for the relevant region and select the affected microservice in the `service` dropdown selector. The sections labelled `Rules Engine Thoroughput` and `Rules Engine General` will have the related metrics. 

## Escalation Policy

Open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
