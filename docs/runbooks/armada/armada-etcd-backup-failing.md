---
layout: default
description: How to resolve etcd cluster backup related alerts
title: armada-etcd-backup-failing - How to resolve etcd cluster backup related alerts
service: armada-etcd-backup-failing
runbook-name: "armada-etcd-backup-failing"
tags:  armada, etcd, etcd-recovery, backup, etcd-backup
link: /armada/armada-etcd-backup-failing.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `ArmadaEtcdClusterDidNotSucceedEtcdBackupForHour`| The hourly etcd backup job failed to complete for the armada etcd instance. | [Failed etcd backup](#failed-etcd-backup) |
| `ArmadaEtcdClusterBackupSnapshotFailed`| The etcd backup operator failed to take a db snapshot from the etcd cluster. | [Failed etcd backup](#failed-etcd-backup) |
| `ArmadaEtcdClusterBackupCOSWriteFailed`| The etcd backup operator failed to write the db snapshot to COS. | [Failed etcd backup](#failed-etcd-backup) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~text
Labels:
 - alertname = ArmadaEtcdClusterDidNotSucceedEtcdBackupForHour
 - alert_key = armada-etcd/armada_etcd_cluster_did_not_succeed_etcd_backup_for_hour
 - alert_situation = armada_etcd_cluster_did_not_succeed_etcd_backup_for_hour
 - carrier_name = prod-syd01-carrier102
 - carrier_type = hub-tugboat-etcd
 - crn_cname = bluemix
 - crn_ctype = public
 - crn_region = au-syd
 - crn_servicename = containers-kubernetes
 - crn_version = v1
 - namespace = armada
 - service = armada-etcd
 - severity = critical
 - tip_customer_impacting = false
 ~~~~

Armada etcd backups should be taken every hour per region.  The last 24 hours of backups should be available as well as weekly backup for 6 months.  You can see the current backup list using the [Get ETCD Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-info/) with `SKIP_BACKUPS` unchecked.
Search the logs for section "Armada Etcd Backups"

## Actions to take

### Failed Etcd Backup

This means that the etcd backup job for the armada etcd cluster did not complete.

The basic backup flow:

- The backup cron job is started and creates a backup CR (kube kind: etcdbackup)
- The backup operator will see the new backup CR and start a backup
- The backup operator will call the etcd client API to take a snapshot of the db.
- The backup operator will call the COS API to upload the db.
- The backup opeartor has 3 pods, one is the leader trying to do the backups.

To debug:

1. Bring up the kubernetes pod backup dashboard

    - For backup cron job info:

      - Bring up the Grafana kuberentes pod dashboard and use pod regex: `.*[0-9]+-backup.*`
      - Example: https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd01/carrier102/grafana/d/pods/pods?orgId=1&var-datasource=prometheus&var-namespace=armada&var-pod=.%2Abackup.%2A&from=now-6h&to=now

    - For backup operator info:
      - Bring up the Grafana deployment dashboard and select deployment `etcd-backup-operator`
      - Example: https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd01/carrier102/grafana/d/deployment/deployment?orgId=1&var-datasource=prometheus&var-namespace=armada&var-deployment=etcd-backup-operator

1. Find and login into the tugboat hub (carrier100+) in the region.

    - More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)

1. Check the etcd backup operator logs for more information:

    - `kubectl logs -n armada -l name=etcd-backup-operator --tail=-1`
    - Search for the following successes:
       - `Successfully uploaded snapshot`
       - Example: `Successfully uploaded snapshot to prod-au-syd-iks-etcd-backups/102-armada-ap-south/backups/2024-02-20-15-00-v3.db`
         - The timestamp on the db file will be the last successful backup.  In some cases the backup operator was successful in the last hour, but the cron job pod fails to log the success because of issues with Prometheous.  Can sleep the alert until the next hour and check the backup operator logs again for the next successful backup.
    - Search for the following errors:
       - `failed to receive snapshot`
       - `failed to write snapshot`
       - `failed to close snapshot file`
    - The log message for the errors above will contain the detailed error from the ETCD client or
      COS API call.
    - If the error looks transient, delete the etcd backup operator pod that reported the error. A different etcd backup operator pod will become the leader and try the backup again. Moving the etcd backup operator leader to another zone can work around zone specific COS issues.
       - Example transient errors are timeouts and network failures.
    - if the error is not transient, please [escalate immediately](#escalation-policy)

1. Check the etcd backup cron job for more information:

    - Cronjob: `kubectl -n armada get cronjob | grep -E 'etcd-[0-9]+-backup'`
    - Pod: `kubectl -n armada get pod | grep -E 'etcd-[0-9]+-backup'`
    - Logs: `kubectl -n armada logs <pod-name> --tail=-1`
    - Search for the following successes:
       - `wait for v3 backup`
       - `V3 Etcdbackup completed successfully`

    The also might be errors in the backup pod logs that need to be resolved.  The cron job has a back off limit of 3.

### Additional Information

More information can be found about our implementation and use of etcd-operator [here](armada-etcd-operator-information.html)

The [Get ETCD Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-info/) can be run to see more detailed information about the etcd cluster.

## Escalation Policy

First open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.
