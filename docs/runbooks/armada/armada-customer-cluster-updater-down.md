---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Customers cluster updater pod is down"
type: Troubleshooting
runbook-name: "Customers cluster updater pod is down"
description: "The sidecar cluster-updater for a kubx master is down"
service: Razee
tags: razee, armada
link: /armada/armada-customer-cluster-updater-down.html
failure: ""
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

There is one side-car cluster-updater deployment pod that runs in the kubx-master namespace for every master. If one of the
cluster updater pods is down or not responding, its master can't get updates and there wont be any file enforcement. [Other cluster-updater runbooks](https://github.ibm.com/alchemy-containers/cluster-updater/blob/master/runbooks/runbooks.md)

## Example Alerts

~~~~
Labels:
 - alertname = master_cluster_updater_down
 - alert_situation = "master_cluster_updater_down"
 - service = armada-deploy
 - severity = critical
 - clusterID = <clusterID>
Annotations:
 - summary = "Customers cluster updater pod is down."
 - description = "Customers cluster updater pod is down for cluster <clusterID>"
~~~~

## Investigation and Action
1. Check the cluster ID against the [#armada-xo](https://ibm-argonauts.slack.com/archives/G53AJ95TP) bot, to see if the status is `deleted` or `deleting`
    * if so, proceed to [if the master doesnt exist](#if-the-master-doesnt-exist)
1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region.
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
    * Export variables. Replace the `<>` values with what is in the alert
      ```sh
      export CLUSTER_ID=<cluster_id>
      export TROUBLED_POD_ID=$(kubectl get pod -n kubx-masters -l app=cluster-updater-$CLUSTER_ID --no-headers|awk '{print $1}')
      echo $TROUBLED_POD_ID
      ```
      _NB. If the `cluster-updater` deployment has been scaled down to 0 there will be no results - see below for recovery_
1. Ensure cluster-updater should be running:
    * Sometimes a master has been deleted but fails to clean up cluster-updater  
    `kubectl get deployment -n kubx-masters master-${CLUSTER_ID}`
 
    * <a id="if-the-master-doesnt-exist">if the master doesnt exist</a>, **CAUTION!** [This step can be execute **only if the master doesn't exist**] **CAUTION!**    
    delete the associated cluster updater deployment and resolve incident.  
    `kubectl delete deployment -n kubx-masters cluster-updater-$CLUSTER_ID`
1. Check to see if the cluster-updater deployment is scaled down:
    * Sometimes a cluster-updater deployment may be scaled down to facilitate an update being held up  
    `kubectl get deployment -n kubx-masters cluster-updater-${CLUSTER_ID}`
    * If the deployment is scaled down to 0/0, scale it back up  
    `kubectl scale -n kubx-masters --replicas=1 deployment/cluster-updater-${CLUSTER_ID}`
1. Delete the pod to see if it comes up...  
`kubectl delete pod -n kubx-masters $TROUBLED_POD_ID`  
If not, continue diagnosis!
1. Ensure the cluster-updater version is current.
    - Note: if running on a tugboat (carrier100+), cluster-updater will be running in namespace `armada` instead of `kube-system`
    - Manually deploy a current, stable version of cluster-updater to manage the customer's cluster.
      ```sh
      export NAMESPACE=<legacy=kube-system, tugboat=armada>
      export KUBECONFIG=<path to carrier kube config>
      kubectl -n "${NAMESPACE}" get pods -l app=cluster-updater
      export CU_POD=<ID of running pod from previous command>
      kubectl -n "${NAMESPACE}" exec -it "${CU_POD}" -- /bin/sh sh/update-cruiser.sh "${CLUSTER_ID}"
      ```
    - Wait for the pod to cycle, then continue the diagnosis if the pod doesn't start normally.      

1. Identify if pod is stuck in state 'ContainerCreating' > 3m
    - Verify the pod has everything needed to fully start up. _`kubectl describe pod -n kubx-masters $TROUBLED_POD_ID` can also help point to a missing resource when starting up._
        1. Razee managed items. If any are missing, see the [razee escalation policy](#escalation-policy).
            - If armada-cluster-store in  the armada namespace is missing or down, review [Investigation and Action](./armada-cluster-store.html)
            - configmap `cluster-updater-cruiser-configmap` in kubx-masters
            - clusterRoleBinding `cluster-updater-binding` [here](https://github.ibm.com/alchemy-containers/cluster-updater/blob/master/services/cluster-updater/deployment.yaml#L29-L47)
            - serviceAccount `cluster-updater` in `kubx-masters` [here](https://github.ibm.com/alchemy-containers/cluster-updater/blob/master/services/cluster-updater/deployment.yaml#L19-L27)
        1. Deploy managed items. If any are missing, escalate to `Alchemy - Containers Tribe - armada-deploy`.
            - configmap `master-$CLUSTER_ID-cluster-info` with a section `cluster-config.json` or `cluster.json`
            - configmap `master-$CLUSTER_ID-config` in kubx-masters
            - secret `$CLUSTER_ID-secrets` in kubx-masters
1. Pod is stuck in state 'Unknown' (usually charactarized in the inability to run any action against the pod)
    1. The Kubernetes Worker Node is in a bad state. [runbook to debug troubled node](./armada-carrier-node-troubled.html#debugging-the-troubled-node)
1. Else follow [razee escalation policy](#escalation-policy).

## Escalation Policy

Contact the @razee-pipeline team in the [#razee](https://ibm-argonauts.slack.com/messages/C5X987RU0/) channel for help.
Reassigned the PD incident to `Alchemy - Containers Tribe - Pipeline`
