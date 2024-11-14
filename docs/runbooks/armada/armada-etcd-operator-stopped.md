---
layout: default
description: How to resolve the armada-etcd-operator cluster down alerts
title: armada-etcd-operator-cluster-failed - How to resolve the etcd operator cluster failure related alerts
service: armada-etcd
runbook-name: "armada-etcd-operator cluster failure"
tags: armada, armada-etcd, etcd-operator.
link:
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This Runbook describes how to resolve armada-etcd-operator cluster failure.

### Background of etcd-operator

Etcd-operator is an open source tool from the community. General information can be found [here](https://github.com/coreos/etcd-operator)

The etcd operator manages etcd clusters deployed to [Kubernetes](http://kubernetes.io) and automates tasks related to operating an etcd cluster.

## Actions to take
The cluster has been unhealthy long enough that the `etcdcluster` Custom Resource as been marked as `Failed`.  That means `etcd-operator` will no longer try to recover pods in the `etcdcluster`.  To try to recover the cluster, we need to patch the CR so it can be recovered by `etcd-operator`.

1. Verify there are at least 3 pods running in the etcdcluster (`kubectl get pods -n armada -l app=etcd`).  If there are fewer than 3 pods, we've lost quorum. Proceed to [these steps](armada-etcd-unhealthy.html#armada-etcd-backup-restore).

2. Get the `etcdcluster` name; There should only be one present in the tugboat and it should look like `etcd-105-armada-eu-central` (e.g. eu-central).  This variable will be needed in future steps:
```
ETCD_CLUSTER_NAME=$(kubectl get -n armada etcdcluster --no-headers | awk '{print $1}')
```

3. Verify the `etcdcluster` is 'Failed':
```
kubectl get -n armada etcdcluster $ETCD_CLUSTER_NAME -o jsonpath='{.status.phase}'
```

4. Patch the `etcdcluster` resource:
```
kubectl -n armada get etcdcluster/$ETCD_CLUSTER_NAME -o yaml > cr.yaml
sed -i 's/phase: Failed/phase: Running/g' cr.yaml
kubectl -n armada patch etcdcluster/$ETCD_CLUSTER_NAME --patch "$(cat cr.yaml)" --type merge
```

5. Verify the `etcdcluster` has phase 'Running':
```
kubectl get -n armada etcdcluster $ETCD_CLUSTER_NAME -o jsonpath='{.status.phase}'
```

6. Ensure `etcd-operator` starts to repair the etcd pods; this may take about 5 minutes.  If after the 5 minutes, no new etcd pods are provisioned, check the `etcd-operator` pod logs.  If there are still `ignore failed cluster` messages in the logs, restart the `etcd-operator` pods and check the logs again:
```
kubectl -n armada delete pods -l name=etcd-operator
```

7. If new etcd pods do not come up, [escalate to dev](#escalation-policy).

## Escalation Policy

First open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.
