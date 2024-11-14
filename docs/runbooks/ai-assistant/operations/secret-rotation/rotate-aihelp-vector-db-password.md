---
layout: default
title: "Rotate Secret: aihelp--VECTOR_DB_PASSWORD"
runbook-name: "Rotate Secret: aihelp--VECTOR_DB_PASSWORD"
description: "Rotate Secret: aihelp--VECTOR_DB_PASSWORD"
service: "AI Assistant"
tags: ai-assistant, vector-db-password, milvus
link: /ai-assistant/operations/secret-rotation/aihelp-rotate-vector-db-password.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: aihelp--VECTOR_DB_PASSWORD
- Purpose: Access to the Vector DB search ( Milvus ) hosted by CIO
- Support channel: #cio-milvus-aas

**Access Role Required**: SRE Operator

## Example alerts

- None

## Detailed Information

This secret needs to be rotated manually using the `aihelp@ibm.com` functional user.  Once rotated, the operator must immediately run the automation to push the new values to each of the environments.

**Important** Once you generate a new password, the old password is no longer valid.  All steps need to be completed in order.

## Detailed Procedure

Using a PRIVATE browser session

- Browse to: <https://dataservices.cirrus.ibm.com/login>
- Login using the `aihelp` functional ID
- Browse to: <https://dataservices.cirrus.ibm.com/db2/milvus/reset-password>
- Click: **Generate Password**

> Note:  It is possible to rotate the secret directly in Secrets Manager however using the pipelines will generate the necessary change requests and validation.

- In the **AI HELP** account, open the **aihelp-operations-toolchain**
- Open the pipeline **Manage Dreadnought Secrets**
- Run the trigger **ALL - Rotate Secret: aihelp--VECTOR_DB_PASSWORD**
- Set the property `rotated-secret-value` to the new secret
- Click `Run`

This trigger performs the following

- Creates a new ChangeRequest for Staging and Production
- Rotates the value in secrets manager for each environment
- Verifies that the secret was rotated successfully

ESO will refresh the value in the cluster and restart the services with the new value.

## Automation

- None
