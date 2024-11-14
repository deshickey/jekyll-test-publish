---
layout: default
description: Procedure to troubleshoot VPC Block CSI issues.
title: armada-vpc-block-csi - Procedure to troubleshoot the issues with VPC-Block-CSI
service: armada-storage
category: vpc-block-csi-driver
runbook-name: "Procedure to troubleshoot the issue with VPC-Block-CSI on IKS or ROKS clusters"
tags: alchemy, armada, kubernetes, kube, kubectl, vpc-block-csi-driver, block-storage, block
link: /armada/armada-vpc-block-csi-toubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to troubleshoot the issues with ibm-vpc-block-csi-driver.
The driver consists mainly of,
- `vpc-block-csi-controller` stateful-set.
- `vpc-block-csi-node` daemon-set.

## Example Alert(s)
None

## Must gather info and triaging issue
Any issues related with vpc data volume on IKS, ROKS cluster then customer ticket should have following details

1- PVC describe <br>
	```
	$kubectl describe pvc <PVC-NAME> -n <PVC-NAMESPACE>
	```
	
2- PV describe <br>
	```
	$kubectl describe pv <pv-name>
	```
	
3- POD describe which is causing issue because of pvc <br>
	```
	$kubectl describe pod <POD-NAME> -n <POD-NAMESPACE> 
	```
	
3- Volume details by using `ibmcloud is` command <br>
	```
	$ibmcloud is vol <VOLUME-ID>
	```
	
	**NOTE:**  `VOLUME-ID` can be found by using `kubectl describe pv <pv-name> | grep volumeId`
	
4- Volume attachment details by using following command <br>
	```
	$ibmcloud ks storage attachment ls --cluster <CLUSTER-name/id> --worker <WORKER-ID> | grep <VOLUME-ID>
	```
	
	**NOTE:**  `WORKER-ID` should be the one on which POD deployed, If volume in `attaching` or `detaching` state then customer ticket need to be transferred to `VPC-IaaS` team.
	
