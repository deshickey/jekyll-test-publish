---
layout: default
title: "AI Assistant Dependencies"
runbook-name: "AI Assistant Dependencies"
description: "AI Assistant Dependencies"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/operations/dependencies.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook contains information about the AI Assistant dependencies.

## Detailed Information

Use the information below to check the health of the service as well as contact information if there is an issue that requires assistance from another team

| Service        | Slack Channel              | Support Process |
| ----           | ----                       | ----            |
| ICD Postgres   | [#icd-downstream-cie-support](https://ibm.enterprise.slack.com/archives/GHGGLV43U)| [ICD Issues](./icd.html)|
| ICD Redis      | [#icd-downstream-cie-support](https://ibm.enterprise.slack.com/archives/GHGGLV43U)| [ICD Issues](./icd.html)|
| Milvus         | [#cio-milvus-aas](https://ibm.enterprise.slack.com/archives/C06DFHTL3QA)            | Slack |
| Search Wrapper | [#m-search](https://ibm.enterprise.slack.com/archives/C5AENNYL9)                  | <https://w3.ibm.com/w3publisher/search-and-discovery> |
| WW GHE         | [#whitewater-github](https://ibm.enterprise.slack.com/archives/C3SSJ6CSE)         | Slack |
| W3 Login       | [#w3id-support](https://ibm.enterprise.slack.com/archives/C04RFL1SP18)              | Slack |
| One Pipeline   | [#devops-compliance](https://ibm.enterprise.slack.com/archives/CFQHG5PP1)         | Slack |

For escalation and CIE channels, please see [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Health Check endpoints

The following endpoints will provide details on the different dependencies

### AI Assistant: Global endpoint

This will return the health based on the region closest to the user running the command

```bash
curl -s https://ai-assistant.cloud.ibm.com/ai-contextual-help/v1/health/healthz | jq '.'
```

### AI Assistant: Region specific endpoints

```bash
- curl -s https://au-syd-1.ai-assistant.cloud.ibm.com/ai-contextual-help/v1/health/healthz | jq '.'
- curl -s https://eu-de-1.ai-assistant.cloud.ibm.com/ai-contextual-help/v1/health/healthz | jq '.'
- curl -s https://us-east-1.ai-assistant.cloud.ibm.com/ai-contextual-help/v1/health/healthz | jq '.'
```

### Question Analyzer: Global endpoint

This will return the health based on the region closest to the user running the command

```bash
- curl -s https://ai-assistant.cloud.ibm.com/question-response-analyzer/v1/health/healthz | jq '.'
```

### Question Analyzer: Region specific endpoints

```bash
- curl -s https://au-syd-1.ai-assistant.cloud.ibm.com/question-response-analyzer/v1/health/healthz | jq '.'
- curl -s https://eu-de-1.ai-assistant.cloud.ibm.com/question-response-analyzer/v1/health/healthz | jq '.'
- curl -s https://us-east-1.ai-assistant.cloud.ibm.com/question-response-analyzer/v1/health/healthz | jq '.'
```
