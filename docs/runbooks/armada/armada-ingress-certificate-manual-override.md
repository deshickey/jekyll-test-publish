---
layout: default
description: How to force certificate renewal for clusters that are unsupported.
title: Enabling certificate renewal through manual override for unsupported clusters
service: armada
runbook-name: "Enabling certificate renewal through manual override for unsupported clusters"
tags: alchemy, armada, certificate, ingress
link: /armada/armada-ingress-certificate-manual-override.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to enable the manual override so unsupported clusters that have recieved exceptions can renew the certificates managed by IKS.

## Detailed Information

First, approval must be given by Ralph Bateman (@Ralph (DE SRE)) to run this tool on an unsupported cluster.

Next, open a train in the follwing format:

```
Squad: <squad>
Title: Update manual override for unsupported cluster to enable Ingress rules triggers
Environment: <region>
Details: Use xo command to set ingress override field for cluster <id>
Risk: low
OutageDuration: 0
BackoutPlan: Mnaual override ttl timeout will reset value
PlannedStartTime: now
PlannedEndTime: now + 3h
Ops: true
CustomerImpact: no_impact
ServiceEnvironment: production
ValidationRecord: Operational change
DeploymentImpact: small
DeploymentMethod: automated
```

Gather the cluster ID and the train ID. Then navigate to either the conductors or secure xo channel. The command to set the manual override uses the following syntax:
`@xo ingress.override cluster=<clusterID> train=<trainID>`. Once ran the command will return `Successfully set the ingress rule manual override to <trainID>`, however if you wish to validate the field was set you can fetch the cluster fields using `@xo ingress.Cluster <clusterID> show=all` and check that the field `IngressManualOverride` and `IngressManualOverrideTTL` were set. The ttl is 3 hours and for that duration the cert renewal rules will be supported. At the end of the three hours the field will be wiped and Ingress rules will no longer trigger on that cluster.
