---
layout: default
description: How to handle an issue provisioning a paid cluster.
title: armada-api - How to handle an issue provisioning a paid cluster.
service: Containers-Kube
runbook-name: "armada-api - How to handle an issue provisioning a paid cluster."
tags: alchemy, armada, provisioning
link: /armada-api-provision-paid-cluster-fails.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

Users may indicate that they are having issues provisioning a paid cluster.

## Example Alerts
## Investigation and Action

Advise users to run the following command `bx credentials-set`.  This issue may be caused by an authentication failure.  Refer to [runbook armada-api-authentication](./armada-api-login.html) for more information.  

If that does not resolve the issue verify with the user that they have upgraded to a paid account.

Also, VLAN configuration issues could manifest themselves in this way.  Refer to the [VLAN troubleshooting runbook](./armada-network-initial-troubleshooting.html) to determine if VLAN configuration is the underlying cause.

## Escalation Policy

It's likely that you'll need to include the armada-api squad when the actions taken do not resolve this issue.

Review the [escalation policy](./armada_pagerduty_escalation_policies.html) document for full details of which squad to escalate to.
