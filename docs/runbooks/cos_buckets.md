---
layout: default
description: Creating COS buckets for armada microservices
service: IKS
title: Creating COS buckets for armada microservices
runbook-name: "Creating COS buckets for armada microservices"
link: /cos_buckets.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
This runbook covers the general steps to procure a cloud object storage (COS) bucket and credential for an armada microservice.
All requests _should_ come in the form of a GHE issue such as this [example](https://github.ibm.com/alchemy-conductors/team/issues/6367) and should first be approved by the appropriate authority.

## Detailed Information
We need to Dedicated COS bucket for all microservices and a set of service credentials with only write permission to that bucket. This bucket will be used by the microservice travis build job to store kube configs. 

Cluster updater will then read from this bucket with read only credentials that are stored in [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/build-env-vars/cluster-updater/ARMADA_SECURE_COS_API_KEY.gpg) and apply any requested changes to the carrier.

The bucket names needs to clearly identify purpose:  
```
<microservice>-bucket-name  
addon-<addonname>-bucket-name
```

### Procurement steps
1. Sign into [IBM Cloud](https://cloud.ibm.com)
1. Select the `531277 - Argonauts Production` account
1. Go to [manage ServiceIDs](https://cloud.ibm.com/iam/serviceids) and create a ServiceID for the new microservice in the following format:
   ```
   Argonauts ServiceIDs
   <microservice>-config-prod-global
   e.g.
   armada-deploy-config-prod-global
   armada-api-config-prod-global
   armada-health-config-prod-global

   OR
   <addonname>-config-prod-global
   e.g.
   addon-hyper-protect-config-prod-global
   ```
1. Head to the [armada-pipeline-config-prod-global COS instance](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Af92e973d-e90f-4cba-8411-512ebbeabdca%3A%3A?paneId=manage)
1. Gather information from the GHE issue in order to create the requested bucket type with the requested name. Select the following parameters:
   - Resiliency: Cross Region
   - Location: us-geo
   - Storage class: Standard
1. Head back to [manage ServiceIDs](https://cloud.ibm.com/iam/serviceids) and click on the newly created ServiceID and select the `Access Policies` tab and select `Assign Access`. 
1. Select `Assign access to resources` and provide the following parameters
   - Services: Cloud Object Storage
   - Service Instance: armada-pipeline-config-prod-global (f92e973d-e90f-4cba-8411-512ebbeabdca)
   - Resource Type: bucket
   - Resource ID: `<bucket-name-created-in-earlier-steps>`
   - Service Access: Writer
1. Head to the [armada-pipeline-config-prod-global COS instance](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe223e119c9be31669e5688bb376411f7%3Af92e973d-e90f-4cba-8411-512ebbeabdca%3A%3A?paneId=manage) and select `Service Credentials`
1. Create `New Credential` and provide the following parameters:
   - Name: `<microservice>-config-prod-global-apikey` or `addon-<addonname>-config-prod-global-apikey`
   - Role: Reader
   - Select Service ID: `<serviceID-name-created-in-earlier-steps>`
   - Select `Include HMAC Credential`
1. Use the [secret rotation runbook](secret_rotation.html) to "rotate" the credentials to the requested destination.
