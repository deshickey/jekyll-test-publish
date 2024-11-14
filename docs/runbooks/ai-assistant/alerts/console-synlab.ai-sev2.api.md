---
layout: default
title: "Alert: console-synlab.ai-sev2.api"
runbook-name: "console-synlab.ai-sev2.api"
description: "AI Assistant monitor failure:  API Health Check"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/alerts/console-synlab.ai-sev2.api.html
type: Alert
parent: AI Assistant
grand_parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview

Alert is generated when a synthetic test fails a single time.

This is an **API** test that performs the following actions:

- Authenticates against IBM Cloud
- Checks the health endpoint for the service
- Posts a question to the service

## Example alert(s)

Alert Type:  Synthetic

INC7646671:PDE6361724:console-synlab.ai-sev2.api - Metric: aggregate with value 1 crosses threshold 0

## Automation

N/A

## Actions to take

- Verify the health of the system ( See: [Verify Health](#verify-the-health-of-the-system))
- Check for any potential CIEs in progress for dependencies ( See: [dependencies](ai-assistant-dependencies.html) )

If there are a large number of failures generated from a specific POP ( i.e.  Washington ) then check in the [#synthetics-issues](https://ibm.enterprise.slack.com/archives/C02A338FSA1)

### Verify the health of the system

- Check the health endpoints using the list below [health-endpoints](ai-assistant-dependencies.html#health-check-endpoints)

Expected Results: ( Cluster names will depend on the endpoint used.  Global endpoint will return information for the cluster geographically closest to where the command was run )

```json
{
  "cluster": "cpapi-au-syd-syd01-0001-cluster",
  "ok": true,
  "dependencies": [
    {
      "service": "agentic-assistant",
      "ok": true
    },
    {
      "ok": true,
      "service": "Postgres"
    },
    {
      "ok": true,
      "service": "Redis"
    },
    {
      "ok": true,
      "service": "AppId"
    },
    {
      "ok": true,
      "service": "Straker"
    }
  ]
}
```

- Login to the Cloud Console: <https://cloud.ibm.com>
- From the **Help** icon open the AI Assistant
- Enter a question in the chat window

### Dependency Runbooks

If the system appears healthy and the alert does not resolve or if the health checks indicate an error, please review the appropriate runbook

- [Postgres](icd.html)
- [Redis](icd.html)
- [agentic-assistant-service](agentic-assistant-service.html)

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Reference (Optional)

See the [Dependencies Runbook](ai-assistant-dependencies.html) for information related to the services the AI Assistant depends on.

For component and networking information, see the [AI Assistant Overview](../operations/networking.html) runbook.

Synlab Console: <https://synthetics.cloud.ibm.com/kibana/s/console/app/discover#/view/c22d1000-2cc4-11ef-af76-69ead25693a8?_g=(filters%3A!()%2CrefreshInterval%3A(pause%3A!f%2Cvalue%3A300000)%2Ctime%3A(from%3A'2024-09-30T16%3A52%3A00.000Z'%2Cto%3A'2024-09-30T16%3A52%3A30.000Z'))>
