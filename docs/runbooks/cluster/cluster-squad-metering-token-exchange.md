---
layout: default
title: armada-cluster - Metering IAM Token Exchange Failures
type: Alert
runbook-name: "armada-cluster - Metering IAM Token Exchange Failures"
description: armada-cluster - Metering IAM Token Exchange Failures
category: armada
service: armada-cluster
link: /cluster/cluster-squad-metering-token-exchange.html
tags: armada-cluster, iam, metering
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

These alerts will trigger when more than 50 occurrences of an error from IAM token exchange occur within an hour.

## Example Alert

There are **two alerts** that can indicate failures 

Example PD title:

```text
#XXXXXXX: bluemix.containers-kubernetes.armada-cluster_error_metering_token_exchange.us-south
#XXXXXXX: bluemix.containers-kubernetes.armada-billing_error_metering_token_exchange.us-south
```

## Actions to Take

The steps below describe the operations to perform to determine the appropriate action.

1. Raise a pCIE for the affected region(s)
    - Title: Customers may see delays when provisioning or deleting workers
    - Use the [notification template](#pcie-notification-template)
1. Check the logs in **LogDNA** for **each** region the alert is firing in

    1. Select the correct LogDNA instance for the region specified in the alert  
    Logs can be accessed through [the dashboard](https://alchemy-dashboard.containers.cloud.ibm.com) 
    1. In the left hand pane under `CLUSTER-SQUAD` there should be a view called `MeteringErrors`
    1. Enter `ErrorMeteringTokenExchangeFailure` to the search bar in LogDNA
    1. Use that view to search for lines containing this reason code

1. Check the wrapped error message in the log

   Here is an example message:

   ```text
   ErrorMeteringTokenExchangeFailure: Failed to prepare OpenShift license metering  IAM token exchange failure 
   Wrapped Errors: ["The IAM token exchange request failed. (429)","Failed to decode response (429): \"ApiKey based rate limit for calls to /token\"","invalid character 'A' looking for beginning of value"]
   ```

1. If the error message references possible authentication or authorization issues (error code 401 or 403), there is likely to be an issue with the API Key used by the IKS Service. Review recent API Key rotations/removals carried out by SRE and replace the key as necessary.
1. For other messages, page the troutbridge squad for further investigation [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98)


---

## Escalation Policy

Raise a pCIE and page the relevant team(s) based on the actions described [above](#actions-to-take)

### pCIE Notification template

   ```txt
   TITLE:   Customers may see delays when provisioning or deleting workers

   SERVICES/COMPONENTS AFFECTED:
   - IBM Kubernetes Service
   - Red Hat OpenShift on IBM Cloud

   IMPACT:
   - Users may see delays in provisioning workers for new or existing Kubernetes clusters
   - Users may see delays in reloading, rebooting or deleting existing workers of Kubernetes clusters

   STATUS:
   - 20XX-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
   ```

---

## Notes for troutbridge squad 

We need to answer the following questions...

- Are the failures intermittent?
  - Check CPO channels for affected regions to see if any metering is happening. What we're looking for are posts that say:
    - Worker metering started
    - Worker metering stopped
    - OpenShift licences usage submitted
  - Attempt to provision a cluster if there is not a lot of activity in CPO
- What is the nature of the failures?
  - Network related failures?
    - Is there an open IAM CIE? Ask in #conductors to see if they are aware of any IAM CIEs?
    - Use LogDNA to highlight failure messages
    - Are the failures scoped to a single pod? Yes? Ask SRE to delete the pod.
    - If more pods are hitting network issues
      - Are we seeing network failures for BSS/SoftLayer/VPC too?
      - Are other services seeing network failures for IAM?
      - Request assistance from SRE to investigate network stability, further help from Ingress may be required
  - Rate limiting (429)
    - Post in #iam-issues requesting information on potential changes to IAM configurations that could cause us to be rate limited
    - Are other IKS services being rate limited?
      - for example armada-api, armada-cluster, armada-billing, armada-provider-riaas, armada-orchestrator could be impacted, but just searching for the rate limiting area ( e.g. search keywords: "`iam apikey rate limit`" ) would show which services are affected
    - Work with Ironsides and Ingress to see if there's something that's changed in our configuration recently that could cause us to be rate limited
  - Other failures
    - Is there an ongoing IAM CIE that could cause the failure?
    - Work with the team in #iam-issues or page IAM if out of office hours to understand the failure