---
layout: default
title: "AI Assistant Service: Slack Notifier"
runbook-name: "AI Assistant Service: Slack Notifier"
description: "AI Assistant Service: Slack Notifier"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/alerts/slack-notifier.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The Slack Notifier is only used for internal development team notifications.

It sends slack messages containing the questions and answers from the AI Assistant, including references to the documents used in generating the answer and other analysis information.

## Detailed Information

For any error, the Query Processor logs will show `Error in Slack notification service: ....` and will continue as normal

Possible errors could be:

- IAM failed to connect
- IAM failed to validate QP token
- Failed to connect to Postgres

These will result in error logs from the SlackNotifier

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Further Information

[Slack Notifier Technical Documentation](https://dev.console.test.cloud.ibm.com/docs/ai-assistant?topic=ai-assistant-slack-notifier)
