---
layout: default
title: "AI Assistant Service: Query Processor"
runbook-name: "AI Assistant Service: Query Processor"
description: "AI Assistant Service: Query Processor"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/alerts/query-processor.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The Query Processor microservice is the root of the AI Contextual Help application. It is the entry point to the application and is connected to all other microservices in the application.

## Detailed Information

## API endpoints overview
The query-processor microservice provides following API endpoints

**/ask**
This API endpoint routes the question to be asked to the agentic service.

**/feedback**
This API endpoint is used to get user feedback to the answers returned by the agentic service.

**/health/healthz**
This is an internal endpoint used to provide information about the health state of the query-processor microservice.

## GitHub repository

Code of query-processor resides in this GitHub repository:https://github.ibm.com/ai-content/query-processor

## Error handling

This section describes possible errors with query-processor and how they can be solved

### Error 1

Request not routed to agentic service

### Solution 1

- Check configuration of the AppConfiguration service as described in https://github.ibm.com/ibmcloud/ai-contextual-help/wiki/Query-Processor. In the failing environment (development, staging, or production), is the feature flag set to true for the failing user? Check targeting segments and general configuration in AppConfiguration service.
- Check log files for query-processor errors, e.g. "AppConfig Client has not been initialized yet" or "Did not find AppConfiguration configuration, bootstrapping NoopAppConfiguration"

### Error 2

Instead of an response from the agentic service, the user gets an error message

### Solution 2

Check log file for errors from query-processor. In case of an exception from another service, details should be in the log file. For example, if agentic assistant service returned with an error, details are contained in the log entry starting with "Error in Agentic Assistant service" .

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Further Information

[Query Processor Technical Documentation](https://dev.console.test.cloud.ibm.com/docs/ai-assistant?topic=ai-assistant-query-processor)
