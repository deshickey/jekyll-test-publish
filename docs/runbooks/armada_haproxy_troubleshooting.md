---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to debug Armada HA Proxy (LVS) front end api load balancer
service: NetInt
title: How to debug Armada HA Proxy (LVS) front end api load balancer
runbook-name: "NetInt: How to debug Armada HA Proxy (LVS) front end api load balancer"
link: /armada_haproxy_troubleshooting.html
type: Troubleshooting
tags: alchemy, kubernetes
failure: ["Instance XXXX downstream node count critical", "Instance XXXX is down"]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

The netint squad run a pair of machines in each Carrier environment that own virtual IPs to front the Carrier service. This way, Armada users only need to allow access to/from 1 IP address (the VIP) to reach the "control plane" rather than an entire Carrier subnet. These machines run on ENV_NAME-carrierN-haproxy-0N (e.g. prod-dal10-carrier3-haproxy-01). For more detail on the architecture, please refer to the wiki page here: https://github.ibm.com/alchemy-netint/team/wiki/LVS-(HA-Proxy)-Overview

## Example Alert(s)

I don't have any atm, but PR builder is failing

## Investigation and Action

Follow the steps outlined below

## Escalation Policy

Alchemy - Network Intel 24x7

## Automation

See links below where appropriate


## How do I know it's working at a high level?

