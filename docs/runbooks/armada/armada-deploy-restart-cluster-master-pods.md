---
layout: default
title: How to restart cluster master pods
type: Informational
runbook-name: "How to restart cluster master pods"
description: How to trigger a rolling restart of cluster master pods
category: Armada
service: armada-deploy
tags: armada, master, restart
link: /armada/armada-deploy-restart-cluster-master-pods.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to safely trigger a rolling restart of the master
pods for a cluster.

## Detailed Information

If you need to restart all the pods for a cluster you can use any of the methods
described below to trigger a rolling restart of the master pods. The pods will
be restarted one at a time, waiting for pods to pass the readiness checks before
restarting the next pod.

All these methods are equivalent; use the one that best meets your needs.

### Jenkins job

- Go to the [armada-deploy-master-restart](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-master-restart/)
job.

- Click `Build with parameters` and provide the following information:
  - CLUSTER: The cluster id.
  - REASON: A short reason. The time, user and resource will be recorded.
  - WAIT: Optionally check this box to have the job wait for the rollout to complete.
    You can watch the progress in the job console output.

### armada-master-restart command on a carrier master

- Login to one of the carrier masters for the carrier hosting the cluster
(e.g. stage-dal09-carrier0-master-01)

- Run the `armada-master-restart` command:

```
armada-master-restart - Does a rolling restart of pods in the master-CLUSTER deployment

Restart cluster:
  armada-master-restart [-w|--watch] --reason "REASON" CLUSTERID

Display info about last rollout restart (which may not be the last update):
  armada-master-restart --last CLUSTERID

Where:
  --help       Displays this help
  --last       Shows date, user and reason for last 'rollout restart'
  --reason     Brief reason for restart.
  -w, --watch  Watches rollout progress via 'kubectl rollout status'
  CLUSTERID    The ID of the cluster to restart
```

### ibmcloud ks cluster master refresh --cluster <cluster-id> (customer)

Customers can trigger a restart themselves via the
[ibmcloud ks cluster master refresh --cluster <cluster-id>](https://cloud.ibm.com/docs/containers-cli-plugin?topic=containers-cli-plugin-kubernetes-service-cli#cs_apiserver_refresh)

## See info about the last restart

You can see the date, user and reason for the restart by using the
`armada-master-restart` command. If the cluster was restarted due to a
patch update or some other operation that will not be reflected; just the last
explicit restart is shown.

- Login to one of the carrier masters hosting the cluster master.

- Run this command:
  `armada-master-restart --last CLUSTERID`

For example:
  ```
  $ armada-master-restart --last bjdek2u20vivstraf7k0
  Restarted at 2019-05-14T17:39:06Z by 'jmcmeek': testing
  ```

## Further Information

Contact the deploy team if you have questions or problems.
