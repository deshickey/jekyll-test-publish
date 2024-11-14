---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Access hosts via Privileged Access Gateway(PAG)
type: Informational
runbook-name: "Access hosts via Privileged Access Gateway(PAG)"
description: "Access hosts via Privileged Access Gateway(PAG)"
service: Conductors
link: /docs/runbooks/pag/pag_access_hosts.html
grand_parent: Armada Runbooks
parent: PAG
---

Informational
{: .label }

# Access hosts via Privileged Access Gateway(PAG)

## Overview
This document describe how to connect to hosts via Privileged Access Gateway(PAG)

**NOTE**: due to PAG not being available in all regions(at the time this runbook is written - September 2024), only 4 instances in `us-south`, `us-east`, `eu-de` and `eu-fr2` are deployed.

## Detailed Information
### Pre-requisites

**IMPORTANT**: If you are already using GPVPN **skip steps 2 through 5**

1. [Setup new SOSID](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pag/pag_sosid.html) \
**IMPORTANT**: The above step is only needed if you want to use pag for ssh connection
1. SL account set up: [Request Softlayer Account](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#request-an-account-into-the-softlayer-commercial-environment-sl-imsad-credentials-and-a-yubikey-via-accesshub-iaas-access-management-application)
1. MFA setup:
    1. **Access required to pre-prod only**: Symantec VIP registration: [Symantec VIP Credential](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#register-the-symantec-vip-credential-id)
    1. **Access required to pre-prod and prod**: Yubi key registration: [Register your Yubikey](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#register-your-yubikey)
1. GP package installed for MAC and Linux: [Global Protect VPN](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#setting-up-global-protect-vpn)
1. Onboarded to GP Active Directory Groups: [Self onboard to GP VPN profile](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#ticket-for-self-onboarding-to-global-protect-vpn-profile)
1. [CLI plugin install](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-install-CLI-plugin)
1. Have a valid INC, CHG or CS number ready for ticket validation [ServiceNow Ticket Definition](#2-servicenow-ticket-definition)


### Typical example of authenticate and connect over CLI

Typical example of how to authenticate and connect using IBMCloud `pag` plugin on the command-line.

#### Step 1: Authenticate to IBMCloud with cli
```
ibmcloud login --sso
```

#### Step 2: Set PAG gateway
```
ibmcloud pag gateway set <endpoint url>
```

`<endpoint url>` \
The gateway address you want to connect to (e.g. `iks-dev.us-east.pag.appdomain.cloud`)

#### Step 3a: Log into a particular node via IP
```
ic pag ssh connect <target ip> --ticket-id <INCXXXXX>
```

`<target ip>` \
The machine IP you want to connect to

**Troubleshooting hint** \
In some cases(frequently) you might get a `Session failed` error.
```
Connecting to XXX.XXX.XXX.XXX...

FAILED
Session failed

FAILED
You do not have permission to SSH through PAG

Target SSH error : ...
```
Please try to remove all ssh identities by running `ssh-add -D` and retry. The PAG team is aware of this issue and will be moving out of using `ssh-agent` in the future.
#### Step 3b: Connect to a Kubernetes cluster
**IMPORTANT**: You should not use PAG to connect to IKS tugboats directly (e.g. `ibmcloud pag ks config ...`) in Production. The only approved method of connection is via `invoke-tugboat` from a carrier worker.
1. **IKS**
```
ibmcloud pag ks config <cluster-name> --ticket-id <INCXXXXX> [--endpoint <private|public|vpe>]
```

2. **ROKS**
```
ic pag oc config <cluster name> [--passcode <passcode>] --ticket-id <INCXXXXX> [--endpoint <private|public|vpe>]
```

*When the CLI command is run, the cluster can be controlled through the oc or kubectl command like it's normally be done.*


For more details, see
- [Accessing VSI with SSH](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-using-pag-ssh)
- [Accessing a Kubernetes cluster](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-using-pag-kubernetes)

### Gateways

**IKS**

|account_name|environment|deployment_issue|endpoint|regions|
| --- | --- | --- | --- | --- |
|Argonauts Dev 659437|Dev+Pre-Stage|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23420)|`iks-dev.us-east.pag.appdomain.cloud`|All Public regions|
|Argo Staging 1858147|Stage|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23696)|`iks-stage.us-south.pag.appdomain.cloud`|All Public regions|
|Argonauts Production 531277|Prod|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23845)|`iks-prod.us-south.pag.appdomain.cloud`|All Public regions|
|Argonauts Production 531277|Prod|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23843)|`iks-prod.us-east.pag.appdomain.cloud`|All Public regions|
|Argonauts Production 531277|Prod|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23844)|`iks-prod.eu-de.pag.appdomain.cloud`|All Public regions|
|IKS BNPP Prod 2051458|Prod|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23846)|`iks-prod.eu-fr2.pag.appdomain.cloud`|dMZR(eu-fr2)|

**SATELLITE**