1. [Status Cake](https://app.statuscake.com/Bigscreen/display.php?id=ceb93b4e-f541-4b7e-98fc-a6074cb3047c) - Setup by Kitch this monitors the endpoints from a global set of IPs and reports availability. Note this can report down due to Carrier being broken, it's not necessarily the load balancer being broken.
1. [Europe](https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon02/prod/network/prometheus/dashboard/db/carrier-load-balancer?refresh=1m&orgId=1) and [US-South](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal09/prod/network/prometheus/dashboard/db/carrier-load-balancer?refresh=1m&orgId=1) dashboards. In particular check that the number of downstream nodes has not dropped to zero and that there are connections and bandwidth being reported for the problem nodes.
1. Manually - See Below

## Manual health / status checks

### PD alert for `[FIRING:1] ArmadaHAProxyCriticalProcessDown ... conntrackd`

If the PD alert is for `[FIRING:1] ArmadaHAProxyCriticalProcessDown ... contrackd` for a particular haproxy node, then the service may need manual intervention to start up. This sometimes occurs after a reboot.

Check the status and attempt a restart:

```bash
systemctl status conntrackd
sudo systemctl restart conntrackd
```

If there is a stale lockfile left behind during the reboot, it may need to be manually removed:

```
[ERROR] lockfile `/var/lock/conntrack.lock' exists, perhaps conntrackd already running?
```

In that case, run the following:

```bash
sudo rm -f /var/lock/conntrack.lock
sudo systemctl start conntrackd
```

If removing the lockfile doesn't resolve the alert, then these steps may be needed:

```bash
sudo systemctl stop ipvsadm
sudo systemctl stop keepalived
sudo systemctl start ipvsadm
sudo systemctl start keepalived # must be done after ipvsadm start
```

### Find VIPs used by haproxy in this environment

Using netmax device lookup or the devices.csv, look for "ENV_NAME-carrierN-loadbalancer-vip" for the front VIP and "ENV_NAME-carrierN-loadbalancer-gateway-vip" for the gateway VIP (e.g. prod-syd01-carrier1-loadbalancer-vip)

### Determine which machine is "Master"

We run an HA Pair of loadbalancers (which is why we call it HA proxy), to find out which machine out of the pair currently owns the VIPs, run:

```
$ sudo ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
...
...
...
8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 0c:c4:7a:8f:10:c8 brd ff:ff:ff:ff:ff:ff
    inet 10.165.196.246/26 brd 10.165.196.255 scope global bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::ec4:7aff:fe8f:10c8/64 scope link
       valid_lft forever preferred_lft forever
9: bond1: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 0c:c4:7a:8f:10:c9 brd ff:ff:ff:ff:ff:ff
    inet 169.50.220.39/27 brd 169.50.220.63 scope global bond1
       valid_lft forever preferred_lft forever
    inet 159.122.242.78/32 scope global bond1
       valid_lft forever preferred_lft forever
    inet 159.122.242.77/32 scope global bond1
       valid_lft forever preferred_lft forever
    inet6 fe80::ec4:7aff:fe8f:10c9/64 scope link
       valid_lft forever preferred_lft forever

```

If the two VIPs (the front-end and gateway) show up under bond1 as above, then this machine is master. If only the subnet containing the host's bond1 IP address is listed under bond1, then this machine is backup. Only one machine of the pair should be routing both the IPs. Any other state will cause serious issues.

If both haproxy machines claim to own the VIPs, then use `ipvsadm` (described below) to determine which of the machines is actually routing traffic, and reboot the one that is **not** routing.

### What if I still can't determine which is Master (or neither are)

Keepalived reports its VRRP status into SNMP which is scraped by snmp_exporter running on the haproxy, to get the SNMP data run the following with either a VPN connection or on the haproxy itself.
```
curl 'http://<haproxy private ip>:9116/snmp?module=interfaces&target=127.0.0.1'
```
That will give output like this;
```
# HELP vrrpInstanceState Current state of this VRRP instance. - 1.3.6.1.4.1.9586.100.5.2.3.1.4
# TYPE vrrpInstanceState gauge
vrrpInstanceState{vrrpInstanceIndex="1",vrrpInstanceName="VI_1"} 2
vrrpInstanceState{vrrpInstanceIndex="2",vrrpInstanceName="VP_1"} 2
vrrpInstanceState{vrrpInstanceIndex="3",vrrpInstanceName="VP_GATEWAY"} 2
vrrpInstanceState{vrrpInstanceIndex="4",vrrpInstanceName="VI_GATEWAY"} 2
# HELP vrrpInstanceWantedState Desired state of this VRRP instance. - 2.3.6.1.4.1.9586.100.5.2.3.1.6
# TYPE vrrpInstanceWantedState gauge
vrrpInstanceWantedState{vrrpInstanceIndex="1",vrrpInstanceName="VI_1"} 2
vrrpInstanceWantedState{vrrpInstanceIndex="2",vrrpInstanceName="VP_1"} 2
vrrpInstanceWantedState{vrrpInstanceIndex="3",vrrpInstanceName="VP_GATEWAY"} 2
vrrpInstanceWantedState{vrrpInstanceIndex="4",vrrpInstanceName="VI_GATEWAY"} 2
```
The values for each interface have the following meanings; init(0), backup(1), master(2), fault(3), unknown(4)
vrrpInstanceState is the current state, vrrpInstanceWantedState is the state Keepalived is trying to get to, these should be nearly always the same.

It's possible for a VRRP clash to prevent either machines becoming master. In this case you'll see LOTS of errors (every second) in /var/log/syslog similar to:

```
Jan 11 20:50:45 stage-dal09-carrier0-haproxy-01.alchemy.ibm.com Keepalived_vrrp[31409]: ip address associated with VRID not present in received packet : 169.55.8.93
Jan 11 20:50:45 stage-dal09-carrier0-haproxy-01.alchemy.ibm.com Keepalived_vrrp[31409]: one or more VIP associated with VRID mismatch actual MASTER advert
Jan 11 20:50:45 stage-dal09-carrier0-haproxy-01.alchemy.ibm.com Keepalived_vrrp[31409]: bogus VRRP packet received on bond1 !!!
Jan 11 20:50:45 stage-dal09-carrier0-haproxy-01.alchemy.ibm.com Keepalived_vrrp[31409]: VRRP_Instance(VI_GATEWAY) ignoring received advertisment...
```

To diagnose where the clash is, run tcpdump on bond1 `sudo tcpdump -i bond1 -n` you should then see packets similar to:

```
20:51:01.122194 IP 169.55.35.123 > 224.0.0.18: VRRPv2, Advertisement, vrid 51, prio 150, authtype simple, intvl 1s, length 20
20:51:01.122270 IP 169.55.35.123 > 224.0.0.18: VRRPv2, Advertisement, vrid 52, prio 150, authtype simple, intvl 1s, length 20
```

Here you can see VRRP advertisements for vrid 51 and 52 (which are the two groups we use in the keepalived config you can see below)

Check the IP address which is sending the advertisment (169.55.35.123 in the example above) with netmax and make sure that all machines you see advertisments from are supposed to be part of the pair of ha proxy machines.

If not, this means we have a clashing vrid configured between multiple pairs that can see each other (are on the same vlan). Fix one of the sets of machines to have a new virtual_router_id on each pair and then restart keepalived, then re-check master state as per above, one machine should now own the VIPs


### Checking the Logs

LVS is composed of the kernel extension, the `Keepalived` daemon that takes care of doig the VRRP part and the Healthcheck part and `conntrack-sync` that keeps the `conntrac` between master and slave in sync.

The kernel extension doesn't provide logs, but `Keepalived` provides lots of logs regarding the Healthcheck part. Just grep the `/var/log/syslog` file for `Keepalived`:
```
chiquito@prod-dal10-carrier3-haproxy-01:~$ sudo grep Keepali /var/log/syslog
Aug 19 22:35:31 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Timeout connect, timeout server [169.48.180.230]:0.
Aug 19 22:35:31 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Removing service [169.48.180.230]:0 from VS [169.46.7.238]:0
Aug 19 22:35:32 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Timeout connect, timeout server [169.48.180.173]:20001.
Aug 19 22:35:32 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Removing service [169.48.180.173]:20001 from VS [169.46.7.238]:443
Aug 19 22:35:33 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Timeout connect, timeout server [169.48.180.221]:0.
Aug 19 22:35:33 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Removing service [169.48.180.221]:0 from VS [169.46.7.238]:0
Aug 19 22:35:35 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Timeout connect, timeout server [169.48.180.176]:20001.
Aug 19 22:35:35 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Removing service [169.48.180.176]:20001 from VS [169.46.7.238]:443
Aug 19 22:35:35 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Timeout connect, timeout server [169.48.180.155]:0.
Aug 19 22:35:35 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Removing service [169.48.180.155]:0 from VS [169.46.7.238]:0
Aug 19 22:35:36 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: HTTP status code success to [169.48.180.221]:0 url(1).
Aug 19 22:35:36 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Timeout connect, timeout server [169.48.180.163]:0.
Aug 19 22:35:36 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Removing service [169.48.180.163]:0 from VS [169.46.7.238]:0
Aug 19 22:35:38 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: HTTP status code success to [169.48.180.176]:20001 url(1).
Aug 19 22:35:38 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: HTTP status code success to [169.48.180.155]:0 url(1).
Aug 19 22:35:39 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: HTTP status code success to [169.48.180.163]:0 url(1).
Aug 19 22:35:40 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com Keepalived_healthcheckers[7564]: Timeout connect, timeout server [169.48.180.176]:0.
```
To check the conntrack logs, you can grep for `conntrack-tools` on the `/var/log/syslog` file:
```
chiquito@prod-dal10-carrier3-haproxy-01:~$ sudo grep conntrack-tools /var/log/syslog
/var/log/syslog.9:May  8 14:28:12 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com conntrack-tools[5964]: using user-space event filtering
/var/log/syslog.9:May  8 14:28:12 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com conntrack-tools[5964]: netlink event socket buffer size has been set to 262142 bytes
/var/log/syslog.9:May  8 14:28:12 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com conntrack-tools[5964]: initialization completed
/var/log/syslog.9:May  8 14:28:12 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com conntrack-tools[5964]: -- starting in console mode --
/var/log/syslog.9:May  8 14:29:14 prod-dal10-carrier3-haproxy-01.alchemy.ibm.com conntrack-tools[5964]: ---- shutdown received ----
```

### Enable IPVS packet tracing while debugging issues

It can often be helpful to review packet traces from the IPVS machines (haproxy-01 or haproxy-02, whichever is currently master) after a problem has been resolved.  If investigating a specific cluster that is having master connectivity issues (either kubectl commands timing out or worker nodes going to NotReady state), please temporarily turn on packet traces on whichever haproxy-XX machine is the master using the following instructions:

#### Enabling packet traces

1. SSH into the master haproxy-XX system, and know what the apiserver NodePort is for the cluster having the issue.  The apiserver NodePort can be found in the #armada-xo slack channel by querying for the master information using `@xo cluster <CLUSTER_ID>` and finding the: `ServerURL` line.  The nodeport is the 5 digit number at the end of the URL after the `:`

1. Run `sudo ipvsadm -Ln` to make sure you are on the active haproxy-XX system and that there are active connections.  If there are no active connections then there is no use in enabling packet traces

1. Run `df` and make sure the / mount has at least 200GB available (values are show in K, so look for at least 200,000,000 K available)

1. Run `export PORT=<apiserver NodePort>`  (so if the apiserver NodePort is 30390, run `export PORT=30390`)

1. Run the following commands to create a directory to store the traces in and to start the traces:

```
mkdir ipvsPort${PORT}Pcaps
cd ipvsPort${PORT}Pcaps
nohup sudo tcpdump -lnei bond1 port ${PORT} -C 200 -W 500 -w ipvsPort${PORT}.pcap &
sleep 5
ls -ltr
sleep 5
ls -ltr
```

The `ls -ltr` commands at the end is to see if the ipvsPort<PORT>.pcap file is growing in size.  If not, recheck the above steps to make sure everything was run correctly.  If the file isn't growing, then it could be that no traffic is getting to the haproxy-XX system that is master at all, but often it is because the wrong port was specified, or the master is the other haproxy-XX node.

#### Disabling packet traces and creating an issue for someone to look at the traces

1. Run `ps -ef | grep [t]cpdump` to find the process ID of the tcpdump process to kill (either the 'sudo tcpdump' or 'tcpdump' process will work)

1. Run `sudo kill <tcpdump_pid>` to end the packet tracing

1. Run `ps -ef | grep [t]cpdump` to verify that the tcpdump process(es) are no longer running

1. If the problem is resolved and the cause is well known (i.e. the problem didn't just resolve on its own, and it was not just resolved by failing over the haproxy-XX master to the other node or restarting one of the haproxy-XX machines), then just delete the packet trace files to ensure that the disk doesn't fill.

1. If it is unclear what was/is happening during the master connectivity problems and the packet traces should be analyzed, write an issue in https://github.ibm.com/alchemy-containers/armada-network/issues with the following information:
    - Exact times that the connection problems happened (include the timezone)
    - The cluster ID, carrier, and apiserver port (so we can find the traces)
    - The nature of the problem, including:
        - was this a total connectivity failures or only intermittent problems?
	    - exact error messages for connectivity problems
	    - were these kubectl calls that were failing?
	    - were worker nodes going to NotReady state?  If so, were all workers in NotReady state, or just some?
	    - how was (or was) the problem resolved?


### What worker node is servicing a specific connection?

If you troubleshooting a specific connection, you can use the command `ipvsadmi -Ln -c` to find out what is the mapping of specific connections:
```
sudo ipvsadm -Ln -c
IPVS connection entries
pro expire state       source             virtual            destination
TCP 00:07  CLOSE       169.48.169.137:50176 169.46.7.238:28372 169.48.180.191:28372
TCP 00:24  TIME_WAIT   169.48.141.52:35544 169.46.7.238:29129 169.48.180.235:29129
TCP 14:59  ESTABLISHED 169.60.24.86:52470 169.46.7.238:27234 169.48.180.244:27234
TCP 14:49  ESTABLISHED 169.48.238.164:45788 169.46.7.238:28205 169.48.180.215:28205
TCP 00:58  NONE        169.46.57.9:0      169.46.7.238:0     169.48.180.190:0
TCP 00:59  NONE        169.46.57.9:0      169.46.7.238:65535 169.48.180.229:65535
TCP 14:17  ESTABLISHED 169.61.228.50:43814 169.46.7.238:30446 169.48.180.180:30446
TCP 14:33  ESTABLISHED 169.48.137.125:16155 169.46.7.238:24702 169.48.180.239:24702
TCP 14:59  ESTABLISHED 169.60.1.57:41624  169.46.7.238:22133 169.48.180.155:22133
TCP 14:59  ESTABLISHED 169.60.224.27:5504 169.46.7.238:29711 169.48.180.223:29711
TCP 14:34  ESTABLISHED 169.48.170.211:40574 169.46.7.238:24564 169.48.180.212:24564
```


### Is iptables Configured Properly?

We use iptables to NAT traffic going to the carrier workers behind the gateway VIP to ensure traffic can return to the haproxy, and use RELATED policy to ensure that traffic is succesfully failed over if the haproxy machines themselves fail over. The output of running iptables should look as below.

Specifically when running to view the NAT rules, ensure that the front VIP (159.122.242.78 in example below) is NATing to the gateway VIP (159.122.242.77).

```
$ sudo iptables -t nat -L -n
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
SNAT       all  --  0.0.0.0/0            0.0.0.0/0            vaddr 159.122.242.78 to:159.122.242.77

```

```
$ sudo iptables -L -n
    Chain FORWARD (policy DROP)
    target     prot opt source               destination         
    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW
    ACCEPT     udp  --  0.0.0.0/0            0.0.0.0/0            state NEW
```

If the iptables are incorrect, they can be reloaded using the following commands, note change {{ VIP }} and {{ GATEWAY_VIP }} to the appropriate values below

```
$ vi /tmp/iptables-restore.conf

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o bond1 -m ipvs --vaddr {{ VIP }} -j SNAT --to-source {{ GATEWAY_VIP }}
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -i bond1 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i bond1 -p tcp -m state --state NEW -j ACCEPT
-A FORWARD -i bond1 -p udp -m state --state NEW -j ACCEPT
COMMIT

$ iptables-restore < /tmp/iptables-restore.conf
```

### Is keepalived running?

```
# ps -ef |grep keepalived
root     18872     1  0 May18 ?        00:00:34 /usr/sbin/keepalived
root     18873 18872  0 May18 ?        00:01:18 /usr/sbin/keepalived
root     18874 18872  0 May18 ?        00:01:25 /usr/sbin/keepalived
root     25456 25424  0 12:21 pts/1    00:00:00 grep --color=auto keepalived
```

If not running then run:

```
service keepalived start
```

Then check again.

### Check that keepalived is properly configured

Check the configuration against this annotated version in `/etc/keepalived/keepalived.conf`
If configuration is not correct then check against the [Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Network-Intelligence/job/Network-Intelligence/job/loadbalancer-config-build/) for the master configuration files. These are generated by the code in [lvs-load-balancer](https://github.ibm.com/alchemy-netint/lvs-load-balancer) project on GHE.

```
! Configuration File for keepalived

vrrp_sync_group G1 {
  group {
    VI_1
    VI_GATEWAY
  }
  notify_master "/etc/conntrackd/primary-backup.sh primary"
  notify_backup "/etc/conntrackd/primary-backup.sh backup"
  notify_fault "/etc/conntrackd/primary-backup.sh fault"
}

vrrp_instance VI_1 {
    state BACKUP
    nopreempt # should only be on node -01
    interface bond1
    virtual_router_id 51
    priority 150 # Should be 150 on -01 node, and 149 on -02 node
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 9a2a33e8 # needs to match between the 2 nodes
    }
    virtual_ipaddress {
        169.55.8.94
    }
}

