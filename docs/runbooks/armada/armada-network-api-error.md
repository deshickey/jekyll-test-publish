---
layout: default
description: How to troubleshoot errors thrown by armada-network-api microservice.
title: armada-network-api - How to troubleshoot errors thrown by armada-network-api microservice.
service: armada
runbook-name: "armada-network-api - How to troubleshoot errors thrown by armada-network-api microservice"
tags: network, microservice
link: /armada/armada-network-api-error.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to troubleshoot errors thrown by the armada-network-api microservice. Alerts are triggered when specific errors are generated and aggregated across nodes. Too many errors generated over a minute will trigger the alert.

## Example alert

```
summary = "too many ETCD write errors have occurred over the last minute"
description = "5 ETCD write errors have occurred over the last minute. Dependency marked as etcd"
```

## Investigation and Action

Alerts in the armada-network-api microservice are composed of two important pieces of information- the error description and the dependency associated with the error.

## Where to Find Logs (Initial Troubleshooting)

Logs for the network microservice are published to Slack (similar to the way the armada-deploy squad posts their log messages):

- Pre-Production Successes [here](https://ibm-argonauts.slack.com/archives/C019HR3481M)
- Pre-Production Failures [here](https://ibm-argonauts.slack.com/archives/C01AB6H3SHX)
- Production Successes [here](https://ibm-argonauts.slack.com/archives/C01ANCQF26L)
- Production Failures [here](https://ibm-argonauts.slack.com/archives/C019RR8HPDL)

Visiting one of the above channels and searching for the Cluster ID will provide links to logs that can be vital in searching what happened to cause this failure.

## Where to Find Metrics Dashboards (Initial Troubleshooting)

For every region there is an Armada Observability HTTP Dashboard. Armada services related, like armada-network-api, metrics can be found on this Grafana dasboard.
Visiting this dashboard will provide useful info about armada-network-api related requests too.
e.g. for us-south: [Armada Observability HTTP](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier105/grafana/d/observability-http/armada-observability-http?orgId=1&var-datasource=prometheus&var-service=armada-network-api&var-path=All)

## Possible Common Error Scenarios

- ETCD store initialization fails
- ETCD read and write operation fails

### ETCD store initialization fails

This kind of error means that the backend ETCD server is not available or the credentials are wrong. Connection details are comming from armada secure as secrets. To detect the root cause of this type of error need to go through on the following list:

 * Check the logs of service to identify the reason of the error.
 * Make sure the network between service and ETCD is working properly.
 * Ensure that the given ETCD connection details are valid and up to date. You can use `env` command inside the service container to list all the variables.
 * Check ETCD server logs for connection and credential errors.

### ETCD read and write operation fails

Read and write operation errors can occure many times and they have several reasons like:

 * ETCD didn't responsed in time
 * ETCD server has some serious issue
 * Data is not available
 * Data is locked by one other process
 * Network error between the service and ETCD server

To identify the problem please follow the list below:

 * Check the logs of service to identify the reason of the error.
 * Make sure the network between service and ETCDis working properly.
 * Check ETCD server logs for any kind of error.

### Catch-All

For all other failures please reach out to the armada-network squad directly via Slack or create a new issue [here](https://github.ibm.com/alchemy-containers/armada-network/issues/new).  Network squad will add more scenarios to this runbook to help facilitate SRE debugging.

## Escalation Policy

Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
