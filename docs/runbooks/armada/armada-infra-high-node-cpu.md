---
layout: default
description: How to handle a node which has high CPU usage.
title: armada-infra - How to handle a node which is reporting high CPU usage.
service: armada
runbook-name: "armada-infra - How to handle a node which is reporting high CPU usage"
tags: alchemy, armada, disk, CPU
link: /armada/armada-infra-high-node-cpu.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to handle a node which is reporting high CPU usage.

Worker nodes have many pods running on them, all performing different tasks.
Sometimes a node can get overloaded because the Kube scheduler puts work onto an already busy node.
In other cases, the whole cluster may be nearly overloaded.

This alert will trigger worker nodes going over 85% CPU usage and remaining above this percentage for 5 minutes or more.

## Example Alerts

Example:

- `bluemix.containers-kubernetes.critical_cpu_usage_on_node_10.176.24.115.us-south`

## Investigation and Actions

_**PLEASE NOTE:**  If you are unsure about actions to take during the execution of this runbook, then proceed to the escalation policy and involve the correct development team as soon as possible._

We need to take the following immediate actions

- Prevent more work being added to the node(s) flagged as at critical cpu, 
- Check that the cluster as a whole is not overloaded
- Consider migrating some of the work(pods) off the node(s) at critical cpu.
- **Note** As of Q1 2020, High occurance of high CPU alerts are triggered. The majority of the alerts appear to come from ICD or Watson Clusters (WAMS / Watson). 
   * The long term resolution discussion can be found:  https://github.ibm.com/alchemy-containers/armada-deploy/issues/3798

   
### Track troublesome clusters


1.   Raise a [Conductors team GHE](https://github.ibm.com/alchemy-conductors/team/issues/new) to track investigations.
1.   There are usually several nodes triggering in a carrier so the investigation should occur in parallel
1.   Log onto the troubled node(s) in a particular carrier
1.   Run `top -c -b -n1 -o %CPU` to show processes ordered by the cpu being consumed
1.   Run `cat /proc/<PID>/cpuset | awk -F '/' '{print $5}'` to get the container id
1.   Run `sudo crictl inspect <containerid> | grep io.kubernetes.pod.name` to get the pod name
1.   Query the cluster id in `#armada-xo`, in most of cases, it will be ICD or WAMS/Watson.
1.   Add details into the GHE raised earlier
1.   If a specific master has been identified, then request approval from SRE Leads to order new dedicated nodes for this master.
1.  Add the ticket issues to the GHE and work to order and dedicate nodes to this master

### Cordon the node(s)

1. log on to the master node for this cluster, or if it is a tugboat (carrier100+) log onto the hub in the region..
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)
_eg. `ssh prod-dal10-carrier3-master-01`_

1. Cordon the worker with:  
`export NODEIP=<ip>`  
_replace `<ip>` wth the nodes ip address_
  
   `armada-cordon-node --reason "high cpu usage" $NODEIP`

### Review already cordoned nodes

1. log on to the master node for this cluster, or if it is a tugboat (carrier100+) log onto the hub in the region..
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)  
_For example: `ssh prod-dal10-carrier3-master-01`_

1. Check to make sure that the cordoned state of other nodes in the cluster  
_we have previously observered issues where nodes have been left cordoned which means the remaining uncordoned nodes get overloaded_

   On the carrier-master, look for nodes marked **NotReady** or **SchedulingDisabled** using  
   `kubectl get nodes`  

   _Or  
   `kubectl get nodes | grep -v "Ready "`  
   which will list all the nodes **not** ready_

   _if there are a lot of these, use  
   `armada-get-cordoned-nodes`  
   (which should provide the cordon reasons) and uncordon nodes where necessary/appropriate_

1. If there are other nodes cordoned, use the information in the [high number of cordoned nodes](./armada-carrier-high-number-cordoned-nodes.html) runbook to assist investigating and potentially uncordoning these nodes.

