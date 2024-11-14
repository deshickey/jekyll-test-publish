---
layout: default
description: Procedure to debug armada-satellite-storage aws EBS and EFS template issues.
title: armada-storage -  Procedure to debug armada-satellite-storage aws EBS and EFS template issues.
service: armada-storage, satellite-storage
runbook-name: "armada - armada-satellite-storage aws EBS and EFS issues."
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/armada-sat-storage-aws-ebs-efs-troubleshooting.html
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

This runbook describes how to debug issues related to satellite storage templates - 'AWS EBS and EFS' and fix those issues.

Please refer to the template specific readme for assignment creation / template install steps - <br>
https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates

## Example Alert(s)

   None

## Investigation and Action

[AWS EBS install issues](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-aws-ebs-efs-troubleshooting.html#install-issues-for-aws-ebs) <br>
[AWS EFS install issues](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-aws-ebs-efs-troubleshooting.html#install-issues-for-aws-efs) <br>

### install issues for aws ebs

1. Check weather all the template specific Remote resources got created on creating the assignment.<br>
   Run below command and verify all the respective remote resources got created and are up and running.

   List the EBS driver pods in the kube-system namespace and verify that the status is Running.

   `kubectl get pods -n kube-system | grep ebs`


   Reference output:
   ```
   $ kubectl get pods -n kube-system | grep ebs
   ebs-csi-controller-76d48cd86d-nvbx9     6/6     Running   0          61m
   ebs-csi-controller-76d48cd86d-tgb9l     6/6     Running   0          61m
   ebs-csi-node-6k4xd                      3/3     Running   0          61m
   ebs-csi-node-dg59c                      3/3     Running   0          61m
   ebs-csi-node-r7jcl                      3/3     Running   0          61m
   ebs-snapshot-controller-0               1/1     Running   0          61m
   ```

1. Verify the default storage classes (as specified in the template) got created <br>
   `oc get sc| grep ebs`

   Reference output:
     ```.env
   % oc get sc| grep ebs
   sat-aws-block-bronze         ebs.csi.aws.com    Delete          Immediate              true                   61m
   sat-aws-block-bronze-metro   ebs.csi.aws.com    Delete          WaitForFirstConsumer   true                   61m
   sat-aws-block-gold           ebs.csi.aws.com    Delete          Immediate              true                   61m
   sat-aws-block-gold-metro     ebs.csi.aws.com    Delete          WaitForFirstConsumer   true                   61m
   sat-aws-block-silver         ebs.csi.aws.com    Delete          Immediate              true                   61m
   sat-aws-block-silver-metro   ebs.csi.aws.com    Delete          WaitForFirstConsumer   true                   61m
   ```

1. Remote resources not created when the assignment is created

   1. Fetch mustachetemplate-controller pod logs and check for any errors in config/ assignment creation.

        ```
        kubectl logs mustachetemplate-controller-xxx-xxx -n razeedeploy
        ```

        **Troubleshoot** - Check for any config creation / assignment creation errors in the logs

1. PVC not getting bound / PVC creation errors     
   1. Get the logs for `ebs-csi-controller-xxx` pod.
        `kubectl logs -f pod/ebs-csi-controller-xxx -n kube-system`

       **Troubleshoot** - Check if the csi-controller pod has any errors


### Debug checks for common expected issues

1. For the functionality specific issues follow the provider links for more debug steps

    *AWS-EBS-CSI-Driver* : https://github.com/kubernetes-sigs/aws-ebs-csi-driver

    *Examples* : https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes

    *Amazon EBS* : https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEBS.html

    *AWS Support* : https://console.aws.amazon.com/support/home#/



### install issues for aws efs

1. Check weather all the template specific Remote resources got created on creating the assignment.<br>
   Run below command and verify all the respective remote resources got created and are up and running.

   List the EBS driver pods in the kube-system namespace and verify that the status is Running. <br>
   `kubectl get pods -n kube-system | grep efs`


   Reference output:
      ```
      $ kubectl get pods -n kube-system | grep efs
      efs-csi-controller-7796788877-fvx46     3/3     Running   0          37s
      efs-csi-controller-7796788877-mbcsr     3/3     Running   0          37s
      efs-csi-node-76kks                      3/3     Running   0          37s
      efs-csi-node-bfw8v                      3/3     Running   0          37s
      efs-csi-node-jkqls                      3/3     Running   0          37s
      ```

1. Remote resources not created when the assignment is created

   1. Fetch mustachetemplate-controller pod logs and check for any errors in config/ assignment creation.

        ```
        kubectl logs mustachetemplate-controller-xxx-xxx -n razeedeploy
        ```

        **Troubleshoot** - Check for any config creation / assignment creation errors in the logs

1. PVC not getting bound / PVC creation errors     
   1. Get the logs for `efs-csi-controller-xxx` pod.
        `kubectl logs -f pod/efs-csi-controller-xxx -n kube-system`

       **Troubleshoot** - Check if the csi-controller pod has any errors


### Debug checks for common expected issues

1. For the functionality specific issues follow the provider links for more debug steps

    *AWS-EFS-CSI-Driver* : https://github.com/kubernetes-sigs/aws-efs-csi-driver

    *Examples* : https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes

    *Amazon EFS* : https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html

    *AWS Support* : https://console.aws.amazon.com/support/home#/



### Must Gather tool for armada-storage-api - TODO

Must gather tool to collect necessary artifacts /logs for troubleshooting is in progress.

Use Victory slack bot to fetch the must gather logs for gcp driver on customer cluster
```
@victory get-storage-info

Usage: @victory get-storage-info <cluster_id> <drivername> <optional:namespace>Please select drivername from below:drivername options - aws-ebs, aws-efs, azuredisk, azurefile, gcp-compute-persistent-disk, ibm-vpc-block, local-volume-block, local-volume-file, netapp-trident, netapp-ontap-nas, netapp-ontap-san, odf, portworx, vsphere-csi-driver

Example:-
@victory get-storage-info cahl3brt0dik075klkhg aws-ebs/aws-efs <optional_app_ns>
```


### Other issues and recovery


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
