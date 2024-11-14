---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Defining and managing SOS IDMgt groups
service: SOS IDMgt
title: SOS IDMgt Group Configuration
runbook-name: "Defining new SOS IDMgt groups for Alchemy"
link: /sso_groups.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

Defining new groups
-------------

## Overview

The Purpose of this runbook is to help a member of the SRE team submit a request to the SOS team to define new SOS IDMgt groups.

## Detailed Information

### Group names

Ralph will need to approve all requests and group names.
Work with Ralph to define a suitable name for the team requesting a SOS IDMgt group.

Our names are usually in this format:

`BU044-ALC-<ROLE>-<ENVIRONMENT>` where ROLE is a descriptive of the role for this group, and ENVIRONMENT references which environment the group is for (i.e. Prod, stage, development)

`BU044-ALC-<ROLE>-<TEAM>-PIM` is used to identify groups used for accessing Privileged Information Manager (PIM) which is currently Thycotic.

## Detailed Procedure

### Submitting a request

The requests are submitted to the SOS team for processing. These instructions are taken from [SOS IDMgt - Premium Service](https://pages.github.ibm.com/SOSTeam/SOS-Docs/idmgt/howto/boardingIDMgt-premium.html)

1. Download [Group Request Spreadsheet (Box)](https://ibm.box.com/s/htjiks1exev6p0fpv06o91ub52ouwpfv)

2. Edit the spreadsheet to add the new groups. For example:

   Group   Name | Description | Access Criteria     (Start with *Priv* or *Non-Priv*)
   -- | -- | --
   BU044-ALC-IDCC-Deploy-PIM | Deploy  squad access to Thycotic | *Non-Priv* Access to functional and shared id credentials
   BU044-ALC-IDCC-Update-PIM: | Update squad access to Thycotic | *Non-Priv* Access to functional and shared id credentials

3. Follow the [Service Request Ticket](https://pages.github.ibm.com/SOSTeam/SOS-Docs/general/servicenow.html) steps to submit a request to the SOS IDMgt team to create these new groups. 
Remember to attach an updated spreadsheet.

### Post actions for PIM (Thycotic) access:

A new folder needs to be created in Thycotic by the SOS PIM team. Here is an example of a previous team ticket that added access to Thycotic [Issue 10198](https://github.ibm.com/alchemy-conductors/team/issues/10198

1. Follow [Service Request Ticket](https://pages.github.ibm.com/SOSTeam/SOS-Docs/general/servicenow.html) steps to submit a request to the SOS PIM team to create these new folders. 

- Short description: `Request for new folders in Thycotic controlled by new AD groups1`

- Example body: 
  ```
  Please can you create folders with access controlled by the following SOS IDMgt groups:

  BU044-ALC-IDCC-Deploy-PIM
  BU044-ALC-IDCC-Update-PIM
  ```

2. Once the folders have been created notify the team that they can start requesting access via AccessHub to the new SOS IDMgt group. 



### Post actions for environment access:

The new SOS IDMgt group needs to be added to the bootstrap process.

The following changes need to be made:

1. Add the SOS IDMgt groups to the relevant  [group_vars](https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/group_vars) files for each environment.
1. Add configuration under [add_usam_groups.yml](https://github.ibm.com/alchemy-conductors/bootstrap-one/blob/master/playbooks/roles/usam-config/tasks/add_usam_groups.yml) playbook to add the new group to the relevant servers.
1. Update the configuration for [openVPN](https://github.ibm.com/alchemy-conductors/conductors-playbooks/tree/master/playbooks/roles/openvpn-usam-groups/files) to authenticate these groups

Here is an example when we added the [front door team](https://github.ibm.com/alchemy-conductors/team/issues/92)


