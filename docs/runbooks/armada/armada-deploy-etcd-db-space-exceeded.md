---
layout: default
description: How to resolve cruiser etcd database space exceeded error
title: cruiser-etcd - how to resolve etcd database space exceeded error
service: armada-deploy
runbook-name: "cruiser-etcd - etcd database space exceeded"
tags: etcd, etcdserver, database, space, exceeded, no
link: /armada/armada-deploy-etcd-db-space-exceeded.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to handle cruiser etcd database space exceeded errors.

Resolving this issue is likely to require customer action. Initial investigation is required to form a plan to address the situation. The [Additional Information section](#additional-information) contains additional troubleshooting information and specific actions SRE might be requested to perform to assist in resolving the problem.

Cruiser etcd clusters have a maximum size of 4GB. The etcd database holds all secrets, configmaps, pods, and other Kubernetes objects. When the maximum size is reached, all of the etcd cluster members (i.e. all 3 pods) are put into a `NOSPACE` alarm state and the database is read-only except for delete operations. It will remain in that state until the database size is reduced, the database is defragmented, and the `NOSPACE` alarm is "disarmed". This condition can also occur if the database becomes badly fragmented and the resulting unused space is sufficient to push the size over the limit.

Additional background about etcd database size issues can be found in [this blog post](https://etcd.io/blog/2023/how_to_debug_large_db_size_issue/).

## Example Alerts

This situation is typically discovered due to customer tickets, HA master unhealthy alerts, or master operation failures.

- `kubectl` commands or Kubernetes API requests will fail with `Error from server: etcdserver: mvcc: database space exceeded`

- `etcd` pods logs will have `etcdserver: no space` errors like:

   `2021-06-28 09:49:20.464404 W | etcdserver: failed to apply request "header:<ID:15535019865963264666 username:\"etcd-client\" auth_revision:1 > txn:<compare:<target:MOD key:\"/kubernetes.io/clusterroles/openshift-cluster-monitoring-edit\" mod_revision:97580350 > success:<request_put:<key:\"/kubernetes.io/clusterroles/openshift-cluster-monitoring-edit\" value_size:790 >> failure:<request_range:<key:\"/kubernetes.io/clusterroles/openshift-cluster-monitoring-edit\" > >>" with response "" took (7.756µs) to execute, err is etcdserver: no space`

## Investigation and Action

1. Search for any existing issues in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issues }}) using the cluster ID.
    - `IF` an open issue exists
        - Copy/Paste the URL link of the customer ticket, __Failed Master Operation__ slack message, or PD alert.
        - Add any additional information to the issue that you have gathered.
        - If you are responding to a customer ticket and the armada-deploy issue contains information intended to be passed to the customer copy that information into the customer ticket.
        - Inform the armada-deploy squad. See [Escalation Policy](#escalation-policy)
        - Barring other instructions in the armada-deploy issue, you are done.

1. Get the database size and database size in use from Prometheus on the tugboat or carrier where the cruiser is running. The metric for database size is `etcd_mvcc_db_total_size_in_bytes`, and the metric for database size in use is `etcd_mvcc_db_total_size_in_use_in_bytes`. Both metrics have a `cluster_id` label that you can use to specify the cluster you're interested in, e.g.

   `etcd_mvcc_db_total_size_in_bytes{cluster_id="<clusterid>"}`

   The `etcd_mvcc_db_total_size_in_bytes` is expected to be close to `4294967296` since you are in this runbook. A given etcd pod might be a little above or below this value.

1. `IF` the `etcd_mvcc_db_total_size_in_use_in_bytes` is under 4 GB and this is the first occurrence `THEN`
    - Follow the directions to [defragment the database](#defragment-database)
    - This might fix the problem or give the customer time to fix the problem, but it is likely the problem will come back without further action.

1. Inform the armada-deploy squad. See [Escalation Policy](#escalation-policy). Record your actions in the issue that link asks you to open. You are done.

## Escalation Policy

1. Search for any existing issues in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issues }}) using the cluster ID.
     - `IF` an open issue exists
          - Use that issue as the tracking issue for interacting with the cluster owner.
          - Copy/Paste the URL link of the customer ticket, __Failed Master Operation__ slack message, or PD alert.
          - Add any additional information to the issue that you have gathered.
     - `ELSE`
          - Open a new [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) issue.
          - Fill in the information described below for the `new issue`:
               - `Title:` Owner Followup Required for cluster __cluster-id__ etcd database space exceeded
               - `Issue Details:`
               - Copy/Paste the URL link of the customer ticket, __Failed Master Operation__ slack message, or PD alert.
               - Add any additional information to the issue that you have gathered.
          - If applicable, copy/paste the issue URL link to the __Failed Master Operation__ message thread.

1. Reach out to the @deploy handle in #armada-deploy.  If immediate action is required (i.e. SEV-1 customer outage) escalate the alert directly to the squad by using the armada-deploy PD [escalation policy](https://ibm.pagerduty.com/escalation_policies#PT2ZIIQ)

## Additional Information

This section documents additional troubleshooting information for developers and canned actions that SREs might be requested to perform.

### Investigation tips

Problems we have seen fall into the following categories:

