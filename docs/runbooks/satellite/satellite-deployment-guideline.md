---
layout: default
description: Instruction how to deploy Satellite services
service: satellite
title: Satellite deployment guidelines
runbook-name: "Satellite deployment guideline"
link: /satellite-deployment-guideline.html
type: Operations
grand_parent: Armada Runbooks
parent: Satellite
---

Ops
{: .label .label-green}

## Overview

This runbook is to provide the instruction how to deploy each Satellite service. There are common services to be prepared along with resource groups and access groups to support the Satellite service deployment and rollout. 

## Detailed Information 

Further details below

## Detailed Procedure

Follow the detailed procedures below

## Preliminary requirements

There are some resources need to be created in the Satellite Production account with designated region.

- Environment: Satellite Production (2094928) 

### Set Up Resource Groups

The following resource groups are required.

- Tugboatm-[**REGION**]Fleet
- Satellite-prod-[**REGION**]
- config-Satellite-prod-[**REGION**]
- link-Satellite-prod-[**REGION**]
- satellite-platform-prod-[**REGION**]
- micro-Satellite-prod-[**REGION**]
- LogDNA-prod-[**REGION**]
- ActivityTracker-prod-[**REGION**]
- sysdig-prod-[**REGION**]

### Set Up Access Groups

Please use the reference for each access group for detailed configuration. 

- satellite-location_[**REGION**]_all_viewer - https://cloud.ibm.com/iam/groups/AccessGroupId-9d769ee6-7ad4-4bf8-adc2-d625ce1df30f?tab=iam
- satellite-location_[**REGION**]_metrics-logs_viewer - https://cloud.ibm.com/iam/groups/AccessGroupId-7c2b2fb0-6429-47be-b687-589125f382af?tab=iam
- satellite-config_[**REGION**]_all_viewer - https://cloud.ibm.com/iam/groups/AccessGroupId-81075596-b5ce-40de-8376-754665a0608f?tab=iam
- satellite-config_[**REGION**]_metrics-logs_viewer - https://cloud.ibm.com/iam/groups/AccessGroupId-4c3517b2-6c18-4950-8c7d-737d33dd7dc2?tab=iam
- satellite-link_[**REGION**]_all_admin - https://cloud.ibm.com/iam/groups/AccessGroupId-830c69df-2af0-489e-819e-5ccfe78a6907?tab=iam
- satellite-link_[**REGION**]_all_viewer - https://cloud.ibm.com/iam/groups/AccessGroupId-81075596-b5ce-40de-8376-754665a0608f?tab=iam
- satellite-link_[**REGION**]_metrics-logs_viewer - https://cloud.ibm.com/iam/groups/AccessGroupId-db2b5c61-e2dc-41cb-8b86-adf596a63817?tab=iam

### CSE API Key

In order to create a private Cloud Service Endpoint (CSE) for Satellite in a region, you need to ensure you have CSE apikey for the region. 

If a CSE api key does not exist for the region, you need to create one. 

- ServiceID: satellite-prod-[**REGION**]-MIS
- APIKEY title: satellite-prod-[region]-MIS

Once the service ID and api key is created, a ticket needs to be submitted to get IAM Access to CSE - eg) https://github.ibm.com/NetworkTribe/MISsupport/issues/54


### Create services to support Satellite services
---
Here is the list of service required for each service. Further instruction can be found below. 

