---
layout: default
title: Grant access to production VPC related network accounts
type: Informational
runbook-name: Grant developers access to production VPC related network accounts
description: Grant developers access to production VPC related network accounts
service: Conductors
link: /armada/grant-developers-prod-vpc-network-account-access.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview (Required)

This runbook describes the process for developers to request and be granted access to production VPC related network accounts.

## Detailed Information (Required)

### Developer actions

1. Login to with the w3 ID and password for the user requiring access - [USAM](https://usam.svl.ibm.com:9443/AM/)
1. Click `Request system access`, in the `System search` section search for `Argonauts`
1. The id to request should be your w3 ID
1. Select `iks_vpc/iks_vpc_networkacct-prod-cloud-squad` from the available list, entering a justification for creating clusters in the networks account

### SRE actions

Once the above developer actions have been completed and the request approved (either by Colin, Hannah, the developers manager or Ralph), and assuming that the correct roles have been requested, then access to the IBM Cloud account(s) will be automatically provided by the [compliance-argonauts-access-reconcile-iks](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-argonauts-access-reconcile-iks/) jenkins job.

The job runs periodically so it will take some hours before access is granted.

The following accounts are included in the role-based access config:

- `IKS Prod VPC Classic Networks (89064b69455a476583d12df4524b099b) <-> 1926435`
- `IKS.Prod.VPC.Network (68010fd8df4f467681ddec1e065d7a48) <-> 1984464`
- `IKS Prod VPC Classic Service (9751a0d772e5457eb52eb4c747f1c1b7) <-> 1926335`
- `IKS.Prod.VPC.Service (bab556e1c47446ef8da61e399343a3e7) <-> 1984462`
