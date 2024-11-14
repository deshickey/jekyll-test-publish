---
layout: default
description: Armada-Fluentd general troubleshooting
title: armada-fluentd troubleshooting
service: armada
runbook-name: "armada-fluentd troubleshooting"
tags: armada, fluentd, logging, wanda
link: /armada/armada-fluentd.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Armada-Fluentd General Trouble shooting

## Overview 
This document contains "must gather" information and debugging steps for issues viewing logs.

When a customer cannot see logs for their cluster, some of the more simple, common issues we see are: the cluster is not a paid cluster, the user is looking at the wrong logging endpoint, the user is looking at the wrong account/org/space for their logs, the user is out of logging quota. The following is a list of debug steps to rule out any of these issues.

## Example alert
N/A

## Must-Gather information for logs not being shown for cluster
1. cluster ID (in text, not a screenshot if possible)
2. The following cluster details:
    -  Is the cluster paid? Logging and metrics are only supported on paid clusters
    -  The cluster's `ActualState` must be `deployed` and the `HealthState` must be `normal`.
3. The logging UI endpoint for where they are failing to find their logs. i.e. https://logging.ng.bluemix.net
4. The account or org and space IDs that the customer has targeted in the top right corner of Kibana at the above logging endpoint for where they are trying to view their logs
5. The type of logs the customer is having trouble viewing. i.e. container logs, ingress logs, etc. For a list of log source types, view the logging config documentation. https://console.bluemix.net/docs/containers/cs_health.html#health
6. Have the customer check their logging quota. They should log in to Kibana and target the correct space or account in the top right corner. Then have them click on the admin tab where they can get the total daily quota and the amount used.
    - If the user is passed their quota, external users must upgrade their plan. Internal users can open an issue against the [{{ site.data.teams.logging-service.name }}]({{ site.data.teams.logging-service.issue }}).
7. The output of `ibmcloud ks logging config get --cluster <cluster-id>`

## Investigation and Action
If the information obtained from the must-gather steps above looks ok: the cluster is a paid cluster and in a good state, the customer is not out of quota, and the customer has logging configs on their cluster, proceed with matching up the output of the `ibmcloud ks logging config get` command with the info you received in the must-gather steps 3-5.

1. The user should have a logging config for the log type they are trying to view from step 5 above.
2. The host in the logging config is the [ingestion endpoint](https://console.bluemix.net/docs/services/CloudLogAnalysis/log_ingestion.html#log_ingestion_urls) and should map to the Kibana endpoint for where they are trying to view their logs from step 3 above.
3. If they are viewing their logs at the account level, the org and space should not be filled out in the logging config output. If they are viewing their logs for a specific org and space, it should match the output of the logging config output. If everything looks good here, proceed with verifying that fluentd is running in the cluster.

### Verify that armada-fluentd is running in cluster.
This step involves interacting with the customer's cluster.
1. Verify that the cluster has a fluentd daemonset. `kubectl -n kube-system get ds | grep fluentd`
2. Verify that the cluster has a fluentd instance for each node in the cluster. `kubectl -n kube-system get pods | grep ibm-kube-fluentd | grep Running | wc -l`
3. Verify that the cluster has a fluentd configmap. `kubectl -n kube-system get cm | grep fluentd`
4. Verify that the cluster has a fluentd secret `kubectl -n kube-system get secret | grep fluentd`
5. If any one the steps fail, open an issue against [{{ site.data.teams.armada-api.name }}]({{ site.data.teams.armada-api.issue }}).

## Escalation Policy
- For most problems, open an issue against [{{ site.data.teams.armada-api.name }}]({{ site.data.teams.armada-api.issue }})
- For critical issues not listed escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

## Automation
None