vrrp_instance VI_GATEWAY {
    ** similar to VI_1 above but with different IP
}

virtual_server 169.55.8.94 0 { # Routes all TCP traffic on any port, IP needs to match virtual IP from VI_1 above
    lb_algo wlc
    lb_kind NAT
    persistence_timeout 360
    persistence_granularity 169.55.8.94 # needs to match virtual IP from VI_1 above
    protocol TCP
    real_server 169.55.35.104 0 { # These nodes are repeated 1 per downstream server
        weight 1
        TCP_CHECK {
            connect_timeout 3
            connect_port 20000
        }
    }
}
virtual_server 169.55.8.94 0 { # Routes all UDP traffic on any port, IP needs to match virtual IP from VI_1 above
    ** similar to virtual_server above **
    protocol UDP
}
virtual_server 169.55.8.94 443 { # Override route for port 443 being directed to port 20001 on the worker nodes
    lb_algo wlc
    lb_kind NAT
    persistence_timeout 360
    persistence_granularity 169.55.8.94
    protocol TCP
    real_server 169.55.35.104 20001 { # NB port 20001 here for redirect.
        ** health checks as above **
    }
}
```

### Check ipvs is running

```
# ps -ef |grep ipvs
root      4058     2  0 May11 ?        00:34:49 [ipvs-m:0:0]
```

If not running it will need to be restarted. **HOWEVER** starting or restarting it will wipe any configuration created by `keepalived`, so you **MUST** also restart `keepalived` afterwards:

```
service start ipvsadm
service restart keepalived
```

### Check that ipvs has the correct live configuration

```
# sudo ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  169.55.8.94:0 wlc persistent 360 mask 169.55.8.94
  -> 169.55.35.102:0              Masq    1      90         9         
  -> 169.55.35.103:0              Masq    1      121        951       
  -> 169.55.35.104:0              Masq    1      80         213       
  -> 169.55.35.107:0              Masq    1      327        33        
  -> 169.55.35.113:0              Masq    1      94         494       
  -> 169.55.35.117:0              Masq    1      146        216       
  -> 169.55.35.120:0              Masq    1      58         1081      
  -> 169.55.35.126:0              Masq    1      99         6         
