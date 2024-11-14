---
layout: default
title: Introduction to Satellite Config Infrastructure
type: Informational
runbook-name: "Introduction to Satellite Config Infrastructure"
description: Introduction to Satellite Config Infrastructure
service: Satellite Config
link: /satellite-config/Introduction_to_SatelliteConfig_Infrastructure.html
grand_parent: Armada Runbooks
parent: Satellite Config
---

Informational
{: .label }

# Introduction to Satellite Config Infrastructure

## Overview
This runbook provides the high level details about `Satellite Config Infrastructure` and `On-boarding steps` for SRE.

#### Topics Covered
- How to get access to Satellite Config environment
- How to access Satellite Config Infrastructure portal using `cloud.ibm.com` and `CLI`
- How to access Satellite Config Sysdig Monitoring portal
- How to access Satellite Config LogDNA Logging portal
- How to access Satellite Config LogDNA Activity Tracker portal
- How to access Satellite Config MongoDB portal
- How to access Satellite Config Redis portal
- Satellite Config details: <br>
  SoftLayer Accounts, PagerDuty Services, Cluster Names and Pager Duty Escalation Policies
- Miscellaneous

---

## Detailed Information

### How to get access to Satellite Config environment
- Follow the below steps
  - Raise a request in AccessHub. Login to [Access Hub](https://ibm-support.saviyntcloud.com)
  - Use the Request or Manage Access to start
  - The name of the application is  `IBM Kubernetes Service
(IKS) Access`. Search for this application name in the search box
  - A first time user can only select `ADD TO CART`, if you already used the application
   `MODIFY EXISTING ACCOUNT` is appropriate
  - Once you selected your appropriate option, use the `Checkout` button on top
  - Add the appropriate role based on your location `ROLE_RAZEE_SRE-XX`
  - Select `Next` to go to next page, add the below text in mandatory text field `Business Justification`:

    `Access to Satellite Config Infrastructure is required to perform SRE activities`
  - Submit the request

### How to access Satellite Config Infrastructure portal
Details of the clusters and worker nodes of the Production accounts can be viewed using UI Portal or CLI commands.

#### Using cloud.ibm.com
Use Cloud UI to login to the Production Account
- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select `2094928 Satellite Production` account for *US-East*  
	- Select `Kubernetes` (on left hand side)
	- Select `Clusters`

#### Using CLI
Use IBM Cloud CLI to login to the Production Account

    - Login using CLI

    	> ibmcloud login --sso (or use other options to login)

    - Select Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928


 List the clusters and nodes

        > ibmcloud ks clusters
        > ibmcloud ks workers --cluster <CLUSTER-ID>

 Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

 Can run kubectl commands to get further information

         > kubectl get pods -A

### How to access Satellite Config's Sysdig Monitoring portal
Satellite Config uses Sysdig for monitoring .

Follow the below steps to access Sysdig portal:

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select `2094928 Satellite Production` account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Monitoring`
	- Select `Razee-Hosted-Sysdig-Prod-us-east` for *US-East*  
	- Select `View Sysdig`

### How to access Satellite Config's LogDNA Logging portal
Satellite Config uses LogDNA for Logging purposes.

Follow the below steps to access LogDNA portal:

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select `2094928 Satellite Production` account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Logging`
	- Select `Razee-Hosted-LogDNA-STS-Prod-us-east` for *US-East*  
	- Select `View LogDNA`

### How to access Satellite Config's Activity Tracker portal
Satellite Config uses Activity Tracker.

Follow the below steps to access Activity Tracker portal:

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select `2094928 Satellite Production` account for *US-East*
	- Select `Observability` (on left hand side)
	- Select `Activity Tracker`
	- Select `Razee-Hosted-LogDNA-ATS-Prod-us-east` for *US-East*  
	- Select `View LogDNA`

### How to access Satellite Config's MongoDB portal
Satellite Config uses MongoDB.

Follow the below steps to access MongoDB portal:

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select `2094928 Satellite Production` account for *US-East*
  - Select `Resource List` (on left hand side)
	- Select `Services`
	- Select `Razee-Hosted-MongoDB-Prod-us-east` for *US-East*

### How to access Satellite Config's Redis portal
Satellite Config uses Redis.

Follow the below steps to access Redis portal:

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select `2094928 Satellite Production` account for *US-East*
  - Select `Resource List` (on left hand side)
	- Select `Services`
	- Select `Razee-Hosted-Redis-Prod-us-east` for *US-East*

## Satellite Config details

#### Clusters

Cluster Name | Cluster ID | Location | Region | Account
-- | -- | -- | -- | --
prod-us-east-sr-carrier108 | bsg87bnw0tmcjr5jof7g | WashingtonDC | US-East  | 2094928



#### Account Info

  `2094928 Satellite Production`: US-East


#### Pager Duty

 `PD Services & Escalation Policies`:

   [Alchemy - Satellite - Config](https://ibm.pagerduty.com/escalation_policies#P42GAQ1)

#### Availability
Clusters are Multi Zone

#### Scalability
None for now

#### Recovery & Backup
MondoDB databases are redundant, and backed up daily

#### Dependency
MongoDB, Redis and COS and IAM


---
## Miscellaneous

 NA


---
## Satellite Config Architecture
- [Satellite Config Functional Overview](https://github.ibm.com/alchemy-containers/satellite-config/tree/master/Architecture)

## Further Information
* Please contact the Satellite Config squad in the [#satellite-config](https://ibm-argonauts.slack.com/archives/CPPG4CX3N) slack channel for further information
* PD escalation policy : Escalate to [Alchemy - Satellite - Config](https://ibm.pagerduty.com/escalation_policies#P42GAQ1)
