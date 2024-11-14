---
layout: default
title: How to create a new functional ID 
type: Informational
runbook-name: "How to create a new functional ID"
description: "How to create a new functional ID"
service: Conductors
link: /docs/ops_functional_id_creation.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook is here to provide instructions to create Functional IDs that may be needed for automation or other tasks.

## Detailed information

Below are the instructions to create a functional ID using the DRMS tool. This task is usually reserved for managers.


### Useful links:

* DRMS: https://w3.ibm.com/tools/drms/index.html?locale=en_US
* Bluepages: https://w3.ibm.com/bluepages/
* Identity Provisioning: https://prdbcraw3gen01.w3-969.ibm.com/itim/self/Home.do
* Thycotic to store new credentials: https://https://pim.sos.ibm.com/
* 1337 secrets (if needed) are defined in: https://github.ibm.com/alchemy-1337/asimov-bot-creds


## Functional ID creation

1. First, navigate to [DRMS](https://w3.ibm.com/tools/drms/index.html?locale=en_US) and click on `Add Record`
2. Input the following information
  ```
  PSC: 754 (Ireland) Note: Don't manage other GEOs or countries. It will cause complications further down
  Manager's Serial: I68892 (Andres Rehmann)
  PSC: 754 (Ireland)
  N (Non personal ID)
  ```
3. Submit. You will get an email to confirm that the ID was created
4. Wait for 2nd line manager's approval.
5. Once approval has been granted and 24 hours has passed, check bluepages to see if the new functional ID is listed under the creator. (Using Andres for example: https://w3.ibm.com/bluepages/profile.html?uid=I68892754)
6. If the new functional ID is correct and present, Login to [Identity Provisioning](https://prdbcraw3gen01.w3-969.ibm.com/itim/self/Home.do), as `FP_i68892754` using w3 password
7. Navigate to `View my requests` and complete the request you created
8. You will recieve an initial password via email from DRMS. This password will need to be reset via https://w3idprofile.sso.ibm.com/password/nonperson_id_entry.wss

NOTE: This runbook is a work in progress. More information is needed after step 8

**Note: Do NOT use non alphanumeric characters for email addresses** 

## Onboard the Functional ID to w3ID Password Rotation Automation 
 
1. Go to Access Hub Next Gen [here](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome)
2. Click on "Request New Access" and search "W3ID and BlueGroup Administrators" and hover over to click on "Request New Account" and apply access for "w3idProfileThycoticIds". This request will go to functional ID manager for approval first and then a Bluegroup team for approval.
3. Once AccessHub request is approved and complete, the credential should be stored under Secrets "BU044-ALC > BU044-ALC-Conductor > Functional ID > w3ID FID Credentials" in Thycotic. The credential should be saved with the following details:
- Under "General" please use the following:
  * Secret Name: Email address for the FunctionaL ID + " w3ID"
  * Template: BU044-ALC w3 Functional ID Password Rotation
  * BlueGroupName: w3idProfileThycoticIds
  * Username: The email address for the Functional ID
  * Password: The current w3ID password which would have been emailed to you when the ID was set up
- Under "Remote Password Changing" please use the following:
  * Change Password Using: Privileged Account
  * Privileged Account: svc-thycotic2 (<sub>*</sub>)
  * Auto Change Enabled: Yes
  * Next Password: Randomly Generated
  * Auto Change Schedule: Monthly
  * Change Every: 1 Months on First Tuesday 
  * Starting on: The First Tuesday of the next month
4. Test the Heartbeat for the saved Functonal ID credential in Thycotic and ensure the result is "Success"
5. The SOS documentation for w3ID Password Rotation Automation can be found [here](https://pages.github.ibm.com/SOSTeam/SOS-Docs/pim/w3Functional_id-PasswordRotation/)

<sub>*</sub>: If you do not have access to the `svc-thycotic2` account in Thycotic, you will need to ask permissions from the PIM admins. Open a ServiceNow ticket [here](https://ibm.biz/BdqD8G) with the following details:
  - Assignment group: "SOS ID Mgmt"
  - Severity: "Sev 3"
  - C_Code: "ARMADA"
  - Short Description: "Add access to svc-thycotic2"
  - Description: "I've reached step 3 of https://pages.github.ibm.com/SOSTeam/SOS-Docs/pim/w3Functional_id-PasswordRotation/#create-a-secret-for-w3id-password-rotation and want to set the "Privileged Account" to "svc-thycotic2", but that account doesn't show up when I search for it.  The docs suggest I need to request access to it"
  - Category: "Support"

## Escalation Policy

There is no formal escalation policy.

This is not a tool owned by the SRE squad. You should reach out to support on Help@IBM (W3)
