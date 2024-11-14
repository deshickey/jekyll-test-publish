---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Template for documenting the root cause analysis process of a production incident
service: Runbook needs to be updated with service
runbook-name: "Root Cause Analysis Template"
title: "Root Cause Analysis Template"
link: /RCATemplate.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

_NOTE_: Some sections are duplicated in the CIE PPT but are included here to ease indexing/searching.

# Overview

|---------------------|-------------------------------------------------------------------------------|
|Link to CIE Template | (The URL of the CIE PPT on Box)                                               |
|Owners               | (Logins of on-call developer, Conductor and Escalation)                       |
|Interested Parties   | (Logins of all interested parties)                                            |
|Pager Duty Incident  | (# of the PD Incident)                                                        |
|RTC Work Item        | (# for the Delivery Squad RTC Work Item, if any)                              |
|CloudOE Incident     | (# for the CloudOE RTC Incident record)                                       |
|=====================|===============================================================================|
{:.table .table-bordered}

# Timeline and Worklog

Extract the relevant details from the worklog, and include timestamps, in sequence for:

* Include timestamped entries for:
  * Timing of observations that indicated an incident
  * Timing of additional on-calls that are paged and engaged
  * Timing of key observations - that proved relevant or not
  * Timing of actions that mitigated or did not mitigate
  * Timing of when issue was mitigated and the actions that caused it

# Identify defects relevant to the incident (DERP) {#derp}

Summarize the defects in the incident by answering the following questions:

* Detection
  * Did we find the defect before the customer ? If not, why ?
  * Did we find the defect in staging or development ? If not, why ?

* Escalation
  * Did the right people get engaged quickly ? If not, why ?
  * Could our detection have engaged the right people more quickly ?

* Remediation
  * How did we restore the service ? Why did it require human intervention ?

* Prevention
  * Will this incident, or a form of it/similar to it, recur in the future ? Why ?

# Root Cause Analysis (5 Whys) {#fivewhys}

For each of questions above, where you answered why - dive deeper and conduct a '5 Whys' analysis to identify action items to address the latent defect. It says that the true root cause of a defect can be identified by asking Why five or more times. It also helps use identify action items (at each level of Why) that we can complete to help eliminate the defect.

More info on [__5 Whys__](https://hbr.org/video/2189146765001/5-whys)

__Why..?__

__Why..?__

__Why..?__

__Why..?__

__Why..?__


# Action Items

For each action item provide:

* __Summary__
* __RTC Reference #__
* __Owner__
* __Due Date__

# Close
**RCA Closed On**: (Date)

**Summary of resolution impacts**: (when closed, identify impacts in metrics that resulted from RCA action items)
