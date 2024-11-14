---
layout: default
description: Satellite config Pod count is less than desired
title: Satellite config Pod count is less than desired
service: Satellite Config
runbook-name: "Satellite Config Pod count is less than desired"
link: /schematics/satellite-config-pod-count-is-less-than-desired.html
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Config
---

Alert
{: .label .label-purple}

## Overview

When a few pods do a restart or get into a state other than 'Ready',
the available pod count falls less than the desired pod count.

The alert is segmented based on the deployment name and is scoped only to `satellite-config`.


**Permission required**: Please follow [Satellite Config access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/satellite-config/Introduction_to_SatelliteConfig_Infrastructure.html) to get the required permission to access Satellite config Environment.

---

## Example Alert


- **Source**: Sysdig
- **Alert Name**: `"**<service name>**[Kubernetes] Satellite Config pod count less than desired"`

- **Alert condition**: `avg(timeAvg(kubernetes.deployment.replicas.available)) < avg(timeAvg(kubernetes.deployment.replicas.desired))`

- **Trigger duration**: 5 mins for 100%



---

## Actions to take

#### Collect the debug data from Pager Duty Incident


Login to Sysdig portal and gather details-

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select 2094928 account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Monitoring`
	- Select `Razee-Hosted-Sysdig-Prod-us-east` for *US-East*  
	- Select `View Sysdig`
  - Select `Event` (on left hand side)
  - Select `High` at the top of the window
  - View all the recent `High` severity Events
  - Locate the latest alert `Satellite Config Pods Available less than desired is triggered.`
  - Click on the alert and a new sub-window (with details) will
    open up on the right hand side
  - Gather the required debug data


Proceed to `Investigation Steps`.

#### Investigation Steps

1. Use IBM Cloud CLI to login to the Production Account

    - Login using CLI

    	> ibmcloud login --sso (or use other options to login)

    - Select Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928


2. List the clusters and nodes

        > ibmcloud ks clusters
        > ibmcloud ks workers --cluster <CLUSTER-ID>

3. Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

4. Can run kubectl commands to get further information

         > kubectl get pods -n razee

5. Check if the number of `deployment` pods match the `desired available replicas` value. If it matches, then the issue is resolved. No further action is required.
If it doesn't match, identify the pod names in error or unknown state, which are prefixed with the `deployment` name specified in the alert.
For example: if deployment name is `satellite-config` the pod name would be `satellite-config-<some value>`.
Delete the identified pods that are in error or unknown state.

         > kubectl delete pod <pod-name> -n <Namespace identified in the alert>

6. Monitor if new pods are created with running or ready state.

7. If the new pods continue to go to error/unknown/any state other than 'Ready' or the number of deployment pods doesn't match `desired available replicas` value, collect the logs and follow the escalation step.

---

## Automation

None

---

## Escalation Policy

* Please contact the Satellite Config squad in the [#satellite-config](https://ibm-argonauts.slack.com/archives/CPPG4CX3N) slack channel for further information
* PD escalation policy : Escalate to [Alchemy - Satellite - Config](https://ibm.pagerduty.com/escalation_policies#P42GAQ1)


---