- Large number of objects. A cluster might have 10s of thousands of secrets or other objects. The [armada-deploy-get-master-info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info) output includes an `ETCD_TOP.log` **Build Artifact** which will give the count of the top 5 most-frequently-occurring resources in the database. Ultimately it is the size of the objects that is important, but we don't have an easy way to get that.

- etcd space fragmentation. Prometheus on the tugboat/carrier where the cruiser is running can be used to check the value of metrics which measure the total DB size (`etcd_mvcc_db_total_size_in_bytes`) as well as the in-use DB size (`etcd_mvcc_db_total_size_in_use_in_bytes`). If the `etcd_mvcc_db_total_size_in_bytes` is significantly larger than the `etcd_mvcc_db_total_size_in_use_in_bytes`, the etcd database file is badly fragmented. "Significantly larger" is intentionally vague. It can be as obvious as a 4 GB `etcd_mvcc_db_total_size_in_bytes` vs a 2 GB `etcd_mvcc_db_total_size_in_use_in_bytes`. It could be much closer if the etcd DB is large to begin with.

  This can be the result of things like:
    - Multiple operators managing the same resource (i.e. what is intended to be a single operator was installed in multiple namespaces). This can result in thousands of updates per minute to the same objects as each copy of the operator sees changes made by the other and tries to reconcile the state. The chane might be as basic as the operator name being recorded in the managed resources. I was able to identify this from apiserver logs. Fortunately the updates were happening often enough that even the get-master-info log snippets showed configmaps being updated multiple times in a short time.
    - An application that repeatedly writes an ever growing object. For example: If a configmap grows over time when it is updated it likely will not fit in the same space it was in. In that case etcd allocates a new file segment and the old space is available for a smaller object. If the object is frequently updated and is larger each time, etcd will keep allocating new larger segments and leave a growing collection of empty spaces.

### Resolution tips

The mechanics of resolving the issue will typically require actions by both the customer and IBM:
- The customer might be able to delete objects (i.e. secrets) with the cluster in its current state.
- SREs might need to [defragment the database](#defragment-database) and, if that doesn't free up space, [temporarily increase the size of the database](#temporarily-increase-database-size) before the customer can perform corrective actions.
- Customer perform corrective actions.
- SREs perform a final etcd defragmentation and possibly return the database to its original size.

### Defragment database

You can use the [armada-defrag-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-defrag-cluster-etcd/) job to defrag the database and disable the NOSPACE alarms.

If the job is unavailable or not working, the manual steps to perform the defrag are:
- List the etcd pods:
  `kubectl get pod -n $NAMESPACE -l etcd_cluster=etcd-$CLUSTER_ID`
- For each POD_NAME:
  - Use the [Cloud SOC Notification Bot](https://ibm-argonauts.slack.com/archives/D01FSDLS4JJ) to notify that you are about to `exec` into a pod (see the [channel](https://ibm-argonauts.slack.com/archives/C4BHPCX89) notices for more)
  - `REV=$(kubectl exec -n $NAMESPACE $POD_NAME -c etcd -- etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt endpoint status --write-out=json | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*')`
  - `kubectl exec -n $NAMESPACE $POD_NAME -c etcd -- etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt --command-timeout=50000s compact $REV`
  - `kubectl exec -n $NAMESPACE $POD_NAME -c etcd -- etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt --command-timeout=50000s defrag`
  - `kubectl exec -n $NAMESPACE $POD_NAME -c etcd -- etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt --command-timeout=50000s alarm disarm`

### Temporarily increase database size

- **NOTE:** Prior to performing this step, you should ensure that the customer is on-hand and ready to perform cleanup.
- Edit the etcdcluster: `kubectl edit etcdcluster -n $NAMESPACE etcd-$CLUSTER_ID`
- Find and edit the ETCD_QUOTA_BACKEND_BYTES. To increase the size by 1 GB (from 4 GB to 5 GB) set the size to `"5368709120"` (all env var values are strings)

    ```
    etcdEnv:
    ...
    - name: ETCD_QUOTA_BACKEND_BYTES
      value: "5368709120"
    ```

- Apply the new quota by rolling out new etcd pods. Do this by running the [armada-restart-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-restart-cluster-etcd/) Jenkins job.
- `exec` into one of the etcd pods to run the `alarm disarm` command:
  `kubectl exec -n $NAMESPACE $POD_NAME -c etcd -- etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt --command-timeout=50000s alarm disarm`

**Important** Once the problem is resolved, repeat this process to restore the original etcd size - setting it back to `"4294967296"`

### Prod trains template

Prod trains are submitted in the [#cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ) slack channel.

Below is a sample trains template you can use for a request to defrag an etcd cluster via the armada-defrag-cluster-etcd job:
```
Squad: <squad>
Title: Run armada-defrag-cluster-etcd job for cluster <cluster_id>
Environment: <cluster_region>
Details: |
 Run the armada-defrag-cluster-etcd job (https://ibm.biz/Bdf5Qv) to defragment the etcd database for cluster <cluster_id>.
 <Provide a link to pd incident here if you have one>
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 1h
Ops: true
BackoutPlan: NA
```
