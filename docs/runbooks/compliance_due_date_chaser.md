---
layout: default
title: Compliance Due Date Chaser
type: Informational
runbook-name: Compliance Due Date Chaser
description: Tool that reminds of upcoming due dates of GHE issues
category: Armada
service: NA
tags: GITHUB, compliance
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The compliance due date chaser is a tool for reminding users of upcoming due dates on GitHub Enterprise issues. The application is intended to be set up as a nightly Jenkins/cron job. It searches through the configured repositories looking for open issues that have a due date.

## What to do if you receive a PagerDuty alert

If you receive a PagerDuty alert for an approaching GitHub Issue due date, follow these steps:

* Ensure the issue has an assignee.
  * If the issue has no assignee, contact the [squad responsible for the repository](https://ibm.ent.box.com/notes/141718696958?v=Argonauts-Squad-List) and ask them to assign it to someone. This document can be used to map GHE repository to squad. The SRE team know how to contact each squad so that should be enough info.
  * If the issue already has an assignee:
    * Contact the assignee to remind them that the issue is due soon. If the assignee is out of the office, contact their manager and ask for it to be assigned to someone else.
    * If necessary the due date could be changed, but only with the agreement of the Security Focal and SRE management which must be documented in writing as comments in the GHE issue.

## Detailed Information

* Source code: https://github.ibm.com/alchemy-conductors/compliance-due-date-chaser
* README: https://github.ibm.com/alchemy-conductors/compliance-due-date-chaser/blob/master/README.md
* Jenkin's Job: TBD