---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to setup a new infra-vpn machine.
service: Infra
title: Setup a new infra-vpn machine
runbook-name: "How to order and deploy an infra-vpn machine"
link: /order_a_new_infra_vpn_server.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Table of contents
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

---

## Overview

How to order, bootstrap and deploy an newly created `infra-vpn` machine.

The **normal** procedure to follow involves :
1. Order new machine in IaaS (Colin Thorne or Ralph Bateman approvel required)
1. Verifying that the Bootstrap process has completed
1. Register the new node in DUO server

**NB. this document is incomplete and under process...**


## Detailed Information

As noted above, these instructions are to order a new `infra-vpn` machine.

## Detailed procedure
1. Order new machine in IaaS Virtual Server for Classic e.g [prod-dal09-infra-vpn-12](https://cloud.ibm.com/gen1/infrastructure/bare-metal/1867063/details#main)
      - Hostname will be incremented to next available suffix e.g (prod-dal09-infra-vpn-**) 
      - Domain name 'alchemy.ibm.com' in the desired regions and add a SSH key.

1. Verifying that the Bootstrap process has completed
1. Register the new node in DUO server and then add details to 1337 [alchemy-1337/duo-credentials](https://github.ibm.com/alchemy-1337/duo-credentials) eg. [PR](https://github.ibm.com/alchemy-1337/duo-credentials/pull/6)
1. Create Netint ticket(s)
   - Set up openconnect and openvpn subnets eg [netint ticket PR] (https://github.ibm.com/alchemy-netint/firewall-requests/issues/4224)
   - create netint firewall ticket to Update the static routes on the firewalls with these new server(s) do when all servers are ordered [alchemy-netint/firewall-requests](https://github.ibm.com/alchemy-netint/firewall-requests/issues/4228)
   - **Until above netint tickets are complete, no further actions can be taken**
1. update bootstrap-one to allow inter vpn routing make PR [playbooks/group_vars/{regions}.yml](https://github.ibm.com/alchemy-conductors/bootstrap-one/pull/732)
1. As the bootstrap adding VPN subpools for the new VPN server will take a while to roll out to production, you should log into the new server and existing server and manually run these commands.
   Get the `vpn_address_range` and `server_ip` from the above bootstrap PR.\
   (e.g.)`sudo ip route add vpn_address_range via server_ip`\
   openvpn subnet pools\
   VPN 03  `sudo ip route add 10.142.23.192/26 via 10.143.143.6`\
   VPN 04  `sudo ip route add 10.142.206.64/26 via 10.143.143.29`\
   openconnect subnet pools\
   VPN 03 `sudo ip route add 10.142.132.128/26 via 10.143.143.6`\
   VPN 04 `sudo ip route add 10.142.88.0/26 via 10.143.143.29`\
1. update openVPN code to reference the new subnets created by netint (only openvpn ones)\
 GHE link to update file https://github.ibm.com/alchemy-conductors/openVPN/blob/master/roles/ansible-openvpn-server/vars/main.yml\
(e.g.) [PR](https://github.ibm.com/alchemy-conductors/openVPN/pull/60/files)

   **Once all config is successfully placed.**
1. Run the deployment jenkins job of [deploy-infra-vpn-server](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/job/deploy-infra-vpn-server/)
1. Test manually as login to machines and verified as working
1. Ask netint `@ask-netint` to add these new server to cloudflare for this VPN pool.\
   Raised #netint ticket to add the servers in the cloudflare VPN pool. (e.g.) [Cloudflare DNS update](https://github.ibm.com/alchemy-netint/firewall-requests/issues/4269)
 
1. Update the openconnect-client IP in run.sh file , [repo](https://github.ibm.com/alchemy-conductors/openconnect-client/blob/master/run.sh), (e.g.) [PR](https://github.ibm.com/alchemy-conductors/openconnect-client/pull/17/files)

1. Add the new nodes details in Sensu-uptime (e.g.) [PR](https://github.ibm.com/alchemy-conductors/sensu-uptime/pull/1176/files) and [PR](https://github.ibm.com/alchemy-conductors/sensu-uptime/pull/1177/files).
