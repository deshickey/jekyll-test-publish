---
layout: default
title: "AI Assistant On Call Checkist"
runbook-name: "AI Assistant On Call Checkist"
description: "AI Assistant On Call Checkist"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/operations/on-call-checklist.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The purpose of this document is to provide information for going on-call for the AI Assistant Service

## Detailed Information

The onboarding and checklist below provide guidance on the following:

- Tasks to ensure that you are onboarded correctly
- Things to check before each shift
- How to hand-off between shift
- Responding to PagerDuty alerts

### Important Slack Channels

- #ai-assistant-cie : This channel is used for communications if there is an active CIE.  It should not be used for any other purpose.  
- #ai-assistant-pagerdury:  This channel is used to capture the PagerDuty notifications sent
- #ai-assistant-issues: This channel is used to communicate and/or receive potential issues related to the offering.
- #dn-sre: If Dreadnought team needs to be engaged

### Important Links

- [Runbooks](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/runbooks.html) : Search for `AI Assistant` under **Related Service**
- [Dreadnought SRE](https://test.cloud.ibm.com/docs-internal/dreadnought?topic=dreadnought-dreadnought-sre-policy) : In case assistance is required from the dreadnought team

### Required tools and accesses

Before you can go on-call, you will need to make sure you have access to the following accounts and have them configured as needed.

#### Access to production systems

You will need access to the Dreadnought account so that you are able to access the monitoring and logging tools

To request access for Dreadnought see [Link](https://github.ibm.com/ibmcloud/ai-contextual-help/wiki/Access-Management#dreadnought-access)

Access also requires the use of a YubiKey and a Softlayer account.

#### PagerDuty

[PagerDuty Documentation](https://w3.ibm.com/w3publisher/pagerduty/getting-started)

PagerDuty is the mechanism by which you will be notified if there is a production incident needing attention.

Make sure you have access to PagerDuty.  Open [PagerDuty](https://ibm.pagerduty.com).  If you can not login, follow this [Link](https://w3.ibm.com/w3publisher/pagerduty/getting-started/teams/add-yourself)
to register.  You will want to be on the team: **AI Assistant**

You will need to install the PagerDuty mobile application on your mobile phone.  See this [Link](https://w3.ibm.com/w3publisher/pagerduty/mobile-devices) for setup and security information.

#### ServiceNow

- Review [Apply for access to ServiceNow](https://pages.github.ibm.com/cloud-sre/ciebot-docs/auth_request_privileges/#apply-access-to-servicenow)

The assignment group to join is:  `AI Assistant`

For justification you **MUST** include:

- Your specific role on the team
- Specific information on why you need access

If this is not specified your request may be denied

#### CIEBot

[CIEBot Documentation](https://pages.github.ibm.com/cloud-sre/ciebot-docs/)

You will need access to CIEBot.  This requires ServiceNow access. [See above](#servicenow).

To verify that your access is working correctly, you can run the following in the `#ai-assistant-cie`.  See [Verification](https://pages.github.ibm.com/cloud-sre/ciebot-docs/auth_verification/) for more information.

### Checklist

Use the following checklist before your on-call shift:

- [ ] Verify your phone is charged
- [ ] Verify your laptop is charged
- [ ] Make sure you have the latest runbooks cloned to your laptop
- [ ] Verify that your Yubikey is still working.  If it is not working, reach out to `#sl-helpdesk` to have it reset
- [ ] Verify you can access the production Dreadnought account and have access to Sysdig and Logs
- [ ] Check if there are any active CIEs that affect the service
- [ ] Check with the team member you are relieving if there are or were any issues to be aware of

### Process

If you are paged out

- Make sure you acknowledge the notification within the first **10** minutes.  This stops any escalation process
- Log into the system and verify the health according to the runbook associated with the alert
- Perform any initial investigation to determine if this is a CIE or not