### Satellite Location 
- [Certificate Manager](#certificate-manager) 
- LogDNA 
- Sysdig

### Satellite Link
- [Certificate Manager](#certificate-manager) 
- [Regional MongoDB](#regional-mongodb)
- Digicert procurment for private and public service domain
  - public: *.[**REGION**].link.satellite.cloud.ibm.com
  - private: *.private.[**REGION**].link.satellite.cloud.ibm.com
- [COS for BCDR](#regional-cos-and-cos-bcdr)

### Satellite Config
- [Regional MongoDB](#regional-mongodb)
- [Regional COS](#regional-cos-and-cos-bcdr)
- [Regional REDIS](#regional-redis)
- LogDNA
- Sysdig
- Digicert procurement 
  - public: config.[**REGION**].satellite.cloud.ibm.com
- COS for BCDR

### Instruction How To Provision Services
---

### Certificate Manager 

The certificate manager can be provisioned via IBM Cloud web UI.

- Satellite location:
  - Name: `Satellite-Locations-Ingress-CertMgr-[REGION]Fleet`
  - Resource group: `Tugboatm-[REGION]Fleet`

- Satellite Link 
  - Name: `satellite-link-certmgr01-[REGION]`
  - Resource group: `link-Satellite-prod-[REGION]`

### Regional MongoDB

Required for both Satellite Config and Satellite Link and use the same configuration 
- Satellite Config
  - Plan: `standard`
  - Name: `Satellite-Config-MongoDB-Prod-[REGION]`
  - Resource group: `config-Satellite-prod-[REGION]`

- Satellite Link 
  - Plan: `standard`
  - Name: `satellite-link-mongodb01-[REGION]`
  - Resource group: `link-Satellite-prod-[REGION]`

Service provisioning instruction:  
```
ibmcloud resource service-instance-create [SERVICE_NAME] databases-for-mongodb standard [REGION] -p '{"members_cpu_allocation_count": "9"}' --service-endpoints private 
```
Enable memory disk autoscale
```
ibmcloud cdb deployment-autoscaling-set [SERVICE_NAME] member '{"autoscaling": { "memory": {"scalers": {"io_utilization": {"enabled": true, "over_period": "15m","above_percent": 90}},"rate": {"increase_percent": 10.0, "period_seconds": 900,"limit_mb_per_member": 114688,"units": "mb"}}}}'

ibmcloud cdb deployment-autoscaling-set [SERVICE_NAME] member '{"autoscaling": { "disk": {"scalers": {"io_utilization": {"enabled": true, "over_period": "15m","above_percent": 90}},"rate": {"increase_percent": 10.0, "period_seconds": 900,"limit_mb_per_member": 3670016,"units": "mb"}}}}'
```
**Store the service credential to armada-secure**
- Satellite Config: 
  - Create a new service credentail with the name `Satellite-Config-MongoDB-Prod-[REGION]-credential`
  - Copy the value of MongoDB DB URL under `Composed` field 
  ```
  "composed": [
        "mongodb://ibm_cloud_xxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150/ibmclouddb?authSource=admin&replicaSet=replset"
  ```
    The value of MongoDB URL (db-secret) must not including double quote "" as following
  ```
  mongodb://ibm_cloud_xxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150/ibmclouddb?authSource=admin&replicaSet=replset
  ```
  - Replace the path and query string at the end of url from `/ibmclouddb?authSource=admin&replicaSet=replset` to `/sloop?authSource=admin&replicaSet=replset&tls=true&tlsCAFile=/var/run/secrets/razeeio/razeedash-secret/mongo_cert`
  - View secrets in production environment to make sure the new db-secret format is correct.
  - [Encrypt db-secret as a GPG key](#encrypt-gpg-key)
  - Copy the value of `Certificate_base64`field and encrypt as a GPG key as a CERT file. 
  - Upload both CERT and MongoDB Connection link into armada-secure under `build-env-vars/satellite-config`
- Satellite Link:
  - Create a new service credentail with the name `Satellite-Config-MongoDB-Prod-[REGION]-credential`
  - Copy the value of MongoDB DB URL under `Composed` field 
  ```
  "composed": [
        "mongodb://ibm_cloud_xxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150/ibmclouddb?authSource=admin&replicaSet=replset"
  ```
    The value of MongoDB URL (db-secret) must not including double quote "" as following
  ```
  mongodb://ibm_cloud_xxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150,xxxxxxx.private.databases.appdomain.cloud:32150/ibmclouddb?authSource=admin&replicaSet=replset
  ```
  - View secrets in production environment to make sure the new db-secret format is correct.
  - [Encrypt db-secret as a GPG key](#encrypt-gpg-key) and upload into armada-secure under `build-env-vars/satellite-link`
### Regional COS and COS BCDR

- Satellite Config:
  - Plan: `Standard`
  - Name: `Satellite-Config-Cos-Prod-[REGION]`
  - Resource group: `config-Satellite-prod-[REGION]`

  - COS Backup 
    - Name: `Satellite-Config-Cos-Backup-Prod-[REGION]`
    - Resource group: `config-Satellite-prod-[REGION]`
    - Buckets: 
        - satellite-config-[zone]-configs-backup-prod-[REGION]
        - satellite-config-[zone]-resources-backup-prod-[REGION]
    - Service credential: `satellite-config-COS-backup-prod-[REGION]-service-key_TIMESTAMP` by `ServiceID-satellite-config-COS-backup-prod-[REGION]`

- Satellite Link COS BCDR:
  - Plan: `Standard`
  - Name: `link-mongodb-backup-prod-[REGION]`
  - Resource group: `link-Satellite-prod-[REGION]`
  - Service credential: `ServiceID-satellite-link-cos-prod-[REGION]`

- Command line instruction  
```
ibmcloud resource service-instance-create [SERVICE_NAME]-[REGION] cloud-object-storage standard global
```
- Create a service credential
```
ibmcloud iam service-id-create [SERVICE_NAME]-[REGION]-key-manager
ibmcloud resource service-key-create [SERVICE_NAME]-[REGION]-Credential Manager --instance-name [SERVICE_NAME]-[REGION]  --service-id ServiceId-UUID-FROM-THE-ABOVE-COMMANDXXXXX -p '{"HMAC": true}'
```
  - Upload the following keys from the service credential into armada-secure
    - Copy `access_key_id` value 
    - Copy `secret_access_key`

### Regional REDIS

- Satellite Config:
  - Plan: `Standard`
  - Name: `Satellite-Config-Redis-Prod-[REGION]`
  - Resource group: `config-Satellite-prod-[REGION]`
  - Service endpoint: `private`
  - CPU allocation : 6 cores

  ```
  ibmcloud resource service-instance-create Satellite-Config-Redis-Prod-ca-tor databases-for-redis standard ca-tor -p '{"members_cpu_allocation_count": "6"}' --service-endpoints private
  ```
  - Enable memory disk autoscale
  ```
  ibmcloud cdb deployment-autoscaling-set Razee-Hosted-Redis-Prod-eu-gb member '{"autoscaling": { "memory": {"scalers": {"io_utilization": {"enabled": true, "over_period": "15m","above_percent": 90}},"rate": {"increase_percent": 10.0, "period_seconds": 900,"limit_mb_per_member": 114688,"units": "mb"}}}}'
  
  ibmcloud cdb deployment-autoscaling-set Razee-Hosted-Redis-Prod-eu-gb member '{"autoscaling": { "disk": {"scalers": {"io_utilization": {"enabled": true, "over_period": "15m","above_percent": 90}},"rate": {"increase_percent": 10.0, "period_seconds": 900,"limit_mb_per_member": 3670016,"units": "mb"}}}}'
  ```
- Service credential: 
  - Name: `Satellite-Config-Redis-Prod-[REGION]-credential`
  - CERT file: Copy the value in the field `certificate_base64`
  - Redis connection URL: Copy the value of redis url (`rediss://admin....../0`)
  - Encrypt as a GPG file for both and upload into armada-secure under `build-env-vars/satellite-config`

### DigiCert Procurement

- Follow the runbooks - [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/using_certificate_manager.html](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/using_certificate_manager.html)

### Encrypt GPG key
- Follow below steps to encrypt db-secret to gpg key
```
git clone git@github.ibm.com:alchemy-containers/armada-secure.git
cd armada-secure
gpg --import build/root@oneibmcloud.com
Copy db-secret into txt file NEW_DB_SECRET.txt
gpg -a -e -r root@oneibmcloud.com -o NEW_DB_SECRET.gpg NEW_DB_SECRET.txt
```