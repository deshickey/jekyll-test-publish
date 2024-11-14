---
layout: default
title: Access control for Argonauts Squads
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

# Policy: Access control

## Purpose

This document covers the correct use and management of access controls throughout the IBM Containers Argonauts organisation.

The purpose of the policy is to define the correct use of access controls within the IBM Containers tribe.

## Policy Requirements
Each resouce is required to meet or exceed the following requirements:
- Individual accountability for all persons accessing all systems
  - Access is only granted after all approvals are in place. ([Emergency access is considered an exception from the normal process](access_control_emergency_access.html))
  - Access must be revoked in a timely fashion when no longer required/upon termination.
  - Use of shared IDs must be tracked back to an individual using a shared ID.
- Separation of duties for individuals into roles based on their business needs. Roles are used to categorize access granted to individuals who are associated to a specific role.
  - Separate organization-defined duties of individuals
  - Define system access authorizations to support separation of duties
  - Document separation of duties of individuals 
- Employ the principle of least privilege, allowing only authorized accesses for users (or processes acting on behalf of users) which are necessary to accomplish assigned tasks in accordance with organizational missions and business functions.
- Access control at each of those layers is enforced via usernames and complex passwords
- A documented process for requesting, approving, re-validating (periodically), and revoking access exists

## Policy/Process Scope
Each resource is required to address the policy requirements for the following processes:
- Access Request
- Request Approval
- Re-Validation (Quarterly)
- Prompt revocation of access upon termination or team reassignment

## Audit Requirements 
Each resource is required to provide the following audit outputs:
- A list of all userids (individual, shared, local, functional, etc) with access to any resources in your inventory; e.g. Armada clusters, firewall devices, SoftLayer accounts, databases, etc
- For each user, show that their access was requested, approved and tracked
- For production access, show that the [Production Onboarding process](./production_onboarding.html) was completed before the user's access was approved.
- Demonstrate that their access was reviewed once in the last quarter (Continuous Business Need)
- For functional/shared IDs, demonstrate how access is controlled, e.g. password vault
- Provide records of [off-boarding](./production_offboarding.html) of users who have left IBM. (including proof 
passwords changed if using a shared ID or proof that the former IBMer cannot utilize the password)
- When a user changes role, their access must be changed appropriately for their new role and any access no longer required by the user must be revoked.

## Scope
The following resources have been identified as having their own access control, identity, authentication, and authorization requirements.  Each resource is required to meet the standards set forth by the policy herein. 

- Machine access
  - OpenVPN access to Softlayer infrastructure
  - ssh access to Development servers in Softlayer
  - ssh access to Prestaging servers in Softlayer
  - ssh access to Staging servers in Softlayer
  - ssh access to Production servers in Softlayer
  
- Pipelines
  - Jenkins
  - Travis
  - Razee
  
- GHE Organization Repos
  - Cloud Functions GHE
  - Containers GHE
  - Conductors GHE
  - 1337 GHE
  - SRE Bots GHE
  - Registry Squad GHE
  - Vulnerability Advisor Squad GHE
  - Netint GHE

- Other Access
  - Local IDs on network/firewall devices (Vyattas)
  - IBM Infrastructure non-linked accounts
  - IBM Infrastructure / IBM Cloud linked accounts
  - LaunchDarkly
  - Akamai
  - PagerDuty
  - Slack
  - ServiceNow

## Account Privileges

- Access rights and privileges to systems will be allocated based on the specific requirement of a users role / function

- The criteria used for granting access privileges must be based on the principle of “least privilege” -  authorized users will only be granted access to systems which are necessary for them to carry out the responsibilities of their role or function.

- Care must be taken to ensure that access privileges granted to users do not unknowingly or unnecessarily undermine essential separation of duties.  For example, no one can approve their own access request.

- The creation of user access accounts with special privileges such as administrators must be rigorously controlled and restricted to only those users who are responsible for the management or maintenance of the system.

## Account registration

-  Requests for access to specific resource/accounts should be made according to the specific instructions in each related document in the section below.

- Squad Leads and / or Managers may complete this on behalf of new squad members

- Approvals must be obtained for each request from the authorized approvers detailed in each access request document in the section below.

- For production access, the [Production Onboarding process](./production_onboarding.html) must be completed by the user before the user's access is approved.

- Only approved requests should be processed.

## Account management

- Existing user’s who require additional access privileges on an system must gain authorization of the designated owner/approver as detailed in the access request document in the section below.

## Account de-activation

The following circumstances will drive account de-activation

- Leaving employment in IBM
- Leaving the IBM Containers tribe

The users line manager or Squad Lead is responsible for raising a request to get the account of a user revoked/removed.  
The designated owner, as detailed in the access request document in the section below, will then process this request.
As per the [IBM Cloud Authentication & access control policy](https://pages.github.ibm.com/ibmcloud/Security/guidance/baseline/authenticationaccess.html#authentication--access-control), credentials which can be used over the internet by someone who has left IBM must be updated within 24 hours of separation.

## Roles involved in access control requests and approvals

The following are roles discussed in this document and link access control documents

| Role  | Role description |
|--|--|
| Development Squad Member | A member of one or more of the IBM Containers development squads |
| Development Squad Lead | Squad Lead for an IBM Containers development squad |
| Development Manager | Manager of one or more IBM Containers development squads |
| Development Technical Lead | Tech leads in the Containers tribe - roles such as Distinguished Engineers or STSMs |
| SRE Squad Member | A member of the world wide SRE squad |
| SRE Squad Lead | SRE Squad Lead for a specific Geo |
| SRE Squad Manager | SRE Squad Manager for a specific Geo |
| SRE World Wide Squad Lead | World Wide SRE Squad Lead responsibilities |
| SRE World Wide Manager | World Wide SRE management responsibilities |
| SRE World Wide Technical Lead | World Wide SRE Technical leadership responsibilities |
| IBM Security focal for IBM Container service | Interested in Security and enforcing security requirements in the tribe |
| Network intelligence Squad member | Member of the NetInt squad |
| Network intelligence Squad Lead | Lead for Netint squad |
{:.table .table-bordered .table-striped}



## Reviews

The process will be reviewed by management at least annually.

Last review: 2024-07-11 Last reviewer: Hannah Devlin Next review due by: 2025-07-10


