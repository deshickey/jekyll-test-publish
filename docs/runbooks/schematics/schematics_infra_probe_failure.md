---
layout: default
description: Schematics - Liveness probe failed or Readiness probe failed
title: Schematics - How to handle a probe failure 
service: schematics
runbook-name: "Schematics - How to handle a probe failure "
link: /schematics/schematics-infra-probe-failure.html
type: Alert
grand_parent: Armada Runbooks
parent: Schematics
---

Alert
{: .label .label-purple}

## Overview
The alert triggers when a pod cannot probe a service.
A pod is performing a probe against the service, and in our instance, expecting a HTTP 200 return code to return from the service endpoint we probe.

**Permission required**: Please follow [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) to get the required permission to access Schematics Environment.

---

## Example Alerts


- **Source**: Sysdig
- **Alert Names**: <br> 
                 `"**<pod name>**[Kubernetes]: Liveness probe failed"` 
                 `"**<pod name>**[Kubernetes]: Readiness probe failed"`

- **Alert condition**: `number of events > 1`

- **Trigger duration**: 10 mins

[https://ibm.pagerduty.com/incidents/PXGLELJ](https://ibm.pagerduty.com/incidents/PXGLELJ) <br>
[https://ibm.pagerduty.com/incidents/PGD2893](https://ibm.pagerduty.com/incidents/PGD2893)
   

---

## Actions to take

### Investigation Steps

##### Gather the debug information
* The title of the Pager Duty Incident specifies the pod which has caused the alert. <br>
* The Cluster ID and Name Space info need to be taken from Sysdig portal. The steps are listed below. <br>
* The Region: If the alert has the prefix EU then the alert is triggered from one of the EU clusters or if the prefix is BNPP then the alert is triggered from the BNPP/eu-fr2 cluster. Otherwise, it is from one of the US-South/US-East clusters.

For example: <br>
1. PD Incident `INC2530903:PDE1897017:*EU*  **calico-kube-controllers-7c7d954b58-f6dgf** [Kubernetes] Readiness probe failed is Triggered`.
Here the pod name is `calico-kube-controllers-7c7d954b58-f6dgf`.
2. PD Incident `INC2609981:PDE1943230:[Kubernetes]: Liveness probe failed is Triggered on kubernetes.pod.name = crowdstrike-xcqrd`.
Here the pod name is `crowdstrike-xcqrd`.


##### Steps to collect Cluster ID from Sysdig portal
         - Login to cloud.ibm.com
         - Select `1998758` account for *EU*  or 
                  `1944771` for Non-*EU* or
		  `2123790` for BNPP/EU-FR2
         - Select `Resource List` (on left hand side)
         - Select `Services`
         - Select `Schematics-Prod-SysDig-<REGION>` (for example: REGION is EU-DE for EU)
         - Select `View Sysdig`
         - Select `Event` (on left hand side)
         - Select `Low` at the top of the window
         - View all the recent `Low` severity Events 
         - Locate the latest alert "Liveness probe failed" or "Readiness probe failed"
         - Click on the alert and a new sub-window (with details) will 
		open up on the right hand side
         - Gather the required debug data (the name of the pod, region, namespace and cluster id)

<a href="images/Schematics Probe Failure.png">
<img src="images/Schematics Probe Failure.png" alt="Schematics Probe Failure" style="width: 300px;"/></a>


##### Steps to identify and fix the failing pods from CLI 


1. Login using CLI

         > ibmcloud login --sso (or use other options to login)

2. Select Schematics Softlayer Account 1944771 (US-South/US-East)
   or 1998758 (EU) or `2123790` for BNPP/EU-FR2

   If the alert has the prefix EU then the alert is triggered from one of the EU clusters or if the prefix is BNPP then the alert is triggered from the BNPP/eu-fr2 cluster. Otherwise, it is from one of the US-South/US-East clusters.

3. List the clusters

         > ibmcloud ks clusters

4. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>


5. Find the service name of the failing pod and verify if all the pods of that service are running ok. <br>
For example:  
The pod name from above example PD Incident is `calico-kube-controllers-7c7d954b58-f6dgf`. In this case the corresponding Service name is `calico-kube-controllers`.

		> kubectl get pods --namespace=<namespace name> | grep <SERVICE_NAME>

6. If all the pods of identified microservice are in running state, it might be that the failed pod has been deleted and new pods are created and running successfully. Please resolve the Pager Duty Incident  manually with the investigation and identification details as resolution comments. Otherwise, go to next step.

7. There is a possibility that, the service itself is down and no PODs from this service will be running.
If the PODs are in `ContainerCreating` state then kubernetes may be in the process of resolving the issue and re-creating the containers.  
If this is the case, monitor the PODs and only continue with further steps if the containers fail to create after a period of 5 to 10 minutes.

8. If the PODs are NOT in the `Running` state then following action need to be taken to revive the PODs: <br>
Collect the debug information for further investigation by the development team.
- Capture describe of POD `kubectl describe pod <pod-name> -n <namespace>` 
- Collect the logs for each pod in this state `kubectl logs <pod-name> -n <namespace> > <pod-name-file>.log 2>&1`
- After collecting debug, delete the PODs:
 `kubectl delete pod <pod-name> -n <namespace>` 
-  After deleting, monitor the POD recreation by running `kubectl get pods -n <namespace>` to check the pod has recovered successfully.
If the PODs recreate successfully, the associated pagerduty alert should auto resolve.
If the PODs fail to create, re-gather the debug and pod logs as described earlier and follow the steps in `escalation policy` below.


## Automation
None

## Escalation Policy

* Slack channel : [#schematics-dev](https://ibm-argonauts.slack.com/archives/GHFT8J7CJ)
* PD escalation Policy : Escalate to [schematics-low-urgency](https://ibm.pagerduty.com/escalation_policies#PVF4F77)



---


