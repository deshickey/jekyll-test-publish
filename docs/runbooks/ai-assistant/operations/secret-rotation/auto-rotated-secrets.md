---
layout: default
title: "AI Assistant - Secrets auto-rotated via Secrets Manager"
runbook-name: "AI Assistant - Secrets auto-rotated via Secrets Manager"
description: "Secrets auto-rotated via Secrets Manager"
service: "AI Assistant"
tags: ai-assistant,secret rotation
link: /ai-assistant/operations/secret-rotation/auto-rotated-secrets.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---
Informational
{: .label }

## Overview

This runbook lists the secrets that are rotated by Secret Manager in each Dreadnought environment

## Detailed Information

### Cluser Secrets

The following secrets are used by the services and are deployed into the cluster

| Secret Name                     | Purpose                         | Type               | Used by services |
| ----                            | ----                            | ----               | ----             |
| aihelp--postgres-credential     | Access to the Postgres database | Service Credential |                  |
| aihelp--redis-credential        | Access to the Redis database    | Service Credential |                  |
| aihelp--app-config              | Access to App Config            | Service Credential |                  |
| aihelp--qp-sysdig-writer-apikey | Used to write events to sysdig  | IAM Credential     |                  |

### Operational Secrets

The following secrets are used to manage the environment and are not pushed into the cluster

| Secret Name                         | Purpose                                            | Type           |
| ----                                | ----                                               | ----           |
| aihelp--sre-stg-sm-reader-apikey    | Read access to Secrets manager - used by ESO       | IAM Credential |
| aihelp--sre-stg-sm-writer-apikey    | Read access to Secrets manager - used by rotations | IAM Credential |
| aihelp--stage-cos-ci-apikey         | COS Access                                         | IAM Credential |
| dn--icr-reader-access-aihelp-apikey |                                                    | IAM Credential |
| aihelp--cd-deployment-api-key       |                                                    | IAM Credential |

## Further Information (Optional)

None
