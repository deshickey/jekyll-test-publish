---
layout: default
title: armada-xo - Looking up Portable Subnet information using armada-xo
type: Informational
runbook-name: "armada-xo - Looking up Portable Subnet information using armada-xo"
description: "armada-xo - Looking up Portable Subnet information using armada-xo"
service: armada
link: /armada/armada-xo-querying-a-portable-subnet.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

  * Armada-xo is a Slackbot which is available only in private channel #armada-xo within the Argonauts Slack team. If you need to access armada-xo and are not currently a member of the channel, then a Conductor should be able to invite you.

  * Armada-xo can be used to retrieve information about portable subnets that have been added to or created for a cluster.

To do this use the clusterPortableSubnets summary command, e.g.  
`@xo clusterPortableSubnets bnbd03o00gqdnvo46fkg`

```
Retrieving portable subnets for cluster bnbd03o00gqdnvo46fkg in region: us-south, environment: staging, carrier: carrier5
                            GUID |  Subnet ID |            Type |    VLAN ID |         Actual State |          Actual CIDR |   Order ID
c0b0251ae3c64ed08c55dc410cf98a68 |    1753437 |    public_vlans |    2257463 |                added |    169.61.220.120/29 |           
002715d0f7a746dcbe26798cd8b57ccf |    1714956 |   private_vlans |    2257439 |                added |     10.93.240.168/29 | 
```

To view more details on a portable subnet, use the information from the summary table to construct the portableSubnet command"  
`@xo portableSubnet clusterid/Type/VLANID/GUID`  
_For example:_  
_`@xo portableSubnet bnbd03o00gqdnvo46fkg/public_vlans/2257463/c0b0251ae3c64ed08c55dc410cf98a68`_

## Detailed Information

  If the `DesiredState` of the subnet is `added`, then this was an existing portable subnet which the user has manually added to their cluster using armada-api. These will never reach an `ActualState` of `deleted`, as armada-cluster will only delete portable subnets that it has created itself.

  If the `DesiredState` of the subnet is `created`, then armada-cluster has been asked to order the portable subnet for the cluster. The `ActualState` will indicate whether this is in progress (`creating`), succeeded (`created`), or failed (`create_failed`). In the latter case the `Status` and `ErrorMessage` will provide more details on the reason for the failure.

## Further reading

  * For issues with the VLAN IP config map, containing the subnet information, view https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-network-portable-subnet-config-misconfigured.html
  * For issues with subnets not being successfully added using the api, contact `armada-api`.
  * For issues where subnets have failed to create or delete, and the reason is not obvious, contact `armada-cluster`.
