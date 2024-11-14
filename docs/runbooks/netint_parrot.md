---
layout: default
description: Troubleshooting Parrot PDs
service: Network Intelligence
title: Network Intelligence Parrot
runbook-name: Network Intelligence Parrot
playbooks: ["NoPlaybooksSpecified"]
failure: ["NoFailuresSpecified"]
ownership-details:
  escalation: "Alchemy - Network Intel 24x7"
  owner-link: "https://ibm-cloudplatform.slack.com/messages/netint"
  corehours: "UK"
  owner-notification: False
  group-for-rtc-ticket: Runbook needs to be Updated with group-for-rtc-ticket
  owner: "Network Intelligence [#netint]"
  owner-approval: False
link: /netint_parrot.html
type: Troubleshooting
category: Armada
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

Parrot is used to check with Softlayer what version of Vyattas we should be running. Asks them in a Softlayer ticket and parses response automatically.

---

## Example alerts

None

---

## Investigation and Action

SSH onto `sup-wdc04-infra-bots-01` and check that a docker container called `parrotd` is running.

If you are unable to get this running by restarting the container and common sense debugging using `docker logs`, try repromoteing the latest parrotd by executing the following [jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/parrotd-build/)

If the `parrotd` container successfully starts, re-run the [Parrot compliance jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/parrot-checker/) 

If the container remains down, proceed to the escalation policy below.

---

## Escalation Policy

As this is linked to compliance, esclate any occurrences to the Netint Squad.

Re-assgin the PD to `Alchemy - Network Intel 24x7`

---

## Automation

None

---