---
layout: default
title: "AI Assistant Dependency: WW GHE"
runbook-name: "AI Assistant Dependency: WW GHE"
description: "AI Assistant Dependency: WW GHE"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/alerts/github.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook provides information on how WW GHE is used by the QA Analyzer tool.

## Detailed Information

GHE is used to track evaluation results.  Users can open issues in GHE directly from the analyzer tool.

If GHE is not accessible the tool can still be used for evaluations, however, Git issues can not be created.

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Further Information

Issues repository: <https://github.ibm.com/cloud-ai-assistant-evaluation/ai-assistant-issues/issues>

For information on how to access the repository, see [bluegroup-sync](../operations/bluegroup-sync.html)
