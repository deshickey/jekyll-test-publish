---
layout: default
title: Access control for Argonauts Squads - SOS Security Center
type: Informational
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

# Brief scope

This policy covers access control specific to requesting access to the Shared Operational Services [Security Center console](https://w3sccv.sos.ibm.com/) used to manage Nessus vulnerability scans.

**Note:** The Security Center tools are closely integrated with the SOS Inventory. Before getting access to Security Center, you must first have access to the SOS Inventory as described [here](./access_control_sos_inventory.html).

## Roles requiring access

- SRE Squad Member
- SRE Squad Lead
- SRE Worldwide Squad Lead
- Network Intelligence Squad Member
- Network Intelligence Squad Lead

## Roles authorised to approve access

- SRE Squad Lead
- SRE Worldwide Squad Lead

Nobody may approve their own access request.

## Roles authorised to process the request

- SRE Squad Lead
- SRE Worldwide Squad Lead
- Security Focal

Nobody may process their own access request.

## SOS Inventory Roles used

- BU Security Analyst - can view security scans, asset lists, policies and status
- BU Security Manager - can do everything the BU Security Analyst can, plus they can change configuration, add/remove users, and re-submit scans

Note: "BU" refers to "Business Unit". This is just the naming convention used by SOS.

Note: the SOS doc [Role-Definitions-in-Security-Center](https://pages.github.ibm.com/SOSTeam/SOS-Docs/sca/Role-Defintions-in-Security-Center/#general-roles-definitions) suggests that `BU Security Analyst` is sufficient to re-submit scans; however, it is not. It is only sufficient to re-submit _scans that you created yourself_. Hence for most of SRE, `BU_Security Manager` is required to take action on failed scan alerts. Ref discussion in issue[22051](https://github.ibm.com/alchemy-conductors/team/issues/22051).

## Roles requiring access and access levels granted

### Security Center Roles

| Role  | Access granted to |
|-------| ----------------- |
| BU Security Analyst (BU_Security_Analyst) | - Network Intelligence Squad Member |
| BU Security Manager (BU_Security_Manager) | - SRE Squad Member<br/>- SRE Squad Lead<br/>- SRE Worldwide Squad Lead <br/>- Network Intelligence Squad Lead<br/> - Security Focal |

## Process

### Access request process

This can be performed on behalf of a new user, but the person raising the request **cannot** approve then process the request, even if they are in both of the roles authorised to do so.


- The user should open [AccessHub](https://ibm-support.saviyntcloud.com/ECM/workflowmanagement/requesthome?menu=1) and select **Manage Access**  
   1) Select System:  
    Search for the `SOS-IDMgt` system, select **ADD TO CART** and then click **Checkout**  
   2) Select Access:  
      - Specify the desired **USER ID**
      - Set **Brand Type** to `BU044-ALC` or `BU410-ALC_FR2`
      - In the **Available memberOf** search field, specify `SecurityCenter`  
      - Click the **ADD** button next to the `SOS-SecurityCenter` entry  (NB: The name depends on the brand you are ordering for)
      - Click the **Next** button  
   3) Provide a justification: _I'm joining the \<squad\> in \<location\> as a \<role\>_  
   4) Click **Submit**
   5) Repeat if multiple accesses are needed 
  
    Add the SOS Security Center ID to the GHE issue via a comment.
 
 Only when the AccessHub request has been approved should the user go on to request an appropriate person to add them to Security Center
 
- Raise a GitHub enterprise issue in the GHE repository which the Squad uses for their work.
- In the request provide a title of `ACCESS REQUEST: SOS Security Center access request for <Intranet ID>` providing details of the user to be added, the users SSO ID and email address and the role to be granted.
- The person raising the request should assign the request in GHE to one of the roles authorised to review access requests.

#### Approval process

Any role in the authorised approvers list can approve new requests (with the exception of their own requests). Approval will be indicated by the approver attaching an approval label to the GHE issue.

