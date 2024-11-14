---
layout: default
title: "AI Assistant Rotate Secret: aihelp-ai-component-session-secret-key"
runbook-name: "AI Assistant Rotate Secret: aihelp-ai-component-session-secret-key"
description: "AI Assistant Rotate Secret: aihelp-ai-component-session-secret-key"
service: "AI Assistant"
tags: ai-assistant, w3, secret rotation
link: /ai-assistant/operations/secret-rotation/rotate-aihelp-ai-component-session-secret-key.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: aihelp-ai-component-session-secret-key
- Purpose: Console session key

- **Access Role Required**: SRE Operator

## Example alerts

- None

## Detailed Information

This secret needs to be rotated manually.  Once rotated, the operator must immediately run the automation to push the new values to each of the environments.

**Important** Once you generate a new password, the old password is no longer valid.  All steps need to be completed in order.

## Detailed Procedure

The current process is to contact <jkung@us.ibm.com>

The information needed to provide is as follows

### Dev / Staging

```json
{
    "iam_id": "iam-ServiceId-1545ecc0-2bea-4e2f-8bac-1aa15eb728ca",
    "name": "session-ai-assistant",
    "description": "https://github.ibm.com/Bluemix/core-dev/issues/11600 - alexc@ca.ibm.com",
    "key_id": "ApiKey-12587dc0-e028-485b-8e92-78ef5a9d6e16"
}
```

### Production

```json
{
    "iam_id": "iam-ServiceId-1e265428-6187-4acb-a2d1-080c89d531e8",
    "name": "session-ai-assistant",
    "description": "https://github.ibm.com/Bluemix/core-dev/issues/11600 - alexc@ca.ibm.com",
    "key_id": "ApiKey-faa19197-d6ac-47ec-986c-76e70d477ead"
  }
```

> Note:  It is possible to rotate the secret directly in Secrets Manager however using the pipelines will generate the necessary change requests and validation.

Once you retrieve the new token value

- In the **AI HELP** account, open the **aihelp-operations-toolchain**
- Open the pipeline **Manage Dreadnought Secrets**
- Run the trigger **[DEV / STAGE / PROD] - Rotate Secret: aihelp--ai-component-iam-client-secret**
- Set the property `rotated-secret-value` to the new secret
- Click `Run`

This trigger performs the following

- Creates a new ChangeRequest for Staging and Production
- Rotates the value in secrets manager for each environment
- Verifies that the secret was copied successfully

ESO will refresh the value in the cluster and restart the services with the new value.

Once the secret has been rotated, please follow the information in the IAM document to invalidate the old value.

## Automation

- None
