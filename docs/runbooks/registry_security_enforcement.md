---
layout: default
title: Registry - Security Enforcement - Customer tickets
type: Troubleshooting
runbook-name: "Registry - Security Enforcement - Customer tickets"
description: "Registry - Security Enforcement - Customer tickets"
service: Containers Registry
link: /registry_security_enforcement.html
playbooks: []
failure: []
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

A user may report that they are seeing issues with the Container Image Security Enforcement package. The customer receives an error message when creating their pods, or their pods do not appear when creating a deployment.


## Example Alert(s)

There are no example alerts for this runbook, these are likely to be customer problems reported through tickets.

## Investigation And Action

There will be additional details visible to the user, if they get the logs for the replicaset that was created. Ask them to run `kubectl describe deployment`, find their replicaset, then run `kubectl describe rs $replicaset`.

If the replicaset is being denied due to a policy configuration (the error message contains "Deny,"), ask the customer to fetch their imagepolicy and clusterimagepolicy. `kubectl get imagepolicy -o yaml; kubectl get clusterimagepolicy -o yaml`

Security Enforcement runs in the `ibm-system` Kubernetes namespace. The customer can run `kubectl get po -n ibm-system` to find the pods, and extract the logs.

## Status/Error messages

### Deny, no image policies or cluster polices for &lt;image-name&gt;

No policies match the requested image. Ask the user to create a policy. You can direct them to the docs at https://console.bluemix.net/docs/services/Registry/registry_security_enforce.html#customize_policies.

### The Vulnerability Advisor image scan assessment found issues with the container image that are not exempted. Refer to your image vulnerability report for more details by using the command `bx cr va`.

This means that the customer's image is marked as vulnerable in VA, and their security policy says to deny images when this is the case. Ask the customer to fix their image. Usually instructing the distribution's package manager to upgrade (`apt-get upgrade`, `apk update`, etc.) will retrieve the fixed versions of the offending packages.

### Deny, failed to get content trust information: &lt;description&gt;

A problem was detected with the trust data. This could be that the trust data doesn't exist, or that it is not valid for the image. Ask the customer to ensure the correctness of the trust data. You can direct them to the docs at https://console.bluemix.net/docs/services/Registry/registry_trusted_content.html#trustedcontent_viewsigned.

### Trust is not supported for images from this registry

The customer has trust enabled for images from third party registries in their security policy. Trust is only supported for images from IBM Cloud Container Registry. Ask the customer to modify their security policy to not enforce trust or VA for images from their third party registry.

### VA is not supported for images from this registry

The customer has VA enabled for images from third party registries in their security policy. VA is only supported for images from IBM Cloud Container Registry. Ask the customer to modify their security policy to not enforce trust or VA for images from their third party registry.

## Automation

None

## Escalation Policy

For any other issues, if the error message does not make it clear how to resolve, or if it is not listed in the above messages, then escalate to the registry team for further investigation.

[Slack](https://ibm-argonauts.slack.com/messages/C53RR7TPE/)

[PagerDuty](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)

[GitHub](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)