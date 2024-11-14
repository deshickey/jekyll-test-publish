---
layout: default
description: How to resolve Hypershift NodePool reconciler backup related alerts
title: hypershift-nodepool-reconcile-failed - How to resolve Hypershift NodePool reconciler backup related alerts 
service: armada-hypershift
runbook-name: "hypershift-nodepool-reconcile-failed"
tags:  hypershift, nodePoolReconcile
link: /hypershift/hypershift-nodepool-reconcile-failed.html
type: Alert
grand_parent: Armada Runbooks
parent: Hypershift
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `HypershiftNodePoolReconcileJobFailed`| The hypershift nodepool reconcile job failed to complete for a cluster | [Failed NodePool Reconcile](#failed-nodepool-reconcile) |
{:.table .table-bordered .table-striped}

## Customer impact

Users may not be able to attach worker nodes to this satellite location clusters. A critical error message is displayed to the users.

## Example Alert(s)

~~~~
Labels:
 - alertname = hypershift_nodepool_reconcile_failed
 - alert_situation = hypershift_nodepool_reconcile_failed
 - service = armada-hypershift
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = master
Annotations:
 - summary = "The hypershift nodepool reconciler job failed to complete"
 - description = "The hypershift nodepool reconciler job failed to complete"
~~~~

## Actions to take

### Failed NodePool Reconcile

This means that the nodepool reconcile job for the customer cluster did not complete

To debug:

1. Find and login into the tugboat of the satellite location having issues
    * More info on how to do this step can be found [here](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
1. Export variables. Replace the `<>` values with what is in the alert
```
export CLUSTER_ID=<cluster_id>
```
1. Find the job. `kubectl -n master get jobs -l rhcos-config-clusterid=$CLUSTER_ID`
```
NAME                                          COMPLETIONS   DURATION   AGE
ibm-nodepool-reconcile-c4rr1hh10si6oa0qp05g   1/1           30s        47h
```
1. Describe the job found from above. `kubectl describe job -n master <jobName>`
```
Name:           ibm-nodepool-reconcile-c4rr1hh10si6oa0qp05g
Namespace:      master
Selector:       controller-uid=6c1d4e72-6e9d-4e5c-8f8d-6d04f8e481cf
Labels:         app=ibm-nodepool-reconcile
                rhcos-config-clusterid=c4rr1hh10si6oa0qp05g
Annotations:    razee.io/build-url: https://travis.ibm.com/alchemy-containers/rhcos-vpcgen2-ignitiondata/builds/55398549
                razee.io/source-url: https://github.ibm.com/alchemy-containers/rhcos-vpcgen2-ignitiondata/commit/00443de7009758521be1c8bd856b33ac5e053454
                version: 00443de7009758521be1c8bd856b33ac5e053454
Parallelism:    1
Completions:    1
Start Time:     Tue, 07 Sep 2021 13:53:52 -0500
Completed At:   Tue, 07 Sep 2021 13:54:22 -0500
Duration:       30s
Pods Statuses:  0 Running / 0 Succeeded / 1 Failed
Pod Template:
  Labels:           controller-uid=6c1d4e72-6e9d-4e5c-8f8d-6d04f8e481cf
                    job-name=ibm-nodepool-reconcile-c4rr1hh10si6oa0qp05g
  Service Account:  ibm-nodepoolreconciler
  Containers:
   nodepool-reconcile:
    Image:      registry.ng.bluemix.net/armada-master/rhcos-vpcgen2-ignitiondata:00443de7009758521be1c8bd856b33ac5e053454
    Port:       <none>
    Host Port:  <none>
    Command:
      /bin/bash
      -c
      /usr/local/bin/reconcile_nodepool_metadata.sh
    Environment:
      NODE_POOL_NAMESPACE:  master
      HOSTED_CLUSTERID:     c4rr1hh10si6oa0qp05g
    Mounts:
      /tmp/nodepool-metadata from nodepool-metadata (rw)
  Volumes:
   nodepool-metadata:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      nodepool-metadata-info-c4rr1hh10si6oa0qp05g
    Optional:  false
Events:        <none>
```
1. Look at the `Pod Statuses` section. 
  - If it all reports 0, like `Pods Statuses:  0 Running / 0 Succeeded / 0 Failed`, open an issue and against [armada-bootstrap](https://github.ibm.com/alchemy-containers/armada-bootstrap). 
  Snooze the alert until US working day for dev team to investigate.
  - If it reports 1 Failed, like `Pods Statuses:  0 Running / 0 Succeeded / 1 Failed`, continue onto the next steps.
2. Find the failing jobs pods.
```
kubectl -n master get po | grep $CLUSTER_ID
ibm-nodepool-reconcile-c4sfbk810b8bj91700l0-bqkpm       0/1     Error       0          162m
ibm-nodepool-reconcile-c4sfbk810b8bj91700l0-g9vbh       0/1     Error       0          112m
ibm-nodepool-reconcile-c4sfbk810b8bj91700l0-hpw7b       0/1     Error       0          150m
ibm-nodepool-reconcile-c4sfbk810b8bj91700l0-n2q2v       0/1     Error       0          137m
ibm-nodepool-reconcile-c4sfbk810b8bj91700l0-wkv9v       0/1     Error       0          125m
ibm-nodepool-reconcile-c4sfbk810b8bj91700l0-xvlzx       0/1     Error       0          100m
ibm-nodepool-reconcile-c4sfbk810b8bj91700l0-xxpnx       0/1     Error       0          85m
```
3. Grab the latest pod not in `Completed` and export it
```
export POD_ID=<pod_id>
```
3. View the logs of the failing jobs. `kubectl logs -n master <FAILED_POD_NAME>`. If the cause of the failure is not clear (i.e. master control plane issues), then please [escalate](#escalation-policy) 
4. Check to see if all jobs are failing, this could indicate a bigger issue with the tugboat or location.
```
kubectl -n master get po | grep ibm-nodepool-reconcile
```

### Additional Information

More information can be found about the implementation of the nodepool reconcile job can be found [here](https://github.ibm.com/alchemy-containers/rhcos-vpcgen2-ignitiondata)

## Escalation Policy

If you need assistance, please reach out to the developers using the [{{ site.data.teams.armada-hypershift.comm.name }}]({{ site.data.teams.armada-hypershift.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-hypershift.name }}]({{ site.data.teams.armada-hypershift.issue }}) Github repository with all the debugging steps and information done to get to this point.
