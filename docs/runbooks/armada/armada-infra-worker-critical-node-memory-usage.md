---
layout: default
title: Armada Worker critical Memory usage
type: Troubleshooting
runbook-name: "armada-infra-worker-critical-memory-usage"
description: "For handling situations when worker nodes are running out of memory"
service: armada
tags: alchemy, armada, memory
link: /armada/armada-infra-worker-critical-memory-usage.html
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Armada Worker node at critical memory usage

## Overview

Worker nodes have many pods running on them, all performing different tasks.  
Sometimes a node can get overloaded because the Kube scheduler puts work onto an already busy node.  
In other cases, the whole cluster may be nearly overloaded.

High priority alerts will trigger when machines are at 80% memory utilisation for a 5 minute duration.  
When nodes go over this thresshold, they start to become unstable and can begin to fail.

As a result, we want to take action at 80% to reduce this.

## Example alerts

Example:

- `bluemix.containers-kubernetes.critical_node_memory_usage_on_10.176.24.115.us-south`

## Investigation and Actions

_**PLEASE NOTE:**  If you are unsure about actions to take during the execution of this runbook, then proceed to the escalation policy and involve the correct development team as soon as possible._

We need to take the following immediate actions (See sections below this bullet list for details)

- Prevent more work being added to the node(s) flagged as at critical memory
- Check that the cluster as a whole is not overloaded
- Check other worker nodes are not reaching this criticial memory level.
- Consider migrating some of the work(pods) off the node(s) at critical memory

### Cordon the node(s)

1. log on to the master node for this cluster  
   _e.g. `ssh prod-dal10-carrier3-master-01`_
   
   Note: If this is a tugboat, follow the procedure in this runbook to proceed:
   https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats
   
1. Cordon the worker with:  
   `export NODEIP=<ip>`  
   _replace `<ip>` wth the nodes ip address_  
   `armada-cordon-node --reason "high memory usage" $NODEIP`

### Review already cordoned nodes

1. log on to the master node for this cluster  
   _eg. `ssh prod-dal10-carrier3-master-01`_

1. Check to make sure that the cordoned state of other nodes in the cluster  
   _we have previously observered issues where nodes have been left cordoned which means the remaining uncordoned nodes get overloaded_  
   `kubectl get nodes`  
   _look for nodes marked `NotReady` or `schedulingDisabled`_  
   if there are a lot of cordoned nodes, uncordon nodes where necessary, use:  
   `armada-get-cordoned-nodes`

1. If there are other nodes cordoned, use the information in the [high number of cordoned nodes](../armada/armada-carrier-high-number-cordoned-nodes.html) runbook to assist investigating and potentially uncordoning these nodes.

### Investigate if the cluster is overloaded

1. Ensure the cluster is not overloaded by running these checks.

   - See if there are any alerts for other nodes in that cluster active
   - Login to the prometheus instance for the cluster (eg: [prod-dal10-carrier3](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier3/prometheus/graph) ) and run the following queries.
   - View memory usage of all nodes:  
      `sum by (hostname) (node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes) / sum by (hostname) (node_memory_MemTotal_bytes) *100`
   - Verify if any other nodes that have critical memory usage:  
      `sum by (hostname) (node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes) / sum by (hostname) (node_memory_MemTotal_bytes) *100 >80`
   - Review the memory usage over the carrier:  
      `(sum(max_over_time(container_memory_working_set_bytes{id="/kubepods",dedicated=""}[20m])))/(sum(max_over_time(container_spec_memory_limit_bytes{id="/kubepods",dedicated=""}[60m])))*100`
   - Review pods per host - this will help see if the work is evenly distributed across the carrier:  
      `sum by (hostname) (max_over_time(kubelet_running_pod_count[10m]))`

1. If multiple nodes have high memory usage, this cluster may need more nodes adding to it.  
    Follow [this runbook](../armada/armada-scale-carrier-up.html) to scale up a carrier

### Investigate problematic pods and/or memory leaks

