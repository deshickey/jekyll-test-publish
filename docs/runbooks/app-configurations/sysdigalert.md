---
layout: default
title: IBM Cloud App Configuration Sysdig Alerts
type: Informational
runbook-name: "IBM Cloud App Configuration Sysdig Alerts"
description: "IBM Cloud App Configuration Sysdig Alerts"
service: App Configuration
tags: app-configurations
link: /app-configurations/sysdigalert.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
# Sysdig Alerts
## List of Sysdig Alerts


| Alert Name | Threshold value for Slack Notification | Threshold value for PD Alerts | Action |
| :----------| :-----| :----| :--|
| {Region} prod postgres usages high | 70 | 95 ||
| {Region} prod postgres disk io usages is high | 80 | 90 ||
| {Region} prod Postgres memory usages is high | 90 | 99 | 99.5(autoscale up) |
| apprapp_{Region}_cluster_cpu_usage_high | 85 | 90 ||
| apprapp_{Region}_cluster_memory_usage_high | 90 | 95 ||
| apprapp_{Region}_node_cpu_usage_high | 80 | 85 ||
| apprapp_{Region}_node_memory_usage_high | 80 | 85 ||
| apprapp_{Region}_pod_cpu_usage_high | 80 | 85 ||
| apprapp_{Region}_pod_momory_usage_high | 80 | 85 ||
| apprapp_{Region}_restarts_high | 2 |  3 ||

## Detailed Information
## {Region} prod postgres usages high

* increase disk size (Active action)
* Perform evaluation data backup (Side Action)

## {Region} prod Postgres memory usages is high

* Auto scale should be setup
* Restarts events
* Restart feature if impact seen

## apprapp_{Region}_cluster_cpu_usage_high

* Find impacted node and restart node, refer Troubleshoot-issues-related-to-CPU-or-Memory-utlization section.

## apprapp_{Region}_cluster_memory_usage_high

* Find impacted node and restart node, refer Troubleshoot-issues-related-to-CPU-or-Memory-utlization section.

## apprapp_{Region}_node_cpu_usage_high

* Find impacted node and restart node, refer Troubleshoot-issues-related-to-CPU-or-Memory-utlization section.

## apprapp_{Region}_node_memory_usage_high

* Find impacted node and restart node, refer Troubleshoot-issues-related-to-CPU-or-Memory-utlization section.

## apprapp_{Region}_pod_cpu_usage_high

* Investigate issue and find a problamatic pod, refer Troubleshoot-issues-related-to-CPU-or-Memory-utlization section.
* Restart pod

## apprapp_{Region}_pod_momory_usage_high

* Investigate issue and find a problamatic pod, refer Troubleshoot-issues-related-to-CPU-or-Memory-utlization section.
* Restart pod

## apprapp_{Region}_restarts_high

* Investigate issue and take action based on cases



# Actions

## Troubleshoot issues related to CPU or Memory utlization

`kubectl top` command can be used to retrieve snapshots of resource utilization of pods or nodes in your Kubernetes cluster. Resource utilization is an important thing to monitor for Kubernetes cluster owners. In order to monitor resource utilization, you can keep track of things like CPU, memory.

### kubectl top node
Running the `kubectl top node` command lists metrics of the current nodes
```
Mayanks-MacBook-Pro:~ mayank$ kubectl top node
NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
10.221.2.11     286m         7%     2829Mi          21%       
10.221.2.18     535m         6%     4385Mi          15%       
10.221.2.2      400m         10%    2672Mi          20%       
10.221.2.21     523m         6%     5165Mi          18%       
10.241.131.32   803m         10%    5418Mi          19%       
10.241.131.37   409m         5%     4367Mi          15%       
10.241.131.51   469m         11%    2773Mi          21%       
10.241.131.58   420m         10%    2683Mi          20%       
10.73.2.119     286m         7%     2772Mi          21%       
10.73.2.125     301m         7%     2675Mi          20%       
10.73.2.75      598m         7%     4635Mi          16%       
10.73.2.79      342m         4%     4590Mi          16% 
```

The output from kubectl top node gives you information about CPU(cores), CPU%, memory, and memory%. Let’s see what these terms mean:

* CPU(cores)

  `535m means 535 millicpu. 1000m is equal to 1 CPU, hence 535m means 53.5% of 1 CPU.`

* CPU%

  `It is displayed only for nodes, and it stands for the total CPU usage percentage of that node.`

* Memory

  `Memory being used by that node`

* Memory%

  `It is also displayed only for nodes, and it stands for total memory usage percentage of that node.`


### kubectl top pod
Running the `kubectl top pod` command displays the metrics about pods from the default namespace.

```
Mayanks-MacBook-Pro:~ mayank$ kubectl top pod -n apprapp
NAME                                      CPU(cores)   MEMORY(bytes)   
appconfig-pgbouncer-5db45bc66c-br7hl      4m           45Mi            
appconfig-pgbouncer-5db45bc66c-n84m4      4m           45Mi            
appconfig-pgbouncer-5db45bc66c-wglrd      4m           43Mi            
apprapp-api-gateway-5f66d5b674-4k74p      15m          58Mi            
apprapp-api-gateway-5f66d5b674-h28tm      12m          61Mi            
apprapp-api-gateway-5f66d5b674-s676n      15m          60Mi            
apprapp-broker-568cc974cc-45pcn           5m           87Mi            
apprapp-broker-568cc974cc-59vrf           5m           85Mi            
apprapp-broker-568cc974cc-7tw9b           5m           87Mi            
apprapp-dashboard-778595658c-7jgfw        5m           114Mi           
apprapp-dashboard-778595658c-wcpkc        5m           116Mi           
apprapp-dashboard-778595658c-xzrf2        5m           113Mi           
apprapp-server-events-65dc95fcb8-bsszq    11m          399Mi           
apprapp-server-events-65dc95fcb8-w5ng5    15m          400Mi           
apprapp-server-events-65dc95fcb8-w85ms    10m          392Mi           
apprapp-server-feature-7456d9dd66-4dbhr   13m          459Mi           
apprapp-server-feature-7456d9dd66-79w8j   20m          461Mi           
apprapp-server-feature-7456d9dd66-d5kdx   17m          460Mi 
```

Analyze the output received from command and find problamatic pod and restart that pod.



## Postgres AutoScale Setup
### TBD