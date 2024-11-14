---
layout: default
description: This runbook covers the  portworx post install issues
title: portworx-usage-portworx_usage_issues
service: portworx
category: armada
runbook-name: "usage-portworx_usage_issues"
tags: portworx, portworx-volume, portworx-pvc, portworx-postinstall
link: /armada/porworx_usage_issues.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains some useful trouble shooting tips to recover from the portworx post install issues.

## Example Alerts

None

## Investigation and Action

- Log into the associated IBM Cloud account
  ```
  ibmcloud login --sso
  ```

- Target the correct region
  ```
  ibmcloud target -r <region>
  _e.g. `ibmcloud target -r us-south`_
  ```

- Identify the correct cluster
  ```
  ibmcloud ks cluster ls`
  ~~~shell
  root@muraliVM1::~$ ibmcloud ks cluster ls
  OK
  Name                ID                                 State    Created        Workers   Location   Version
  portworx-us-south-zone1   d5dc142d62ef4d23b44c10b9976c790d   normal   8 months ago   9         dal10      1.8.11_1509*
  portworx-us-south-zone2   4e13b43147c043e5ab00632b676f95d1   normal   8 months ago   9         dal12      1.8.11_1509*`
  ~~~
  ```

- Direct your K8s commands to the cluster
  ```
  ibmcloud ks cluster config --cluster <cluster id>
  ```

- List Portworx pods
  ```
   kubectl get pods -l name=portworx -n kube-system -o wide

   root@muraliVM1:~/portworx# kubectl get pods -l name=portworx -n kube-system -o wide
   NAME             READY   STATUS    RESTARTS   AGE   IP              NODE            NOMINATED NODE   READINESS GATES
   portworx-7bjht   0/1     Running   0          14m   10.243.128.50   10.243.128.50   <none>           <none>
   portworx-grfn6   0/1     Running   0          14m   10.243.128.49   10.243.128.49   <none>           <none>
   portworx-m45ts   0/1     Running   0          14m   10.243.128.51   10.243.128.51   <none>           <none>
   root@muraliVM1:~/portworx#
  ```

- Get Portworx cluster status
  ```
  PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
  kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status

  Status: PX is operational
  License: Enterprise
  Node ID: 10.176.48.67
  IP: 10.176.48.67
  Local Storage Pool: 1 pool
  POOL    IO_PRIORITY    RAID_LEVEL    USABLE    USED    STATUS    ZONE    REGION
  0    LOW        raid0        20 GiB    3.0 GiB    Online    dal10    us-south
  Local Storage Devices: 1 device
  Device    Path                        Media Type        Size        Last-Scan
   0:1    /dev/mapper/3600a09803830445455244c4a38754c66    STORAGE_MEDIUM_MAGNETIC    20 GiB        17 Sep 18 20:36 UTC
  total                            -            20 GiB
  Cluster Summary
  Cluster ID: mycluster
  Cluster UUID: a0d287ba-be82-4aac-b81c-7e22ac49faf5
  Scheduler: kubernetes
  Nodes: 2 node(s) with storage (2 online), 1 node(s) without storage (1 online)
  IP        ID        StorageNode    Used    Capacity    Status    StorageStatus    Version        Kernel            OS
  10.184.58.11    10.184.58.11    Yes        3.0 GiB    20 GiB        Online    Up        1.5.0.0-bc1c580    4.4.0-133-generic    Ubuntu 16.04.5 LTS
  10.176.48.67    10.176.48.67    Yes        3.0 GiB    20 GiB        Online    Up (This node)    1.5.0.0-bc1c580    4.4.0-133-generic   Ubuntu 16.04.5 LTS
  10.176.48.83    10.176.48.83    No        0 B    0 B        Online    No Storage    1.5.0.0-bc1c580    4.4.0-133-generic    Ubuntu 16.04.5 LTS
  Global Storage Pool
  Total Used        :  6.0 GiB
  Total Capacity    :  40 GiB
  ```

- List Portworx volumes
  ```
  PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
  kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume list
  ```

- To inspect the portworx volume
  ```
  PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
  kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume inspect volName
  ```

- Updating VPC worker nodes with portworx volumes

  Use the following link to upgrade the VPC worker nodes

  https://cloud.ibm.com/docs/containers?topic=containers-portworx#portworx_vpc_up

  or alternately use the following script to perform the upgrade of the worker nodes of VPC CLuster with portworx volumes

  https://github.com/IBM/ibmcloud-storage-utilities/tree/master/px-utils/px_vpc_upgrade

- Collecting Portworx logs.

  Use the following script to collect logs.

  https://github.com/IBM/ibmcloud-storage-utilities/tree/master/px-utils/px_logcollector



## Issues covered by this runbook

