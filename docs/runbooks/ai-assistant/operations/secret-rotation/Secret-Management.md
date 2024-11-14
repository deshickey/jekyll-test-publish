---
layout: default
title: "AI Assistant - Secrets Catalog"
runbook-name: "AI Assistant - Secrets Catalog"
description: "All secrets used to run and operate AI Assistant"
service: "AI Assistant"
tags: ai-assistant,secret rotation
link: /ai-assistant/operations/secret-rotation/secret-management.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook lists all the secrets that are used by the service as well as operate the service.

They are stored in the Secrets Manager instance for the different environments.

Once the secrets are set, they should not need to be changed, outside of rotation.  AI Help uses an External Secrets Operator to ensure the secrets stored in Secrets Manager and the secrets in the cluster stay in sync.

When a secret is rotated, ESO will make updates to the cluster within 5 minutes.

## Detailed Information

This document is broken down into the following sections

- Cluster secrets are those that reside in the cluster and are managed by the external secrets operator
- Operational secrets are used to manage and run the service within the Dreadnought infrastructure
- Operational secrets that are used to manage and run the service outside the Dreadnought infrastructure

### Cluster Secrets

The following secrets are used by the services and are deployed into the cluster

| Secret Name                             | Purpose                                         | Type                  | Rotation      | Used by services |
| ----                                    | ----                                            | ----                  | ----          | ----             |
| aihelp--postgres-credential             | Access to the Postgres database                 | Service Credential    | SM Managed    |                  |
| aihelp--redis-credential                | Access to the Redis database                    | Service Credential    | SM Managed    |                  |
| aihelp--app-config                      | Access to App Config                            | Service Credential    | SM Managed    |                  |
| aihelp--qp-sysdig-writer-apikey         | Used to write events to sysdig                  | IAM Credential        | SM Managed    |                  |
| aihelp--QA_GIT_TOKEN                    | Used to access WW GHE from QA Analyzer          | GHE Token             | [Link](rotate-aihelp-qa-git-token.html) | QA Analyzer |
| aihelp--W3_LOGIN_CLIENT_SECRET          | Used to authenticate for QA Analyzer            | W3 Client Secret      | [Link](rotate-aihelp-w3-login-password.html) | QA Analyzer |
| aihelp--api_key                         | Used to access Watson Services                  | FID managed API Key   | [Link](rotate-aihelp-api-key.html) | |
| aihelp--IBM_SEARCH_API_KEY              | Access Unified Search                           | Externally managed    | [Link](rotate_ibm_search_api_key.html) ||
| aihelp--VECTOR_DB_PASSWORD              | Access to Vector DB Search                      | Externally managed    | [Link](rotate-aihelp-vector-db-password.html) | |
| aihelp--watson_api_key                  | Used to access Watson Services                  | FID managed API Key   | [Link](rotate-aihelp-watson_api_key.html) | |
| aihelp--internal-service-token          | Used for enabling IAM Actions                   | SVCID managed API Key | [Link](rotate-aihelp-internal-service-token.html) | |
| aihelp--ai-component-iam-client-secret  | Used for IAM Authentication between services    | Externally managed    | [Link](rotate-aihelp-ai-component-iam-client-secret.html) | |
| aihelp--ai-component-session-secret-key | Used for console sessions                       | Externally managed    | [Link](rotate-aihelp-ai-component-session-secret-key.html) | |
| aihelp--APPID_CLIENT_SECRET             | Used to access translation services             | Externally managed    | [Link](rotate-aihelp-appid_client_secret.html) | |
| aihelp--SLACK_WEBHOOK                   | Used as part of logging and monitoring          | Externally managed    | NEEDS DOC | |
| aihelp--SLACK_TOKEN                     | Used as part of logging and monitoring          | Externally managed    | NEEDS DOC | |

#### The following are currently in Secrets manager but are not secrets

| SM Entry                   | Purpose |
| ----                       | ----    |
| aihelp--APPID_CLIENT_ID    | User/Account ID associated with tranlation services |
| aihelp--VECTOR_DB_USER     | Vector DB / Milvus userID |
| aihelp--W3_LOGIN_CLIENT_ID | Client Identifier for W3 login |
| aihelp--VECTOR_SERVER_PEM  | Vector DB / Milvus public cert |
| aihelp--watson_project_id  | Watson project ID used to access Watson services |
| aihelp--qra_session_key    | Salt to randomize header information |

### Operational Secrets

The following secrets are used to manage the environment and are not pushed into the cluster but are in the Dreadnought SM instance

| Secret Name                         | Purpose                                            | Type           | Environment |
| ----                                | ----                                               | ----           | ----        |
| aihelp--sre-stg-sm-reader-apikey    | Read access to Secrets manager - used by ESO       | IAM Credential | stage |
| aihelp--sre-stg-sm-writer-apikey    | Read access to Secrets manager - used by rotations | IAM Credential | stage |
| aihelp--stage-cos-ci-apikey         | COS Access                                         | IAM Credential | stage |
| dn--icr-reader-access-aihelp-apikey |                                                    | IAM Credential | stage |
| aihelp--cd-deployment-api-key       |                                                    | IAM Credential | stage |

## Further Information

None
