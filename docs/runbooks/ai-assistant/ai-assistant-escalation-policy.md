---
layout: default
title: "AI Assistant Escalations"
runbook-name: "AI Assistant Escalations"
description: "AI Assistant Escalations"
service: "AI Assistant"
tags: ai-assistant
link: ai-assistant-escalation-policy.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks
---

Informational
{: .label }


## Overview

This runbook is to provide the escalation policy to reach AI Assistant

AI Assistant does not provide any business critical functionality at this time.

In general, we would see the following types of errors if the service is not functional

- Responses are incorrect or contain an error message
- The link is missing from the Console help icon
- The link is available but the chat window does not load

## Detailed Information

AI assistant is using Synthetics tests to determinate the service status. It determinate the service status by performing tests for 3 major areas:
    - General health checks to verify that the services themselves are life, up and running and reporting healthy
    - An API test that asks a question
    - UI Test

In case of a failure, if it is repeated 2 more times (total of 3 attempts).  If all 3 attempts fail, an incident record is opened in ServiceNow and will generate a PagerDuty.

The PagerDuty notification will appear in [#ai-assistant-pagerduty](https://ibm.enterprise.slack.com/archives/C07GYMLHH5G)

## Further Information

Pagerduty escalation policy:

- `AI-Assistant Service`:  <https://ibm.pagerduty.com/service-directory/PHOVG5O>

### Incident Management Overview

Support Engineer will be notified by PagerDuty tool, using the AI-Assistant Service escalation policy, mentioned above. After receiving the PD notification, support engineer needs to check if the incident properly assigned to AI Assistant team, in case if it should be resolved by other team the incident should be rerouted to the appropriate team. If this is AI Assistant incident, engineer needs to acknowledge the PagerDuty tool.

- Check if there is no impacting CIE at
  - IBM Cloud level - [IBM Cloud Status](https://cloud.ibm.com/status/)
  - Infrastructure level - [#dreadnought-support-cie](https://ibm.enterprise.slack.com/archives/C04U1E4VDQA)
  
- Collect the application data and logs
- Perform the problem determination steps using Cloud AI Assistant runbooks
- Provide the regular status updates into [#ai-assistant-cie](https://ibm.enterprise.slack.com/archives/C07JKM54V8W) slack channel
- After the problem resolution, the CIE retrospective should be performed

### Runbooks

- Operational runbooks: <https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/ai-assistant/ai-assistant-general-info.html>
- Internal documentation: <https://test.cloud.ibm.com/docs/ai-assistant>

### Slack channels

- Active CIE Slack channel: [#ai-assistant-cie](https://ibm.enterprise.slack.com/archives/C07JKM54V8W)
- PagerDuty notifications: [#ai-assistant-pagerduty](https://ibm.enterprise.slack.com/archives/C07GYMLHH5G)
- Adopters Slack channel: [#cloud-ai-assistant](https://ibm.enterprise.slack.com/archives/C06CVJ77WTH)
- Issues Slack channel: [#ai-assistant-issues](https://ibm.enterprise.slack.com/archives/C07R6H3TQ10)
- Dreadnought CIE channel: [#dreadnought-support-cie](https://ibm.enterprise.slack.com/archives/C04U1E4VDQA)
- Console CIE channel: [#console-cie](https://ibm.enterprise.slack.com/archives/CLJ4QQWNN)
- IAM CIE channel: [#iam-cie](https://ibm.enterprise.slack.com/archives/C5T7AUCKD)
- IBM Cloud CIE channel: [#ibmcloud-cie](https://ibm.enterprise.slack.com/archives/C020WBYPGGK)
- Watson AI/Platform channel: [#sre-wdc-incidents](https://ibm.enterprise.slack.com/archives/C3P1C7BHQ)
- Watson WML channel: [#wml-pd-ops](https://ibm.enterprise.slack.com/archives/C5FCWT753)

### Support issues

You can open a GHE issue on [AI Content Support Tickets](https://github.ibm.com/ai-content/ai-content-support-tickets)

### Engaging with Dreadnought / Platform SRE

Please see <https://test.cloud.ibm.com/docs-internal/dreadnought?topic=dreadnought-user-support> for getting Dreadnought support.
