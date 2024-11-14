---
layout: default
description: Procedure to debug armada-satellite-storage redhat local volume template issues.
title: armada-storage -  Procedure to debug armada-satellite-storage redhat local volume issues.
service: armada-storage, satellite-storage
runbook-name: "armada - armada-satellite-storage redhat local-volume-file and local-volume-block issues."
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/armada-sat-storage-redhat-local-volume-troubleshooting.html
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

This runbook describes how to debug issues related to satellite storage templates - 'redhat local volume file and block' and fix those issues.

Please refer to the template specific readme for assignment creation / template install steps - <br>
https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates

## Example Alert(s)

   None

## Investigation and Action

### install issues

1. Check weather all the template specific Remote resources got created on creating the assignment.<br>
   Run below command and verify all the respective remote resources (service, daemonset, deployment , replicaset and pods) got created and are up and running. <br>
   `oc get all -n local-storage`

   *Note* - Here `local-storage` is the install namespace.

   Reference output:
   ```
    $ oc get all -n local-storage
    NAME                                         READY   STATUS    RESTARTS   AGE
    pod/local-disk-local-diskmaker-cpk4r         1/1     Running   0          30s
    pod/local-disk-local-provisioner-xstjh       1/1     Running   0          30s
    pod/local-storage-operator-96c444dfc-ttpmq   1/1     Running   0          35s

    NAME                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
    service/local-storage-operator   ClusterIP   172.21.173.238   <none>        60000/TCP   32s

    NAME                                          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
    daemonset.apps/local-disk-local-diskmaker     1         1         1       1            1           <none>          31s
    daemonset.apps/local-disk-local-provisioner   1         1         1       1            1           <none>          31s

    NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/local-storage-operator   1/1     1            1           36s

    NAME                                               DESIRED   CURRENT   READY   AGE
    replicaset.apps/local-storage-operator-96c444dfc   1         1         1       37s
    ```

1. Verify the default storage classes (as specified in the template) got created
   `oc get sc -n local-storage | grep local`

   Reference output:
   ```
   $ oc get sc -n local-storage | grep local
   sat-local-file-gold       kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  21m
   ```

1. Verify the default PV got created  
   `$ oc get pv`

   Reference output for local volume file:
   ```.env
    $ oc get pv
    NAME               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS          REASON   AGE
    local-pv-1d14680   50Gi       RWO            Delete           Available           sat-local-file-gold            50s
    ```

     Reference output for local volume block:
   ```.env
    $ oc get pv
    NAME               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS          REASON   AGE
    local-pv-1d14680   50Gi       RWO            Delete           Available           sat-local-block-gold            50s
    ```

1. Remote resources not created when the assignment is created

   1. Verify the target cluster version is same as the local-volume template version you have picked.
      For example, the target cluster version should be 4.7.X to use the local-volume version 4.7 template.

   1. Fetch mustachetemplate-controller pod logs and check for any errors in config/ assignment creation.

        ```
        kubectl logs mustachetemplate-controller-xxx-xxx -n razeedeploy
        ```

        **Troubleshoot** - Check for any config creation / assignment creation errors in the logs

   1. Get the namespace where you deployed the local storage template and verify that the status is Active
        `oc get ns local-storage`

        **Troubleshoot** - If the ns is in Termination state, follow below steps to delete ns.

        1. Cleanup/delete all the pvc, pv and pods that are using local volume.
        2. delete the symlink to the mount path as mention in step 4
        3. Force Delete the ns.

   1. Get the logs for `local-disk-local-diskmaker` pod.
        `kubectl logs -f pod/local-disk-local-diskmaker-7ww2j -n local-storage`

   1. If the diskmaker pod has error as below
        ```
        kubectl logs -f pod/local-disk-local-diskmaker-7ww2j -n local-storage01
        I0213 06:19:35.103830       1 diskmaker.go:24] Go Version: go1.13.15
        I0213 06:19:35.104141       1 diskmaker.go:25] Go OS/Arch: linux/amd64
        I0213 06:19:35.104148       1 diskmaker.go:26] local-storage-diskmaker Version: v4.6.0-202101300210.p0-0-ged6884f-dirty
        E0213 06:19:40.697628       1 diskmaker.go:203] failed to acquire lock on device /dev/xvde
        E0213 06:19:40.697657       1 diskmaker.go:180] error symlinking /dev/xvde to /mnt/local-storage/sat-local-file-gold/xvde: error acquiring exclusive lock on /dev/xvde
       ```
   *Note1* - The storage-class name in the above mentioned path will change to `/mnt/local-storage/sat-local-block-gold/xvde` for local-volume-block.

   *Note2* - The disk name in the above mentioned path would be the name of the additional volume you attached to the worker node as a pre-req for local-volume install.

   **Troubleshoot** -   
    1. Log-in to the node where the diskmaker pod is deployed.
        ```
        oc debug node/<node-name>
        ```
    2. Run the following command to use host binaries.
        ```.env
        chroot /host
        ```
    3. Delete the symlink.
        ```.env
        rm -rf </path/to/symlink/as/shown/in/logs>
        ```
        Example command - `rm -rf  /mnt/local-storage/sat-local-file-gold/xvde`



### Debug checks for common expected issues
(pvc issues, volume mount issues etc)
1. If the PVC creation has issues / PVC is not in `Bound` or `Available` state -
    **Troubleshoot** -   
    1. Get the `local-disk-provisioner` pod logs and verify any errors with PV creation.

    `kubectl logs -f pod/local-disk-local-provisioner-xstjh -n local-storage`


### uninstall issues

   1. Get the namespace where you deployed the local storage template and verify that the status is Active
      `oc get ns local-storage`

      **Troubleshoot** - If the ns is in Termination state, follow below steps to delete ns.
        1. Cleanup/delete all the pvc, pv and pods that are using local volume.
        2. delete the symlink to the mount path as mention in step 4
        3. Force Delete the ns.


### Must Gather tool for armada-storage-api - TODO
Must gather tool to collect necessary artifacts /logs for troubleshooting is in progress.

Use Victory slack bot to fetch the must gather logs for gcp driver on customer cluster
```
@victory get-storage-info

Usage: @victory get-storage-info <cluster_id> <drivername> <optional:namespace>Please select drivername from below:drivername options - aws-ebs, aws-efs, azuredisk, azurefile, gcp-compute-persistent-disk, ibm-vpc-block, local-volume-block, local-volume-file, netapp-trident, netapp-ontap-nas, netapp-ontap-san, odf, portworx, vsphere-csi-driver

Example:-
@victory get-storage-info cahl3brt0dik075klkhg local-volume-block/local-volume-file <optional_app_ns>
```


### Other issues and recovery


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
