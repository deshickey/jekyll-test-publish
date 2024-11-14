---
layout: default
title: "Alert: console-synlab.ui-sev2.qa"
runbook-name: "console-synlab.ui-sev2.qa"
description: "Synthetic monitor failure:  QA Analyzer health check"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/alerts/console-synlab.ai-sev2.qa.html
type: Alert
parent: AI Assistant
grand_parent: Armada Runbooks

---

Alert
{: .label .label-purple}


## Overview

This document provides detail on the Question Response Analysis tool.

This application is used by information SMEs to evaluate the responses provided by the AI Assistant tool.  Response evaluations are then used to improve the models which, in turn, improves the responses being returned to the end user.

The responses and evaluations are stored in a Postgres database.  Evaluators can open Git issues to track the evaluations.

Authentication for the application is managed by W3 login.  Access is managed by AccessHub according to the following flow

- User opens an accesshub request.   This will update the bluegroup `ai-contextual-help-qa-analyzer`
  - Application: AI Assistant Q&A Analyzer
  - Select role: Reviewer

Every 6 hours a process runs and will refresh the GHE team.  The refresh

- Adds new users to the GIT team that are specified in the bluegroup
- Removes users from the GIT team that are not in the bluegroup

## Example alert(s)

Alert Type:  Synthetic

INC7646671:PDE6361724:console-synlab.ai-sev2.qa - Metric: aggregate with value 2 crosses threshold 3

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
      "ok": true,
      "service": "Postgres"
    },
    {
      "ok": true,
      "service": "Github"
    },
    {
      "ok": true,
      "service": "W3"
    }
  ]
}
```

- Attempt to access the UI:  <https://ai-assistant.cloud.ibm.com/question-response-analyzer>
- If you have access, attempt a login
- Verify that the initial screen shows some graphs
- Verify that the second page shows a listing of responses to be evaluated

### Dependency Runbooks

If the system appears healthy and the alert does not resolve or if the health checks indicate an error, please review the appropriate runbook

- [Postgres](icd.html)
- [Github](github.html)
- [W3](w3.html)

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Reference (Optional)

See the [Dependencies Runbook](ai-assistant-dependencies.html) for information related to the services the AI Assistant depends on.

For component and networking information, see the [AI Assistant Overview](../operations/networking.html) runbook.

Synlab Console: <https://synthetics.cloud.ibm.com/kibana/s/console/app/discover#/view/2a6ff890-8046-11ec-b6c0-cb19f58f0fef?_g=(filters%3A!()%2CrefreshInterval%3A(pause%3A!f%2Cvalue%3A300000)%2Ctime%3A(from%3Anow-1h%2Cto%3Anow))>
