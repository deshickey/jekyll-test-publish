---
layout: default
title: Vyatta OS update process
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Overview

NetInt manage almost 200 vyattas. The process for managing keeping OS levels current is documented here.

## 1. Discovery

The [Parrot](https://github.ibm.com/alchemy-conductors/security/tree/master/parrot) tool requests monthly updates on the latest available Vyatta OS levels for both 5400 and 5600 variants from Softlayer. It runs on the `sup-wdc04-infra-bots-01` machine.

Parrot has a REST endpoint which serves the latest versions it knows about, including any errors it has encountered in discovering the latest versions in case human intervention is required.

The [parrot-checker](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/parrot-checker/) Jenkins job queries Parrot every day, and updates the [compliance-vyattaversion-record](https://github.ibm.com/alchemy-conductors/compliance-vyattaversion-records) repository with its results.

## 2. Alerting

The NetInt squad is alerted to new versions of the Vyatta OS through GHE Issues raised in the [firewall-requests](https://github.ibm.com/alchemy-netint/firewall-requests/issues) repository.

## 3. Upgrade process

The [Softlayer Vyatta OS upgrade process](https://knowledgelayer.softlayer.com/es/procedure/vyatta-os-upgrades) should be followed. The upgrades should be performed in the following environment order:

1. dev
2. prestage
3. stage
4. prod (with the following order for regions)
  1. ap-south
  2. ap-north
  3. uk-south
  4. eu-central
  5. us-east
  6. us-south

Each Vyatta's completion of upgrade process will be recorded in the GHE Issue.

**NOTE: The target date for closure of the GHE Issue is 21 days. If this is not achievable for any reason then the exception process below must be followed.**

## 4. Exception process

- For any case where we discover a problem that prevents Vyatta upgrade within the time limit of **21 days**, we will have a remediation issue in the team GitHub Enterprise [firewall-requests repository](https://github.ibm.com/alchemy-netint/firewall-requests). The remediation issue will have distinctive labels that will allow all such issues to be identified for audit purposes:
    - `EXCEPTION` and
    - `Vyatta OS Upgrade`

- The remediation issue can be the same issue used to track the OS upgrade, provided it has the `EXCEPTION` label attached.

- The remediation issue will specify which Vyatta hosts cannot be upgraded, the problem description and the details of the support ticket through which resolution is being tracked.

- The remediation issue will be treated as a high priority for closure and the target time to resolution will be 7 days (measured from the date when the `EXCEPTION` label is attached) unless otherwise agreed with SRE management and documented in the issue: any such agreement must be given **before the original 7 days elapses** and must specify the new target date and the justification for the delay. The issue will not be closed until it has been fully resolved for all applicable Vyatta hosts.

- [This query](https://github.ibm.com/alchemy-netint/firewall-requests/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3A%22Vyatta+OS+Upgrade%22+label%3AEXCEPTION) shows all historical Vyatta OS upgrade exceptions.

### Reviews

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
