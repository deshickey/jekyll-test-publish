---
layout: default
description: "[Troubleshooting] Armada - Load balancer service"
title: "[Troubleshooting] Armada - Load balancer service"
runbook-name: "[Troubleshooting] Armada - Load balancer service"
service: armada
tags: alchemy, armada, armada-lb, cloud provider, containers, ibm, kubernetes, kube, kubectl, load balancer, LoadBalancer, network, node port, NodePort, service
link: /armada/armada-network-load-balancer-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

The IBM Bluemix Container Service implements Kubernetes load balancer services (i.e. type `LoadBalancer`) via an `ibm`
cloud provider built into Kubernetes. When a user requests Kubernetes to create, update or delete a load balancer service,
Kubernetes invokes the `ibm` cloud provider to complete the request within the cloud. Unlike other Kubernetes cloud
providers (such as Google or Amazon), the IBM cloud provider does not implement its load balancer outside the Kubernetes
cluster (i.e. via a SoftLayer external load balancer). Instead, the load balancer is managed within the Kubernetes cluster
as a deployment running `keepalived` within the `ibm-system` namespace. As a result, the IBM cloud provider code runs on
carrier, cruiser and patrol nodes and may require information from a user's cluster in order to troubleshoot certain issues.

By using Kubernetes deployments to implement the load balancer services within a user's cluster, these services benefit from
Kubernetes' high availability and upgrade support for deployments. However, this also means that a user has authority to mess
with the load balancer service components.

![](./images/armada-network/load-balancer-network-flow.jpg)

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Limitations

