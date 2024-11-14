---
layout: default
title: "AI Assistant Rotate Secret: QA_GIT_TOKEN"
runbook-name: "AI Assistant Rotate Secret: QA_GIT_TOKEN"
description: "AI Assistant Rotate Secret: QA_GIT_TOKEN"
service: "AI Assistant"
tags: ai-assistant, w3, secret rotation
link: /ai-assistant/operations/secret-rotation/rotate-aihelp-ga-git-token.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: aihelp--QA_GIT_TOKEN
- Purpose: GIT Access to QA Analyzer tool

- **Access Role Required**: SRE Operator

## Example alerts

- None

## Detailed Information

This secret needs to be rotated manually.  Once rotated, the operator must immediately run the automation to push the new values to each of the environments.

This secret can only be rotated using the `aihelp` functional ID

## Detailed Procedure

In a private browsing session

- Browse to: <https://github.ibm.com>.  Login as the `aihelp` functional ID
- In the upper right of the page, click the profile icon and select **Settings**
- On the settings page select **Developer Settings** at the bottom left of the page
- Selet **Personal access tokens (Classic)**
- Click **Generate new token (Classic)**
- In the **Note** field provide a description which **MUST** include the environment the token is for ( i.e.  `qa-analyzer-stg`)
- Select **Expiration** as `90 days`
- Select **Repo** for scope
- Click **Generate**. Record this token as it is only shown once

> Note:  It is possible to rotate the secret directly in Secrets Manager however using the pipelines will generate the necessary change requests and validation.  Be sure that you select the proper trigger so the secret is rotated in the correct environment

- In the **AI HELP** account, open the **aihelp-operations-toolchain**
- Open the pipeline **Manage Dreadnought Secrets**
- Run the trigger **[DEV / STAGE / PROD] - Rotate Secret: aihelp--QA_GIT_TOKEN**
- Set the property `rotated-secret-value` to the new secret
- Click `Run`

This trigger performs the following

- Creates a new ChangeRequest for Staging and Production
- Rotates the value in secrets manager for each environment
- Verifies that the secret was copied successfully

ESO will refresh the value in the cluster and restart the services with the new value.

### Cleanup

> Note:  By default the old secret is not removed.  It is renamed so it can be removed later.  The reason why it is not removed because it takes time for the new secret value to be pushed out to the cluster.

- Once the secret has been rotated, the old value needs to be removed.

## Automation

- None
