---
layout: default
title: Vyatta Temporary Softlayer Access
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Overview

Sometimes it is necessary to allow SoftLayer employees to have temporary access to a vyatta, for example; to assist in debugging problems. It is not possible to use the usual mechanisms to control access (USAM), so an exception process is required.

## Requirements

- The access is only given for SSH with public key authentication
- The access given is the minimal access required for the agreed actions
- The access is removed as soon as it is no longer necessary

## Process

An issue must be raised in the [firewall-requests](https://github.ibm.com/alchemy-netint/firewall-requests/issues/) repo with the title in the form "Provide temporary access for user <username> for <vyatta name>".  
The body of the issue should include a link to the SoftLayer ticket where the access was requested by the SoftLayer employee and a description of reason access is being given.  
The issue should be labeled "URGENT" and "approval required".

**Management approval is required before the access is granted.**

Once approved the temporary user can be created, the ticket should be updated to indicate when this has happened.
The issue should be updated and closed once the temporary access is no longer required and the temporary user has been removed from the vyatta.

Note: Adding temporary access will cause the [vyatta-healthcheck](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/vyatta-healthcheck/) job to fail

### Reviews
Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14