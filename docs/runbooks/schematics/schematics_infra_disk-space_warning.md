---
layout: default
description: Schematics - How to handle nodes with disk space warning
title: Schematics - How to handle nodes with disk space warning
service: schematcis
runbook-name: "Schematics - How to handle nodes with disk space warning"
link: /schematics/schematics_how_tohandle_nodes_with_diskspacewarning.html
type: Alert
grand_parent: Armada Runbooks
parent: Schematics
---

Alert
{: .label .label-purple}

## Overview
This runbook describes how to handle the nodes which are running out of disk space or has got disk 100% full.

**Permission required**: Please follow [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) to get the required permission to access Schematics Environment.

## Example Alert
- **Source**: Sysdig
- **Alert Names**: <br> `"[Kubernetes] Node out of disk"` <br>
		   `"[Kubernetes] Node under disk pressure` <br>
                   `"Root volume disk usage warning"`  <br>
		   `"Filesystem device full warning"`  <br>
		   `"Largest volume disk usage warning"` 

- **Alert condition**: `"avg(avg(kubernetes.node.outOfDisk)) != 0"`
- **Trigger duration**: 10 mins

[https://ibm.pagerduty.com/incidents/PI9D2U8](https://ibm.pagerduty.com/incidents/PI9D2U8) <br>
`{nodename} [Kubernetes] Node out of disk`

---

## Actions to take

### Investigation

##### Gather the debug information

Example PD Incident Title:
`INC2381665:PDE1848727:kube-bko1vhhd0cgnhj8ebg40-schematicsp-schemat-000022e6 Largest volume disk usage warning is Triggered on host.mac = 06:80:b2:a0:a7:02`

* The Worker node name will be available in the title of the Pager Duty (PD) Incident <br>
  In this example it is `kube-bko1vhhd0cgnhj8ebg40-schematicsp-schemat-000022e6`
* The Cluster ID will be available as part of the Worker node name <br>
  In this example it is  `bko1vhhd0cgnhj8ebg40` <br>

#### Steps

	The troubled worker node need to be reloaded to fix the disk warning error. Gather the disk usage information prior to reload.

##### ssh to the worker node and capture the disk usage information
`Note: this is a cruiser worker node so no direct ssh access is available.


- use [running commands on worker nodes runbook](./../armada/armada-run-commands-on-workers.html) to safely gain access to worker nodes.

- Notify SoS in #soc-notify channel that the worker node will be accessed. <br>
  Example Template to be posted in the channel:

		I’m going to ssh to worker node for debugging purpose.
		CRN App ID: schematics
		Cluster Name: schematics-prod
		Cluster ID: bko21qlw0i694b4upbgg
		Worker Name/ID: kube-bko1vhhd0cgnhj8ebg40-schematicsp-schemat-000022e6
		Justification: debugging issue on worker node

1. Login using CLI

		> ibmcloud login --sso (or use other options to login)

2. Select Schematics Softlayer Account 1944771 (US-South/US-East) 
   or 1998758 (EU) or 2123790 (BNPP/EU-FR2)

   If the alert has the prefix EU then the alert is triggered from one of the EU clusters or if the prefix is BNPP then the alert is triggered from the BNPP/eu-fr2 cluster. Otherwise, it is from one of the US-South/US-East clusters.


3. List the clusters 

         > ibmcloud ks clusters

4. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

5. Get the worker node `Private IP` address (will be used for drain command) using below command

		> ibmcloud ks worker get --cluster <CLUSTER-ID> --worker <WORKER-NODE-NAME>
		Example:
		> ibmcloud ks worker get --cluster bmp46d5f0pu4npo0u9s0 --worker kube-bmp46d5f0pu4npo0u9s0-schematicsp-default-00000103 

6. Exec to the node: <br>
Execute the below commands and capture the output. Open a GHE Issue in [Schematics-GitRepo](https://github.ibm.com/blueprint/schematics-devops/issues) and save the output in the GHE Issue. Add the PD Incident to GHE Issue and vice versa (i.e. add the GHE Issue to PD Incident).  <br>

		Gather the output of `df -Th` command
		
		Gather /var/log files that are greater than +2G
		> find /var/log -size +2G
			
		Gather the directory names that's consumed a huge memory
		> du -h > /tmp/du_h_output.txt
			
		Gather the details of top 3 directories that consumed a huge memory
		> command du <directory name>| sort -n -r | head -n 30
		
	Ignore if any of the above commands doesn't provide any output. 		


##### Reload the worker node
1. Ignore DRAIN:
Suppose to Drain the worker node prior to RELOAD, however, since SRE doesn't have ADMIN permissions (not suppose to have it) can't run any kubectl commands including ``` kubectl drain <WORKER-NODE-NAME> ``` on worker nodes. As per discussion with Schematics squad we can skip DRAIN and proceed to step 2.
2. Reload the worker node 

		> ibmcloud ks worker reload --cluster <CLUSTER-ID> -w <WORKER-NODE-NAME> -f

3. Wait for the reload to complete. Gather the worker node status by running below command

		> ibmcloud ks worker get --cluster <CLUSTER-ID> --worker <WORKER-NODE-NAME>		
4. If the worker node is back to Ready state, the PD Incident suppose to be auto resolved. If not, proceed to escalation policy.
5. If the work node is NOT back to Ready state, add the worker status information from above command to the PD Incident and the GHE Issue opened in above steps. Proceed to the Escalation Policy. The Schematics Squad need to open an issue with Softlayer to fix the troubled worker node.

## Automation
None


## Escalation Policy
* Slack channel : [#schematics-dev](https://ibm-argonauts.slack.com/archives/GHFT8J7CJ)
* PD escalation policy : Escalate to [schematics-prod-sev2-4](https://ibm.pagerduty.com/escalation_policies#PNFUE36)


----

