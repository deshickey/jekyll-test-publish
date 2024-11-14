---
layout: default
description: How to handle a sensu uptime check reporting alertmanager down.
title: armada-ops - How to handle a sensu uptime check reporting alertmanager down.
service: armada
runbook-name: "armada-ops - How to handle a sensu uptime check reporting alertmanager down"
tags: alchemy, armada, node, down, alertmanager
link: /armada/armada-ops-sensu-uptime-alertmanager-down.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with alerts arising from sensu-uptime reporting alertmanager is down.

## Example Alerts

Example PD title:

- `alertmanager-down.dev-mex01-carrier5 DOWN: <Error Code>`

## Investigation and Action

Alertmanager is troubled and has either crashed or failed deployment to the environment.

This could be due to an ongoing promotion or maintenance.
**armda-ops-alertmanager promotion** This can be checked [here](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-alertmanager).

If no ongoing promotion or maintenance, then there are something wrong on the Alertmanager microservice, please do the following:

1. `kubectl get pods -n monitoring -o wide | grep alertmanager`. 
  - If the pod is not running, please [Restart alertmanager pod](#restart-alertmanager-pod) directly. 
  - If it's running, please make a note of alertmanager pod name and node IP, and continue.  
~~~
  kubectl get pods -n monitoring -o wide | grep alertmanager
  armada-ops-alertmanager-6769cd5cff-88ncx         1/1     Running       0          3d22h   172.16.76.138    10.130.231.206     <none>
~~~
2. Go to this [jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/check-calico-node-status-master/)
  * Select the correct `Environment` and `Carrier` from the alert `service_name`
  * Select the `Service` value `alertmanager`
  * Input `ServiceURL` which can be found in alert details `service_url` 
  * Input `SensuClient` which can be found in alert details `client > address` 
  * Input `Worker` and `Pod` that get from previous step
3. If the jenkins job successful, then the pd should be auto-resolved soon, or please escalate
4. if unable to run the jenkins job, continue to [Fix alertmanager manually](#fix-alertmanager-manually)

## Restart alertmanager pod
1. `kubectl describe pod <alertmanager-pod-name> -n monitoring` - this will describe the health of the pod and the latest messages associated with it
2. `kubectl logs <alertmanager-pod-name> -n monitoring > alertmanager.log 2>&1` - collect the logs for the pod, this may be needed later for further debug
3. `kubectl delete pods <alertmanager-pod-name> -n monitoring` - this deletes the pod (which will be in not ready state) and the pod is recreated automatically.

If the issue persists, view the logs (in step 2), there could be an issue with the current build causing this outage.

## Fix alertmanager manually
1. `kubectl get ep -n monitoring | grep alertmanager` - get the endpoint of alertmanager and verify on the worker node that alertmanager pod in and the master node with `curl <alertmanger-endpoint>`
~~~
  kubectl get ep -n monitoring | grep alert
  armada-ops-alertmanager         172.16.76.138:9093
~~~
2. If `curl <alertmanager-endpoint>` timeout in worker node, it indicates something wrong with the alertmanger pod.  Then please [Restart alertmanager pod](#restart-alertmanager-pod).

3. If `curl <alertmanager-endpoint>` returns normal in worker node, but timeout in master node, it indicates calico node is down on 1 or more master nodes (ha master). go to every master node, do the following
   - `sudo crictl ps | grep calico-node`- get the calico-node container id
   - `sudo crictl stop <container-id>` - restart the calico-node container

4. If `curl <alertmanager-endpoint>` returns normally in both worker node and master node, it indicates something wrong with the kubectl-proxy in sensu-uptime.
 - please [Restart kubectl-proxy container in sensu uptime](#only-for-carrier-restart-kubectl-proxy-container-in-sensu-uptime).


## (Only for carrier) Restart kubectl-proxy container in sensu uptime

Skip this section if the alert occurs on tugboat.

1. Get the sensu uptime-client ip address in PD incident details and login. 

2. Get the service_url in PD incident details. for example,

   ~~~
   service_url: http://devmex01carrier5master01:8001/api/v1/namespaces/monitoring/services/armada-ops-prometheus:9090/proxy/dev-mex01/carrier5/prometheus/metrics
   ~~~

   And the kubectl proxy container for this check is `jenkins_devmex01carrier5master01` which is consist of the host in the url.

3. `docker ps  -a | grep jenkins_devmex01carrier5master01`. If it's down, please check the log with `docker logs jenkins_devmex01carrier5master01` before restart.

4. `docker restart jenkins_devmex01carrier5master01` - restart kubectl proxy container for dev-mex01-carrier5.

5. `docker exec -it jenkins_httpclient_1 curl -v <service url>` - verify the check manually. If it returns 200, then the PD will be auto-resolved soon, if not, please escalate.

## Escalation Policy

Involve the `armada-ops` squad via the [{{ site.data.teams.armada-ops.escalate.name }}]({{ site.data.teams.armada-ops.escalate.link }})

Discussion for down nodes is best handled in the [Armada-Ansible Slack Channel](https://ibm-argonauts.slack.com/messages/C53ML1TV0).

Discussion for general AlertManager problems is best handled in the [Armada-Ops Slack Channel](https://ibm-argonauts.slack.com/messages/C534XTE49).