|account_name|environment|deployment_issue|endpoint|regions|
| --- | --- | --- | --- | --- |
|Satellite Stage 2146126|Stage|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23801)|`sat-stage.us-south.pag.appdomain.cloud`|All Public regions|
|Satellite Production 2094928|Prod|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23856)|`sat-prod.us-south.pag.appdomain.cloud`|All Public regions|
|Satellite Production 2094928|Prod|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23856)|`sat-prod.us-east.pag.appdomain.cloud`|All Public regions|
|Satellite Production 2094928|Prod|[Link](https://github.ibm.com/alchemy-conductors/team/issues/23856)|`sat-prod.eu-de.pag.appdomain.cloud`|All Public regions|

## References

### 1. Learning Resources

- Conductor playback: TBD
- Global Protect VPN: [PaaS Service - Wave 1](https://ibm.ent.box.com/folder/127192196001)
- [Privileged Access Gateway official documentation](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-requirements)
- [PAG Sec044 Architecture](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-sec044-architecture)
- [Connectivity Troubleshooting](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-internal-connectivity-issues)
- [Session recordings](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-session-recording-ref)

### 2. ServiceNow Ticket Definition

A valid ServiceNow ticket must be used when logging into the bastion proxy. We can use:

- `Incidents (INCxxx)` when investigating a particular incident, or while on PD (see below for different scenarios)
- `Change Requests (CHGxxx)` when supporting a particular change request
- `Customer Support requests (CSxxx)` when supporting a particular customer issue

The validation of the ServiceNow incident/change request ticket is performed based on the following criteria:

- the ticket must be active (i.e. open status)
- the ticket must be either assigned to the operator accessing the cloud resources (for change requests) or assigned to the `Containers SRE` group (for incidents)

### 3. Ticket Validation Guidelines

- SN tickets should ideally be linked to the specific issue being investigated.
- Please consider that we support several types of SN tickets: incidents, change requests, cases and problems. So depending on the situation being addressed, you might need to consider using one or another.
- For example usually incidents get opened when a problem occured in a prod env, and potentially they come from a support request. In that case you will use that incident only for dealing with that specific problem  and will close it once the problem is solved.
- If you need to access the prod envs to troubleshoot an issue and understand if an incident ever occurred, in that case the recommended approach is to have some automation that would collect the troubleshooting info for you, so your operators won’t have to login to access the systems just for collecting logs.
- If that is not possible for whatever reason, you migth want to create a SN case or a problem that might eventually evolve into an incident if anything is found during investigation. Also on this case we discourage using the same SN ticket for investigating multiple issues. In other words, is not allowed opening a single SN ticket and use it for the whole day of activities, nor to have long lasting tickets that are open for days/weeks/months...
- Please consider that a single SN ticket can be shared among the operators contributing to the resolution of the same:
  - the logic we implemented in teleport is to check that the requestor, passing the SN ticket number at login time, is either part of the assignment group of a ticket, or part of one of the contributing groups subscribed to the same ticket. 
  - Personal assignment and validation is only implemented for the Change requests type of ticket: in that case you can pass a CR number only if that was assigned personally to you
- We should certainly be using CS when we are investigating reported issues..
- We should be using INC for anything our automation finds or if we need to look at things proactively..
- We should be using CHG if we are debugging something due to a CHG as that will already have been raised.

### 4. Conductors Use Cases

**Q. I am a primary and need to access multiple prod. What ticket type do I need to use and how often can I use?**  
A. Create an INC in https://watson.service-now.com. Add a note saying you are accessing the env to investigate issues for the PD shift.
- Select appropriate `Detection Source`
- Select `containers-kubernetes` as the `Configuration Item`
- Select `Containers SRE` as the `Assignment Group`

**Q. I am a secondary and received a request from #conductors.**  
A. Go ahead and create an INC for the request. Add a link to the request in the channel to the Description.

**Q. I am asked to help out Primary when PD madness started.**  
A. Share the same INC created for the shift by Primary of the day to work on the same issues.
 
**Q. I am not sure if I need to raise an INC or not.**  
A. An INC needs to be related to an issue. Raise an INC to address a specific issue.
 
**Q. I am asked to help out EU request from #conductors.**  
A. If secondary of the day has already created an INC for the request, share it. If not, a new INC should be created.
 
**Q. I need to access prod to investigate a Customer ticket.**  
A. SRE can use CS number from Customer ticket. Currently, a CS ticket is only assigned to `acs fabrics` team. to enable the access for SREs:
1. Go to the ticket in  https://watson.service-now.com    
2. Unlock `Assistant Groups`
3. Add `Containers SRE`
4. Lock it again
5. Click `Update` to save the ticket

### 5. Break The Glass Scenario

If PAG is unavailable SREs can ssh via OpenVPN.

#### PAG break-glass scenario

Details in this runbook: [Break the glass scenarios for PAG installation in FS Cloud](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pag/pag_break_the_glass_scenarios.html)

