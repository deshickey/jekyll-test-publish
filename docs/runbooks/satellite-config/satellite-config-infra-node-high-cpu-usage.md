---
layout: default
description: How to handle a node which is reporting high CPU usage
title: Satellite Config - How to handle a node which is reporting high CPU usage
service: Satellite Config
runbook-name: "Satellite Config - How to handle a node which is reporting high CPU usage"
link: /satellite-config/satellite-config-infra-node-high-cpu-usage.html
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Config
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle a worker node which is reporting high CPU usage.

Worker nodes have many pods running on them, all performing different tasks.
Sometimes a worker node can get overloaded because the Kube scheduler puts work onto an already busy worker node.
In other cases, the whole cluster may be overloaded.

This alert will trigger worker nodes exceed 80% CPU usage and remain above this percentage for 10 minutes or more.

**Permission required**: Please follow [Satellite Config access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/satellite-config/Introduction_to_SatelliteConfig_Infrastructure.html) to get the required permission to access Satellite config Environment.


---


## Example Alert

- **Source**: Sysdig
- **Alert Names**: `"CPU usage warning"`
- **Alert condition**: `"Average"` of `"cpu.used.percent"` is `>=80` for `"the last 10 minutes"`
- **Trigger duration**: 10 mins for >=80%

---

## Actions to take

##### Gather the debug information
* The title of the Pager Duty (PD) Incident has the information about the `cluster region` (optionally `cluster id`) and the `host name` <br>
* The Cluster ID will be available in the `description` of the PD Incident.

Example PD Incident title:
`{hostname} CPU usage warning is triggered on cluster = cluster name/region.`

##### If the required debug data is not available in the PD Incident, login to Sysdig portal and gather the same
Login to Sysdig portal and gather details-

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select 2094928 account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Monitoring`
	- Select `Razee-Hosted-Sysdig-Prod-us-east` for *US-East*  
	- Select `View Sysdig`
  - Select `Event` (on left hand side)
  - Select `High` at the top of the window
  - View all the recent `Med` severity Events
  - Locate the latest alert `CPU usage warning`
  - Click on the alert and a new sub-window (with details) will
    open up on the right hand side
  - Gather the required debug data

### Cordon the worker node

1. Use IBM Cloud CLI to login to the Production Account

    - Login using CLI

    	> ibmcloud login --sso (or use other options to login)

    - Select Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928


2. List the clusters and worker nodes

        > ibmcloud ks clusters
        > ibmcloud ks workers --cluster <CLUSTER-ID>

3. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

4. Cordon the worker node

		>  kubectl cordon --reason "high cpu usage" <WORKER-NODE-IP>


### Investigate if the cluster is overloaded

Ensure the cluster is not overloaded by checking both memory and CPU usage.
Login to the sysdig instance using the below steps to view the usage of all worker nodes.

#### View Sysdig Portal

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select 2094928 account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Monitoring`
	- Select `Razee-Hosted-Sysdig-Prod-us-east` for *US-East*  
	- Select `View Sysdig`
- Go to Dashboards (on left panel)
- Under `Shared By My Team`, Select `Kubernetes Cluster and Node Capacity`
- Go to `Capacity Details` (scroll down to locate it)
- Review `CPU Requests/Limits/Capacity by Nodes`
- Review pods per node  

If multiple worker nodes have high cpu usage, this cluster may need more worker nodes adding to it.
Add additional workers and assess if the CPU use stablizes and the alert resolves.
If not, proceed to the next step.

### Check what processes are using high amounts of CPU on the reported worker node
Follow the steps mentioned above to `View Sysdig Portal`

        - Go to Dashboards (on left panel)
        - Under `Shared By My Team`, select "Overview by Host"
        - Choose the `Region` and `hostName` as per identified from above steps
        - Find the processes consuming high percentage of CPU and investigate why these processes are consuming high CPU

  - Non-container based processes such as system or root processes tied with the operating system may indicate an issue with the server so consider draining and rebooting or reloading the worker node. <br>
	Drain: `kubectl drain <Worker-Private-IP>` <br>
    	Reboot:	`ibmcloud ks worker-reboot --cluster <CLUSTER-ID> <Worker-Privte-IP>` <br>

    	Note: this may push the problem to another worker node if its a pod problem.
  - If the process can be linked to one of the PODs running on the node, capture logs from that POD  -  for example: `kubectl -n <namespace> logs <pod>` and raise a [GHE Issue](https://github.ibm.com/alchemy-containers/satellite-config/issues) with the Satellite Config squad.
  - After capturing logs consider deleting the POD `kubectl -n razee delete pod <pod-name> ` to see if this is a temporary issue and recreating it resolves the high CPU.
- Monitor the CPU after taking above actions.  If improvements are not seen, if there is a particular POD which is consuming a lot of CPU or has spiked and remained high, go to escalation policy.



## Automation

None

## Escalation policy
* Please contact the Satellite Config squad in the [#satellite-config](https://ibm-argonauts.slack.com/archives/CPPG4CX3N) slack channel for further information
* PD escalation policy : Escalate to [Alchemy - Satellite - Config](https://ibm.pagerduty.com/escalation_policies#P42GAQ1)