5- In case of mount failed or fsck issue <br>

	1- Get the cluster's node IP for which POD is deployed
	
		$kubectl describe pod <POD-NAME> -n <POD-NAMESPACE> | grep 'Node:'
	
		
	2- Get CSI block driver's node server POD by using
	
		$kubectl get pod -n kube-system -o wide | grep ibm-vpc-block-csi-node | grep <IP-GOT-AT-STEP-1>
	
	3- Exec into this driver's node server POD
		
		$kubectl exec -it <NODE-SERVER-POD> -n kube-system -c iks-vpc-block-node-driver bash
		
		Then run following commands and share the output

		$lsblk
		$ls -la /dev/disk/by-id/*
		$ls -la /dev/disk/by-uuid/*
		
		

## Investigation and Action

### General basic checks
1. **Pull the cluster configuration.**<br>
   ```
   ibmcloud ks cluster config -c <cluster_name/cluster_id>
   ```

1. **Check addon version installed.**<br>
   ```
   ibmcloud ks cluster addon ls -c <cluster_name/cluster_id> | grep vpc-block-csi-driver
   ```
   It is recommeneded to use the latest version for better support. Available versions can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-vpc_bs_changelog).

1. **Ensure all csi driver pods are in running state.**<br>
   ```
   kubectl get pods -n kube-system | grep vpc-block-csi
   ```
   1. **If any of the above pod are stuck in** **_`ImagePullBackOff`_** **state**<br>
      **Resolution:** That means the image used for pods creation is not avaialble in the registry or there may be permission issues, make sure you have access to the registry. If issue not resolved reach out to [#registry-ibm-image](https://ibm-argonauts.slack.com/archives/C543T384B) team.<br>

   1. **If any of the above pod is in** **_`CrashLoopBackOff`_** **state**<br>
      **Resolution:** This may be due to multiple reasons like insufficient memory, IKS/ROKS version incompatibility etc.. 
      - Collect logs for more details. Refer to [#Fetching logs from victory](#fetching-logs-from-victory)
      - Upgrade to the latest version of addon for a possible fix. If the issue persists, refer to the [#Escalation Policy](#escalation-policy)

   1. **If any of the node-server pod is in "_`Init:Error`_"** **state**<br>
      **Resolution:** This is because _initContainer_ is failing. This may be due to incorrect endpoint URL, api-key or resource-group id. Ask user to check the failure reason from below commands and take actions accordingly.
      - Collect logs of all the failing pods. The reason for the failure can be found here.
        ```
        kubectl logs ibm-vpc-block-csi-node-xxxx -n kube-system vpc-node-label-updater 
        ```
      **Note:** This is only in case of satellite cluster.

### Issues with volume creation
1. There are some common issues due to which volume creation may fail. Those are listed below along with debugging steps. <br>
    1. **If a PVC is given access mode other than** **_ReadWriteOnce_**<br>
        **Errors:** _`Error: failed to provision volume with StorageClass "xxx": rpc error: code = InvalidArgument desc = {RequestID: xxx , Code: VolumeCapabilitiesNotSupported, Description: Volume capabilities not supported`_ <br>
        **Resolution:** <br>
        Change accessMode, as ReadWriteOnce is the only supported access mode for VPC Block. Example can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-vpc-block#vpc-block-add).

    1. **If a PVC request has volume size which is unsupported as per IOPS tier chosen** <br>
        **Errors:** `Error: The volume profile specified in the request is not valid for the provided capacity and/or IOPS. Please check http://www.bluemix.com/help#volume_profile_capacity_iops_invalid, RC:500`_ <br>
        **Resolution:** <br>
        Choose from block storage profiles [here](https://cloud.ibm.com/docs/vpc?topic=vpc-block-storage-profiles&interface=ui).

1. If there is unknown issue of PVC not getting created, collect the relevant logs,
    - In case of VPC IKS/ROKS/satellite cluster -> Refer to [#Fetching logs from victory](#fetching-logs-from-victory) section.
   


### Issues with volume attachment/mounting
1. There are many cases due to which mount or attach issues can occur, some of the common issues along with debugging steps are listed below. <br>
    1. **If a PVC is already attached to pod in one node then it cannot be attached to a pod created in another node.** <br>
        **Error:** _`Multi-Attach error for volume "pvc-xxx" Volume is already used by pod(s) testpod-xxx`_ <br>
        **Resolution:**<br>
        Block CSI driver only supports _ReadWriteONce_ i.e it can be attached to one node. Make sure to choose the pod which you want pvc to be mounted to. <br>

    1. **FormatAndMount failing with "fsck" related errors**<br>
        **Error:** _`Failed to format '/dev/disk/by-id/virtio-xxx' and mount it at '/var/data/kubelet/plugins/kubernetes.io/csi/pv/pvc-xxx/globalmount', BackendError: 'fsck' found errors on device /dev/disk/by-id/virtio-xxx but could not correct them`_ <br>
        **Resolution:**<br>
        This is due to corrupted disks. Refer to the following script to resolve the issue -> [run-fsck-for-pvc.sh](https://github.ibm.com/alchemy-containers/armada-storage-tools-utils/blob/master/vpc/block/apply-fix/run-fsck-for-pvc.sh)<br>
        ```
        # Usage
        bash run-fsck-for-pvc.sh <pod-namespace> <pod-name> <pvc-name>

        # POD-NAME: name of the POD which is facing fsck related issues.
        # POD-NAMESPACE: Namespace of the pods.
        # PVC-NAME: name of PVC which is used in the POD and causing fsck check issue.
        ``` 
        - Note: This might lead to possible data loss, user need to take decision accordingly <br>  

1. If there is unknown issue of PVC not getting created, collect the relevant logs,
    - In case of VPC IKS/ROKS/satellite cluster -> Refer to [#Fetching logs from victory](#fetching-logs-from-victory) section.
    - Also collect the following,
        - `kubectl get pods -n kube-system -o wide  | grep csi-node`
        - The node on which the volume mount/attachment having issue please logon to that node server pod using <br>
        `kubectl exec -it ibm-vpc-block-csi-node-xxxx -n kube-system -c iks-vpc-block-node-driver bash`  
        - Run below commands and attach the logs for the same.
        ```
        lsblk 
        ls -la /dev/disk/by-id/*
        ls -la /dev/disk/by-uuid/*
        ```
        - Run ibmcloud cli command to see attachment status.
        ```
        ibmcloud ks storage attachment ls -c <cluster_name/cluster_id> -w <worker_id>
        ```

### Issues with volume expansion
1. Volume expansion is supported in version `>=4.2`. For reference see [doc](https://cloud.ibm.com/docs/containers?topic=containers-vpc-block#vpc-block-volume-expand). Some of the issues and resolutions and listed below, <br>
    1. **Offline volume expansion i.e user tries to expand a pvc which is not attached to any node.**<br>
        **Impact:** PVC not getting expanded. <br>
        **Resolution:** <br>
        This is because vpc-block driver only supports "Online Expansion", which means volume is already attached to a pod. Attach volume to a pod and then edit the pvc to see the expanded volume.

### Issues with volume deletion
1. **Deleting PVC while a application/pod is already using it.**<br>
    **Impact:** PVC will be stuck in _Terminating_ state<br>
    **Resolution:**
    Delete the pod which is attached to the impacted volume. The volume will be deleted automatically.

### Issues with volume snapshot creation
   **Symptoms**
   1. PX Backup fails to take backups when using vpc-block-csi driver related snapshot classes. VPC IaaSSnapshot service keep getting continues snapshot calls even after source volume has been deleted.
   2. VPC Block CSI driver keep re-trying snapshot creation even there is no new volumesnapshot creation request.
   3. Volumesnapshot object in false status or volumesnapshotcontent object does not have any status.</br>

  **Impact:**
   - The stale volumesnapshot and volumesnapshotcontent objects in the cluster forces kubernetes to reconcile the status and retry "CreateSnapshot" call overloading underlying infrastructure. 
   - PX-Backup fails to take backup.</br> 

  **Resolution:**
   - Cleanup Snapshot resources (Repeat these steps for all volumesnapshot and volumesnapshotcontent objects).</br>
     -  Normally volumesnapshot and volumesnapshotcontent is one to one mapping hence following steps will work
        - Trigger deletion for volumesnapshots objects which has `ReadyToUse` status as `false` `$kubectl delete volumesnapshot snapshot-csi-block-3` 
        - Remove finalizer from volumesnapshot objects `$kubectl patch volumesnapshot/snapshot-csi-block-3 --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'
        - Remove finalizer from volumesnapshotcontent objects `$kubectl patch volumesnapshotcontent/snapcontent-79c59ef6-7be6-4632-b2d5-6b4efdfc3058 --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'`</br> 
     - In case volumesnapshot object has been deleted and volumesnapshotcontent still exists in the cluster.
        - Find volumesnapshotcontent objects which does not have `ReadyToUse` status as `empty` or `false` `$ kubectl get volumesnapshotcontents | egrep -v 'true'`
        - Trigger content deletion `$kubectl delete volumesnapshotcontent snapcontent-024b37d1-7601-4b89-b8b4-044deccd53db`
        - Remove the finalizer `$kubectl patch volumesnapshotcontent/snapcontent-79c59ef6-7be6-4632-b2d5-6b4efdfc3058 --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'`
   - Edit the add-on configmap for finer control of your volume snapshots.
     - Turning off snapshots, By default, snapshot functionality is enabled when using the vpc-block-csi driver. This functionality can be turned off in the configmap `addon-vpc-block-csi-driver-configmap` in the `kube-system` namespace by changing the `IsSnapshotEnabled` to `false`. Note that with this change in the configmap, any snapshots that are created fail with the message: "CreateSnapshot functionality is disabled."

### Fetching logs from victory
**Note:** Only for VPC IKS/ROKS clusters.
1. **Fetch logs from the victory bot**<br>
   **Step 1:** From any of IBM slack workspace, add "victory" app.

   **Step 2:** Run command 
   ```
   @victory get-storage-info <cluster-id> ibm-vpc-block detailed
   ```
   This command will be responsible for fetching all the vpc-block related info like controller logs, node-server logs, pods which are using the block csi controller, pvc/pv used in the failing pods, etc.. . More info can be found [here](https://github.ibm.com/alchemy-containers/armada-storage-tools-utils/blob/master/vpc/block/README.md).

   **Sample Output**
   ```
    <User 12:14> : @victory get-storage-info <cluster-id> ibm-vpc-block detailed

    <victoryAPP 12:14> : Running the armada-storage-analysis job for cluster: <cluster-id>

    <victoryAPP 12:25> : Please review the results of running the analyze-storage Jenkins job.
   ```

   **Note:** The command takes approximately 10-20 minutes to complete and with publish the link for the jenkins job. Please share the jenkins job link provided.

### Fetching logs manually
1. If any of the driver pod is in failing state, describe for more details.
    ```
    kubectl describe pod -n kube-system <failed controller/node-server pod>
    ```
1. Collect driver logs.
    ```
    # Controller logs
    kubectl logs ibm-vpc-block-csi-controller-0 -n kube-system -c iks-vpc-block-driver

    # Node server logs
    kubectl logs ibm-vpc-block-csi-node-xxx -n kube-system -c iks-vpc-block-node-driver
    ```
1. Collect pvc/pv details. (In case of volume creation/ attachment issues)
    ```
    # Describe pvc
    kubectl describe pvc <pvc-name>

    # Describe pvc
    kubectl describe pv <pv-name>
    ```

## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
