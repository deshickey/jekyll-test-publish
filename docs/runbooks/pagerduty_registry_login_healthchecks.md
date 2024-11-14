---
layout: default
description: Runbook for pagerduty incidents raised by the Containers Registry service login healthchecks.
service: "Containers Registry "
title: Registry Login Healthcheck PagerDuty Guide
runbook-name: Registry Login Healthcheck PagerDuty Guide
playbooks: [""]
failure: ["Sensu DOWN: Registry-bx-cr-login on _host_", "Sensu DOWN: Registry-docker-login on _host_", "Sensu DOWN: Registry-bmuaa on _host_" ]
ownership-details:
  escalation: " Alchemy - Registry and Build "
  owner-link: "https://ibm-argonauts.slack.com/messages/registry/"
  corehours: " UK "
  owner-notification: False
  owner: " R&B Squad [#registry]"
  owner-approval: False
link: /pagerduty_registry_login_healthchecks.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
In order to perform these actions, the healthcheck needs to log in. The healthcheck logs in using `bx login` (to log into the Bluemix api environment) and `bx cr login` (to log the local Docker daemon into the registry).
If the bx-cr-login fails, this means that the healthcheck service is unable to log in, and cannot verify other Registry capability.

## Example alert(s)
    * Registry bx cr login on <machine-name>
    * Registry docker login on <machine-name>
    * Registry bmuaa on <machine-name>

## Automation
Automation is not available likely to be another service that is down.

## Actions to take

There are multiple potential causes of a failure of the `bx cr login`  check:

* The Bluemix Login API is down or slow

* The IBM Containers Registry is down or slow

* The Health Check service has crashed or restarted

To investigate the cause and route the issue to the correct team:

1. Open Sensu (eg: https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd01/prod/sensu-uptime/#/events) and click the failing bx-cr-login check.

1. On the check page, look at the Sensu "output" field. If this contains `HTTP:500`, continue down this guide. Otherwise, forward the page to the Registry & Build squad.

1. Check also the status of the `Registry-bmuaa-on-<env>-registry-health-0x` ('bmuaa' below) check.
Refer to the table below to understand the cause of the login failure.
 <table style="width:100%" border="1">
  <tr valign="top">
    <th>bx-cr-login result</th>
    <th>bmuaa result</th>
    <th>What it means</th>
  </tr>
  <tr valign="top" bgcolor="#00FFFF">
    <td>PASS</td>
    <td>PASS</td>
    <td>All good, <b>bx-cr-login</b> isn't down - just here for clarity.</td>
  </tr>
  <tr valign="top">
    <td>FAIL</td>
    <td>PASS</td>
    <td><b>Docker login</b> is failing. This is a problem with the registry. Forward the page to the Registry and Build squad.</td>
  </tr>
  <tr valign="top" bgcolor="#00FFFF">
    <td>FAIL</td>
    <td>FAIL</td>
    <td><b>Bluemix UAA</b> is failing. Check for other pages to do with Bluemix UAA and escalate those accordingly. <b>bmuaa</b> is a pre-req for Registry - this is not a registry outage. Contact point is #sre-platform-onshift in Slack.</td>
  </tr>
</table> 

## Escalation Policy
 * PagerDuty Escalation Policy: [Alchemy - Containers - Registry and Build (High Priority)
](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)
  * Slack channel: [Argonauts - registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE)
  * GHE repo link for issues with runbook or PD: [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)