Before troubleshooting, review any limitations for [IKS Classic and VPC clusters](https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_lb) and for [Openshift Clusters](https://cloud.ibm.com/docs/openshift?topic=openshift-cs_troubleshoot_lb)
for load balancer services. Also note that load balancer services are **not** supported in lite clusters. Node port services
(i.e. type `NodePort`) must be used instead. In addition, a user may have at most 255 load balancer services on the same VLAN
across all of their clusters.  Newer versions of the keepalived image support 1,020 load balancer services on the same VLAN.

## Investigation and Action

### Troubleshoot load balancer service creation

Start by troubleshooting load balancer service creation. Describe the service.  
`kubectl describe service`  
Look for the following in the output. If the following checks are okay then continue to the next troubleshooting section.

1. `Type` must be set to `LoadBalancer`. If not, then the user did not create a load balancer service.
2. `Endpoints` must reference the pods associated with the load balancer service. If no endpoints exist or the endpoint
   ports aren't correct, then the user did not properly associate the load balancer service with the Kubernetes resources
   (i.e. pod, replicaset, deployment, etc.) when the load balancer service was created. The user must delete and recreate
   the load balancer service with the correct information.
3. `LoadBalancer Ingress` must be set to the IP address for the load balancer service. If not set or missing then
   proceed with troubleshooting load balancer service creation.
4. If `Events` do not include an event with `Reason` `CreatedLoadBalancer` then proceed with troubleshooting load balancer
   service creation.

```
$ kubectl describe service myapp -n default
Name:                   myapp
Namespace:              default
Labels:                 run=myapp
Selector:               run=myapp
Type:                   LoadBalancer
IP:                     10.10.10.111
LoadBalancer Ingress:   192.168.10.37
Port:                   <unset> 80/TCP
NodePort:               <unset> 30967/TCP
Endpoints:              172.30.156.216:80,172.30.156.217:80
Session Affinity:       None
Events:
  FirstSeen     LastSeen        Count   From                    SubObjectPath   Type            Reason                  Message
  ---------     --------        -----   ----                    -------------   --------        ------                  -------
  22s           22s             1       {service-controller }                   Normal          CreatingLoadBalancer    Creating load balancer
  22s           22s             1       {service-controller }                   Normal          CreatedLoadBalancer     Created load balancer
```

Review all `Events` warning messages for the service to determine actions to take to resolve the problem.

* `Clusters with one node must use services of type NodePort`  
   Load balancer services are **not** supported in this cluster.
* `No cloud provider IPs are available to fulfill the load balancer service request. Add a portable subnet to the cluster and try again`  
   There are no cloud provider IP addresses available to fulfill the load balancer service request. By default (assuming no errors), only a small number of addresses are automatically provisioned to the Bluemix Infrastructure (SoftLayer) account for the cluster.
   The user must provision (additional) addresses at `control.softlayer.com` or use an available public or private subnet within their
   SoftLayer account that is on the cluster VLAN.  
   The user can view subnets  
   `ibmcloud ks subnets --provider <provider>`  
   and the user can add a subnet to the Kubernetes cluster  
   `ibmcloud ks cluster subnet add <cluster name or id> <subnet id>`  
   After the subnet has been added, the additional IP addresses should be available. Once available, the load balancer service should be created successfully within a few minutes. If the IP addresses do not become available then refer to the [armada cloud provider IP runbook](./armada-network-portable-subnet-config-misconfigured.html).
* `Requested cloud provider IP <cloud-provider-ip> is not available. The following cloud provider IPs are available: <available-cloud-provider-ips>`  
   The user specified an IP address that is not available when creating the load balancer service. The user must either use one of the available IP addresses in the message or allow the `ibm` cloud provider to select an available IP address.
* `No available nodes for load balancer services`  
   There are no nodes available to support load balancer services. List all available nodes.  
   `kubectl describe nodes`  
   If no nodes are found then the cluster deployment may have failed during node provisioning. If nodes are found then ensure that the `publicVLAN` and `privateVLAN` labels match the SoftLayer public and private VLAN IDs of the nodes.
* `Conflicting cloud provider IP service annotations were specified`  
   The service contains multiple IBM annotations `service.kubernetes.io/ibm-*`. The user must delete and recreate the service with a single IBM service annotation.
* `Value for service annotation service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type must be 'public' or 'private'`  
   The user must delete and recreate the service with a valid value for the `service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type` annotation.

If unable to resolve, see the [Escalation Policy](#escalation-policy).

### Troubleshoot load balancer service connection

Start by troubleshooting load balancer service creation. If the service was created successfully then proceed with this
troubleshooting section. If you suspect general networking problems, refer to the
[armada network troubleshooting runbook](./armada-network-initial-troubleshooting.html).
See the escalation paths if you are unable to resolve any of the problems encountered.

#### Check the application pods

Ensure that the user's application is running. Gather information from pod description and logs.  
`kubectl describe pod <pod name>`  
`kubectl logs <pod name>`  

Look for the following in the output:
1. `Status` must be `Running`. If not running, troubleshoot the problem before proceeding. Event messages may indicate why
   the pod isn't running.
2. `IP` must be set to the internal IP address for the pod. If not set, troubleshoot the problem before proceeding. Again,
   event messages may indicate why the pod doesn't have an internal IP address.
3. `Containers.<container>.Port` must be set to the port being used by the application running within the pod. If not correct
   or unset, the pod must be re-deployed with the correct port.
4. Ensure that the logs show the application is running. If not running, troubleshoot the application problem before
   proceeding.

```
$ kubectl describe pod myapp-3999250892-2nr8t
Name:           myapp-3999250892-2nr8t
Namespace:      default
Node:           192.168.10.4/192.168.10.4
Start Time:     Wed, 22 Mar 2017 15:48:52 +0000
Labels:         pod-template-hash=3999250892
                run=myapp
Status:         Running
IP:             172.30.156.217
Controllers:    ReplicaSet/myapp-3999250892
Containers:
  myapp:
    Container ID:       docker://fe99f61e4480dc7d1996aee4da6925184595ecbbd16f386a6f8c025c4dd8e964
    Image:              nginx
    Image ID:           docker-pullable://nginx@sha256:52a189e49c0c797cfc5cbfe578c68c225d160fb13a42954144b29af3fe4fe335
    Port:               80/TCP
    State:              Running
      Started:          Wed, 22 Mar 2017 15:48:55 +0000
    Ready:              True
    Restart Count:      0
    Volume Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-vwqh4 (ro)
    Environment Variables:      <none>
Conditions:
  Type          Status
  Initialized   True
  Ready         True
  PodScheduled  True
Volumes:
  default-token-vwqh4:
    Type:       Secret (a volume populated by a Secret)
    SecretName: default-token-vwqh4
QoS Class:      BestEffort
Tolerations:    <none>
No events.
$ kubectl logs myapp-3999250892-2nr8t
...
```

#### Check the Kubernetes network policies

Next, ensure that the `calico-kube-controllers` pod is `Running`.  Note that alico-kube-controllers pods are in the `kube-system` (IKS 1.28 or lower) or `calico-system` (IKS 1.29 and above) namespace for IKS, and in the `calico-system` namespace for ROKS.

Example for `kube-system` namespace:

```bash
$ kubectl get pod -n kube-system -o wide | grep -e calico.*controller -e NAME
NAME                                                              READY     STATUS    RESTARTS   AGE       IP               NODE
calico-kube-controllers-695d4db56f-vwsmz                          1/1       Running   0          1d        10.130.119.143   10.130.119.143
```

Example for `calico-system` namespace:

```bash
$ kubectl get pod -n calico-system -o wide | grep -e calico.*controller -e NAME
NAME                                       READY   STATUS    RESTARTS   AGE   IP               NODE           NOMINATED NODE   READINESS GATES
calico-kube-controllers-85c89dd878-qbphg   1/1     Running   0          13d   172.30.184.194   10.176.57.25   <none>           <none>
```

If `calico-kube-controllers` pod is not running, use the [Kubernetes Networking Calico Node Troubleshooting Runbook](./armada-network-calico-node-troubleshooting.html) to get it running again.

Users may apply [Kubernetes network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) to control
access to pods (for example: [Simple Policy Demo](https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/simple-policy)).

Determine if there is a network policy in place on the namespace of the pod(s) supporting the load balancer service.  
`kubectl get networkpolicy -o yaml -n <namespace> | tee /tmp/save-networkpolicy.yaml`  
Such policies may be blocking the connection. To test this, note the policy's current value and then remove it, run below command.  
`kubectl delete networkpolicy -n <namespace> <name>`  
_The policy can be added back by running_  
_`kubectl apply -f /tmp/save-networkpolicy.yaml`_  

#### Check the Calico network policies
In addition to Kubernetes network policies, users may modify the default Calico network policies for the cluster. In particular, the cluster is required to have the `allow-node-port-dnat` policy in order to support Kubernetes services.  Check that this policy is in place and has not been modified by running the following command from the carrier master:  
  - Calico v2 command (for kube 1.9 and earlier clusters):  
  `kubx-calicoctl <clusterID> get policy allow-node-port-dnat -o yaml`
  - Calico v3 command (for kube 1.10 and newer clusters):  
  `kubx-calicoctl <clusterID> get GlobalNetworkPolicy allow-node-port-dnat -o yaml`

The spec part of the policy should look similar to this:
~~~
spec:
  ingress:
  - action: Allow
    destination:
      nets:
      - 172.30.0.0/16
    source: {}
  order: 1500
  selector: ibm.role == 'worker_public'
  types:
  - Ingress
~~~

Also, clusters may have `preDNAT` host policies that control access to Kubernetes `NodePort` and `LoadBalancer` services. For example:  
`calicoctl get policy -o yaml | grep "preDNAT: true"`  

Use the following commands from the carrier master to check for preDNAT policies:
 - Calico v2 command (for kube 1.9 and earlier clusters):  
 `kubx-calicoctl <clusterID> get policy -o yaml | grep "preDNAT: true" -B 20`
 - Calico v3 command (for kube 1.10 and newer clusters):  
 `kubx-calicoctl <clusterID> get GlobalNetworkPolicy -o yaml | grep "preDNAT: true" -B 20`

Such policies enable the cluster administrator to deny access
to the public node port(s) of a private `LoadBalancer` service. They also enable whitelisting access to `NodePort` and `LoadBalancer`
services.  If there are preDNAT policies in place they may be preventing the load balancer from working as expected.  To troubleshoot, the customer should either delete the policies and try the scenario again, or delete the policies and replace them with policies that use the "Log" action instead of the "Deny" action.  Packets that would have been denies will then just be logged with a `calico-packet` prefix in `/var/log/syslog` on the worker nodes.

See Network policies for worker nodes in IBM Bluemix Container Service for [IKS Clusters](https://cloud.ibm.com/docs/containers?topic=containers-network_policies) and for [Openshift Clusters](https://cloud.ibm.com/docs/openshift?topic=openshift-network_policies).

If any of these steps don't work, please ask the customer to run the [IKS Diagnostics and Debug Tool](https://cloud.ibm.com/docs/openshift?topic=openshift-cs_troubleshoot#debug_utility) and run the network tests for the cluster and export the logs and see what tests are failing and provide the logs to the network team.

#### Check the service node port

Kubernetes allocates node ports for load balancer services. As a result, a duplicate node port will cause a load balancer service connection fail. Check for each of the load balancer's node ports.  
`kubectl get services --all-namespaces -o yaml | grep nodePort | grep <lb-node-port> | wc -l`  
If the result is greater than 1 then a duplicate node port has been allocated. The user must delete and recreate the load balancer service.

#### Check the service resources

Describe the service and describe the cloud load balancer deployment and review all `Events` warning messages to determine if any actions can be taken to resolve the problem. Run following commands:  
`kubectl describe service`  
`kubectl describe deployment -n ibm-system ibm-cloud-provider-ip-<loadbalancer ingress ip>`  

* `Cloud load balancer deployment not found`: There was a problem with the cloud load balancer deployment. The user must delete
  and recreate the load balancer service. If still available, the user can request the same cloud provider IP when recreating
  the service.
* `Cloud load balancer deployment not available`: The cloud load balancer deployment does not have at least 1 available replica. Ensure that the deployment has 2 desired replicas. If not, then scale up the deployment.  
   `kubectl scale deployment`  
   Also, ensure that the cluster nodes are available for scheduling pods.  
   `kubectl describe nodes`  

If no pods have become the master then it's possible that there is a subnet conflict between clusters.  
`kubectl get cm ibm-cloud-provider-vlan-ip-config -n kube-system -o yaml`  
_**Note:** You may only/also find the config map in the `ibm-system` namespace on older clusters._  

The data for this config map is in JSON format and contains a list of subnets that are available for use by load balancer services. It's possible that one or more of these subnets have been accidentally deleted by the user and bound to a new cluster. Run the following command to ensure that all of the
subnets in the config map still exist and are bound to the cluster.  
`ibmcloud ks subnets --provider <provider>`  

If any of the subnets have been deleted or removed from the cluster
then contact the conductors to determine if the subnets can be restored and added back to the cluster.  
`ibmcloud ks cluster subnet add --cluster <cluster> --subnet-id <subnet id>`  

Next, determine if the load balancer service has `spec.loadBalancerSourceRanges` or `metadata.annotations` set.  
`kubectl get service -o yaml`  

If `spec.loadBalancerSourceRanges` is set then incoming connections to the load balancer service must come from a client in the allowed load balancer source ranges. If `metadata.annotations` includes `service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type` set to `private` or `service.kubernetes.io/ibm-ingress-controller-private` set to any value, or if `kubectl get nodes -l publicVLAN` doesn't return any nodes then the load balancer service is using a private IP address. As a result, incoming connections to the load balancer service must come from a client that has access to the cluster's private network.

Now attempt to `ping` and `nc` or `curl` the load balancer service using its `LoadBalancer Ingress` IP address and `Port`. If the
`ping` works but the `nc` or `curl` fails then ensure that the user's application is working properly.

```
$ ping -c1 192.168.10.37
PING 192.168.10.37 (192.168.10.37): 56 data bytes
64 bytes from 192.168.10.37: icmp_seq=0 ttl=64 time=0.315 ms

--- 192.168.10.37 ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.315/0.315/0.315/0.000 ms
$ curl --connect-timeout 5 http://192.168.10.37:80/
...
$ nc -w 5 -v 192.168.10.37 80
...
```

#### Check the SoftLayer network

Since the load balancer service and supporting Kubernetes resources look good at this point, review
[Accessing a service in the cluster fails](https://console.ng.bluemix.net/docs/containers/cs_troubleshoot.html#cs_firewall)
for possible firewall issues. Also, determine if the cluster is protected by a SoftLayer Vyatta firewall. The firewall may be
blocking access to the service.

Finally, run `traceroute` against the `LoadBalancer Ingress` IP address. If the trace does not resolve then there may be SoftLayer
routing problems. Contact the conductors on their slack channel for assistance.

```
$ traceroute 192.168.10.37
traceroute to 192.168.10.37 (192.168.10.37), 64 hops max, 52 byte packets
...
 15  192.168.10.37 (192.168.10.37)  81.625 ms  76.210 ms  75.614 ms
```

#### Time to escalate

If the previous actions do not resolve the load balancer service connection problem, see the escalation paths.

## Escalation Policy

If unable to resolve problems with a load balancer service, involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network),
    [#conductors](https://ibm-argonauts.slack.com/messages/conductors)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [Armada Load Balancer Design](https://github.ibm.com/alchemy-containers/armada-network/blob/master/architecture/load_balancer.md)
  * [Connecting Applications with Services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)
  * [Creating an External Load Balancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
