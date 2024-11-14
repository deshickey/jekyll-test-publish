---
layout: default
description: Creating COS/Key Protect Accounts
service: IKS
title: Creating COS/Key Protect Accounts
runbook-name: "Creating COS/Key Protect Accounts"
link: /create_cos_keyprotect_account.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
This runbook covers the general steps to procure a cloud object storage (COS) account or other accounts such as Key Protect Accounts. All requests _should_ come in the form of a GHE issue such as [this](https://github.ibm.com/alchemy-conductors/team/issues/3661) and should first be approved by the appropriate authority.

## Detailed Information
1. Sign into [IBM Cloud](https://cloud.ibm.com/)
1. Head to the Dashboard and look for a `Create resource` button.  
_(Make sure you are in the correct account before proceeding)_
1. Find `Object Storage` from the list, or use the search box
1. Gather information from the GHE issue in order to create the requested account type (and other details) with the requested name and in the requested resource group.
    - For Cloud Object Storage accounts, specify the "Standard" plan when naming the service unless the GHE issue says otherwise. 
    - Below is the general naming convention for accounts (service instances) and serviceIDs (created on command line)

```
Argonauts Resource Groups
dev
prestage
stage
prod
prodeu

Argonouts ServiceIDs
<microservice>-<resource group>[-region]
armada-deploy-dev
armada-deploy-prod-ap-south
armada-deploy-prodeu-eu-de

Argonauts Service Instances
<microservice>-<purpose>-<resource group>[-region]
armada-deploy-ectd-backups-prod-us-south (COS)
armada-pipeline-encryption-key-dev (KP)
armada-pipeline-cruiser-configs-prod-us-east (COS)
```

## Further Information

### Cloud Object Storage accounts
Generally speaking, after you have created a COS account you will likely create a bucket, service ID, access keys, and IAM policies.

- Buckets can be created from the IBM cloud console and generally don't have a naming convention.
- Keys and IAM policies can be created from the bx command line. Here is one example. 

```
service instance:
armada-deploy-ectd-backups-dev

bucket:
dev-south-iks-etcd-backups

service id
armada-deploy-dev
```

creating service id, apikey, and iam policy

```
bx iam service-id-create armada-deploy-dev

bx iam service-api-key-create coskey armada-deploy-dev --file armada-deploy-dev.apikey

bx iam service-policy-create armada-deploy-dev --service-name cloud-object-storage --service-instance armada-deploy-ectd-backups-dev --resource-type bucket --resource dev-south-iks-etcd-backups --roles Writer
```

### Key Protect accounts
[Here](https://cloud.ibm.com/docs/key-protect?topic=key-protect-getting-started-tutorial) is some general information about key protect accounts. 
