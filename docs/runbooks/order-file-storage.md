---
layout: default
description: Procedure for ordering file storage from Softlayer
title: Order Softlayer File Storage
runbook-name: "Procedure for ordering file storage from Softlayer"
tags: nfs storage volume
link: /order-file-storage.html
type: Informational
service: Conductors
parent: Armada Runbooks

---

Informational
{: .label }

# Purpose

This runbook describes how to order nfs for Armada.


# Process

## Order Storage

Always order `Endurance` storage using jenkins job: [softlayer-utils](https://alchemy-containers-jenkins.swg-devops.com:8443/job/Containers-Volumes/view/SoftLayer/job/softlayer-utils/).

- `SL_USER` and `SL_API_KEY`<br>
  Use your own username and API key for the account where the file storage will be allocated.<br>
  *Note*: If you use an IBMid to access your account, this username may **not** be the same as your IBMid.  
- `SL_DC`<br>
  Select the Softlayer site where the storage is to be allocated. This should be relevant for the account you are using.  
- `OPERATION`<br>
  Only use `create`; do not think any of the others work. 
- `NAME`<br>
  Use a descriptive string identifying the purpose.  e.g. `Carrier kubx NFS - fra02(p2)`. This is important to identify the storage later in the Softlayer portal so that subnets and hosts can be authorized.  
- `STORAGE_TYPE`<br>
  Endurance. No other choice.  
- `SIZE` and `IOPS`<br>
  Endurance IOPs are measured per GB with a maximum of 10 IOPs/GB, so select a storage size that provides the requested IOPs. e.g. A request for 20 GB @ 250 IOPs would require 25 GB @ 10 IOPs/GB.  
- `STORAGE_ID`<br>
  leave as 0.  
- `TIMEOUT`<br>
  The default seems adequate.<br>
  *Note*: If the job times out, do **not** simply re-order the storage. Inspect the job log. In all likelihood the storage order was placed, and it timed out waiting for tthe order to be fulfilled. Unfortunately if this happens the `NAME` will not have been applied to the storage; you will have to use the order id to locate the storage.  

## Identify Storage in Softlayer Portal

In Softlayer portal select `Storage`->`File Storage` from the menu bar.  Alchemy has so many volumes it is easiest to filter by location and size.  Identify the volume by the `NAME` you supplied to the [softlayer-utils](https://alchemy-containers-jenkins.swg-devops.com:8443/job/Containers-Volumes/view/SoftLayer/job/softlayer-utils/) jenkins job (this will be the `NOTES` column in the portal display). Click on the volume name to *drill down*.  

## Scheduling Storage Backup

This is achieved through snapshots. When *drilled down* on the storage volume, the `Snapshot Space` should be `0 GB`.  Click on `Add Snapshot Space` and order space equal to the storage space. This will place an order, and you will have to refresh the screen a few times before you will see it.  

Once the snapshot space is allocated, modify the schedule for a daily backup and retain the last 14 images.  

## Authorizing Subnets

In Armada, subnets are authorized; not individual hosts.  

Identify the backend VLAN (e.g. Prod/Carrier1) in the environment (`Network`->`IP Management`->`VLANS`) and *drill down* to display the subnets.

While *drilled down* on the storage volume click on `Authorize Host`, select `Subnets` and enter the subnets identified above one by one.  

*Note*: Only private subnets can be authorized.
