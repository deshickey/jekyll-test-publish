---
layout: default
description: How to debug the issue when PVC creation is failed.
title: armada-storage -  How to debug the issue when PVC creation is failed.
service: armada-storage
category: armada
runbook-name: "How to debug the issue when PVC creation is failed."
tags: alchemy, armada, kubernetes, kube, kubectl, wanda
link: /armada/armada-stroage-pvc-creation-fail.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to debug the issue when PVC creation is failed.

## Example Alert(s)

### Possible issues to be looked in the logs of storage pod obtained from cluster owner

### 1. {{ site.data.storage.slname.name }} Account issues

1.  If you see the following entries in logs, it must be {{ site.data.storage.slname.name }} account quota issue. Please increase the Quota for your SL Account used in this Cluster. 
    2.  Storage creation failed with error: Your order will exceed the maximum number of storage volumes allowed. Please contact Sales.<br>
&nbsp;
1.  The following possible issue is related with rate limit. Set the Rate limit of the SL account user ID used in this cluster to 50 requests per second. 
    
    2.  {<i>"level":"error","ts":"2017-03-18*T11:55:54Z*","msg":"http_client_basic.go:89: Error occurred","error":"Rate limit of 5 requests for every 1 second(s) exceeded."<i>}
    2.  {<i>"level":"error","ts":"2017-03-18*T11:55:54Z*","msg":"nfs-provisioner.go:108: Storage creation failed with error: ","error":"Rate limit of 5 requests for every 1 second(s) exceeded."<i>}
    2.  <i>E0318 11:55:54.130793 1 controller.go:572] Failed to provision volume for claim "armada-storage-e2e-namespace/armada-prestage-qc7wr" with StorageClass "ibmc-file-bronze": Storage creation failed with error: Rate limit of 5 requests for every 1 second(s) exceeded<i>.<br>
