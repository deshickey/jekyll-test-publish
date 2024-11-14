---
layout: default
title: IKS Network - calico-node Troubleshooting
runbook-name: "IKS Network - calico-node Troubleshooting"
tags: calico calico-node network networking troubleshooting
description: "IKS Network - calico-node Troubleshooting"
service: armada-network
link: /armada/armada-network-calico-node-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

calico-node is a daemonset that should be running in every IKS/ROKS cluster, with a single calico-node pod on each worker in the cluster.  When an IKS/ROKS cluster is first deployed, and again when its master is updated, calico-node and other calico components are deployed and configured specifically to work with IBM Cloud and IKS/ROKS components.  In most cases this configuration should not be changed at all.  There are a few specific settings, such as Calico's MTU, which can be modified if needed to handle specific situations, but only Calico settings that are specifically described in the IKS/ROKS documentation should be changed.  Changing other Calico settings is not supported.  Also Calico is updated to new versions as part of IKS/ROKS master updates.  Do NOT attempt to update Calico yourself.

The calico-node pod on each worker has three main jobs:

1. Run init containers to:
    - Deploy the Calico CNI on each worker
    - Add a private Calico HostEndpoint (and public Calico HostEndpoint for classic workers attached to a public VLAN) for the given worker, to make it easier to use Calico policies that restrict traffic on the private and public network.  This requires a connection to the cluster master.  Note that on ROKS this HostEndpoint creation is done on an init container on the ibm-keepalived-watcher pod instead

2. Program pod routes in the worker's linux routing table, and to share those routes with other calico-node pods on other workers.  This ensures that pods can communicate with other pods, even when they are on different workers, VLANs, and subnets

3. Update iptables rules that implement the Calico and Kubernetes network policies that are applied to the cluster.  This ensures that these policies are enforced and only allow the specified traffic to various endpoints to which they are applied.

More details can be found at https://docs.projectcalico.org/reference/node/configuration

This runbook covers steps to take when calico-node is not working correctly in either a customer cluster, tugboat, or carrier.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts


## Investigation and Action

### Check If Worker Is Ready and Healthy

Sometimes calico-node having problems on a node is simply caused by the worker itself not being healthy.  So first check that the worker nodes in the cluster are in Ready state.  If one or more are not, do a `kubectl describe node ...` to see why.  There are two typical reasons a node will report NotReady.

#### Reason 1: The kubelet has not contacted the master in at least the last 30 seconds.

If this is the case, you will see Conditions similar to this:

```
  MemoryPressure       Unknown   Thu, 07 Oct 2021 00:34:33 -0500   Thu, 07 Oct 2021 00:39:42 -0500   NodeStatusUnknown   Kubelet stopped posting node status.
  DiskPressure         Unknown   Thu, 07 Oct 2021 00:34:33 -0500   Thu, 07 Oct 2021 00:39:42 -0500   NodeStatusUnknown   Kubelet stopped posting node status.
  PIDPressure          Unknown   Thu, 07 Oct 2021 00:34:33 -0500   Thu, 07 Oct 2021 00:39:42 -0500   NodeStatusUnknown   Kubelet stopped posting node status.
  Ready                Unknown   Thu, 07 Oct 2021 00:34:33 -0500   Thu, 07 Oct 2021 00:39:42 -0500   NodeStatusUnknown   Kubelet stopped posting node status.

```

or you might see that the Condition is Ready (check this), but that the worker has been toggling between ready and not ready, as shown by events like this at the bottom of the `kubectl desecribe node...` output:

