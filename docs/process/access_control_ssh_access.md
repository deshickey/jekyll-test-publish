---
layout: default
title: Access control for Argonauts Squads - openVPN and IBM Infrastructure machine access
type: Informational
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

## Brief scope

This policy covers access control specific to requesting ssh access to servers in Alchemy owned IBM Infrastructure accounts (Softlayer).

## Roles requiring Access

- SRE Squad Member
- SRE Squad lead
- SRE Worldwide Squad Lead
- SRE Worldwide Technical Lead
- Development Squad member
- Development Squad lead
- Development Technical Lead

## Roles authorised to approve access requests

Tier 1:
The requestors Bluepages Manager will provide an initial approval.

Tier 2:

A second level of approval by technical contacts

For development/prestage role:
- Development Managers

For Production roles:

- SRE Technical lead
- SRE World Wide Manager
- SRE World Wide Squad Lead


## Roles authorised to process access requests

The processing of this user in AccessHub will be performed by the Shared Operational Services Squad who own the SOS IDMgt/Active Directory servers.

Once tier 1 and tier 2 approvals are complete, the user will be added to SOS IDMgt/Active Directory and their ID associated with the groups they have been authorised to be part of.


## Level of access

| Role  | Access granted |
|--
| Conductor | Grants access to all machines in all IBM Infrastructure accounts |
| GROUPNAME-Developer | Grants access to all dev and prestage machines of that group |
| GROUPNAME-Staging | Grants access to all Staging machines of that group |
| GROUPNAME-Production | Grants access to all Production machines of that group |
| GROUPNAME-Production_EU | Grants access to all Production EU based machines of that group |
| GROUPNAME-Production_EU_EMERG | Grants emergency temporary access to all Production EU based machines of that group |
{:.table .table-bordered .table-striped}

## Groups

The following is a list of groups which users can be associated with.  One or more of these groups must be selected when requesting access.
The table details the servers each group provides access to.

| Group name  | Machines access is granted to  | Groups / individuals who are allowed access |
|--
| BU044-ALC-Compose | Compose servers |<br>- SRE Squad lead<br>- SRE Worldwide Squad lead<br>- SRE Worldwide Technical Lead<br>- Development Squad Lead<br>-Development Technical Lead |
| BU044-ALC-Compose_EU | Compose servers |  EU Based persons in these capacities:<br>- SRE Squad lead<br>- SRE Worldwide Squad lead<br>- SRE Worldwide Technical Lead<br>- Development Squad Lead<br>-Development Technical Lead (EU Based) |
| BU044-ALC-Compose_EU_EMERG | Compose servers  | Any of the following groups requiring emergency access:<br>- SRE Squad lead<br>- SRE Worldwide Squad lead<br>- SRE Worldwide Technical Lead<br>- Development Squad Lead<br>-Development Technical Lead  |
| BU044-ALC-Conductor | All servers | - SRE Squad member<br>- SRE Squad lead<br>- SRE Worldwide Squad lead<br>- SRE Worldwide Technical Lead <br>- Network intelligence Squad Member<br>- Network intelligence Squad Lead |
| BU044-ALC-Conductor_EU | All servers | All EU based in these roles:<br>- SRE squad member<br>- SRE Squad lead<br>- SRE Worldwide Squad lead<br>- SRE Worldwide Technical Lead<br>- Network intelligence Squad Member<br>- Network intelligence Squad Lead |
| BU044-ALC-Conductor_EU_EMERG | All servers | All Non EU Based requesting temporary emergency access in:<br>- SRE squad member<br>- SRE Squad lead<br>- SRE Worldwide Squad lead<br>- SRE Worldwide Technical Lead<br>- Network intelligence Squad Member<br>- Network intelligence Squad Lead  |
| BU044-ALC-DockerIBM-Developer | Docker at IBM servers | In the Docker at IBM squad in:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead  |
| BU044-ALC-DockerIBM-Staging | Docker at IBM servers | In the Docker at IBM squad in:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead  |
| BU044-ALC-DockerIBM-Production | Docker at IBM servers | In the Docker at IBM squad in:<br>Development Squad lead<br>- Development Technical Lead  |
| BU044-ALC-IDCC-Developer | All IBM Container, Vulnerability advisor and Registry servers (Armada Squad) | In any of the Armada squads in:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead |
| BU044-ALC-IDCC-Staging | All IBM Container, Vulnerability advisor and Registry servers (Armada Squad) | In any of the Armada squads in:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead |
| BU044-ALC-IDCC-Production | All IBM Container, Vulnerability advisor and Registry servers (Armada Squad) | In any of the Armada squads in:<br>Development Squad lead<br>- Development Technical Lead |
| BU044-ALC-IDCC-Production_EU | All IBM Container, Vulnerability advisor and Registry servers (Armada Squad) based in the EU | In any of the Armada squads in the EU:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead |
| BU044-ALC-IDCC-Production_EU_EMERG | All IBM Container, Vulnerability advisor and Registry servers (Armada Squad) based in the EU | All Armada Developers outside of the EU requiring emergency access:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead  |
| BU044-ALC-KeyProtect-Developer | Access to Keyprotect dev and prestage servers | Any KeyProtect Squad in:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead |
| BU044-ALC-KeyProtect-Staging | Access to Keyprotect stage servers | Any KeyProtect Squad in:<br>- Development Squad member<br>Development Squad lead<br>- Development Technical Lead |
| BU044-ALC-KeyProtect-Production | Access to Keyprotect production servers | Any KeyProtect Squad in:<br>Development Squad lead<br>- Development Technical Lead |
{:.table .table-bordered .table-striped}

