---
layout: default
description: This runbook covers the issues with the  portworx catalog installation
title: portworx-Install-portworx_install_issues
service: portworx
category: armada
runbook-name: "install-portworx_install_issues"
tags: portworx, portworx-install, catalog, portworx enterprise, catalog install
link: /armada/porworx-install_issues.html
type: Troubleshooting
grand_parent: Armada Runbooks
parent: Armada
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains some useful trouble shooting tips to recover from the issues with portworx catalog install.

## Example Alerts

None

## Investigation and Action

- To access the portworx services from catalog, click the below link.

   https://cloud.ibm.com/resources
   1. Click on **services** tab to access the installed portworx services.

- To see the information about failed service.
   1. Once the service list is displayed, click on the tab **Failed**.
   2. It will pop up info about failed service.

- How to see the error log about the failed service.
   1. Once the service list is displayed, click on the tab "Failed".
   2. Pop up will appear and display info about failed service.
   3. Click on the **(i)** icon  between **Failed** and **View cloud status** tabs to see failure info.

- How to verify the licencing of the portworx cluster.

    Access the one of the worker node and run the following command to see the licence info

   ```
   sh-4.4# /opt/pwx/bin/pxctl license list
   DESCRIPTION                                             ENABLEMENT                      ADDITIONAL INFO
   Number of nodes maximum                                            1000
   Number of volumes per cluster maximum                             16384
   Volume capacity [TB] maximum                                         40
   Node disk capacity [TB] maximum                                     256
   Node disk capacity extension                                        yes
   Number of snapshots per volume maximum                               64
   Number of attached volumes per node maximum                         256
   Storage aggregation                                                 yes
   Shared volumes                                                      yes
   Volume sets                                                         yes
   BYOK data encryption                                                yes
   Limit BYOK encryption to cluster-wide secrets                        no
   Resize volumes on demand                                            yes
   Snapshot to object store [CloudSnap]                                yes
   Number of CloudSnaps daily per volume maximum                     unlim
   Cluster-level migration [Kube-motion/Data Migration]                yes
   Disaster Recovery [PX-DR]                                           yes
   Autopilot Capacity Management                                        no                 feature upgrade needed
   OIDC Security                                                       yes
   Bare-metal hosts                                                    yes
   Virtual machine hosts                                               yes
   Product SKU                                             PX-Enterprise IBM Cloud DR      expires in 1174 daysi
   ```


## Issues covered by this runbook.

- Portworx installation form catalog fails.

  **Error:**
   ```
   "Error: cannot re-use a name that is still in use"
   ```
   **Resolution:**
    1. The above error is due to the previous helm installation of the portworx is not cleaned up properly.
    2. Use the following command to see the existing helm release.

   ```
   root@muraliVM1:~/portworx# helm ls
   NAME            NAMESPACE       REVISION        UPDATED                                 STATUS  CHART           APP VERSION
   portworx        default         1               2021-01-20 01:13:29.825491447 +0000 UTC failed  portworx-1.0.22 2.6.1
   root@muraliVM1:~/portworx#`
   ```
    Use the following command to remove the portworx helm release.
   ```
   helm delete portworx
   ```
    To remove the exisitng portworx installation including the portworx services use

    https://github.com/IBM/ibmcloud-storage-utilities/tree/master/px-utils/px_cleanup

- If the px-hook-etcd-preinstall-xxxxx pod struck in container creating stage

  **Error:**  
   1. Check the describe of the px-hook-etcd-preinstall-xxxxx.
   2. If the following error is seen in the pod describe output, then this is due to etcd certs are not available in the cluster

   ```
   Normal   Scheduled    <unknown>       default-scheduler  Successfully assigned kube-system/px-hook-etcd-preinstall-772rk
                                                             to 10.216.8.198
   Warning  FailedMount  13s (x10 over 4m23s)  kubelet, 10.216.8.198  MountVolume.SetUp failed for volume "etcdcerts" :
                                                                       secret "px-etcd-certs" not found
   Warning  FailedMount  7s (x2 over 2m20s)    kubelet, 10.216.8.198  Unable to attach or mount volumes:
                                                unmounted volumes=[etcdcerts],unattached volumes=[default-token-vj7l9 etcdcerts]:
                                                timed out waiting for the condition
   ```

   **Resolution:**

     Create the secret px-etcd-certs using the below doc.

     https://test.cloud.ibm.com/docs/containers?topic=containers-portworx#portworx-kvdb

- If the px-hook-etcd-preinstall-xxxxx  pod  struck is in error state

   **Error:**  

     Check the logs of the px-hook-etcd-preinstall-xxxxx pod

   ```
   root@muraliVM1:~/portworx# kubectl logs px-hook-etcd-preinstall-8h5gk -n kube-system
   Initializing...
   Verifying if the provided etcd url is accessible:
   https://5e6d4eba-4474-45a1-b2e2-398c434161fb.blrrvkdw0thh68l98t20.databases.appdomain.cloud:32198
   Verifying connectivity to secure etcd... The ca cert needs to be at the location /etc/pwx/etcdcerts/ca.pem
   Response Code: 000
   Incorrect ETCD URL provided. It is either not reachable, is incorrect or
   does not have the tls certificates placed in the right directory(if this is the case
   please validate the manner to provide certs
   to Portworx on docs.portworx.com)...
   root@muraliVM1:~/portworx#
   ```

   **Resolution:**

     The issue can be with etcd url or the etcd secrets follow the below doc to create the etcd configuration

     https://test.cloud.ibm.com/docs/containers?topic=containers-portworx#portworx-kvdb

- If the volume creation is failing with licence error

   **Error:**  
   ```
   Failed to provision volume with StorageClass "xxx-xxx-xxxx": rpc error: code = Internal desc = Failed
   to create volume: Volume (Name: pvc-eadcd4bc-625d-4f45-9a91-bc5c3f587625)
   create failed: Feature upgrade needed.Licensed maximum reached for 'VolumeSize'
   feature (allowed 0 GiB, requested 100 GiB)
   ```

   **Resolution:**
    1. The above issue is due to the portworx service  was deleted  from the catalog.
    2. When the portworx service get deleted, the licence will be expired and billing will be stopped.
    3. This raises issues in PVC creation also.

     Follow the below steps to recover from the above issue

    1. Use the following command to remove the portworx helm release

   ```
   helm delete portworx
   ```
    2. Re-provision the portworx again from the catalog with same parameters but with different portworx cluster name


###  NOTE: If  the issue is not listed above or the issue is not resolved, please contact portworx support

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
