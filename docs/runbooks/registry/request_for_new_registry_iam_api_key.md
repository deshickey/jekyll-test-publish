---
layout: default
description: Creating registry api keys for armada squads
service: IKS
title: Creating registry api keys for armada squads
runbook-name: "Creating registry api keys for armada squads"
link: /create_iam_registry_api_key_armada_squads.html
type: Informational
grand_parent: Armada Runbooks
parent: Registry
---

Informational
{: .label }

## Overview
This runbook covers the general steps to create a registry IAM apikey for an armada squad.
All requests _should_ come in the form of a GHE issue such as this [example](https://github.ibm.com/alchemy-conductors/team/issues/7807) and should first be approved by the appropriate authority.

## Detailed Information
We are dedicating a registry IAM apikey with read/write permission to registries in all regions to each armada squad. This apikey will be used by the microservice travis build jobs to push build images. Carrier/tugboat workers will then be able to pull images with read only credentials stored in a kubernetes secret in armada-secure

### Procurement steps
1. Sign into [IBM Cloud](https://cloud.ibm.com/)
2. Select the `1185207 - Alchemy Production's Account` account
3. Go to the [ServiceID iks-armada-master-registry-access-20210422](https://cloud.ibm.com/iam/serviceids/ServiceId-a1c100f1-e2e6-4d83-b6d1-ab3cbff9a809?tab=apikeys) and click on `Create`. Name the key with the name convention and description below. 

   ~~~
   YYYYMMDD is Year Month Day
   <armada-squad>-build-registry-YYYYMMDD
   e.g.
   armada-deploy-build-registry-YYYYMMDD
   armada-api-build-registry-YYYYMMDD
   armada-health-build-registry-YYYYMMDD
   ~~~

   with the following description: `Used to push images to registries in all regions during travis razee builds`

4. Create secret-rotate-metadata issue with [ServiceID API Key Request](https://github.ibm.com/alchemy-containers/secret-rotate-metadata/issues/new?assignees=&labels=secret-rotation&template=serviceID_apikey.md&title=%5B--IBM+Cloud+account+no--%5D+ServiceID+API+Key+Request+for) template and place details of ServiceID and apikey in the issue.
5. Ask user to populate correct destination in the comment put `ready-to-rotate` label once destination is in place. 
    * _Refer [Secret Rotation](https://ibm.ent.box.com/notes/1522215644801?s=8zv91rtvxm2d2mss7fr8loz39ldxor9n) box note for guide on rotating secret._
6. Once apikey is rotated, remove the key created in step 3.

### Permissions steps

1. Open a PR into the [image-iam](https://github.ibm.com/alchemy-registry/image-iam/blob/master/image-iam.yaml) repo, adding your email address to the correct repo
1. Once merged, verify access following these [IKS Platform CLI examples](https://github.ibm.com/alchemy-registry/image-iam#iks-platform-cli-examples)
