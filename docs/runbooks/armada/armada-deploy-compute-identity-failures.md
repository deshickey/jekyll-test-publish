---
layout: default
description: How to handle armada-compute-identity failures.
title: armada-deploy - How to handle failures for compute identity.
service: armada-compute-identity
runbook-name: "armada-deploy - How to handle failures for compute identity"
tags: alchemy, armada-deploy, compute-identity, pod-identity
link: /armada/armada-deploy-compute-identity-failures.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle alerts which report that the microservice `armada-compute-identity` is having an issue handling requests to register or delete Compute Identity Providers. More information about the micorservice can be found in the [microservice git repo](https://github.ibm.com/alchemy-containers/armada-compute-identity).

The design for Compute Identity can be found in the Architecture Concept Document [IAM Pod Identity](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/iam-compute-identity.md). Note, Compute Identity and Pod Identity are used interchangeably.

## Example Alerts

~~~~
Labels:
 - alertname = armada-compute-identity/armada_compute_identity_failures
 - alert_situation = "armada-compute-identity/armada_compute_identity_failures"
 - service = armada-deploy
 - severity = critical
Annotations:
 - summary = "armada-compute-identity is experiencing consistent failures while attempting to manage Compute Identity Providers"
 - description = "armada-compute-identity has experienced 5 failures processing Compute Identity requests over the past 15 minutes"
~~~~

## Actions to take

Review the microservice logs for `armada-compute-identity` in LogDNA using the query `app:compute-identity error`. The logs can also be viewed by going to the hub directly and looking for the `armada-compute-identity` pod in the `armada` namespace.

Failures and Actions:
* ETCD related failure - Failure related to retrieving or setting ETCD data. Verify carrier ETCD is working correctly.
* `failed to create a new kube client` - Investigate if there are any other issues ongoing with the carrier/tugboat where the cluster's master is running.
* `failed to get web key set` or `error requesting web key set` - The cluster's JSON Web Key Set could not be retrieved using the kube config for the cluster. This includes a call to the cluster's master openid/v1/jwks url, `https://MASTER_URL/openid/v1/jwks`.  The keys are needed for registering the key set with IAM. Investigate if there are any other issues ongoing with the carrier/tugboat where the cluster's master is running. For satellite clusters, ensure the Location is healthy.
* `failed to get the IAM token using the API key` - The request to get the bearer token failed using the Service IAM API Key. This is preventing the armada-compute-identity microservice from communicating with IAM. See IAM Actions below.
* `error getting compute identity provider` - The request to get a Compute Identity Provider failed. The check is to verify if the provider exists already or not. See IAM Actions below.
* `error registering compute identity provider` - The request to register a Compute Identity Provider failed. The cluster cannot be associated with an identity provider. See IAM Actions below.
* `error registering compute identity key set` - The request to register a Compute Identity Key Set failed. The cluster keys cannot be associated with the Identity Provider. See IAM Actions below.
* `error deleing compute identity provider` - The request to delete the Compute Identity Provider failed. The association with the the cluster cannot be removed. See IAM Actions below.

Actions related to IAM errors:
* Find the response output from the request. See examples below.
* If the response code is `500` - Reach out to the IAM team for help in the #iam-issues slack channel.
* Look for other details in the response for clues about the underlying issue.

Example log entry for a post request response with a status code of `500`:
```
{"level":"error","time":"2021-06-17T10:38:20.461","msg":"post request returned a non-successful return code: 500","response":{"Status":"","StatusCode":500,"Proto":"","ProtoMajor":0,"ProtoMinor":0,"Header":null,"Body":{"Reader":{}},"ContentLength":0,"TransferEncoding":null,"Close":false,"Uncompressed":false,"Trailer":null,"Request":null,"TLS":null}}
```

Example log entry for a get request response with a status code of `500`:
```
{"level":"error","time":"2021-06-17T10:38:20.459","msg":"get request returned a non-successful return code: 500","response":{"Status":"","StatusCode":500,"Proto":"","ProtoMajor":0,"ProtoMinor":0,"Header":null,"Body":{"Reader":{}},"ContentLength":0,"TransferEncoding":null,"Close":false,"Uncompressed":false,"Trailer":null,"Request":null,"TLS":null}}
```

Example log entry for a delete request response with a status code of `500`:
```
{"level":"error","time":"2021-06-17T10:38:20.461","msg":"delete request returned a non-successful return code: 500","response":{"Status":"","StatusCode":500,"Proto":"","ProtoMajor":0,"ProtoMinor":0,"Header":null,"Body":{"Reader":{}},"ContentLength":0,"TransferEncoding":null,"Close":false,"Uncompressed":false,"Trailer":null,"Request":null,"TLS":null}}
```

## Dev notes

The pod-identity state can be set by the Jenkins Job [armada-deploy-set-podidentitystate](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-set-podidentitystate/).

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE:
- Create an issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository.
- Post the issue in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel.
- Silence the alert for 24 hours.