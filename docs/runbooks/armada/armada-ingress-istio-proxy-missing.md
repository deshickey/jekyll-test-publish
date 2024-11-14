---
layout: default
title: armada-ingress - one or more pods missing istio-proxy container
type: Alert
runbook-name: "armada-ingress - one or more pods missing istio-proxy container"
description: How to handle alerts for pods missing the istio-proxy container
category: armada
service: armada-ingress
tags: ingress, istio, istio-proxy, sidecar, side-car
link: /armada/armada-ingress-istio-proxy-missing.html
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

Istio ingress and egress policies are enabled in the `armada` and `monitoring` namespaces on microservices tugboats. Pods in these namespaces must have an `istio-proxy` container to be able to communicate outside of the cluster. Without the container, they will fail to reach dependent services, which can cause 5xx errors to users.

## Example alerts 

- `ArmadaIstioProxyContainerMissing`  

  ```
  Labels:
   - alertname = ArmadaIstioProxyContainerMissing
   - alert_key = armada-ingress/armada_pod_missing_istio_proxy
   - alert_situation = armada_pod_missing_istio_proxy
   - carrier_name = dev-dal10-carrier104
   - carrier_type = hub-tugboat-etcd
   - service = armada-ingress
   - severity = critical
   - tip_customer_impacting = false
  Annotations:
   - description = At least one pod from the armada and monitoring namespaces is missing its required
   istio-proxy sidecar and needs to be restarted
   - summary = Pods that are missing the istio-proxy container in istio-enabled namespaces will be unable
   to reach external dependent services, and users may receive errors when trying to administer clusters.
  ```

## Automation

Use the [armada-istio-status](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-istio-status/) Jenkins job to restart automatically restart the problematic pods.
1. Click `Build with Parameters`
1. For `OPERATION` select `restart-pods-missing-istio-proxy`
1. For `TUGBOAT` select the `carrier_name` that was identified in the PagerDuty alert.
1. Leave all other parameters at their defaults, and click `Build`

## Actions to take

If the [armada-istio-status](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-istio-status/) job is not available or not working properly, you can restart the pods manually using the steps below.
1. Click on the `Source` link in the pagerduty alert to view the failing pods and their namespaces in prometheus.  
  Sample prometheus output:
   ```
   {namespace="armada", pod="armada-iam-events-76df4c7557-s5mhc"}
   {namespace="monitoring", pod="armada-ops-grafana-9bb4465b8-jsvcb"}
   {namespace="armada", pod="armada-iam-events-76df4c7557-7t8qr"}
   {namespace="armada", pod="armada-storage-billing-5544fcd9d6-7rs5q"}
   {namespace="monitoring", pod="armada-ops-dashboard-6d8ffd7f8b-mgxg5"}
   ```
1. [Access the tugboat](armada-tugboats.html) listed under `carrier_name` in the alert.
1. For each pod in the prometheus output, replace `NAMESPACE` and `POD` in the command below with the values from prometheus.
   ```
   kubectl -n NAMESPACE delete pod POD
   ```
1. Verify that the new pod has the `istio-proxy` container. Either refresh the prometheus query, or list all of the pods for the app of the pod that was deleted and confirm that the newest pod has the correct number of containers. For example, if `armada-iam-events-76df4c7557-s5mhc` was deleted, run `kubectl -n armada get pod -l app=armada-iam-events` to get the output below.  

   ```
   NAME                                 READY   STATUS    RESTARTS   AGE
   armada-iam-events-76df4c7557-7t8qr   1/1     Running   0          5d9h
   armada-iam-events-76df4c7557-87ltm   2/2     Running   0          2d
   armada-iam-events-76df4c7557-9b6pd   2/2     Running   0          32s 
   ```
   Note that the second `armada-iam-events` pod from the prometheus listing has not been deleted yet.  
1. If the new pod is still missing the `istio-proxy` container, delete it too. If its replacement also comes up without the `istio-proxy` container, describe the pod (`kubectl -n NAMESPACE describe pod POD`) and look at the `Annotations` section. 
   - If the pod does not have a `sidecar.istio.io/inject: false` annotation, follow the steps in the [Escalation Policy](#escalation-policy) section.
   - If the pod *does* have a `sidecar.istio.io/inject: false` annotation, open a new GHE issue in [alchemy-conductors/team]({{ site.data.teams.containers-sre.issue }}) with details so that the alert expression can be updated to exclude those pods.

## Escalation Policy

- Raise a [new GHE issue](https://github.ibm.com/alchemy-containers/satellite-network) with the @satmesh-squad squad and include the steps that were performed, the current pod listing, and a link to the PagerDuty alert. Post the issue in [armada-control-plane-istio](https://ibm.enterprise.slack.com/archives/C072XHMACTY) so that the team will see it when next online.  

 - If *all* pods for a particular deployment are still missing the `istio-proxy` container after following the steps in this runbook
   - escalate to [Carrier Istio](https://ibm.pagerduty.com/escalation_policies#PKXCMU3)
   - start thread in[armada-control-plane-istio](https://ibm.enterprise.slack.com/archives/C072XHMACTY) with slack handle of the person the alert was escalated to

## Useful links

- Escalation policy: [Carrier Istio](https://ibm.pagerduty.com/escalation_policies#PKXCMU3)
- Slack channels: [armada-control-plane-istio](https://ibm.enterprise.slack.com/archives/C072XHMACTY)
- GHE issues: [GHE](https://github.ibm.com/alchemy-containers/satellite-network)
