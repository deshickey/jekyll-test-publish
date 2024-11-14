---
layout: default
description: How to resolve bootstrap critical memory usage alerts 
title: armada-bootstrap-critical-memory-alert - How to resolve unreconciled osimage alerts
service: armada-bootstrap
runbook-name: "armada-bootstrap-critical-memory-alert - How to resolve unreconciled osimage alerts"
tags:  armada, armada-bootstrap
link: /armada/armada-bootstrap-critical-memory-alert.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook contain steps to take when debugging bootstrap critical memory usage alerts.

## Example Alert(s)

~~~~
labels:
  alert_key: bootstrap_high_memory_usage_gigabytes
  alert_situation: bootstrap_high_memory_usage_gigabytes
  service: armada-bootstrap
  severity: critical
annotations:
  description: Bootstrap pods consuming too many resources on nodes, potential failures
~~~~

## Actions to Take

This alert means that something is causing bootstrap pods to consume a lot of memory on the nodes it's running on.


1. Check Prometheus

    - Go to the [alchemy-dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) and check the tugboat in the region where this alert is triggered. This would be the microservices tugboat.

    - Enter this query and check 
    ```
    armada_bootstrap:bootstrap_average_memory_usage_gb > 20
    ```
    
    - Check the graph over the past day to see if it's a gradual increase (which may indicate a memory leak) or a sharp increase. This will also determine which pods are taking up the most memory and on the graph, you can select each pod individually to track the rate of increase. Take a screenshot for information. 

2. Open an issue in the [bootstrap squad repo](https://github.ibm.com/alchemy-containers/bootstrap-squad/issues/new) and document information.

    - If its a gradual increase over time, kill the pod to reset the amount of memory and create an issue with armada-bootstrap to look at during business hours. 
      - If it's been over an hour of high memory usage after the pod gets deleted, create an issue with bootstrap to look at during business hours and snooze the alert.
    - If it's a spike and only lasts for <1 hour, create an issue with bootstrap to look at during business hours and snooze the alert.

3. If previous steps have been taken and the high memory usage causes bootstrap failures in the region (such as seeing many new worker provisioning failures, many worker reload/replaces failures), escalate to armada-bootstrap:
    -  Provide information on the increase of memory usage as well as information on pod memory usage. 



## Escalation Policy
Please follow the [escalation guidelines](./armada-bootstrap-collect-info-before-escalation.html) to engage the bootstrap development squads.
