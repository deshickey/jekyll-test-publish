---
layout: default
title: New SysDig instance
type: Informational
runbook-name: "SysDig new instance"
description: How and where to create SysDig instances for IKS
category: Armada
service: LogDNA
tags: alchemy, armada, sysdig
link: /sysDig_new_instance.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

SysDig is being trialed for our services for metrics that we used to send to IBM Metrics service.

## Detailed Information

We have several accounts.

We use the following accounts for IBM Cloud service that we create like LogDNA / SysDig / KeyP etc.
- For development and prestage - `Dev 1186049` linked account alchdev@uk.ibm.com
- For stage argostag@uk.ibm.com - Note this is for our use of other peoples production services, this is not our stage test account that is linked to YS1.
- For Production `Alchemy Production's Account (cc7530878c499d74ad77f31c918c626e) <-> 1185207`

### Resource Groups
There are resource groups in each account for the type of service we are going to create.

For Sysdig, we use regional resource groups. For example `sysdig-prod-eu-es` for Madrid in 1185207.

Legacy resource groups may still be in use:

Resource group In the Dev 1186049 linked account alchdev@uk.ibm.com
- SysDig dev
- SysDig prestage

In the IBM Cloud account argostag@uk.ibm.com (being created)
- SysDig stage

In the IBM Cloud Account Alchemy Production's Account (cc7530878c499d74ad77f31c918c626e) <-> 1185207
- SysDig prod

### Creating the Sysdig (IBM Cloud Monitoring) instances

Use the Cloud UI to create the instances.

_Make sure that you are in the correct Cloud account, per above._

_Please verify that the settings below are correct for the instance that you are creating._

1. Create resource
1. Select Logging and Monitoring
1. Select IBM Cloud Monitoring (new name for `Sysdig`)
1. Select the region
1. Insert the name
1. Choose Graduated tier
1. Select the resource group
1. Chose Platform Metrics or not, depending on whether it is required

### Access Groups

We will create an Access group that will enable certain privs with those resource groups for all SysDig instances in those resource groups.

Userids will then be added to the Access groups relevant to that user

(ralph) I need to decide how We will create SysDig instances for each deployed region so that we can see metrics across our deployments in the same SysDig instance for a given region
