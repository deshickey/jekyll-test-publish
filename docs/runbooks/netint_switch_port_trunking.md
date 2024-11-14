---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Switch Port Trunking Issues
service: Conductors
title: Switch Port Trunking Issues
runbook-name: "Switch Port Trunking Issues"
link: /netint_switch_port_trunking.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
- Sometime we experience switch port trunking issue during firewall deploys if its being slow, or they've broken. Also Softlayer will mess it up on their side. This runbook goes over checking if there's a firewall deploy running; and what softlayer ticket to raise if everything else is okay. If in doubt page Netint.

## Example alert(s)
[FIRING:1] PossibleSwitchPortTrunkingIssue prodwat-fra02-firewall-vyattaha2-02:9090 prodwat-fra02-firewall-vyattaha2 (prod-lon02 bond1.1212 normal)
This could be on any vyatta, in any environment.

## Automation

## Actions to take
- Check if there's a current firewall deploy for that environment at https://alchemy-containers-jenkins.swg-devops.com/job/Network-Intelligence/job/firewall-deploy/
- If there is a deployment in the same environment wait until it finishes, since the check may have just happened part way through removing/adding an interface resulting in a false posative.
- If there's no deployments happening, page netint out for the rest of the runbook.
- Check tunnels that the interface may be using, this could cause the loss of connectivity.
- Check if the VLAN has recently been unassociated or bypassed with the vyatta.
- If tunnels are fine, we'll raise a ticket with SL next
- Log into the relevant SL account for the vyatta, and create the following ticket:
- If there's been a chassis replacement recently this text has proven fruitful in the past to get them checking.

```
Hi

After all chassis replacement activities are complete, we want SoftLayer to verify the switch port trunking configuration for the switches attached to the pair of Vyattas in this gateway. We recently had an issue where a chassis replacement left the switch port trunking configuration in a bad state and it caused problems with failover at a later date. To avoid a reoccurrence of the issue, we would like to verify this before the ticket is closed.

Between the 4 ports attached to each Vyatta there will be two pairs of configuration, one for the ports attached to the bond0 Ethernet NICs and the other for the ports attached to the bond1 NICs. Typically these are grouped such that bond0 = eth0+eth2 and bond1 = eth1+eth3.

A "normal" healthy switch port trunking configuration should look similar to the following:

#show running-config interface Ethernet17
interface Ethernet17
   description 00531277-0875
   load-interval 5
   speed forced 10000full
   switchport trunk native vlan 875
   switchport trunk allowed vlan 829,843,875,885-886,1382,1530,1637,1720,1807

Our understanding is that, for each pair of switch ports for a bond, the "switchport trunk native vlan" should be the corresponding transit VLAN number of that bond and the "switchport trunk allowed vlan" should list all of the VLANs routed behind the Vyatta pair (the vifs attached to the bond).

In some cases we have found that chassis replacements or provisioning issues can result in a broken configuration like this:

#show running-config interface Ethernet17
interface Ethernet17
   description 00531277-0859
   load-interval 5
   speed forced 10000full
   switchport access vlan 859

where the switchport access vlan is the transit VLAN number, but there is no trunking configured and none of the routed VLANs are defined. This type of configuration causes problems for Vyattas.

Please note that the above VLAN numbers are only examples from a previous occurrence of the issue. Please check the portal configuration for the gateway in question to obtain the correct set of VLANs for this gateway.
```

- If there wasn't a chassis recently, come up with something similar too: (obv replace IPs/machines with relevent ones dummy)

```
Hi,
We've recently received alerts from this machine, where it cannot ping the 192 address on the other side of the VLAN 1185:


birch@stgwat-lon04-firewall-vyattaha1-02:~$ show interfaces
Codes: S - State, L - Link, u - Up, D - Down, A - Admin Down
Interface IP Address S/L Description
--------- ---------- --- -----------
bond0 10.45.71.101/26 u/u
bond0.1185 192.168.147.42/30 u/u Stgwat/Lon04/Cruiser1/B 1185 (bcr01a.lon04)
10.45.107.17/29
10.45.68.129/28
bond0v1 10.45.71.100/26 u/u
bond1 158.175.65.157/29 u/u
bond1.972 192.168.147.162/30 u/u Stgwat/Lon04/Cruiser1/F 972 (fcr01a.lon04)
158.175.79.49/29
158.175.92.65/28
bond1v1 158.175.65.156/29 u/u
eth0 - u/D
eth1 - u/D
eth2 - u/D
eth3 - u/D
eth4 - u/u
eth5 - u/u
eth6 - u/u
eth7 - u/u
lo 127.0.0.1/8 u/u
172.31.26.5/32
::1/128
tun965 172.17.26.38/30 u/u Tunnel to stage-dal09 for k8
birch@stgwat-lon04-firewall-vyattaha1-02:~$ ping 192.168.147.41
PING 192.168.147.41 (192.168.147.41) 56(84) bytes of data.
^C
--- 192.168.147.41 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2008ms

birch@stgwat-lon04-firewall-vyattaha1-02:~$

Could you please investigate the switch port trunking config; as something may have changed recently to trigger our alert and we now cannot ping the other side of the interface.

Thanks
```

- Goodluck chum

## Escalation Policy 
- Alchemy - Network Intel 24x7
