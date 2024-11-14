---
layout: default
description: Procedure to troubleshoot VPC File CSI issues.
title: armada-vpc-file-csi - Procedure to troubleshoot the issues with VPC-FILE-CSI
service: armada-storage
category: vpc-file-csi-driver
runbook-name: "Procedure to troubleshoot the issue with addon VPC-File-CSI on IKS or ROKS clusters"
tags: alchemy, armada, kubernetes, kube, kubectl, vpc-file-csi-driver, addon-vpc-file-csi-driver, file-storage, file, shares, mount-targets
link: /armada/armada-vpc-file-csi-toubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to troubleshoot the issues with ibm-vpc-file-csi-driver.
The driver consists mainly of,
- `vpc-file-csi-controller` controller deployment pods.
- `vpc-file-csi-node` node server daemonset pods.

**Important info**
This runbook is created keeping _addon-vpc-file-driver 2.0_ in mind.

## Example Alerts
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
	$ibmcloud is share <SHARE-ID>
    $ibmcloud is share-mount-targets <SHARE-ID>
	$ibmcloud is share-mount-target <SHARE-ID> <SHARE-MOUNT-TARGET-ID>
	```
	
	**NOTE:**  `SHARE-ID and SHARE-MOUNT-TARGET-ID` can be found by using `kubectl describe pv <pv-name> | grep volumeId`. This is in format SHARE-ID#SHARE-MOUNT-TARGET-ID

4- Get details of the recent events that happened in file csi driver
    ```
    $kubectl describe cm file-csi-driver-status -n kube-system
    ```

## Investigation and Action

### General basic checks
1. **Pull the cluster configuration.**<br>
   ```
   ibmcloud ks cluster config -c <cluster_name/cluster_id>
   ```

1. **Check addon version installed.**<br>
   ```
   ibmcloud ks cluster addon ls -c <cluster_name/cluster_id> | grep vpc-file-csi-driver
   ```
   It is recommeneded to use the latest version for better support. Available versions can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-versions-vpc-file-addon).

1. **Ensure all csi driver pods are in running state.**<br>
   ```
   kubectl get pods -n kube-system | grep vpc-file-csi
   ```
   1. **If any of the above pod are stuck in** **_`ImagePullBackOff`_** **state**<br>
      **Resolution:** That means the image used for pods creation is not avaialble in the registry or there may be permission issues. For such issues please refer to [#Escalation Policy](#escalation-policy) team.<br>

   1. **If any of the above pod is in** **_`CrashLoopBackOff`_** **state**<br>
      **Resolution:** This may be due to unforseen reasons...
      - Describe that pod using command `kubectl describe pod ibm-vpc-file-csi-xxx-xxx -n kube-system`.
      - Look for the container which is continuously restarting.
      - Collect logs for more details. Refer to [#Fetching logs from victory](#fetching-logs-from-victory)
      - Get into the failing "pod folder" which is failing and the container logs can be found over there. Open the crashing container logs for a possible reason of failure.
      - Upgrade to the latest version of addon for a possible fix. If the issue persists, refer to the [#Escalation Policy](#escalation-policy)


### Issues with volume creation
1. There are few common usage issues due to which volume creation may fail. Those are listed below along with debugging steps. <br>
Describe the PVC and look for events. <br>
    1. **If a PVC is given access mode other than** **_ReadWriteOnce_ or _ReadWriteMany_**<br>
        **Errors:** _`Error: failed to provision volume with StorageClass "xxx": rpc error: code = InvalidArgument desc = {RequestID: xxx , Code: VolumeCapabilitiesNotSupported, Description: Volume capabilities not supported`_ <br>
        **Resolution:** <br>
        Change accessMode, as ReadWriteOnce and ReadWriteMany are the only supported access mode for VPC FILE. Example can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-vpc-file#vpc-file-add).<br>
    1. **If a PVC request has volume size which is unsupported as per IOPS range chosen**<br>
        **Errors:** `Error: The volume profile specified in the request is not valid for the provided capacity and/or IOPS. Please check http://www.bluemix.com/help#share_profile_capacity_iops_invalid, RC:500`_ <br>
        **Resolution:** <br>
        Choose from file storage profiles [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui).<br>
    1. **If a PVC creation fails with below error** <br>
        **Errors:** `vpc.file.csi.ibm.io_ibm-vpc-file-csi-controller-xxx failed to provision volume with StorageClass "xxx": rpc error: code = FailedPrecondition desc = {RequestID: xxxx , Code: SubnetFindFailed, Description: A subnet with the specified zone 'xxx' and available cluster subnet list 'xxx,xxx,xxx' could not be found., BackendError: {Code:SubnetFindFailed, Type:RetrivalFailed, Description:A subnet with the specified zone 'xxx' and available cluster subnet list 'xxx,xxx,xxx' could not be found., BackendError:no subnet found, RC:404}, Action: Please check if the property 'vpc_subnet_ids' contains valid subnetIds. Please check 'kubectl get configmap ibm-cloud-provider-data -n kube-system -o yaml'.Please check 'BackendError' tag for more details}`_ <br>
        **Resolution:** <br>
        1. Have cluster and VPC/subnet in same resource group
        1. Create [custom-storage-class](https://test.cloud.ibm.com/docs/containers?topic=containers-storage-file-vpc-apps#storage-file-vpc-custom-sc) and provide the VPC resourceGroup ID. Then try creating PVC/PV with this custom storage class.
        1. If resource group is common and the command does have subnet list `kubectl get configmap ibm-cloud-provider-data -n kube-system -o yaml` then compare it with `ibmcloud is subnets` for the respective vpc subnets.
         - Collect logs for more details. Refer to [#Fetching logs from victory](#fetching-logs-from-victory) 
         - Refer to the [#Escalation Policy](#escalation-policy)

1. For any other usage issue, there is generally explanation in the PVC events. If there is unknown issue of PVC not getting created, collect the [victory logs](#fetching-logs-from-victory) and then refer to the [#Escalation Policy](#escalation-policy)

### Issues with volume mounting
1. There are issues due to which mount failure can occur, some of the common issues along with debugging steps are listed below. <br>
    1. **MountVolume failed.** <br>
        **Error:** _`MountVolume.SetUp failed for volume "pvc-xxxx" : rpc error: code = DeadlineExceeded desc = context deadline exceeded`_ <br>
        **Resolution:**<br>
        1. Check if user has upgraded from an older version to IKS 1.25+ and ROKS 4.11+. New security group rules have been introduced in versions IKS 1.25/ROKS 4.11 and later due to which user need to sync security group. Please go through below note to make sure mount has no restrictions with CSI provided default storage classes.-> [sync-security-groups](https://test.cloud.ibm.com/docs/containers?topic=containers-storage-file-vpc-apps#storage-file-vpc-custom-sc:~:text=If%20your%20cluster%20was%20initially%20created%20at%20version%201.25%20or%20earlier%2C%20run%20the%20following%20commands%20to%20sync%20your%20security%20group%20settings.)<br>
        2. Check if POD is scheduled to worker node which is restricted.[#Limiting file share access](https://cloud.ibm.com/docs/containers?topic=containers-storage-file-vpc-apps#storage-file-vpc-vni-setup)
        - If the issue still persist then, refer to the next point...
     <br>  

1. If there is unknown issue due to which pod is not going into "Running" state, follow below steps to try root cause the issue.
    1. Get the node where the impacted user application is trying to run. Use command `kubectl get pods -o wide |grep <app-name>` and look for node. 
    2. Get the nodeServer pod name running on that same node. Use command `kubectl get pods -o wide | grep vpc-file-csi-node | grep <nodeIp>`
    2. Get the volumeID which is being mounted to the application. Use command `kubectl describe pv <pvc-xxxx> | grep volumeID`
    3. Collect [logs from victory](#fetching-logs-from-victory).
    4. Now that you know the node where the app is running. Go to that node server folder and grep for '<VolumeID>'. You will be able to see the log which might be causing this issue.

### Issues mounting EIT enabled volume
1. Confirm if the volume is EIT enabled or not. Look for tag `isEITEnabled=true` in PV describe
    ```
    $ kubectl describe pv <pvc-xxxxx> | grep isEITEnabled
    ```
1. If found, then go through following troubleshooting doc
    1. [Why do I see a MetadataServiceNotEnabled error for File Storage for VPC?](https://test.cloud.ibm.com/docs/containers?topic=containers-ts-storage-vpc-file-eit-access)
    2. [Why do I see an UnresponsiveMountHelperContainerUtility error for File Storage for VPC?](https://test.cloud.ibm.com/docs/containers?topic=containers-ts-storage-vpc-file-eit-unresponsive)

- If there is any concerns related to **EIT package installation** try to disable and enable EIT on the worker pool again. To do so run,
    1. `kubectl edit cm -n kube-system addon-vpc-file-csi-driver-configmap` and remove worker pool from field  `EIT_ENABLED_WORKER_POOLS`
    2. Wait for 5 min
    3. Edit cm and enable for the same worker pool.
    - If issue persist [collect logs from victory](#fetching-logs-from-victory) and report to the storage issue referring to [#Escalation Policy](#escalation-policy).


- For any unknown reasons related to **mount failure**, the user needs to collect relevant logs that will indicate the cause of mount failure.
User might see pod events like this in case some unknown error while mounting,
    ```
    Events:
    Type     Reason       Age                   From               Message
    ----     ------       ----                  ----               -------
    Normal   Scheduled    5m59s                 default-scheduler  Successfully assigned default/my-eit-app to 10.10.10.10
    Warning  FailedMount  119s (x2 over 4m)     kubelet            MountVolume.SetUp failed for volume "pvc-129c8073-95f7-4cba-bff0-fd3a0cde0f94" : rpc error: code = DeadlineExceeded desc = context deadline exceeded
    Warning  FailedMount  102s (x2 over 3m57s)  kubelet            Unable to attach or mount volumes: unmounted volumes=[my-volume], unattached volumes=[], failed to process volumes=[]: timed out waiting for the condition
    ```
    or
    ```
    Events:
    Type     Reason       Age    From               Message
    ----     ------       ----   ----               -------
    Normal   Scheduled    6m37s  default-scheduler  Successfully assigned default/my-dep-eit2-7474654bb8-69gx4 to 10.240.0.25
    Warning  FailedMount  5m     kubelet            MountVolume.SetUp failed for volume "pvc-3985f611-538b-4a1c-b80a-36e313ba8157" : rpc error: code = Internal desc = {RequestID: c90443bc-cb90-4905-b2fe-488735b0579e , Code: MountingTargetFailed, Description: Failed to mount target., BackendError: Response from mount-helper-container -> Exit Status Code: exit status 1 ,ResponseCode: 500, Action: Check node server logs for more details on mount failure.}
    ```

    Step 1: Get the node where the application pod is running and the volumeID
    ```
    ❯ kubectl get pods -n application -o wide
    my-eit-app                            0/1     ContainerCreating   0          128s   10.240.0.238     10.240.0.238   <none>           <none>

    ❯ kubectl describe pv <pv-name> | grep volumeID
    ```

    Step 2: Get nodeServer logs of the node where application is running and grep with volumeID

    ```
    ❯ kubectl get pods -n kube-system | grep vpc-file-csi-node | grep <NodeIP>

    # Look for requestID in the below output
    ❯ kubectl logs ibm-vpc-file-csi-node-xxxx -n kube-system -c iks-vpc-file-node-driver | grep <volumeID>

    # See all events for this requestID
    ❯ kubectl logs ibm-vpc-file-csi-node-xxxx -n kube-system -c iks-vpc-file-node-driver | grep <requestID>
    ```

    Step 3: Get mount-helper logs
    ```
    ❯ kubectl exec ibm-vpc-file-csi-node-xxxx -n kube-system -c iks-vpc-file-node-driver -it -- cat /tmp/mount-helper/mount-ibmshare.log
    # Copy those logs to a file 'mount-ibmshare.log'
    ```


### Issues with volume expansion
1. For reference see [doc](https://cloud.ibm.com/docs/containers?topic=containers-vpc-file#vpc-file-volume-expand). Some of the issues and resolutions and listed below, <br>
    1. **Offline volume expansion i.e user tries to expand a pvc which is not attached to any node.**<br>
        **Impact:** PVC not getting expanded. <br>
        **Resolution:** <br>
        This is because vpc-file driver only supports "Online Expansion", which means volume is already attached to a pod. Attach volume to a pod and then edit the pvc to see the expanded volume.

### Issues with volume deletion
1. **Deleting PVC while a application/pod is already using it.**<br>
    **Impact:** PVC will be stuck in _Terminating_ state<br>
    **Resolution:**
    Delete the pod which is attached to the impacted volume. The volume will be deleted automatically.


### Fetching logs from victory
**Note:** Only for VPC IKS/ROKS clusters.
1. **Running victory bot**<br>
   **Step 1:** From any of IBM slack workspace, add "victory" app.

   **Step 2:** Run command 
   ```
   @victory get-storage-info <cluster-id> ibm-vpc-file detailed
   ```
   This command will be responsible for fetching all the vpc-file related info like controller logs, node-server logs, pods which are using the file csi controller, pvc/pv used in the failing pods, etc.. . More info can be found [here](https://github.ibm.com/alchemy-containers/armada-storage-tools-utils/blob/master/vpc/file/README.md).

   **Sample Output**
   ```
    <VictoryAPP 12:14> : @victory get-storage-info <cluster-id> ibm-vpc-file detailed

    <victoryAPP 12:14> : Running the armada-storage-analysis job for cluster: <cluster-id>

    <victoryAPP 12:25> : Please review the results of running the analyze-storage Jenkins job.
   ```

   **Note:** The command takes approximately 10-20 minutes to complete and publish the link for the jenkins job. Please share the jenkins job link provided.

1. **Downloading logs from jenkins job**
   **Step 1:** Like mentioned in abobe output, there will be a jenkins links posted to you once the job runs successfully. Click on it.

   **Step 2:** On the left panel, click on 'Status'. Once there download the folder under `Build Artifacts`

   **Step 3:** Untar the folder using command `tar -xvzf xyz.tar.gz -O <your-custom-folder-name>`


### Fetching logs manually
1. If any of the driver pod is in failing state, describe for more details.
    ```
    kubectl describe pod -n kube-system <failed controller/node-server pod>
    ```
1. Collect driver logs.
    ```
    # Controller logs
    kubectl logs ibm-vpc-file-csi-controller-xxx -n kube-system -c iks-vpc-file-driver

    # Node server logs
    kubectl logs ibm-vpc-file-csi-node-xxx -n kube-system -c iks-vpc-file-node-driver
    ```
1. Collect pvc/pv details. (In case of volume creation/ attachment issues)
    ```
    # Describe pvc
    kubectl describe pvc <pvc-name>

    # Describe pv
    kubectl describe pv <pv-name>
    ```

## Escalation Policy
If you have any problems with the above steps, please ping in [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) channel on Slack tagging `vpc-storage-ca` squad. Make sure to give link the customer ticket GHE.
