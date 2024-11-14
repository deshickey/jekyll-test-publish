---
layout: default
title: Disabling a cluster master deployment
type: Informational
runbook-name: "Disabling a cluster master deployment"
description: How to disable a cluster master deployment
category: armada
service: armada-deploy
tags: armada, master
link: /armada/armada-deploy-disable-master.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to scale down a cluster master deployment for cluster(s) reported in abuse case notification when requested by IBM Cloud Abuse department.

## Detailed Information

The IBM Cloud Abuse department is authorized to enforce the Acceptable Use Policy by accepting and addressing actionable reports and taking appropriate, timely action to remediate issues through open communication with clients and application of administrative action where necessary to disable live threats as required by SEC050 Abuse.

A GHE issue should have been raised by the IBM Cloud Abuse department. An SRE is reached out to disable the master deployment of the cluster in Abuse Notification by scaling down the master deployment.

### Look up owner email
Abuse team would ask to check details of cluster in the notification such as owner Email. 
1. Use XO to find an owner email

```
@xo cluster <clusterID> show=all

    "Region": "us-south",
    "ClusterID": "ch17dhpd0e9253hh1b3g",
    "Name": "mhalai-iks-classic",
    "NameCreateOnly": false,
    "RBACNamespaces": "true",
    "DesiredRegionalRegistryToken": null,
    "DesiredIntRegistryToken": null,
    "DesiredCreatedDate": "2023-04-21T11:43:03+0000",
    "DesiredModifiedDate": "2023-04-21T11:43:03+0000",
    "IsPaid": "true",
    "OrderPortableSubnet": "true",
    "OwnerEmail": "E@N@C@R@Y@P@T:47998ac029ed4ca69cf807338b7dbd2e:2:7667b4",
    "IsIBMer": "true",
 ```
 
2. The ownerEmail from XO is encrypted. The decrypted value can be obtained by accessing COS bucket.
3. With GP VPN on, loginto Cloud UI.
4. go to 1185207 - Alchemy Production
5. Search for COS Instance: armada-xo-prod, and go to a region specific bucket. 

`If  cluster is in us-south, find a bucket: armada-xo-us-south-prod`

6. Download the object matching timestamp that XO query was run.
7. retrive decrypted owner email from downloaded COS object. 
```
    "Region": "us-south",
    "ClusterID": "ch17dhpd0e9253hh1b3g",
    "Name": "mhalai-iks-classic",
    "NameCreateOnly": false,
    "RBACNamespaces": "true",
    "DesiredRegionalRegistryToken": null,
    "DesiredIntRegistryToken": null,
    "DesiredCreatedDate": "2023-04-21T11:43:03+0000",
    "DesiredModifiedDate": "2023-04-21T11:43:03+0000",
    "IsPaid": "true",
    "OrderPortableSubnet": "true",
    "OwnerEmail": "Mayur.Halai@ibm.com",
    "IsIBMer": "true",
```
    

### armada-master-scale-down job

1. Update [allowlist for Jenkins](https://github.ibm.com/alchemy-containers/pd-tools/blob/master/allowlist-jenkins/armada-master-scale-down.txt) to include the cluster for connectivity.

Syntax:

`# Allowlist syntax: CLUSTER_ID FOR_CANCELED_ACCOUNT_DELETION FOR_UNSUPPORTED_CLUSTER_DELETION FOR_DATACENTER_CLOSURE`

Example Syntax:

`c5mpcl8d0f6ollrleaig false false false`

2.  Create an ops prod train
```
Squad: SRE
Title: armada-deploy-master-scale-down
Environment: <REGION>
Details: Cluster <cluster-id> in <region> is reported in Abuse notification. Immediate action is required to disable live threats as required by SEC050. GHE issue: <GHE Issue link>
Risk: high
PlannedStartTime: now
PlannedEndTime: now + 1h
Ops: true
BackoutPlan: manually refresh master deployment
```

3. Run [armada-master-scale-down](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-master-scale-down/)
To run this job you need to provide:
- CLUSTER_ID : cluster id
- FOR_CANCELED_ACCOUNT_DELETION Leave it unchecked
- FOR_UNSUPPORTED_CLUSTER_DELETION Leave it unchecked
- FOR_DATACENTER_CLOSURE Leave it unchecked
- PROD_TRAIN_REQUEST_ID : Approved prod train number

4. Upload successful Jenkins Job execution Console output to GHE issue that was created by IBM Cloud Abuse Department.


### Refresh Master Deployment
If scaled down master deployment needs to be reverted, the customer needs to refresh master deployment. 

```
ibmcloud ks cluster master refresh --cluster <CLUSTER-ID>
```

This needs to be driven by the customer. When requested by Abuse team, this command needs to be shared to the GHE issue. The Abuse team would communicate with customer. 


## Escalation Policy

Reach out to the #conductors-for-life channel in slack for team help
