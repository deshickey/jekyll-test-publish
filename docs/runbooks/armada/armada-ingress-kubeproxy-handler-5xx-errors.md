---
layout: default
description: How to deal with 5xx errors returned by ingress for _kubeproxy_ handler.
title: armada - dealing with 5xx errors returned by ingress for _kubeproxy_ handler.
service: armada-kube-dashboard-proxy
runbook-name: "Dealing with 5xx errors returned by ingress for _kubeproxy_ handler"
tags: alchemy, armada, 5xx, ingress, kubeproxy, proxy, kube-dashboard
link: /armada/armada-ingress-kubeproxy-handler-5xx-errors.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with ingress reporting 5xx errors from the `_kubeproxy_` backend service, `armada-kube-dashboard-proxy`.

## Example Alerts

This runbook is intended for debugging and resolving the following alert situations:
- `kube_dashboard_proxy_internal_server_errors`

## Investigation and Action

### Accessing the Grafana dashboard

Navigate to the Grafana dashboard for the alerting region; the grafana dashboard links can be found on the [alchemy-dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/).  From the Grafana instance, navigate to the dashboard via `Home` -> `Kube Dashboard Proxy`.

### Dependencies

The `armada-kube-dashboard-proxy` microservice has multiple dependencies, any of which being down may cause the 5xx error rate to spike for the `_kubeproxy_` ingress handler.  Those dependencies include:
* IAM
* armada-api
* customer clusters (apiservers)

If there are outstanding issues/outages with any of the aforementioned dependencies, please wait until several minutes after those issues are resolved -- at which point, this alert should autoresolve.

If there are no know issues with those dependencies, manually verify the health of those dependencies:
#### IAM
Under the `Outgoing Requests` panel of the `Kube Dashboard Proxy` dashboard, observe the following graphs:
  * `IAM Timeouts (by call)` - If there is a large spike in timeouts during the time period in question, there is likely an IAM outage.
  * `IAM Requests (by status code)` - If the number of 5xx codes spikes for one of the listed calls, there is likely an IAM outage.

In either case, work with the IAM team to determine the cause of the problem.  If there is no IAM outage, continue on to the next section.

#### armada-api
Under the `Outgoing Request` panel of the `Kube Dashboard Proxy` dashboard, observe the following graphs:
* `Armada API Timeouts (by call)` - If there is a spike (>20) in timeouts during the time period in question, there is likely an armada-api outage.
* `Armada API Requests (by status code)` - If the number of 5xx codes spikes (>20) for one of the listed calls, there is likely an armada-api outage.

In either case, work with the armada-api team to determine the cause of the problem:
* investigate the `Ingress Stats` and `Armada API` dashboards for any obvious problems
* if the issue is with armada-api you can dig in deeper by performing the following search in LogDNA:
 `app:"armada-api" msg: "request complete" status_code:500`.
 This will show all the armada-api requests that generated an 500. Expand one of the logs and grab the value of
 `req-id`. Run a new query with just `req-id: "<REQUEST_ID>`, and
 you'll be able to follow the request along and see where the failure is originating.
* if necessary, work with the developer on-call to resolve the armada-api issue.
* see the `armada-api` PagerDuty team for any alerts,
Once the armada-api issue is resolved, wait several minutes to determine if the `_kubeproxy` 5xx error rates goes down and the alert autoresolves. If the alert doesn't autoresolve, [escalate](#escalation-policy).

If it is determined there is no issue with the armada-api service, continue on to the next section.

#### customer clusters (apiserver)

The armada-kube-dashboard-proxy microservice needs to communicate with the apiserver of the customer clusters.  Region or Carrier-wide networking outages (e.g. SoftLayer) can cause that communication to fail and 5xx errors to be returned.  Such a networking outage should manifest in similar problems and alerts in other armada microservices (including armada-api, armada-fluentd-cartographer, armada-ingress-microservice, armada-reaper, armada-health).  If no such outage, exists [escalate](#escalation-policy).

<!-- TODO: add steps for networking verification, e.g. curl 8.8.8.8, random customer master, ... -->

## Escalation Policy

Escalate to the [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}) team in PagerDuty.