TCP  169.55.8.94:443 wlc persistent 360 mask 169.55.8.94
  -> 169.55.35.102:20001          Masq    1      0          0         
  -> 169.55.35.103:20001          Masq    1      0          0         
  -> 169.55.35.104:20001          Masq    1      0          0         
  -> 169.55.35.107:20001          Masq    1      0          0         
  -> 169.55.35.113:20001          Masq    1      0          0         
  -> 169.55.35.117:20001          Masq    1      0          0         
  -> 169.55.35.120:20001          Masq    1      0          0         
  -> 169.55.35.126:20001          Masq    1      0          0         
UDP  169.55.8.94:0 wlc persistent 360 mask 169.55.8.94
  -> 169.55.35.102:0              Masq    1      0          3         
  -> 169.55.35.103:0              Masq    1      0          6         
  -> 169.55.35.104:0              Masq    1      0          2         
  -> 169.55.35.107:0              Masq    1      0          5         
  -> 169.55.35.113:0              Masq    1      0          9         
  -> 169.55.35.117:0              Masq    1      0          12        
  -> 169.55.35.120:0              Masq    1      0          9         
  -> 169.55.35.126:0              Masq    1      0          2
```

There should be 2 TCP lines, and 1 UDP line. TCP should be for :0 and :443.

If there is nothing listed, then `keepalived` probably needs to be restarted.

If there seems to be a few lines missing then check the configuration in the [Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Network-Intelligence/job/Network-Intelligence/job/loadbalancer-config-build/) with the IP rows displayed.

To ensure that traffic is being routed through this machine, run

```
$ sudo watch ipvsadm -Ln --stats
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  169.55.8.94:0                 159040K    2447M    2045M     285G     798G
  -> 169.55.35.102:0               3026615  159347K  152858K   19050M   63258M
  -> 169.55.35.103:0              46267058  355003K  229569K   36051M   91727M
  -> 169.55.35.104:0              11033290  209136K  177280K   19973M   47295M
  -> 169.55.35.107:0              11102223  657015K  622189K   90222M     231G
  -> 169.55.35.113:0              25868417  254313K  186778K   27174M   72960M
  -> 169.55.35.117:0               3612330  253143K  245526K   30208M     120G
  -> 169.55.35.120:0              56098811  334453K  210393K   38516M   95196M
  -> 169.55.35.126:0               2031698  225315K  220715K   24785M   76228M
