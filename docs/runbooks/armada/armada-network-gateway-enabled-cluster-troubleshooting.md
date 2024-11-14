---
layout: default
description: "[Troubleshooting] Armada - Gateway Enabled Cluster"
title: "[Troubleshooting] Armada - Gateway Enabled Cluster"
runbook-name: "[Troubleshooting] Armada - Gateway Enabled Cluster"
service: armada
tags: armada, cloud provider, kubernetes, kubectl, lb, loadbalancer, network, service, gateway, bgp, bird
link: /armada/armada-network-gateway-enabled-cluster-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview: IKS Gateway Enabled Cluster

We have extended Gateway Enabled Cluster support for a single customer, Qualtrics (Clarabridge), until 1/31/24, so we will need to continue to provide them support.  For all other customers, they can not create new Gateway Enabled clusters, and for existing clusters:

GEC are only supported through IKS 1.23 (which goes unsupported on 5/8/23)
    - Customers can not create GE clusters, and can't update their cluster masters to 1.24
        - https://cloud.ibm.com/docs/containers?topic=containers-cs_versions_124
        - These docs state: "The end of support dates are linked directly to the end of support of IBM Cloud Kubernetes Service version 1.23. Gateway-enabled clusters are not supported on version 1.24 and later. If your cluster is gateway-enabled, plan to create a new cluster before support ends. If you need similar functionality, consider creating a cluster on VPC infrastructure."

GEC are only supported through 4.9 (which goes unsupported on 7/26/23)
    - Customers can not create GE clusters, and can't update their cluster masters to 4.10
        - https://cloud.ibm.com/docs/openshift?topic=openshift-cs_versions_410
        - These docs state: "The end of support dates are linked directly to the end of support of Red Hat OpenShift on IBM Cloud version 4.9. Gateway-enabled clusters are not supported on version 4.10 and later"

The IBM Cloud Kubernetes Service (IKS) introduces the gateway enabled cluster which provides a way for customers to deploy private workers and a few public "gateway" workers.

These gateway workers will provide egress to the public network (or egress to another private network or VPN). A gateway enabled cluster could be created with cluster create command combined with the option flag `--gateway-enabled`.

By default 2 gateway nodes will be created and these nodes will serve the NLBs. The ALBs will run on the private-only compute nodes and will not be directly exposed to the public network. If the user still wants to isolate their ALBs to specific nodes, they can easily add edge nodes to their VPC Lite Cluster by adding an edge worker pool.