#### Adding new users to Security Center

The first step must be performed by someone with authority to approve user group memberships in SOS-IDMgt for the `BU044-ALC/BU044-ALC-SOS-SecurityCenter` group:

- Approve the pending AccessHub transaction to add the new user to the `BU044-ALC/BU044-ALC-SOS-SecurityCenter` group in the `SOS-IDMgt` system.

The remaining steps of this process must be performed by a `BU Security Manager`, who will be in one of the job roles listed above.

1. Open [Security Center](https://w3sccv.sos.ibm.com/) and navigate to the Users view.

2. Click the Add button at the top left.

3. Don't fill out most of the fields as we will use LDAP lookup to populate the record. Instead:

    - From the `Type` list, select `LDAP`. Additional LDAP fields will appear.
    - Enter new user's surname (family name) after the `sn=` string in the `Search String` field and click the Search button. For example, for Fred Bloggs the surname is `Bloggs` so enter `sn=Bloggs`
    - Check the `LDAP users found list` and select the correct SOS IDMgt ID from the list. If no user is found then check they have requested access to the `BU044-ALC/BU044-ALC-SOS-SecurityCenter` group and that their SOS IDMgt group membership has been approved.
    - Ensure that the `Username` field contains the correct SOS IDMgt ID. If not, change this field to match.
    - Fill out the other fields. The following are required:
        - `First Name`
        - `Last Name`
        - `Time Zone`
        - `Scan Result Default Timeframe`: `Last 120 days`
        - `Membership -> Role` as appropriate to the job role, shown in the table above
        - `Membership -> Group`: `ALC_GRP`
        - `Responsibility -> Asset`: `All Defined Ranges`
    - Click the Submit button to create the user.

4. Raise an SOS ticket for the permissions to be manually applied.

    - See here for how to [Create a Ticket](https://pages.github.ibm.com/SOSTeam/SOS-Docs/general/servicenow/#servicenow-configurations-for-sos) in ServiceNow
    - Select `Assignment group = SOS Vulnerability Scanning`
    - Select `C_CODE = ALC`
    - Select `Category = Support`
    - Select `Priority = Sev - 3`
    - List the SOS usernames of the new users, and request that they be granted access to edit and re-submit scans.

**Attention:** The user must be a member of the SOS IDMgt group before they are added in Security Center. The SOS team will remove any user for which there is no corresponding SOS IDMgt group membership without warning. It is important to follow this process in the correct order.

### Access removal process

This can be performed on behalf of a user, but the person raising the request **cannot** then process the request, even if they are in the roles authorised to do so.

- Raise a GitHub enterprise issue in the GHE repository which the Squad uses for their work.
- In the request provide a title of `ACCESS REMOVAL: SOS Security Center access for <Intranet ID>` providing details of the user to be removed including the user's SOS IDMgt ID.

#### Removing users

The following steps must be performed by a BU Security Manager, who will be in one of the job roles listed above.

1. Open [Security Center](https://w3sccv.sos.ibm.com/) and navigate to the Users view.

2. On the right-hand side below the Add button is a filters icon. Click the filters icon.

3. Click the Name filter field, enter the name of the user to be removed and click the Apply button. Partial name strings may be supplied and Security Center will show all users whose name includes the specified substring.

4. Locate the user to be removed in the list and click their name to open the user record.

5. Change the `Membership -> Role` field to `None`.

6. Take note of the user's SOS IDMgt ID from the `Username` field.

7. Click the Submit button to revoke the user's access.

The final step must be performed by someone with authority to revoke user group memberships in SOS-IDMgt for the `BU044-ALC/BU044-ALC-SOS-SecurityCenter` group:

- Remove the user from the `BU044-ALC/BU044-ALC-SOS-SecurityCenter` group in the `SOS-IDMgt` system.


Reviews

The process will be reviewed by management at least annually.

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