TCP  169.55.8.94:443                  2839    18823    12953  2177194  6255190
  -> 169.55.35.102:20001                 0        0        0        0        0
  -> 169.55.35.103:20001                 0        0        0        0        0
  -> 169.55.35.104:20001                 0        0        0        0        0
  -> 169.55.35.107:20001                69      463      347    44705   149836
  -> 169.55.35.113:20001                12       95       71     7993    19360
  -> 169.55.35.117:20001              2739    18160    12460  2113764  6054341
  -> 169.55.35.120:20001                 0        0        0        0        0
  -> 169.55.35.126:20001                19      105       75    10732    31653
UDP  169.55.8.94:0                  199146 17412831 18059805   12175M    3560M
  -> 169.55.35.102:0                  1223  2109923  2310340    1586M  458994K
  -> 169.55.35.103:0                   147  3142251  3433014    2292M  663969K
  -> 169.55.35.104:0                   614  1834802  2003815    1264M  375722K
  -> 169.55.35.107:0                   302  3203663  3547371    2290M  719545K
  -> 169.55.35.113:0                 47646  2113790  2084553    1447M  411250K
  -> 169.55.35.117:0                 97519  1414287  1004738  713240K  195785K
  -> 169.55.35.120:0                 48251  2242834  2185457    1551M  438168K
  -> 169.55.35.126:0                    38       41        0    13144        0

