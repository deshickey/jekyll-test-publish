---
layout: default
title: "AI Assistant Rotate Secret: docker-contextual-search-lakehouse-token"
runbook-name: "AI Assistant Rotate Secret: docker-contextual-search-lakehouse-token"
description: "AI Assistant Rotate Secret: docker-contextual-search-lakehouse-token"
service: "AI Assistant"
tags: ai-assistant, lakehouse token
link: /ai-assistant/operations/secret-rotation/rotate-lakehouse-token.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: docker-contextual-search-lakehouse-token
- Purpose: Access to the `slate_30m` embedder model
- Support channel: #research-lakehouse-support

**Access Role Required**: SRE Operator

## Example alerts

- None

## Detailed Information

This secret needs to be rotated manually using the `aihelp@ibm.com` functional user.  Once rotated, the operator must immediately run the automation to push the new values to each of the environments.

**Important** Once you generate a new password, the old password is no longer valid.  All steps need to be completed in order.

## Detailed Procedure

Using a PRIVATE browser session

- Browse to: <https://watsonx-data.cash.sl.cloud9.ibm.com/token>
- Login using the `aihelp` functional ID
- Under the profile avatar select **Lakehouse Token**.
- Select 90 days for the Token validity duration value.
- Click **Generate Token**

> Note:  It is possible to rotate the secret directly in Secrets Manager however using the pipelines will generate the necessary change requests and validation.

- In the **AI HELP** account, open the **aihelp-operations-toolchain**
- Open the pipeline **Rotate Operations Secrets**
- Run the trigger **Rotate docker-contextual-search-lakehouse-token**
- Set the property `rotated-secret-value` to the new secret
- Click `Run`

This trigger performs the following

- Creates a new ChangeRequest for Staging and Production
- Rotates the value in secrets manager for each environment
- Verifies that the secret was copied successfully

> Note: This secret is used at build time and is not pushed out to the cluster

## Automation

- None
