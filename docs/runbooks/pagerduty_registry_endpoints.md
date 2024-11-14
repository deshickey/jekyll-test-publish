---
layout: default
description: Runbook for pagerduty incidents raised by the Containers Registry Endpoint checks.
service: "Containers Registry "
title: Registry Endpoints PagerDuty Guide
runbook-name: Registry Endpoints PagerDuty Guide
playbooks: [ "registry/recoveryTool/reboot_scripted" ]
failure: ["Sensu DOWN: registry endpoints _env_" , "Sensu DOWN: ccs endpoints _env_"]
ownership-details:
  escalation: " Alchemy - Registry and Build "
  owner-link: "https://ibm-argonauts.slack.com/messages/registry/"
  corehours: " UK "
  owner-notification: False
  owner: " R&B Squad [#registry]"
  owner-approval: False
link: /pagerduty_registry_endpoints.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
_The Registry services are load balanced across three or four instances in each environment. If one of the registry checks has failed, this means that one of the 'nginx' front-end services for the registry is not working correctly.<br/>If only one machine in each group of 3/4 is down, there should be no impact to customers._

Each individual endpoint host has a Sensu check (e.g. *Registry-Endpoint on prod-dal09-registry-endpoint-01*). These checks cause low severity pages, which go directly to the Registry and Build Squad.<br/>

These individual checks _roll up_ into *HA Service* Sensu checks. In each availability zone, there is a roll-up check called *'registry endpoints &lt;env&gt;'* and another called *'ccs endpoints &lt;env&gt;'*.

These roll-up *HA Service* checks will fail if we are down to 0 or 1 of the contributing machines still being healthy. i.e. they will fail if we have an outage or a single point of failure.

If you are reading this, it is because this state has occurred. 2, 3 or even 4 endpoint hosts in the group referenced in the PD alert are down.

## Example alert(s)
    * Registry-Endpoint on <machine-name>

## Automation
No Automation beyond machine reboots

## Actions to take

#### If this is in office hours for the UK
- Please reassign the page to so that we can gather more root cause analysis information on the failure.  
Reassign to [`Alchemy - Containers - Registry and Build (High Priority)`](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)

#### Outside of UK office hours :
1. Check Sensu for the environment (from the [Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) > [Carrier](https://alchemy-dashboard.containers.cloud.ibm.com/carrier)  > Service Health > Sensu-Uptime). Find the check that caused the PD. If it is green, then the problem has resolved.
2. Find the contributing Sensu checks for the individual hosts (e.g. *Registry-Endpoint on prod-dal09-registry-endpoint-01*), and identify which of these are failing (there must be at least two).
3. Restart the machines that have failed.
4. If the PD has not resolved, escalate to the Registry & Build squad.


## Escalation Policy
 * PagerDuty Escalation Policy: [Alchemy - Containers - Registry and Build (High Priority)
](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)
  * Slack channel: [Argonauts - registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE)
  * GHE repo link for issues with runbook or PD: [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)
