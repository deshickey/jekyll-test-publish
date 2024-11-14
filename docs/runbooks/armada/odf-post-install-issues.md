---
layout: default
description: This runbook covers the issues with the ODF addon post installation issues
title: odf-postinstall-odf_post_install_issues
service: odf
category: armada
runbook-name: "ODF post installation issues"
tags: odf, odf-install, addon, openshift-storage namespace
link: /armada/odf-post-install-issues.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains some useful trouble shooting tips to recover from the issues after ODF installation.

## Example Alerts

None

## Investigation and Action

None

## Issues covered by this runbook

- `rook-ceph-rgw-ocs-storagecluster-cephobjectstore-a-xxx` pod is in CrashLoopBackOff and shows the below logs
```
debug 2022-05-16 16:55:32.776 7fcf7c531280  0 deferred set uid:gid to 167:167 (ceph:ceph)
debug 2022-05-16 16:55:32.776 7fcf7c531280  0 ceph version 14.2.11-208.el8cp (6738ba96f296a41c24357c12e8d594fbde457abc) nautilus (stable), process radosgw, pid 1514
debug 2022-05-16 16:55:32.816 7fcf7c531280  0 failed reading zonegroup info: ret -2 (2) No such file or directory
debug 2022-05-16 16:55:32.816 7fcf7c531280  0 ERROR: failed to start notify service ((2) No such file or directory
debug 2022-05-16 16:55:32.816 7fcf7c531280  0 ERROR: failed to init services (ret=(2) No such file or directory)
debug 2022-05-16 16:55:32.817 7fcf7c531280 -1 Couldn't init storage provider (RADOS)
```
  **Resolution:**
  Follow these steps to restore the pod
  1. Scale down the ocs-operator and rook-ceph-operator pods
    ```
    oc scale deployment ocs-operator -n openshift-storage --replicas=0
    oc scale deployment rook-ceph-operator -n openshift-storage --replicas=0
    ```
  2. Wait about 30 seconds and verify the pods are not present
  3. Access this link https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.8/html/troubleshooting_openshift_container_storage/restoring-the-monitor-pods-in-openshift-container-storage_rhocs
  4. After entering the link, find the section `Restoring the Multicloud Object Gateway` to find the commands that have to be run
  5. When completed, scale up the rook-ceph-operator and ocs-operator deployments.
    ```
    oc scale deployment rook-ceph-operator --replicas=1 -n openshift-storage
    oc scale deployment ocs-operator --replicas=1 -n openshift-storage
    ```
- If user applied taint on a node describe application shows error `kubernetes.io/csi: attacher.MountDevice failed to create newCsiDriverClient: driver name openshift-storage.rbd.csi.ceph.com not found in the list of registered CSI drivers`

   **Resolution:**
   Because of the taint on the node, the csi plugin pods aren't created for that node. Please add a toleration to the CSI Plugin daemonset using the steps given here : https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.8/html-single/managing_and_allocating_storage_resources/index#managing-container-storage-interface-component-placements_rhocs

- If dashboard shows storage full/warning messages or `oc describe cephcluster -n openshift-storage` shows any error like below.
   ```
   Details:
      OSD_BACKFILLFULL:
        Message:   2 backfillfull osd(s)
        Severity:  HEALTH_WARN
      OSD_FULL:
        Message:   1 full osd(s)
        Severity:  HEALTH_ERR
   ```
    **Resolution:**
    Increase the number of OSD by editing `ocscluster` resource and increase the value of `num-of-osd`

