---
layout: default
description: How to resolve etcd cluster related alerts
title: armada-cluster-etcd-unhealthy - How to resolve etcd cluster related alerts
service: armada-cluster-etcd-unhealthy
runbook-name: "armada-cluster-etcd-unhealthy - etcd pods down failures"
tags:  armada, etcd, etcd-recovery
link: /armada/armada-cluster-etcd-unhealthy.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
Follow the below link depending on the alertname in the firing PD alert. There are two different scenarios and broke quorum should take priority over unhealthy alerts.

| Alert_Situation | Info | Start |
|--
| `ArmadaDeployHighAvailabilityMasterClusterEtcdClusterUnhealthy` (and other alerts where etcd cluster has 2 of 3 pods) | Customer etcd cluster moved down to 2/3 available pods. | [Etcd cluster unhealthy](#etcd-cluster-unhealthy) |
| `ArmadaDeployHighAvailabilityMasterClusterEtcdClusterBrokeQuorum` (and other alerts where etcd cluster has 1 or fewer pods) | Customer etcd cluster moved down to 1 or less available pods. Quorum broke. Manual recovery of cluster needed. | [Etcd cluster broke quorum](#etcd-cluster-broke-quorum) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = master_cluster_etcd_cluster_unhealthy
 - alert_situation = master_cluster_etcd_cluster_unhealthy
 - service = armada-deploy
 - severity = critical
 - cluster_id = xxxxxxxxxxx
Annotations:
 - namespace = kubx-etcd-0X
~~~~

## Actions to take

## Before starting
At any time during your investigation, feel free to run an etcd backup using the [armada-backup-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-backup-cluster-etcd/) job.  This job can be run for any cluster at any time.  If the cluster is healthy enough, a backup will be taken.  It is generally a good idea to run it before attempting any potentially harmful operation against a cluster.

If there is outage on base infrastructure (network outage, mass nodes not ready), fix the base infrastructure issues firstly.

If there are multiple etcd clusters (e.g. more than 10) in trouble, it might be caused by unstable networking.

Run [analyze-bad-node-from-pagerduty](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/analyze-bad-node-from-pagerduty/) to analyze which worker nodes the issues come from

- For each node associated with not ready etcd pods, check its status. If the node is not ready, try hard reboot (don't drain or cordon) first. Reason to not drain: The node still has a chance to run again and all the individual etcd pod data is persisted on the node. If the node comes back healthy after the reboot, then the etcd pods will pick right back up with no quorum loss. If nodes cannot be recovered or etcd clusters are not recovered after reboot, try reload (drain the workload off before reload)
- If issues distribute across multiple nodes, and all nodes are ready, consider it's vyatta issue.
- Get the worker node ip from the output of [analyze-bad-node-from-pagerduty](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/analyze-bad-node-from-pagerduty/). Check gateway of a specific worker using netmax bot in slack.
  ```
  @nextmax 10.171.78.122
  prod-dal10-carrier2-worker-1030 (Virtual Server) - Dallas 10:02 - Acct531277
  Public: 169.46.30.142 169.46.30.128/26 (Prod/Carrier2) (1527 (fcr02a.dal10))
  Private: 10.171.78.122 10.171.78.64/26 (Prod/Carrier2) (879 (bcr02a.dal10))
  OS: UBUNTU_18_64
  Tags: imageid:5959464
  Gateway: prod-dal10-firewall-vyattaha0
  ```
    <span style="color:red">**!!! Get approval from Ralph before reboot Vyattas !!!**</span>

    Check in slack channel #netint-status-updates to ensure the specific vyatta ha pair is not rebooting. Reboot the vyatta using following command in slack channel #sre-cfs. If the bot can not work, use [Das-reboot jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Network-Intelligence/job/Network-Intelligence/job/Das-reboot/)
  ```
  @netmax reboot prod-dal10-firewall-vyattaha0 via ssh
  ```
- If reboot vyatta can not help, consider it's [CoreDNS problem](#coredns-problem).

If alerts are still unresolved, follow below steps to investigate each cluster one by one.

### Etcd cluster Broke Quorum

Check the [before-starting](#before-starting) section for possible problems to resolve before proceeding.

This is a very critical issue to try and solve as soon as possible. While quorum is lost, customers are not able to read/write to etcd.

To resolve this issue, follow the below steps to restore an ETCD cluster.

#### Restoring an ETCD Cluster
When an etcd cluster has lost quorum (<= 1 members remain), the only resolution is to restore the cluster from a backup.  The steps below will walk you through the restore process:

1. Run the [armada-restore-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-restore-cluster-etcd) jenkins job.
    - Clusters that still have 1 or more members, but all are in some unhealthy state, will require dev squad authorization before a restore can be performed.  See the [Restore Authorization](#restore-authorization) section for next steps.
    - Clusters that have exactly 1 healthy member remaining will first automatically have a backup taken from that member before the subsequent restore is performed.  Any unhealthy members will be automatically removed during the restore process.  No dev squad authorization is required in this case.
    - Clusters with 0 remaining members (in any state) will be restored from an earlier backup.  No dev squad authorization is required in this case.
    - Restores of production clusters require a valid PROD_TRAIN_REQUEST_ID ([sample template](#prod-trains-template-for-etcd-restore))
2. Wait for the job to complete.
    - Job progress can be monitored by following the corresponding "ETCD Recovery" thread for this particular cluster in the [#cruiser-etcd-alerts](https://ibm-argonauts.slack.com/archives/C039AGJJ7AT) Slack channel.  This Slack thread will be automatically generated shortly after the job is started.
3. Process job results.
    - Review the ETCD recovery Slack thread and/or jenkins job.  Confirm all operations completed successfully.
    - If you see any failures, please ping the @deploy squad in the Slack thread for assistance and/or [escalate](#escalation-policy).
    - If all sub-operations passed, there is nothing more to do here.  You are done.

### Etcd cluster unhealthy

This means a customer etcd cluster moved down to 2/3 available pods. Their cluster is fully operational and there are no issues, but if a second pod were to fail it would cause downtime and quorum loss for the customer, which we want to avoid.  Most of the time, this situation is automatically resolved by the etcd-operator.  But in some cases, it may require some manual intervention.

To resolve this issue, follow the below steps for Cluster reconciliation problems.

### Cluster reconciliation problems

When the cluster has quorum but is considered unhealthy (i.e. 2/3 pods are healthy), the leader `etcd-operator` pod should be automatically cleaning up dead members and creating the third member.  If an error occurred that switched the cluster into a `Failed` state, the `etcd-operator` should automatically recover from this as well, patching the etcd cluster back into `Running` and start reconciling it again.  However, if the `etcd-operator` pod is not creating the third member, one of these situations may have occurred:
- The etcd cluster anti-affinity rules cannot be met, due to a lack of available worker nodes for it to be scheduled upon. Correct worker nodes as needed.  Reference: [before-starting](#before-starting)
- The etcd operator has lost management of the cluster and cannot reobtain it.
- The etcd operator was not able to successfully patch the `Failed` cluster back to `Running`.
- Any other unexpected error has caused to operator to stop reconciling the etcd cluster or perform any of its recovery operations automatically.

#### Steps:

1. Try to run the recovery jenkins job to see if it can get the etcd cluster operational again.
    - Go to the jenkins job [armada-restore-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-restore-cluster-etcd/build)
    - Enter the CLUSTER_ID from the alert, then run the job (build).
    - Restores of production clusters require a valid PROD_TRAIN_REQUEST_ID ([sample template](#prod-trains-template-for-etcd-restore))

2. Wait for the job to complete. Once complete, look at the job status to verify that a restore was successful.
    - If the job finished with a successful/green status, the restore was successful and no follow-up actions are required. You are done with this section.
    - If the job finished with a warning/yellow status, the restore was successful; however, follow-up actions are required to ensure full recovery of the cluster. The job should have automatically opened an issue against [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issues }}) with the required information. Verify that the issue was created and leave a note in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel notifying of the need for additional actions. Once the Slack message has been sent, you are done with this section.
    - If the job finished with an error/red status, it was unable to perform any actions to restore the etcd cluster. This does not necessarily imply that the job had an error; this status will appear when the job detects that the etcd cluster is not in a state which can be automatically recovered via backups and restores. Continue following the runbook steps below.

3. Further manual steps to watch the recovery or for data capture if later escalation is needed follow.
4. Get the `etcdcluster` name. There should only be one present and it should look like `etcd-$CLUSTER_ID`.  This variable will be needed in future steps:
   ``` shell
   ETCD_CLUSTER_NAME=$(kubectl get -n $NAMESPACE etcdcluster -l clusterID=$CLUSTER_ID --no-headers | awk '{print $1}')
   echo $ETCD_CLUSTER_NAME
   ```

5. Verify the `etcdcluster` phase.  It should be 'Running'.  If not, continue with further steps below to discover another repair step, or for debug data if escalation is needed later.
   ``` shell
   kubectl get -n $NAMESPACE etcdcluster $ETCD_CLUSTER_NAME -o jsonpath='{.status.phase}'; echo
   ```

6. Ensure the `etcd-operator` starts to repair the etcd cluster; this may take several minutes. Watch this by monitoring all the etcd pods for the cluster.  Use the command:
   ``` shell
   kubectl get po -n $NAMESPACE -l etcd_cluster=etcd-$CLUSTER_ID -o wide
   ```

7. If you now have 3 running etcd cluster pods, all with 2/2 containers running, the etcd cluster should now be healthy.  No further steps should be needed.

8. If after a few minutes, no new etcd pods have been provisioned, then check the leader `etcd-operator` pod.
    1. Get the leader's pod name (under the HOLDER column):
       ``` shell
       kubectl get leases etcd-operator -n $NAMESPACE
       ```
    2. Ensure the leader pod is found and is in `Running` state.
       ``` shell
       kubectl get pod <lease holder pod> -n $NAMESPACE
       ```
    4. If the leader pod was not found, follow the steps described in [extra operator pods](#extra-operator-pods) to confirm and cleanup that errant lease holder pod directly on the worker.  After doing this, the other `etcd-operator` pods should re-vote for a new lease holder.
        1. This can be monitored by watching the leases:
           ``` shell
           kubectl get leases etcd-operator -n $NAMESPACE -w
           ```
        2. Once a new leader is elected, confirm the leader pod is in `Running` state and then proceed to the next steps for watching the logs.
        3. If after a few minutes, a new lease holder `etcd-operator` pod has not taken effect, you need to trigger Kubernetes to restart the `etcd-operator` pods. Follow [these steps to restart the etcd operators](#restarting-the-etcd-operator-pods).  Then repeat the earlier steps to obtain the **NEW** `etcd-operator` lease holder pod.

    4. If the leader pod is found but not in `Running` state, and you have not yet attempted a full restart of the etcd operator pods, then follow [these steps to restart the etcd operators](#restarting-the-etcd-operator-pods).

    5. If the leader pod is found in `Running` state, check the leader pod's logs (increase the number of lines on `tail` as needed):
       ``` shell
       kubectl logs -n $NAMESPACE <lease holder pod> -c etcd-operator | grep $ETCD_CLUSTER_NAME | tail -n 40
       ```
        - You should see multiple sets of messages that begin `Start reconciling` and `Finish reconciling`, each containing the etcd cluster name.
        - In between the message pairs, you may see messages for removal of dead members (if there were any), and subsequent messages for adding the third member. Later, you may see reconciling of the cluster skipped because the third new member is still in Pending state while it loads.
        - If the last reference is old (hours or days), or if there are new `ignore failed cluster` messages in the log, you need to trigger Kubernetes to restart the `etcd-operator` pods.  Follow [these steps to restart the etcd operators](#restarting-the-etcd-operator-pods).  Then repeat the earlier steps to obtain the **NEW** `etcd-operator` lease holder pod so that you can monitor the logs for this etcd cluster.

9. If you now have 3 running etcd cluster pods, all with 2/2 containers running, the etcd cluster should now be healthy.  No further steps should be needed.

10. If the problem isn't resolved and you haven't yet checked for extra `etcd-operator` pods, check that now as described in [extra operator pods](#extra-operator-pods).  If you haven't restarted the `etcd-operator` pods yet, then follow [these steps to restart the etcd operators](#restarting-the-etcd-operator-pods). Then perform/repeat the earlier steps described above to obtain the **NEW** `etcd-operator` lease holder pod and monitor its logs.

11. If the missing etcd cluster member pod does not come up after you executed the above steps, or if you are unable to ever get the `etcd-operator` pods to run as described, then either return to the section that brought you here for further diagnosis or if none, check **[escalate](#escalation-policy)**.


### Coredns problem

1. Use the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) to bring up Prometheus for the carrier or tugboat
   1. Enter this query
   `sum (container_memory_working_set_bytes{image!="",pod=~"coredns-.*"}) by (pod,kubernetes_io_hostname)`
   1. Selet the `Graph` option
   1. Change the time range from `1h` to `1d`

1. If the graph shows that memory use is steadily increasing the CoreDNS pods need to be restarted. To restart the pods:
   1. login to the carrier or tugboat (login to carrier worker, then use `invoke-tugboat`) and run
   `kubectl -n kube-system rollout restart deployment/coredns`
   1. Wait for the new coredns pods to roll out
   `kubectl -n kube-system rollout status deployment/coredns --watch`

1. If the etcd cluster remains troubled, return to the step that brought you here
   _Additional actions may be required after fixing coredns_

If Prometheus is not available, you can query logDNA to determine if any carrier or tugboat coredns pods have experienced
a panic recently. The "panic" message described here will occur once and `coredns` will
not function properly until the pods have been restarted.
- Use the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) to bring up logDNA for the carrier or tugboat.
They share a region wide logDNA.
- Enter this query: `app:coredns panic`
- If there are recent entries expand the log entry by clicking on the arrow to the left of the log entry. You will need to move the cursor to the left of the line to see this.
- The expanded section includes the host name. If the host corresponds to the carrier or tugboat you are working on restart `coredns`.
  - To restart the pods, login to the carrier or tugboat (login to carrier worker, then use `invoke-tugboat`) and run<br/>
  `kubectl -n kube-system rollout restart deployment/coredns`
  - Wait for the new coredns pods to roll out.<br/>
  `kubectl -n kube-system rollout status deployment/coredns --watch`
- If the etcd cluster remains troubled, return to the step that brought you here. Additional actions may be required after fixing coredns.


### Restarting the etcd operator pods

1. Delete the pods to restart them.  **Do not "force delete" a `Terminating` operator pod**, as this can leave a possibly broken operator running that is no longer known to Kubernetes):
   ``` shell
   kubectl -n $NAMESPACE delete pods -l name=etcd-operator
   ```
2. Allow a few minutes for the operators to elect a leader and for that leader pod to initialize.  It will start managing all of the etcd clusters known to its namespace.
3. Return to the steps/section that brought you here.

### RESTORE TIMEOUT

If you see following error when restore etcd, it means that the restore job timed out
```
ERROR: Restore Job never completed. Displaying logs above.
```

You might see the new provisioned etcd pods in `Init:Error` or `Init:CrashLoopBackOff` state.
```
kubx-etcd-06   etcd-bmf36rod0kd8fhkrjqe0-fk4sxhbkbt                              0/2     Init:Error         6          5m59s   172.16.152.17    10.74.66.66      <none>           <none>
```
The `fetch-backup` container in the pod is in State `Waiting`, Reason `CrashLoopBackOff`. Nothing in the logs of container fetch-backup
```
kubect -n kubx-etcd-06 logs etcd-bmf36rod0kd8fhkrjqe0-k6pwdlj9db -c fetch-backup
```

Restart the etcd-restore-operator pods.
```
kubectl -n $NAMESPACE delete pods -l name=etcd-restore-operator
```

**Do not "force delete" a Terminating operator pod.** This can leave a possibly broken operator running but no longer known to Kubernetes.

If restore still times out after deleting the operator pods, check for extra `etcd-restore-operator` pods as described in [extra operator pods](#extra-operator-pods).

If the issue still persist, check [escalation policy](#escalation-policy).

### Restore Authorization
Dev squad authorization is required in certain etcd restore scenarios due to potential data-loss that can occur.

_** The following steps should only be followed when ALL remaining etcd member pods (1 or more) are in an unhealthy state.**_

1. [Escalate](#escalation-policy) the alert immediately to get the dev squad involved.

2. Attempt to retrieve a backup from remaining pods. **Skip this step if there are 0 remaining member pods**

Even though this may fail due to all remaining members being unhealthy, we can first try taking a backup using the [armada-backup-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-backup-cluster-etcd/) job.  If this job succeeds, continue to step 3.

If the standard backup job fails, we can try to retrieve and upload the etcd data file directly from a member pod using the [armada-deploy-breakglass-etcd-backup](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-breakglass-etcd-backup/) job. This job is only for use in rare circumstances where there is still at least one etcd pod remaining, but the etcd cluster is so unhealthy that the normal backup processes can no longer function. Prior to running the job, request authorization from the dev squad via an [allow-list entry](https://github.ibm.com/alchemy-containers/pd-tools/blob/master/allowlist-jenkins/armada-deploy-breakglass-etcd-backup.txt). A prod train will also be required to run the job.

Whether you were able to successfully take a backup or not, an etcd restore is still required.  Proceed to the next step.

3. Request authorization from the dev squad to perform the restore via an allow-list [entry](https://github.ibm.com/alchemy-containers/pd-tools/blob/master/allowlist-jenkins/armada-restore-cluster-etcd.txt). The development squad is ultimately responsible for ensuring that we have exhausted all available options for obtaining the latest backup from any remaining unhealthy pods prior to taking actions that may cause customer data loss.

4. Once you have the necessary approval, head back to the [Restoring an ETCD cluster](#restoring-an-etcd-cluster) section to continue with the restore.

### Manual Restore

**STOP and read the following instruction warnings and instructions before proceeding**

**This information is primarily for use in pre-prod, or only in special cases of prod under advisement from the Development team.**

`IF` you have gotten to this point, be aware that using this process can cause data loss and is only to be used when the Jenkins job is not working.

This is a manual process, so please open a:
- prod train in [#cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ)
- [armada-deploy](https://github.ibm.com/alchemy-containers/armada-deploy/issues/new) tracking issue. *Record all steps taken in the tracking issue.*

- Scale down the control plane
  - This can be done via the [armada-master-scale-down](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-master-scale-down/) Jenkins job
  - If Jenkins is not functioning, and the job is not an option, you can also trigger a scale-down operation via an armada-data command like:
    ```
    armada-data set Master -field ScaleDownConfigurationRequested -value true -pathvar MasterID="$MASTER_ID"
    ```

- Once the scale-down of the control plane has completed, use the following template and instructions to create a custom `EtcdRestore` resource.

```yaml
apiVersion: "etcd.database.coreos.com/v1beta2"
kind: "EtcdRestore"
metadata:
  name: etcd-$CLUSTER_ID
  namespace: $NAMESPACE
  labels:
    prodTrainId: "$PROD_TRAIN_ID"
    deployIssueNum: "$DEPLOY_ISSUE_NUM"
spec:
  etcdCluster:
    name: etcd-$CLUSTER_ID
  backupStorageType: S3
  s3:
    path: $ETCD_BACKUP_BUCKET/$CLUSTER_ID/backups/$BACKUP_FILE
    awsSecret: cos-credentials
    endpoint: $ETCD_BACKUPS_ENDPOINT
```

  - Replace the following vars in the template:
    - **CLUSTER_ID**
      - Cluster ID of the cluster you want to restore.
    - **NAMESPACE**
      - The namespace the cluster is in.
      - `kubectl get etcdcluster --all-namespaces | grep $CLUSTER_ID`
    - **ETCD_BACKUP_BUCKET** & **ETCD_BACKUPS_ENDPOINT**
      - Located in the `cos-credentials` secret in any kubx-etcd-/master- namespace:
      - `kubectl get secret -n kubx-etcd-01 cos-credentials -o jsonpath='{.data.config}' | base64 -d`
    - **BACKUP_FILE**
      - The specific backup file you want to restore to. (ex. 2021-11-10-23-11-v3.db)
      - IMPORTANT! Always choose the latest backup unless you are specifically targeting an older one.
      - Options for finding a backup file:
        - Look for `Backups found` in the logs of the most recent backup pod for the cluster
          - `kubectl logs -n $NAMESPACE "kubx-etcd-backup-$CLUSTER_ID" | grep "Backups found" -A 5`
        - Query AWS directly
          - `aws --endpoint "$ETCD_BACKUPS_ENDPOINT" s3 ls "$ETCD_BACKUP_BUCKET/$CLUSTER_ID/backups/"`
  - Example Templated Resource:

```yaml
apiVersion: "etcd.database.coreos.com/v1beta2"
kind: "EtcdRestore"
metadata:
  name: etcd-1ea05e42269f417b95f471e973b96291
  namespace: kubx-etcd-15
  labels:
    prodTrainId: "CHG1234567"
    deployIssueNum: "8765"
spec:
  etcdCluster:
    name: etcd-1ea05e42269f417b95f471e973b96291
  backupStorageType: S3
  s3:
    path: prod-us-south-iks-etcd-backups/1ea05e42269f417b95f471e973b96291/backups/2019-03-15-17-18-v3.db
    awsSecret: cos-credentials
    endpoint: https://s3.us-south.objectstorage.softlayer.net
```

- Apply the EtcdRestore resource to the carrier/tugboat
  - `kubectl apply -f $RESTORE_RESOURCE_FILE`

- Wait for the etcd restore to complete. The restore is complete when the cluster has 3 `Running` etcd pods with all containers ready.

- Scale the control plane backup via a master refresh operation
  - This can be done via the [armada-master-refresh](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-master-refresh/) Jenkins job
  - If Jenkins is not functioning, and the job is not an option, you can also trigger a refresh operation via an armada-data command like:
    ```
    armada-data set Master -field RefreshConfigurationRequested -value true -pathvar MasterID="$MASTER_ID"
    ```

- One the scale-up of the control plane is complete, delete the calico-typha and calico-kube-controllers pods in the cluster's data plane. The `calico_namespace` will be `kube-system` for IKS clusters and `calico-system` for ROKS clusters:
```
kubx-kubectl ${CLUSTER_ID} delete pod -l 'k8s-app in (calico-typha, calico-kube-controllers)' -n $calico_namespace
```

### Extra Operator Pods

These directions pertain to any of the 3 types of etcd operators:  `etcd-operator`, `etcd-restore-operator`, or `etcd-backup-operator`.

There might be an old operator pod still running that is not visible to Kubernetes (i.e., `kubectl get pods <operator pod> -n $NAMESPACE` indicates the pod is `not found`). We have seen instances of workers that failed a reload or reboot
where someone force deleted the pod.

You can use this Prometheus query to see if there are extra containers running.

`sum (container_memory_working_set_bytes{image!="",namespace="NAMESPACE",pod=~"PREFIX-.*"}) by (pod,kubernetes_io_hostname)`

Replace `NAMESPACE` with the namespace for the etcd cluster, e.g. `kubx-etcd-10`, and replace `PREFIX` with the
operator deployment name, e.g. `etcd-operator` or `etcd-restore-operator`.

If the Prometheus query shows a pod not listed by `kubectl` see if you can login to the worker (`kubernetes_io_hostname`) and run
these commands to delete the pod:
- `crictl pods | etcd-restore-operator` (or `etcd-operator`)
- The first column is the POD_ID.
- `crictl stopp POD_ID`
- `crictl rmp POD_ID`

If you cannot login to the worker or those commands fail, ensure the worker is shutdown or reloaded.

### Restart all etcd member pods
There exists a jenkins job, [armada-restart-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-restart-cluster-etcd/).
This job will safely restart the existing etcd members as a rolling restart.  Additionally, it takes a fresh backup prior to initiating the restart request.  However, it currently can only be used on an existing cluster that is in an healthy condition.
Production cluster restarts must provide a train ID.  See ([sample template](#prod-trains-template-to-restart-etcd-members) for requesting a train approval.

Some intended usecases for this are:

1. Forcing pods to get scheduled on a new "home" host node.  For example, part of the process for setting up dedicated workers is a restart of etcd and the master to move pods to their new homes.
2. The etcd member is appearing otherwise healthy to the etcd-operator, but logs indicate that there might be communication issues between the members, preventing reads or writes from occurring or responding within reasonable time.  The underlying causes of this could be community etcd open source defects, or other unknown conditions causing it.  In this case, restarting the etcd in this safe manner may resolve the issue (clearing it's local memory, db state, etc.).
3. An incident once occurred where deployments were having troubles rolling out to a carrier.
4. Large, internal customers sometimes have hit performance issues with their production clusters that were resolved by restarts of etcd.

#### Prod trains template to restart etcd members:
Prod trains are submitted in the [#cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ) slack channel.

Below is a sample trains template you can use for a request restarting an etcd cluster via the [armada-restart-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-restart-cluster-etcd/) job:

```
Squad: <squad>
Title: Run armada-restart-cluster-etcd job for cluster <cluster_id>
Environment: <cluster_region>
Details: |
  Run the armada-restart-cluster-etcd job (https://ibm.biz/BdPdpN) to restart the etcd cluster in a safe manner for cluster <cluster_id>.
  <Provide a link to pd incident here if you have one>
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 1h
Ops: true
BackoutPlan: NA
```

### Prod trains template for etcd restore

Prod trains are submitted in the [#cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ) slack channel.

```
Squad: <squad>
Title: Run armada-restore-cluster-etcd job for cluster <cluster_id>
Environment: <cluster_region>
Details: |
  Run armada-restore-cluster-etcd job (https://ibm.biz/BdfADL) to restore etcd for cluster <cluster_id>.
  <Provide a link to pd incident here if you have one>
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 1h
Ops: true
BackoutPlan: NA
```

## Rarely seen situations

This section is intended primarily for *developer* use. It documents rarely seen scenarios and tips for diagnosing or resolving the problem.

### Cannot add 3rd member to cluster

Sometimes an etcd cluster has 2 apparently healthy pods, the `armada-restore-cluster-etcd` job finds nothing to fix, but the etcd-operator is not able to add or remove a member during reconciliation.

#### etcd-operator leader logs:

Search for references to the cluster (`bmpi52ms078i9sm0sni0` below) in the etcd-operator leader pod logs.

```
$ kubectl -n kubx-etcd-16 logs pod/etcd-operator-5b69dcdb6d-6f6fz -c etcd-operator | grep bmpi52ms078i9sm0sni0 | tail -10

time="2022-02-10T19:51:14Z" level=info msg="setupServices start" cluster-name=etcd-bmpi52ms078i9sm0sni0 cluster-namespace=kubx-etcd-16 pkg=cluster
time="2022-02-10T19:51:15Z" level=info msg="service etcd-bmpi52ms078i9sm0sni0-client already exists; patching instead\n"
time="2022-02-10T19:51:15Z" level=info msg="service etcd-bmpi52ms078i9sm0sni0 already exists; patching instead\n"
time="2022-02-10T19:51:15Z" level=info msg="setupServices end" cluster-name=etcd-bmpi52ms078i9sm0sni0 cluster-namespace=kubx-etcd-16 pkg=cluster
time="2022-02-10T19:51:15Z" level=info msg="Start reconciling" cluster-name=etcd-bmpi52ms078i9sm0sni0 cluster-namespace=kubx-etcd-16 pkg=cluster
time="2022-02-10T19:51:15Z" level=info msg="running members: etcd-bmpi52ms078i9sm0sni0-r22sx4vqd9,etcd-bmpi52ms078i9sm0sni0-vqwrb8qnn4" cluster-name=etcd-bmpi52ms078i9sm0sni0 cluster-namespace=kubx-etcd-16 pkg=cluster
time="2022-02-10T19:51:15Z" level=info msg="cluster membership: etcd-bmpi52ms078i9sm0sni0-vqwrb8qnn4,etcd-bmpi52ms078i9sm0sni0-r22sx4vqd9" cluster-name=etcd-bmpi52ms078i9sm0sni0 cluster-namespace=kubx-etcd-16 pkg=cluster
{"level":"warn","ts":"2022-02-10T19:51:15.094Z","caller":"clientv3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"endpoint://client-265692d3-84a8-471b-acfd-5a715abdc5c5/etcd-bmpi52ms078i9sm0sni0-r22sx4vqd9.etcd-bmpi52ms078i9sm0sni0.kubx-etcd-16.svc:2379","attempt":0,"error":"rpc error: code = Unavailable desc = etcdserver: unhealthy cluster"}
time="2022-02-10T19:51:15Z" level=info msg="Finish reconciling" cluster-name=etcd-bmpi52ms078i9sm0sni0 cluster-namespace=kubx-etcd-16 pkg=cluster
time="2022-02-10T19:51:15Z" level=error msg="failed to reconcile: fail to add new member (etcd-bmpi52ms078i9sm0sni0-rbnc6k7m6b): etcdserver: unhealthy cluster" cluster-name=etcd-bmpi52ms078i9sm0sni0 cluster-namespace=kubx-etcd-16 pkg=cluster
```

We can see that the operator is attempting to add a new member (or remove a dead member).

#### etcd pod logs

Looking at the etcd pod logs you find one pod logging `etcdserver: not healthy for reconfigure, rejecting member add`
errors:
```
$ kubectl -n kubx-etcd-16 logs pod/etcd-bmpi52ms078i9sm0sni0-r22sx4vqd9 -c etcd |tail -5
2022-02-10 20:00:07.701123 W | etcdserver: not healthy for reconfigure, rejecting member add {ID:f1ee7723484e15d3 RaftAttributes:{PeerURLs:[https://etcd-bmpi52ms078i9sm0sni0-q2pvcn46xh.etcd-bmpi52ms078i9sm0sni0.kubx-etcd-16.svc:2380] IsLearner:false} Attributes:{Name: ClientURLs:[]}}
2022-02-10 20:00:15.855515 W | etcdserver: not healthy for reconfigure, rejecting member add {ID:c46acc270eebb4b8 RaftAttributes:{PeerURLs:[https://etcd-bmpi52ms078i9sm0sni0-v7nssmxxgg.etcd-bmpi52ms078i9sm0sni0.kubx-etcd-16.svc:2380] IsLearner:false} Attributes:{Name: ClientURLs:[]}}
2022-02-10 20:00:24.042182 W | etcdserver: not healthy for reconfigure, rejecting member add {ID:c4263cda05046172 RaftAttributes:{PeerURLs:[https://etcd-bmpi52ms078i9sm0sni0-kpxg4nwfzh.etcd-bmpi52ms078i9sm0sni0.kubx-etcd-16.svc:2380] IsLearner:false} Attributes:{Name: ClientURLs:[]}}
2022-02-10 20:00:40.344422 W | etcdserver: not healthy for reconfigure, rejecting member add {ID:5b3baff00e48d9ef RaftAttributes:{PeerURLs:[https://etcd-bmpi52ms078i9sm0sni0-9lkx7dmwht.etcd-bmpi52ms078i9sm0sni0.kubx-etcd-16.svc:2380] IsLearner:false} Attributes:{Name: ClientURLs:[]}}
2022-02-10 20:00:48.531653 W | etcdserver: not healthy for reconfigure, rejecting member add {ID:2e55be0d78284d18 RaftAttributes:{PeerURLs:[https://etcd-bmpi52ms078i9sm0sni0-bsflhs7fmk.etcd-bmpi52ms078i9sm0sni0.kubx-etcd-16.svc:2380] IsLearner:false} Attributes:{Name: ClientURLs:[]}}
```

There are several variations on this, with messages including the text:
- `rejecting member add`
- `rejecting member remove request`
- `rejecting member promote request`

#### What's happening

Etcd is configured to use the `-strict-reconfig-check` option to protect itself from
operations that will break quorum (for example, adding a 4th member to a 3 member cluster
when only 2 members are healthy, or removing one of the healthy members).
While the operator will not intentionally make such changes, it is possible that any
given member is in a state where it believes quorum loss will occur; that member will
reject the change.

We have seen that restarting the etcd member has corrected the problem.

#### How to fix it

We can restart the `etcd` container without deleting the pod:

In the sample logs this pod was logging the `not healthy for reconfigure, rejecting member add` errors:
- `NAMESPACE=kubx-etcd-16`
- `POD=etcd-bmpi52ms078i9sm0sni0-r22sx4vqd9`

Exec into that pod and kill the main process with a SIGTERM (15):
- `kubectl -n $NAMESPACE exec $POD -c etcd -- sh -ec "kill -15 1"`

Notes:

1. The `kill` normally produces no output.
1. Yes, we need automation for this.
1. If you are in this condition when all members report they are `Running` and `Ready`, consider trying the Jenkins job to restart it: [Restart etcd cluster](#restart-all-etcd-member-pods).


Kubelet should restart the container in place, keeping the local database file and preserving quorum.
Once the pod has restarted it should accept the next `member add` or `remove` request from the etcd-operator and
the etcd-operator will be able to create and bring up the 3rd pod.

## Escalation Policy
For assistance during normal business hours, you can contact the dev squad via the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel.

If unable to obtain help via the slack channel, use the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy to notify the current on-call squad member. NOTE: **DO NOT PAGE DEVELOPMENT FOR SATELLITE MASTER OPERATION OR CONTROL PLANE STABILITY PROBLEMS DUE TO UNHEALTHY SATELLITE LOCATIONS** as it is up to the customer to resolve the issue.

_If the etcd cluster has not lost quorum (i.e. still has 2 out of 3 members running), *DO NOT ESCALATE* as the cluster is still functional at this time. Open an issue against [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) so the dev squad can investigate later._
