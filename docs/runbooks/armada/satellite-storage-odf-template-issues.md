---
layout: default
description: Procedure to debug armada-satellite-storage redhat odf-local and odf-remote template issues.
title: armada-storage - Procedure to debug armada-satellite-storage redhat odf-local and odf-remote issues.
service: odf, armada-storage, satellite-storage
category: armada
runbook-name: "satellite-storage-odf_template_issues"
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/satellite-storage-odf-template-issues.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

### Overview

This runbook describes how to debug issues related to satellite storage templates - redhat `odf-local` and `odf-remote` and fix those issues.

Please refer to the template specific readme for assignment creation / template install steps - <br>
https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates

### Example Alert(s)

   None

### Prerequisites
odf-remote :
1) Please make sure there is a remote volume provisioner present on the cluster and provide the corresponding storageclass in the configuration

odf-local :
1) The nodes should have a minimum of 2 raw, unformatted disks <br>
If only one disk is present, it can be partitioned and a small 20Gi partition can be used for monDevicePath and the rest for osdDevicePath


### Investigation and Action

1. On creating the assignment, verify if all the template specific remote resources got created.<br>
   Run the below commands and verify if all the respective remote resources got created and are up and running. <br>
   a) `oc get pods -n kube-system | grep ocs`

   Reference output:
   ```
   % oc get pods -n kube-system | grep ocs                     
   NAME                                                   READY   STATUS    RESTARTS   AGE
   ibm-ocs-operator-controller-manager-55fc75c755-twgbc   1/1     Running   0          64s
    ```

   b) `oc get ocscluster`

   Reference output:
   ```
   % oc get ocscluster
   NAME             AGE
   testocscluster   114s
   ```

   c) oc get secret -n kube-system | grep storage

   Reference output:
   ```
   % oc get secret -n kube-system | grep storage
   storage-secret-store                                 Opaque                                1      29s
   ```

2. Verify the default storage classes (as specified in the template) got created
   `oc get sc`

   Reference output:
   ```
   $ oc get sc
    NAME                          PROVISIONER                             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    localblock                    kubernetes.io/no-provisioner            Delete          WaitForFirstConsumer   false                  5m48s
    localfile                     kubernetes.io/no-provisioner            Delete          WaitForFirstConsumer   false                  5m49s
    ocs-storagecluster-ceph-rbd   openshift-storage.rbd.csi.ceph.com      Delete          Immediate              true                   5m31s
    ocs-storagecluster-ceph-rgw   openshift-storage.ceph.rook.io/bucket   Delete          Immediate              false                  5m31s
    ocs-storagecluster-cephfs     openshift-storage.cephfs.csi.ceph.com   Delete          Immediate              true                   5m31s
    openshift-storage.noobaa.io   openshift-storage.noobaa.io/obc         Delete          Immediate              false                  96s
    sat-ocs-cephfs-gold           openshift-storage.cephfs.csi.ceph.com   Delete          Immediate              true                   6m54s
    sat-ocs-cephfs-gold-metro     openshift-storage.cephfs.csi.ceph.com   Delete          WaitForFirstConsumer   true                   6m53s
    sat-ocs-cephrbd-gold          openshift-storage.rbd.csi.ceph.com      Delete          Immediate              true                   6m55s
    sat-ocs-cephrbd-gold-metro    openshift-storage.rbd.csi.ceph.com      Delete          WaitForFirstConsumer   true                   6m53s
    sat-ocs-cephrgw-gold          openshift-storage.ceph.rook.io/bucket   Delete          Immediate              false                  6m54s
    sat-ocs-noobaa-gold           openshift-storage.noobaa.io/obc         Delete          Immediate              false                  6m54s
   ```

### Issues covered by this runbook.

**If any of the above remote resources are not created on creating the assignment**

   1. Verify the target cluster version is compatible with the `odf-local` or `odf-remote` template version you have picked.
      For example, the target cluster version should be 4.7.X or 4.8.X to use `odf-local` or `odf-remote` version 4.7 template (n, n+1)

   2. Fetch the `mustachetemplate-controller` pod logs and check for any errors in the config/ assignment creation.

        ```
        kubectl logs mustachetemplate-controller-xxx-xxx -n razeedeploy
        ```

        **Troubleshoot** - Check for any config creation / assignment creation errors in the logs <br>
        **Example:** <br>
        **Error:**
        ```
        {"level":50,"time":1630591701131,"pid":1,"hostname":"mustachetemplate-controller-78f6b8dc6c-wbtc7","name":"MustacheTemplate","statusCode":422,"body":{"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"OcsCluster.ocs.ibm.io \"ps-AWS-MZ-1\" is invalid: metadata.name: Invalid value: \"ps-AWS-MZ-1\": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*')","reason":"Invalid","details":{"name":"ps-AWS-MZ-1","group":"ocs.ibm.io","kind":"OcsCluster","causes":[{"reason":"FieldValueInvalid","message":"Invalid value: \"ps-AWS-MZ-1\": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*')","field":"metadata.name"}]},"code":422}}
        ```

        **Cause :** <br>
        The parameter `ocs-cluster-name` refers to the name we're giving to the ocscluster resource and according to the naming convention of kubernetes resources, we can't have upper case names in them.

        **Resolution :** <br>
        1) Delete the assignment
        2) Create a new storage config with a supported value of `ocs-cluster-name`
        3) Apply an assignment of the new config to the satellite cluster/group

### Other issues and recovery


## Escalation Policy

   For more help in searching the logs, please visit the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) channel.

   If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by
   using the [Alchemy - Containers Tribe - armada-storage](https://ibm.pagerduty.com/escalation_policies#P5B6A9G) PD
   escalation policy.

   If you run across any armada-storage problems during your search, you can open a GHE issue for [armada-storage issues](https://github.ibm.com/alchemy-containers/armada-storage/issues/new/choose).
