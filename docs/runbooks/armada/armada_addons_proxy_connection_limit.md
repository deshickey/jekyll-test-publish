---
layout: default
description: How to troubleshoot connection limit issues in the armada-addons-proxy microservice.
title: Troubleshooting armada-addons-proxy connection limit issues
service: armada-addons-proxy
runbook-name: "armada-addons-proxy approaching connection limit"
tags: alchemy, armada, down, alertmanager, proxy, addons
link: /armada/armada-addons-proxy-connection-limit.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This is caused when one or more instances of the `armada-addons-proxy` microservice exceeds a threshold near it's connection limit.  At the time this runbook was written, the alert threshold was 450 connections and the hard limit was 512 connections.  If there is an imbalance (e.g. in load balancing), the goal is to more equaly distribute the number of open connections across pods.

## Example Alerts

This runbook should be used to address the following alert situtation(s):
- `addons_proxy_instance_running_out_of_connections`

## Investigation and Action

### Check dashboard

Navigate to the Grafana instances for the production environment in question; the Grafana links are located on the [Hursley dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier).  From Grafana, navigate to the `armada-addons-proxy dashboard` at `Home` -> `Armada Addons Proxy`.

Once you are on the `Armada Addons Proxy` dashboard, there are several things to verify:

(1) **There are at least 3 replicas running.**  See the `Running Instance` stat under the `Runtime Information` section to verify none of the pods are down.  If the doesn't display a value or the count is less than 3, verify the instance count on the relevant Carrier with `kubectl -n armada get pods -l app=armada-addons-proxy`.
  - If the instance count is a least 3  and the pods appear normal, continue to step #2.
  - If the instance count is less than 3 and the pods appear normal, run `kubectl -n armada scale deploy/armada-addons-proxy --replicas=3` to attempt to bring the replica count to 3.
  - If the pods are crashing (i.e. state is `Error` or `CrashLoopBackoff`) and there are no other outstanding issues with the carrier, follow the [escalation](#escalation-policy) section below.

(2) **The connections are balanced between service instances.** Check the `Open API Server Connections` graph under the `Incoming Requests` panel.  If the number of connections is roughly the same across all microservice instances (+/-10%), [escalate](#escalation-policy).  If there is a large discrepancy in connection counts between different pods (e.g. one pod has far more connections), identify the pod with the most active connections and delete it (`kubectl -n armada delete pod armada-addons-proxy-<HASH>`); this should help rebalance connections between the pods.  Wait several minutes, then assess whether the connections have equalized among the running pods.  If the connections equalize and are below the alert threshold, resolve the alert.  If not, [escalate](#escalation-policy).


## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
