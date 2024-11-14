---
layout: default
title: "AI Assistant Dependency: ICD"
runbook-name: "AI Assistant Dependency: ICD"
description: "AI Assistant Dependency: ICD"
service: "AI Assistant"
tags: ai-assistant, redis, postgres
link: /ai-assistant/alerts/icd.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

General information about ICD services used by AI Assistant

## Detailed Information

### Postgres

Database is used to gather information about the responses.  Information is used for improving the models and evaluating the correctness of the respoonses being generated.

### Redis

Redis is used as a cache for authentication tokens

## Further Information

ICD escalations require a SEV1 or SEV2 support ticket

## Escalation Policy

- If the service is being affected by a dependency, please follow the information in the [Dependencies Runbook](ai-assistant-dependencies.html)
- If the service is not functional, please follow the escalation policy documented in the [AI Assistant Escalation Policy](../ai-assistant-escalation-policy.html)

### CRN Information

| Env   | Service      | Version | CRN  |
| ----  | ----         | ----    | ---- |
| Dev   | ICD Postgres |  14     | crn:v1:bluemix:public:databases-for-postgresql:eu-gb:a/7d628d4c66f840f2b7baf3af96a0e3c2:3659643f-a332-490b-8573-4266c3b072a4:: |
| Dev   | ICD Redis    |  6.2    | crn:v1:bluemix:public:databases-for-redis:eu-gb:a/7d628d4c66f840f2b7baf3af96a0e3c2:f7a03031-3fe0-4252-aad3-93fca419d3fb:: |
| Stage | ICD Postgres |  14     | crn:v1:bluemix:public:databases-for-postgresql:eu-gb:a/c51c30c3178047acb15d947c7b6e5852:28eaf47c-ef29-48eb-bfdd-43c1ffbf98e9:: |
| Stage | ICD Redis    |  6.2    | crn:v1:bluemix:public:databases-for-redis:eu-gb:a/c51c30c3178047acb15d947c7b6e5852:cb9e364f-63ca-47bd-9ca6-18396e678764:: |
| Prod  | ICD Postgres |  14     | crn:v1:bluemix:public:databases-for-postgresql:eu-de:a/a708cf9c0032433782568b6baf876b14:3757d370-ffd7-4bfe-85b3-7c9f2c728ed1:: |
| Prod  | ICD Redis    |  6.2    | crn:v1:bluemix:public:databases-for-redis:eu-de:a/a708cf9c0032433782568b6baf876b14:97a835df-fec4-424e-b6ea-8c9982aa17f1:: |
