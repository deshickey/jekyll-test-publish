---
layout: default
title: One or more Hypershift control plane deployments are down. How to resolve the alerts.
type: Alert
runbook-name: "hypershift-control-plane-deployment-alerts"
description: How to resolve HypershiftDeploymentUnavailable
service: armada-deploy
link: /hypershift/hypershift-control-plane-deployment-alerts.html
tags:  hypershift, HypershiftDeploymentUnavailable
grand_parent: Armada Runbooks
parent: Hypershift
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `HypershiftDeploymentUnavailable` | one or more Hypershift control plane deployment instance pods are down | [Actions to take](#actions-to-take) |
{:.table .table-bordered .table-striped}

These alerts fire when one or more Hypershift control plane deployment pod instances are down. The hypershift cluster deployments normally should have one pod replica running.

## Customer impact

- **Control Plane Operator**: handles lifecycle of a given cluster's control plane and rolls out the control plane based on the configuration in the HostedControlPlane object. These deployments include the standard Kubernetes control plane components, such as `kube-apiserver` and `kube-controller-manager`. If down, the hosted cluster's control plane may not be rolled out properly. 
- **Hosted Cluster Config Operator**: handles the configuration within a managed HostedCluster for core cluster resources necessary to bootstrap the cluster. If down, the hosted cluster configuration may not be created or may be incomplete.
- **Cluster Autoscaler**: autoscaler deployment set to work with the cluster-api deployment system. 
- **Machine Approver**: Handles approving node CSR renewals against cluster-api metadata to automate initial machine provisioning/bootstrapping. If down, nodes may not be able to join the hosted cluster properly. 
- **Ingress Operator**: Operator that handles ingress components. If down, external access to the service in a cluster may not work properly.
- **OLM Operator**: helps user install, update and manage the lifecycle of Kubernetes native applications and their associated services running across their Openshift Container Platform clusters. If down, Kubernetes operators may not manage their applications properly.

## Example Alert(s)

~~~~
Labels:
 - alertname = HypershiftDeploymentUnavailable
 - alert_situation = <DEPLOYMENT>_unavailable
 - service = armada-deploy
 - severity = critical
 - cluster_id = <CLUSTER-ID>
 - deployment: <DEPLOYMENT>
 - namespace = master-<CLUSTER-ID>
Annotations:
 - summary = "Hypershift control plane deployment is unavailable."
 - description = "Hypershift control plane deployment is unavailable for the cluster."
~~~~

## Automation

None

## Actions to take

1. Check to see if there is another alert that should be worked for this cluster such as a failed master patch or upgrade.
  - If that is the case, this is likely a symptom of the issue indicated by the other alert. Work that alert to attempt to get to the root cause.
2. Find and login into the tugboat of the satellite location or ROKS cluster having issues
   More info on how to do this step can be found [here](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)  
3. Identify which deployments are currently failing and check the customer impact found [above](#customer-impact).
4. Find the failing hypershift control plane deployment pods: `kubectl get po -n master-<CLUSTER-ID> |grep <DEPLOYMENT>`
```
NAME                                      READY   STATUS        RESTARTS   AGE
control-plane-operator-7b4f9f947b-kfh6c   0/1     Pending       9          19h
```
5. Describe failed pod found from above. `kubectl -n master-<CLUSTER-ID> describe pod <FAILED-POD-NAME>`
```
Name:                      control-plane-operator-7b4f9f947b-kfh6c
Namespace:                 master-topmike-1
Priority:                  100000000
Priority Class Name:       hypershift-control-plane
Node:                      10.177.180.252/10.177.180.252
Start Time:                Wed, 02 Feb 2022 18:08:55 -0500
Labels:                    app=control-plane-operator
...
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 hypershift.openshift.io/cluster=master-topmike-1:NoSchedule
                             hypershift.openshift.io/control-plane=true:NoSchedule
                             node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason        Age   From             Message
  ----     ------        ----  ----             -------
  Warning  NodeNotReady  112m  node-controller  Node is not ready
```
6. Look at the `Events` section. If a pod is down due to affinity/anti-affinity rules, then one of the cluster nodes is likely down. Replace the failing node with a healthy one and then force-delete the failed pod `kubectl delete po -n master-<CLUSTER-ID> <FAILED-POD-NAME> --force --grace-period 0` and the alert will be cleared. The process of replacing worker node can be found [here](../ibmcloud_replace_worker.html) 
7. View the logs of the failing pod. `kubectl logs -n master-<CLUSTER-ID> <FAILED-POD-NAME>`. If the cause of the failure is not clear, then please [escalate](#escalation-policy) 

## Escalation Policy

If you need assistance, please reach out to the developers using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository with all the debugging steps and information done to get to this point.
