---
layout: default
description: How to debug and resolve the "armada-kube-dashboard-proxy is close to hitting connection limits in one or more instances" pager
title: Runbook for pager "armada-kube-dashboard-proxy is close to hitting connection limits in one or more instances"
service: armada-kube-dashboard-proxy
runbook-name: "armadakube-dashboard-proxy approaching connection limit"
tags: alchemy, armada, down, alertmanager
link: /armada/armada-kube-dashboard-proxy-approaching-connection-limit.html
type: Troubleshooting
grand_parent: Armada Runbooks
parent: Armada
---

## Overview

This is caused when one or more instances of the `armada-kube-dashboard-proxy` microservice exceeds a threshold near it's connection limit.  At the time this runbook was written, the alert threshold was 450 connections and the hard limit was 512 connections.  If there is an imbalance (e.g. in load balancing), the goal is to more equaly distribute the number of open connections across pods.

## Example Alerts

This runbook should be used to address the following alert situtation(s):
- `kube_dashboard_proxy_instance_running_out_of_connections`

## Investigation and Action

### Check dashboard

Navigate to the Grafana instances for the production environment in question; the Grafana links are located on the [Hursley dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier).  From Grafana, navigate to the `armada-kube-dashboard-proxy dashboard` at `Home` -> `Kube Dashboard Proxy`.

Once you are on the `Kube Dashboard Proxy` dashboard, there are several things to verify:

(1) **There are at least 3 replicas running.**  See the `Running Instance` stat under the `Runtime Information` section to verify none of the pods are down.  If the doesn't display a value or the count is less than 3, verify the instance count on the relevant Carrier with `kubectl -n armada get pods -l app=armada-kube-dashboard-proxy`.
  - If the instance count is a least 3  and the pods appear normal, continue to step #2.
  - If the instance count is less than 3 and the pods appear normal, run `kubectl -n armada scale deploy/armada-kube-dashboard-proxy --replicas=3` to attempt to bring the replica count to 3.
  - If the pods are crashing (i.e. state is `Error` or `CrashLoopBackoff`) and there are no other outstanding issues with the carrier, escalate to the `armada-api` team in PagerDuty.

(2) **The connections are balanced between service instances.** Check the `Open API Server Connections` graph under the `Incoming Requests` panel.  If the number of connections is roughly the same across all microservice instances (+/-10%), [escalate](#escalation-policy).  If there is a large discrepancy in connection counts between different pods (e.g. one pod has far more connections), identify the pod with the most active connections and delete it (`kubectl -n armada delete pod armada-kube-dashboard-proxy-<HASH>`); this should help rebalance connections between the pods.  Wait several minutes, then assess whether the connections have equalized among the running pods.  If the connections equalize and are below the alert threshold, resolve the alert.  If not, [escalate](#escalation-policy).


## Escalation Policy

Escalate to the `armada-api` team in PagerDuty to further diagnose and resolve this incident.
