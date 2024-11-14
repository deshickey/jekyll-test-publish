---
layout: default
title: New IBM Cloud Logs instance
type: Informational
runbook-name: "IBM Cloud Logs new instance"
description: How and where to create IBM Cloud Logs instances for IKS
category: Armada
service: IBM Cloud Logs
tags: alchemy, armada, IBM Cloud Logs 
link: /IBM_Cloud_Logs_new_instance.html
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

IBM Cloud Logs is used by our services for storing logs.


## Detailed Information

We have several accounts.

### Accounts

We use the following accounts for IBM Cloud service that we create like IBM Cloud Logs / SysDig / KeyP etc.  

| Pipeline | Account |
| -- | -- |
| development and prestage |  1186049 - Dev Containers |
| stage | 1858147 - Argo Staging |
| production | 1185207 - Alchemy Production's Account |

### Resource Groups
There are resource groups in each account for the type of service we are going to create. Same follows for IBM Cloud Logs.

| Account | Resource group |
| -- | -- |
| 1186049 - Dev Containers | `LogDNA-DevPrestage` |
| 1858147 - Argo Staging | `LogDNA-stage` |
| 1185207 - Alchemy Production's Account | `LogDNA-Prod-<region>` |

_Production environment should have a resource group per region_

Resource groups must be created via the [access-group-config](https://github.ibm.com/argonauts-access/access-group-config) terraform code.

1. Create `LogDNA-Prod-<REGION>` (e.g. `LogDNA-Prod-eu-es`) resource group via access-group-config repo [Example](https://github.ibm.com/argonauts-access/access-group-config/pull/275)

### Provisioning key
Create an issue at https://github.ibm.com/activity-tracker/customer-issues/issues  

Title:
```
New provisioning key for <region> region
```
Issue description:
```
## Request for IBM Cloud Logs provision key
Service Full Name: IBM Cloud Kubernetes Service

Service CRN Name: crn:v1:bluemix:public:containers-kubernetes
  
Contact:
  
- Name: <your name>
- Email: <your email>
- Slack: <your slack user>
Regions (us-south, eu-de): <region>
```

The provisioning key will be emailed to you. Store it in the Thycotic [LogDNA folder](https://pimconsole.sos.ibm.com/SecretServer/app/#/folders/8541).

### IBM Cloud Logs Instance
Once you recieve IBM Cloud Logs provision key from above issue, create IBM Cloud Logs instances with following commands. Make sure you logged in with correct account.  
```
ibmcloud account show
```

Note in particular that `<existing region>` will be an appropriate existing region, as the new region will not have IBM Cloud Logs enabled yet (circular dependency). For example if it's a new region in the EU, `eu-de` may be used. Use an appropriate region.

Note that currently we are using the `7-day` plan.

Create `kubx-master-microservices-<region>-STS` instance. 
```
ibmcloud resource service-instance-create kubx-master-microservices-<region>-icl logdna 7-day <existing region> -p '{"service_supertenant": "containers-kubernetes" , "provision_key": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"}' -g LogDNA-Prod-<region>
```

You will get the ID and `CRN` of `kubx-master-microservices-<region>-STS` as a result of this command. Make a note of the `CRN`. We will use this to create `kubx-master-microservices-<region>-ATS`.

Create `kubx-master-microservices-<region>-ATS` instance. 
```
ibmcloud resource service-instance-create kubx-master-microservices-<region>-ATS logdnaat 30-day <existing region> -p '{"service_supertenant": "containers-kubernetes" , "associated_logging_crn": "<crn of previously created kubx-master-microservices-<region>-STS>", "provision_key": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"}' -g LogDNA-Prod-<region>
```

### IBM CLoud Logs Access Groups

Access groups must be created via the [access-group-config](https://github.ibm.com/argonauts-access/access-group-config) terraform code, and roles assigned via the [role-config]() repo.

_Note that creating the **access groups** and assigning roles must be done together - we have alerts for when an access group does not exist in role-config._

Create access policies for `LogDNA-Prod-<REGION>` (e.g. `LogDNA-Prod-eu-es`) resource group via

1. access-group-config repo (create the access groups) [Example](https://github.ibm.com/argonauts-access/access-group-config/pull/274)
1. role-config repo (assign roles) [Example](https://zenhub.ibm.com/workspace/o/argonauts-access/role-config/issues/561)
