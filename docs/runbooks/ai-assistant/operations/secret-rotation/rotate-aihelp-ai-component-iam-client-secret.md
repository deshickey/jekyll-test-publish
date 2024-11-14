---
layout: default
title: "AI Assistant Rotate Secret: aihelp--ai-component-iam-client-secret"
runbook-name: "AI Assistant Rotate Secret: aihelp--ai-component-iam-client-secret"
description: "AI Assistant Rotate Secret: aihelp--ai-component-iam-client-secret"
service: "AI Assistant"
tags: ai-assistant, w3, secret rotation
link: /ai-assistant/operations/secret-rotation/rotate-aihelp-ai-component-iam-client-secret.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: aihelp--ai-component-iam-client-secret
- Purpose: IAM Access token

- **Access Role Required**: SRE Operator

## Example alerts

- None

## Detailed Information

This secret needs to be rotated manually.  Once rotated, the operator must immediately run the automation to push the new values to each of the environments.

**Important** Once you generate a new password, the old password is no longer valid.  All steps need to be completed in order.

## Detailed Procedure

Important:  The initial process needs to be done by the owner of the clientID.

- Please follow the [CLIENT SECRET ROTATION instructions](https://github.ibm.com/BlueMix-Fabric/CloudIAM-APIKeys/blob/integration/runbooks/reference/client_secret_rotation.md) provided by the IAM team

- **CURRENT_CLIENT_SECRET**: This value needs to come from the SM instance in the environment ( dev / stage are the same value ).  To get this value, the `aihelp` userID needs to be used.
- **OLD_SECRET_VALID_FOR**:  This value is in seconds and should be at least the equivalent of `30 minutes` : `1800 seconds`

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