```
  Normal   Starting                 44m                kubelet  Starting kubelet.
  Normal   NodeReady                44m                kubelet  Node 10.188.156.137 status is now: NodeReady
  Normal   NodeAllocatableEnforced  42m                kubelet  Updated Node Allocatable limit across pods
  Normal   NodeHasSufficientPID     42m (x7 over 42m)  kubelet  Node 10.188.156.137 status is now: NodeHasSufficientPID
  Normal   NodeHasSufficientMemory  42m (x8 over 42m)  kubelet  Node 10.188.156.137 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    42m (x8 over 42m)  kubelet  Node 10.188.156.137 status is now: NodeHasNoDiskPressure
  Normal   Starting                 31m                kubelet  Starting kubelet.
  Warning  InvalidDiskCapacity      31m                kubelet  invalid capacity 0 on image filesystem
  Normal   NodeHasSufficientMemory  31m                kubelet  Node 10.188.156.137 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    31m                kubelet  Node 10.188.156.137 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     31m                kubelet  Node 10.188.156.137 status is now: NodeHasSufficientPID
  Normal   NodeNotReady             31m                kubelet  Node 10.188.156.137 status is now: NodeNotReady
  Normal   NodeAllocatableEnforced  31m                kubelet  Updated Node Allocatable limit across pods
  Normal   NodeReady                31m                kubelet  Node 10.188.156.137 status is now: NodeReady
  Normal   Starting                 27m                kubelet  Starting kubelet.
  Warning  InvalidDiskCapacity      27m                kubelet  invalid capacity 0 on image filesystem
  Normal   NodeAllocatableEnforced  27m                kubelet  Updated Node Allocatable limit across pods
  Normal   NodeNotReady             27m                kubelet  Node 10.188.156.137 status is now: NodeNotReady
  Normal   NodeHasSufficientPID     21m (x2 over 27m)  kubelet  Node 10.188.156.137 status is now: NodeHasSufficientPID
  Normal   NodeHasNoDiskPressure    21m (x2 over 27m)  kubelet  Node 10.188.156.137 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientMemory  21m (x2 over 27m)  kubelet  Node 10.188.156.137 status is now: NodeHasSufficientMemory
  Normal   NodeReady                21m (x2 over 27m)  kubelet  Node 10.188.156.137 status is now: NodeReady
  Normal   NodeAllocatableEnforced  17m                kubelet  Updated Node Allocatable limit across pods
  Normal   NodeHasNoDiskPressure    16m (x7 over 17m)  kubelet  Node 10.188.156.137 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     16m (x7 over 17m)  kubelet  Node 10.188.156.137 status is now: NodeHasSufficientPID
  Normal   NodeHasSufficientMemory  16m (x8 over 17m)  kubelet  Node 10.188.156.137 status is now: NodeHasSufficientMemory
```

You should follow the troubleshooting docs for worker nodes (PUT LINK HERE), since the problem is with the connection from the worker to the master (which does not use Calico).

#### Reason 2: Kubelet is connected to the master, but calico-node is not successfully running on the node.

If this is the case, you will see a Condition similar to one of the following:

  - ` Ready            False   Wed, 06 Oct 2021 17:08:17 -0500   Wed, 06 Oct 2021 17:07:57 -0500   KubeletNotReady              container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized`
  - `  NetworkUnavailable   True    Thu, 07 Oct 2021 00:49:02 -0500   Thu, 07 Oct 2021 00:49:02 -0500   CalicoIsDown                 Calico is shutting down on this node`
 
and you should follow this runbook to try to repair Calico on this worker.

### calico-node Not Running at all on any Workers

calico-node should be running on each worker node.  If it is not running on any nodes (not even in CrashLoopBackOff or Pending state), then most likely the daemonset was deleted, or a custom webhook is preventing the pods from starting.  To recover, run: `ibmcloud ks cluster-refresh --cluster <CLUSTER_NAME>`  It will take up to 45 minutes for the master to completely refresh and for the calico-node daemonset to be recreated.  If this still doesn't fix the problem, search for "webhook" in the [Armada-Deploy Operations Failure](armada-deploy-operation-failures.html) runbook for more options.

### calico-node Pod Not Running on One or a Few Customer Workers

If calico-node is not running or is in a bad state on one or a few workers, then there is most likely something wrong with that specific worker.  

First cordon the worker so no more pods are scheduled to the worker: `kubectl cordon <worker_node_name>`

Next gather the output and logs listed in the "Logs and Data to Gather For Calico Issues" section below.  At that point if the customer wants the problem resolved quickly move on to the next step.  If it is a development or test cluster and the customer is more interested in the root cause, they can examine that output for an indication of what the problem might be.

Once the data has been gathered, or if the customer doesn't want to gather the data, take the following steps in order to try to solve the issue

1. Delete the calico-node pod: `kubectl delete pod -n <kube-system/calico-system> <calico-node-XXXXX>`.   If calico-node restarts and goes to Running state on that worker, then the problem is solved.  Uncordon the worker.
2. Reboot the worker.  If this solves the problem, uncordon the worker
3. Reload the worker.  If this works, then uncordon the worker

If this problem persists after a Reload where calico-node fails to stay in Running state for very long (or every few days it goes bad), check:
  - If a calico-typha pod (or several) does not appear healthy, that could affect any calico-node pods that are trying to connect to it.  In that case consult the [calico-typha troubleshooting runbook](armada-network-calico-typha-troubleshooting.html)
  - For Classic clusters, ensure either VLAN spanning or VRF is enable in the customer account by asking the customer to run `ibmcloud account show`.
  - For Classic cluster, check if there is a Vyatta or other Gateway/Firewall managing the cluster workers.  If so, it might be misconfigured for the given workers (or subnets) that are seeing this problem.  If these nodes worked in the past, check for any configuration changes or new workload around the time the problem started.
  - For VPC clusters, check for any new workload or if the customer modified any Security Groups, ACLs, public Gateway, or custom routes for the VPC the cluster is in.

