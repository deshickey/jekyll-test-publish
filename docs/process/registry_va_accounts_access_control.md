---
layout: default
title: Access control for registry-stage and registry-prod accounts.
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

## Brief scope

This policy covers access control specific to the `registry-stage` and `registry-prod` IBM Cloud accounts. These accounts are used to deploy, manage and run the IBM Cloud Container Registry staging and production services.

## Roles authorised for access

- Registry squad member
- Registry functional ID
- VA squad member
- VA functional ID
- Netint squad member
- Netint functional ID
- SRE squad member
- SRE functional ID

## Roles authorised to approve access requests

- Registry squad lead
- VA squad lead
- SRE squad lead
- Registry/VA squad manager
- SRE squad manager

## Roles authorised to process access requests

- SRE squad

## The process

### Access request process

Authorised users requiring access should:

- Create an issue in [Conductors Team] requesting access to the desired account(s). `registry-stage` is account `1687267` and `registry-prod` is account `1455723`.
- Detail your role and why access is needed.

### Approval process

Only persons in the roles authorised to approve access requests.

- Authorised person performing the review will either;
  - Reject the request if the user should not have access to the accounts and close the ticket
  - Approve the request

### Adding access

Only requests which have been approved can be processed.

- The authorised person will grant the user access to the accounts and grant them appropriate privileges via IAM Group membership and application of a SoftLayer permissions [template].
- The authorised person will update the issue with actions taken and close the ticket if all actions are complete.

### Access levels by role

- Registry / VA squad member:
  - Access groups: **SQUAD, SQUAD_EU (if based in EU)**
  - Softlayer template: **registry\_squad\_read\_only**
- Netint squad member:
  - Access groups: **none**
  - Softlayer template: **Administrator**
- SRE squad member:
  - Access groups: **SRE, SRE_EU (if based in EU)**
  - Softlayer template: **usam.softlayer.admin**
- All functional IDs:
  - Access groups: FCT_ID
  - SoftLayer template: **Administrator**


### Removing access

The process is handled by roles authorised to approve and process access requests.

The line manager of the person whose access is to be removed should create an issue in [Conductors Team] requesting that access be removed.

The roles authorised to process approve requests should be assigned these issues.

Once approved, the roles authorised to process access requests will remove the user's access within 24 hours and will change the password of any functional IDs which also have access to registry systems.

## Access control review

The following reviews will be performed on an regular basis:

- Persons with access to the accounts will be reviewed quarterly by the Registry and VA 1st line manager to confirm that:
  - The person is employed (Quarterly Employment Verification).
  - The person has a Continued Business Need (CBN) to access the VA clusters.
- This access policy document will be reviewed annually for accuracy and updates made accordingly.

  An issue will be created for each document review in [VA Registry Team].

## How to collect evidence

Evidence will be collected at time of review, detailing who has access and that they are still in a role which allows them access to the accounts.

## Where to store evidence

Access and removal requests will be tracked and approved via GHE in [Conductors Team].

Access control reviews will be tracked by an issue in [VA Registry Team]

[template]: https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web
[VA Registry Team]:https://github.ibm.com/alchemy-registry/team
[Conductors Team]: https://github.ibm.com/alchemy-conductors/team

## Reviews

The process will be reviewed by management at least annually.

Last review: 2024-07-09 Last reviewer: Michael Hough Next review due by: 2025-07-09
