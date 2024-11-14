---
layout: default
description: Troubleshooting vyatta healthcheck PDs
service: Network Intelligence
title: Network Intelligence Vyatta Healthcheck
runbook-name: Network Intelligence Vyatta Healthcheck
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
link: /netint_vyatta_healthcheck.html
type: Troubleshooting
category: Armada
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

Vyatta Healthcheck runs against vyattas checking that the configuration that is currently live is what we expect.

This is a compliance check that needs to run everyday, and is on a set escalation policy so cannot come straight to Netint.

---

## Example alerts

None

---

## Investigation and Action

Check that the failing vyatta(s) aren't expected to be down due to OS Reloading/SL Maintanance. Run again once it's over.

Ensure that the jenkins job is running correctly: [Vyatta-Healthcheck](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/vyatta-healthcheck).

If the job failed since it was unable to reach a vyatta, this could be due to a network blip or slow response. Run the job again and see if it's the same vyatta failing.

The job will pass if all the checks run, you'll need to read the logs to see if any vyattas failed the check.

Each time it fails, it'll create a PD alert, along with a GHE @ https://github.ibm.com/alchemy-netint/firewall-requests/issues#boards?repos=11364.

Once a run passes on all vyattas, all PD & GHE's can be resolved with a message: `Healthcheck ran successfully @ <<Link to passing jenkins job>>`

If you're unable to resolve the issue discuss with netint member who's handling firewall tickets that week. `@netmax oncall`

---

## Escalation Policy

Alchemy - Network Intel 24x7

Only escalate if there are vyattas that are infront of production carriers. Otherwise wait until office hours to discuss with the oncall netint member.

---

## Automation

None

---
