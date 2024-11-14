---
layout: default
title: "AI Assistant Rotate Secret: aihelp--api_key"
runbook-name: "AI Assistant Rotate Secret: aihelp--api_key"
description: "AI Assistant Rotate Secret: aihelp--api_key"
service: "AI Assistant"
tags: ai-assistant, watson api key
link: /ai-assistant/operations/secret-rotation/rotate-aihelp-api_key.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: aihelp--api_key
- Purpose: Access to Watson services

## Example alerts

- None

## Detailed Information

This secret is managed by the AIHELP functional id and should only be rotated using the method in this runbook

## Detailed Procedure

> Note:  It is possible to rotate the secret directly in Secrets Manager however using the pipelines will generate the necessary change requests and validation.

- In the **AI HELP** account, open the **aihelp-operations-toolchain**
- Open the pipeline **Manage Dreadnought Secrets**
- Find the the trigger specific to the environment **[DEV / STAGE / PROD] - Rotate Secret: aihelp--api_key**
- Click `Run`.  No property values need to be updated

This trigger performs the following

- Creates a new ChangeRequest for Staging and Production
- Rotates the value in secrets manager for each environment
- Verifies that the secret was copied successfully

> Note:  By default the old secret is not removed.  It is renamed so it can be removed later.  The reason why it is not removed because it takes time for the new secret value to be pushed out to the cluster.

## Automation

- None
