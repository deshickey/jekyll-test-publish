---
layout: default
description: Procedure to debug the armada-storage-s3fs-plugin issues.
title: armada-storage -  Procedure to debug the armada-storage-s3fs-plugin issues.
service: armada-storage
runbook-name: "armada - Procedure to debug the armada-storage-s3fs-plugin issues."
tags: alchemy, armada, armada-storage-s3fs-plugin, armada-storage, object storage
link: /armada/armada-storage-s3fs-plugin-troubleshooting.html
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
The S3FS integration with K8S involves three components, namely `S3FS Provisioner`, `S3FS flex-driver` and `S3FS Fuse`.
For more details please refer to [architecture](https://github.ibm.com/alchemy-containers/armada-storage-s3fs-plugin/blob/master/doc/Armada-S3FS-Architecture-v0.1.pdf).<br>
Provisioner pod is deployed on one of the worker node by deployment `ibmcloud-object-storage-plugin` under `ibm-object-s3fs
` namespace. Where as `S3FS flex-driver` and `S3FS Fuse` are installed on all the worker nodes of a cluster. It is deployed by daemonset `ibmcloud-object-storage-driver` under  `ibm-object-s3fs` namespace.

This runbook describes how to debug the `armada-storage-s3fs-plugin` issues and fix those issues.

## Example Alert(s)

   None

## Investigation and Action

### General basic checks
1. Pull the cluster configuration.
   ```
   ibmcloud ks cluster config -c <cluster_name/cluster_id>
   ```

1. Ensure helm is installed on your local system. Execute `helm help`.<br>
   If output is `-bash: helm: command not found`
   then follow [instructions](https://cloud.ibm.com/docs/containers?topic=containers-helm#install_v3) to install helm.

1. Check the helm setup is configured properly on cluster using command `helm ls`<br>

   Note - S3FS supports only Helm V3 and will not work with Helm V2. If Helm V2 is installed on your local machine or on your cluster, then [migrate from Helm V2 to V3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3)

 1. Check if the plugin is installed on customer cluster.<br>
    ```
    helm ls -A --all-namespaces
    ```
### Note - If the plugin is not installed on the customer cluster, please reverify if the issue is related to cos s3fs plugin.  

1. Find the worker node IP(`<WORKER_NODE_IP>`) where pod with `s3fs-volume` problem is scheduled.<br>
   ```
   kubectl get pod <POD_NAME> -n <POD_NAMESPACE> -o wide
   ```

   Sample output:
   ```
   NAME       READY   STATUS    RESTARTS   AGE   IP        NODE
   test-pod   1/1     Running   0          3d    x.x.x.x   y.y.y.y    
   ```

   In above output, IP mentioned under column `NODE` is worker node IP where pod is scheduled.


### Issues with plugin install
1. If the install of s3fs plugin fails, possible issues might be old version of helm or old version of ibmc plugin.

1. Check the helm version and the ibmc plugin install by running below command
    ```
     helm ibmc --help
    ```

   If the version is V2 or < V3.2.0, it is required to update helm to V3.2.0 or later.
1. If there is any issue with ibmc plugin, update the `ibmc` plugin to latest.
    ```
    helm ibmc -u
    ```
    OR
    ```
     $ helm plugin uninstall ibmc
     $ helm fetch --untar ibm-helm/ibm-object-storage-plugin && cd ibm-object-storage-plugin
     $ helm plugin install ./ibm-object-storage-plugin/helm-ibmc
     $ helm ibmc --help
    ```

### Issues with plugin update
If the user has already installed the plugin and is trying to update the plugin to later version and is facing issues,
1. Get the current version of the s3fs plugin installed on customer cluster
    ```
    helm ls
    ```
1. If the s3fs plugin version is in 1.x.x, please check the currently added helm repositories

    helm repo list
   If `ibm-helm` repository is not added in the list, then add the repository and then install the plugin.
   ```
    With version 2.0.0, the IBM Cloud Object Storage Helm chart is now available in the ibm-helm repository. To add the repository, run-
     $ helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
     $ helm repo update
    ```
1. Update the ibmc plugin as below:
    ```
    helm ibmc --update
   ```
1. Pull the latest version of s3fs plugin
    ```
    helm pull --untar ibm-helm/ibm-object-storage-plugin
    ```
1. Run upgrade command:

   	helm ibmc upgrade ibm-object-storage-plugin ibm-helm/ibm-object-storage-plugin --force --set license=true --namespace "ibm-object-s3fs"


### Pod creation failures and Recovery
Creation of Pod, with `S3FS Volume` attached, may fail because of multiple reasons. Below are some possible failure reasons and steps to recover from failure:

**A)** If pod creation fails with error:
`Unable to mount volumes for pod "xxxxxx": timeout expired waiting for volumes to attach/mount for pod "xxxxxx", MountVolume.SetUp failed for volume "pvc-yyyyyy"`
It means _**s3fs-flex-driver**_ might _**not**_ be installed on the worker node where pod is scheduled.

Follow below steps to fix the issue:

   1. _**Check `IBM Cloud Object Storage plugin`**_<br>
      Check if plugin is installed on the cluster by executing<br>
      `helm ls | grep ibmcloud-object-storage-plugin`<br>
      If output of the cmd is _**empty**_, it means `IBM Cloud Object Storage plugin` is _**not**_ installed.<br>
      Follow [deploy readme](https://github.ibm.com/alchemy-containers/armada-storage-s3fs-plugin/tree/iks-master/stable/ibm-object-storage-plugin-bundle/charts/ibm-object-storage-plugin/README.md) to install IBM Cloud Object Storage plugin.<br>
      Else, move to next step.

   1. _**Check  `ibmcloud-object-storage-driver-xxx` POD**_<br>
      Check if the plugin driver pod deployed on the worker node (refer to Step 5 of _**General basic checks**_ above) is in `Running` state.<br>
      ```
      kubectl get pods -n ibm-object-s3fs -o wide | grep ibmcloud-object-storage-driver | grep <WORKER_NODE_IP>
      ```
      **Note:** Here `<WORKER_NODE_IP>` is IP of worker node retrieved by **STEP 5** under section **General basic checks**.

      1. If output of above command is _**empty**_, it means _**s3fs-flex-driver**_ is not installed on this worker
          node.<br>
          Check worker node status by executing<br>
          `kubectl get nodes |grep <WORKER_NODE_IP>`.<br>
          If node is in `Ready` state, then fetch the plugin and driver logs by using [s3fs diagnostic tool](https://github.com/IBM/ibmcloud-object-storage-plugin/tree/master/tools/IBM#how-to-execute-diagnostic-tool) and
          post issue in [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) slack channel and tag _**@nkashyap @masachan @ambikanair @bhagyak1**_.

      1. If  `ibmcloud-object-storage-driver-xxx` pod is _**not**_ in `Running` state, then follow below steps:<br>
         1. Find `ibmcloud-object-storage-driver-xxx` pod name.<br>
            ```
            driver_podname=$(kubectl get pods -n ibm-object-s3fs -o wide | grep ibmcloud-object-storage-driver | grep <WORKER_NODE_IP> | awk '{print $1}')
            ```
         1. Check the details of `ibmcloud-object-storage-driver-xxx` pod.<br>
            ```
            kubectl describe pod $driver_podname -n ibm-object-s3fs
            ```
         1. Check logs of `ibmcloud-object-storage-driver-xxx` pod<br>
            ```
            kubectl logs $driver_podname -n ibm-object-s3fs
            ```


**B)** If pod creation fails with error:
`Unable to mount volumes for pod "xxxxxx": timeout expired waiting for volumes to attach/mount for pod "xxxxxx", MountVolume.SetUp failed for volume "pvc-yyyyyy": : mount command failed, status: Failure, reason: Error mounting volume:`,<br> then there could be many reason for pod creation failure like `invalid S3 endpoint` or `S3 endpoint not accessible` or `invalid S3 account credentials(access key & secret key, etc)`.<br>
Follow below steps to debug the issue:<br>
   1. Find `ibmcloud-object-storage-driver-xxx` pod name.<br>
               ```
               driver_podname=$(kubectl get pods -n ibm-object-s3fs -o wide | grep ibmcloud-object-storage-driver | grep <WORKER_NODE_IP> | awk '{print $1}')
               ```

   1. Check the details of `ibmcloud-object-storage-driver-xxx` pod.<br>
               ```
               kubectl describe pod $driver_podname -n ibm-object-s3fs
               ```
    1. Check logs of `ibmcloud-object-storage-driver-xxx` pod<br>
               ```
               kubectl logs $driver_podname -n ibm-object-s3fs
               ```
   1. OR, fetch the driver logs by using [s3fs diagnostic tool](https://github.com/IBM/ibmcloud-object-storage-plugin/tree/master/tools/IBM#how-to-execute-diagnostic-tool) and
      post issue in [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) slack channel and tag _**@nkashyap @masachan @ambikanair @bhagyak1**_.

**C)** If pod creation fails with error:
`PersistentVolumeClaim is not bound`, it means the related PVC is in `PENDING state`.<br>
Follow below steps to check why PVC is in PENDING state:<br>
   1. Check whether `IBM Cloud Object Storage plugin` is installed on the cluster by executing<br>
      `helm ls | grep ibmcloud-object-storage-plugin`<br>
      If output of the cmd is _**empty**_, it means `IBM Cloud Object Storage plugin` is _**not**_ installed in the cluster.<br>
      Follow [deploy readme](https://github.ibm.com/alchemy-containers/armada-storage-s3fs-plugin/tree/iks-master/stable/ibm-object-storage-plugin-bundle/charts/ibm-object-storage-plugin/README.md) to install `IBM Cloud Object Storage plugin` in the cluster.<br>
      Else, move to next step.

   1. Check whether s3-provisioner pod is in `Running` state by running below commands:<br>
      ```
      kubectl get pods -n ibm-object-s3fs | grep 'ibmcloud-object-storage-plugin'
      ```

      1. If s3-provisioner pod is _**not**_ in `Running` state, then delete s3-provisioner pod using below commands:<br>
         ```
         provisioner_podname=$(kubectl get pods -n ibm-object-s3fs | grep 'ibmcloud-object-storage-plugin' | awk '{print $1}')
         kubectl delete pod $provisioner_podname -n ibm-object-s3fs
         ```
         And deployment `ibmcloud-object-storage-plugin` will redeploy provisioner pod on one of the worker nodes of the cluster.<br>
         Check state of newly created provisioner pod by using below commands:<br>
         ```
         kubectl get pods -n ibm-object-s3fs | grep 'ibmcloud-object-storage-plugin'
         ```
         If newly created provisioner pod is also _**not**_ in `Running` state, then use [s3fs diagnostic tool](https://github.com/IBM/ibmcloud-object-storage-plugin/tree/master/tools/IBM#how-to-execute-diagnostic-tool) to debug the issue.

         OR fetch the plugin and driver logs by using [s3fs diagnostic tool](https://github.com/IBM/ibmcloud-object-storage-plugin/tree/master/tools/IBM#how-to-execute-diagnostic-tool) and then post issue in [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) slack channel and tag _**@nkashyap @masachan @ambikanair @bhagyak1**_.

      1. If s3-provisioner pod is in `Running` state, then execute below steps:<br>

         1. Get PVC name used for mounting inside pod.
            ```
            pvc_name=$(kubectl get pods <POD_NAME> -n <POD_NAMESPACE> -o yaml | grep claimName: | awk -F ' ' '{print $2}')
            ```
         1. Find out the reason for PVC stuck in PENDING state.
            ```
            kubectl describe pvc $pvc_name -n <PVC_NAMESPACE>
            ```
         1. Also, check s3-provisioner pod logs.
            ```
            provisioner_podname=$(kubectl get pods -n ibm-object-s3fs | grep 'ibmcloud-object-storage-plugin' | awk '{print $1}')
            kubectl logs $provisioner_podname -n ibm-object-s3fs
            ```


### Using s3fs diagnostic tool

1. Pull the cluster KUBECONFIG
   ```
   ibmcloud ks cluster config -c <cluster_name/cluster_id>
   ```
2. Clone the repo   
`git clone https://github.com/IBM/ibmcloud-object-storage-plugin.git`

    and navigate to diagnostic tool   
 `cd ibmcloud-object-storage-plugin/tools/IBM`

3. Follow the readme as below to run the s3fs diagnostic tool
   https://github.com/IBM/ibmcloud-object-storage-plugin/tree/master/tools/IBM#how-to-execute-diagnostic-tool


### Other issues and recovery
There are some other issues with s3fs-plugin as given below:

1. _**S3FS process to manage the mount point crashed:**_<br>
   When S3FS process to manage the mount point crashed or stuck, the POD process trying to access mounted path receives
   _**"Transport endpoint is not connected"**_ error.<br>

   **Recovery:**<br>
   To fix this issue, you need to force-delete the POD and recreate the POD (in case of deployment, POD will be auto recreated).<br>
   Force delete the POD by executing below command:<br>
   ```
   kubectl delete pod <POD_NAME> -n <POD_NAMESPACE> --grace-period=0 --force
   ```

1. _**Issue while accessing the mount: Input/output Error, Performance or Throughput issues:**_<br>
   Analyze **syslog (/var/log/syslog)** for issue with s3fs process.


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