1. If the portworx service is not running or not healthy, and in the portworx pod logs it is showing as the nodes
   are started as storage less nodes.

    **Error:**
    ```
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]# pxctl status
    PX is not running on  host: Could not reach 'HealthMonitor'
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#

    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#
    @kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000298 portworx[946427]: time="2021-01-14T12:23:30Z"
    level=error msg="Could not find any available storage disks on this node: unable to start as a storageless node
    as no storage node found in the cluster.Please add storage to your nodes and restart Portworx."
    ```

    **Resolution:**

    Refer the below doc to attach storage volumes and restart the portworx service.

    https://cloud.ibm.com/docs/containers?topic=containers-portworx#create_block_storage

2. Portworx service is not up due to the etcd is not reachable, and in the portworx pod logs it is showing etcd service is not
   reachable.

    **Error:**
    ```
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]# pxctl status
    PX is not running on  host: Could not reach 'HealthMonitor'
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#

    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#
    @kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000298 portworx[946427]: time="2021-01-14T12:23:30Z"
    level=error msg="Etcd service is not reachable.The etcd location specified when creating the Portworx
    cluster needs to be reachable from all nodes."
    ```
    **Resolution:**

    1. Run curl <etcd_url>/version from each node to ensure reachability
    2. If the curl command fails to bring the version then refer the below doc for proper etcd installtion
       and configuration

       https://cloud.ibm.com/docs/containers?topic=containers-portworx#portworx_database

3. Portworx pod is not up due to etcd authorization issues

    **Error:**
    ```
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]# pxctl status
    PX is not running on  host: Could not reach 'HealthMonitor'
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#

    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#
    @kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000298 portworx[946427]: time="2021-01-14T12:23:30Z"
    level=error msg="Could not init boot manager” error=“failed to connect to external kvdb:
    etcdserver: authentication failed, invalid user ID or password”."
    ```

    **Resolution:**

    Refer the below doc for proper configuration of the etcd username and password

    https://cloud.ibm.com/docs/containers?topic=containers-portworx#portworx_database

4. Portworx pod is not up due to etcd username and password empty

    **Error:**
    ```
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]# pxctl status
    PX is not running on  host: Could not reach 'HealthMonitor'
    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#

    [root@kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000384 /]#
    @kube-bvusl2of018s5mqcf37g-j009icm1r3t-default-00000298 portworx[946427]: time="2021-01-14T12:23:30Z"
    level=error msg="Could not init boot manager” error=“failed to connect to external kvdb: etcdserver:
    username is empty, invalid user ID or password”."
    ```

    **Resolution:**

    Refer the below doc for proper configuration of the etcd username and password. Ensure that there are
    no new line characters and spaces at the end of the usename and password.

    https://cloud.ibm.com/docs/containers?topic=containers-portworx#portworx_database

