---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: VPN Multi Factor Auth Servers Unreachable
service: Conductors
title: VPN Multi Factor Auth Servers Unreachable
runbook-name: "VPN Multi Factor Auth Servers Unreachable"
link: /vpn_multi_factor_auth_servers.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview

**WARNING:**  [2020/06/26] 2FA support is in the process of migrating to DUO (from Symantec VIP)
These PDs may start triggering whilst migration occurs, due alterations to active end points.

Please bear this in mind when dealing with these alerts!
_**There is work in progress to update the 2FA uptime checks.**_

Armada VPNs use multi-factor authentication [2FA] to meet with compliance requirements.  

2FA is implemented using Symantec VIP servers provided by SOS.  
If these servers are not reachable then VPN logins will fail in 2FA enabled environments, even if given valid credentials.  
This failure scenario will also include logins that are exempt from multi-factor authentication (automation).

## Example alert(s)
Sensu check fails and an alert similar to this will trigger

- `Symantec-VIP-Server-B-on-prod-dal09 DOWN: ICMP:1 execution expired`
- `Symantec-VIP-Server-A-on-prod-lon02 DOWN: ICMP:1 execution expired`

The following PD services are used for these alerts:
- [Alchemy - infra - prod-lon02](https://ibm.pagerduty.com/services/PC891PN)
- [Alchemy - infra - prod-dal09](https://ibm.pagerduty.com/services/PT7YZIM)




## Automation
none

## Actions to take

### If multiple environments are firing alerts

As each environment uses the same 2FA endpoints, we will likely see several alerts trigger if the 2FA endpoints are troubled.
Go to [Raise and SOS ticket](#raise-an-sos-ticket) section below if multiple sensu checks are firing for different regions as this will need SOS assistance to investigate and fix.

### If a single environment is affected

If only one region is firing, go to [check with netint](#check-with-netint) section as it is more likely there is an issue with the network tunnel to SOS.

### Raise an SOS ticket

See [ServiceNow for SOS Customer usage](https://w3-connections.ibm.com/wikis/home?lang=en#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/ServiceNow%20for%20SOS%20Customer%20usage)

1. Login to [Service Catalog](https://ibm.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D45ef56a7db7c4c10c717e9ec0b96193a%26sysparm_link_parent%3D109f0438c6112276003ae8ac13e7009d%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default%26sysparm_view%3Dcatalog_default)
    - Select **SOS Requests** followed by **Report Outage__

2.  Fill out the following fields

    - **Assignment Group** : `SOS 2FA`
    - **Severity** : `S1` if production is affected, otherwise `S2`
    - **C_CODE** : `ALC`
    - **Configuration Item** : `sos`
    - **Short Description** : ie `'Symantec VIP Server X.X.X.X is unreachable. This is impacting Armada VPN users.'`
    - **Description** : can be same as short description

3.  Click on the submit button (Blue button on bottom left)
4.  Ping [#sos-help](https://ibm-uk-labs.slack.com/archives/C5FLVNA9W) slack channel with the ticket number asking for immediate help looking into the issue.

### Check with netint

We have experienced problems with the tunnel between our envioronment and SOS.  
If SOS have ruled out problems with the symantic VIP endpoints, and/or, you suspect a tunnel issue (usual symptoms are 2FA login works else where) then reach out to the netint squad via the [#netint slack channel](https://ibm-argonauts.slack.com/archives/C53PUD2TE) and request a review of the SOS tunnel in the environment where the alert is triggering.


## Escalation Policy

   - The IKS SRE squad own and manage the `infra-vpn` servers 
   - The netint squad own the firewall rules and config which produces the tunnels between our environments and SOS endpoints
   - ping in #sos-help on slack if help is needed from the SOS team and no-one is responding to the ticket raised.


