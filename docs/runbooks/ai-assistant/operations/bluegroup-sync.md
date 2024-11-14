---
layout: default
title: "Bluegroup Access Sync"
runbook-name: "Bluegroup Access Sync"
description: "Bluegroup Access Sync"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/operations/bluegroup-sync.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

The Question Analyzer service uses Bluegroups and W3 authentication.  There is a feature in this tool to open, update, and manage issues in Git.  

## Detailed Information

To remove the need for multiple levels of requests, the team has implemented a sync process the manages the membership in the GHE team based on the membership in the Blue group.  This process performs the following actions

- Retrieves the listing of users from the desired Bluegroup
- Compares the user list with the members in the Github team
- Adds any users that are in the Bluegroup but not on the Github team
- Removes any users that are in the Github team but not in the Bluegroup

When the sync is complete, the status is posted to Slack.

Access to the Bluegroup is managed via AccessHub which is also enabled with OOB and 2 level approvals as required.   If a user is removed from the Bluegroup, the next sync will also remove that user from the GHE team

## Further Information

The table below provides information on the current process

| Bluegroup                      | GHE Organization              |GHE Team                   | Trigger | Frequency |
| ----                           | ----                          | ----                      | ----    | ----      |
| ai-contextual-help-qa-analyzer | cloud-ai-assistant-evaluation | ai-assistant-issue-triage | [Link](https://cloud.ibm.com/devops/pipelines/tekton/6bfdc479-225f-4992-ad7f-3ee809d719b8/runs?env_id=ibm:yp:us-east&triggerName=Sync+Bluegroup%3A+ai-contextual-help-qa-analyzer+with+team%3Aai-assistant-issue-triage) | Every 6h |
