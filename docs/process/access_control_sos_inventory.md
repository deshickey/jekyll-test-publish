---
layout: default
title: Access control for Argonauts Squads - SOS Inventory
type: Informational
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

## Brief scope

This policy covers access control specific to requesting access to the Shared Operational Services Inventory used to manage security compliance.

We use three inventories identified by their SOS Client Code (C_Code):
- [ALC](https://w3.sos.ibm.com/inventory.nsf/index.xsp?c_code=alc) - inventory for the SoftLayer accounts 659397, 1858147, 278445 and 531277
- [ALC_FR2](https://w3.sos.ibm.com/inventory.nsf/index.xsp?c_code=alc_fr2) - inventory for the SoftLayer account 2051458
- [ARMADA](https://w3.sos.ibm.com/inventory.nsf/index.xsp?c_code=armada) - inventory for services on Armada onboarded via [ibmcloud csutil](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI)

## Roles requiring access

- SRE Squad Member
- SRE Squad Lead
- SRE Worldwide Squad Lead
- Network Intelligence Squad Member
- Network Intelligence Squad Lead
- Security Focal
- Compliance Focal
- Development Squad Member (only when they have a specific business need to do compliance-related work)

## Roles authorised to approve access

- SRE Squad Lead
- SRE Worldwide Squad Lead
- SRE Worldwide Manager

Nobody may approve their own access request.

## Roles authorised to process the request

- SRE Squad Lead
- SRE Worldwide Squad Lead
- SRE Worldwide Manager

Nobody may process their own access request.

## SOS Inventory Roles used

- Reader - can view security compliance status information
- Editor - can view and edit security compliance status information

## Roles requiring access and access levels granted

## SOS Inventory Roles

| Role  | Access granted to |
|-------| ----------------- |
| Reader | - Network Intelligence Squad Lead<br/>- Network Intelligence Squad Member<br/>- Development Squad Member |
| Editor | - SRE Squad Member<br/>- SRE Squad Lead<br/>- SRE Worldwide Squad Lead<br/>- Security Focal<br/>- Compliance Focal |

## Process

### Access request process

### ALC and ALC_FR2 access

Access is authorised and granted via AccessHub.

The user requiring access should open [AccessHub](https://ibm-support.saviyntcloud.com/ECM/workflowmanagement/requesthome?menu=1) and select **Request or Manage Access**  
   1) Select Application:  
    Search for the `SOS IDMgt` system, select either **MODIFY EXISTING ACCOUNT** if you already have an SOS-ID or **ADD TO CART** if setting up a new ID, and then click **Checkout**  
   2) Select Access:  
      Repeat the below steps for each of these **Brand Types** - `BU044-ALC` and `BU410-ALC_FR2`
      - Specify the desired **USER ID**
      - Search for **Brand Type** (see list above)
      - In the **Available Groups** search field, specify `inventory`  
      - Click the **ADD** button next to the `SOS-Inventory-Reader` and `SOS-Inventory-Editor` entries  
   3) Once all brands have been added, click the **Next** button  
   4) Provide a justification: _I'm joining the \<squad\> in \<location\> as a \<role\>_  
   5) Click **Submit**

### Armada Access

Access to the `ARMADA` inventory (to see kubernetes clusters machines compliance) is also controlled via `AccessHub` and is detailed in [adding-additional-users](https://pages.github.ibm.com/SOSTeam/SOS-Docs/armada/adding-additional-users.html).  

IKS SREs should request access to the following AccessHub groups 

- BU203-ARMADA-containers-kubernetes-SOS-Inventory-Reader
- BU203-ARMADA-containers-kubernetes-dev-SOS-Inventory-Reader
- BU203-ARMADA-containers-kubernetes-tugboat-SOS-Inventory-Reader
- BU203-ARMADA-satellite-link-SOS-Inventory-Author

Once approved, an SRE lead will need to then add you to the relevant [SOS application record](https://w3.sos.ibm.com/inventory.nsf/index.xsp?c_code=armada&viewName=Applications) as a security focal.

### Approval process

Only approvers defined in AccessHub can approve persons to be added to the SOS inventory for ALC and ALC_FR2 brands.

### Adding new users

#### Adding users to the ALC and ALC_FR2 inventory

This is an automated process which occurs after AccessHub approval process has completed.  
Previously, SRE leads have had to update access in domino groups in the [SOS Inventory dbnames database](https://w3.sos.ibm.com/inventory.nsf/dbnames.xsp)

Editing these groups is no longer required. 

#### Adding new users to the ARMADA SOS Inventory

Once `AccessHub` access has been granted for a user, follow these steps to add them as a `Security Focal`.

1. Open the [ARMADA Inventory](https://w3.sos.ibm.com/inventory.nsf/index.xsp?c_code=armada).

1. Click the Applications list.

1. Locate the following applications:
    - container-registry
    - containers-kubernetes
    - containers-kubernetes-tugboat
    - containers-kubernetes-tugboat-fr2
    - satellite-config
    - satellite-link
    - satellite-location

1. Double-click each application in turn. With each application:
    - Click the Edit button at the top to put the application into edit mode.
    - Locate the Security Focals field.
    - Add the person's notes ID to the Security Focals field. Take care to leave the list cleanly comma-separated.
    - Click the Save button to save the changes, then close the browser tab.

1. The user will need to restart their web browser and clear its caches in order for the access change to take effect.

### Removing users

#### Removing users from the ALC and ALC_FR2 SOS Inventory

- If leaving IBM, this should be automatically performed when their AccessHub IDs are automatically removed.

- If moving roles/departments within IBM, the user needs to have their AccessHub group membership updated.  Removing access to these groups will automatically remove their access.

#### Removing users from the ARMADA SOS Inventory

Access to the ARMADA inventory is controlled as described in [adding-additional-users](https://pages.github.ibm.com/SOSTeam/SOS-Docs/armada/adding-additional-users.html).

When offboarding, users should request removal of the `BU203-ARMADA-SOS-Inventory-Author` group

SRE Leads should also remove users from the Security Focal list using the steps below

1. Open the [ARMADA Inventory](https://w3.sos.ibm.com/inventory.nsf/index.xsp?c_code=armada).

1. Click the Applications list.

1. Locate the following applications:
    - container-registry
    - containers-kubernetes
    - containers-kubernetes-tugboat
    - containers-kubernetes-tugboat-fr2
    - satellite-config
    - satellite-link
    - satellite-location


1. Double-click each application in turn. With each application:
    - Click the Edit button at the top to put the application into edit mode.
    - Locate the Security Focals field.
    - Remove the person's notes ID from the Security Focals field. Take care to leave the list cleanly comma-separated.
    - Click the Save button to save the changes, then close the browser tab.


Reviews

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
