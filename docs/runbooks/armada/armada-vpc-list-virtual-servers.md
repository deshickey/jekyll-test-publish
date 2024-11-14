---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Virtual Private Cloud (VPC) - How to access list of virtual servers in the service account
service: armada-vpc
title: VPC - How to access list of virtual servers in service account
runbook-name: "VPC - How to access list of virtual servers in service account."
link: /armada/armada-vpc-list-virtual-servers.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

Describes how to list the virtual servers in the Virtual Private Cloud (VPC) Service account.

## Detailed Information

When a customer orders a worker node using VPC Gen1 or Gen2 options the
customer's virtual servers are provisioned in an account owned by IBM Kubernetes Service.

## Detailed Procedure

### Identify if the worker is Gen1 or Gen2

- Request the worker ID from the customer
- Query xo for the worker.

```text
  @xo worker <workerID>
```

- The value of `ActualProvider` will determine the generation.
  - `gc` is VPC Gen 1
  - `g2` is VPC Gen 2

### Accessing the list of virtual servers

- Log in to <https://cloud.ibm.com> (or <https://test.cloud.ibm.com> for stage).
- Switch to the account
  - Prod:
    - Gen 1: `IKS Prod VPC Classic Service TEST`
    - Gen 2: `IKS.Prod.VPC.Service`
  - Stage:
    - Gen 1: `IKS Stage VPC Classic Service`
    - Gen 2: `IKS.Stage.VPC.Service`
- Navigate to `VPC Infrastructure` and `Virtual Server Instances`
- Select desired `Region`

## Automation

None