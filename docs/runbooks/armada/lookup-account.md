---
layout: default
title: Lookup information about an account
type: Informational
runbook-name: "Lookup an information about an account"
description: Information about an account includes owner email and account name and type and status
category: armada
service: armada-xo
tags: alchemy, armada, kubernetes, bss, account, lookup, armada-xo
link: /armada/lookup-account.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to lookup information an account from bss.  This is useful for helping to debug owner information for resources.

## Detailed Information
To lookup information about an account you will first need a BSS account id.  It is 32 characters without any dashes.

An example account id is `969beae4566d4511c40d68eac29d4912`.  Notice there is no dashes (`-`) in it.  If you have an account id with dashes it's not a BSS account id.

To lookup the account go into the `#xo-secure` channel in slack.

Type in `@xo bss-account <account id>`
   - ex. `@xo bss-account 969beae4566d4511c40d68eac29d4912`
   
If the account is found you will get a response like the following:

```
{
    "ID": "969beae4566d4511c40d68eac29d4912",
    "IMS": "",
    "IsActive": true,
    "IsPaid": true,
    "IsAPIKeyReset": false,
    "Type": "PAYG",
    "State": "ACTIVE",
    "OwnerEmail": "bob@us.ibm.com",
    "Name": "top secret account"
}
```

If the account is not found you will get a message like the following.

```
Region: us-east, Carrier: carrier1, Build: https://travis.ibm.com/alchemy-containers/armada-xo/builds/31682112
Error getting account from bss404 Not Found
```
