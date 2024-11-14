---
layout: default
title: "AI Assistant Service: AI Assistant UI Component"
runbook-name: "AI Assistant Service: AI Assistant UI Component"
description: "AI Assistant Service: AI Assistant UI Component"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/alerts/ai-assistant-component.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The AI Assistant UI Component provides the UI and the "chat bot" functionality to the offering

This service is accessible via the `Help` icon in the console using the menu item `AI Assistant`.

## Detailed Information

Possible errors:

### AI Assistantlink is missing from UI

1. Check whether there are sysdig alerts indicating that the `ai-assistant-component` pods/replicas are not running.  If this is the case, review the logs to determine possible issues.  You may need to engage Dreadnought SRE for assistance ( see [Dependencies Runbook](ai-assistant-dependencies.html))

2. Check Cloud Logs to determine if there are any issues related to the dependencies ( REDIS )

3. Attempt to access the chat bot using multiple browser types ( private sessions as well as normal sessions )

4. If there are no errors in found and all dependencies are working as they should, you may need to contact the console team for assistance: [#console-cie](https://ibm.enterprise.slack.com/archives/CLJ4QQWNN)

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Further Information

[AI Assistant UI Component Technical Documentation](https://dev.console.test.cloud.ibm.com/docs/ai-assistant?topic=ai-assistant-ui-component)