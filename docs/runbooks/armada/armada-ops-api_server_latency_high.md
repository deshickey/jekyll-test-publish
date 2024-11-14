---
layout: default
description: How to handle an alert for high kubernetes apiserver latency.
title: armada-infra - How to handle an alert for high kubernetes apiserver latency.
service: armada
runbook-name: "armada-infra - How to handle an alert for high kubernetes apiserver latency"
tags: alchemy, armada, K8SApiServerLatency
link: /armada/armada-ops-api_server_latency_high.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

The above alert triggers when, for a 10 minute period, the 99 percentile check for latency for a verb is over 1 second.

## Example alerts

Example PD title:

- `#3533816: bluemix.containers-kubernetes.Kubernetes_apiserver_latency_is_high.us-south`


Example Body:

```
num_resolved     	  0

num firing       	  1

firing     	  

Labels:
 - alertname = K8SApiServerLatency
 - job = kubernetes-apiservers
 - service = armada-infra
 - severity = warning
 - verb = GET
 - alert_situation = Kubernetes_apiserver_latency_is_high
Annotations:
  - description = 99th percentile Latency for GET requests to the kube-apiserver is higher than 1s.
  - summary = Kubernetes apiserver latency is high
  - runbook = https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-ops-api_server_latency_high.html
Source: http://prometheus-1607893960-1vqmj:9090/graph?g0.expr=histogram_quantile%280.99%2C+sum%28apiserver_request_latencies_bucket%7Bverb%21~%22CONNECT%7CWATCHLIST%7CWATCH%22%7D%29+WITHOUT+%28instance%2C+node%2C+resource%29%29+%2F+1000000+%3E+1&g0.tab=0
```

## Actions to take

### Move the master pod containing the slow apiserver to another worker node

For example, if you receive an alert with the title:

`bluemix.containers-kubernetes.Kubernetes_apiserver_latency_is_high.wat-stgc2`

Take note of the `wat-stgc2` on the end of the string.  This is referring to which master pod is being slow.  In this case, it is referring to Watson's stage environment.  If you take a quick [search](https://github.ibm.com/alchemy-containers/armada-envs/search?utf8=%E2%9C%93&q=stgwat&type=Code) through the armada-envs repository, you will find out that the `stgwat` clusters are maintained by `prod-dal10-carrier1`.

If you run into a slow "managed" cluster such as one of the Watson clusters, you can move their master pod to another worker to try and mitigate the latency alerts.

1) SSH to the carrier master in question

~~~
ssh user@prod-dal09-carrier1-master-01
~~~

2) List out the master pods, looking for the Watson cluster:

~~~
root@prod-dal10-carrier1-master-01:~# kubectl get pods -n kubx-masters -o wide | grep wat
master-prodwat-cr01-1733060464-6kl7j                       6/6       Running       0          2h        172.16.103.9     10.171.220.200
master-stgwat-cr01-3926549357-50246                        6/6       Running       1          16h       172.16.200.170   10.171.220.194
master-stgwat-cr02-1209623245-6n0l5                        6/6       Running       1          16h       172.16.251.78    10.171.220.206
~~~

The last column is the worker node the the master pod is currently residing on.

3) Cordon the node

In the example above, `stgwat-cr02` resides on `10.171.220.206`.  You can cordon off the node to prevent additional load to be added to the worker.

~~~
armada-cordon-node --reason <reason> <node>
~~~

4) Move the master pod

Now that the loaded worker node has been cordoned, if you delete the master pod, it will be forced to be recreated on another worker node with hopefully less load than the previous.

~~~
kubectl delete pod master-stgwat-cr02-1209623245-6n0l5 -n kubx-masters
~~~

Wait for the master pod to come back online.

5) Uncordon the old-node (if necessary)

Now that the master pod has been recreated on another node, you can uncordon the previous node using:

~~~
armada-uncordon-node <node>
~~~

6) Resolve the alert

The master pod has been moved to a new worker.


### Carrier Slowness

Sometimes, you will see `us-south` at the end of the string.  This is specifically talking about the carrier master apiserver itself.  In that case, there isn't anything you can do.  The Armada-Runtime team is currently working to mitigate the problem by:

* Adding more carriers and regions
* Adding load balancing to spread the load of all of the master pods being created
* Maintaining/improving the health of our existing carriers
* Moving to a cluster-based etcd for carriers

Please resolve these alerts promptly if you do not see a specific cluster in the alert.

## Escalation Policy
Escalation paths should be to the `armada-ops` squad (#armada-ops in slack).
Review the [escalation policy](./armada_pagerduty_escalation_policies.html) document for full details of which squad to escalate to.