```

Watching this you should see "Conns" and any of the "Out" columns increasing in value. If there doesn't appear to be any incrase, try creating your own connection to the front VIP (e.g. curl -k https://FRONT_VIP:443), if you do not see the connections going up on this machine then it is not routing traffic using the VIP.

### Check that ipvsadm is correctly configured

```
# cat /etc/default/ipvsadm
# ipvsadm

# if you want to start ipvsadm on boot set this to true
AUTO="true"

# daemon method (none|master|backup)
DAEMON="master"

# use interface (eth0,eth1...)
IFACE="bond1"

# syncid to use
SYNCID="1"
```

### Are downstream servers working?

You can check that all the expected downstream servers are healthchecking OK using the following command:

```
for IP in `grep real_server /etc/keepalived/keepalived.conf |grep -v 20001 | awk -F " " '{print $2}' | sort |uniq`; do nc -zv -w 3 $IP 20000; done
```

This will attempt to connect to port 20000 on all of the servers, if any are not responding then they will need investigating as to why they are offline.

Carrier worker nodes also require the correct routes to be configured on the host to be able to use the VIPs to route back to the haproxy machines.

SSH into one of the carrier worker machines and use the following command to ensure the routes are correctly configured:

```
stage-dal09-carrier0-worker-01:~$ route -N | grep -v 172.
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         169.55.35.97    0.0.0.0         UG    0      0        0 eth1
10.0.0.0        10.143.139.193  255.0.0.0       UG    0      0        0 eth0
10.143.139.192  0.0.0.0         255.255.255.192 U     0      0        0 eth0
161.26.0.0      10.143.139.193  255.255.0.0     UG    0      0        0 eth0
169.55.8.80     0.0.0.0         255.255.255.240 U     0      0        0 eth1
169.55.8.93     0.0.0.0         255.255.255.255 UH    0      0        0 eth1
169.55.8.94     0.0.0.0         255.255.255.255 UH    0      0        0 eth1
169.55.35.96    0.0.0.0         255.255.255.224 U     0      0        0 eth1
```

Specifically the routes for 169.55.8.93 and 169.55.8.94 (the gateway VIP and front VIP respectively) need to be there for this to work.

To test that traffic is actually flowing through the VIP on the haproxy machine and getting to the workers, run the following tcpdump on the carrierN-haproxy machine that currently owns the front VIP, whilst running a curl from a separate client (`curl -k https://169.55.8.94:443`)