- If cluster is 2 versions ahead than ODF (ie ODF 4.8 and OCP 4.10)
  The normal upgrade of ODF won't be possible as ODF have n & n+1 support
    **Resolution:**
    Follow the below steps to move from ODF version same as OCP

    UPGRADE ODF FROM CURRENT TO NEXT VERSION (eg: ODF 4.8 to ODF 4.9)
    1. Disable the openshift data foundation addon by using the below command
      `ibmcloud ks cluster addon disable openshift-data-foundation -c <cluster-id>`
    2. Get the backup of below resources.
      ```
      oc get catsrc -n openshift-marketplace redhat-operators -o yaml > catsrc-rh-operator.yaml
      oc get sub -n openshift-storage -o yaml > sub-4.8.yaml
      oc get installplan -n openshift-storage > installplan-4.8.yaml
      oc get csv -n openshift-storage > csv-4.8.yaml
      ```
    3. Disable the catalogsource using the below command.
       `oc patch operatorhub.config.openshift.io/cluster -p='{"spec":{"sources":[{"disabled":true,"name":"redhat-operators"}]}}' --type=merge`
    4. Create the new catalogsource by pointing to the next ODF version ie 4.9 here, create a new file, catsrc-4.9.yaml Paste the below content and save
        ```
        apiVersion: operators.coreos.com/v1alpha1
        kind: CatalogSource
        metadata:
        name: redhat-operators
        namespace: openshift-marketplace
        spec:
        displayName: Red Hat Operators
        icon:
        base64data: ""
        mediatype: ""
        image: registry.redhat.io/redhat/redhat-operator-index:v4.9
        priority: -100
        publisher: Red Hat
        sourceType: grpc
        updateStrategy:
        registryPoll:
        interval: 10m
        ```
        Apply file file by `oc apply -f catsrc-4.9.yaml`
    5. Check the catalogsource is created successfully by checking, redhat-operators-xxx pod is created.
        `oc get po -n openshift-marketplace`
    6. Now edit the subscription and change the channel to the next version/the version that catalogsource pointing. ie `stable-4.9` here
       `oc edit sub -n openshift-storage odf-operator` change `channel` value to `stable-4.9`
    7. Check the storagecluster and confirm it is showing progressing right after the sub has changed
       `oc get storagecluster -n openshift-storage`
    8. wait for 10 minutes and check the below resources and confirm the ODF has moved to 4.9 version
        ```
        oc get sub -n openshift-storage
        oc get csv -n openshift-storage
        oc get storagecluster -n openshift-storage
        ```
      Here is the sample output
       ```
        oc get csv
        ocNAME DISPLAY VERSION REPLACES PHASE
        mcg-operator.v4.11.8 NooBaa Operator 4.11.8 mcg-operator.v4.10.13 Succeeded
        ocs-operator.v4.11.8 OpenShift Container Storage 4.11.8 ocs-operator.v4.10.13 Succeeded
        odf-csi-addons-operator.v4.11.8 CSI Addons 4.11.8 odf-csi-addons-operator.v4.10.13 Succeeded
        odf-operator.v4.11.8 OpenShift Data Foundation 4.11.8 odf-operator.v4.10.13 Succeeded
        gayathrimenath@Gayathris-MacBook-Pro test % oc get sub
        NAME PACKAGE SOURCE CHANNEL
        mcg-operator-stable-4.10-redhat-operators-openshift-marketplace mcg-operator redhat-operators stable-4.11
        ocs-operator-stable-4.10-redhat-operators-openshift-marketplace ocs-operator redhat-operators stable-4.11
        odf-csi-addons-operator-stable-4.10-redhat-operators-openshift-marketplace odf-csi-addons-operator redhat-operators stable-4.11
        odf-operator odf-operator redhat-operators stable-4.11
        gayathrimenath@Gayathris-MacBook-Pro test % oc get storagecluster -n openshift-storage
        NAME AGE PHASE EXTERNAL CREATED AT VERSION
        ocs-storagecluster 12d Ready 2023-06-22T13:47:02Z 4.11.0
       ```
    Now ODF has moved to next version, ie 4.9

    STEPS TO UPGRADE ODF TO OCP VERSION (ie 4.9 TO 4.10 )
    1. Delete the catalogsource redhat-operators which is created manually.
       `oc delete -f catsrc-4.9.yaml`
    2. Enable the catalogsource redhat operator using below command
       `oc patch operatorhub.config.openshift.io/cluster -p='{"spec":{"sources":[{"disabled":false,"name":"redhat-operators"}]}}' --type=merge`
      Verify the `redhat-operator-xxx` pod is running on `openshift-marketplace` namespace. (refer the command from above)
    3. Enable openshift-data-foundation addon by using the below command or from UI, the values doesn't matter as the resources are not deleted, it will not be creating any new resources.
      `ibmcloud ks cluster addon enable openshift-data-foundation -c --vesion 4.10.0`
    4. Once the addon is ready, edit the `ocscluster` and make `ocsUpgrade` to true
       `oc edit ocscluster`
    5. Check the below resources and confirm ODF moved to next version ie 4.10
        ```
        oc get sub -n openshift-storage
        oc get csv -n openshift-storage
        oc get storagecluster -n openshift-storage
        ```
       Sample response below
        ```
        oc get sub
        NAME PACKAGE SOURCE CHANNEL
        mcg-operator-stable-4.10-redhat-operators-openshift-marketplace mcg-operator redhat-operators stable-4.12
        ocs-operator-stable-4.10-redhat-operators-openshift-marketplace ocs-operator redhat-operators stable-4.12
        odf-csi-addons-operator-stable-4.10-redhat-operators-openshift-marketplace odf-csi-addons-operator redhat-operators stable-4.12
        odf-operator odf-operator redhat-operators stable-4.12
        gayathrimenath@Gayathris-MacBook-Pro test % oc get csv
        NAME DISPLAY VERSION REPLACES PHASE
        mcg-operator.v4.12.4-rhodf NooBaa Operator 4.12.4-rhodf mcg-operator.v4.11.8 Succeeded
        ocs-operator.v4.12.4-rhodf OpenShift Container Storage 4.12.4-rhodf ocs-operator.v4.11.8 Succeeded
        odf-csi-addons-operator.v4.12.4-rhodf CSI Addons 4.12.4-rhodf odf-csi-addons-operator.v4.11.8 Succeeded
        odf-operator.v4.12.4-rhodf OpenShift Data Foundation 4.12.4-rhodf odf-operator.v4.11.8 Succeeded
        oc get storagecluster
        NAME AGE PHASE EXTERNAL CREATED AT VERSION
        ocs-storagecluster 12d Ready 2023-06-22T13:47:02Z 4.12.0
        ```
## Escalation Policy

   For more help in searching the logs, please visit the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) channel.

   If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by
   using the [Alchemy - Containers Tribe - armada-storage](https://ibm.pagerduty.com/escalation_policies#P5B6A9G) PD
   escalation policy.

   If you run across any armada-storage problems during your search, you can open a GHE issue for [armada-storage issues](https://github.ibm.com/alchemy-containers/armada-storage/issues/new/choose).
