---
layout: default
title: Introduction to Schematics Infrastructure
type: Informational
runbook-name: "Introduction to Schematics Infrastructure"
description: Introduction to Schematics Infrastructure
service: schematics
link: /schematics/Introduction_to_Schematics_Infrastructure.html
grand_parent: Armada Runbooks
parent: Schematics
---

Informational
{: .label }

# Introduction to Schematics Infrastructure

## Overview
This runbook is intended to provide the high level details about `Schematics Infrastructure` and `On-boarding steps` for SRE.

#### Topics Covered
- How to get access to Schematics environment 
- How to access Schematics Infrastructure portal using `cloud.ibm.com` and `CLI`
- How to access Schematics Sysdig Monitoring portal
- Schematics details: <br>
  SoftLayer Accounts, PagerDuty Services, Cluster Names and Pager Duty Escalation Policies 
- Miscellaneous

---
       
## Detailed Information

### How to get access to Schematics environment
- Follow the below steps
  1. Raise a request in AccessHub. Login to [Access Hub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome)
  2. A first time user can select "Request New Account". If you already used the application, select "Manage My Existing Access" to start
  3. There are 3 Schematics Production Applications available <br>
    `Schematics Prod US` <br>
    `Schematics Prod EU` <br>
    `Schematics Prod EU-FR2` <br>
  4. Search and select one of the application name in the search box. If its "Request New Account" scenario, select "Manage Access" and then "Modify". If its "Manage My Existing Access" scenario, select "Modify"
  5. Select "Add" option to add the roles: <br>
    `Schematics Prod Operators` <br>
    `Schematics Prod Operators IKS/Bastion` <br>
  6. Select `Review and Submit`. Add the below text in mandatory text field `Business Justification`: <br>
    `Access to Schematics Infrastructure is required to perform SRE activities`. 
  7. Submit the request
  8. Repeat the steps 4 and 7 for all 3 applications

### How to access Schematics Infrastructure portal
Details of the clusters and worker nodes of the Production accounts can be viewed using UI Portal or CLI commands.

#### Using cloud.ibm.com
Use Cloud UI to login to the Production Account
- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select 1998758 account for *EU*  OR
                 1944771 account for *Non-EU* OR
                 2123790 account for *BNPP*
	- Select `Kubernetes` (on left hand side)
	- Select `Clusters`

#### Using CLI
##### Use IBM Cloud CLI to login to the Production Account

    - Login using CLI

    	> ibmcloud login --sso (or use other options to login)

    - Select Schematics Softlayer Account 1944771 (US-South/US-East) 
      or 1998758 (EU) or 2123790 (BNPP - Paris)
    
    - To access Schematics Softlayer Account 2123790 (BNPP):
      Install teleport and configure it in-order to run kubectl commands.

      1. Intall tsh by
      > brew install teleport
      2. Use the following command to login to bastion proxy:
      > tsh login --proxy schematics-prod-eu-fr2-01-056aef997f1ca8b1f13879af0ca660a2-0006.par04.containers.appdomain.cloud:443
      This will open a browser window and login using the current IBMID credentials in the browser session.
      If no session in active, login using your IBM ID in the browser.
      3. After successful login in the browser callback, check the terminal for the login success message as below:
      >
      Profile URL:  ****
      Logged in as: <your IBM ID>
      Cluster:      schematics-prod-eu-fr2-01-bastion
      Roles:        iks-user
      Logins:       <your IBM ID
      Valid until:  <timestamp> [valid for 1h0m0s]
      Extensions:   permit-agent-forwarding, permit-pty

##### Run the ibmcloud or kubectl commands 

 List the clusters and nodes

        > ibmcloud ks clusters
        > ibmcloud ks workers --cluster <CLUSTER-ID>

 Set cluster config to access the cluster

         > ibmcloud ks cluster config --cluster <CLUSTER-ID>

 Can run kubectl commands to get further information

         > kubectl get pods -A
	 
	 	
 Use can move from one account to another, using `target` command

     	> ibmcloud target -c c19ef85117044059a3be5e45d6dc1cf6 
                             (SL Account 1944771 - US-South/US-East)

      	> ibmcloud target -c c1c277d0979b4c1eaef50ab125279c2e 
                             (SL Account 1998758 - EU)

	 