### Investigate if the cluster is overloaded

1. ensure the cluster is not overloaded (Checking both memory and CPU)
    - see if there are any alerts for other nodes in that cluster active
    - login to the prometheus instance for this node (eg: [prod-dal10-carrier3](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier3/prometheus/graph) )
      - to see the cpu usage of all nodes, run the query:  
    `100 - (avg by (hostname) (rate(node_cpu_seconds_total{mode="idle"}[10m]) * 100))`
       - to see nodes that have critical cpu usage, run:  
    `100 - (avg by (hostname) (rate(node_cpu_seconds_total{mode="idle"}[10m]) * 100)) >85`
       - Review the memory usage over the carrier  
    `(sum(max_over_time(container_memory_working_set_bytes{id="/kubepods",dedicated=""}[20m])))/(sum(max_over_time(container_spec_memory_limit_bytes{id="/kubepods",dedicated=""}[60m])))*100`
       - Review pods per host  
    `sum by (hostname) (max_over_time(kubelet_running_pod_count[10m]))`

1. If multiple nodes have high cpu usage, this cluster may need more nodes adding to it.  
   Follow [this runbook](../armada/armada-scale-carrier-up.html) to scale up a carrier

### Check what processes are using high amounts of CPU

- From the node reporting CPU issues
  - run  `top -c -b -n1 -o %CPU` to show  processes ordered by the cpu being consumed.
  - From the `top` output, find  processes consuming high percentages of CPU and investigate why these processes are consuming high CPU.
  - Non container based processes such as system or root processes tied with the operating system may indicate an issue with the server so [consider draining and rebooting the worker node](./armada-carrier-node-troubled.html#rebooting-worker-node), however, note, that this may just push the problem to another worker node if it is a problem with an armada POD.
  - If the process can be linked to one of the PODs running on the node, capture logs from that POD  -  for example: `kubectl logs -n <namespace> <pod>` and raise a GHE against the armada squad that owns the component.
  - Once logs have been captured, consider deleting the POD to see if this is a temporary issue and recreating it resolves the high CPU.
- Monitor the CPU after taking above actions.  If improvements are not seem, if there is a particular POD which is consuming a lot of CPU or has spiked and remained high, then we may need advice from the squad which own that POD/process and consider escalating the page to them.

### Check non-terminated pod distribution and re-balance if necessary

1. After checking the cordoned node status, check how non-terminated pods are distributed across the carrier - example:
    ~~~shell
    kubectl describe node | grep -E '^(Name|Non)'
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
    _to limit to 30 and over use:  
    `kubectl describe node | grep -E '^(Name|Non)' | grep -E '(Name|\([1-9][0-9][0-9]|\([3-9][0-9])'`_  
    _**Warning: the above command takes a while to run!**_

1. If the node reporting high cpu usage has over 40 non-terminated pods, drain some pods from this worker to other worker nodes.
   - Identify a kubx-worker pods on the node that we can delete  
      `kubectl get pods -n kubx-masters -o=wide | grep $NODEIP`
   - Delete it with:  
      `kubectl delete pod -n kubx-masters <POD_NAME>`

1. The cpu usage of the node should go down.  You can confirm this with prometheus query:
   `100 - (avg by (hostname) (rate(node_cpu_seconds_total{mode="idle"}[10m]) * 100))`

1. Once pods have rescheduled onto other nodes, and the alert has resolved uncordon the worker with:
   `armada-uncordon-node $NODEIP`

### Further Debugging/Monitoring (required)

There are a number of useful queries that you can run in prometheus to get a better idea of what is going on in the cluster.  If this cluster is repeatedly triggering this error you should investigate further here  
for example: [prod-dal12/carrier2 complex query](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.range_input=12h&g0.stacked=0&g0.expr=100%20-%20(avg%20by%20(hostname)%20(rate(node_cpu_seconds_total%7Bmode%3D%22idle%22%7D%5B10m%5D)%20*%20100))&g0.tab=0&g1.range_input=12h&g1.expr=%20sum%20by%20(hostname)%20(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)%20%2F%20sum%20by%20(hostname)%20(node_memory_MemTotal_bytes)%20*100&g1.tab=0&g2.range_input=12h&g2.expr=(avg%20by%20(hostname)%20(node_load15))&g2.tab=0)

NOTE: 1 node in the cluster is the prometheus node. This will always be more heavily loaded than the others, but should not be running any kubx-master pods.

- Memory:
   `sum by (hostname) (node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes) / sum by (hostname) (node_memory_MemTotal_bytes) *100`  
   _This alert triggers for nodes with > 80% memory usage for 5 minutes.  see if there ant_
- CPU:
   `100 - (avg by (hostname) (rate(node_cpu_seconds_total{mode="idle"}[10m]) * 100))`

   Nodes should not be above 80% CPU  
   If you see spikes in load over 5-10 minute ranges, these are likely due to evictions happening to to memory usage being high.
   If the same node is repeately evicting pods, we shoild cordon that node and look more closely at it, is something consuming it's CPU / memory?  
   _follow this runbook for that node too_

- Load:  
   `(avg by (hostname) (node_load15))`  
   On our 16 core nodes a load average under 16-20 is desirable.  We should look closer at nodes whith higher Load

### Other commands

The following commands are useful commands which are worth mentioning 

- From the worker node reporting high CPU, list processes consuming high CPU
   `top -c -b -n1 -o %CPU`
- to see the memory and CPU usage of the nodes in the cluster  
   `kubectl top nodes`  
- to show you pods that have been evicted  
   `kubectl -n kubx-masters get pods -o wide | grep Evict`  
   _are these pods causing problems?_
- To see repeat evictions on the same node  
   `kubectl -n kubx-masters get po -o wide | grep Evict | awk '{print $7}' | sort | uniq -c`  
   _If a node is repeatedly evicting, the scheduler is giving it too much work.  Cordon this node and see if it gets better_
- To show repeated evictions of the same kubx-master pod  
   `kubectl -n kubx-masters get po -o wide | grep Evict | awk -F "-" '{print $2}' | sort | uniq -c`  
   _is there one pod that is causing problems on a node and repeatedly being moved between nodes?_
- Find utilization of evicted masters:

~~~shell
for i in `kubectl -n kubx-masters get po -o wide | grep Evict | awk -F "-" '{print $2}' | sort | uniq -c | awk '{print $2}'`; do kubectl -n kubx-masters top pods -n kubx-masters | grep $i; done
~~~

If there are a few masters that are using a lot of resources thats ok as long as there is capcity for them. If they are being regularly rescheduled AND its from the same nodes, the cordoning those trouble nodes will fix it, however, if they keep getting rescheduled from DIFFERENT nodes, then it may be time for more capacity

- clean up the log of evicted pods - do this if the list is too long so that you can see whats happening NOW - and make sure the scheduler is doing its job properly.

~~~shell
for i in `kubectl -n kubx-masters get po -o wide | grep Evict | awk '{print $1}'`; do kubectl -n kubx-masters delete pod $i; done
~~~

### Other useful info

**NOTE:** the worker running prometheus will often have higher memory usage than other workers
We have excluded prometheus tainted nodes from this process so we should not see alerts for high memory usage on these nodes.

## RCA and pCIEs

If you have identified that the cluster is overloaded, and more nodes need to be adding, if load increases further on this cluster we may have a pCIE or CIE.  Those will be identified by other alerts triggering.  The solution will often be to add more nodes.

## Escalation policy

If issues appear to be as a result of an Armada squads pod causing the spike, escalate to the owning squad via their [escalation policy](./armada_pagerduty_escalation_policies.html) and work with them to understand and debug the cause.

### Assistance from armada-carrier squad

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.
