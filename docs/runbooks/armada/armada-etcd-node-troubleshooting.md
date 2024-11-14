---
layout: default
description: Armada etcd node troubleshooting
title: armada-etcd - Node Troubleshooting
service: armada-etcd
runbook-name: "armada-etcd - node troubleshooting"
tags: alchemy, armada, etcd, armada-etcd
link: /armada/armada-etcd-node-troubleshooting.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook contains armada etcd node troubleshooting steps.

| Alert_Situation | Info | Start |
|--
| `CriticalNodeCPUAvailableEtcdWorkerPool`| Average node CPU usage on etcd node is over 80 percent for the past 5 minutes. | [Etcd node cpu](#actions-to-take) |
| `WarningNodeCPUAvailableEtcdWorkerPool`| Average node CPU usage on etcd node is over 60 percent for the past 5 minutes. | [Etcd node cpu](#actions-to-take) |
| `CriticalNodeMemoryAvailableEtcdWorkerPool`| Average node Memory available on etcd node is less than 2GB for the past 10 minutes. | [Etcd node memory](#actions-to-take) |
| `WarningNodeMemoryAvailableEtcdWorkerPool`| Average node Memory available on etcd node is less than 3GB for the past 10 minutes | [Etcd node memory](#actions-to-take) |
| `CriticalPeakIOOnEtcdWorkerPool`| The peak number of I/Os on etcd node is more than 1k over the past 24 hours. | [Etcd node disk](#actions-to-take) |
| `WarningPeakIOOnEtcdWorkerPool`| The peak number of I/Os on etcd node is more than 500 over the past 24 hours. | [Etcd node disk](#actions-to-take) |
{:.table .table-bordered .table-striped}
| `CriticalArmadaETCDNodeCountAlert`| The count of armada-etcd nodes are less than 4 for last 15min. | [Etcd node count](#actions-to-take) |
| `WarningArmadaETCDNodeCountAlert`| The count of armada-etcd nodes are less than 6 for last 15min. | [Etcd node count](#actions-to-take) |
## Example Alerts

~~~~text
Labels:
 - alertname = armada-etcd/critical_cpu_usage_on_node_hostname_etcd_worker_pool
 - alert_situation = critical_cpu_usage_on_node_hostname_etcd_worker_pool
 - service = armada-etcd
 - severity = critical
Annotations:
 - summary: Average node CPU usage on 10.123.5.6 etcd node is over 80 percent for the past 5 minutes. Current average {% raw %}{{ $value }}{% endraw %}%
 - description: Average node CPU usage on 10.123.5.6 etcd node is over 80 percent for the past 5 minutes. Current average {% raw %}{{ $value }}{% endraw %}%
~~~~

## Actions to take

1. Lets go to prometheus to review the node and etcd information

  More info on how to get to prometheus can be found in [armada-general-debugging-info --> general-prometheus-usage](.//armada-general-debugging-info.html#general-prometheus-usage)

  Check for the following in the prometheus instance for the region's armada etcd hub tugboat:

- Review the armada etcd node ready status.

  This query should show 6 ready nodes:
`kube_node_status_condition{condition="Ready", status="true"} and on(node) (kube_node_labels{label_etcd="armada"})`

  This query will show any NOT ready nodes:

 `kube_node_status_condition{condition="Ready", status="true"} and on(node) (kube_node_labels{label_etcd="armada"})==0`

  If any nodes are not ready, see the following [runbook to check the node health](./armada-carrier-node-troubled.html).

- Review the armada etcd pod ready status. There should be 5 pods ready and running.
`kube_pod_container_status_ready{namespace=~"armada",pod=~"etcd-\\d+-armada.*",container="etcd"}`

  If any armada etcd pods are not ready, see the following [runbook to check armada etcd health](./armada-etcd-unhealthy.html).

- Review the armada etcd node count status. There should be 6 nodes ready and running.
`sum by (status, node) (kube_node_status_condition{condition="Ready",status="true"}) and on (node) kube_node_labels{label_etcd="armada"} and on (node) kube_node_spec_unschedulable == 0`

 If the count of the armada etcd nodes is below 6, see the following [runbook to check the nodes](./armada-carrier-node-troubled.html).

- Review other alerts

  Additionally, you should check for the following alerts in the prometheus instance for the region's armada etcd hub tugboat.  Click on `Alerts` in the upper left of the prometheus view.

  - `ArmadaEtcdClusterBrokeQuorum`
  - `ArmadaEtcdClusterUnhealthy`

  If so, jump to [this runbook](./armada-etcd-unhealthy.html).

1. Lets go to grafana to review the etcd information

  More info on how to get to grafana can be found in [armada-general-debugging-info --> general-grafana-usage](.//armada-general-debugging-info.html#general-grafana-usage)

- Review armada etcd grafana dashboard

  See the `Microservice Etcd Metrics V2` Grafana dashboard for the armada etcd tugboat in the region. The Summary view will give you a broad view of the state of the armada etcd cluster.

  The `Microservice Etcd response times (non-crawler)` graph should be below 200ms.
  The `Request Throughput` graph should be below 20k ops/s.
  The `Etcd Data Errors` graph should be below 50.

  If the graphs are above any of these, see the following [runbook to check armada etcd health](./armada-etcd-unhealthy.html).

### Additional Information

More information can be found about our implementation and use of etcd-operator [here](armada-etcd-operator-information.html) and general etcd trouble shooting [here](armada-etcd-general-troubleshooting.html).

## Escalation policy

First open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.