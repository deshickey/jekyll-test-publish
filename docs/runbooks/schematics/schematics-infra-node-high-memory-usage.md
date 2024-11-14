---
layout: default
description: Schematics - How to handle a node which is reporting high MEMORY usage
title: Schematics - How to handle a node which is reporting high MEMORY usage
service: schematics
runbook-name: "Schematics - How to handle a node which is reporting high MEMORY usage"
link: /schematics/schematics-infra-node-high-memory-usage.html
type: Alert
grand_parent: Armada Runbooks
parent: Schematics
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle a worker node which is reporting high Memory usage.

Kube Scheduler puts many pods on worker nodes and some pods may demands more memory while serving requests.
Memory usage reaches a state where only  20MiB is left to use from the alerted worker.
Investigation is required to identify which pods using high memory on the alerting node.

**Permission required**: Please follow [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) to get the required permission to access Schematics Environment.

---


## Example Alert

- **Source**: Sysdig
- **Alert Name**: <br>
		 `"Memory Usage Warning"` <br>
		 `"Memory Usage Critical"`
- **Alert condition**: `"Average"` of `"memory.used.percentage"` is `>=66%` for `"the last 10 minutes"` - warning.
                       `"Average"` of `"memory.used.percentage"` is `>=90%` for `"the last 10 minutes"` - critical.
- **Trigger duration**: 10 min

---

## Actions to take

##### Gather the debug information
* The title of the Pager Duty (PD) Incident has the information about the `cluster region` (optionally `cluster id`) and the `host name` <br>
* The Cluster ID will be available in the `description` of the PD Incident.

Example PD Incident title:
`{hostname} Memory Usage Warning is triggered on cluster = cluster name/region`

##### If the required debug data is not available in the PD Incident, login to Sysdig portal and gather the same
         - Login to cloud.ibm.com
         - Select `1998758` account for *EU*  or
                  `1944771` for Non-*EU* or 
	          `2123790` for BNPP/EU-FR2
         - Select `Resource List` (on left hand side)
         - Select `Services`
         - Select `Schematics-Prod-SysDig-<Account Region>`
         - Select `View Sysdig`
         - Select `Event` (on left hand side)
         - Select `Med` at the top of the window
         - View all the recent `Med` severity Events
         - Locate the latest alert title as per the received PD Incident title "Memory Usage Warning" or  "Memory Usage Critical"
         - Click on the alert and a new sub-window (with details) will
                open up on the right hand side
         - Gather the required debug data (hostName and cluster ID)

<a href="images/Schematics Probe Failure.png">
<img src="images/Schematics Probe Failure.png" alt="Schematics Probe Failure" style="width: 300px;"/></a>

### Investigation
We need to take the following immediate actions

- confirm that the alerted worker node is remain functional in terms of memory
- confirm other worker nodes are not alerted out of memory warning
- if other nodes are also alerted for out of memory involve Schematics squad for further investigation

### Cordon the worker node

1. Login using CLI

         > ibmcloud login --sso (or use other options to login)

2. Select Schematics Softlayer Account 1944771 (US-South/US-East)
   or 1998758 (EU) or 2123790 (BNPP/EU-FR2)

   If the alert has the prefix EU then the alert is triggered from one of the EU clusters or if the prefix is BNPP then the alert is triggered from the BNPP/EU-FR2 cluster. Otherwise, it is from one of the US-South/US-East clusters.

3. List the clusters

         > ibmcloud ks clusters

4. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

5. Cordon the worker node 

		>  kubectl cordon --reason "high memory usage" <WORKER-NODE-IP>


### Investigate if the cluster is overloaded

Ensure the cluster is not overloaded by checking memory usage.
Login to the sysdig instance using the below steps to view the usage of all worker nodes.

#### View Sysdig Portal

	- Login to [cloud.ibm.com](cloud.ibm.com)
        - Select 1998758 account for *EU*  or
                 1944771 account for *Non-EU* or
	         2123790 account for BNPP/EU-FR2
        - Select `Resource List` (on left hand side)
        - Select `Services`
        - Select `Schematics-Prod-SysDig-EU-DE` for *EU*  or 
                  `Schematics-Prod-Sysdig-US-South` for *Non-EU* or 
	          `Schematics-Prod-SysDig-EU-FR2` for *BNPP/EU-FR2*
        - Select `View Sysdig`
		- Go to Dashboards (on left panel) 
		- Under `Shared By My Team`, Select `Kubernetes Cluster and Node Capacity`
		- Go to `Capacity Details` (scroll down to locate it)
        	- Review `Memory Requests/Limits/Capacity by Nodes`
		- Review pods per node  

If multiple worker nodes have high memory usage, this cluster may need more worker nodes adding to it.Contact Schematics team for adding new worker nodes. If not, proceed to the next step.


### Check what processes are using high memory on the reported worker node
Follow the steps mentioned above to `View Sysdig Portal`

        - Go to Dashboards (on left panel)
        - Under `Shared By My Team`, select "Overview by Host"
        - Go to `Host-Process` (scroll down to locate it)
        - In the table of hosts, get the process of the reported host/worker node that is consuming high percentage of Memory and investigate 

  - Check the process PODs running on the node, capture logs from those PODs  -  for example: `kubectl logs -n <namespace> <pod>` and raise a [GHE Issue](https://github.ibm.com/blueprint/schematics-devops/issues) against the schematics squad.
  - Once logs have been captured, consider deleting the POD `kubectl delete pod <pod-name> -n <Namespace of the identified the process>` to see if this is a temporary issue and recreating it resolves the high memory usage.
  - Monitor the Memory after taking above actions.  If improvements are not seen, if there is a particular POD which is consuming a lot of Memory or has spiked and remained high, go to escalation policy.
  
---
## Automation 
None 
## Escalation policy
* Slack channel : [#schematics-dev](https://ibm-argonauts.slack.com/archives/GHFT8J7CJ)
* PD escalation policy : Escalate to [schematics-prod-sev2-4](https://ibm.pagerduty.com/escalation_policies#PNFUE36)


---
