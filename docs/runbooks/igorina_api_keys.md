---
layout: default
description: How to create and publish a new Igorina API key
service: Igorina
title: Creating new Igorina API keys
runbook-name: Creating new Igorina API keys
playbooks: ["NoPlaybooksSpecified"]
failure: ["NoFailuresSpecified"]
link: /igorina_api_keys.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Igorina manages Chlorine actions and requests for Alchemy. If a service or custom client wishes to integrate with Igorina, it requires a REST API key.

## Example Alert(s)

None, this isn't an alert.

## Investigation and Action

See below.

## Escalation Policy

None.

---

## Detailed Information

See below.

---

## Issue: Someone wants a new API Key

They may request this via a conductors ticket.

### Solution:

1. Generate a new API key with `openssl rand -base64 31`:

```bash
$ openssl rand -base64 31
BUjtUFAxJsMZh8sao57XfKSjkaSI08U12ikNsPT5Rg==
```

2. Add it to the [chlorine-bot-creds repo](https://github.ibm.com/alchemy-1337/chlorine-bot-creds/) in the `{TARGET_ENVIRONMENT}/restcreds.json` file, e.g.:

```json
{
    "4tIsr7LQs8zxaqzNxbJ/6gJqCfjneXj8MqcqcjkebQ==": {
        "name": "Test Squad",
        "level": "1"
    },
    "BUjtUFAxJsMZh8sao57XfKSjkaSI08U12ikNsPT5Rg==": {
        "name": "New API Key",
        "level": "0"
    }
}
```
3. The `name` field is purely descriptive, make it as specific as possible, e.g. "Netint Lighthouse Promote Hooks" rather than just "Lighthouse"

4. `level` should almost always be `0` which is a basic user. `admin` with a value greater than `0` is also valid but should be reserved for only when it is strictly necessary.

5. Build first `chlorine-ha-build` then promote to the target enviornment [Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/chlorine-ha-build/).
