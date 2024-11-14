---
layout: default
description: Procedure to debug armada-satellite-storage azure template issues.
title: armada-storage -  Procedure to debug armada-satellite-storage azure template issues.
service: armada-storage, satellite-storage
runbook-name: "armada - armada-satellite-storage azure csi driver issues."
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/armada-sat-storage-azure-troubleshooting.html
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

This runbook describes how to debug issues related to satellite storage templates - 'Azure csi driver' and fix those issues.

Please refer to the template specific readme for prerequisites, assignment creation / template install steps - <br>
https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates


## Example Alert(s)

   None

## Investigation and Action

### install issues

1. Check wether all the template specific Remote resources got created on creating the assignment.<br>
   Run below command and verify all the respective remote resources got created and are up and running.

   List the azuredisk driver pods in the kube-system namespace and verify that the status is Running

   `kubectl get pods -n kube-system | grep azure`

   Reference output:
   ```
   csi-azuredisk-controller-849d854b96-6jbjg   5/5     Running   0          167m
   csi-azuredisk-controller-849d854b96-lkplx   5/5     Running   0          167m
   csi-azuredisk-node-7qwlj                    3/3     Running   6          167m
   csi-azuredisk-node-8xm4c                    3/3     Running   6          167m
   csi-azuredisk-node-snsdb                    3/3     Running   6          167m
   ```

1. Verify the default storage classes (as specified in the template) got created <br>
   `kubectl get sc | grep azure`

   Reference output:
     ```.env
   % kubectl get sc | grep azure
    sat-azure-block-bronze           disk.csi.azure.com   Delete          Immediate              true                   167m
    sat-azure-block-bronze-metro     disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   167m
    sat-azure-block-gold             disk.csi.azure.com   Delete          Immediate              true                   167m
    sat-azure-block-gold-metro       disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   167m
    sat-azure-block-platinum         disk.csi.azure.com   Delete          Immediate              true                   167m
    sat-azure-block-platinum-metro   disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   167m
    sat-azure-block-silver           disk.csi.azure.com   Delete          Immediate              true                   167m
    sat-azure-block-silver-metro     disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   167m
   ```

1. Remote resources not created when the assignment is created

   1. Fetch mustachetemplate-controller pod logs and check for any errors in config/ assignment creation.

        ```
        kubectl logs mustachetemplate-controller-xxx-xxx -n razeedeploy
        ```

        **Troubleshoot** - Check for any config creation / assignment creation errors in the logs

1. PVC not getting bound / PVC creation errors     
   1. Get the logs for `csi-azuredisk-controller-xxx` pod.
        `kubectl logs -f pod/csi-azuredisk-controller-xxx -n kube-system`

       **Troubleshoot** - Check if the csi-controller pod has any errors

1. In case of `node register failure`, please make sure that nodes are labelled with proper zone.

1. In case of `authentication failure`, please make sure that Service Principal is created properly.



### Debug checks for common expected issues

1. For the functionality specific issues follow the provider links for more debug steps

    *Azuredisk-CSI-Driver* : https://github.com/kubernetes-sigs/azuredisk-csi-driver

    *Examples* : https://github.com/kubernetes-sigs/azuredisk-csi-driver/tree/d08f1a08abda7e6f195b3b952528e6b1c6a8b363/deploy/example

    *Get Azure Credentials* : https://www.inkoop.io/blog/how-to-get-azure-api-credentials/


### Must Gather tool for armada-storage-api - TODO

Must gather tool to collect necessary artifacts /logs for troubleshooting is in progress.

Use Victory slack bot to fetch the must gather logs for gcp driver on customer cluster
```
@victory get-storage-info

Usage: @victory get-storage-info <cluster_id> <drivername> <optional:namespace>Please select drivername from below:drivername options - aws-ebs, aws-efs, azuredisk, azurefile, gcp-compute-persistent-disk, ibm-vpc-block, local-volume-block, local-volume-file, netapp-trident, netapp-ontap-nas, netapp-ontap-san, odf, portworx, vsphere-csi-driver

Example:-
@victory get-storage-info cahl3brt0dik075klkhg azuredisk/azurefile <optional_app_ns>
```


### Other issues and recovery


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
