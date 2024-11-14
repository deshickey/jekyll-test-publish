---
layout: default
description: Details of Netint alerts and resolution
service: Network Intelligence
title: Network Intelligence AlertManger has triggered PD
runbook-name: Network Intelligence AlertManger has triggered PD
playbooks: ["NoPlaybooksSpecified"]
failure: ["NoFailuresSpecified"]
ownership-details:
  escalation: "Alchemy - Network Intel 24x7"
  owner-link: "https://ibm-cloudplatform.slack.com/messages/netint"
  corehours: "UK"
  owner-notification: False
  group-for-rtc-ticket: Runbook needs to be Updated with group-for-rtc-ticket
  owner: "Network Intelligence [#netint]"
  owner-approval: False
link: /netint_alertmanager_checks.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Node Exporter is run on each of the Vyattas and the values from each are picked up by a local Prometheus instance with rules defined to check the status of the Vyatta. If any of the rules are met an alert is triggered with Alertmanager whcih will notify in different places depending on the alert rules.

## Example Alert(s)

See below.

## Investigation and Action

See below.

## Escalation Policy

See below.

---

## Detailed Information

---

## Issue: "Instance _prod*-firewall-vyatta-*_ is down"

Vyatta is showing as down based on node exporter checks.

### Solution:

1. Ask netmax (either in [#netint](https://ibm-argonauts.slack.com/messages/C53PUD2TE) or via direct message) about the vyatta by pasting the hostname to get the public and private IP addresses.

2. Ping the public IP address, or if you have VPN access to the environment in question, the private IP address. If the vyatta does not respond to ping, restart it via the [SoftLayer control portal](http://control.softlayer.com).

3. If the vyatta does respond to ping, it is either a monitoring fault or a more serious problem. Page the netint squad.

### SNMP Instance down

There is another varient of instance down: `InstanceDown <*-firewall-vyattaha*>:9116 snmp`

This is used to monitor if Vyatta's hit any VRRP error states. It can be caused by several issues such as firewall rules, tunnels being down. This page should be going directly to Netint.

---

## Issue: "A tunnel is down on _vyatta pair_"

This check works by comparing the number of tunnel interfaces present on a vyatta with the number of tunnels reported active, so if this alert triggers that means we have one or more tunnel interfaces without a corresponding active tunnel.

### Solution:

1. Log in to the current vrrp `MASTER` of the vyatta pair in question. This can be determined by logging in to each member of the pair in turn and running `show vrrp` - you should see `MASTER` or `BACKUP` in the command output. 

If you are unsure which devices comprise the vyatta pair, paste the page title into a DM with netmax and he will output the correct devices.

2. Run `show interfaces tunnel` and `show interfaces vti` and add up the number of interfaces. Compare this to the number of peers listed in `show vpn ipsec sa` output. If they match, something has gone wrong with the alerting, snooze the page and raise a [firewall-requests issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues). Reassign to netint on call during UK office hours.

3. If they don't match, figure out which tunnel has gone wrong by comparing the list of peer addresses in the `show vpn ipsec sa` output versus the configured list (enter configure mode using `conf`, then start typing `show security vpn ipsec site-to-site peer` and double press tab to get a list of peer IPs).

4. Attempt to restart the tunnel (exit configure mode first if you entered it with `exit`) by running `reset vpn ipsec-peer <peer address>`.

5. Recheck the list of `up` tunnels under `show vpn ipsec sa`.

6. If it's still down, `restart vpn` will restart the vpn process and attempt to reestablish all tunnels.

7. If it's still down, `reset vrrp master interface dp0bond0 group ` then tab complete for the group number.

8. Log in to the other vyatta in the pair and recheck everything. If it's still down, the configuration is probably bad. Snooze the page and raise a [firewall-requests issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues). Reassign to netint on call during UK office hours.

---

## Issue "Instance _vyatta_ conntrack over 750000" or "Instance _vyatta_ conntrack over 75%"

This means that the conntrack table on the vyatta in the related environment is overly high.

### Solution:

1. Firstly, please bear in mind that if the conntrack table completely fills, it is very serious and could halt all new traffic in the target environment, effectively bringing down the entire service. For now, please proceed to step 2. In the mean time, if the issue auto resolves without any action on your behalf, please raise a ticket against our [firewall-requests repository](https://github.ibm.com/alchemy-netint/firewall-requests/issues), as this is a sign that our thresholds for this alert are not calibrated correctly.

2. If you are seeing or start to see other alerts relating to new connection failures in the target environment, page out the netint squad, and ask them to follow the quoted guidance below to reset the vyatta conntrack table. For now, please proceed to step 3.

    > Run `/usr/local/bin/vyatta-status-reporter/vyatta-status-reporter -t 10` and look at the top talkers output.

    > If the problem is related to a container IP, work with a conductor to get the container paused.

    > Delete stale conntrack table entries using `delete conntrack table ipv4 source x.x.x.x` to delete entries for connections made from IP address x.x.x.x.

---

## Issue "Instance _vyatta_ arp over 90%"

This means that the arp table on the vyatta is nearly at its evict limit.

### Solution:

The issue may auto resolve. If you find that the issue has auto resolved in less than 10 minutes, it is a sign that we have our thresholds too low, or arp table size too small. In this case please raise a ticket against our [firewall-requests repository](https://github.ibm.com/alchemy-netint/firewall-requests/issues). If the page does not auto resolve in under 10 minutes, please page out the netint squad.

---

## Issue "Instance _vyatta_ load average over 12"

This means that the cpu usage is unusually high on one of our machines.

### Solution:

The issue may auto resolve. If you find that the issue has auto resolved in less than 10 minutes, it may be a sign that we have our thresholds too low. The vyatta can handle load average of up to 24 or higher without a problem. In this case please raise a ticket against our [firewall-requests repository](https://github.ibm.com/alchemy-netint/firewall-requests/issues). If the page does not auto resolve in under 10 minutes, please page out the netint squad.

---

## Issue "Instance _vyatta_ is showing abnormal VRRP" or "Instance _vyatta_ is showing a VRRP fault"

This means that the VRRP status on the vyatta is showing something other than MASTER or BACKUP (the normal states).

### Solution:

The issue may auto resolve. If the page does not auto resolve in under 10 minutes, please page out the netint squad.

---

## Issue "No tunnel is routing to Bluemix gorouter _ip_ on _vyatta_"

This means that the tunnels between the Bluemix Vyattas and the Alchemy Vyattas are not routing packets to the gorouters correctly. A tunnel is down or the routing configuration for the tunnel is incorrect.

This issue is one possible cause of 502 errors from container routers on `*.mybluemix.net` and `*.bluemix.net`, BUT note that other problems may cause the same symptom.

### Solution:

The issue is unlikely to auto resolve and the netint squad will be paged out automatically.

Ensure that the tunnel is up and that the routing is working correctly. First, check that the output of the following commands show the tunnel in up (`u/u`) state:
```
show interfaces tunnel
show vpn ipsec sa
```

Second, check that the output from command `show ip route 10.xx.xx.xx` for the specified gorouter IP shows the IP being routed over one of the tunnels to Bluemix, for example:

```
$ show ip route 10.84.xx.xx
Routing entry for 10.84.xx.yy/26
  via "ospf", [110/20], selected
  Last update 00:00:44 ago
  FIB route, 172.aa.bb.cc, via tunXX
```

If the last line says `via bond0` instead of via `via tunXX` then this is a problem which must be fixed. To do so, run `reset ip ospf process` on the specified Vyatta named in the alert. The same command can also be run on the corresponding Bluemix Vyatta at the other end of the affected tunnel: either side can initiate a reset.

The OSPF reset command may itself cause some 502 errors for several seconds until the routing information has been resychronized between the Vyattas. Only run the command if the `show ip route` output indicates it is necessary.

---

## Issue "ExcessLoad Instance _haproxy_ load average over 12"

This means that the cpu usage is unusually high on one of our machines.

### Solution:

The issue may, and usually will auto resolve without any input. It usually isn't anything to be worried about unless you are also seeing service endpoints down, or other stability issues. You can restart the pair using Netmax which can sometimes resolve this issue as it causes a failover. For instance, to restart the `prod-fra02-carrier2-haproxy` pair, run the command `@netmax reboot prod-fra02-carrier2-haproxy` in the `#sre-cfs` slack channel. If this alert hasn't resolved itself within a few hours, or there are other issues showing, then page out Netint. 

---