```
$ sudo tcpdump -i bond1 -n port 443
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on bond1, link-type EN10MB (Ethernet), capture size 262144 bytes
14:14:55.098873 IP 195.212.29.72.50908 > 169.55.8.94.443: Flags [S], seq 1670214232, win 65535, options [mss 1380,nop,wscale 5,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,sackOK,eol], length 0
14:14:55.100344 IP 169.55.8.94.443 > 195.212.29.72.50908: Flags [S.], seq 1063823180, ack 1670214233, win 28800, options [mss 1440,nop,nop,sackOK,nop,wscale 7], length 0
14:14:55.253469 IP 195.212.29.72.50908 > 169.55.8.94.443: Flags [.], ack 1, win 8192, length 0
14:14:55.261777 IP 195.212.29.72.50908 > 169.55.8.94.443: Flags [P.], seq 1:176, ack 1, win 8192, length 175
14:14:55.262510 IP 169.55.8.94.443 > 195.212.29.72.50908: Flags [.], ack 176, win 234, length 0
14:14:55.264994 IP 169.55.8.94.443 > 195.212.29.72.50908: Flags [P.], seq 1:2993, ack 176, win 234, length 2992
14:14:55.536586 IP 195.212.29.72.50908 > 169.55.8.94.443: Flags [.], ack 2993, win 8098, length 0
14:14:55.536599 IP 195.212.29.72.50908 > 169.55.8.94.443: Flags [.], ack 2761, win 8105, length 0
14:14:55.543414 IP 195.212.29.72.50908 > 169.55.8.94.443: Flags [.], ack 2993, win 8191, length 0
```

This should show both the requests arriving to the VIP on port 443 and the responses back to the client machine from the VIP.

If traffic is arriving but not getting responses, then run the same curl as before with the following tcpdump on the carrier-haproxy:

```
$ sudo tcpdump -i bond1 -n port 20001
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on bond1, link-type EN10MB (Ethernet), capture size 262144 bytes
14:18:53.624673 IP 169.55.8.93.15884 > 169.55.35.126.20001: Flags [S], seq 4233898811, win 65535, options [mss 1380,nop,wscale 5,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,sackOK,eol], length 0
14:18:53.626061 IP 169.55.35.126.20001 > 169.55.8.93.15884: Flags [S.], seq 1839909369, ack 4233898812, win 28800, options [mss 1440,nop,nop,sackOK,nop,wscale 7], length 0
14:18:53.810413 IP 169.55.8.93.15884 > 169.55.35.126.20001: Flags [.], ack 1, win 8192, length 0
14:18:53.815645 IP 169.55.8.93.15884 > 169.55.35.126.20001: Flags [P.], seq 1:176, ack 1, win 8192, length 175
14:18:53.816161 IP 169.55.35.126.20001 > 169.55.8.93.15884: Flags [.], ack 176, win 234, length 0
14:18:53.818837 IP 169.55.35.126.20001 > 169.55.8.93.15884: Flags [P.], seq 1:2993, ack 176, win 234, length 2992
14:18:54.004852 IP 169.55.8.93.15884 > 169.55.35.126.20001: Flags [.], ack 2761, win 8148, length 0
14:18:54.004859 IP 169.55.8.93.15884 > 169.55.35.126.20001: Flags [.], ack 2993, win 8141, length 0
```


LVS maps requests on port 443 to port 20001 on the workers, so this should show that transformating taking place, if no data is returned then this LVS configuration is not working. If traffic is getting through, then you will be able to see it forwarded to the worker (169.55.35.126 in the example above).

Log onto the worker and run the following tcpdump:

