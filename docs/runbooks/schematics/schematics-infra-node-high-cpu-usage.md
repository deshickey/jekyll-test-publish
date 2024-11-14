---
layout: default
description: How to handle a node which is reporting high CPU usage
title: Schematics - How to handle a node which is reporting high CPU usage
service: schematics
runbook-name: "Schematics - How to handle a node which is reporting high CPU usage"
link: /schematics/schematics-infra-node-high-cpu-usage.html
type: Alert
grand_parent: Armada Runbooks
parent: Schematics
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle a worker node which is reporting high CPU usage.

Worker nodes have many pods running on them, all performing different tasks.
Sometimes a worker node can get overloaded because the Kube scheduler puts work onto an already busy worker node.
In other cases, the whole cluster may be nearly overloaded.

This alert will trigger worker nodes going over 80% CPU usage and remaining above this percentage for 10 minutes or more.

**Permission required**: Please follow [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) to get the required permission to access Schematics Environment.

---


## Example Alert

- **Source**: Sysdig
- **Alert Names**: <br> 
                  `"CPU usage warning"` <br>
		  `"[Schematics] Total CPU Capacity Threshold Alert"` <br>
		  `"Processor Load is too high"`
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
         - Locate the latest alert title as per the received PD Incident title "CPU usage warning" or "Total CPU Capacity Threshold Alert" or "Processor Load is too high"
         - Click on the alert and a new sub-window (with details) will
                open up on the right hand side
         - Gather the required debug data (hostName and cluster ID)

<a href="images/Schematics Probe Failure.png">
<img src="images/Schematics Probe Failure.png" alt="Schematics Probe Failure" style="width: 300px;"/></a>


### Cordon the worker node

1. Login using CLI

         > ibmcloud login --sso (or use other options to login)

2. Select Schematics Softlayer Account 1944771 (US-South/US-East)
   or 1998758 (EU) or 2123790 (BNPP/EU-FR2)

   If the alert has the prefix *EU* then the alert is triggered from one of the EU clusters or if the prefix is *BNPP* then the alert is triggered from the BNPP/eu-fr2 cluster. Otherwise, it is from one of the US-South/US-East clusters.

3. List the clusters

         > ibmcloud ks clusters

4. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

5. Cordon the worker node 

		>  kubectl cordon --reason "high cpu usage" <WORKER-NODE-IP>


### Investigate if the cluster is overloaded

Ensure the cluster is not overloaded by checking both memory and CPU usage.
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
        	- Review `CPU Requests/Limits/Capacity by Nodes` 
		- Review pods per node  

If multiple worker nodes have high cpu usage, this cluster may need more worker nodes adding to it.Contact Schematics team for adding new worker nodes. If not, proceed to the next step.

### Check what processes are using high amounts of CPU on the reported worker node
Follow the steps mentioned above to `View Sysdig Portal`

        - Go to Dashboards (on left panel)
        - Under `Shared By My Team`, select "Overview by Host"
        - Choose the `Region` and `hostName` as per identified from above steps
        - Find the processes consuming high percentage of CPU and investigate why these processes are consuming high CPU

  - Non container based processes such as system or root processes tied with the operating system may indicate an issue with the server so consider draining and rebooting the worker node. <br>
	Drain: `kubectl drain <Worker-Private-IP>` <br>
    	Reboot:	`ibmcloud ks worker-reboot --cluster <CLUSTER-ID> <Worker-Privte-IP>` <br>

    	Note: this may just push the problem to another worker node if it is a problem with a POD.
  - If the process can be linked to one of the PODs running on the node, capture logs from that POD  -  for example: `kubectl logs -n <namespace> <pod>` and raise a [GHE Issue](https://github.ibm.com/blueprint/schematics-devops/issues) against the schematics squad.
  - Once logs have been captured, consider deleting the POD `kubectl delete pod <pod-name> -n <Namespace of the identified the process>` to see if this is a temporary issue and recreating it resolves the high CPU.
- Monitor the CPU after taking above actions.  If improvements are not seen, if there is a particular POD which is consuming a lot of CPU or has spiked and remained high, go to escalation policy.

### Check non-terminated pod distribution and re-balance if necessary

1. After checking the cordoned node status, check how non-terminated pods are distributed across the carrier - example:
    ~~~shell
    kubectl describe node <Worker-Privte-IP> | grep -E '^(Name|Non)'
    Name:               10.176.215.2
    Non-terminated Pods:         (24 in total)
    Name:               10.176.215.31
    Non-terminated Pods:         (32 in total)
    Name:               10.176.215.43
    Non-terminated Pods:         (19 in total)
    Name:               10.176.215.5
    Non-terminated Pods:         (31 in total)
    Name:               10.176.215.60
    Non-terminated Pods:         (21 in total)
    Name:               10.176.215.9
    Non-terminated Pods:         (40 in total)
    ~~~
    _to limit to 30 and over use:  
    `kubectl describe node <Worker-Private-IP> | grep -E '^(Name|Non)' | grep -E '(Name|\([1-9][0-9][0-9]|\([3-9][0-9])'`_  
    _*Warning: the above command takes a while to run!*_

2. If the node reporting high cpu usage has over 40 non-terminated pods, drain some pods from this worker to other worker nodes by cordoning the node and then deleting the pods.

    Identify a worker pods on the node that we can delete:
    `kubectl get pods -n kubx-masters -o=wide | grep <Worker-Private-IP>` <br>
    Delete it with:<br>
    `kubectl delete pod -n kubx-masters <POD_NAME>`


3. The cpu usage of the node should go down.  You can confirm by going to sysdig dashboard,select region,hostname.

4. Once pods have rescheduled onto other nodes, and the alert has resolved uncordon the worker with:
   `kubectl uncordon <Worker-Private-IP>`

## Automation 

None 

## Escalation policy
* Slack channel : #schematics-dev
* PD escalation policy : Escalate to [schematics-prod-sev2-4](https://ibm.pagerduty.com/escalation_policies#PNFUE36)

