---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Links to common & essential SRE functions and runbooks, inventory of tools (and ownership)
service: sre
title: Links to common & essential SRE functions and runbooks, inventory of tools (and ownership)
runbook-name: SRE Table of contents.
link: /sre_contents.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

The table details the tools and processes which the Armada SRE team either user or are responsible for

## Aim of this page

- To provide links to information / runbooks to perform crucial parts of the SRE role
- To provide an inventory of tools we use and the ownership of the tools (BOTs, tools, etc)

## Detailed Information

### Onboarding to SRE

- Follow [this document](./sre_onboarding.html) if you are new to the SRE squad and need to onboard yourself

## Detailed procedure

### Compliance related responsibilities

For all compliance related runbook links, go to the [Compliance contents page](./compliance_contents.html)

### Inventory of SRE slack BOTs

| Name | Brief overview | Main Owner  | Useful links |
| ---- | -------------- | ------------| ------------ |
| dutyshift | Assist SRE when on interrupt duties | SRE - UK | - [GHE repo](https://github.ibm.com/sre-bots/dutyshift-bot)<br> - documentation required |
| fat-controller | Used in the trains process - for production deployments  | SRE and Netint | - [GHE repo](https://github.ibm.com/sre-bots/fat-controller) |
| igor | The conductors helper bot | SRE  - UK | - [GHE repo](https://github.ibm.com/sre-bots/igor)<br> -  [Igor usage docs](https://github.ibm.com/sre-bots/igor/blob/master/README.md) <br> DEPLOYMENT AND CONTRIBUTING LINKS MISSING |
| igorina | The SRE helper - only responds / works with SRE members | UK | - [GHE repo](https://github.ibm.com/sre-bots/igorina) |
| interrupt bot | A bot to find who is on call and provide that team with general admin support during their shift. | SRE - UK | - [GHE repo](https://github.ibm.com/sre-bots/interrupt) |
| netmax | Netint slack bot | Netint | - [GHE repo](https://github.ibm.com/sre-bots/netmax) |
| ooh bot | Out of hours bot -  used by teams to set OOH info on their slack channels | Netint | - [GHE repo](https://github.ibm.com/sre-bots/ooh) |
| shepherd | Used to assist setting up of new carriers | SRE - US | [GHE repo](https://github.ibm.com/sre-bots/shepherd) |
| tickbot | Used for interaction with Armada / IKS Customer tickets | SRE - US | - [GHE repo](https://github.ibm.com/sre-bots/tickbot) |
| victory | Bot for pulling carrier cluster information | US armada-deploy squad - Brandon Palm | - [GHE repo](https://github.ibm.com/sre-bots/victory) |
| xo | Executive Officer (xo) - helps query status of clusters running on our carriers | Armada dev | - [Only available from xo channel](https://ibm-argonauts.slack.com/messages/G53AJ95TP) <br>- [Code](https://github.ibm.com/alchemy-containers/armada-xo) |

### Other SRE tooling

| Name | Brief overview | Main Owner  | Useful links |
| ---- | -------------- | ------------| ------------ |
| Sensu uptime| Sensu uptime alerting | India SRE | LINKS ARE MISSING  |
| QRadar | QRadar | Paul / US Squad | LINKS ARE MISSING |
| OpenVPN | Allows ssh connections to Alchmey servers | Worldwide SRE | <b>** Deployment information**</b><br><br>- [Client side setup](./vpn.html) - documentation to help users configure their machines so they can establish VPN connections into our Softlayer accounts<br>- [openvpn 2FA auth server information](./vpn_multi_factor_auth_servers.html) - details about the 2FA authentication servers and how to raise tickets with SOS who own and administer them.<br>- [openVPN GHE](https://github.ibm.com/alchemy-conductors/openVPN) - GHE repo used to deploy openvpn configuration to openvpn servers.<br>- [How to osreload infra-vpn servers](./reloading_infra_vpn_server.html) - The process to follow if an `infra-vpn` server needs to be osreloaded.<br><br><b>** Debugging runbooks **</b><br><br>- [Troubleshooting](./vpn_troubleshooting.html) -  Troubleshooting vpn issues.<br>- [How to restart the openvpn process on the infra-vpn servers](./restart_openvpn.html) - troubleshooting when we have openvpn issues<br>- [How to restart Jenkins VPNs](./restart_openvpn_containers_swarm_jenkins.html) - How to restart the openvpn containers in Jenkins.|
| Jenkins | Responsible for the application layer | Worldwide SRE  | [SRE Jenkins responsibilities](sre_jenkins_responsibilities.html)  |
| SL CLI tool | Command line tool to query SL | Worldwide SRE | slcli tool can be installed using these [instructions](https://softlayer-api-python-client.readthedocs.io/en/latest/install/) |

### Processes SRE are responsible for

| Process | Brief overview | Main Owner  | Useful links |
| ------- | -------------- | ------------| ------------ |
| The `bootstrap` process | Process which hardens settings and configuration on the machines in Softlayer that SRE order on behalf of the development squads | UK and US Squads | - [Main documentation contents page](./bootstrap_contents.html) |
| cfs-inventory | Creates ansible inventory files used by the bootstrap process amoung other tools | UK SRE | MISSING DOCS |
| Softlayer machine ordering | How to order machines | US | - SRE bot shepherd helps with ordering whole new carriers.<br><br>- Runbooks assist with other machine orders such as adding new machines to an existing carrier, and are listed below with relevant links<br>1. [Runbook detailing generic machine ordering](./../runbooks/conductors_requesting_softlayer_machine.html)<br>2. [Ordering carrier nodes](./../runbooks/conductors_requesting_carrier_workers.html) - details how to order additional nodes for a carrier (known as workers)<br>3. [Maintaining the provisioning application](./sl_provisioning.html) - the provisioning app is our main way of ordering machines and this doc assists with resolving issues with it or contributing to it.<br>4. [Provisioning api - Troubleshooting and design documentation](./sl_provisioning_design.html) - contains details on how to build, deploy and  diagnose issues with the provisioning application |
| CIE process | Handling CIEs in the containers team | UK | The SRE squad are responsible for managing CIEs for IBM Containers Kubernetes Service, Event Streams, Cloud Functions, Registry and Vulnerability Advisor.  The following documents help with understanding and actioning CIEs. <br>- [How to raise a CIE](./sre_raising_cie.html) <br>- [SRE squad roles and responsibilities when managing a CIE](./sre_cie_responsibilities.html)<br>- [Closed loop mechanism](./clm-incidents.html) - how incidents are handled by IBM Containers Kubernetes SRE |
| EU SRE responsibilities | How to engage the EU SRE squad out of hours | EU squad | - [EU Cloud Access, escalation and process for IKS documentation ](./conductors_eu_cloud_iks.html)<br>- [EU Cloud Access, escalation and process for Satellite documentation ](./conductors_eu_cloud_sat.html)<br>-  [Igor interactive mode docs](https://github.ibm.com/sre-bots/igor/blob/master/README.md)|
| openvpn responsibilities | Looking after the openvpn servers | Worldwide - UK and US do have a lot of knowledge | NEED LINKS |
| Patching | Patching our machines | UK SRE Squad | - [Patching runbooks](./patching_contents.html) -  Link to documents related to the patching process, covering;<br>- How to patch a machine or set of machines<br>- How to validate a new smith apot-repository and roll patching out across all our regions.<br>- How to recover a smith apt-repo mirror  |
| Ordering certificates | How to order certificates for other squads | Any SRE Squad | See [procedure doc here](./using_certificate_manager.html) |
| Replacing workers | How to replace worker nodes on carrier or tugboat | Any SRE Squad | See [worker replace runbook](./ibmcloud_replace_worker.html) |

### Common tasks SREs are asked to perform

| Request | How to deal with it |
| ------- | ------------------- |
| How to handle Customer tickets | We receive pagerduty alerts for customer tickets that arrive, [for example](https://ibm.pagerduty.com/incidents/9294329) - The following docs help SRE action these alerts<br> - Instructions on [how to handle customer tickets](./../runbooks/conductors_support_tickets.html) <br> - Hints and tips when [investigating customer tickets](./../runbooks/conductors_support_tickets_hints_and_tips.html)|
| How to post a maintenance notification | We are sometimes asked to post a scheduled maintenance notification - for example [GHE 3879 from Registry](https://github.ibm.com/alchemy-conductors/team/issues/3879)<br>To request this, follow this [process](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W0b18f57537fa_4d83_be88_7e9aaffed4f8/page/Maintenance)|
| **Cancelling and deprovisioning machines** <br>How to cancel servers we look after <br>_**Aliases:** delete, remove_  | - [Deprovision a machine in Softlayer](./deprovision_machines.html)<br>_Generic information/process to follow when you are asked to cancel a server in Softlayer_<br>- [Remove a worker node from a carrier](./decomm_carrier_workers.html)<br>_Steps to follow if you are asked to cancel and remove a carrier worker node._ |
| Adding users to IBM Cloud and IBM Infrastructure accounts | - [Runbook detailing IBM Cloud account management](./ibmcloud_account_management.html)<br> - [Runbook on IBM Infrastructure user management](./sl_usrmgmt.html)|
| Fixing a read only filesystem on a Softlayer machine | Use the instructions in this [runbook](./recover_read_only_fs.html) |
| Give a user access to a space in AlchemyStaging and AlchemyProduction Bluemix organizations | Check user is part of Alchemy project (for example, check with their squad lead). [Adding and configuring a user to IBM Cloud](./../runbooks/ibmcloud_account_management.html) |
| How to change and update the `igoropenvpn` password | - [Changing the igoropenvpn users vpn password.](./sre_updating_igoropenvpn_password.html) |
| How to look up IBM Cloud account details | - [Runbook with hints and tips for finding account details](./sre_lookup_accounts.html) |
| Handling quota requests via customer tickets | - [SRE Docs to action quota increase customer tickets](./armada/armada-api-quota.html) <br> You can find an overview of this in the [release notes:](https://test.cloud.ibm.com/docs/containers?topic=containers-iks-release) and get further information on service limitations [here:](https://test.cloud.ibm.com/docs/containers?topic=containers-limitations) - Squad: Ironsides | 

### Other responsibilities/requests

| Request | How to deal with it |
| ------- | ------------------- |
| IBM Squads seeking help with IKS | Sometimes we get posts in `#conductors`, or GHE team tickets from IBM Squads who we are not the SRE team for.  In these instances, the raising squad should be be pointed at this [runbook](./armada/armada-internal-ibm-cruiser-problem-escalation.html) |
| Armada development squad asking for assistance with onboarding an internal cruiser cluster to SOS tooling | Development squads should be managing this themselves.  The following [runbook details the process](./development_onboard_sos_tools.html) and who in the SRE squad can further assist |

### Requesting help from other squads

| Request | Who to speak to |
| ------- | ------------------- |
| Change a firewall. For example: open a port between two machines or create a tunnel | Firewall changes are made by the Network Intelligence Squad. Request that they open an issue against [alchemy-netint/firewall-requests](https://github.ibm.com/alchemy-netint/firewall-requests/issues) using the process defined in [Firewall Configuration](./../runbooks/firewall_configuration.html). |
| Armada development help needed <br>_**Aliases:** call-out, page-out, escalate_| Consult [armada escalation policy document](./armada/armada_pagerduty_escalation_policies.html) |



