---
layout: default
title: Silence Recurring Owner Related Cruiser Failures
type: Informational
runbook-name: Silence Recurring Owner Related Cruiser Failures
description: PD Alerts can continue to trigger for broken cruisers due to owner related issues. Once the owner is notified of the issue they must fix, we can silence future PD Alerts for the cluster until the owner has addressed the issue.
service: Conductors
link: /armada-cruiser-silence-recurring-owner-issues.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

When we encounter a cluster where the owner has broken something and they must fix it, PD alerts may continuously (re)trigger that their cluster is broken. We want to silence these alerts until the owner is able to fix their cluster.


## Detailed Information

Some clusters encounter failures or trigger PD alerts due to owner related issues. Common instances of this is KMS issues, bad custom webhooks, etc. When a cluster runs into issues due to owner related content, we notify the owner to fix the issue and return their cluster back to a functional state.

However, in some of these cases, PD alerts will continue to (re)trigger for these clusters until the owner has fixed their issue. In order to prevent PD alerts from continuing to trigger for a cluster that has been identified as broken and dependent on the owner to fix, we add a Kuberntes label to their cluster. This label will prevent a majority of future PD alerts for their cluster from triggering.

Preventing the retriggering of alerts for these broken clusters will alleviate the issues we constantly see and prevent the need to 'hand-off' a series of clusters and alerts that are known to continue triggering until the owner addresses the issue (especially in the case where the owner is not responsive or away). Once the owner is able to fix their cluster, we can remove the label and allow PD alerts to trigger as normal once again.


## Proceedure

Steps provided to [silence cluster](#silence-cluster-pd-alerts) that is broken or continuously alerting or to [unsilence cluster](#unsilence-cluster-pd-alerts) once it has been fixed.


### Silence Cluster PD Alerts

Follow these steps to silence cluster(s) PD alerts.

1. Collect the cluster Id(s) of the cluster(s) you wish to silence PD alerts for.

1. Check for any open issues for the clusters in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issues }}) (search for the cluster Ids).

1. Open any new issues for each cluster (if there is a large quantity of clusters, involve the armada-runtime squads first) in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}). **Make sure to enter the cluster Id and the reason why the cluster is being silenced.**

1. Once you have found or opened a GHE issue, use the [armada-deploy-blocklist-master Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-blocklist-master/) to have the automation blocklist and silence the cluster (blocklisting prevents the cluster from showing up in the `armada-deploy` squads daily scans as well).
    - Enter the cluster Ids, separated by a comma if providing more than one, and a reason the cluster is being silenced. Commonly, providing the `armada-deploy` issue number for the reason, e.g., `armada-deploy-issue-1`.
    **Keep in mind the [restrictions for Kubernetes labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set).**
    - By default, cluster etcd alerts are NOT silenced.  If you wish to also silence the etcd alerts for the specified clusters, select the `SILENCE_ETCD_ALERTS` build option.

1. Monitor the job until it completes. Bear in mind it may take a while to complete as retries on the carriers/tugboats are built in, in case there are issues reaching the carrier/tugboat.
    - `IF successful`, you are done. The `armada-deploy` squad will find the GHE issue with details you provided.
    - `ELSE` Post a callout for the `deploy` squad in the [[{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel linking the failed Jenkins job and/or `armada-deploy` issue and that you were trying to silence the retriggering cluster. They can investigate the failure further during normal business hours.


### Unsilence Cluster PD Alerts

Follow these steps to unsilence cluster(s) PD alerts.

1. Collect the cluster Id(s) of the cluster(s) you wish to unsilence PD alerts for.

1. Check for open issues for the clusters in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issues }}), you can post the results in those issues and likely close the issue if the cluster has been fixed, the cluster monitoring re-enabled (unsilenced) and the issue is complete.

1. Use the [armada-deploy-blocklist-master Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-blocklist-master/) to have the automation unblocklist and unsilence the cluster(s) (unblocklisting allows the cluster(s) to show up in `armada-deploy` squads daily scans, if necessary).
    - Provide the cluster Ids, separated by a comma if providing more than one, and check the `REMOVE_CLUSTER_IDS` checkbox (you can leave `SILENCE_REASON` empty in this case).

1. Monitor the job until it completes. Bear in mind it may take a while to complete as retries on the carriers/tugboats are built in, in case there are issues reaching the carrier/tugboat.
    - `IF successful`, you are done. Close the related GHE issue(s) in `armada-deploy`. The cluster will once again be monitored by our PD alerts when the cluster becomes unhealthy.
    - `ELSE` Post a callout for the `deploy` squad in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel, linking the failed Jenkins job and/or `armada-deploy` issue and that you were trying to unsilence the now fixed/healthy cluster. They can investigate the faliure further during normal business hours.


### Collect Current Silenced Clusters

You can collect the current set of silenced clusters as well. This process is run every Monday, and should be reviewed each week. To run manually, simply:

1. Run the [armada-deploy-blocklist-master Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-blocklist-master/) without providing any parameters (leave all value empty, unchecked).

1. Monitor the job, it will take a significantly long time to complete, as it checks every carrier and tugboat in production.

1. The job may fail, if it cannot reach one of the carriers or tugboats, which is not uncommon. With so many carriers and tugboats, having a successful check on all is difficult. However, the collected set of silenced clusters is archived to the job in the `master_results.yaml` file.
    - The `master_results.yaml` file contains a list of blocklisted cluster Ids and the silenced cluster deployments (multiple may appear since tugboats may be checked more than once and/or ROKS v4 has ~10 deployments per cluster control plane).
    - The `failed_master_attempts.txt` will mention any failures, typically a list of carriers/tugboats that it was unable to check.

1. If the job is successful, it will likely trigger the [armada-deploy-silence-issue Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-silence-issue/), which is responsible for attempting to find an open GHE issue for each unique cluster Id in `armada-deploy`.
    - You can monitor that build and results as well, as it is used to verify every silenced cluster has the proper documentation and issue tracking and we are not simply silencing clusters without reason.
