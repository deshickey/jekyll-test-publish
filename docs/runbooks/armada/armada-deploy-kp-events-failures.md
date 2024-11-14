---
layout: default
description: How to handle armada-kp-events failures.
title: armada-deploy - How to handle failures for key protect events
service: armada-kp-events
runbook-name: "armada-deploy - How to handle failures for key protect events"
tags: alchemy, armada-deploy, key-protect, kms
link: /armada/armada-deploy-kp-events-failures.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle alerts which report that the microservice `armada-kp-events` is having an issue processing requests. More information about the microservice can be found in the [armada-kp-events git repo](https://github.ibm.com/alchemy-containers/armada-kp-events).

The design for Key Protect BYOK can be found in the Architecture Concept Document [Architecture Concept - Key Protect BYOK support](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/concept-kp-byok.md).

## Example Alerts

[Example Alert](https://ibm.pagerduty.com/incidents/P1AH22I)
~~~
Labels:
 - alertname = ArmadaKPEventsProcessingErrors
 - CRN = crn:v1:bluemix:public:containers-kubernetes:eu-de:a/ACCOUNT_ID:CLUSTER_ID::
 - alert_key = armada-kp-events/armada_kp_events_process_failures
 - alert_situation = armada_kp_events_process_failures
 - carrier_name = prod-fra02-carrier105
 - carrier_type = hub-tugboat-etcd
 - crn_cname = bluemix
 - crn_ctype = public
 - crn_region = eu-de
 - crn_servicename = containers-kubernetes
 - crn_version = v1
 - service = armada-kp-events
 - severity = warning
 - tip_customer_impacting = false
Annotations:
 - description = armada-kp-events service has experienced 2.246975 event processing failures for resource crn:v1:bluemix:public:containers-kubernetes:eu-de:a/ACCOUNT_ID:CLUSTERID:: in the last 5 mins
 - runbook = https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-deploy-kp-events-failures.html
 - summary = armada-kp-events is experiencing consistent event processing failures for a particular cluster resource
Source: https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier105/prometheus/graph?g0.expr=sum+by%28CRN%29+%28delta%28armada_kp_events_status%7Bstatus%3D%22failed%22%7D%5B5m%5D%29%29+%3E+0&g0.tab=1
~~~

## Actions to take

1. Identify cluster with the issue. This can determined from the alert or the prometheus query.
1. Determine if the cluster has a kms_update master operation failure by searching the [#armada-deploy-failure](https://ibm-argonauts.slack.com/archives/C9XGSR292) channel for the cluster id. If this is the case, follow the runbook for [diagnosing master operation failures](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-deploy-operation-failures.html).
1. Determine the error for the microservice by searching the [#armada-kp-events-alerts](https://ibm-argonauts.slack.com/archives/C018KJ6NW4A) slack channel for the cluster id.
1. If the failure is in the eu-fr2 region in September/October 2024, it's possible this is related to key migration. See [EU-FR2 Key Migration section](#eu-fr2-key-migration) for additional details and debug information.
1. If the error matches "error completing request, the cluster is busy with another KMS action," then the requested action cannot be completed until the prior action is completed. This is most likely to occur when a kms_update operation fails and the user has requested to rotate/enable/disable their root key. In this case, the kms_update failure needs to be resolved first using the runbook for [diagnosing master operation failures](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-deploy-operation-failures.html). If this is not the case, then likely the service just needs some time to complete the prior operation. In this case, the alert can be snoozed for 2 hours.
1. If the error matches "Error finding ETCD info for the cluster" then the microservice cannot find the record of the cluster in ETCD. In this rare situation, either ETCD is unavailable or the cluster has been deleted and the associated ETCD data has since been expunged.
  - If ETCD is not working properly, then resolve the ETCD issue first.
  - If ETCD is working properly, then the cluster data does not exist in ETCD because the cluster was deleted and the data has since been expunged. Search the [#armada-deploy-alerts](https://ibm-argonauts.slack.com/archives/C54FY4EKG) channel to verify the cluster was deleted. This error is caused by an orphan KMS provider key registration which did not get properly deleted when the cluster was deleted. Since the key is still linked to the cluster, the `armada-kp-events` microservice still receives notifications for any actions against the linked key. To handle this case, create an issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository and snooze the alert for 12 hours. The alert should resolve automatically after that time.

Additional information about the failure can be found by reviewing the microservice logs for the App `armada-kp-events` in LogDNA. The logs can also be viewed by going to the hub directly and looking for the `armada-kp-events` pod in the `armada` namespace.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create an issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.

## EU-FR2 Key Migration
* BNPP is migrating keys used for encryption from Key Protect to Hyper Protect Crypto Service (HPCS)
* Customer will manage both manual and automated parts of the migration
* No downtime expected

### Potential Issues
1. Key migration blocked - Key events are handled sequentially via hyperwarp notifications. Some migration actions must wait until the prior action is completed. Therefore, it is likely we will see ArmadaKPEventsProcessingErrors as the migration events are handled. See [ArmadaKPEventsProcessingErrors](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-deploy-kp-events-failures.html) for more info.
1. KMS_UPDATE master operations may fail due to webhook issues. See the [cloud docs](https://cloud.ibm.com/docs/openshift?topic=openshift-webhooks_update) and [this git issue](https://github.ibm.com/alchemy-containers/armada-update/issues/5306) for more info.
1. Key migration fails due to missing service authorization policies. See the _Required Service Authorizations_ section.
1. Key migration fails due to migration intent incorrectly specified. See the _General Debugging_ section.


### General Debugging
1. Identify the cluster and/or worker pool being migrated.
1. See if the cluster passed its last master operation. If it failed, debug as a normal master operation failure.
1. Find the `CorrID` for the failure in the (armada-kp-events slack channel)[https://ibm.enterprise.slack.com/archives/C018KJ6NW4A].
1. Use the `CorrID` to search in LogDNA (microservice carrier) for an error. If the `CorrID` is not found, you can try looking specifically at the `armada-kp-events` application logs.
1. Look for any error messages to identify the underling issue.
  a. _check cluster state_ error message indicates that the cluster is not in a valid state for key migration. For example, it might be deleted or busy with another KMS operation. Suggestion is to look at the current state of the cluster and verify it is healthy and that the master is not stuck in another master operation.
  b. _check key in use_ error message indicates that the migration intent source key is not in use by the cluster. Suggestion is to look at the migration intent and verify it specifies the correct source CRK.
  c. _get key info from ghost_ error message indicates that our service does not have the proper service authorization to read the key. Suggestion is to have the customer look at the service authorizations in place and verify they are correct.
  d. _check key status for migration_ error message indicates that the key is not in a valid state for migration (it might be disabled for example). Suggestion is to have the customer verify the key is enabled.
1. Look at the log output to find the migration intent target and source key CRNs. Note these CRNS in any tickets or requests to other teams for additional information.
1. For failed authorization requests, the likely issue is with service authorization policies. Reach out in the [iam-adopters](https://ibm.enterprise.slack.com/archives/C0NLB2W3B) slack channel. Post the correlation ID for the failed request and ask about why the request failed (likely missing service authorization policy).
1. For server side errors related to Key Protect, reach out in the [key-protect](https://ibm.enterprise.slack.com/archives/C1UB18PQB) slack channel.
1. For server side errors related to HPCS, reach out in the [hp-crypto-kms](https://ibm.enterprise.slack.com/archives/CFFC7M3B3) slack channel.


### Containers Key Migration Impact
Data Plane:
* Keys used to encrypt cluster secrets. The key is stored in ETCD with the cluster.
* Keys used to encrypt VPC worker nodes. The key is stored in ETCD with the worker pool.
* Keys used to encrypt persistent storage attached to a cluster. The key is stored in the storage secret or customized storage class configuration.
  * Block Storage.
  * Portworx Storage


### Required Service Authorizations

#### Service ID and Names

| Service ID            | Service Name                 | Alias |
| --------------------- | ---------------------------- | ----- |
| containers-kubernetes | IKS & ROKS                   |       |
| server-protect        | Block Storage                | Block |
| kms                   | Key Protect                  |       |
| hs-crypto             | Hyper Protect Crypto Service | HPCS  |

#### Accounts

| Account   | Services Hosted                            | Purpose                                                                                  |
| --------- | ------------------------------------------ | ---------------------------------------------------------------------------------------- |
| account-1 | containers-kubernetes, kms, server-protect | Segmentation of clusters within eu-fr2. Multiple accounts like this exist in the region. |
| account-2 | server-protect                             | IBM SRE account where VPC workers are provisioned                                        |
| account-3 | hs-crypto                                  | Host KMS Hyper Protect Crypto Service                                                    |

_account-1 and account-3 are examples of accounts in the region. account-2 will always be bab556e1c47446ef8da61e399343a3e7 for eu-fr2_

#### Required Service Authorizations Before Migration

| ID | Subject               | Subject Account | Target Service | Created in Account | Key-Ring | Notes                                                 |
| -- | --------------------- | ----------------| -------------- | ------------------ | -------- | ----------------------------------------------------- |
| 1  | containers-kubernetes | account-1       | kms            | account-1          | no       | IKS Cluster encrypted secrets support                 |
| 2  | server-protect        | account-2       | kms            | account-1          | no       | IKS Cluster encrypted worker support, created by IKS  |
| 3  | server-protect        | account-1       | kms            | account-1          | no       | Encrypted block storage support                       |
| 4  | _various_             | account-1       | kms            | account-1          | no       | One for each required service (not IKS or Block)

#### Required Service Authorizations After Migration

| ID | Subject               | Subject Account  | Target Service | Created in Account | Key-Ring | Notes                                                |
| -- | --------------------- | ---------------- | -------------- | ------------------ | -------- | ---------------------------------------------------- |
| 5  | containers-kubernetes | account-1        | hs-crypto      | account-3          | yes      | IKS Cluster encrypted secrets support                |
| 6  | server-protect        | account-2        | hs-crypto      | account-3          | yes      | IKS Cluster encrypted worker support, created by IKS |
| 7  | server-protect        | account-1        | hs-crypto      | account-3          | yes      | Block storage support & VPC worker migration         |
| 8  | Resource Group (*)    | account-1        | hs-crypto      | account-3          | yes      | All Services except IKS and Block                    |

#### Required Service Authorizations Matrix

| Scenario               | Before Migration | During Migration | After Migration | Notes
| ---------------------- | ---------------- | ---------------- | --------------- | ----------------------------------------------------------------- |
| IKS Secret Encryption  | 1                | 1, 5             | 5               |                                                                   |
| IKS Encrypted Worker   | 2                | 2,3,6            | 6               | Service authorization for #6 is required to a Block Storage issue |
| Attached Block Storage | 3                | 3,7              | 7               |                                                                   |

### Migration expectations

Keys used to encrypt cluster secrets
* Migration is managed by the user via migration intent on the source key.
* Migration time per cluster is expected to be approximately 20-40 minutes.
* Migration attempts will be retried for 2 hours before failing.
* Migration attempts can be retriggered by requesting a sync event on the source key.
* Prior to migration, a webhook test can be done to verify no issues will be encountered during the master pods updates.
* If multiple migrations are triggered at once, clusters and worker pools in the same account will migrate in sequence and clusters and worker nodes in different accounts will migrate in parallel.
* Recommendation is to do key migrations one at a time or in small batches.
* During the migration, the cluster masters will update in sequence which will handle the re-encryption of all cluster secrets.
* No service interruption is expected.

Keys used to encrypt VPC worker node boot volumes
* Migration is managed by the user via migration intents on the source key.
* Migration time per worker node boot volume is expected to be less than 2 minutes.
* Migration attempts will be retried for 2 hours before failing.
* Migration attempts can be retriggered by requesting a sync event on the source key.
* If multiple migrations are triggered at once, clusters and worker nodes in the same account will migrate in sequence and clusters and worker nodes in different accounts will migrate in parallel.
* Recommendation is to do key migrations one at a time or in small batches.
* During migration, a new authorization policy will be created allowing Cloud Block Storage access to Hyper Protect Crypto Services specific to an account owned by IBM where the encrypted VPC worker nodes are located. See the Service Authorization's section for more info.
* No service interruption is expected.

Keys used to encrypt Block Storage attached to a cluster
* Migration is managed by the user via manual update of the custom storage class configuration or the kubernetes storage secret.
* Migration time for Block Storage is expected to be less than 2 minutes.
* Prior to adding any new Block Storage, the Key Protect key CRN must be replaced with the Hyper Protect Crypto Service key CRN in the custom storage class or Kubernetes secret depending on how it was originally configured. The encryption key CRN for both the storage class and Kubernetes secret is defined via the parameter "encryptionKey". More details can be found in the cloud doc: https://cloud.ibm.com/docs/containers?topic=containers-vpc-block#vpc-block-encryption
* No service interruption is expected.

Keys used to encrypt Portworx
* Portworx to handle migration.

### Attached storage migration

If the user has defined either a [custom storage class configuration or kubernetes secret for storage](https://cloud.ibm.com/docs/containers?topic=containers-vpc-block#vpc-block-encryption), they will need to update the key CRNs to point to the target key prior to ordering additional storage.

#### Steps to Update Customized Storage Class Configuration

1. View the existing Block Storage Class
2. Save the existing Block Storage Class to a file
3. Edit the file and replace the encryption key CRN with the new encryption key CRN
4. Delete the existing Block Storage Class
5. Apply the new Block Storage Class
6. View the new Block Storage Class

```
rkcradic@rmac ~/temp> kubectl get StorageClass block -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"block"},"parameters":{"billingType":"hourly","csi.storage.k8s.io/fstype":"ext4","encrypted":"true","encryptionKey":"KEY_CRN_1","generation":"gc","profile":"5iops-tier","resourceGroup":"","tags":"","zone":""},"provisioner":"vpc.block.csi.ibm.io"}
  creationTimestamp: "2023-10-10T18:26:42Z"
  name: block
  resourceVersion: "53137"
  uid: 86594c90-923b-47f9-970f-52eeeaab65cd
parameters:
  billingType: hourly
  csi.storage.k8s.io/fstype: ext4
  encrypted: "true"
  encryptionKey: KEY_CRN_1
  generation: gc
  profile: 5iops-tier
  resourceGroup: ""
  tags: ""
  zone: ""
provisioner: vpc.block.csi.ibm.io
reclaimPolicy: Delete
volumeBindingMode: Immediate
rkcradic@rmac ~/temp [1]> kubectl get StorageClass block -o yaml > block.yaml
rkcradic@rmac ~/temp> vi block.yaml
rkcradic@rmac ~/temp> kubectl delete StorageClass block
storageclass.storage.k8s.io "block" deleted
rkcradic@rmac ~/temp> kubectl apply -f block.yaml 
storageclass.storage.k8s.io/block created
rkcradic@rmac ~/temp> kubectl get StorageClass block -o yaml 
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"creationTimestamp":"2023-10-10T18:26:42Z","name":"block","resourceVersion":"53137","uid":"86594c90-923b-47f9-970f-52eeeaab65cd"},"parameters":{"billingType":"hourly","csi.storage.k8s.io/fstype":"ext4","encrypted":"true","encryptionKey":"KEY_CRN_2","generation":"gc","profile":"5iops-tier","resourceGroup":"","tags":"","zone":""},"provisioner":"vpc.block.csi.ibm.io","reclaimPolicy":"Delete","volumeBindingMode":"Immediate"}
  creationTimestamp: "2023-10-10T18:33:20Z"
  name: block
  resourceVersion: "53396"
  uid: ae520722-340d-41f3-a69b-6b5a1876e6ce
parameters:
  billingType: hourly
  csi.storage.k8s.io/fstype: ext4
  encrypted: "true"
  encryptionKey: KEY_CRN_2
  generation: gc
  profile: 5iops-tier
  resourceGroup: ""
  tags: ""
  zone: ""
provisioner: vpc.block.csi.ibm.io
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

#### Steps to Update Block Storage Secret

1. View the existing Block Storage Secret
2. Edit the Block Storage Secret and replace the base64 encoded key CRN with the new
base64 encoded key CRN.
3. View the updated Block Storage Secret

```
rkcradic@rmac ~/temp> kubectl get secret block -o yaml
apiVersion: v1
data:
  encrypted: dHJ1ZQ==
  encryptionKey: a2V5Cg==
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"encryptionKey":"a2V5Cg=="},"kind":"Secret","metadata":{"annotations":{},"name":"block","namespace":"default"},"stringData":{"encrypted":"true"},"type":"vpc.block.csi.ibm.io"}
  creationTimestamp: "2023-10-10T18:10:51Z"
  name: block
  namespace: default
  resourceVersion: "52525"
  uid: 0f18e522-5cc7-4a72-8c1a-037def424013
type: vpc.block.csi.ibm.io
rkcradic@rmac ~/temp> kubectl edit secret block
secret/block edited
rkcradic@rmac ~/temp> kubectl get secret block -o yaml
apiVersion: v1
data:
  encrypted: dHJ1ZQ==
  encryptionKey: a2V5Mgo=
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"encryptionKey":"a2V5Cg=="},"kind":"Secret","metadata":{"annotations":{},"name":"block","namespace":"default"},"stringData":{"encrypted":"true"},"type":"vpc.block.csi.ibm.io"}
  creationTimestamp: "2023-10-10T18:10:51Z"
  name: block
  namespace: default
  resourceVersion: "52671"
  uid: 0f18e522-5cc7-4a72-8c1a-037def424013
type: vpc.block.csi.ibm.io
```

### Webhook validation

When keys that are used for secret encryption are migrated, the master pod definitions will be updated which require a rolling master update. As with patch updates, we have seen an increased number of these operations fail due to [webhook issues](https://cloud.ibm.com/docs/openshift?topic=openshift-webhooks_update). The following outlines a process by which webhooks can be tested in advance of a key migration.

Run the following commands to verify that the webhooks will not cause an issue. If these commands fail, then the key migration will likely hit an issue. Note, the namespace, `ibm-system`, should be changed to match a namespace where secrets are stored.

```
kubectl label ns ibm-system ibm-cloud.kubernetes.io/webhook-test-at="$(date -u +%FT%H_%M_%SZ)" --overwrite
kubectl run webhook-test --image registry.ng.bluemix.net/armada-master/pause:3.10 -n ibm-system
kubectl delete pod -n ibm-system webhook-test
kubectl create secret generic -n ibm-system webhook-test --from-literal=webhook=test
kubectl delete secret -n ibm-system webhook-test
```
