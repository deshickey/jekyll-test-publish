---
layout: default
title: "AI Assistant Service: QA Anlyzer"
runbook-name: "AI Assistant Service: QA Anlyzer"
description: "AI Assistant Service: QA Anlyzer"
service: "AI Assistant"
tags: ai-assistant, qa-analyzer
link: /ai-assistant/alerts/qa-analyzer.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

QA Analyzer is used to evaluate the responses provided by the AI Assistant.  The SME can indicate whether:

- The responsese were correct and appropriate
- The question was categorized correctly
- The linked resources were valid

Please see the link below in [Futher Information](#further-information)

## Detailed Information

QA analyzer has 3 dependencies:

### Postgres

- In case of an error accessing the Postgres db the user will probably see an empty dashboard without any data.
- In other cases, we should make sure the database is up and running. For more information check with #icd-questions slack channel

### w3id login

- This is the most important dependency, it is used to log in to the qa analyzer dashboard, and without it, the user will not be able to log in
- In case of a failure with the w3id login [use this runbook ](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/ai-assistant/alerts/w3.html)

### GitHub

- GitHub is used to create an issue as part of the evaluation process. In case of an error when calling GitHub the user wont be able to post an evaluation (Only if the `Create GitHub issue` checkbox is selected.)
- In case of an authorization error, the user will get a 401 error code when he is trying to post an evaluation. In such case we should check the `QA_GIT_TOKEN` - use [this runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/ai-assistant/operations/secret-rotation/rotate-aihelp-qa-git-token.html) to resolve this error
- In the case of other error codes returning from the GitHub API, we need to make sure GitHub is up and running and no maintenance is in progress.
- If GitHub is up and running and we still get an error code from Github the user can share with the team the response code from the error toast. 
- More information about the error can be found in the  Q&A Analyzer logs by searching the following: `Error while updating GIT service. Error:`

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Further Information

[QA Analyzer Technical Documentation](https://dev.console.test.cloud.ibm.com/docs/ai-assistant?topic=ai-assistant-qa-analyzer)