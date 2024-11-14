---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Create new SOS ID for Privileged Access Gateway(PAG) access
type: Informational
runbook-name: "Create new SOS ID for Privileged Access Gateway(PAG) access"
description: "Create new SOS ID for Privileged Access Gateway(PAG) access"
service: Conductors
link: /docs/runbooks/pag/pag_sosid.html
grand_parent: Armada Runbooks
parent: PAG
---

Informational
{: .label }

# Create new SOS ID for Privileged Access Gateway(PAG) access

## Overview
Privileged Access Gateway(PAG) is using IBM unique id as username when connecting to VSIs via ssh. In order to leverage SOSAD and linux PAM scripts already existing on our machines, all SRE and Dev users should request a new SOSID, which will be only used for PAG integration.

## Detailed Information
### Where can I find my IBM unique Id?
If you have the proper access to list account users you can use the following command by replacing `${USER_EMAIL}` with your email address (**lowercase**)
```
ic account users --output json | jq -r '.[] | select(.userId | ascii_downcase == "'${USER_EMAIL}'") | .ibmUniqueId'
```

If not, please reach out to SRE in [#conductors](https://ibm.enterprise.slack.com/archives/C54H08JSK)

### Create a new SOSId
1. Go to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome)
1. Click on `Request Access for Self` \
<img src="./images/pag_sosid_1.png" style="width: 600px;"/>
1. Click on `SOS IDMgt` \
<img src="./images/pag_sosid_2.png" style="width: 600px;"/>
1. Click on `Request New Account` \
<img src="./images/pag_sosid_3.png" style="width: 600px;"/>
1. Fill the required information
  - Account Name: `Your IBMID` (`IBMid-XXXXXXXXX`)
  - Brand: `BU044-ALC`
  - Under `Groups` click on `Add` \
<img src="./images/pag_sosid_4.png" style="width: 600px;"/>
1. Select the group
   - SRE:
     - `BU044-ALC-Conductor` (Needed for all SREs)
     - `BU044-ALC-Conductor_EU` (Only for EU SREs)
   - Developer:
     - Dev/Prestage: `BU044-ALC-IDCC-Developer`
     - Stage: `BU044-ALC-IDCC-Staging` \
 <img src="./images/pag_sosid_5.png" style="width: 300px;"/> <img src="./images/pag_sosid_6.png" style="width: 300px;"/>
1. Click on `Submit & Review`
1. Provide a business justification. example: `Member of IKS SRE squad, requesting new SOSID for PAG onboarding`
1. Submit

When the request is approved by the approver chain, you should be able to use PAG for connecting to VSIs via ssh.

### Further information
[PAG VSI Preparation Documentation](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-prep-vsi)
