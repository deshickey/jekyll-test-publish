---
layout: default
description: Dedicating carrier workers to specific customers kubx-master PODs
title: How to dedicate carrier workers to specific customers kubx-master PODs
service: armada-deploy
runbook-name: "How to dedicate carrier workers to specific customers kubx-master PODs"
tags: alchemy, armada, kubernetes, armada-deploy
link: /armada/armada-dedicate-worker-node-for-master-pod.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to manually dedicate worker node(s) so that only a certain kubx master lands on it.

We have had requests like this in the past as HA kubx masters do not currently exist.  However, we are still seeing requests for this even now we run HA Masters as some internal squads masters require to run on a dedicated node.

## Previous example requests

An example of a previous requests
- [request via team ticket 3858](https://github.ibm.com/alchemy-conductors/team/issues/3858)
- [request via team ticket 6625](https://github.ibm.com/alchemy-conductors/team/issues/6625)

## Detailed Information

Follow these steps to action the request;

1. Determine which carrier the kubx master is located using [armada-xo](https://ibm-argonauts.slack.com/messages/G53AJ95TP)  
`@xo cluster clusterid` and look for `ActualDatacenterCluster`
2. Legacy carriers: Obtain suitable workers to be dedicated. You can use existing nodes, or order new ones.
  - If ordering new nodes follow [this runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/conductors_requesting_carrier_workers.html) and use template `carrier-workers-1000-series-ded-worker`. Procure two nodes in each DC.
  - If using existing nodes:
    - make sure config matches template `carrier-workers-1000-series-ded-worker` in the [provsioning app](https://alchemy-dashboard.containers.cloud.ibm.com/prov/web/templates/list) .  We are looking for the below spec

          | Key | Values |
          | -------------- | --------- |
          | pkgId | 46 |
          | description | "32 x 2.0 GHz or higher Cores (Dedicated)" |
          | ram_item | "RAM_64_GB" |
          | disks | {"guest_disk0": "GUEST_DISK_100_GB_LOCAL", "guest_disk1": "GUEST_DISK_150_GB_LOCAL"} |

    - Check to see if the nodes are already tainted/labelled for another cluster.  
    - Check to see if nodes are on dedicated hosts.  If so check the existing resources on the host. If there are not enough for the upgrade it may be better/faster to order new nodes.
3. Tugboats: If ordering new nodes follow instructions here https://github.ibm.com/alchemy-containers/tugboat-bootstrap/#scaling-the-worker-pool, otherwise use existing workers dedicated to multi-az workload (`kubectl get node -l multi-az-worker=true`)
- Three replicas for a kubx-master POD will exist in a carrier/tugboat.  This means, at a minimum, we should be allocating at least 6 nodes to run a single master.  We require 6 for failover reasons.  i.e. 2 nodes in AZ1, 2 nodes in AZ2 and 2 nodes in AZ3 for a MZR.
- You can identify existing workers with potential capacity with  
   - This will exclude already tainted/dedicated nodes for another cluster  
   
```
for x in \
$(kubectl top node -l topology.kubernetes.io/zone=dal10,multi-az-worker=true | sort -nk5 | awk '{print $1}' | grep -v NAME); \
do for y in $(kubectl get node $x --show-labels | grep -v "dedicated=master" | awk '{print $1}' | grep -v NAME); \
do echo $y && \
kubectl describe node $y | grep -e "cpu:" -e "memory:" | head -n 2 && \
echo "Current percentage of resources used" && \
kubectl top node $y | awk '{print $3, $5}' && \
echo -n "Number of Master pods running = " && \
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=$y | grep master- | grep -v ibm-master-proxy | wc -l && \
echo -n "Number of ETCD pods running = " && \
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=$y | grep etcd- | grep -v -e etcd-op -e operator -e backup | wc -l && \
echo "*************************************"; \
done; done
```

  - be sure to use the correct zone. Replace the value of `topology.kubernetes.io/zone=` 
  - The best candidates are nodes with no or little etcd and master pods.
  - We are also lookin for nodes with at least 32CPU & 64GB RAM. We can resize the nodes if needed. (Step 3 below)
4. Create an ops prod train (Example previous Change request is CHG2738416)
```
Squad: SRE
Service: 
Title: Cordon, drain and upgrade taint nodes
Status: Complete
Environment: <REGION>
Details: For moving master to dedicated nodes <LINK TO GHE ISSUE>
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 4h
BackoutPlan: manually restore the nodes
```

5. If a resize is needed take the following action on each node.
  - Make sure the node is **not** on a dedicated host.
   If the return value is not nil, don't use this node  
   **hint:** higher number is unlikely to be on dedicated host.  
  `slcli virtual detail <NODE-IP> | grep dedicated_host`
  - cordon the node.
  - drain the node. Take care to move the etcd pods and that you leave the etcd cluster in a healthy state.
  - Go to IBM Cloud UI [Device List](https://cloud.ibm.com/gen1/infrastructure/devices)
  - Find the node and resize it from the UI.
6. Add taints to all the workers you have identified.
 - Legacy Carriers: this can be done via this [Jenkins Job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-taint-label-worker)

**Note** that if all nodes have minimal etcd pods, the JJ should be able to run the drains successfully. Otherwise armada-drain node with possible manual assistance will be needed.

 - Tugboats: you will need to manually taint & label the workers [Taints runbook for guidance](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/Taints.md) 



After choosing and tainting each node, perform these steps:

_NB:_ Please consult the deploy squads [runbook](./armada-carrier-node-troubled.html#rebooting-worker-node) for steps to cordon and drain the worker nodes.

1. Tugboats only: Use invoke-tugboat to target the proper tugboat from a regional carrier worker
1. uncordon the nodes once all drains and tainting has completed.
1. Find the kubx masters and run the following command.  
`armada-master-restart <CLUSTER-ID> --reason 'restarting master pods for dedicated nodes'`  
1. Make sure all 3 master pods are running on the selected nodes.
1. Delete the kubx-etcd pods one by one so they also get recreated on the tainted node(s)
- `kubectl get po --all-namespaces -o wide | grep etcd-<clusterid>` will find the etcd pods  
- `kubectl delete po -n <etcd-namespace> <pod id>` - will delete the etcd pod (perform one deletion at a time AND make sure etcd pods are back to 3/3 before continuing)
1. Verify that the masters and etcd pods are back online and running on the tainted node(s)
- `kubectl get po -n kubx-masters -l app=master-<clusterid> -o wide`
- `kubectl get po --all-namespaces -o wide | grep etcd-<clusterid>`

## Escalation Policy

This action should not be escalated to development through pager duty.

If assistance is needed, then post in the [armada-deploy](https://ibm-argonauts.slack.com/archives/C54G8PWUF) slack channel.