1. Investigate any potential memory leaks
    1. in prometheus for the carrier in question run  
    _(Prometheus can be found on the [Alchemy-prod dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier))_  
    `container_memory_usage_bytes{instance="x.x.x.x", id!="/", id!="/kubepods", id!="/kubepods/burstable"}`  
    _Replace the instance with the IP of the server triggering the alert_
    1. if any of the pods are trending upwards
       - get some logs from that POD - from the carrier master run  
       `kubectl logs -n <namespace> <pod>`
       - Log details in a GHE issue in the repo of the squad that owns that component (if it is obvious to work out.)  
       _for example, if it's a `kubx-master` raise a GHE against `armada-deploy`_
       - If you are unsure, post details of the memory usage graph to [#armada-dev](https://ibm-argonauts.slack.com/messages/C56K90989) slack channel.
    1. After data capture, find the memory leaking pod in the cluster with the command:  
    `kubectl get pods --all-namespaces | grep <pod name from earlier>`
    1. Delete the memory leaking pod with the command:  
    `kubectl delete pod -n <namespace> <pod-name>`
    1. Deleting the POD should provide some short term solution but this needs further investigation and assistance from development.

1. Investigate potential troubled master pods
    1. From the [promtheus](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) for the carrier in question, run the below query.  
    `(sum (container_memory_usage_bytes{name=~"^k8s_.*",pod_name=~"^master-.*"})by (pod_name,instance)  /   ignoring(pod_name) group_left(instance) sum by(instance) (label_replace(node_memory_MemTotal_bytes,"instance","$0", "hostname", ".*"))) - 100 > 10`
    1. This query will display all of the kubx-master pods that are using over 10% memory on a worker node.  This might indicate an issue with the master that the development team need to investigate.
    1. Capture logs of this master
       - log on to the master node for this cluster (For example: `ssh prod-dal10-carrier3-master-01`)
       - Grab the logs from all containers in the master  
       `kubectl logs -n kubx-masters <master-pod-name> -c <container name>`
       - Create a GHE issues against [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.link }}) and attach all of the logs.
    1. Delete the master pod which is consuming the high memory on the node  
       `kubectl delete pod -n kubx-master -l app=master-<clusterid>`

### Check non-terminated pod distribution and re-balance if necessary

1. If there are no obvious memory leaks or masters consuming abnormal amounts of memory, then it maybe necessary to move work off the node with high memory usage.

1. After checking the cordoned node status, check how non-terminated pods are distributed across the carrier  
   `kubectl describe node | grep -E '^(Name|Non)'`  
   will provide output similar to this

   ~~~shell
   Name:               10.176.215.2
   Non-terminated Pods:         (24 in total)
   Name:               10.176.215.31
   Non-terminated Pods:         (32 in total)
   Name:               10.176.215.43
   Non-terminated Pods:         (19 in total)
   Name:               10.176.215.5
   Non-terminated Pods:         (31 in total)
   Name:               10.176.215.60
   Non-terminated Pods:         (21 in total)
   Name:               10.176.215.9
   Non-terminated Pods:         (40 in total)
   ~~~

1. If the node reporting high memory usage has a large number of non-terminated pods, drain some pods from this worker to other worker nodes.
    - Evict a number of kubx master pods from the node until the memory drops to below 80%. Do this slowly/one at a time.
    - Identify a kubx-worker pods on the node that we can delete  
       `kubectl get pods -n kubx-masters -o=wide | grep $NODEIP`
    - Delete it with:  
       `kubectl delete pod -n kubx-masters <POD_NAME>`

1. The memory usage of the node should go down.  You can confirm this with prometheus query:  
  `sum by (hostname) (node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes) / sum by (hostname) (node_memory_MemTotal_bytes) *100`

1. Once pods have rescheduled onto other nodes, and the alert has resolved uncordon the worker so it can start accepting work again:  
   `armada-uncordon-node $NODEIP`

### Further Debugging/Monitoring