&nbsp;
1.  If you see following error in storage pod logs, The issue is due to payment related issue. So customer needs to check with {{ site.data.storage.slname.name }} customer support or they may need to raise a {{ site.data.storage.slname.name }} ticket from their {{ site.data.storage.slname.name }} portal login.
    2.  {<i>Code:E0003, Description:Failed to place storage order with the storage provider [Backend Error:Could not place order. Problem authorizing the credit card. We're afraid this transaction has been rejected. General decline of the card. No other information provided by the issuing bank.], Type:StorageOrderFailed, RC:500<i>}.
&nbsp;

### 2. Slow provision issues
1.  If you see following error in storage pod logs, The issue is due to `Provisioning` taking more than 15min(may be SL is overloaded/slow in provisioning at that particular time). User can delete the PVC and try recreate.
    2.  {<i>Code:E0005, Description:Storage with the order ID 17618779 could not be created after retrying for 900 seconds. Description: Storage Order Status/Transaction [Current:APPROVED/Storage_SelectServiceResource, Expected:APPROVED/COMPLETE] , Type:StorageProvisionTimeout, RC:408<i>}

### 3. WorkerNode Network issues
1.  If you see following error in stroage pod logs, it means storage pod is not able to talk to {{ site.data.storage.slname.name }} API. It must be a networking issue. Post the error in `#armada-network` channel.<br>
    1.  {<i>"level":"error","ts":"2017-03-10T16:52:58Z","msg":"http_client_basic.go:89: Error occurred","error":"Get {{ site.data.storage.networkissue.link }}/rest/v3/{{ site.data.storage.slname.name }}_Location_Datacenter/getDatacenters: dial tcp: lookup api.{{ site.data.storage.slname.name }}.com on XX.XX.XX.XX:53: dial udp XX.XX.XX.XX:53: i/o timeout"<i>}.<br>
    2.  {<i>"level":"error","ts":"2017-03-10T16:52:58Z","msg":"http_client_basic.go:89: Error occurred","error":"Get {{ site.data.storage.networkissue.link }}/rest/v3/{{ site.data.storage.slname.name }}_Location_Datacenter/getDatacenters: dial tcp: lookup api.{{ site.data.storage.slname.name }}.com on XX.XX.XX.XX:53: dial udp XX.XX.XX.XX:53: i/o timeout"<i>}.<br>
&nbsp;
The above issue is due to egress settings in cruiser cluster.Please refer the point `#6` under `Allowing the cluster to access infrastructure resources and other services` section in the document `{{ site.data.storage.networkdoc.link }}`.
1.  The following is the possible network issue related with pod and cluster(mainly related with cluster setup issue). Post the error in `#armada-network` channel.
    2.  <i>E0316 15:46:19.744198 1 reflector.go:300] github.ibm.com/{{ site.data.storage.alchname.name }}-containers/armada-storage-file-plugin/vendor/k8s.io/client-go/tools/cache/reflector.go:94: Failed to watch *v1.PersistentVolume: Get https://XX.XX.XX.XX:443/api/v1/watch/persistentvolumes?resourceVersion=1&timeoutSeconds=431: dial tcp XX.XX.XX.1:443: getsockopt: connection refused<i>
    2.  <i>E0316 15:46:19.744690 1 reflector.go:300] github.ibm.com/{{ site.data.storage.alchname.name }}-containers/armada-storage-file-plugin/vendor/k8s.io/client-go/tools/cache/reflector.go:94: Failed to watch *v1beta1.StorageClass: Get https://XX.XX.XX.XX:443/apis/storage.k8s.io/v1beta1/watch/storageclasses?resourceVersion=216&timeoutSeconds=506: dial tcp XX.XX.XX.XX:443: getsockopt: connectionrefused<i>
    2.  <i>E0316 15:46:20.749712 1 reflector.go:199] github.ibm.com/{{ site.data.storage.alchname.name }}-containers/armada-storage-file-plugin/vendor/k8s.io/client-go/tools/cache/reflector.go:94: Failed to list *v1.PersistentVolume: Get https://XX.XX.XX.XX:443/api/v1/persistentvolumes?resourceVersion=0: dial tcp XX.XX.XX.XX:443: getsockopt: connection refused<i><br>
&nbsp;

### 4. Mounting issues
1.  If you get permission denied issues while write some file after execute to pod.
    2.  Please check if you expect the mountPath to be owned by specific user as per the image used to deploy pod. If that is the case then you need follow the documentation to resolve permission denied issue - `{{ site.data.storage.mountdoc.link }}`.
1.  If you see following error in describe pod, The issue is due to mounting.
    2.  FailedMount    MountVolume.SetUp failed for volume "" : mount failed: exit status 32
    2.  Please run the following  steps.
        3.  Ssh into the worker and try to see if manual mount works.<br>
        3.  Check from SL portal if that volume is available or deleted there. We can make sure it exists.<br>
        3.  Try to create a new PVC and see if its able to mount in the pod successfully. Then we can say its a issue with that single volume.<br>
&nbsp;
1.  If you see following error in storage pod logs, The authorization issue is due to subnet list is empty.
    2.  {<i>"level":"info","ts":"2017-04-11T14:42:50Z","msg":"{{ site.data.storage.slname.name }}_file_storage.go:332: **Doing AllowAccessFromSubnetList ..","StorageId":22553817,"SubnetIds":[]<i>}
    2.  {<i>"level":"info","ts":"2017-04-11T14:42:50Z","msg":"{{ site.data.storage.slname.name }}_file_storage.go:452: **Getting AllowedSubnets ..","StorageId":22553817<i>}
    2.  {<i>"level":"info","ts":"2017-04-11T14:42:51Z","msg":"{{ site.data.storage.slname.name }}_file_storage.go:343: Already Authorized subnets","subnetIds":[]<i>}
    2.  Please run the following  steps.
        3.  Please check the config map of subnet-config using following command.<br>
            `kubectl get cm subnet-config -n kube-system -o yaml`<br>
        3.  if the config map is not updated with subnets, post the error in `#armada-network` channel.<br>

