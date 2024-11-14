---
layout: default
description: Information about armada etcd backups
title: Armada ETCD cluster backups
service: armada-etcd
runbook-name: "Armada etcd backup information"
tags:  armada, etcd, backup, etcd-backup, armada-ballast
link: /armada/armada-etcd-backup-information.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes the purpose and location of the Armada ETCD backups.
The _armada etcd_ is the ETCD database used by the Armada microservices and holds metadata about customer clusters and workers.

This runbook is useful when gathering information for compliance data requests.

## Detailed Information

We use a self-hosted ETCD cluster managed by [armada-etcd-operator](https://github.ibm.com/alchemy-containers/armada-etcd-operator) per IKS region.
These ETCD clusters are hosted on tugboat clusters with one tugboat cluster per IKS region.

For each ETCD cluster, a backup is taken hourly using kubernetes [CronJob](https://github.ibm.com/alchemy-containers/armada-etcd-operator/blob/master/services/armada-etcd-operator/deployment.yaml#L593).
See section *Backup and Restore* of the runbook [implementation and use of etcd-operator](armada-etcd-operator-information.html) to see how backups are configured.

The automated backup job runs every hour and if fails or pauses it will automatically retry the following hour.

### Alerts

Per-cluster alerts are in place for single backup failures (low priority alert) and daily backup failures (high priority alert).
There is a separate [runbook on how to resolve backup failure alerts](armada-etcd-backup-failing.html).

- `ArmadaEtcdClusterDidNotSucceedEtcdBackup` : These alerts are sent to the [armada-etcd - low - prod](https://ibm.pagerduty.com/services/PILWFNG) pagerduty service.
- `ArmadaEtcdClusterDidNotSucceedEtcdBackupForDay` : These alerts are sent to the [armada-etcd](https://ibm.pagerduty.com/services/P02NF0Z) pagerduty service.

### Backup Locations

The backup is encrypted and is stored in an encrypted Cloud Object Storage (COS) bucket for each IKS region.
The same COS bucket is used for backups of all the customer cluster etcd databases and to find the armada etcd backups search for the prefix listed in the table below.
The COS buckets are located in the 531277 account (use an admin id to access the buckets).

| Region | COS instance name | COS bucket name | Armada etcd backup prefix |
|---|---|---|--|
| us-south | [armada-deploy-etcd-backups-prod-us-south](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3A67b729c8-60dc-4509-bec7-a8fc30ffe9e0%3A%3A?) | prod-us-south-iks-etcd-backups | 105-armada-us-south |
| us-east | [armada-deploy-etcd-backups-prod-us-east](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3A3e25bf44-bb28-4f47-8b79-78eba43c1061%3A%3A?) | prod-us-east-iks-etcd-backups | 103-armada-us-east |
| uk-south | [armada-deploy-etcd-backups-prod-eu-gb](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Ae3fac247-9112-4a21-b652-23b3f16d845b%3A%3A?) | prod-eu-gb-iks-etcd-backups | 101-armada-uk-south |
| eu-central | [armada-deploy-etcd-backups-prodeu-eu-de](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3A3ddac6d8-d18c-4d18-9f07-71963c2771ae%3A%3A?) | prod-eu-de-iks-etcd-backups | 105-armada-eu-central |
| ap-north | [armada-deploy-etcd-backups-prod-jp-tok](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Aa5556dc2-5eb7-431e-a159-3e19b3c556bc%3A%3A?) | prod-jp-tok-iks-etcd-backups | 105-armada-ap-north |
| ap-south | [armada-deploy-etcd-backups-prod-au-syd](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Afd0b3986-7702-4b6b-89c0-81fb70f3c3a3%3A%3A?) | prod-au-syd-iks-etcd-backups | 102-armada-ap-south |
| br-sao | [armada-deploy-etcd-backups-prod-br-sao](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Aea5b3575-8b59-448b-afbe-2f9cfd0d3db5%3A%3A?paneId=manage) | prod-br-sao-iks-etcd-backups | 102-armada-br-sao |
| ca-tor | [armada-deploy-etcd-backups-prod-ca-tor](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3A3fe02393-90ed-4fca-9964-16e2c37c0a93%3A%3A?paneId=manage) | prod-ca-tor-iks-etcd-backups | 102-armada-ca-tor |
| jp-osa | [armada-deploy-etcd-backups-prod-jp-osa](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Ad476707f-0d11-41bc-81fa-9354d79c2020%3A%3A?paneId=manage) | prod-jp-osa-iks-etcd-backups | 100-armada-jp-osa |
| eu-es | [armada-deploy-etcd-backups-prod-eu-es](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Aef92e3e1-6be7-49fc-b88f-b1644748d877%3A%3A?paneId=manage) | prod-eu-es-iks-etcd-backups | 100-armada-eu-es |

Below is the COS bucket for the eu-fr2 region in the 2051458 account

| Region | COS instance name | COS bucket name | Armada etcd backup prefix |
|---|---|---|--|
| eu-fr2 | [armada-deploy-etcd-backups-prod-eu-fr2](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2F540245919b2d49d9ae40250bdf6fd929%3A51a44e0e-fe00-4919-a5d6-199470cc28b1%3A%3A?) |prod-eu-fr2-iks-etcd-backups | 100-armada-eu-fr2 |

A retention policy coded in the backup script will remove old backups to reduce storage consumption.

### Backup Logs

Logs for backups are forwarded to the IBM Cloud Logs instance in each IKS region.
Logs are retained for 30 days and then archived to a separate COS bucket for later retrieval.

Access IBM Cloud Logs for each region from the [Cloud UI](https://cloud.ibm.com), under:

* `1185207 - Alchemy Production's Account` for prod instances
* `1858147 = Argo Staging` for staging instances

Hopefully direct links will be added to the [Alchemy Dashboard view](https://alchemy-dashboard.containers.cloud.ibm.com/carrier)

Example log lines:

```code
Jan 16 12:00:06 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup DO V3
Jan 16 12:00:07 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup Backups found: 2020-01-16-17-00-v3.db
Jan 16 12:00:07 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup running backup on v3 for cluster 1-armada-eu-central
Jan 16 12:00:07 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup etcdbackup.etcd.database.coreos.com "etcd-1-armada-eu-central" deleted
Jan 16 12:00:07 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup Network call kubectl delete --ignore-not-found=true -f /bin/backupv3Template.yaml was successful
Jan 16 12:00:07 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup etcdbackup.etcd.database.coreos.com/etcd-1-armada-eu-central created
Jan 16 12:00:08 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup Network call kubectl apply -f /bin/backupv3Template.yaml was successful
Jan 16 12:00:08 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup wait for v3 restore
Jan 16 12:00:08 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup Network call retrieveBackupInfo was successful
Jan 16 12:00:38 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup Network call retrieveBackupInfo was successful
Jan 16 12:00:38 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup V3 Etcdbackup completed successfully.
Jan 16 12:00:38 etcd-105-backup-eu-central-1579197600-4tcpz kubx-etcd-backup backup ran for v3
```

Logs are archived from IBM Cloud Logs into one of the regional COS buckets in the 1185207-Alchemy Production's Account: [COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fcc7530878c499d74ad77f31c918c626e%3A913538fe-270b-4d8a-92d8-f25865be11a9%3A%3A?)

#### Getting backup log for IDRs

For armada-etcd, backup logs are pushed to to `backup-logs` folder along side the `backups` folder in the etcd COS buckets.  There's a corresponding jenkins job which will allow you to retrieve those logs from COS.

Job: [retrieve armada-etcd backup logs for COS](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/dump-cos-etcd/)

Example Parameters to extra logs for all backup jobs on November, 18th 2020 (us-south production):
```
BRANCH: master
ENV_BRANCH: master
DATE: 2020-11-18
CLUSTER_ID: 105-armada-us-south
TUGBOAT: prod-dal10-carrier105
```


### Data Recovery

To restore etcd, a restore job will need to be triggered.  The restore jobs are served by the etcd-restore-operator in the tugboat cluster.  
A separate runbook explains how to [restore an Armada Etcd instance](armada-etcd-unhealthy.html#armada-etcd-restore) however it is best to involve the _Ballast_ squad if this is needed given the possible impact of having to restore the Armada ETCD database.

### Further Information

More information can be found about our [implementation and use of etcd-operator](armada-etcd-operator-information.html) and how backups are configured.

Information about locating and troubleshooting the armada etcd clusters can be found in the [armada-etcd - General Troubleshooting](armada-etcd-general-troubleshooting.html).
This document also describes the different etcd clusters running in armada.

There is a separate [runbook on how to resolve backup failure alerts](armada-etcd-backup-failing.html).
