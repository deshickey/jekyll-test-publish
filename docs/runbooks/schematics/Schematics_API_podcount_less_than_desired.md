---
layout: default
description: Schematics API Pod count is less than desired 
title: Schematics API Pod count is less than desired 
service: schematics
runbook-name: "Schematics API Pod count is less than desired"
link: /schematics/Schematics_API_Pod_count_is_less_than_desired.html
type: Alert
grand_parent: Armada Runbooks
parent: Schematics
---

Alert
{: .label .label-purple}


## Overview

The schematics services has defined a desirable size of 3 pods for the API services.

**Permission required**: Please follow [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) to get the required permission to access Schematics Environment.

---

## Example Alert


- **Source**: Sysdig
- **Alert Name**: `"**<service name>**[Kubernetes] Pods Available less than desired is Triggered"`
or `"*EU*<cluster name--service name>[Kubernetes] Pods Available less than desired is Triggered"`

- **Alert condition**: `avg(timeAvg(kubernetes.deployment.replicas.available)) < avg(timeAvg(kubernetes.deployment.replicas.desired))`

- **Trigger duration**: 5 mins for 100%


---

## Actions to take 

#### Collect the debug data from Pager Duty Incident

If the alert has the prefix `*EU*` then the alert is triggered from one of the EU clusters or if the prefix is `*BNPP*` then the alert is triggered from the BNPP/eu-fr2 cluster. Otherwise, it is from one of the US-South/US-East clusters.

Take a look at the description of the alert in the Pager Duty (PD) Incident to collect the Cluster ID.
Example of PD Incident Title: `INC2630536:PDE1960114:*EU*  [Schematics] API Pods Available less than desired is Triggered on cluster = schematics-prod-eu-de-01/bmp46d5f0pu4npo0u9s0`.
This is a PD Incident triggered from EU Cluster and the Custer ID is `bmp46d5f0pu4npo0u9s0`. 
Refer to [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) for Cluster ID information for US/EU/BNPP regions.

Proceed to `Investigation Steps`.

#### Investigation Steps

1. Use IBM Cloud CLI to login to the Production Account

         > ibmcloud login --sso (or use other options to login)

         > ibmcloud target -c c19ef85117044059a3be5e45d6dc1cf6  
               (1944771 - for US-South/US-East production account) 

         > ibmcloud target -c c1c277d0979b4c1eaef50ab125279c2e 
                (1998758 - for EU production account)
                
         > ibmcloud target -c 91a8891cb8a0444590d12a16ebc20329 
                (2123790 - for BNPP production account)

2. List the clusters and set the region to point to the required cluster

         > ibmcloud ks clusters

3. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <cluster-id>

4. List the pods in scematics namespace

         > kubectl get pods -n schematics

5. Check whether the pods name prefixed `api` is in error/unknown state. If yes, go to next step. If those pods are not in error/unkonw state, the issue is resolved. No further action is required. 

6. Delete the identified api pods that are in error and unknown state, to create new pods
   
         > kubectl delete pods <api-pod in error state> -n schematics

6. Monitor if new pods are created with running or ready state

7. If the new pods continue to go to error/unknown/any state other than 'Ready', collect the logs and follow the escalation step.

---

## Automation 

None

---

## Escalation Policy

* Slack channel : [#schematics-dev](https://ibm-argonauts.slack.com/archives/GHFT8J7CJ)
* PD escalation policy : Escalate the PD alert to  [schematics-prod-sev1](https://ibm.pagerduty.com/escalation_policies#PNZJB5U)
 
---
