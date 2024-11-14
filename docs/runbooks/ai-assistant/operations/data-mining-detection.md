---
layout: default
title: "Significant Resource Consumption"
runbook-name: "Significant Resource Consumption"
description: "Significant Resource Consumption"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/operations/data-mining-detection.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook provides guidance on the steps to take if there is a potential data-mining issue.  

## Detailed Information

This runbook describes what to do if there is a sudden, abnormal increase in the following metrics:

- disk i/o
- memory usage
- cpu usage

A sudden increase in metrics is defined by metrics exceeding the average value by 90%

### Investigation

Review platform and service log files to determine the cause.
Use Sysdig to determine any patterns that may have led to the increase in consumption ( increased customer usage, processing larger files, etc.)
Review the dashboards for the affected service.

Reach out to the Dreadnought SRE team per the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

### Potential remediation

If this is a valid increase in resource consumption, please reach out to the Dreadnought team per the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html).

### Security / Datamining incident

Formal instructions: <https://pages.github.ibm.com/ibmcloud/Security/procedure/IR-Procedure.html>

If your analysis indicates that there may be an attempt at or actual data-mining activities, please report this immediately to **CSIRT <https://engagementform.csirt.ibm.com/incident/new/**>

Select: **Report a Cyber/Data Incident**

All cybersecurity and data privacy incidents must be reported.  These incidents will or could have an impact on IBM or Client data or systems.  When in doubt, please report using the link above.  **Please remain available for 2 hours after making an incident report.**  You will need to assist the Incident Response Coordinator (IRC) who will be contacting you within that timeframe.