---
layout: default
description: Schematics - How to handle a schematics worker node which is troubled.
title: Schematics - How to handle a worker node which is troubled.
service: schematics
runbook-name: "schematics - How to handle a worker node which is troubled"
tags: schematics, node, down, troubled, worker, az, availability zone
link: /schematics/schematics-node-down.html
type: Alert
grand_parent: Armada Runbooks
parent: Schematics
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to deal with alerts reporting a **schematics** node is troubled.
The Schematics services (API,Jobs,orchestrator, etc) are deployed in a multi-zone cluster - with a worker pool spanning 3 data-centers.

**Permission required**: Please follow [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) to get the required permission to access Schematics Environment.

## Example Alerts
`[Schematics] US South K8s Node down is Triggered on kubernetes.node.name = 10.185.16.91"`


> **Note**
>
> If the alert has the prefix EU then the alert is triggered from one of the EU clusters or if the prefix is BNPP then the alert is triggered from the BNPP/EU-FR2 cluster. Otherwise, it is from one of the US-South/US-East clusters.
>
> The alert title has information regarding the cluster region and the host name.
>
>(Optional) to check sysdig dashboard, please Go to section `Other useful info` mentioned at the bottom of this runbook.

## Actions to take

    Check the Pager Duty for any more "Node Down" alerts are reported and if all are from the same Zone(or data-center), and the failure was triggered simultaneously, then it could be because of any ongoing CIE (slack channel : #containers-cie) in the same region 

### Log into the schematics squad's IBM Cloud account

> SRE can **only** use the same tools and processes which are available to IBM Containers service's customers for debugging and fixing issues with the nodes.
>  
> Official external documentation for debugging worker node issues are [available here](https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_clusters).  
_Reminder : As the nodes are cruiser worker nodes, SRE do **not** have `ssh` access._

To aid SRE, the following steps can be taken to check node status of a schematics cluster.

> **Account ids** :
>
> US Prod (c19ef85117044059a3be5e45d6dc1cf6) <-> 1944771
>
> EU Prod (c1c277d0979b4c1eaef50ab125279c2e) <-> 1998758
>
> BNPP/eu-fr2 (91a8891cb8a0444590d12a16ebc20329) <-> 2123790

1. Log into the associated IBM Cloud account (see above section to obtain account information)  
   `ibmcloud login --sso`  
   ___Tip__ If you are already logged on you can list accounts using_  
   `ibmcloud iam accounts`  
   and  
   `ibmcloud target -c <Account ID>`

1. To target the correct region  
   `ibmcloud target -r <region>`  
   ___Tip__ You can list regions available using_  
   `ibmcloud regions`

1. To find the correct cluster, execute  
   `ibmcloud ks cluster ls`  
   ___Tip__ The cluster name is part of the alert title_

   Export the cluserid as shell variable to re-use in commands later on  
   `export MYCLUSTER=<cluster-ID>`

1. To show details of the workers in this cluster  
   `ibmcloud ks worker ls --cluster $MYCLUSTER`

1. For re-use of the information, export it in shell variables:  
   `export MYWORKER=<worker_name>`  
   `export MYWORKERIP=<worker_ip_address>`

1. To obtain more information on the worker  
   `ibmcloud ks worker get --cluster $MYCLUSTER --worker $MYWORKER`

   The `Status` field here will provide information about any issues that node has.  
   If the `Status` shows `reloading` or `reload_pending` or similar state, the alert can be ignored and should auto-resolve after the indicated activity is completed.

   ~~~shell
   user@host:~$ ibmcloud ks worker get --cluster va-us-south-zone1 --worker kube-dal10-crd5dc142d62ef4d23b44c10b9976c790d-w34
   Retrieving worker kube-dal10-crd5dc142d62ef4d23b44c10b9976c790d-w34...
   OK
   ID:           kube-dal10-crd5dc142d62ef4d23b44c10b9976c790d-w34
   State:        normal
   Status:       Ready
   Private VLAN: 1653547
   Public VLAN:  1653545
   Private IP:   10.171.115.194
   Public IP:    169.46.88.228
   Hardware:     public
   Zone:         dal10
   Version:      1.8.6_1506* (1.8.11_1509 latest)
   ~~~

1. If the state is `critical/Error` or similar , to fix nodes in clusters do the following steps. We generally first try a reboot using cli commands   
   `ibmcloud ks worker reboot --cluster CLUSTER --worker WORKER [--worker WORKER ...] [-f] [--hard]`

1. If a worker reboot fails to bring the node back into the ready state, then a worker reload should be considered. 
   `ibmcloud ks worker reload --cluster CLUSTER --worker WORKER [--worker WORKER ...] [-f] [-s] [--skip-master-health]`  

1. If issue still persists proceed with below steps


### Check master pods health of the cluster

1. Identify the numerical cluster id for the cluster

1. To look up where the cluster is located - look for `ActualDatacenterCluster` in the output  
   [armada-xo](https://ibm-argonauts.slack.com/messages/G53AJ95TP)

1. Log into the master node for the mentioned carrier  

1. Use `kubectl get pods --all-namespaces | grep <cluster_id>` to get master pods of the cluster.  
   
1. Check if master pods are in healthy state if not try to fix them and see the nodes status.


### If None of above steps worked

 If after a reboot and reload a cruiser worker is still in a `Not Ready` state ,escalate to Schematics team by following escalation policy.

---

## Escalation Policy

- Slack channel - [#schematics-dev](https://ibm-argonauts.slack.com/archives/GHFT8J7CJ)
- PD escalation policy : Escalate to [schematics-prod-sev2-4](https://ibm.pagerduty.com/escalation_policies#PNFUE36).

---

## Other useful info 

We can also see alert in sysdig dashboard , to navigate to the alert in sysdig dashboard ,follow below steps 

#### Steps for opening Sysdig alerts dashboard (Optional)

**Steps :**

**To open dashboard If the alert has *EU* prefix**:

   Login to the cloud.ibm.com and then select 1998758 account, go to Resource List -> Services -> Schematics-Prod-SysDig-EU-DE
   
**To open dashboard If the alert does not have a *EU* prefix**:

   Login to the cloud.ibm.com and then select 1944771 account ,go to Resource List -> Services -> Schematics-Prod-Sysdig-US-South
   
**Once the dashboard is opened Proceed with below steps**:

    Open the Events page, to view all the recent High severity Events
        Locate the Event ("K8s Node Down"),
        Record the Node-name, data-center/zone & time-stamp of the failure
    Open the IKS Clusters Page
        Select the Region for which the nodes have failed
        Click on the Worker Nodes tab
        Record the details of all the failed worker nodes.

---
