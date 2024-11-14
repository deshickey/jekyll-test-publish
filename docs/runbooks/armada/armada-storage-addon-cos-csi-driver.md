---
layout: default
description: Procedure to debug COS CSI driver and addon-cos-csi-driver issues.
title: armada-storage -  Procedure to debug COS CSI driver and and addon-cos-csi-driver issues.
service: armada-storage
runbook-name: "armada - Procedure to debug COS CSI driver and addon-cos-csi-driver issues."
tags: alchemy, armada, cos-csi-driver, addon-cos-csi-driver, armada-storage, object storage, kubernetes
link: /armada/armada-storage-addon-cos-csi-driver.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Content
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

---

## Overview
A CSI based object storage plugin with dynamic bucket provisioning and plugable mounters, like rclone, s3fs, goofys and other. 
The COS CSI driver comprises of two main components, namely `Controller` and `node-server`.
The driver consists mainly of,
- `ibm-object-csi-controller` stateful-set.
- `ibm-object-csi-node` daemon-set.
For more details please refer to [architecture](https://github.ibm.com/alchemy-containers/armada/blob/cos-csi-driver/architecture/guild/concept-docs/concept-ibm-object-csi-driver.md).<br>

The Controller is deployed as a Deployment resource. It comprises `csi-provisioner` sidecar,  `ibm-object-csi-controller` and `livenessprobe` sidecar. Csi-Provisioner sidecar manages Kubernetes events and makes appropriate calls to `ibm-object-csi-controller` that implements a CSI Controller service. 
The Node Server is deployed on every node in the cluster through a DaemonSet. It consists of the `ibm-object-csi-node` that implements the CSI Node service and the `node-driver-registrar` sidecar container.

This runbook describes how to debug the `addon-cos-csi-driver` issues and fix those issues.

## Example Alert(s)

   None

## Investigation and Action

As a basic health check support team can verify addon health via LogDNA
1. Navigate to LogDNA - https://alchemy-dashboard.containers.cloud.ibm.com/
2. Select apps=armada-health
3. Query `<cluster id>/addons/addon-ibm-object-csi-driver/state`

### General basic checks
1. Pull the cluster configuration.
   ```
   ibmcloud ks cluster config -c <cluster_name/cluster_id>
   ```

1. **Check the health of addon to ensure it is deployed properly.**<br>
   ```
   ibmcloud ks cluster addon ls --cluster <cluster name or ID>
   ```

1. **Check addon version installed.**<br>
   ```
   ibmcloud ks cluster addon ls --cluster <cluster_name/cluster_id> | grep ibm-object-csi-driver
   ```
   It is recommeneded to use the latest version for better support. Available versions can be found [here](https://test.cloud.ibm.com/docs/openshift?topic=openshift-storage-cos-install-addon).

1. **Ensure all csi driver pods are in running state.**<br>
   ```
   kubectl get pods -n ibm-object-csi-operator | grep ibm-object-csi
   ```
   1. **If any of the above pod are stuck in** **_`ImagePullBackOff`_** **state**<br>
      **Resolution:** That means the image used for pods creation is not avaialble in the registry or there may be permission issues. For such issues please refer to [#Escalation Policy](#escalation-policy) team.<br>

   1. **If any of the above pod is in** **_`CrashLoopBackOff`_** **state**<br>
      **Resolution:** This may be due to unforseen reasons...
      - Describe that pod using command. `kubectl describe pod ibm-ibm-object-csi-xxx -n ibm-object-csi-operator`
      - Look for the container which is continuously restarting.
      - Collect logs for more details. `kubectl logs ibm-ibm-object-csi-xxx -n ibm-object-csi-operator`.
      - Upgrade to the latest version of addon for a possible fix. If the issue persists, refer to the [#Escalation Policy](#escalation-policy)
    

## Must gather info and triaging issue
Any issues related with COS CSI driver addon, customer ticket should have following details. Please pull below mentioned details and verify the next section of troubleshooting steps before reaching out to the storage squad.

1. Addon health status and addon version from General basic checks above.

1. PVC describe <br>
	```
	$kubectl describe pvc <PVC-NAME> -n <PVC-NAMESPACE>
	```
	
1. PV describe <br>
	```
	$kubectl describe pv <pv-name>
	```
	
1. POD describe which is causing issue because of pvc <br>
	```
	$kubectl describe pod <POD-NAME> -n <POD-NAMESPACE> 
	```
	
1. Controller-manager pod logs <br>
    ```
    $kubectl logs ibm-ibm-object-csi-operator-controller-manager-xxx -n ibm-object-csi-operator
    ```
	
1. csi-node pod logs <br>
    ```
    $kubectl logs ibm-object-csi-node-xxx -n ibm-object-csi-operator
    ``` 

## Victory bot for Cos CSI Driver addon 

Victory bot can be used to pull above information for a customer cluster. 
[Victory bot jenkins job to pull cluster details and deployed resource logs](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/)

 Victory bot for cos csi driver addon : <ComingSoon>


### Pod creation failures and Recovery
Creation of Pod, with `S3FS Volume` attached, may fail because of multiple reasons. Below are some possible failure reasons and steps to recover from failure:

**A)** If pod creation fails with error:
`Unable to mount volumes for pod "xxxxxx": timeout expired waiting for volumes to attach/mount for pod "xxxxxx", MountVolume.SetUp failed for volume "pvc-yyyyyy": : mount command failed, status: Failure, reason: Error mounting volume:`,<br> then there could be many reason for pod creation failure like `invalid S3 endpoint` or `S3 endpoint not accessible` or `invalid S3 account credentials(access key & secret key, etc)`.<br>
Follow below steps to debug the issue:<br>
   1. Verify the parameter values of cos secret created. Double check if they are base64 encoded.

   1. Verify the secret name and PVC name are same.
   
   1. Fetch the operator-controller-manager pod logs and csi-node pod logs and
      post issue in [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) slack channel and tag _**@nkashyap @masachan @bhagyak1**_.

**B)** If pod creation fails with error:
`PersistentVolumeClaim is not bound`, it means the related PVC is in `PENDING state`.<br>
Follow below steps to check why PVC is in PENDING state:<br>
   1. Check whether `COS CSI addon` is enabled on the cluster by executing<br>
         ```
        ibmcloud ks cluster addon ls --cluster <cluster name or ID>
        ```
      If the addon is not enabled or not in Healthy state, enable / re-enable addon and wait for it to go to Healthy state.

   1. Check whether ibm-object-csi-operator-controller-manager pod and ibm-object-csi-node-mbs75 pods are in `Running` state by running below commands:<br>
      ```
      kubectl get all -n ibm-object-csi-operator
      ```

      1. If pods are in `Running` state, then execute below steps:<br>

         1. Get PVC name used for mounting inside pod.
            ```
            pvc_name=$(kubectl get pods <POD_NAME> -n <POD_NAMESPACE> -o yaml | grep claimName: | awk -F ' ' '{print $2}')
            ```
         1. Find out the reason for PVC stuck in PENDING state.
            ```
            kubectl describe pvc $pvc_name -n <PVC_NAMESPACE>
            ```

**C)** Transport endpoint issue while writing from application pod to cos bucket:
If you end up in `Transport endpoint` error when in middle of read/write operation from application pod as below
```
Error: cp cmd failed. b"cp: error writing '/cosvoltest/file-43': Software caused connection abort\ncp: failed to close '/cosvoltest/file-43': Transport endpoint is not connected"
```
This is because of the resources and requests limits(CPU and Memery) for node server pods `ibm-object-csi-node`.
Increasing these limits for node pods will fix the issue. The  `ibm-object-csi-driver` addon provides the option to update these values for node pods via a configmap.
Customer can create a config-map by name `cos-csi-driver-configmap` with the configmap structure as below. Request and Limit values can be set as per the size of file in operation.
Once the config-map gets created, the addon and its operator takes care of updating node pods with new configuration.
cos-csi-driver-configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cos-csi-driver-configmap
  namespace: ibm-object-csi-operator
data:
  #Resource Requests per container
  CSINodeCPURequest: "40m"                    #container:ibm-object-csi-node, resource-type: cpu-request
  CSINodeMemoryRequest: "40Mi"                #container:ibm-object-csi-node, resource-type: memory-request

  #Resource Limits per container
  CSINodeCPULimit: "4"                         #container:ibm-object-csi-node, resource-type: cpu-limit
  CSINodeMemoryLimit: "800Mi"                  #container:ibm-object-csi-node, resource-type: memory-limit
```

**D)** Transport endpoint issue on application pod due to connectivity issue with node server pods:
If you see `transport endpoint is not connected` error in application/deployment pod logs and the pod has lost connectivity with the driver, the cause would be termination of `s3fs`/ `rclone` process on the node server pods. This can occur for multiple reasons like restart of node server pods, network connectivity issues etc.
The possible case for this error is when the patch release for the addon is pushed, node pods will get restarted and hence the TransportEndpoint error is expected. 

Need to restart the application deployment inorder to resume the `s3fs`/ `rclone` connection and get the things up again.

The  `ibm-object-csi-driver` addon provides an hassle free solution to this with `RecoverStaleVolume` CustomResource.
User has to create this Custom Resource providing details of their application deployemnts and respective namespace.
The CustomResource continuously monitors the applications specified and automatically restarts the application pods if it catches `TransportEndpoint` error on the specified pods. 

recover-stale-volume.yaml
```
apiVersion: objectdriver.csi.ibm.com/v1alpha1
kind: RecoverStaleVolume
metadata:
  labels:
    app.kubernetes.io/name: recoverstalevolume
    app.kubernetes.io/instance: recoverstalevolume-sample
  name: recoverstalevolume-sample
  namespace: default
spec:
  logHistory: 200
  data:
    - namespace: <namesapce_where_application_is_deployed>
      deployments: [<comma separated list of all the applications you would want to recover>]
```


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.