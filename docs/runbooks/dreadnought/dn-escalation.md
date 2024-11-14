---
layout: default
title: "Escalation for the Conductors team"
runbook-name: "Escalation for the Conductors team"
description: "How to escalate to Dreadnought Runtime squad for help."
category: Dreadnought
service: dreadnought
tags: dreadnought, escalation, pagerduty, servicenow
link: /dreadnought/dn-escalation.html
type: Informational
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

## Overview
This describes the process for service teams to escalate the platform SRE team via both Service Now and PagerDuty.

## Detailed Information

#### Service Now Incident/CIE
- New Incident
  - Configuration Item: `dreadnought`
  - Assignment Group: `Dreadnought Operations` (or `Dreadnought Support`)
- SN Dashboards
  - [Change Overview](https://watson.service-now.com/$pa_dashboard.do?sysparm_dashboard=05b0a8b7c3123010a282a539e540dd69&sysparm_tab=45b0a8b7c3123010a282a539e540dd71&sysparm_cancelable=true&sysparm_editable=undefined&sysparm_active_panel=false){:target="_blank"}

#### PagerDuty direct call out (High Priority Only)
- Add Responder to existing PagerDuty Incident
  - [DreadnoughtOps-Support-EscalationPolicy](https://ibm.pagerduty.com/escalation_policies#P4CIVG4){:target="_blank"}
- New Incident via UI
  - Impacting Service: [Dreadnought](https://ibm.pagerduty.com/service-directory/P1A9W8N){:target="_blank"}
  - Assigned to: [DreadnoughtOps-Support-EscalationPolicy](https://ibm.pagerduty.com/escalation_policies#P4CIVG4){:target="_blank"}
- New Incident via Email
  - [dreadnought-sre@ibm.pagerduty.com](email:dreadnought-sre@ibm.pagerduty.com)

## Further Information

This should only be used by service teams and not by the platform SRE as it will only page out yourself.
