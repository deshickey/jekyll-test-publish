---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to map LogDNA and Activity Tracker Instances to its corresponding COS bucket
service: activity tracker
title: Mapping LogDNA and Activity Tracker instance to COS bucket
runbook-name: "Mapping LogDNA and Activity Tracker instance to COS bucket"
link: /map_logdna_to_cosbucket.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
This document describes how to map LogDNA and Activity Tracker Instance to its corresponding COS bucket

## Detailed Information
The LogDNA and Activity Tracker instances are created per region in `Satellite Prod 2094928` account.
This runbook provides steps to map these instances to their corresponding COS Buckets.

## Detailed Procedure

#### The steps to map instances to their COS buckets
1. For LogDNA, Login to [IBM Cloud Logging](https://cloud.ibm.com/observe/logging). Set Softlayer account `Satellite Prod 2094928` for Prod.
2. Select the LogDNA instance for a region. <br> 
   For example: Select `satellite-microservices-prod-us-south-STS` for us-south and click on `Open Dashboard` <br>
   (2.a) In `satellite-microservices-prod-us-south-STS (Dallas)` page, select `settings->ARCHIVING->Manage` <br>
   (2.b) In `Manage Archiving` page, go to `Settings` and copy the name from `Bucket`. Example: Bucket name `2094928-satellite-microservices-prod-us-south-sts` <br>
3. On the left top corner of [IBM Cloud](https://cloud.ibm.com/observe), click on `Nagation Menu` and select `Resource list` from the drop down menu <br>
   (3.a) In `Resource list` page, under `Storage` click on `LogDNA-COS-prod`  <br>
   (3.b) In `LogDNA-COS-prod` page, search and find the Bucket name `2094928-satellite-microservices-prod-us-south-sts` and click on it. This is the COS bucket for the given instance  <br>
4. Repeat the steps from 2 to 3 for each region to map their corresponding COS Bucket
5. For Activity Tracker, repeat the steps from 2 to 3 for each region

#### List of LogDNA & Activity Tracker instanace names and their correspoinding COS storage & bucket names <br>

`Satellite Prod 2094928` <br>

| Region | LogDNA instance name | Activity Tracker name | COS storage name | COS bucket name|
|---|---|---|--|--|
| us-south | [satellite-microservices-prod-us-south-STS](https://cloud.ibm.com/observe/embedded-view/logging/3ab0aa29-7bc6-4ff3-b475-1c54ea8ed1ad) | [IKS-AT-platform-us-south](https://cloud.ibm.com/observe/embedded-view/activitytracker/945ab1fa-6b6c-4319-a271-0fa9186c9962) | [LogDNA-COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?paneId=manage) | [2094928-activity-tracker-us-south](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-activity-tracker-us-south&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview) |
|us-east | [satellite-microservices-prod-us-east-STS](https://cloud.ibm.com/observe/embedded-view/logging/ccaa75e8-015f-4205-a64f-a40831038701) |  [IKS-AT-platform-us-east](https://cloud.ibm.com/observe/embedded-view/activitytracker/7da5d940-1d9b-4ab0-b5ae-1663b581a4fd) | [LogDNA-COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?paneId=manage)  | [2094928-activity-tracker-us-east](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-activity-tracker-us-east&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview) |
|eu-gb | [satellite-microservices-prod-eu-gb-STS](https://cloud.ibm.com/observe/embedded-view/logging/36824b2e-bc3e-4f7c-b0fb-f052c0baa8d4) | [IKS-AT-platform-eu-gb](https://cloud.ibm.com/observe/embedded-view/activitytracker/1bd40364-06de-43f2-889e-336ea6a894b4) |[LogDNA-COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?paneId=manage)  | [2094928-activity-tracker-eu-gb](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-activity-tracker-eu-gb&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview) |
| jp-tok | [satellite-microservices-prod-jp-tok-STS](https://cloud.ibm.com/observe/embedded-view/activitytracker/1bd40364-06de-43f2-889e-336ea6a894b4) | [IKS-AT-platform-jp-tok](https://cloud.ibm.com/observe/embedded-view/activitytracker/d3507c2e-2a9c-40d0-af86-fa7667215aa0)  | [LogDNA-COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?paneId=manage)  | [2094928-activity-tracker-jp-tok](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-activity-tracker-jp-tok&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview) |
| ca-tor | [satellite-microservices-prod-ca-tor-STS](https://cloud.ibm.com/observe/embedded-view/logging/9b098175-2a15-44e8-8861-17782019409f) | [IKS-AT-platform-ca-tor](https://cloud.ibm.com/observe/embedded-view/activitytracker/22bf0392-8e89-4375-ad8c-abc5fd1a2678) | [LogDNA-COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?paneId=manage) | [2094928-activity-tracker-ca-tor](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-activity-tracker-ca-tor&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview) |
| au-syd | [satellite-microservices-prod-au-syd-STS](https://cloud.ibm.com/observe/embedded-view/logging/0e33aa4f-98af-41e2-8400-bc6bb54af6b5) |  [IKS-AT-platform-au-syd](https://cloud.ibm.com/observe/embedded-view/activitytracker/a5aeab1d-f348-486a-ba28-0b6e2b570fc3)  | [LogDNA-COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?paneId=manage) | For LogDNA [2094928-satellite-microservices-prod-au-syd-sts](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-satellite-microservices-prod-au-syd-sts&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview). For Activity Tracker [2094928-activity-tracker-au-syd](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-activity-tracker-au-syd&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview) |
| jp-osa | [satellite-microservices-prod-jp-osa-STS](https://cloud.ibm.com/observe/embedded-view/logging/767c0eb3-c477-458e-a0dd-c81789096208) | [IKS-AT-platform-jp-osa](https://cloud.ibm.com/observe/embedded-view/logging/767c0eb3-c477-458e-a0dd-c81789096208) | [LogDNA-COS-prod](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?paneId=manage)  |  [2094928-satellite-microservices-prod-jp-osa-sts](https://cloud.ibm.com/objectstorage/crn%3Av1%3Abluemix%3Apublic%3Acloud-object-storage%3Aglobal%3Aa%2Fe3feec44d9b8445690b354c493aa3e89%3Ad262faca-9c3e-4312-a57d-d83a0e5687e4%3A%3A?bucket=2094928-satellite-microservices-prod-jp-osa-sts&bucketRegion=us&endpoint=s3.us.cloud-object-storage.appdomain.cloud&paneId=bucket_overview) |



