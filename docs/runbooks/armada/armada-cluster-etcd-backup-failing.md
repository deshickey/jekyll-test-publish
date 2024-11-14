---
layout: default
description: How to resolve etcd cluster backup related alerts
title: armada-cluster-etcd-backup-failing - How to resolve etcd cluster backup related alerts
service: armada-cluster-etcd-backup-failing
runbook-name: "armada-cluster-etcd-backup-failing"
tags:  armada, etcd, etcd-recovery, backup, etcd-backup
link: /armada/armada-cluster-etcd-backup-failing.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
| Alert_Situation | Info | Start |
|--
| `ArmadaDeployHighAvailabilityMasterClusterEtcdBackupFailing`| There has not been a successful etcd backup taken for this cluster in the last 3 hours. | [Failed etcd backup](#failed-etcd-backup) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = master_cluster_etcd_backup_failing
 - alert_situation = master_cluster_etcd_backup_failing
 - service = armada-deploy
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = xxxxxxxxxxx
Annotations:
 - summary = "There has not been a successful etcd backup taken for this cluster in the last 3 hours."
 - description = "There has not been a successful etcd backup taken for this cluster in the last 3 hours."
~~~~

## Actions to take

### Failed Etcd Backup

This alert firing means that there has not been a successful etcd backup taken for this cluster in the last 3 hours.  Investigation should be performed immediately to determine a root cause and resolve the issue as soon as possible.

Troubleshooting steps:

- Verify that the alert is accurately reporting that there are no backups in the last 3 hours.
  - Run the [armada-deploy-get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job against the cluster with the `ETCD_BACKUP_INFO` option selected.  When the job completes, view the job artifact `ETCD_BACKUP_INFO.log`.  This will show all the backups we currently have for the specified cluster.
    - _Note: The filenames correspond to the date/time in which the backup was taken. All times are in UTC._
  - `IF` there is a backup file from within the last 3 hours...
  - `THEN` Notify the dev squad via the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel.  Let them help confirm your findings before resolving the PD alert.
  - `ELSE` Continue on to the next step...
- [Access the carrier/tugboat](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert) housing the cluster.
- Use one or more of the following methods to debug the issue...
  - Determine the `ETCD_NAMESPACE` where the etcd resources for this cluster live
    - For ROKS clusters, `ETCD_NAMESPACE=master-$CLUSTER_ID`
    - For IKS clusters, `ETCD_NAMESPACE=$(kubectl get -A etcdcluster -l clusterID=$CLUSTER_ID -o jsonpath='{.items[0].metadata.namespace}')`
  - Confirm that the most recent backup jobs for the cluster are failing (`0/1` Completions).
    - `kubectl get jobs -n $ETCD_NAMESPACE | grep kubx-etcd-backup-$CLUSTER_ID`, example:
      ~~~
      master-cidj31f105ae9n5slhig   kubx-etcd-backup-cidj31f105ae9n5slhig-28132772       0/1           172m       172m
      master-cidj31f105ae9n5slhig   kubx-etcd-backup-cidj31f105ae9n5slhig-28132832       0/1           112m       112m
      master-cidj31f105ae9n5slhig   kubx-etcd-backup-cidj31f105ae9n5slhig-28132892       0/1           52m        52m
      ~~~
  - Look to see if there are currently multiple backup job pods **for the same cluster** currently `Running`
    - `kubectl get pods -n $ETCD_NAMESPACE -o jsonpath='{range .items[?(@.status.phase=="Running")]}{.metadata.name}{"\n"}{end}' | grep kubx-etcd-backup-$CLUSTER_ID`
    - If there is more than one backup job pod simultaneously running **for the same cluster**, this may be caused by a [known issue](https://github.ibm.com/alchemy-containers/armada-deploy/issues/11691) where a temporary slowdown in writing the backups to COS can spiral into a larger problem that might persist even after the network recovers. Follow the steps below to attempt to resolve.
      - Notify the dev squad via the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel, then proceed with the following steps.
      - Get the logs from the `etcd-backup-operator` leader pod and save them for later analysis by the dev team: `kubectl logs -n $ETCD_NAMESPACE -c etcd-backup-operator $(kubectl get lease etcd-backup-operator -n $ETCD_NAMESPACE -o jsonpath='{.spec.holderIdentity}')`
      - Get a list of all backup jobs for this cluster that do not have a successful completion: `kubectl get jobs -n $ETCD_NAMESPACE | grep kubx-etcd-backup-$CLUSTER_ID | grep '0/1'`
      - Delete every job in that list **except for the most recently-created job**
      - Delete the `etcd-backup-operator` leader pod: `kubectl delete pod -n $ETCD_NAMESPACE $(kubectl get lease etcd-backup-operator -n $ETCD_NAMESPACE -o jsonpath='{.spec.holderIdentity}')`
      - Determine which etcd member is the leader; you can use a Prometheus query for this: `count by(kubernetes_pod_name)(etcd_server_is_leader{cluster_id="<cluster id>"} == 1)`
      - Inspect the logs for the lead etcd member. If you see messages like `dropped internal Raft message since sending buffer is full (overloaded network)`, this indicates problems in that pod. Run the [armada-restart-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-restart-cluster-etcd) Jenkins job (prod train required) to restart the cluster's etcd pods. **NOTE** that you will need to set the `SKIP_BACKUP` parameter to `true`
      - Once the rollout of the new etcd pods is complete (if needed), kick off a backup of the cluster via the [armada-backup-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-backup-cluster-etcd/) Jenkins job. If the job completes successfully, the PD alert should auto-resolve within a few minutes.
  - Look for any leftover backup pods that are in a failed/error state.
    - `kubectl get pods -n $ETCD_NAMESPACE | grep kubx-etcd-backup-$CLUSTER_ID`
      - _Note: There may not be any pods leftover due to automatic cleanup mechanisms in place._
    - View the pod logs to see if there is any indication as to why the backup failed.
  - Look at the `EtcdBackup` custom resources.
    - `kubectl get EtcdBackup -n $ETCD_NAMESPACE -l name=etcd-$CLUSTER_ID`
      - _Note: There may not be any custom resources created yet due to the nature of the this particular failure._
    - Describe the custom resources; look for anything useful related to backup failures.
  - View the logs from the `etcd-backup-operator` pod that processed the backup request.
    - The etcd-backup-operator component is in charge of snapshotting the etcd database and uploading that snapshot to COS.  It runs in a leader/follower format (1 leader, 2 followers), where only the leader pod performs any actual work. Thus, any useful logs would be found in the leader pod. Logs from the current leader can be obtained via: `kubectl logs -n $ETCD_NAMESPACE -c etcd-backup-operator $(kubectl get lease etcd-backup-operator -n $ETCD_NAMESPACE -o jsonpath='{.spec.holderIdentity}')`
- Verify the issue is resolved and cluster backups are working again via one or more of the following methods:
  - Run the [armada-backup-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-backup-cluster-etcd/) job at anytime to force a backup to occur.  A passing job run means the backup was successful.
  - Wait for an automatic hourly backup attempt to occur again and check the kube job status for successful completion.
  - Run the [armada-deploy-get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job with the `ETCD_BACKUP_INFO` option selected one more time to ensure you see a more recent backup file there.
  - Ensure the PD alert has auto-resolved.

### Additional Information
More information on the how the customer cluster etcd backup process works can be found [here](https://github.ibm.com/alchemy-containers/etcd-operator/wiki/Cruiser-Etcd#backups).

More information can be found about our implementation and use of etcd-operator [here](armada-etcd-operator-information.html)

## Escalation Policy
If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository with all the debugging steps and information done to get to this point.
