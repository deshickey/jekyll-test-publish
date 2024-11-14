---
layout: default
title: Access control for Argonauts Squads - Vyatta Firewall Access
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

## Brief scope

This policy covers access control specific to requesting access to Vyatta firewall devices

Vyatta authentication uses SSH and requires SSH public key authentication over the private network.

The ability to log in to a Vyatta is gated on:

- working OpenVPN access
- SSH public key stored in GHE (in one of the user.json files [here](https://github.ibm.com/alchemy-netint/firewall-source/tree/master/vyatta))
- membership of the appropriate USAM group

## Vyatta Roles used

- `admin` - full access to all configuration commands

There is also `operator` access: read-only access to configuration and ability to run tcpdump and view logs. We do not grant operator access to anyone.

## Roles requiring Access

The following require Vyatta admin access to perform their job functions:
- Network Intelligence Squad Member
- Network Intelligence Squad Lead

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

The processing of this user in USAM will be performed by the Shared Operational Services Squad who own the USAM/Active Directory servers.

Once tier 1 and tier 2 approvals are complete, the user will be added to USAM/Active Directory and their ID associated with the groups they have been authorised to be part of.

### Automation

Access is managed by automation, USAM group information is extracted every 30 minutes from USAM using this code here:

https://github.ibm.com/alchemy-netint/usam-user-extractor

Via jenkins job:

https://alchemy-containers-jenkins.swg-devops.com/view/Network-Intelligence/job/Network-Intelligence/job/softlayer-query-generator/

Any changes to the USAM user list is reported into the slack channel: sre-cfs-network
Any changes to the USAM user list is reported in the GHE commit comment.

The generated CSV files are maintained in GHE here:

https://github.ibm.com/alchemy-netint/network-source/tree/master/usam-data

Those files are then read by our firewall builder whenever changes occur:

https://alchemy-containers-jenkins.swg-devops.com/job/Network-Intelligence/job/firewall-rules-generator/

The firewall build produces a valid list of users by combining the user information in .json files found here:

https://github.ibm.com/alchemy-netint/firewall-source/blob/master/vyatta/ with the USAM group csv files.

Any changes will then be automatically deployed to all the appropriate firewalls via the firewall deploy
jenkins job: https://alchemy-containers-jenkins.swg-devops.com/job/Network-Intelligence/view/Firewall/job/firewall-deploy/

### Requesting Access

Raise a new Issue against the NetInt squad firewall-requests repo: https://github.ibm.com/alchemy-netint/firewall-requests/issues/new

- Business need for firewall admin access (e.g. needed for NetInt squad member)
- Softlayer account where firewall admin access is required
- Provide SSH key that will be added to access list in GHE

Request via USAM: https://usam.svl.ibm.com:9443/AM/

Request access to the "Argonauts" system.
Request access to one or more of the appropriate groups:

| USAM Group | Access provided |
|--- | --- |
| alchemy-firewall-nonprod | admin access to all non-production firewalls |
| alchemy-firewall-prod | admin access to production non-EU firewalls |
| alchemy-firewall-prod-EU | admin access to production EU firewalls |

**NOTES:**

- The USAM request must include the business need.
- Access will only be provided to members of the NetInt squad.

## Reviews

The process will be reviewed by management at least annually.

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