```
$ sudo tcpdump -i eth1 -n port 20001
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
14:54:36.620144 IP 169.55.8.93.28407 > 169.55.35.126.20001: Flags [SEW], seq 1953730300, win 65535, options [mss 1380,nop,wscale 5,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,sackOK,eol], length 0
14:54:36.620954 IP 169.55.35.126.20001 > 169.55.8.93.28407: Flags [S.E], seq 4134326155, ack 1953730301, win 28800, options [mss 1440,nop,nop,sackOK,nop,wscale 7], length 0
14:54:36.744611 IP 169.55.8.93.28407 > 169.55.35.126.20001: Flags [.], ack 1, win 8192, length 0
14:54:36.749928 IP 169.55.8.93.28407 > 169.55.35.126.20001: Flags [P.], seq 1:176, ack 1, win 8192, length 175
14:54:36.750381 IP 169.55.35.126.20001 > 169.55.8.93.28407: Flags [.], ack 176, win 234, length 0
14:54:36.754250 IP 169.55.35.126.20001 > 169.55.8.93.28407: Flags [P.], seq 1:2993, ack 176, win 234, length 2992

```

Here you should see whether the traffic is arriving to the worker and where it is from. If the 'from' IP is not gateway VIP this would imply that the NAT rules in iptables are not being applied correctly.

If no responses are being shown then this would imply the routes are not correctly configured or there is a problem with the service running on the worker itself. To verify whether the service is running locally, try running `curl localhost:20001` as this should respond (with a Bad Request error).

If no traffic is arriving at the worker, verify that the worker is still the one traffic is being forwarded to by referring back to the tcpdump on port 20001 on the haproxy. If that is still sending data to this IP then there is a SoftLayer networking issue preventing the traffic from reaching the worker, and a ticket should be raised.  

### Check that conntrack-sync is working

First check the logs, as explained on the section about checking the logs.

If this is a singleton haproxy it is possible that the `conntrackd.conf` file is incorrect. Open the file and search for the following
```
IPv4_Destination_Address unknown
```
If you find this line comment it out by inserting a `#` at the start of the line, save and restart conntrack with
```
service conntrackd restart
```

```
$ ps -ef |grep conn
root      2230     1  0 Jun04 ?        00:14:29 /usr/sbin/conntrackd -d -C /etc/conntrackd/conntrackd.conf
```

If not running, start with:

```
service conntrackd start
```

Check the status of conntrackd by running on each node. For the current master node the connections should show up in the "cache internal" section. The backup node should have connections listed in the "external inject" section.

```
stage-dal09-carrier0-haproxy-01:~$ sudo conntrackd -s
cache internal:
current active connections:             3839
connections created:                10317395    failed:            0
connections updated:                12159227    failed:            0
connections destroyed:              10313556    failed:            0

external inject:
connections created:                       0    failed:            0
connections updated:                       0    failed:            0
connections destroyed:                     4    failed:            0

traffic processed:
                   0 Bytes                         0 Pckts

UDP traffic (active device=bond0):
          2409652888 Bytes sent              3863952 Bytes recv
            23534376 Pckts sent               241321 Pckts recv
                   0 Error send                    0 Error recv

message tracking:
                   0 Malformed msgs                    0 Lost msgs
```

```
stage-dal09-carrier0-haproxy-02:~$ sudo conntrackd -s
cache internal:
current active connections:             2904
connections created:                    2938    failed:            0
connections updated:                       0    failed:            0
connections destroyed:                    34    failed:            0

external inject:
connections created:                 5762524    failed:            0
connections updated:                 6124977    failed:            0
connections destroyed:               5754372    failed:            0

traffic processed:
                   0 Bytes                         0 Pckts

UDP traffic (active device=bond0):
             2168448 Bytes sent           1341666352 Bytes recv
              135355 Pckts sent             13071476 Pckts recv
                   0 Error send                    0 Error recv

message tracking:
                   0 Malformed msgs                    0 Lost msgs
```

If this is not working, check `/etc/conntrackd/conntrackd.conf`. Important configuration sections are below. This is generated from [conntrackd.j2](https://github.ibm.com/alchemy-netint/deploy/blob/master/loadbalancer/conntrackd.j2) in Git.

```
Sync {
  UDP {
    # This should be the primary private IP of the box this config is on
    IPv4_address 10.176.215.23

    # This should be the primary private IP of the other box in the pair
    IPv4_Destination_Address 10.176.215.10
    Port 3780
    Interface bond0
  }
}

General {
  Filter From Userspace {
    Address Ignore { # Ignore local primary IPs on this box, we DON'T want to sync those.
      IPv4_address 127.0.0.1 # loopback
      IPv4_address 10.176.215.23
      IPv4_address 169.48.138.96
    }
  }
}
```
