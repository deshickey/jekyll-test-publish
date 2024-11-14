---
layout: default
title: "AI Assistant Service: Agentic Assistant"
runbook-name: "AI Assistant Service: Agentic Assistant"
description: "AI Assistant Service: Agentic Assistant"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/alerts/agentic-assistant.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

With the Agentic Assistant microservice we are able to query data in unified search to find chunks of info to include in the prompt for answering questions.

Today, we have two retrieval options incorporated into the Agentic Assistant microservice. We can query against the UnifiedSearch Search Wrapper and UnifiedSearch Milvus vector database.

Both Search Wrapper and Milvus are combined by using a ensemble search method, were the best matches of both sources are combined.

## Detailed Information

Agentic Assistant Service relies on

- Unified Search
- Milvus / Vector Search
- Watson Machine Learning for
  - Embeddings for search and vector search
  - LLMs for inference of different aspects for refining the search query and results.

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

## Further Information

[Agentic Assistant Technical Info](https://dev.console.test.cloud.ibm.com/docs/ai-assistant?topic=ai-assistant-agentic)
