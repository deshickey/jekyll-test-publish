---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Virtual Private Cloud (VPC) - When and how to raise a support ticket for VPC workers
service: armada-vpc
title: VPC - When and how to raise a support ticket for a worker
runbook-name: "VPC - When and how to raise a support ticket for a worker."
link: /armada/armada-vpc-raise-support-ticket-for-worker.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

Describes When and how to raise a support ticket for Virtual Private Cloud (VPC) Gen1 or VPC Gen2.

## Detailed Information

When a customer orders a worker node using VPC Gen1 or Gen2 options the
customer's virtual servers are provisioned in an account owned by IBM Kubernetes Service.
The customer is unable to raise a support ticket directly against the VPC team because
the virtual server is in the IKS owned account.

When to raise a support ticket against the VPC team

- A customer has reported a virtual server instance is in failed state and can not be deleted
- A customer has reported a virtual server instance is stuck in a pending state

## Detailed Procedure

Identify if the worker is Gen1 or Gen2

- Request the worker ID from the customer
- Query xo for the worker.

```text
  @xo worker <workerID>
```

- The value of `ActualProvider` will determine the generation.
  - `gc` is VPC Gen 1
  - `g2` is VPC Gen 2

How to raise a support ticket:

- Log in to <https://cloud.ibm.com>
- Switch to the relevant account
  - Gen 1: `IKS Prod VPC Classic Service` (9751a0d772e5457eb52eb4c747f1c1b7)
  - Gen 2: `IKS.Prod.VPC.Service` (bab556e1c47446ef8da61e399343a3e7)
- Navigate to a <https://cloud.ibm.com/unifiedsupport/cases/add> and select the following...
  - Offering - `Virtual Server for VPC`
  - Subject - Provide a brief summary
  - Description - Provide more details about the situation the customer is facing.
    Include the Hostname of the instance.

## Escalation

If this is a request that requires urgent attention from the VPC team, once the ticket ID has been created, follow up in `ipops-cases` channel in the `ibm-cloudplatform.slack.com` workspace. [Link](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD)

When requesting additional help, highlight the request is coming from the IKS SRE team.

## Automation

None