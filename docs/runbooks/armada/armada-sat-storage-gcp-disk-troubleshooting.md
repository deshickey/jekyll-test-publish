---
layout: default
description: Procedure to debug armada-satellite-storage GCP template issues.
title: armada-storage -  Procedure to debug armada-satellite-storage GCP template issues.
service: armada-storage, satellite-storage
runbook-name: "armada - armada-satellite-storage GCP issues."
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/armada-sat-storage-gcp-disk-troubleshooting.html
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

This runbook describes how to debug issues related to satellite storage templates - 'GCP' and fix those issues.

Please refer to the template specific readme for assignment creation / template install steps - <br>
https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates

## Example Alert(s)

   None

## Investigation and Action

[GCP install issues](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-gcp-disk-troubleshooting.html#install-issues) <br>

### install issues

1. Check weather all the template specific Remote resources got created on creating the assignment.<br>
   Run below command and verify all the respective remote resources got created and are up and running.

   `$ oc -n razeedeploy get rr`
   `$ oc -n razeedeploy get rr <clustersubscription resource name> -o yaml`
   `$ oc -n razeedeploy get MustacheTemplate`
   `$ oc -n razeedeploy get MustacheTemplate <teplate-resource-name> -o yaml`

   List all the resources in the gce-pd-csi-driver namespace and verify that the status is Running.

   `$ oc get all -n  gce-pd-csi-driver`


   Reference output:
   ``` 
                               
    NAME                                         READY   STATUS    RESTARTS   AGE
    pod/csi-gce-pd-controller-5fdc6f5596-49v5r   5/5     Running   0          27s
    pod/csi-gce-pd-node-rqrwg                    2/2     Running   0          27s
    pod/csi-gce-pd-node-t8k6x                    2/2     Running   0          27s
    pod/csi-gce-pd-node-xd87n                    2/2     Running   0          27s

    NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    daemonset.apps/csi-gce-pd-node   3         3         3       3            3           kubernetes.io/os=linux   28s

    NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/csi-gce-pd-controller   1/1     1            1           28s

    NAME                                               DESIRED   CURRENT   READY   AGE
    replicaset.apps/csi-gce-pd-controller-5fdc6f5596   1         1         1       28s
   ```

1. Verify the default storage classes (as specified in the template) got created <br>
   `oc get sc| grep gce`

   Reference output:
     ```.env
    NAME                                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    sat-gce-block-bronze                 pd.csi.storage.gke.io   Delete          Immediate              false                  27m
    sat-gce-block-bronze-metro           pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   false                  27m
    sat-gce-block-gold                   pd.csi.storage.gke.io   Delete          Immediate              false                  27m
    sat-gce-block-gold-metro (default)   pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   false                  27m
    sat-gce-block-platinum               pd.csi.storage.gke.io   Delete          Immediate              false                  27m
    sat-gce-block-platinum-metro         pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   false                  27m
    sat-gce-block-silver                 pd.csi.storage.gke.io   Delete          Immediate              false                  27m
    sat-gce-block-silver-metro           pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   false                  27m

   ```

1. Remote resources not created when the assignment is created

   1. Fetch mustachetemplate-controller pod logs and check for any errors in config/ assignment creation.

        ```
        kubectl logs mustachetemplate-controller-xxx-xxx -n razeedeploy
        ```

        **Troubleshoot** - Check for any config creation / assignment creation errors in the logs

1. PVC not getting bound / PVC creation errors     
   1. Get the logs for `csi-gce-pd-controller-xxx` pod.
        `kubectl logs -f pod/csi-gce-pd-controller-xxx -n gce-pd-csi-driver`

       **Troubleshoot** - Check if the csi-controller pod has any errors


### Debug checks for common expected issues

1. For the functionality specific issues follow the provider links for more debug steps

    *GCP-Disk-CSI-Driver* : https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver/

    *Examples* : https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver/tree/master/examples/kubernetes

    *Storage Options* : https://cloud.google.com/compute/docs/disks#footnote-1

    *AWS Support* : https://cloud.google.com/support/home#/



### Must Gather tool for armada-storage-api

Must gather tool to collect necessary artifacts /logs for troubleshooting is in progress.

Use Victory slack bot to fetch the must gather logs for gcp driver on customer cluster
```
@victory get-storage-info

Usage: @victory get-storage-info <cluster_id> <drivername> <optional:namespace>Please select drivername from below:drivername options - aws-ebs, aws-efs, azuredisk, azurefile, gcp-compute-persistent-disk, ibm-vpc-block, local-volume-block, local-volume-file, netapp-trident, netapp-ontap-nas, netapp-ontap-san, odf, portworx, vsphere-csi-driver

Example:-
@victory get-storage-info cahl3brt0dik075klkhg gcp-compute-persistent-disk <optional_app_ns>
```

### Other issues and recovery


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
