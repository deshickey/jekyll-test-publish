---
layout: default
description: How to reboot if a VPC worker is stuck  
title: How to reboot a VPC worker node(s)  
service: armada-infra
category: vpc-worker-reboot
runbook-name: "How to reboot a VPC worker node to handle a node issue"
tags: alchemy, armada, kubernetes, kube, kubectl, read-only, initramfs 
link: /armada/armada-vpc-worker-reboot.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes how to handle a VPC worker reboot when a VPC node is stuck due to issues such as filesystem write error, read-only caused by external factors such as SAN outage. 


## Detailed Information 

In certain situations, VPC workers can experience outage such as SAN issue or other infrastructure related issues, which could trigger reboot of the system out of kernel panic. However, the read-only filesystem issue can be persistent when a machine is trying to come back up. Consequently, the worker node fails to mount the root filesystem and the node becomes no longer available within a cluster. 

A solution to this type of situation is when outage is no longer present, all VPC workers should be rebooted in impacted regions. It is important to be aware that the remediation action here can reduce our impact time and reduce the turnaround time to resolution.

This is not an instruction to troubleshoot a customer owned VPC workers but how to recover outages from the infrastructure level. Please refer [https://cloud.ibm.com/docs/containers?topic=containers-responsibilities_iks](https://cloud.ibm.com/docs/containers?topic=containers-responsibilities_iks) for more details regarding to responsibilities.

### How to execute mass reboot of VPC workers 

1. Access **1984462 - IKS.Prod.VPC.Service** account via ibmcloud CLI. 

1. Install `vpc-infrastructure` IBM Cloud plugin if haven't

1. Set the impacted region using `ibmcloud target -r [REGION]`

1. Populate a list of VPC worker for one zone in the region by the following script. **IMPORTANT: Make sure you only operate one zone at a time.** 

```
eg) Region: au-syd    Zone: au-syd-1
ibmcloud is instances | grep au-syd-1 >> /tmp/au-syd-1-workers
```

1. In case, all workers in the impacted region are not up and running, you can follow the procedure using the associated scripts provided below.

  - Use the populated a list file eg, `/tmp/au-syd-1-workers` for each operation
  - Stop all VPC workers in a zone using `vpc_stop.sh /tmp/au-syd-1-workers` 
  - Check the status of VPC workers using `vps_status.sh /tmp/au-syd-1-workers` til all workers are in Stopped state
    - If there is an issue with stopping a VPC worker, it needs to be removed from the list file and open a ticket to SL team for further investigation.
  - Start VPC workers using `vpc_start.sh /tmp/au-syd-1-workers` 
    - Currently there is a sleep time for 15 seconds set to avoid any issue with API request handling. In case VPC API responds slow or intermittent failure, the sleep time can be increased to cope with the situation. 
  - Check the status using `vps_status.sh /tmp/au-syd-1-workers` til all workers are in running state


### vpc_status.sh
```
#!/usr/bin/env bash
list_file=$1
while read -r line; do
  instance_id=$(echo "$line" | awk '{print $1}')
  worker_name=$(echo "$line" | awk '{print $2}')
  echo $instance_id
  ibmcloud is instance "$instance_id" | grep "Status"
  sleep 1
done<$list_file
```

### vpc_stop.sh
```
#!/usr/bin/env bash
list_file=$1
while read -r line; do
  instance_id=$(echo "$line" | awk '{print $1}')
  worker_name=$(echo "$line" | awk '{print $2}')
  ibmcloud is instance-stop "$instance_id" --force
  sleep 1
done<$list_file
```

### vpc_start.sh
```
#!/usr/bin/env bash
list_file=$1
while read -r line; do
  instance_id=$(echo "$line" | awk '{print $1}')
  worker_name=$(echo "$line" | awk '{print $2}')
  ibmcloud is instance-start "$instance_id"
  sleep 15
done<$list_file
```

## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK) on Slack.
