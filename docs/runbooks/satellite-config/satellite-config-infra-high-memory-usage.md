---
layout: default
description: How to handle a node which is reporting high MEMORY usage
title: Satellite Config - How to handle a node which is reporting high MEMORY usage
service: Satellite Config
runbook-name: "Satellite Config - How to handle a node which is reporting high MEMORY usage"
link: /satellite-config/satellite-config-infra-high-memory-usage.html
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Config
---

Alert
{: .label .label-purple}


## Overview

This runbook describes how to handle a worker node which is reporting high memory usage.

Kube Scheduler puts many pods on worker nodes and some pods may demand more memory while serving requests.
Memory usage reaches a state where only 20MiB remains to use from the alerted worker.
Investigation is required to identify the pods using high memory on the alerting node.

**Permission required**: Please follow [Satellite Config access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/satellite-config/Introduction_to_SatelliteConfig_Infrastructure.html) to get the required permission to access Satellite config Environment.

---

## Example Alert

- **Source**: Sysdig
- **Alert Name**: <br>
		 `"Memory Usage Warning"` <br>
		 `"Memory Usage Critical"`
- **Alert condition**: <br>
  `"Average"` of `"memory.used.percentage"` is `>=60%` for `"the last 10 minutes"` - warning. <br>
  `"Average"` of `"memory.used.percentage"` is `>=90%` for `"the last 10 minutes"` - critical.
- **Trigger duration**: 30 min

---

## Actions to take

##### Gather the debug information
* The title of the Pager Duty (PD) Incident has the information about the `cluster region`, `cluster id` and the `host name` <br>
* The Cluster ID will be available in the `description` of the PD Incident.

Example PD Incident title:
`{hostname} Memory Usage Warning is triggered on cluster = cluster name/region`


##### If the required debug data is not available in the PD Incident, login to Sysdig portal and gather the same
Login to Sysdig portal and gather details-

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select 2094928 account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Monitoring`
	- Select `Razee-Hosted-Sysdig-Prod-us-east` for *US-East*  
	- Select `View Sysdig`
  - Select `Event` (on left hand side)
  - Select `Low/Med` at the top of the window
  - View all the recent `Med` severity Events
  - Locate the latest alert `Memory Usage Warning` or `Memory Usage Critical`
  - Click on the alert and a new sub-window (with details) will
    open up on the right hand side
  - Gather the required debug data

### Investigation
We need to take the following immediate actions

- confirm that the alerted worker node is functional in terms of memory
- confirm other worker nodes are not alerted out of memory warning
- if other nodes are also alerted for out of memory involve Satellite Config squad for further investigation

### Cordon the worker node

1. Use IBM Cloud CLI to login to the Production Account

    - Login using CLI

    	> ibmcloud login --sso (or use other options to login)

    - Select Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928


2. List the clusters and nodes

        > ibmcloud ks clusters
        > ibmcloud ks workers --cluster <CLUSTER-ID>

3. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

4. Cordon the worker node

		>  kubectl cordon --reason "high memory usage" <WORKER-NODE-IP>


### Investigate if the cluster is overloaded

Ensure the cluster is not overloaded by checking memory usage.
Login to the Sysdig instance using the below steps to view the usage of all worker nodes.

#### View Sysdig Portal

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select `2094928 Satellite Production` account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Monitoring`
	- Select `Razee-Hosted-Sysdig-Prod-us-east` for *US-East*  
	- Select `View Sysdig`
- Go to Dashboards (on left panel)
- Under `Shared By My Team`, Select `Kubernetes Cluster and Node Capacity`
- Review pods per node
		- Go to `Capacity Details` (scroll down to locate it)
        	- Review `Memory Requests/Limits/Capacity by Nodes`
		- Review pods per node  

If multiple worker nodes have high memory usage, this cluster may need more worker nodes. If not, proceed to the next step.

### Check what processes are using high memory on the reported worker node
Follow the steps mentioned above to `View Sysdig Portal`

        - Go to Dashboards (on left panel)
        - Under `Shared By My Team`, select "Overview by Host"
        - Go to `Host-Process` (scroll down to locate it)
        - In the table of hosts, get the process of the reported host/worker node that is consuming high percentage of Memory and investigate

  - Check the process PODs running on the node, capture logs from those PODs  -  for example: `kubectl -n razee logs <pod>` and raise a [GHE Issue](https://github.ibm.com/alchemy-containers/satellite-config/issues) against the Satellite Config squad.
  - Once logs have been captured, consider deleting the POD `kubectl -n razee delete pod <pod-name>` to see if this is a temporary issue and recreating it resolves the high memory usage.
  - Monitor the memory after taking above actions.  If improvements are not seen, if there is a particular POD which is consuming a lot of Memory or has spiked and remained high, go to escalation policy.

## Automation

None

## Escalation policy
* Please contact the Satellite Config squad in the [#satellite-config](https://ibm-argonauts.slack.com/archives/CPPG4CX3N) slack channel for further information
* PD escalation policy : Escalate to [Alchemy - Satellite - Config](https://ibm.pagerduty.com/escalation_policies#P42GAQ1)
