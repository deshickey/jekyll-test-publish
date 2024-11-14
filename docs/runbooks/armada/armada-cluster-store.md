---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Troubleshooting armada-cluster-store"
type: Informational
runbook-name: "armada-cluster-store "
description: "The armada-cluster-store service is not functioning properly for a carrier."
service: Razee
tags: razee, armada
link: /armada/armada-cluster-store.html
failure: ""
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
The armada-cluster-store service provides storage and retrieval of cluster configuration.
The armada-cluster-store deployment defines two pods that run in the armada namespace on every carrier.
Additional pods may be added by auto-scaling, but two is the minimum.
The service is accessed via kubedns at http://armada-cluster-store-service.armada.svc.cluster.local.
The armada-cluster-store service depends on
- [LaunchDarkly](https://app.launchdarkly.com/default/production/features) for determining if the primary or backup bucket should be used.
- [IBM Cloud Object Store](https://www.ibm.com/cloud/object-storage) stores the configuration files.

## Detailed Information
1. Find and connect to the carrier having issues.
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
1. Identify the pods and their state. By default there are two.
  ~~~~
  kubectl -n armada get pod -l app=armada-cluster-store
  export POD_NAME=<the more interesting pod from above>
  ~~~~
1. If no pods are running, see [armada-cluster-store-down](./armada-cluster-store-down.html).
1. If only some of the pods are running, see [armada-cluster-store-low](./armada-cluster-store-low.html).
1. Check the logs for clues. (The bunyan formatter is optional.)
  ~~~~
  kubectl -n armada logs $POD_NAME | bunyan
  ~~~~
1. If the logs indicate problems with LaunchDarkly [escalate](#escalation-policy).
1. If the logs indicate problems with COS:
  1. `kubectl -n armada exec -it $POD_NAME -- /bin/sh`
  1. `ping s3-api.us-geo.objectstorage.softlayer.net` from within and outside the pod.
    - If the COS endpoint is not accessible from your computer, see the [COS runbook](./armada-cos-problems.html).
    - If the COS endpoint is not accessible from the pod, see the [armada-networking runbook](./armada-network-initial-troubleshooting.html).
  1. `export AWS_ACCESS_KEY_ID="${PRIMARY_COS_ACCESS_KEYID}"`
  1. `export AWS_SECRET_ACCESS_KEY="${PRIMARY_COS_ACCESS_KEY}"`
  1. `aws  --endpoint ${PRIMARY_COS_ENDPOINT} s3 ls "s3://${PRIMARY_COS_BUCKET}/"`
1. Determine if kubedns is functioning:
  1. Determine the cluster-updater pod name `kubectl -n kube-system get pod -l app=cluster-updater)`
  1. `kubectl -n kube-system exec -it "<cluster-updater pod>" -- /bin/sh`
  1. `curl http://armada-cluster-store-service.armada.svc.cluster.local/12345` should return 200 and give a JSON object response. 

## Escalation Policy
Contact the @razee-pipeline team in the [#razee](https://ibm-argonauts.slack.com/messages/C5X987RU0/) channel for help.
Reassign the PD incident to `Alchemy - Containers Tribe - Pipeline`
