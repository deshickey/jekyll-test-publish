---
layout: default
description: How to handle when Prometheus appears to be scraping few samples
title: armada-ops - How to handle when Prometheus stops scraping data
service: armada
runbook-name: "armada-ops - How to handle when Prometheus stops scraping"
tags: alchemy, armada, prometheus, scrape, scraping
link: /armada/armada-ops-prometheus-low-samples-scrape.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook is used to troubleshoot Prometheus when the amount of scraping of metrics falls below
the threshold of 10 scrape records over a two minute period.

## Example alerts which would have brought you here

- `bluemix.containers-kubernetes.10.176.31.236_prometheus_scraping_low`

## Investigation and Action

This alert is triggered when Prometheus completes less than 10 scrapes in a two minute period.

#### Checklist:

- Go to [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and access `Grafana` > `Grafana Carrier` for the environment

- Open the `Kubernetes Pod Resources` Dashboard and examine the Memory Working Set. If there are scraping
issues, you should see gaps in the charts (such as where the lines on the graph appear to have breaks).
  - If you do not see this, escalate to [{{ site.data.teams.armada-ops.escalate.name }}]({{ site.data.teams.armada-ops.escalate.link }}) .

##### Action to take

* Logon to the carrier master for that environment.
* Run `kubectl get pods -n monitoring` - this will list all the pods running on this environment, make a note of prometheus pod name

```
NAME                                  READY     STATUS    RESTARTS   AGE
alertmanager-2162462176-kcx4r         1/1       Running   0          1h
blackbox-exporter-60644949-47vbl      1/1       Running   0          1h
grafana-3904738335-h83nw              1/1       Running   0          1h
kube-state-metrics-3494959828-c9hjt   1/1       Running   0          1h
node-exporter-5jhvr                   1/1       Running   1          13d
node-exporter-61r64                   1/1       Running   1          20d
prometheus-1500618247-3hlh2           1/1       Running   0          1h`

```

If the prometheus is reporting `Not Ready`, then follow these steps:

1. `kubectl describe pod <prometheus-pod-name> -n monitoring` - this will describe the health of the pod and the latest messages associated with it
1. `kubectl logs <prometheus-pod-name> -n monitoring > file.log 2>&1` - collect the logs for the pod, this may be needed later for further debug
1. `kubectl delete pods <prometheus-pod-name> -n monitoring` - this deletes the pod (which will be in not ready state) and the pod is recreated automatically.

Finish by running `kubectl get pods -n monitoring` to ensure the pod has recovered successfully. If problems persist, call out the #armada-ops team.

## Escalation policy

Per the [escalation policy](./armada_pagerduty_escalation_policies.html) document, please escalate alerts to the [{{ site.data.teams.armada-ops.escalate.name }}]({{ site.data.teams.armada-ops.escalate.link }})

Also, please use the [Armada-Ops Slack Channel](https://ibm-argonauts.slack.com/messages/C534XTE49) for discussion on these alerts.