To check if a cluster is created with gateway enabled mode, please use the following services:
- Slack bot [@xo cluster command](https://ibm-argonauts.slack.com/messages/G53AJ95TP)  
or 
- Jenkins job [get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/)  
_The clusterID needs to be provided to these services!_

Once the result is received, look for **isVPCLite** flag:  
` "IsVPCLite": "true"`  
_`true` means this **is** a gateway enabled cluster_

External documentation on IKS Gateway Enabled Clusters:
- [Gateway Enabled Blog Post](https://www.ibm.com/cloud/blog/announcements/ibm-cloud-kubernetes-service-gateway-enabled-clusters)  
_for additional description about the feature_

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts.
The symptom could be following: applications on the compute worker nodes cannot reach external services.

## Limitations

The IKS Gateway Enabled Clusters are supported at Kubernetes version 1.15 and higher.
Before troubleshooting, review the following customer documentation:
- [Network planning](https://cloud.ibm.com/docs/containers?topic=containers-plan_clusters#gateway)
- [Cluster create](https://cloud.ibm.com/docs/containers?topic=containers-clusters#gateway_cluster_cli)
- [Add Worker Pools](https://test.cloud.ibm.com/docs/containers?topic=containers-add_workers#gateway_pools)
- [Edge nodes](https://cloud.ibm.com/docs/containers?topic=containers-edge#edge_gateway)
- [NLB 1.0 flow](https://cloud.ibm.com/docs/containers?topic=containers-loadbalancer-about#v1_gateway)
- [NLB 2.0 flow](https://cloud.ibm.com/docs/containers?topic=containers-loadbalancer-about#v2_gateway)
- [Ingress flow](https://cloud.ibm.com/docs/containers?topic=containers-ingress-about#classic-gateway) 

## Investigation and Action

### Troubleshoot cluster setup

Start by troubleshooting the deployed cluster setup.
The cluster contains gateway worker nodes and compute worker nodes. As the nodes will have the labels, using the `kubectl get nodes` with a **selector** will list the appropriate nodes in the cluster.

To print the gateway worker nodes, use the following command:  
`kubectl get nodes --selector "ibm-cloud.kubernetes.io/private-cluster-role=gateway"`

Example result:
```
NAME           STATUS   ROLES     AGE    VERSION
10.176.3.156   Ready    gateway   147m   v1.15.4+IKS
10.176.3.171   Ready    gateway   147m   v1.15.4+IKS
```

To print the compute and edge worker nodes, use the following command:  
`kubectl get nodes --selector "ibm-cloud.kubernetes.io/private-cluster-role=worker"`

Example result:
```
NAME           STATUS   ROLES     AGE    VERSION
10.176.3.138   Ready    compute   146m   v1.15.4+IKS
10.176.3.169   Ready    compute   146m   v1.15.4+IKS
```

**Important: without these node labels, the Gateway Controller DaemonSet cannot run and will report NotReady status.**

### Troubleshoot Gateway Controller DaemonSet

Start by troubleshooting the gateway controller daemonset. This daemonset is responible for setting up the routes on the worker nodes.
To check the actual status of the gateway controller daemonset, use the following command:  
`kubectl get ds -n kube-system --selector "app=ibm-gateway-controller"`

Example result:

```bash
NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ibm-gateway-controller   4         4         4       4            4           <none>          83m
```

Field descriptions:
1. `DESIRED` and `AVAILABLE` must equal to the number of worker nodes in the cluster. To check if the number is valid, please count the nodes in the cluster.
2. `CURRENT` must equal to the number of worker nodes in the cluster. When it is less, then one the worker nodes is posting **other status than `Ready`**. To check the node status, use the `kubectl get nodes` command and troubleshoot the problem.
3. `READY` must equal to the number of worker nodes in the cluster. When it is less, the service in the pod is not working.

  To find which pod has the `NotReady` status, use the command:  
  `kubectl get pods -n kube-system --selector "app=ibm-gateway-controller | grep NotReady"`
 
 Once the pod is found, gather its logs and save it. If there is no obvious error (e.g. missing node label), please follow the next steps in the guide.
4. `UP-TO-DATE` must equal to the number of worker nodes in the cluster. If not, it means one of pods is not running with the latest changes, version.
To troubleshoot the problem, use the command:  
`kubectl describe ds -n kube-system ibm-gateway-controller`
  
  If kubernetes does not update the pod, delete the pod manually, and it will be started with the latest changes, version.
5. `NODE SELECTOR` must be set to `<none>` as the daemonset shall run all worker nodes. The IKS cluster-updater feature assures that the daemonset is always deployed as it should be, so this kind of issue is not likely happen.

#### Examine internal status of the Gateway Controller Pods

Review the internal status of the gateway controller. To do this:
- to list the nodes:  
`kubectl get nodes`

- list the gateway controller pods  
`kubectl get pods -n kube-system --selector "app=ibm-gateway-controller" -o wide`

- execute the following command in all the pods  
`kubectl exec -it -n kube-system ibm-gateway-controller-<pod_id> -- bash /usr/local/bin/debugBird`

Example results:
```
kubectl get nodes
NAME           STATUS   ROLES     AGE    VERSION
10.176.3.138   Ready    compute   119m   v1.15.4+IKS
10.176.3.156   Ready    gateway   120m   v1.15.4+IKS
10.176.3.169   Ready    compute   119m   v1.15.4+IKS
10.176.3.171   Ready    gateway   120m   v1.15.4+IKS
```
```
kubectl get pods -n kube-system --selector "app=ibm-gateway-controller" -o wide
NAME                           READY   STATUS    RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
ibm-gateway-controller-fqs52   1/1     Running   0          120m   10.176.3.156   10.176.3.156   <none>           <none>
ibm-gateway-controller-sp5hd   1/1     Running   0          119m   10.176.3.138   10.176.3.138   <none>           <none>
ibm-gateway-controller-wmcjv   1/1     Running   0          119m   10.176.3.169   10.176.3.169   <none>           <none>
ibm-gateway-controller-xpd25   1/1     Running   0          120m   10.176.3.171   10.176.3.171   <none>           <none>
```
Based on this, it is possible to see which pod runs on a gateway worker node, and which pod runs on a compute worker node.
As the next step, check the internal status.

Result when the pod is running on a gateway worker node:
```
kubectl exec -it -n kube-system ibm-gateway-controller-fqs52 -- bash /usr/local/bin/debugBird
-------------------------------------------
BIRD v1.0.0+birdv1.6.5 ready.
Router ID is 10.176.3.156
Current server time is 2019-09-27 08:57:47
Last reconfiguration on 2019-09-27 06:59:38
------------------------------------------
BFD sessions | Up          (2) | Other (0)
BGP sessions | Established (2) | Other (0)
------------------------------------------
Number of 0.0.0.0/0 routes in the BIRD default_routes_table table: 1
--------------------------------------------------------------------
```
In the printout, BFD and BGP session counts shall equal to the number of compute and edge worker nodes.

Result when the pod is running on a compute/edge worker node:
```
kubectl exec -it -n kube-system ibm-gateway-controller-sp5hd -- bash /usr/local/bin/debugBird
-------------------------------------------
BIRD v1.0.0+birdv1.6.5 ready.
Router ID is 10.176.3.138
Current server time is 2019-09-27 08:59:09
Last reconfiguration on 2019-09-27 06:59:44
------------------------------------------
BFD sessions | Up          (2) | Other (0)
BGP sessions | Established (2) | Other (0)
------------------------------------------
Number of 0.0.0.0/0 routes in the BIRD default_routes_table table: 2
--------------------------------------------------------------------
Default route nexthops in table 180:
10.176.3.156
10.176.3.171
```
In the printout, BIRD shall post `Ready` status. If not, it means the BIRD client cannot run and cannot configure the routing table. The gatewayController application is responsible to start, reload, stop the BIRD client. To the operate properly, it needs access the kubernetes API server. Please make sure that the API server is available from the cluster. 

BFD and BGP session counts shall equal to the number of gateway worker nodes and the route table 180 shall contain as many IP addresses as many gateway nodes are in the cluster. The IP addresses in the list shall match with the gateway worker nodes names/IPs.

To check if BIRD operates, check the following command outputs:

`kubectl exec -it -n kube-system ibm-gateway-controller-<pod_id> -- birdc show protocols all`

Result when the pod is running on a gateway worker node:
```
kubectl exec -it -n kube-system ibm-gateway-controller-fqs52 -- birdc show protocols all
BIRD v1.0.0+birdv1.6.5 ready.
name     proto    table    state  since       info
device1  Device   master   up     06:58:30
  Preference:     240
  Input filter:   ACCEPT
  Output filter:  REJECT
  Routes:         0 imported, 0 exported, 0 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              0          0          0          0          0
    Import withdraws:            0          0        ---          0          0
    Export updates:              0          0          0        ---          0
    Export withdraws:            0        ---        ---        ---          0

static_bgp_routes Static   default_routes_table up     06:58:30
  Preference:     200
  Input filter:   ACCEPT
  Output filter:  REJECT
  Routes:         1 imported, 0 exported, 1 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              1          0          0          0          1
    Import withdraws:            0          0        ---          0          0
    Export updates:              0          0          0        ---          0
    Export withdraws:            0        ---        ---        ---          0

bfd1     BFD      master   up     06:58:30
  Preference:     0
  Input filter:   ACCEPT
  Output filter:  REJECT
  Routes:         0 imported, 0 exported, 0 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              0          0          0          0          0
    Import withdraws:            0          0        ---          0          0
    Export updates:              0          0          0        ---          0
    Export withdraws:            0        ---        ---        ---          0

worker_10_176_3_169 BGP      default_routes_table up     06:59:16    Established
  Preference:     100
  Input filter:   ACCEPT
  Output filter:  ACCEPT
  Routes:         0 imported, 1 exported, 0 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              0          0          0          0          0
    Import withdraws:            0          0        ---          0          0
    Export updates:              1          0          0        ---          1
    Export withdraws:            0        ---        ---        ---          0
  BGP state:          Established
    Neighbor address: 10.176.3.169
    Neighbor AS:      64515
    Neighbor ID:      10.176.3.169
    Neighbor caps:    refresh enhanced-refresh restart-able llgr-aware AS4
    Session:          internal AS4
    Source address:   10.176.3.156
    Hold timer:       178/240
    Keepalive timer:  78/80

worker_10_176_3_138 BGP      default_routes_table up     06:59:44    Established
  Preference:     100
  Input filter:   ACCEPT
  Output filter:  ACCEPT
  Routes:         0 imported, 1 exported, 0 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              0          0          0          0          0
    Import withdraws:            0          0        ---          0          0
    Export updates:              1          0          0        ---          1
    Export withdraws:            0        ---        ---        ---          0
  BGP state:          Established
    Neighbor address: 10.176.3.138
    Neighbor AS:      64515
    Neighbor ID:      10.176.3.138
    Neighbor caps:    refresh enhanced-refresh restart-able llgr-aware AS4
    Session:          internal AS4
    Source address:   10.176.3.156
    Hold timer:       134/240
    Keepalive timer:  15/80
```
The `worker_<IP>` elements are the important lines. It shows which workers are discovered by the gateway. 
Gateways must `Export updates` to the workers. Expected status is `Received and accepted`.

Result when the pod is running on a compute/edge worker node:
```
kubectl exec -it -n kube-system ibm-gateway-controller-<pod_id> -- birdc show protocols all
BIRD v1.0.0+birdv1.6.5 ready.
name     proto    table    state  since       info
device1  Device   master   up     06:59:17
  Preference:     240
  Input filter:   ACCEPT
  Output filter:  REJECT
  Routes:         0 imported, 0 exported, 0 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              0          0          0          0          0
    Import withdraws:            0          0        ---          0          0
    Export updates:              0          0          0        ---          0
    Export withdraws:            0        ---        ---        ---          0

kernel1  Kernel   default_routes_table up     06:59:17
  Preference:     10
  Input filter:   ACCEPT
  Output filter:  ACCEPT
  Routes:         1 imported, 1 exported, 1 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              1          0          0          0          1
    Import withdraws:            0          0        ---          0          0
    Export updates:              2          1          0        ---          1
    Export withdraws:            0        ---        ---        ---          0

bfd1     BFD      master   up     06:59:17
  Preference:     0
  Input filter:   ACCEPT
  Output filter:  REJECT
  Routes:         0 imported, 0 exported, 0 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              0          0          0          0          0
    Import withdraws:            0          0        ---          0          0
    Export updates:              0          0          0        ---          0
    Export withdraws:            0        ---        ---        ---          0

gateway_10_176_3_156 BGP      default_routes_table up     06:59:18    Established
  Preference:     100
  Input filter:   ACCEPT
  Output filter:  REJECT
  Routes:         1 imported, 0 exported, 1 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              1          0          0          0          1
    Import withdraws:            0          0        ---          0          0
    Export updates:              2          1          1        ---          0
    Export withdraws:            0        ---        ---        ---          0
  BGP state:          Established
    Neighbor address: 10.176.3.156
    Neighbor AS:      64515
    Neighbor ID:      10.176.3.156
    Neighbor caps:    refresh enhanced-refresh restart-able llgr-aware AS4
    Session:          internal AS4
    Source address:   10.176.3.169
    Hold timer:       176/240
    Keepalive timer:  46/80

gateway_10_176_3_171 BGP      default_routes_table up     06:59:18    Established
  Preference:     100
  Input filter:   ACCEPT
  Output filter:  REJECT
  Routes:         1 imported, 0 exported, 0 preferred
  Route change stats:     received   rejected   filtered    ignored   accepted
    Import updates:              1          0          0          0          1
    Import withdraws:            0          0        ---          0          0
    Export updates:              2          1          1        ---          0
    Export withdraws:            0        ---        ---        ---          0
  BGP state:          Established
    Neighbor address: 10.176.3.171
    Neighbor AS:      64515
    Neighbor ID:      10.176.3.171
    Neighbor caps:    refresh enhanced-refresh restart-able llgr-aware AS4
    Session:          internal AS4
    Source address:   10.176.3.169
    Hold timer:       190/240
    Keepalive timer:  61/80
```
The `gateway_<IP>` elements are the important lines. It shows which gateways are exporting routes to the worker. 
Workers must `Import updates` from the gateways.
Expected status is `Received and accepted`.

Based on these printouts, it is possible decide on what level we have the problem: gatewayController application, BIRD client, Kubernetes API.
In case of any problem, always save the logs with:  
`kubectl logs -n kube-system ibm-gateway-controller-<pod_id>`

Then if no better idea, try to restart the pod, use the following command:  
`kubectl delete pod -n kube-system bm-gateway-controller-<pod_id>`
 
Once the new one is started, check again the status of the commands above.
If unable to resolve, see the escalation paths, but please always include these logs.

#### Time to escalate

If the previous actions do not resolve the load balancer service connection problem, see the escalation paths.

## Escalation Policy

If unable to resolve problems with a gateway enabled cluster, involve the `armada-network` squad:

- Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
- Slack channels:
  - [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  - [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev)
  - [#conductors](https://ibm-argonauts.slack.com/messages/conductors)
- GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

- [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
- [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
