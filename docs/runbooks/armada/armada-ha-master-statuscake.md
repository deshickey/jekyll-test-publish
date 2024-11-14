---
layout: default
description: How to resolve ha master statuscake related alerts
title: armada-ha-master-statuecake - How to resolve ha master statuscake related alerts
service: armada-ha-master-statuecake
runbook-name: "armada-ha-master-statuecake - How to resolve ha master statuscake related alerts"
tags:  armada, statuscake, ha-master
link: /armada/armada-ha-master-statuecake.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This runbook contains steps to take when debugging HA (high availability) master statuscake related alerts.

## Example Alert(s)

~~~~
Website | Your site 'http://c0-2.stage-south.containers.test.cloud.ibm.com:20000' went down
~~~~

## Actions to take

1. View the uptime in statuscake. [Live status page](https://uptime.statuscake.com/?TestID=Lmp4JGKtKZ) password: `ibmcontainers`
1. If the uptime is reporting up, then the alert should resolve. If it is down or going up and down consistently continue on.
1. Verify that DNS is registered properly by doing an `nslookup`. Verify that is returns a valid loadbalancer VIP.
    * `nslookup c0-2.stage-south.containers.test.cloud.ibm.com`
    * use @netmax in slack to check it returns a valid loadbalancer VIP

    ~~~~
    kodie
    @netmax 169.47.223.77

    netmax APP [6:13 PM]
    @kodie:
    >*stage-dal10-carrier0-loadbalancer-vip* (_Portable_) - Acct531277
    >_Public:_ `169.47.223.77` _169.47.223.72/29_
    ~~~~
1. If above does not return a VIP or the VIP is invalid, gather info and escalate to netint `Alchemy - Network Intel 24x7`
1. If it is valid continue on
1. Run a healthcheck from local machine and verify it returns a 200 code. The url is in the alert.
    * For carriers: `curl -v http://c0-2.stage-south.containers.test.cloud.ibm.com:20000`
    * For tugboats: `curl -v http://c100-2.stage-south.containers.test.cloud.ibm.com:30000`
1. If healthcheck passes the alert should resolve.
   * If it does not resolve after 15 minutes, reboot the edge worker which hosts the `ibm-cloud-provider-ip-<IP>` pod with the MASTER role. See [armada-master-private-service-endpoint-slow](armada-master-private-service-endpoint-slow.html)
   * If it still does not resolve after another 15 minutes [escalate](#escalation-policy)
1. If healthcheck fails, check the health of the haproxy box with [haproxy_troubleshooting](../armada_haproxy_troubleshooting.html). 
   If it is a tugboat, check the health of the load balancer pods with [load balancer troubleshooting](../armada/armada-network-load-balancer-troubleshooting.html)

## Actions after verifying haproxy or load balancer is healthy
1. Now let's verify that the backend health check pods. Log onto the carrier the alert is coming from.
    * For example `c0-2.stage-south` indicates it is carrier0 in stage, so `stage-dal09-carrier0`
    * If unsure, search [armada-envs](https://github.ibm.com/alchemy-containers/armada-envs) for the URL
1. Verify health-check pods are up and running, there should be 3: `kubectl get pod -n kube-system -l run=health-check -o wide`
    ~~~~
    $ kubectl get deploy -n kube-system health-check
    NAME           READY   UP-TO-DATE   AVAILABLE   AGE
    health-check   3/3     3            3           2y146d

    $ kubectl get pod -n kube-system -l run=health-check -o wide
    NAME                            READY   STATUS    RESTARTS   AGE     IP              NODE             NOMINATED NODE   READINESS GATES
    health-check-54d8d87dd6-bqqsj   1/1     Running   0          18d     172.16.34.250   10.143.139.232   <none>           <none>
    health-check-54d8d87dd6-d4rkf   1/1     Running   0          6d23h   172.16.18.46    10.94.114.166    <none>           <none>
    health-check-54d8d87dd6-l78zr   1/1     Running   0          6d23h   172.16.191.19   10.185.25.240    <none>           <none>
    ~~~~
1. Verify health pod is returning healthy. From one of the carrier nodes run `curl -v http://<nodeIP>:20000` for carriers and `curl -v http://<nodeIP>:30000` for tugboats and verify it returns 200. The `nodeIP` can be the `10.x.x.x` IP for any worker node in the cluster.
1. If the health pod is not returning healthy 200 code [escalate](#escalation-policy)
1. If all steps passed above AND its a tugboat [escalate](#escalation-policy)
1. If the health pod is returning healthy, we need to next check the HAProxy machines to verify they are healthy. If unable to resolve after reviewing HAProxy runbook escalate to netint `Alchemy - Network Intel 24x7`
    * runbook to follow [haproxy_troubleshooting](../armada_haproxy_troubleshooting.html)

## Escalation Policy
Carrier/Tugboat Infrasture components are managed by the [armada-infra](https://ibm.pagerduty.com/services/P2LV6TL) team. Escalate alerts to that group.