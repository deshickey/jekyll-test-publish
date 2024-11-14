---
layout: default
title: Shared user IDs
type: Informational
runbook-name: Shared user IDs
description: Shared user IDs policy
category: Armada
service: Privileged Identity Management
tags: Privileged Identity Management, Armada, PIM
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

### Roles who can requested shared ID
All roles

### Roles authorised to approve requests
SRE approver.
Nobody may approve their own request.

### Roles authorised to process requests
SRE squad member.
Nobody may process their own request.

### Repositories where shared IDs are stored
SOS Priliviged Identity Manager (SOS PIM)

### Trigger: a new shared ID is requested

#### Process to follow

1. A authorised person requests a shared ID.
  * Create a PR for document [shared_user_ID_list.md](shared_user_ID_list.html) with the new shared ID details.
  * Create an issue in [Conductors team issues](https://github.ibm.com/alchemy-conductors/team/issues) providing a title of SHARED ACCOUNT: New shared ID for <service> required with justification provided in the body.
  Include a link to the PR in the issue.
1. An authorised approver will review the request and either approve or reject it.
2. If approved:
3. An authorised person will create the shared ID and retrieve the credentials.
4. The PR for the Shared ID inventory will be approved and merged.
5. The shared ID credentials are stored in a secure location: 
   - Thycotic 
   - Optionally, added to Jenkins as a credential 
   - Optionally, securely pass credential to requestor
6. Shared ID user must securely store the credentials.


## Detailed Information

### Storage and access
All credentials for shared IDs are stored in Thycotic and to be accessed and approved in Thycotic Secret Server.
This is a requirement of the [WCP Security Policy](https://pages.github.ibm.com/ibmcloud/Security/policy/WCP-Security-Policy.html).

To access the credential it must be checked out.
The check out requirement is enabled when the secret is first created in Thycotic Secret Server (`Require Check Out` set to `Yes`).
Only one user can check out the shared ID at a time.
When the user has finished using the credential it must be checked back in.
When the credential is checked back in the value must be changed if possible (for example, w3ids may not be changed more than once per day).

### Access definition
Thycotic groups mirror SOS IDMgt groups and access to any Thycotic object (folder or secret in this case) can be configured per Thycotic user or per Thycotic (i.e. SOS IDMgt) group.

### Access log recording
Default Thycotic logging system records what user used what secret (i.e. accessed what target system). Further it is possible to configure secret so that only one user can use one secret at the time and so that any usage of the secret has to be approved, etc.
PIM team's target is keeping data one year in Thycotic database. Plus PIM records get sent to QRadar and there's a year retention.

### SOS IDMgt / PIM relation
Access can be granted to the Thycotic group and the Thycotic group gets synced with SOS IDMgt group periodically. So once a user is added/removed to/from SOS IDMgt group, she/he is after sync added/removed to/from Thycotic group and so gains/looses any access granted to this Thycotic group.

### SOS IDMgt / PIM sync process
SOS IDMgt and Thycotic groups get synced every 12 hours - the max delay between removing user from SOS IDMgt group and Thycotic group is 12 hours. Manual synchronization can be requested, which is technically possible to do quickly. However we should relay on official SOS User Guide, which says that Service Request MAX Severity is 2 and so they have 24 hours to handle it, which is longer then the automatic sync period and so not relevant.

[Official SOS Service Request User Guide](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/ServiceNow%20for%20SOS%20Customer%20usage).

## Further Information
PIM service is pure Thycotic Secret Server - [documentation](https://thycotic.force.com/support/s/secretserver).<br/>
[Thycotic Secret Server runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/thycotic-secret-server.html) - instructions on how to use it.
