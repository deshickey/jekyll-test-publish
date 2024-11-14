---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to log in to a cluster worker node (Classic carrier and tugboat)
service: Conductors
title: How to log in to a cluster worker node (Classic carrier and tugboat)
runbook-name: How to log in to a cluster worker node (Classic carrier and tugboat)
link: /sre_howto_loginto_a_clusterworkernode.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
To gain access to a Classic carrier worker or a Tugboat worker node, multiple methods can be used:
- Bastion
- ssh using OpenVPN
- IPMI/KVM 

## Detailed Information
Detailed information about the access methods
### Using bastion 
##### (highly preferable for  production environment)
To gain access to the production hosts (either a carrier or tugboat worker) need to follow the steps described in [Bastion Access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_hosts_behind_bastion.html).

If bastion is not working due to globalprotect VPN, check the runbook for [bastion break the glassscenarios](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/platform_bastion_break_the_glass_scenarios.html).

Once the Bastion set up is enabled:
- follow the steps explained in Bastion Documentation and access Classic workers
- refer to the steps here on how to [Access Tugboats](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats).

### ssh using OpenVPN 
##### (not recommended for production environment)

Follow the steps to [Install OpenVPN](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/vpn.html)

Start the OpenVPN client on your localhost and connect to the specific production OpenVPN server where the intended worker node resides.

Once OpenVPN is enabled:
- run `ssh user-name@classic-worker-ip` to access the Classic worker
- refer to the steps here on how to [Access Tugboats](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats)

### IPMI/KVM method to gain console access to the host
Details of how to gain access to IPMI/KVM are described in [KVM Access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/kvm_access.html)

## References
How to access a cruiser/tugboat worker [steps](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-cruiser-worker-access.html)