In general customers are responsible for troubleshooting their own cluster workers.  The [Network Mustgather doc under Troubleshooting IKS/ROKS Workers](https://github.ibm.com/ACS-PaaS-Core/MustGathers/blob/master/Kubernetes/Networking/networking.md#troubleshooting-iksroks-workers) provides tips on how to troubleshoot cluster worker problems to determine what workload or component might be causing the problem.

### calico-node in CrashLoopBackOff or Restarting Often on Most or All  Workers

Since you have already checked that the worker nodes themselves (kubelet on the workers) have a reliable connection in section "Check If Worker Is Ready and Healthy" above, the problem is most likely something in the Calico configuration, or possibly in the Calico/Kubernetes Datastore.

If all workers are affected, it is most likely a problem with Calico configuration or the cluster master or datastore.

If a large subset of workers are affected, see if you can tell what that subset of workers have in common.  Some possibilities include:
  - Those nodes have been updated or reloaded/replaced recently
  - Those nodes are all in the same zone, subnet, worker pool
  - Those nodes all have a specific component or pod running on them

In either case, gather the output and logs listed in the "Logs and Data to Gather For Calico Issues" section below, and examine that output for an indication of what the problem is.  Also, examine what changes have been made to the cluster recently that might be directly or indirectly causing the problem, such as:
  - Calico configuration changes
  - Calico or Kubernetes network policy changes
  - Firewall/Gateway device configuration changes
  - Static routes added/changed
  - VPN connection/configuration added/changed
  - Master or worker updates

### calico-node Pod Not Running after upgrading to IKS 1.29 (or newer)

IKS 1.29 introduces Tigera Operator to manage Calico components in `calico-system` namespace. There might be several reason why calico-node pods fail to start in the new namespace `calico-system` during the migration from `kube-system`. One of the thing to check is the BGP mesh. If customer has previously changed the BGP password (and removed or changed `created-by: IBMCloudKubernetesService` annotation in `BGPConfiguration`) the cluster update process won't migrate the `calico-bgp-password` secret from `kube-system` namespace. In this case, the following errors can be seen on the cluster:
1. the calico-node pod has failing readiness probe
  - you should see something similar to: `Warning  Unhealthy  112s (x201 over 73m)  kubelet  (combined from similar events): Readiness probe failed: 2024-02-12 14:42:49.280 [INFO][5037] confd/health.go 180: Number of node(s) with BGP peering established = 0 calico/node is not ready: BIRD is not ready: BGP not established with 10.94.227.28,10.94.227.48` in the output of `kubectl describe po $(kubectl get po -ncalico-system --no-headers | grep calico-node | head -1 | awk '{print $1}') -ncalico-system` command
2. the calico-node pod is in `0/1 Running`

If that's the case, just copy the secret from `kube-system` namespace to `calico-system` namespace with this command: `kubectl get secret calico-bgp-password -n kube-system -o yaml | sed 's/namespace: kube-system/namespace: calico-system/g' | kubectl create -f -`
and run this command to create Role and RoleBinding for the `calico-bgp-password` secret:

```
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: bgp-secret-access
  namespace: calico-system
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["calico-bgp-password"]
  verbs: ["watch", "list", "get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bgp-secret-access
  namespace: calico-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: bgp-secret-access
subjects:
- kind: ServiceAccount
  name: calico-node
  namespace: calico-system
EOF
```

At this point, you should see that the migration of Calico components will continue from `kube-system` to `calico-system`.


### Logs and Data to Gather For Calico Issues

Gather the following output and logs, especially if the customer wants any analysis of the problem after it is resolved via a master refresh or worker reload/replace.  Note that calico-node pods are in the `kube-system` (IKS 1.28 or lower) or `calico-system` (IKS 1.29 and above) namespace for IKS, and the `calico-system` namespace for ROKS.

1. `kubectl describe pod -n <kube-system/calico-system> calico-node-XXXXX` (for the calico-node pod(s) that are in a bad state.
2. `kubectl describe node <worker_node_name>` (for the node the calico-node pod is on that is bad)
3. `kubectl logs -n <kube-system/calico-system> calico-node-XXXXX -c calico-node > calico-node-XXXXX.log`
4. `kubectl logs -n <kube-system/calico-system> calico-node-XXXXX -c install-cni > calico-node-XXXXX-cni.log`
5. For IKS: `kubectl logs -n <kube-system> calico-node-XXXXX -c calico-extension > calico-node-XXXXX-ext.log`
6. For ROKS: `kubectl logs -n kube-system ibm-keepalived-watcher-XXXXX -c calico-extension > ibm-keepalived-watcher-XXXXX-ext.log`

## Escalation Policy

Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)


## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [Calico Architecture](https://docs.projectcalico.org/reference/architecture/)
  * [Connecting Applications with Services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
