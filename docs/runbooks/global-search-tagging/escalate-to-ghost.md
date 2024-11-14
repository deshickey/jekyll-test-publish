---
service: Global Search and Tagging (GhoST)
title: "Escalation to GhoST"
runbook-name: "Escalation to GhoST"
description: "Instructions for escalating an incident to the GhoST SRE team"
category: GhoST
type: Operations # Alert, Troubleshooting, Operations, Informational
tags: ghost, dreadnought, service team, service, escalation, incident, servicenow, service now, pagerduty, slack
link: /global-search-tagging/escalate-to-ghost.html
failure: []
playbooks: []
layout: default
grand_parent: Armada Runbooks
parent: Global Search Tagging
---

Ops
{: .label .label-green}

## Overview

If an issue with GhoST is suspected or has occurred, there are various ways in which the GhoST SRE team can be contacted.

## Detailed Information

An issue can be raised to GhoST by either creating an incident on ServiceNow, on PagerDuty, or posting to the appropriate Slack channel.

## Detailed Procedure

### ServiceNow

1. Create a new incident in [ServiceNow](https://watson.service-now.com/) (All -> Incidents -> Create New)
2. Fill in the mandatory fields:
  - `Caller`
  - `Detection Source`
  - `Configuration Item` = `global-search-tagging`
  - `Severity`
    - `Sev-1`: For **Critical** customer impacting issues
    - `Sev-2`: For time-sensitive important issues
  - `Short Description`

### PagerDuty

> Reserved for high-priority calls only

Create an incident against the [GhoST SEV2 service](https://ibm.pagerduty.com/service-directory/PE492YX).

| Escalation Policies                      | Sev            |
| ---------------------------------------- | -------------- |
| GhoST SEV2 Escalation policy             | All severities |

### Slack

Reach out to the GhoST team on Slack channel:  

* [SRE: discuss issues `#global-search-tagging`](https://ibm.enterprise.slack.com/archives/C11F8KA1Z).

Other relevant channels:

* [SRE: CIE discussions - `#ghost-cie`](https://ibm.enterprise.slack.com/archives/CLKUU18MT)

## Further Information

* [AVM Services Overview](https://pages.github.ibm.com/toc-avm/avm/avmservices/)
* [AVM FAQ](https://pages.github.ibm.com/toc-avm/avm/faq/)
* [How to handle a CIE](https://pages.github.ibm.com/toc-avm/avm/star/2023/03/07/How-to-Handle-CIE/)
* [How to perform an RCA](https://pages.github.ibm.com/toc-avm/avm/star/2023/03/06/How-to-Perform-RCA/)
* [Customer Impacting Event (CIE) Process Overview](https://ibm.ent.box.com/v/WCPAVMProgramDocumentation/file/246138991386)
* [Incident Management “textbook” for ServiceNow](https://ibm.ent.box.com/v/WCPAVMProgramDocumentation/file/282457535354)
* [Problem Management “textbook” for ServiceNow](https://ibm.ent.box.com/v/WCPAVMProgramDocumentation/file/280206799154)
* [How to get access to CIEBOT](https://pages.github.ibm.com/cloud-sre/ciebot-docs/auth_request_privileges/)
* [CIEBot Practice : Pls use cietest bot in the #ciebot-practice channel or direct message to the bot cietest . Any issues using ciebot can be reported in #cie-bot-dev Guidance](https://ibm-cloudplatform.slack.com/archives/C9WA5T2PJ/p1579800581008500)
* [CIEBot Recorded Training](https://yourlearning.ibm.com/activity/URL-2AD833F96AD5)
