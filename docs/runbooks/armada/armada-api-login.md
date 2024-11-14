---
layout: default
description: How to resolve authentication errors when using the armada API or CLI
title: armada-api - How to resolve authentication errors when using the armada API or CLI
service: armada-api
runbook-name: "armada-api - authentication errors"
tags: alchemy, armada, authentication, 401
link: /armada/armada-api-login.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes some common authentication errors with armada-api and how to resolve them.

## Example Alerts

User attempts to list clusters using the armada CLI. They receive an authentication error:

```
$ bx cs clusters
Listing clusters...
FAILED

Not authorized. Log in to Bluemix and try again. (E0003)
Incident ID: bc8feb57-c156-4643-b117-a695a0580063
```

The format of the error message is:

```
<message> (<code>)
Incident ID: <ID>
```

The `code` and `incident ID` are very useful for developers in debugging. The `message` is for the benefit of the user to provide them a reasonable explanation about what is wrong. To specfically look at logs about a given failure, use the `incident ID` as a search key in Kibana for full details about the request. The `code` can be searched for in the armada-api project to determine the logic around the authentication decision.

## Investigation and Action

### Accessing logs

Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment.

### Common authentication errors

A few of the common authentication failure codes are discussed along with resolution steps.

#### E0003

The user's UAA or IAM token cannot be validated against the desired resource. There are a few common causes:

- Token is expired
- Token signature cannot be validated
- Valid token used in combination with an invalid resource (e.g pointing to the wrong account)
- Valid token but no policy exists on IAM PEP endpoint
- Token for `stage` or `prestage` environment pointed at `production`

The general resolution for an `E0003` incident is to request the user:

1. Login to bluemix again using `bx login -a <UAA endpoint>` and ensure the UAA endpoint is the desired environment
1. Re-run `bx cs init --host <armada-api endpoint>` and ensure the armada-api endpoint is the desired environment

Alternatively, the UAA or IAM services may be in error. For example, the IAM service could be down and the armada-api service is unable to authorize users. In this case, the armada-api logs will need to be inspected to determine if errors are being printed related to timeouts or connection failures to IAM endpoints.

#### E0015

The user's provided Softlayer credentials are not able to successfully authenticate against the Softlayer API. Suggest to the user to verify their Softlayer username and API key, and reset them in armada using the following command:

```
bx cs credentials-set --softlayer-username <user> --softlayer-api-key <API key>
```

#### E0018

An admin API was accessed and the user does not have sufficient permission to perform the action. The API team manages an IAM policy to control read/write and read-only access to certain `/admin` REST endpoints. We are willing to provide limited read-only access on an as-needed basis. Contact the armada-api squad on Slack @blackbeard to request read-only admin access.

#### E0031

A token has expired and can no longer be validated. Have the user follow steps from `E0003` to request a new token and re-initialize the armada-api endpoint.

#### E0057

A linked IMS account is required to complete an operation and the provided token does not have this capability. Any armada operation that requires interaction with softlayer (paid clusters, VLAN, subnets, etc) requires either an linkd IMS account or softlayer username and API key to authenticate.

There are two resolutions to `E0057` incident:

1. The user must acquire a token with linked IMS account
1. The user may alternatively acquire a valid softlayer username and API key and set them on the account using `bx cs credentials-set --softlayer-username <user> --softlayer-api-key <API key>`

## Escalation Policy

It's likely that you'll need to include the armada-api squad when the actions taken do not resolve this issue.

Review the [escalation policy](./armada_pagerduty_escalation_policies.html) document for full details of which squad to escalate to.