There are a number of useful queries that you can run in prometheus to get a better idea of what is going on in the cluster.  
If this cluster is repeatedly triggering this error you should investigate futher here for example: [prod-dal12/carrier2 complex query](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.range_input=12h&g0.stacked=0&g0.expr=100%20-%20(avg%20by%20(hostname)%20(rate(node_cpu_seconds_total%7Bmode%3D%22idle%22%7D%5B10m%5D)%20*%20100))&g0.tab=0&g1.range_input=12h&g1.expr=%20sum%20by%20(hostname)%20(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)%20%2F%20sum%20by%20(hostname)%20(node_memory_MemTotal_bytes)%20*100&g1.tab=0&g2.range_input=12h&g2.expr=(avg%20by%20(hostname)%20(node_load15))&g2.tab=0)

NOTE: 1 node in the cluster is the prometheus node. This will always be more heavily loaded than the others, but should _**not**_ be running any kubx-master pods.

- Memory:  
   `sum by (hostname) (node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes) / sum by (hostname) (node_memory_MemTotal_bytes) *100`  
   This alert triggers for nodes with > 80% memory usage for 5 minutes.  see if there ant
- CPU:  
   `100 - (avg by (hostname) (rate(node_cpu_seconds_total{mode="idle"}[10m]) - 100))`  
   nodes should not be above 80% CPU  If you see spikes in load over 5-10 minute ranges, these are likely due to evictions happening to to memory usage being high.  
   If the same node is repeately evicting pods, we shoild cordon that node and look more closely at it, is something consuming it's CPU / memory? -  follow this runbook for that node too.
- Load:  
   `(avg by (hostname) (node_load15))`  
   On our 16 core nodes a load average under 16-20 is desirable.  We should look closer at nodes whith higher Load

## Other commands

The following commands are useful commands which are worth mentioning

- see run  
   `kubectl top nodes`  
   _to see the memory and CPU usage f the nodes in the cluster_  
   _`kubectl top nodes | sort -k 5 -h `_  
   _... sorted by the % [5th] column`_
- `kubectl -n kubx-masters get pods -o wide | grep Evict`  
   will show you pods that have been evicted - are these pods causing problems?
- `kubectl -n kubx-masters get po -o wide | grep Evict | awk '{print $7}' | sort | uniq -c`  
   will show you the repeat evictions on the same node.  If a node is repeatedly evicting, the scheduler is giving it too much work.  Cordon this node and see if it gets better.
- `kubectl -n kubx-masters get po -o wide | grep Evict | awk -F "-" '{print $2}' | sort | uniq -c`  
   will show repeated evictions of the same kubx-master pod - is there one pod that is causing problems on a node and repeatedly being moved between nodes?
- Find utilization of evicted masters:  
   ``for i in `kubectl -n kubx-masters get po -o wide | grep Evict | awk -F "-" '{print $2}' | sort | uniq -c | awk '{print $2}'`; do kubectl -n kubx-masters top pods -n kubx-masters | grep $i; done``  
   If there are a few masters that are using a lot of resources thats ok as long as there is capcity for them. If they are being regularly rescheduled AND its from the same nodes, the cordoning those trouble nodes will fix it, however, if they keep getting rescheduled from DIFFERENT nodes, then it may be time for more capacity
- clean up the log of evicted pods - do this if the list is too long so that you can see whats happening NOW - and make sure the scheduler is doing its job properly.  
   ``for i in `kubectl -n kubx-masters get po -o wide | grep Evict | awk '{print $1}'`; do kubectl -n kubx-masters delete pod $i; done``

## Other useful info

**NOTE:** the worker running prometheus will often have higher memory usage than other workers
We have excluded prometheus tainted nodes from this process so we should not see alerts for high memory usage on these nodes.

### RCA and pCIEs

If you have identified that the cluster is overloaded, and more nodes need to be adding, if load increases further on this cluster we may have a pCIE or CIE.  Those will be identified by other alerts triggering.  The solution will often be to add more nodes.

## Escalation Policy

If issues appear to be as a result of an Armada squads pod causing the spike, escalate to the owning squad via their [escalation policy](./armada_pagerduty_escalation_policies.html) and work with them to understand and debug the cause.