## Process

### Overview

All Alchemy squads use SOS IDMgt to manage user access to all environments in IBM Cloud Infrastructure (Softlayer).
Requesting access is via [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome).  

Use the table above to determine which groups you should request access to.

As a result of IBM EU Cloud, some production environments have more restricted access and access is only granted to persons in the EU.  
If you are in SRE or development and are based in the EU, then you also need additional access via groups with the `_EU` suffix.  

The access granted via SOS IDMgt groups will allow for bot machine access and openvpn access to our environments. Read the  [openvpn setup](../runbooks/vpn.html) runbook to enable access.

If you have any further question or have problems with your SOS IDMgt id, consult the Conductors squad via [{{ site.data.teams.containers-sre.comm.name }}]({{ site.data.teams.containers-sre.comm.link }})

### Access request process

NOTE on usernames: when creating a new SOS IDMgt user you must avoid picking any username that appears on any machine that supports SOS IDMgt logins --- even if that username belongs to you for some other reason and your intention is to retire it.  This stricture is not checked by SOS IDMgt.
If you violate this restriction, it will cause pain down the road for several people.  If in doubt, check with the SRE squad.

1. Go to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome).
2. Click on **Request or Manage Access**
3. Search for **SOS IDMgt** in the **All Applications** search box.
4. Click on **Add to cart**.
5. Click on **Checkout**.
6. Enter a **Account Name** for yourself (for example, use your intranet short name)
7. In the **Brand Type** field type **BU044-ALC**
8. Find the group from the table above in the **Available Groups** section. You can use the search box to find it quickly.
9. Click **Add**.
10. When you have added all the **Groups** you are requesting, click on **Next** at the bottom of the page.
11. Enter a **business justification**.  This should detail the `squad` you are in, the `region` you are in (important for EU confirmation), and the reason you need access to each `group and role`.
12. Click **Submit**

### Access update process

1. Go to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome).
2. Click on **Request or Manage Access**
3. Search for **SOS IDMgt** in the **All Applications** search box.
4. Click on **Modify Existing Account** .
5. Click on **Checkout**
6. Enter a **Account Name** for yourself (for example, use your intranet short name).
7. In the **Brand Type** field type **BU044-ALC**
8. Find the group from the table above in the **Available Groups** section. You can use the search box to find it quickly.
9. Click **Add**.
10. Alternatively click **Remove** to remove an existing group.
11. When you have added all the **Groups** you are requesting, click on **Next** at the bottom of the page.
12. Enter a **business justification**.  This should detail the `squad` you are in, the `region` you are in (important for EU confirmation), and the reason you need access to each `group and role`.
13. Click **Submit**

### Revoking access process

1. Go to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome).
2. Click on **Request or Manage Access**
3. Search for **SOS IDMgt** in the **All Applications** search box.
4. Click on **Remove Account**.
5. Click on **Checkout**.
6. Add a **business justification** and **Submit** the request.

### Approval process

An approval process is built into the AccessHub tool.
Each request requires approval from the requestors manager(see tier 1 at the top of this process) and a technical approval (see tier 2 at the top of this process).

Individuals can check their [approval status here](https://ibm-support.saviyntcloud.com/ECM/jbpmworkflowmanagement/showmyhistoryrequests).

For all BU044 groups, approval goes to the following role:

For development and prestaging requests (i.e: `<GROUP>-Developer` in AccessHub)

- Development Manager

For Staging and Production requests (i.e: `<GROUP>-Staging` ,`<GROUP>-Production`, or an `_EU_`)

- SRE Worldwide Manager
- SRE Worldwide Squad lead
- SRE Technical lead

### Management of access

Once your account has been created, you will be assigned a password that expires on first log-in. Due to the way accounts are handled on linux machines you may be unable to log in until you have changed your password.  Use one of the Following sites to perform a reset:

### Password reset options

SOS IDMgt Password reset site

1. Visit [SOS IDMgt reset user](https://password.sos.ibm.com/default.aspx)
2. Select search by Mail address or CNUM.
3. Enter the email address or employee number.
4. Select **Reset** against the **userID** you wish to change.
5. An email will be sent to you.
6. Use the link in the email to take you to a page to enter your new password.



## Requesting EU emergency access

Temporary access to EU based servers is available in the event of an emergency and not business as usual activities.

Non EU citizens should not request access to any `EU` groups as standard, and should only request access to the `EU_EMERG` group(s) if and when needed following the guidance here.

Users should follow the process documented in the [Obtaining EU access] runbook. Note that this still uses **USAM** and not **AccessHub**.

There is supporting information and a playback available in [Obtaining EU Access slide deck] and [obtaining EU access recording] - NB: Presentation is from 12mins onwards in the recording.

[Obtaining EU access for IKS]:  ../runbooks/conductors_eu_cloud_iks.html
[Obtaining EU access for Satellite]:  ../runbooks/conductors_eu_cloud_sat.html
[Obtaining EU Access slide deck]: https://ibm.box.com/s/lvpok2qptq3c3yjt3v1khf9spj2zcckg
[obtaining EU access recording]: https://ibm.box.com/s/f6ugmyqcgdffi7pdj7hn5pih11r0qjt8
[openvpn setup]: ../runbooks/vpn.html

## Reviews

The process will be reviewed by management at least annually.

Last review: 2022-08-18
Last reviewer: Hannah Devlin
Next review due by: 2023-08-18
