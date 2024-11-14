---
layout: default
description: How to resolve etcd high latency related alerts
title: etcd-traffic-over-threshold - How to resolve the peer to peer etcd high latency related alerts
service: etcd-traffic-over-threshold
runbook-name: "etcd-traffic-over-threshold - peer to peer high latency failures"
tags:  armada, etcd, armada-etcd, etcd-peer
link: /armada/etcd-traffic-over-threshold.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `ArmadaEtcdOperatorTrafficOverThreshold`| Peer to peer armada etcd operator traffic threshold over 0.1 for the last 10 minutes | [Armada Etcd Operator Traffic Over Threshold](#armada-etcd-operator-traffic-over-threshold) |
| `CarrierEtcdTrafficOverThreshold`| Peer to peer carrier etcd traffic threshold over 0.1 for the last 10 minutes | [Carrier Etcd Traffic Over Threshold](#carrier-etcd-traffic-over-threshold) |
| `ArmadaEtcdPeerRoundTripTimeWarning`| Peer to peer etcd traffic over 45ms threshold for one or more nodes | [Armada Etcd Peer Round Trip Time Warning](#armada-etcd-peer-round-trip-time-warning) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = armada-etcd/armada_etcd_traffic_over_threshold_critical
 - alert_situation = armada_etcd_traffic_over_threshold_critical
 - service = armada-etcd
 - severity = critical
Annotations:
 - namespace = armada
~~~~

## Actions to take

## Gathering Information

### Armada Etcd Operator Traffic Over Threshold


1. Lets go to prometheus and find the peer to peer armada etcd operator traffic threshold for the past 2 hours.
    * More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)
1. Run the following query:
    ~~~~
    sum(rate(etcd_network_peer_round_trip_time_seconds_sum{etcd_cluster =~"etcd-\\d+-armada-.*"}[5m])) by (To,instance) / sum(rate(etcd_network_peer_round_trip_time_seconds_count{etcd_cluster =~"etcd-\\d+-armada-.*"}[5m])) by (To,instance)
    ~~~~
    or click the prometheus link given in the alert.
   Then click on the graphs tab and check for the past 2 hours. Example [here](https://alchemy-dashboard.containers.cloud.ibm.com/dev-mex01/carrier5/prometheus/graph?g0.range_input=2h&g0.expr=sum(rate(etcd_network_peer_round_trip_time_seconds_sum%7Betcd_cluster%20%3D~%22etcd-%2F%2Fd%2B-armada-.*%22%7D%5B5m%5D))%20by%20(To%2Cinstance)%20%2F%20sum(rate(etcd_network_peer_round_trip_time_seconds_count%7Betcd_cluster%20%3D~%22etcd-%2F%2Fd%2B-armada-.*%22%7D%5B5m%5D))%20by%20(To%2Cinstance)&g0.tab=0)
1. Find all the nodes etcd is running on in the master and check it's cpu and memory usage by running `kubectl get pods -n armada -o wide -l app=etcd --no-headers | awk '{print $7}' |xargs -n1 kubectl top node`.
```
$ kubectl get pods -n armada -o wide -l app=etcd --no-headers | awk '{print $7}' |xargs -n1 kubectl top node
NAME           CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%
10.131.16.19   1535m        9%        12831Mi         23%
NAME            CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%
10.131.16.144   1622m        10%       12813Mi         23%
NAME            CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%
10.131.16.172   1298m        8%        12819Mi         23%
NAME           CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%
10.131.16.23   1447m        9%        12098Mi         22%
NAME            CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%
10.131.16.134   3302m        20%       13586Mi         25%
```

### Carrier Etcd Traffic Over Threshold

1. Lets go to prometheus and find the peer to peer carrier etcd traffic threshold for the past 2 hours.
    * More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)
1. Run the following query:
    ~~~~
    sum(rate(etcd_network_peer_round_trip_time_seconds_sum{job=~"carrier-etcd-server-metrics-.*"}[5m])) by (To,instance) / sum(rate(etcd_network_peer_round_trip_time_seconds_count{job=~"carrier-etcd-server-metrics-.*"}[5m])) by (To,instance)
    ~~~~
    or click the prometheus link given in the alert.
1. Then click on the graphs tab and check for the past 2 hours. Example [here](https://alchemy-dashboard.containers.cloud.ibm.com/dev-mex01/carrier5/prometheus/graph?g0.range_input=2h&g0.expr=sum(rate(etcd_network_peer_round_trip_time_seconds_sum%7Bjob%3D~%22carrier-etcd-server-metrics-.*%22%7D%5B5m%5D))%20by%20(To%2Cinstance)%20%2F%20sum(rate(etcd_network_peer_round_trip_time_seconds_count%7Bjob%3D~%22carrier-etcd-server-metrics-.*%22%7D%5B5m%5D))%20by%20(To%2Cinstance)&g0.tab=0)
1. Run the following query to check if cpu availability is low:
    ~~~~
    avg_over_time(armada_infra:node:cpu_available{hostname="<carrier-ip>"}[1h])
    ~~~~
    Replace carrier ip to the one given.
1. Run the following query to check for abnormal memory used:
    ~~~~
    avg_over_time(armada_infra:node:memory_used{hostname="<carrier-ip>"}[30m])
    ~~~~
    Replace carrier ip to the one given.
1. Continue on to find the information on the carrier
1. Find and login to the carrier master having issues.
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
1. Run the command `source /opt/bin/etcd-rc; /opt/bin/etcdctl check perf` on the carrier after logging in as root and make sure it passes.
```
$ sudo su
$ source /opt/bin/etcd-rc; /opt/bin/etcdctl check perf
60 / 60 Boooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo! 100.00%1m0s
PASS: Throughput is 150 writes/s
PASS: Slowest request took 0.191772s
PASS: Stddev is 0.009443s
PASS
```

1. Run the `top` command in the carrier and check the cpu and memory usage.
```
$ top
top - 19:43:51 up 42 days, 10:07,  2 users,  load average: 0.98, 1.35, 1.46
Tasks: 203 total,   1 running, 202 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.3 us,  1.9 sy,  0.0 ni, 91.0 id,  1.0 wa,  0.0 hi,  0.5 si,  0.4 st
KiB Mem : 32935264 total,  9444020 free,  5743148 used, 17748096 buff/cache
KiB Swap:        0 total,        0 free,        0 used. 26202056 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 455027 root      20   0 4764176 2.657g  80068 S  47.5  8.5   5941:16 hyperkube
1533409 root      20   0 2442016 1.713g 326832 S  25.9  5.5   1707:52 etcd
   1730 root      20   0 1035092  97396  39536 S   2.7  0.3   1469:14 dockerd
 456765 root      20   0 1305196 125064  75764 S   2.7  0.4 337:26.96 hyperkube
 461812 root      20   0   74240  50112  24080 S   2.7  0.2 204:50.34 calico-node
 455704 root      20   0 1466936 570824  73024 S   2.0  1.7 265:32.83 hyperkube
 454832 root      20   0    7500   4440   3628 S   1.0  0.0 103:32.72 docker-containe
      8 root      20   0       0      0      0 S   0.3  0.0  73:53.35 rcu_sched
   2099 root      20   0    9512    132     12 S   0.3  0.0 158:21.61 rngd
 448549 haproxy   20   0   32420   4012   2632 S   0.3  0.0  40:47.63 haproxy
 461645 root      20   0  875576  28068  23240 S   0.3  0.1   2:33.93 docker
 579184 root      20   0  598824  82912  18964 S   0.3  0.3   1165:36 BESClient
3418445 bruce.c+  20   0  131644   4448   3420 S   0.3  0.0   0:00.84 sshd
3419611 root      20   0   44616   3900   3184 R   0.3  0.0   0:03.15 top
3423582 root      20   0   46824   9036   5496 S   0.3  0.0   0:00.10 vim
      1 root      20   0  119940   6172   4100 S   0.0  0.0   0:33.40 systemd
      2 root      20   0       0      0      0 S   0.0  0.0   0:00.53 kthreadd
      4 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/0:0H
      6 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 mm_percpu_wq
      7 root      20   0       0      0      0 S   0.0  0.0   5:44.04 ksoftirqd/0
      9 root      20   0       0      0      0 S   0.0  0.0   0:00.00 rcu_bh
     10 root      rt   0       0      0      0 S   0.0  0.0   0:10.18 migration/0
     11 root      rt   0       0      0      0 S   0.0  0.0   0:11.47 watchdog/0
     12 root      20   0       0      0      0 S   0.0  0.0   0:00.00 cpuhp/0
     13 root      20   0       0      0      0 S   0.0  0.0   0:00.01 cpuhp/1
     14 root      rt   0       0      0      0 S   0.0  0.0   0:15.37 watchdog/1
     15 root      rt   0       0      0      0 S   0.0  0.0   0:10.33 migration/1
     16 root      20   0       0      0      0 S   0.0  0.0  10:36.16 ksoftirqd/1
     18 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/1:0H
     19 root      20   0       0      0      0 S   0.0  0.0   0:00.00 cpuhp/2
     20 root      rt   0       0      0      0 S   0.0  0.0   0:11.04 watchdog/2
     21 root      rt   0       0      0      0 S   0.0  0.0   0:10.23 migration/2
     22 root      20   0       0      0      0 S   0.0  0.0   6:09.74 ksoftirqd/2
     24 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/2:0H
     25 root      20   0       0      0      0 S   0.0  0.0   0:00.00 cpuhp/3
     26 root      rt   0       0      0      0 S   0.0  0.0   0:11.79 watchdog/3
     27 root      rt   0       0      0      0 S   0.0  0.0   0:10.29 migration/3
     28 root      20   0       0      0      0 S   0.0  0.0   8:22.96 ksoftirqd/3
     30 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/3:0H
     31 root      20   0       0      0      0 S   0.0  0.0   0:00.00 cpuhp/4
     32 root      rt   0       0      0      0 S   0.0  0.0   0:10.75 watchdog/4
     33 root      rt   0       0      0      0 S   0.0  0.0   0:10.24 migration/4
     34 root      20   0       0      0      0 S   0.0  0.0   5:36.44 ksoftirqd/4
     36 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/4:0H
     37 root      20   0       0      0      0 S   0.0  0.0   0:00.00 cpuhp/5
     38 root      rt   0       0      0      0 S   0.0  0.0   0:11.74 watchdog/5
     39 root      rt   0       0      0      0 S   0.0  0.0   0:10.15 migration/5
     40 root      20   0       0      0      0 S   0.0  0.0   8:56.45 ksoftirqd/5
     42 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/5:0H
     43 root      20   0       0      0      0 S   0.0  0.0   0:00.11 cpuhp/6
     44 root      rt   0       0      0      0 S   0.0  0.0   0:11.29 watchdog/6
     45 root      rt   0       0      0      0 S   0.0  0.0   0:10.24 migration/6
     46 root      20   0       0      0      0 S   0.0  0.0   5:08.33 ksoftirqd/6
     48 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/6:0H
     49 root      20   0       0      0      0 S   0.0  0.0   0:00.00 cpuhp/7
```

### Armada Etcd Peer Round Trip Time Warning

1. Lets go to prometheus and find the peer to peer carrier etcd traffic threshold for the past 2 hours.
    * More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)
1. Run the following query:
    ~~~~
    sum by (hostname)(etcd_network_peer_round_trip_time_seconds_sum{job="kubernetes-pods"}) / sum by (hostname)(etcd_network_peer_round_trip_time_seconds_count{job="kubernetes-pods"}) * 1000
    ~~~~
    or click the prometheus link given in the alert.
1. Look for Nodes with RTT of >45ms
1. Check the node health
1. Check overall health of armada etcd server with the Grafana dashboard `Carrier ETCD`
3. Restart the node to see if that helps

## Escalation Policy
For `ArmadaEtcdOperatorTrafficOverThreshold` alerts,
Open an issue against [site.data.teams.armada-ballast.name]({{ site.data.teams.armada-ballast.issue }}) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.

For `CarrierEtcdTrafficOverThreshold` alerts,
Open an issue against [site.data.teams.armada-carrier.name]({{ site.data.teams.armada-carrier.issue }}) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) escalation policy.
