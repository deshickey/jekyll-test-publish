---

layout: default
title: How to Enable KeyProtect on tugboat
type: Informational
runbook-name: "enable KMS on tugboat"
description: How to enable KMS on tugboat
service: conductors
tags: sre 
link: /sre_keyprotect_enableKMS_tugboat.md
parent: Armada Runbooks

---

Informational
{: .label }

## Overview 
- This document describes the procedure to enable KMS (KeyProtect) on Tugboat. 

## Detailed Information 
- As part of the FS Cloud requirements, all tugboats need to have KMS Enabled. KMS is a key protect service that will encrypt all Kubernetes Secrets using a KMS key. It provides an extra layer of security so that the kubernetes secrets are secure. As part of the requirements, KMS Key also will needs to be enveloped and rotated every 90 days, this is done automatically in the production account.
- KeyProtect KMS instances which we are storing the key can be found under the resource group: `tugboat-keyprotect`. On each region, there should be a key that is to be used for that region. Ensure that the tugboat for that region is using their own region. Separate for EU-DE, EU-DE has its own KP instances and its own key.
- Enabling KeyProtect (KMS) on Tugboat is done through JenkinsJob. Jobs: [Jenkins](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/tugboat/job/kms-enablement/build?delay=0sec)


## Further Information 
To run the JenkinsJob - kms-enablement, open the Jenkins link above and fill in the following fields.

There are three types of KMS Enablement that is available on this Jenkins Job, you can enable KMS based on per region, based on Cluster ID or based on the Tugboat Name. Pick one by selecting the type.

_Note: for tugboats, we can deploy via `Type = cluster and Cluster_ID = id`_

To check the name of KPInstance and ROOTKEY, go to Argonauts Production and filter resource list based on `tugboat-keyprotect` group.

Click into the instance, e.g. `keyprotect-tugboat-eu-de` for Frankfurt, and see the rootkey `Name` where `Type = root`, e.g. `eu-de-tugboat-crk-key`.

1. `Branch*` : set to Master
 
2. `Type*` :  
    - Region
    - Tugboat 
    - Cluster 
3. `Cluster_ID`: 
    - Supply the Cluster_ID if you select Cluster as the type. Otherwise, just leave blank.
4. `Tugboat`: 
    - Supply the tugboat name if you select tugboat as the type. Otherwise, just leave blank.
5. `Region*`:
    - Supply the region if you select region as the type. Otherwise, leave default.
6. `Pipeline_env*`:
    - Choose prod if you are enabling KMS for production.
7. `KPInstance*`:
    - Is the KeyProtect Instance name that you are targetting. You can find the list of name under tugboat-keyprotect resource group. For example: keyprotect-tugboat-us-south.
8. `ROOTKEY*`:
    - Refers to the rootkey name that you are targetting. Note that each region should have its own root key. For example `us-south-tugboat-crk-key`
9. DEBUG: 
    - leave blank - only use for debugging purposes.
10. `CFS_TRAIN_ID`
    - CFS train ticket ID - For deployments in Prod/Stage

Example train template (`CHG5656077`):

```
Squad: conductors
Title: enable kms on prod-eu-es-e-carrier100
Environment: eu-es
Details: |
  enable kms on prod-eu-es-e-carrier100
  BOM issue: https://github.ibm.com/alchemy-conductors/new-environments/issues/1363
  Job https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/tugboat/job/kms-enablement/
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 2h
Ops: true
BackoutPlan: manual repair by conductor
```

On successful completion, JenkinsJob will print: "Completed ProcessFinished" Search for the terms and ensure that "All KMS has been enabled".
