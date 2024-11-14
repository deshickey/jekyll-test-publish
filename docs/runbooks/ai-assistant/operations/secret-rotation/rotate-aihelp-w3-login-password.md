---
layout: default
title: "AI Assistant Rotate Secret: W3_CLIENT_PASSWORD"
runbook-name: "AI Assistant Rotate Secret: W3_CLIENT_PASSWORD"
description: "AI Assistant Rotate Secret: W3_CLIENT_PASSWORD"
service: "AI Assistant"
tags: ai-assistant, w3, secret rotation
link: /ai-assistant/operations/secret-rotation/rotate-w3-login-password.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: aihelp--W3_LOGIN_CLIENT_SECRET
- Purpose: W3 authentication for Question Analyzer tool

- **Access Role Required**: SRE Operator

## Example alerts

- None

## Detailed Information

This secret needs to be rotated manually.  Once rotated, the operator must immediately run the automation to push the new values to each of the environments.

**Important** Once you generate a new password, the old password is no longer valid.  All steps need to be completed in order.

## Detailed Procedure

- Browse to: <https://ies-provisioner.prod.identity-services.intranet.ibm.com/tools/sso/home>
- Select **Manage my SSO registrations**
- Select **Q & A Analyzer** and click **Edit**
- Selet **Edit** next to the provider to update
- On the client details page, select **Edit**
- Next to **Client Secret** click **Generate**
- Click **Next**

> Note:  It is possible to rotate the secret directly in Secrets Manager however using the pipelines will generate the necessary change requests and validation.

- In the **AI HELP** account, open the **aihelp-operations-toolchain**
- Open the pipeline **Manage Dreadnought Secrets**
- Run the trigger **ALL - Rotate Secret: aihelp--W3_LOGIN_CLIENT_SECRET**
- Set the property `rotated-secret-value` to the new secret
- Click `Run`

This trigger performs the following

- Creates a new ChangeRequest for Staging and Production
- Rotates the value in secrets manager for each environment
- Verifies that the secret was copied successfully

ESO will refresh the value in the cluster and restart the services with the new value.

## Automation

- None