## Investigation and Action

### **Steps**:

1.      Configure kube-client to access to customer cluster <br>
        1. Using {{ site.data.storage.bxname.name }} credential 
            1. `bx cs clusters.`
            1. `bx cs workers <clustername | cluster-id>`
            1. `bx cs cluster-config <cluster ID>`
            1. `export KUBECONFIG=<path>`
        1. Using clusterid
            1. Get the cluster id from Customer/Ticket and fetch the DC and CARRIER Name from “armada-xo”

            1. Get the IP details for Carrier master and log into the master node using SSO creds<br>

               `{{ site.data.storage.envrepo.link }}`


1.      List down All pvc<br>
        `kubx-kubectl <clusterid> get pvc --all-namespaces`


1.      Check the following steps if PVC is in pending state for more than 15 mins<br>
        1. Find Error message for your PVC
           2. View Error message from pvc describe<br>
              `kubx-kubectl <clusterid> describe pvc <pvc-name> -n <namespace>`<br>
           2. View Error message from Storage POD log<br>
              `kubx-kubectl <clusterid> get pods -n kube-system | grep ibm-file-plugin`<br>
              `kubx-kubectl <clusterid> logs -f ibm-file-plugin-xxxxxx -n kube-system`
        1. Check if the Storage Plugin and Classes availble on this cluster and User's PVC spec is correct<br>
           2. Check plugin and storage classes available in the cluster<br>
              `kubx-kubectl <clusterid> get pods -n kube-system | grep -E ibm-file-plugin|ibm-storage-watcher`<br>
              `kubx-kubectl <clusterid> get storageclasses | grep ibmc-file.`
           2. Check the PVC definition and the corresponding class file it refers to and Validate the size and iops specified in the PVC against the storage class<br>
              `kubx-kubectl <clusterid> get pvc <pvc-name> -n <name-space> -o yaml`<br>
              `kubx-kubectl <clusterid> get storageclass <storage-class-name-from-pvc> -o yaml`

        1. Check if its a Worker Node connectivity issue
           `Refer to section 3. WorkerNode Network issues below`
       
        1. Check if its a Wrong {{ site.data.storage.slname.name }} credential issue, follow the runbook [{{ site.data.storage.slname.name }} credentails issue](./armada-storage-{{ site.data.storage.slname.name }}-issue.html)
        
        1. Check if the PV creation Order is Placed and Creation is in Progress<br>
           <i>Look for a repetitive message in log : `Trying to see if storage provision has completed` at a regular interval.To see running logs from storage-plugin use the "-f" option as below</i><br>
           `kubx-kubectl <clusterid> logs -f ibm-file-plugin-xxxxxx -n kube-system`<br>
        
        1. Check for 15min Timeout and Possible View/Order Permission issue in that {{ site.data.storage.slname.name }} account<br>
           `Refer Below section {{ site.data.storage.slname.name }} account issues/section 4`

1.      Check the following steps if POD is Unable to mount the PVC
        1. Check for Subnet config Map contents and current worker node subnet details
           `kubectl get cm subnet-config -n kube-system -o yaml`<br>
        1. Look for the Authorization message for that Worker subnet after PV got created in Storage POD log


## Escalation Policy

For more help in searching the logs, please visit the [{{site.data.storage.armada-storage.comm.name}}]({{site.data.storage.armada-storage.comm.link}}) {{site.data.storage.commname.name}} channel.

If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by using the [{{site.data.storage.armada-storage.escalate.name}}]({{site.data.storage.armada-storage.escalate.link}}) PD escalation policy.

If you run across any armada-storage problems during your search, you can open a GHE issue for armada-storage [{{site.data.storage.armada-storage.name}}]({{site.data.storage.armada-storage.issue}}).

## Automation

None
