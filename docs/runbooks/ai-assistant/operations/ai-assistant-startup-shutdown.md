---
layout: default
title: "AI Assistant Startup / Shutdown Procedure"
runbook-name: "AI Assistant Startup / Shutdown Procedure"
description: "AI Assistant Startup / Shutdown Procedure"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/operations/ai-assistant-startup-shutdown.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Each Service must ensure documentation of Shutdown and Start Up Procedures to minimize the impact to operations during emergencies that require an ordered shutdown of the service in a Cloud Location.

## Detailed Information

AI Assistant is a global service currently deployed into the following regions:

- Washington, DC ( `us-east` )
- Sydney, Australia ( `au-syd` )
- Frankfurt, DE ( `eu-de` )

This service is deployed into the Dreadnought environment.

### Replicas per service

| Service                    | num Replicas |
| ----                       | :----:       |
| question-response-analzyer | 3            |
| slack-notifier-service     | 3            |
| query-processor            | 3            |
| data-filter                | 3            |
| contextual-search          | 6            |
| ai-assistant-component     | 3            |
| agentic-assistant-service  | 6            |

The information in the table above provide the number of replicas in production.

### Shutdown

In case of a regional emergency that requires us to reduce our workloads in that region, we can scale the number of replicas for our service to the desired level or to `0` to shut it down completly.

Access to the clusters to perform the shutdown requires administrative access and at this time would need to be done by the Dreadnought / Platform SRE teams.

### Startup

In a regional emergency which required the number of replicas to be reduced, they can be restored based on the table above.

Access to the clusters to perform the shutdown requires administrative access and at this time would need to be done by the Dreadnought / Platform SRE teams.

### Failover

AI Assistant is a global service.  Traffic to the regions is managed via Akamai load balancing. In the event that  region is completely unavailable, the traffic will be diverted to a health region.
