---
layout: default
description: How to debug the issue when block PVC creation or attach fails.
title: armada-storage-block -  How to debug the issue when block PVC creation or attach fails.
service: armada-storage
category: armada
runbook-name: "How to debug the issue when PVC creation or attach fails."
tags: alchemy, armada, kubernetes, kube, kubectl, wanda, block
link: /armada/armada-stroage-block-pvc-creation-attach-fail.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to debug the issue when block PVC creation or attach to pod fails.

## Example Alert(s)
None

## Investigation and Action

### I. Block plugin installation/upgrade/delete issues
1. **Ensure helm is installed and initialized in the cluster.** Else you may get below issues:
    1. **E001: Helm init failure** <br>
         **Error:** _`-bash: helm: command not found`_ <br>
           **Resolution:** install helm following [instructions](https://github.ibm.com/alchemy-containers/armada-storage-block-plugin/blob/master/deploy/helm/README.md). <br>

         **Error:** _`error installing: Post https://X.X.X.X:YY/apis/extensions/v1beta1/namespaces/kube-system/deployments:
           dial tcp X.X.X.X:YY:getsockopt: connection refused`_<br>
           **Resolution:** Make sure the cluster exists `bx cs clusters` and get the latest cluster config `bx cs cluster-config <CLUSTER NAME>` <br>
    1. **E002: If `helm install` fails**  <br>
         **Error:** _`could not find tiller`_ <br>
           **Resolution:** `helm init` <br>

         **Error:** _`release XXXXX failed: storageclasses.storage.k8s.io "ibmc-block-bronze" already exists`_ <br>
           **Resolution:** Use the existing cluster or redeloy the cluster with new values. <br>
1. **Ensure the pods are created/deleted successfully.**<br>
   1. **I001: Check if provsioner and driver are running successfully.** <br>
      `kubectl get pods -n kube-system | grep "ibm-block-plugin"` <br>
      `kubectl get pods -n kube-system | grep "ibm-block-plugin-driver"` <br>

   1. **E003: Provisioner or Driver pods stuck in** **_`ImagePullBackOff`_** **state.** <br>
      **Resolution:** That means the image used for pods creation is not avaialble in the registry or <br>
                  there may be permisiion issues, make sure you have access to the registry. <br>
1. The **`helm upgrade` is not supported** for plugin or driver. Need to delete the installed helm release and re-created a new one with updated values. <br>
   `helm list` will provide the details of installed release. <br>
   `helm delete <HELM RELEASE NAME>` <br>
   `helm install ./ibm-block-plugin` <br>
1. **Helm and Kube client compatibility issues** <br>
   _**TBD**_


### II. PVC Creation issues
1. Creation of PVC may fail due to many resons. Below are some of the common issues and steps to debug them. <br>
   1. **E003:Block PVC only supports `ReadWriteOnce` access modes.** <br>
      **Error:** _`Try creating PVC with other access modes apart from RWO "ReadWriteMany" is an unsupported access mode. Block Storage supports only 'ReadWriteOnce' mode`_ <br>
      **Resolution:**<br>
         1. Re-check the access mode specified whil creation or in describe output using cmd: `kubectl describe pvc <PVC-name>` <br>
         1. Update the `accessModes` to `ReadWriteOnce` and try re-creating the pvc.<br>

   1. **E004: Connection issues with softlayer.**<br>
      **Error:** In this case pvc is stuck in _`Pending`_ state. <br>
      **Resolution:** <br>
         1. Get the exact error with `kubectl describe pvc <PVC NAME>` output. <br>
         1. Or, get the error from logs of provisioner. `kubectl logs <BLOCK-PLUGIN-POD-NAME> -n kube-system` <br>
	 In such cases report the issue in `armada-block-stotage` channel, with `kubectl describe` output. <br>


### III. Mounting Issues
1. There are many cases due to which mount or attach issues can occure, some of the common issues along with debugging steps are listed below. <br>
   1. **E005: Sometimes there can stale iscsi targets which cannot be mounted.** In such cases the `kubectl describe pod <POD-NAME>` shows erros similar to below. <br>
      **Errors:** <br>
         1. _`timeout expired waiting for volumes to attach/mount for pod`_ <br>
         1. _`mountdevice command failed, status: Failure`_ <br>
         1. _`Error while attaching the device Error while attaching Lun YYY from portal X.X.X.X .Error: [sliscsi]`_ <br>

      **Resolution:** <br>
         1. Report these issues to `armada-block-stotage` channel, with `kubectl describe` output. <br>
   1. **E006: If a PVC is already attached other pod then it cannot be attached to other pods.** <br>
      **Errors:**<br>
         1. _`Error: PV pvc-XXXX is already attached to another node X.X.X.X`_ <br>
         1. _`Error while mounting the volume &errors.errorString{s:"RWO check has failed. DevicePath XXXXXX is already mounted on mountpath XXXXXX `_ <br>

      **Resolution:** <br>
      1. Make sure you delete the pod on which pvc is already mounted, before trying to attach pvc to other pod. As block pvc's can be mounted to only one host at a time. <br>
   1. **E007: The PVC mount fails in case if the pod and pvc are scheduled in different zones.** <br>
      **Errors:** _`No nodes are available that match all of the following predicates:: MatchNodeSelector (2), NoVolumeZoneConflict (1).`_ <br>
      **Resolution:** <br>
         1. Get the worker node on which pod is delpoyed. <br>
            `kubectl get pods -o wide` <br>
         1. Get the AZ on with pv is created. <br>
            `kubectl get pv <PV NAME> -o yaml | grep "failure-domain.beta.kubernetes.io/zone"` <br>
         1. Compare worker node's AZ with pv's AZ. If both are not the same then this issue will occur, else post in `armada-block-storage` channel. <br>


### IV. Viewing logs
1. **I002: Get KubeConfig for a cluster.** <br>
   2. Get the cluster config using bx commands `bx cs cluster-config <CLUSTER NAME>`, export the KUBECONFIG as shown in output.
1. **I003: Steps to check provisioner logs.**<br>
   2. Get the provisioner pod name `kubectl get pods -n kube-system | grep "ibm-block-plugin"` <br>
   2. Check the logs `kubectl logs <PROVISIONER POD NAME> -n kube-system` <br>
1. **I004: Steps to check driver logs.** <br>
   2. The driver pod for the worker ip for which logs are needed. `kubectl get pods -n kube-system -o wide | grep "ibm-block-plugin-driver" | grep <WORKER IP>` <br>
   2. Get the logs `kubectl exec <DRIVER POD> -n kube-system - tail -n 200 /host/var/log/ibmc-block.log` <br>
1. **Sample commands with their outputs for viewing logs.** <br>
   2. Get cluster config and export it in env.

   ```

	$bx cs clusters
	OK
	Name              ID                                 State     Created        Workers   Location   Version   
	cluster2          474254eebc324dbb86fee3b41cea4387   normal    2 weeks ago    2         mex01      1.8.8_1507   

	$bx cs cluster-config cluster2
	OK
	The configuration for cluster2 was downloaded successfully. Export environment variables to start using Kubernetes.

	export KUBECONFIG=/root/.bluemix/plugins/container-service/clusters/cluster2/kube-config-mex01-cluster2.yml

	$export KUBECONFIG=/root/.bluemix/plugins/container-service/clusters/cluster2/kube-config-mex01-cluster2.yml

   ```
   2. Get the running block plugin and driver pods.

   ```

	$kubectl get pods -n kube-system | grep block
	ibm-block-plugin-79d998f6f6-4xth8          1/1       Running   0          14d
	ibm-block-plugin-driver-swbcj              1/1       Running   0          14d
	ibm-block-plugin-driver-tw4qj              1/1       Running   0          14d

   ``` 
   For getting provisoner logs execute `kubectl logs -f ibm-block-plugin-79d998f6f6-4xth8` <br>
   2. Get the host on which pod with issues is running.

   ```

	$kubectl get pods -o wide
	NAME      READY     STATUS              RESTARTS   AGE       IP        NODE
	newpod1   0/1       ContainerCreating   0          5s        <none>    10.130.229.124

   ```
   2. Get the driver running on the same host as pod

   ```

	$kubectl get pods -n kube-system -o wide | grep block-plugin-driver
	ibm-block-plugin-driver-swbcj              1/1       Running   0          14d       10.130.229.124   10.130.229.124
	ibm-block-plugin-driver-tw4qj              1/1       Running   0          14d       10.130.229.123   10.130.229.123

   ```
   Get the logs for corresponding driver with below command. 
   `kubectl exec ibm-block-plugin-driver-swbcj -n kube-system -- tail -f -n 100 /host/var/log/ibmc-block.log`


&nbsp;

## Escalation Policy

For more help in searching the logs, please visit the [{{site.data.storage.armada-storage.block.name}}]({{site.data.storage.armada-storage.block.link}})  channel.

If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by using the [{{site.data.storage.armada-storage.escalate.name}}]({{site.data.storage.armada-storage.escalate.link}}) PD escalation policy.

If you run across any armada-storage problems during your search, you can open a GHE issue for armada-storage [{{site.data.storage.armada-storage.name}}]({{site.data.storage.armada-storage.issue}}).

## Automation

None
