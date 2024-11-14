---
layout: default
title: "AI Assistant Rotate Secret: aihelp--IBM_SEARCH_API_KEY"
runbook-name: "AI Assistant Rotate Secret: aihelp--IBM_SEARCH_API_KEY"
description: "AI Assistant Rotate Secret: aihelp--IBM_SEARCH_API_KEY"
service: "AI Assistant"
tags: ai-assistant, w3, secret rotation
link: /ai-assistant/operations/secret-rotation/rotate_ibm_search_api_key.html
type: Operations
parent: AI Assistant
grand_parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Secret rotation

- Secret: aihelp--IBM_SEARCH_API_KEY
- Purpose: Access to unified search

- **Access Role Required**: SRE Operator

## Example alerts

- None

## Detailed Information

This secret needs to be rotated manually.  Once rotated, the operator must immediately run the automation to push the new values to each of the environments.

**Important** Once you generate a new password, the old password is no longer valid.  All steps need to be completed in order.

## Detailed Procedure

Important:  The key can only be rotated by `jschlot@us.ibm.com`

Documentation to obtain the key can be found on the [Unified Search Wiki](https://github.ibm.com/digital-marketplace/search-ai#obtain-your-search-wrapper-api-token)

Specific details to get access: <https://w3.ibm.com/w3publisher/search-and-discovery/adoption-integration/search-llm-wrapper-access-v2>

Once you retrieve the new token value

- In the **AI HELP** account, open the **aihelp-operations-toolchain**
- Open the pipeline **Manage Dreadnought Secrets**
- Run the trigger **ALL - Rotate Secret: aihelp--IBM_SEARCH_API_KEY**
- Set the property `rotated-secret-value` to the new secret
- Click `Run`

This trigger performs the following

- Creates a new ChangeRequest for Staging and Production
- Rotates the value in secrets manager for each environment
- Verifies that the secret was copied successfully

ESO will refresh the value in the cluster and restart the services with the new value.

## Automation

- None