### How to access Schematics Sysdig Monitoring portal
Schematics uses Sysdig for Monitoring purposes.

Follow the below steps to access Sysdig portal:

- Login to [cloud.ibm.com](https://cloud.ibm.com/)
	- Select 1998758 account for *EU*  or
                 1944771 account for *Non-EU* or
                 2123790 account for *BNPP*
	- Select `Resource List` (on left hand side)
	- Select `Services`
	- Select `Schematics-Prod-SysDig-EU-DE` for *EU*  or <br>
                  `Schematics-Prod-Sysdig-US-South` for *Non-EU* 
	- Select `View Sysdig`

---
## Schematics details

#### Clusters

Cluster Name | Cluster ID | Location | Region | SL Account
-- | -- | -- | -- | --
schematics-prod | bko21qlw0i694b4upbgg | WashingtonDC | US-East  | 1944771
schematics-prod | bko1vhhd0cgnhj8ebg40 | Dallas | US-South   | 1944771
schematics-prod-eu-de-01 | bmp46d5f0pu4npo0u9s0 | Frankfurt  | EU-DE | 1998758
schematics-prod-eu-de-01 | bmou4mll0t6kmnmp1qd0 | London     | EU-GB | 1998758
schematics-prod-eu-fr2-01 | btcuifob0q3rimj7cv60 | Paris | EU-FR2 | 2123790


#### SoftLayer Account Info

  `1944771`: US-South and US-East

  `1998758`: EU/UK
  
  `2123790`: BNPP/EU-FR2 - Paris
 
#### Pager Duty

 `PD Services`:
 
   [schematics-prod-sev1](https://ibm.pagerduty.com/service-directory/PJLDDBO)
 
   [schematics-prod-sev2](https://ibm.pagerduty.com/service-directory/PIKQK0B)
 
   [schematics-prod-sev2-4-low-urgency](https://ibm.pagerduty.com/service-directory/PFO2JOO)
 
   [schematics-eu-prod-sev1](https://ibm.pagerduty.com/service-directory/PVD2XEI)
 
   [schematics-eu-prod-sev2](https://ibm.pagerduty.com/service-directory/P7HDIWG)
 
   [schematics-eu-prod-sev2-4-low-urgency](https://ibm.pagerduty.com/service-directory/PJVQHSN)
 
 `PD Escalation Policies`:
 
   [schematics-prod-sev1](https://ibm.pagerduty.com/escalation_policies#PNZJB5U)
 
   [schematics-prod-sev2-4](https://ibm.pagerduty.com/escalation_policies#PNFUE36)
 
   [schematics-low-urgency](https://ibm.pagerduty.com/escalation_policies#PVF4F77)

#### Availability
Clusters are Multi Zone

#### Scalability
None for now

#### Recovery & Backup
Cloudant/Replications/Backups of data are taken frequently

#### Dependency
Keyprotect/Cloudant/RabbitMQ and IAM

#### Capacity planning
None for now

---
## Miscellaneous
`No Runbook listed in this PD Incident`:

Please note this [Pager Duty Incident](https://ibm.pagerduty.com/incidents/PVPWAJX) will not contain a runbook. This is because they are triggered using an email. These PD Incidents need to be MANUALLY resolved when the issue is resolved.

Please follow the [runbook](https://github.ibm.com/blueprint/schematics-devops/blob/runbook_updates/runbooks/Alert_Schmtx_Endpoint_Down.md) to investigate this issue.


`Note`: The PD Incident [DOWN | Pool - schematics-prod-eu-de-pool](https://ibm.pagerduty.com/alerts/P7OOJBH) will be triggered when the `schematics-prod-eu-de-pool` is down. 
If it is back up again then [UP | Pool - schematics-prod-eu-de-pool](https://ibm.pagerduty.com/alerts/PJR7M7K) will be triggered. 
At this point these two PD Incidents need to be MANUALLY resolved.
 

---
## Schematics Architecture
- [Schematics Functional Overview](https://github.ibm.com/blueprint/getting-started/blob/schematics-2.0/docs/architecture/Arch_Core.md)

## Further Information
Please contact the schematics squad in the [#schematics-dev](https://ibm-argonauts.slack.com/archives/GHFT8J7CJ) slack channel for further information

