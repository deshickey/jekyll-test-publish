---
layout: default
title: Armada-IAM-Events Key Process Buffer is at Capacity
type: alert
runbook-name: "Key Process Buffer Is At Capacity"
description: "Key Process Buffer is backed up and callbacks need to be unclogged"
service: armada
link: /armada/key_process_buffer.html
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Armada-IAM-Events Key Process Buffer is at Capacity

### Overview

Whenever a key is changed in etcd that armada-iam-events has a rule for, it is added to the Key Process Buffer queue. From there it waits for the next available worker to reevaluate the rule and see if said rule is still satisfied, then it will proceed with the callback and do whatever the rule requires. Once this is completed, the worker will take the next key from the buffer and repeat the process.

When this alert is firing, it means that the Key Process Buffer queue is full. This will occur when all available workers are busy trying to process slow or unprocessable requests. An error that has been seen before is a specific cluster has had networking errors causing every worker to take 15 seconds before timing out. This can cause a serious backup in the queue. If the errors all have the same clusterID try restarting the cluster.

### Example Alerts

    - `prod.containers-kubernetes.prod-dal10-carrier105.buffer_cap_reached.us-south`

(Only one alert currently associated with this runbook)

### Actions to take - quick steps to bring back to 
Raise a train before attempting the below steps

For a temporary fix: edit armada-iam-events deployment YAML to add more workers and replicas to help process the queue's backlog. To edit the deployment yaml use ``kubectl edit deploy -n armada armada-iam-events``. The default should be ``replicas 3`` and ```RULES_ENGINE_MAX_WORKERS 50```. To start bump it to ``replicas 5`` and ``RULES_ENGINE_MAX_WORKERS 100``. This will provide temporary relief while the investigation is taking place. Make sure to also disable cluster updater before editing the deploment yaml to scale so the changes made will not be reverted. You can follow instructions [HERE](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster-updater-using-launchdarkly.html) on how to disable cluster updater.


### Train Template
```
Squad: SRE
Service: armada-api
Title:  Increase replicas of armada-iam-events on ALERTING-TUGBOAT
Environment: REGION
Details: PD-ALERT-URL
Risk: low
Ops: true
OutageDuration: 0s
PlannedStartTime: now
PlannedEndTime: now + 1h
BackoutPlan: NA
```

### Further Debugging/Monitoring
Search the affected region's logs. Filter with app:armada-iam-events and "connection reset by peer". Try and find common themes in the errors. One good area to check is the master url. It should have the cluster, reqID, and tugboat number in it. 
Look for:
- Same clusterID
- Same accountID

Example of logs:

Helpful Prometheus Queries (Make sure that you edit url to look at the correct region): [HERE](https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier105/prometheus/graph?g0.expr=histogram_quantile(0.5%2Csum%20by%20(pattern%2C%20rule%2C%20le)%20(rate(rules_etcd_callback_wait_ms_bucket%7Bservice_name%3D%22armada-iam-events%22%7D%5B30m%5D)))%2F1000&g0.tab=0&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1d&g1.expr=sum%20by%20(pattern%2C%20rule)%20(rate(rules_etcd_callback_wait_ms_count%7Bservice_name%3D%22armada-iam-events%22%7D%5B5m%5D))&g1.tab=0&g1.display_mode=lines&g1.show_exemplars=0&g1.range_input=1d&g1.step_input=600&g2.expr=rules_etcd_key_process_buffer_cap%7Bservice_name%3D%22armada-iam-events%22%7D&g2.tab=0&g2.display_mode=lines&g2.show_exemplars=0&g2.range_input=1d)

Graph 1: histogram_quantile(0.5,sum by (pattern, rule, le) (rate(rules_etcd_callback_wait_ms_bucket{service_name="armada-iam-events"}[30m])))/1000
- Shows the 0.5 quantile of seconds spent waiting in the Key Process Buffer. If this number is steadily growing even after increasing replicas and worker count then, escalate this alert.

Graph 2: sum by (pattern, rule) (rate(rules_etcd_callback_wait_ms_count{service_name="armada-iam-events"}[5m]))
- Shows the rate at which the callbacks are added queue based on its pattern.

Graph 3: rules_etcd_key_process_buffer_cap{service_name="armada-iam-events"}
- This is the expression for the alert. It shows how much space is on the buffer. 

### Escalation Policy

Escalate to Ironsides: https://ibm.pagerduty.com/escalation_policies#PVJ35ZC

