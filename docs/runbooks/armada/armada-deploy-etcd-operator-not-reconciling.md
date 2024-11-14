---
layout: default
title: armada-deploy - Etcd operator not reconciling
type: Troubleshooting
runbook-name: "armada-deploy - Etcd operator not reconciling"
description: "armada-deploy - Etcd operator not reconciling"
service: armada
link: /armada/armada-deploy-etcd-operator-not-reconciling.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# HA Master Etcd Operator Not Reconciling runbook

## Overview

This alert fires when etcd-operator has not completed a reconcile loop for a particular cluster for an extended period of time. If the reconcile loop is not running for an extended period of time, it can impact management of etcd clusters for the customer clusters. For example, if an etcd pod is deleted due to a worker node being drained, the etcd operator may not be able to create a new pod to replace it and return the cluster to full strength.

| Alert_Situation | Info | Start |
|--
| `EtcdOperatorNotReconcilingCluster`| etcd-operator has not completed a reconcile loop for cluster in 30 minutes | [actions-to-take](#actions-to-take) |
{:.table .table-bordered .table-striped}

## Example Alert

~~~~
Labels:
 - alertname = etcd_operator_not_reconciling_cluster
 - alert_situation = etcd_operator_not_reconciling_cluster
 - service = armada-deploy
 - severity = critical
 - cluster_id = xxxxxx
 - namespace = yyyyyy
~~~~

## Investigation and Action

- Log in to the tugboat or carrier where the alert is firing
- Gather the namespace of the stuck etcd-operator from the alert's labels. Use that value for `$NAMESPACE` in the commands below.
- Determine the lead etcd-operator pod: `POD=$(kubectl get lease -n $NAMESPACE etcd-operator -o jsonpath='{.spec.holderIdentity}') && echo $POD`
- Delete that pod: `kubectl delete pod -n $NAMESPACE $POD`
- A new etcd-operator pod should automatically created to replace the deleted pod, and leadership should transfer to a different pod
- Within a few minutes of transferring leadership, the alert should clear
- If the alert does not clear, or if additional assistance is required, alert development as appropriate via the [escalation policy](#escalation-policy)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
