---
layout: default
title: Access control for Argonauts Squads - Pagerduty access
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

# Brief scope

This policy covers access control specific to requesting access to pagerduty

## Roles requiring Pagerduty access

Roles requiring pagerduty Access

- Development Squad member
- Development Squad Lead
- Development Squad Manager
- Development World Wide Technical Lead

- SRE Squad member
- SRE Squad Lead
- SRE Manager
- SRE World Wide Squad Lead
- SRE World Wide Technical Lead

- Network intelligence Squad member
- Network intelligence Squad Lead

## Roles authorised to approve Pagerduty access requests
- SRE Squad Lead
- SRE Manager
- SRE World Wide Squad Lead
- SRE World Wide Technical Lead

## Roles authorised to action Pagerduty access requests
- SRE Squad Lead
- SRE Manager
- SRE World Wide Squad Lead
- SRE World Wide Technical Lead

## Roles authorised to configure Pagerduty access

- SRE Squad Lead
- SRE Manager
- SRE World Wide Squad Lead
- SRE World Wide Technical Lead

## Process

## User requests access to Bluemix Pager Duty

- Sign in to the [IBM Pagerduty site](https://ibm.pagerduty.com) with your intranet ID
- Fill out your profile

Once your profile is complete, raise a [conductors team ticket](https://github.ibm.com/alchemy-conductors/team/issues/new) with title `Access control: Argonauts Pagerduty team access request` , requesting for your ID to be added to the following teams in Pagerduty.

The following teams are associated with the Argonauts tribe - The table details the team and the specific roles which are added to each team.

| Team  | Roles/Users who should get access |
|--
| Alchemy | All roles listed above in `Roles requiring Pagerduty access` |
| Event Streams Team | - SRE Squad Member<br>- SRE Squad Lead<br>- SRE Worldwide Squad Lead<br>-SRE World Wide Technical Lead |
{:.table .table-bordered .table-striped}

Request the following access in each team.
- For SRE engineers - `Manager`
- For non-SREs - `responder`

## Approval process

One of the roles authorised to approve access will review the request which will then be actioned, or they will reject it with a reason.

## Pagerduty configuration

Once an ID has been approved and access granted, someone from the list of approved roles to configure Pagerduty access will make the required changes to Pagerduty to configure the new user.


## Removing users from pagerduty team

Raise a [conductors team issue] with title, `Access control: Argonauts Pagerduty team access request`, detailing your Pagerduty userid, what role you are in and what teams you need to be removed from, and an authorised person will remove you from the Argonauts teams in pagerduty.

## SRE Leads:  processing access requests

Only authorised persons, as details in roles authorised to configure access, should update team access in pagerduty.

To process the request.

- Assign the [conductors team issue] to yourself.
- Navigate to [IBM pagerduty], click on `Configuration` -> `Teams`
- Search for the teams you need to add the user to
- Edit the team and either add or remove the user, depending on the request type.
- Save the changes to the team.
- Update the [conductors team issue] with actions taken and close the ticket if actions complete.

[conductors team issue]: https://github.ibm.com/alchemy-conductors/team/issues
[IBM pagerduty]: https://ibm.pagerduty.com/

Reviews

The process will be reviewed by management at least annually.

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
