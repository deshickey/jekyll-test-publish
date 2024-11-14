---
layout: default
description: How to resolve the armada etcd cluster related alerts
title: armada-etcd-unhealthy - How to resolve the armada etcd cluster related alerts
service: armada-etcd-unhealthy
runbook-name: "armada-etcd-unhealthy - armada etcd pods down failures"
tags:  armada, etcd, etcd-recovery, armada-etcd, armada-ballast
link: /armada/armada-etcd-unhealthy.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `ArmadaEtcdClusterBrokeQuorum`| Armada etcd cluster moved down to less than 3 available pods for the last 10 minutes. Quorum broke. Manual recovery of cluster needed. | [Etcd cluster broke quorum](#etcd-cluster-broke-quorum) |
| `ArmadaEtcdClusterUnhealthy`| Armada etcd cluster moved down to less than 4 available pods for the last 10 minutes. | [Etcd cluster unhealthy](#etcd-cluster-unhealthy) |
| `ArmadaEtcdClusterUnhealthyPods`| Armada etcd cluster moved down to less than 5 available pods for the last 130 minutes. | [Etcd cluster unhealthy](#etcd-cluster-unhealthy) |
| `ArmadaEtcdClusterUnhealthyOperator`| Armada etcd cluster operator moved down to less than 2 available pods for the last 30 minutes. | [Etcd cluster unhealthy operator](#etcd-cluster-unhealthy-operator) |
| `ArmadaEtcdClusterUnhealthyOperatorBackup`| Armada etcd cluster backup operator moved down to less than 2 available pods for the last 30 minutes. | [Etcd cluster unhealthy operator](#etcd-cluster-unhealthy-operator) |
| `ArmadaEtcdClusterUnhealthyOperatorRestore`| Armada etcd cluster restore operator moved down to less than 2 available pods for the last 30 minutes. | [Etcd cluster unhealthy operator](#etcd-cluster-unhealthy-operator) |
| `ArmadaEtcdDegradedPerformanceForMicroservice`| Microservice etcd latency has exceeded the 50ms threshold for 5m. | [Troubleshooting high etcd latency](#troubleshooting-high-etcd-latency) |
| `WarningArmadaETCDLowGRPCSentRateAlert`| The rate of armada-etcd client grpc bytes sent are less than 50 bytes for the past 15 min. | [Etcd low client rate](#actions-to-take) |
| `WarningArmadaETCDLowGRPCReceivedRateAlert`| The rate of armada-etcd client grpc bytes received are less than 50 bytes for the past 15 min. | [Etcd high client rate](#actions-to-take) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~text
Labels:
 - alertname = armada-etcd/armada_etcd_cluster_unhealthy
 - alert_situation = armada_etcd_cluster_unhealthy
 - service = armada-etcd
 - severity = critical
Annotations:
 - namespace = armada
~~~~

## Actions to take

## Disable Auto Reloader Jobs

1. Search [containers-jenkins](https://alchemy-containers-jenkins.swg-devops.com) for the Cluster Name ie: prod-us-south-carrier105
1. You should see two jobs. [Example](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/tugboat/job/worker-reload/search/?q=prod-us-south-carrier105&Jenkins-Crumb=107c4945faae759b32932ad5bc54800b97dd2f4b68f1f52e4811054c67cf34b0)

~~~~text
Containers-Runtime tugboat automated-worker-reloads worker-automated-reloader-prod-us-south-carrier105
Containers-Runtime tugboat automated-worker-replaces worker-automated-replaces-prod-us-south-carrier105
~~~~

1. Make sure both are disabled (only one should ever be enabled at a time)
1. Disable [update-jenkins-jobs](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/update-jenkins-jobs/), so that any merges to master do not re enable the job you disabled

See [here](./tugboat-autoreloader.html#disable-all-tugboat-automation) for how to disable all tugboat automation

## Before starting

<span style="color:red">Look at the alertname and follow the table of contents above.</span> There are two different scenarios and broke quorum should take priority over unhealthy alerts.

### Etcd cluster Broke Quorum

1. If quorum is broke, we will need to raise a CIE. Follow these steps to resolve. Outage information:
    * [SRE CIE Responsibilities](../sre_cie_responsibilities.html)

    ~~~text
    Customers may experience problems in $REGION_NAME. Unable to perform cluster and worker operations/creations as well as unable to use the API to perform actions.
    ~~~

1. Confirm the CIE ([SRE - raising a CIE](../sre_raising_cie.html)) with the following text in the notice:

    ~~~text
    TITLE:   Delay with IBM Kubernetes cluster provisioning and worker node operations

    SERVICES/COMPONENTS AFFECTED:
    - IBM Kubernetes Service

    IMPACT:
    IBM Cloud Kubernetes Service and RedHat Openshift Kubernetes Services
    - Using classic infrastructure
    - Using VPC on Classic infrastructure
    - Using VPC on Gen2 infrastructure
    - Users may see delays in provisioning workers for new or existing clusters
    - Users may see failures in provisioning portable subnets for new or existing clusters
    - Users may see delays in provisioning persistent volume claims for existing clusters
    - Users may see delays in reloading, rebooting or deleting existing workers of clusters
    - Kubernetes/Openshift workloads otherwise using previously provisioned infrastructure resources are unaffected

    STATUS:
    - 202X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
    ~~~

1. Lets go to prometheus and find all the running etcd member pods for the etcdcluster, normally 5.
    * More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)
    * Run the following query:

       ~~~~text
       count(kube_pod_status_phase{namespace=~"armada",phase="Running",pod=~"etcd-\\d+-armada.*"} > 0)
       ~~~~

    * **At least 1 running pod**, a backup should have been taken automatically by the etcd operator to prevent any major data loss.
    Run the GEI job to see the list of backups and confirm a backup was taken.
       * [GEI](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-info/)
       * Select the `ARMADA_ETCD_REGION`
       * Uncheck the `Skip Backups`
       * Review logs for list of backups, if nothing recent is returned, we can try to run a backup manually, go to [Armada Etcd backup restore](#armada-etcd-backup-restore) below
    * **No running pods** no backup can be taken [escalate](#escalation-policy)

### Etcd cluster unhealthy

This means the armada etcd cluster is down to less than 5 pods. The cluster is fully operational and there are no issues, but if more pods were to fail it would cause downtime and quorum loss, which we want to avoid.

1. Find and login to the microservice/etcd tugboat (name will be in pd title) that is having issues.
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
1. Find all the etcd pods for the cluster
`kubectl -n armada get pod -l app=etcd -o wide`
e.g.

   ~~~text
   kubectl get po -n armada | grep -P "etcd-\d+-armada"
   etcd-1-armada-dev-south-5w7tx4hgnv                                2/2       Running            0          2d
   etcd-1-armada-dev-south-gp98tzm27z                                2/2       Running            0          2d
   etcd-1-armada-dev-south-mv8tjz57n9                                2/2       Running            0          2d
   etcd-1-armada-dev-south-wrsxwgbsph                                2/2       Running            0          2d
   etcd-1-armada-dev-south-qxn9zzg5ds                                2/2       Error              0          2d
   ~~~

1. If there are not 5 pods running, check etcd-operator logs

    `kubectl -n armada logs -l name=etcd-operator`

    * If logs show `fail to handle event: ignore failed cluster`, you need to [patch the etcdcluster CR](#armada-etcd-patch-failed-cluster).
    * If logs shows `lost quorum` a restore is required
        * If there is 1 or more pod in Running state go to [Armada Etcd backup restore](#armada-etcd-backup-restore) below
        * If there are no pods in Running state [escalate](#escalation-policy) below

1. If there are pods that are not in running state, try to delete it and see if it comes back up.
1. If the pods do not come up [escalate](#escalation-policy]

    * If there is 1 or more pod in Running state go to [Armada Etcd backup restore](#armada-etcd-backup-restore) below. **If the cluster has not broken quorum, you will need to specify FORCE_ALLOW_BREAK_QUORUM=true.** FORCE_ALLOW_BREAK_QUORUM is required to break quorum. This won't restore from a recent backup, but will take an on-demand backup since there are pods running.
    * If there are no pods in Running state [escalate](#escalation-policy)

### Etcd cluster unhealthy operator

This means one of the three armada etcd cluster operators is down to less than 2 pods. The cluster state is unknown from the opearator point of view. The etcd cluster operators usually have 3 pods running with one of them being elected the leader.  To check the state of the etcd cluster, see [Etcd cluster unhealthy](#etcd-cluster-unhealthy).

1. Find and login to the carrier master having issues.
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
1. Find all the operator pods for the cluster
    * etcd main operator:
        `kubectl get pods -n armada -l name=etcd-operator`
    * etcd backup operator
        `kubectl get pods -n armada -l name=etcd-backup-operator`
    * etcd restore operator:
        `kubectl get pods -n armada -l name=etcd-restore-operator`

e.g.

   ~~~text
   kubectl get pods -n armada -l name=etcd-operator
   NAME                             READY   STATUS    RESTARTS   AGE
etcd-operator-85fd6b9885-4tsgq   1/1     Running   0          11m
etcd-operator-85fd6b9885-dzdlc   1/1     Running   0          10m
etcd-operator-85fd6b9885-p4xp6   0/1     Error   0          9m35s
   ~~~

1. If there are pods that are not in running state, try to delete it and see if it comes back up.
1. Check the node the pods are running on for issues.
1. If the pods do not come up [escalate](#escalation-policy]

### Armada Etcd Patch Failed Cluster

The cluster has been unhealthy long enough that the `etcdcluster` Custom Resource as been marked as `Failed`.  That means `etcd-operator` will no longer try to recover pods in the `etcdcluster`.  To try to recover the cluster, we need to patch the CR so it can be recovered by `etcd-operator`.

In order to patch and recover the cluster, follow [these steps](armada-etcd-operator-stopped.html#actions-to-take).

### Armada Etcd BACKUP RESTORE

**WARNING: DO NOT ISSUE A BACKUP AND RESTORE WITHOUT COMPLETING THE ABOVE DEBUGGING STEPS FIRST AND CONFIRMING WITH THE DEV SQUAD A BACKUP AND RESTORE IS NEEDED**

Armada Etcd **backup** and **restore** will first take a backup of the current state of etcdcluster. This will prevent data loss.
This script can be run against multiple clusters at the same time

1. **IF THIS ACTION IS TAKEN, WE WILL NEED A CIE** so make sure this is what needs to be done. If unsure [escalate](#escalation-policy)
1. Confirm the CIE ([SRE - raising a CIE](../sre_raising_cie.html)) with the following text in the notice:

    ~~~text
    TITLE:   Delay with IBM Kubernetes cluster provisioning and worker node operations

    SERVICES/COMPONENTS AFFECTED:
    - IBM Kubernetes Service

    IMPACT:
    - IBM Kubernetes Service, using classic infrastructure
    - IBM Kubernetes Service, using VPC on Classic infrastructure
    - IBM Kubernetes Service, using VPC on Gen2 infrastructure
    - Users may see delays in provisioning workers for new or existing clusters
    - Users may see failures in provisioning portable subnets for new or existing clusters
    - Users may see delays in provisioning persistent volume claims for existing clusters
    - Users may see delays in reloading, rebooting or deleting existing workers of clusters
    - Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

    STATUS:
    - 202X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
    ~~~

1. Go to this [Restore Armada ETCD jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/restore-armada-etcd/)

    * **BRANCH** is default of `master`
    * **FORCE_ALLOW_DATA_LOSS** is default of `False`
    * **BACKUP_DATE** is default of empty, will use the most recent one
    * **ARMADA_ETCD_REGION** is set to tugboat
    * **FORCE_ALLOW_BREAK_QUORUM** is changed to `True`

    * Wait for the job to complete. Once complete, look at the console output and verify that a restore was successful.
        * Near the bottom of the log should look like `V3 restore completed successfully`
        * If no success, [escalate](#escalation-policy)

### Armada Etcd RESTORE

This section has been removed. We should NOT run a restore against the armada etcd without having captured a backup first. If the backup fails or is unable to run please [escalate](#escalation-policy) to allow the dev team to debug.

If it is determined that a restore must be run, please obtain approval from Ralph Bateman before executing such a step. The control plane losing data requires a significant amount of clean up and will cause issues for our customers beyond just being unable to manage their clusters.

### Armada Etcd GRPC Alert

Steps to take for the `WarningArmadaEtcdClientGRPCSentRate` and `WarningArmadaEtcdClientGRPCReceivedRate`alert:
- Review the  `Carrier Etcd` Grafana dashboard for the armada etcd tugboat in the region. Check for server side errors using the `GRPC` views. The [armada-etcd-info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-info/) can help with determining pod and node health status.
- Check the logs for the pod with low GRPC rates. Look for networking related log entries in the pod with low grpc. The pod can be restarted and or moved to a different node to see if that resolves the alert.

### Troubleshooting High Etcd Latency

There are two main causes for high etcd latency. The first being that there is an anomaly which is causing unusually high response times. This can be diagnosed by looking at the microservice etcd response times in Grafana, which can be accessed [here](https://alchemy-dashboard.containers.cloud.ibm.com/). After selecting the Grafana instance in the appropriate region, in the left panel, select Dashboards -> Manage -> microservice-etcd-metrics. The second cause is that response times are generally higher than expected due to etcd interactions within the microservice code.

In the case where there is an anomoly, investigation and troubleshooting may be required to find the cause. It may or may not be connected to high latency and request load for etcd in general, in which case the Grafana graphs would show an overall spike in all services. If the spike is solely found for the alerted microservice, then further investigation should be performed by the relevant squad until the specific cause is found.

In the case where there is no anomaly and response times are simply higher than the threshold expects, the first thing to do is ensure that the microservice in question is using the latest release version of the following packages:  `armada-model`, `armada-data`, `armada-soyuz`, and `go-etcd-rules`. Afterwards, check against the [Etcd Best Practices](https://ibm.ent.box.com/notes/947902519534?s=cwjw3njh9yuc9bge0o5hg0h2fazsyieh/) document and ensure that no obvious suboptimal etcd interactions exist. If this has all been done and the response times are still triggering the alert, create a custom alert with a higher threshold for the affected microservice and create an exemption for the microservice in the general alert. Note that this should only be done as a last resort, and that improving etcd usage should be the desired action.

### Additional Information

More information can be found about our implementation and use of etcd-operator [here](armada-etcd-operator-information.html)

The [Get ETCD Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-info/) can be run to see more detailed information about the etcd cluster.

## Escalation Policy

First open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.