5. If one or more of Portworx nodes comes up as storage less nodes after replacing/updating the VPC workers with Portworx volumes
   even when they have block storage attached for Portworx.
   This should/could only happen if neither of the below provided steps for replacing/updating VPC workers with portworx
   volumes are followed:
   https://cloud.ibm.com/docs/containers?topic=containers-portworx#portworx_vpc_up or alternately use the following script
   to perform the upgrade of the worker nodes of VPC Cluster with Portworx volumes
   https://github.com/IBM/ibmcloud-storage-utilities/tree/master/px-utils/px_vpc_upgrade.

   **NOTE**: In case, Portworx service is down after replacing/updating the VPC workers with portworx volumes, we highly recommend to
   raise a Portworx support ticket instead of trying to recover by following the below steps. These steps are only recommended
   in case one or more of Portworx nodes comes up as storage less nodes after updating the VPC workers with Portworx volumes
   even when they have storage attached.

    **Error:**

    ```
    List down the portworx pods and exec into one of the Portworx daemonset pod and get status -
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
    kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status

    Status: PX is operational
    License: Enterprise
    Node ID: 10.175.48.67
    IP: 10.175.48.67
    Local Storage Pool: 1 pool
    POOL    IO_PRIORITY    RAID_LEVEL    USABLE    USED    STATUS    ZONE    REGION
    0    LOW        raid0        100 GiB    3.0 GiB    Online    dal10    us-south
    Local Storage Devices: 1 device
    Device    Path                        Media Type        Size        Last-Scan
    0:1    /dev/mapper/3600a09803830445455244c4b28553c61    STORAGE_MEDIUM_MAGNETIC    100 GiB        17 Sep 18 20:36 UTC
    total                            -            100 GiB
    Cluster Summary
    Cluster ID: my-px-cluster
    Cluster UUID: a0c287ba-be82-4aac-b81c-7e22ac49fae4
    Scheduler: kubernetes
    Nodes: 2 node(s) with storage (2 online), 1 node(s) without storage (1 online)
    IP        ID        StorageNode    Used    Capacity    Status    StorageStatus    Version        Kernel            OS
    10.184.58.11    10.185.58.11    Yes        3.0 GiB    100 GiB        Online    Up        1.5.0.0-bc1c580    4.4.0-133-generic    Ubuntu 16.04.5 LTS
    10.176.48.67    10.175.48.67    Yes        3.0 GiB    100 GiB        Online    Up (This node)    1.5.0.0-bc1c580    4.4.0-133-generic   Ubuntu 16.04.5 LTS
    10.176.48.83    10.175.48.83    No        0 B    0 B        Online    No Storage    1.5.0.0-bc1c580    4.4.0-133-generic    Ubuntu 16.04.5 LTS
    Global Storage Pool
    Total Used        :  6.0 GiB
    Total Capacity    :  200 GiB


    In above Portworx cluster, node 10.176.48.83 is being displayed as storage less node after updating the underlying VPC worker for node 10.176.48.83.
    It is expected to be displayed as storage node as a block storage of 100 GiB is also attached to this node which was being used by /
    Portworx prior to upgrade.
    ```

    **Resolution:**

    **CASE1:** When only one VPC worker with Portworx volumes is updated at a time.

    1. Wait For Portworx to run on the replaced/updated worker (check Portworx daemon pod on the new worker using
       "kubectl get po -n kube-system -l name=portworx -owide").

    2. Check Portworx status after exec into one of the running Portworx DaemonSet pod(kubectl exec -it -n kube-system $portworx-pod bash)
       using “/opt/pwx/bin/pxctl status” and see if the newly added node is being displayed as storage less node and note down node id.

    3. Label newly added worker using "kubectl label nodes $node-name px/enabled=remove --overwrite" to remove the Portworx running on the
       node.

    4. Delete the above node from Portworx cluster using /opt/pwx/bin/pxctl cluster delete $node-id where node id is the id retrieved
       during step 2.

    5. Now, identify the block storage that was attached to the worker that has been updated and attach that block storage to the newly
       added worker using https://cloud.ibm.com/docs/openshift?topic=openshift-utilities#vpc_api_attach.

    6. Remove the labels from the new worker using “kubectl label nodes px/service- --overwrite” and
       “kubectl label nodes px/enabled- --overwrite”.

    7. Delete the Portworx DaemonSet pod from the newly added node using "kubectl delete po -n kube-system $podname",
       the pod will get recreated.

    8. Repeat step 1.

    9. Repeat step 2, only difference being that this time the newly added worker should come up as storage node if storage has been
       attached.

    **CASE2:** When all the VPC workers with Portworx volumes are updated simultaneously.

    **NOTE:** As already stated above, in case, Portworx service is down after update, please contact Portworx support team instead of
    trying to recover on your own. The steps given below are disruptive and will stop Portworx service on all the workers prior to trying to bring it up.

    1. Stop portworx service on all the portworx nodes using "kubectl label nodes --all px/service=stop --overwrite".

    2. Attach block storage (attach block storage previously attached to all the required portworx nodes) using
       https://cloud.ibm.com/docs/openshift?topic=openshift-utilities#vpc_api_attach.

    3. Start portworx service on all the portworx nodes ("kubectl label nodes --all px/service=start --overwrite").

    4. Wait For all the Portworx daemon pods to run (check Portworx daemon pod using "kubectl get po -n kube-system -l name=portworx -owide".

6. Portworx status shows all good and a Portworx PVC is also created successfully but PVC mount fails with the below error.

    **Error:**
    ```
    Application container that uses the created PVC crashes with the below error:

    Warning FailedMount 5s (x5 over 13s) kubelet MountVolume.SetUp failed for volume "pvc-0c93fb31-e6b3-47c1-b2b9-bb83af167d21" : Get "http://mac-mehmodnde-pd03-sat01-worker01:17001/v1/osd-volumes/versions": dial tcp: lookup mac-mehmodnde-pd03-sat01-worker01: no such host
    ```

    **Resolution:**

    1. Check if the mentioned host in the error is present or not.

    2. Check if we are able to access the above host(using nc[netcat] command) from one of the Portworx daemonset pod.

    3. If we are not able to access the host then check on the DNS configuration on that host using "cat /etc/resolv.conf".

    4. Check if we are resolving DNS using hostname or something else, if something else then check if adding hostname in the
       "/etc/resolv.conf" helps with the issue i.e., edit /etc/resolv.conf and add hostname for the resolution.

    5. Verify if the issue is fixed on a given node.

    Above steps could be repeated on all the hosts where Portworx is running but this would be a temporary resolution for above issue.
    These DNS changes will go away in case of worker reboot/reload/update.


###  NOTE: If the issue is not listed above or the issue is not resolved, please contact portworx support

   Please access the Portworx Service Portal here:

   https://pure1.purestorage.com/

   You can also reach them by phone at : 1-866-244-7121
   For a complete list of the Pure support phone numbers follow this link https://support.purestorage.com/Pure1/Support
   You can also submit a request via e-mail by mailing to mailto:support@purestorage.com

   For the sev1 and critical issues raise the **prodoutage request** and other issues raise problem report


## Escalation Policy

   For more help in searching the logs, please visit the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) channel.

   If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by
   using the [Alchemy - Containers Tribe - armada-storage](https://ibm.pagerduty.com/escalation_policies#P5B6A9G) PD
   escalation policy.

   If you run across any armada-storage problems during your search, you can open a GHE issue for armada-storage [issues].
   (https://github.ibm.com/alchemy-containers/armada-storage/issues/new/choose)
