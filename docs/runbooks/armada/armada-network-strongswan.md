---
layout: default
description: "[Troubleshooting] Armada - strongSwan VPN service"
title: "[Troubleshooting] Armada - strongSwan VPN service"
runbook-name: "[Troubleshooting] Armada - strongSwan VPN service"
service: armada
tags: alchemy, armada, armada-strongswan, containers, ibm, kubernetes, kube, kubectl, network, service, vpn, ipsec
link: /armada/armada-network-strongswan.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

The strongSwan VPN service can used to establish a site-to-site IPSec VPN connection between an IKS cluster and:

- another IKS cluster
  - running in same or different account
  - running in same or different data center
  - running in same or different region
  - running the same or different Kubernetes release version
- a SoftLater VSI or bare metal system running strongSwan RPMs or some other VPN endpoint software
- a Vyatta virtual appliance
- a Cisco ASA router (or some other hardware device) running in the a customer's on-premises data center
- an IBM Cloud Private Kubernetes cluster also running the strongSwan VPN helm chart

The strongSwan VPN service was created by the `armada-network` squad and it is a supported service, however it is not
a managed IKS service. The IKS team will never configure or deploy the strongSwan VPN onto a customer's IKS cluster.
The service is configured, started, stopped, and managed completely by the administrator of that specific IKS cluster.

**NOTE:** IBM is responsible for administrating the IKS cluster (on behalf of the customer) in the dedicated environment
and in some GBS/GTS accounts. In these cases, an IBMer may be involved in configuring and setting up the strongSwan VPN.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Limitations

Before troubleshooting, review the [strongSwan VPN service considerations](https://cloud.ibm.com/docs/containers?topic=containers-vpn#strongswan_limitations)
for a list of limitations.

## Investigation and Action

The majority of the issues that have been observed with the current strongSwan VPN service can be broken down into
the following categories:

1. Lack of understanding/clarity as to what is desired for the VPN (and what is allowed)
   - Which side is establishing the VPN connection?
   - What resources need to be accessed and by whom?
   - Wanting to configure strongSwan is a fashion that it does not support:
      - Wanting to use IPSec route based VPN
      - Wanting to allow non-cluster resources to use the VPN
      - Wanting to use something other than pre-shared keys for the authentication
2. Confusion on how to specify the helm chart configuration settings
   - There are currently 50 strongSwan helm chart config options. This number will continue to grow
   - Depending on the environment and what is desired, many fields are optional -OR- the default value can be used
   - If any of the required fields (based on the environment) are not correct, the VPN will not work correctly
   - Documentation of each field in included in the `values.yaml` file
3. Issues trying to get VPN connection to `ESTABLISHED` stage
   - Is IKEv1 or IKEv2 protocol being used by the remote VPN endpoint?  Both sides must match
   - The ike/esp protocols need to match what is configured on the remote VPN endpoint
   - The local and remote IDs values need to match what is configured on the remote VPN endpoint
   - Many of the legacy VPN implementations require that the public IPs of each side are used for the local and remote IDs
   - Incorrect value specified for the public IPs (remote.gateway or the load balancer IP)
   - Incorrect pre-shared key value specified in the helm configuration - does not match remote
   - Network firewalls are not configured to allow both: UDP/500 and UDP/4500 traffic. Have seen cases in which only UDP/500 is allowed
4. Issues with exposing the `local` and `remote` subnets
   - Incorrect local and remote subnets exposed based on what services need to be accessed
   - For example, trying to access a local/remote IP that is not exposed over the VPN
   - Local and remote subnets listed in helm config do not match what is configured in the remote VPN configuration
   - Incorrect NAT subnet values are specified
5. VPN connectivity issues (VPN stops working) after something has changed or been modified
   - Cluster worker node was rebooted
   - Cluster worker node added/removed from the cluster
   - Cluster worker node was tainted
   - Cluster worker node was updated to be an "Edge" node
   - SoftLayer maintenance - VPN connection went down, did not come back up

95+% of the issues with strongSwan VPN typically occur trying to get the VPN connection configured and operational.
The administrator of the cluster is required to review the external
[strongSwan VPN documentation](https://console.bluemix.net/docs/containers/cs_vpn.html#vpn)
and to configure strongSwan as necessary for their environment. There should NEVER be a Sev 1/2 issue opened if
the administrator can not correctly configure strongSwan VPN. If the administrator is unable to configure
strongSwan VPN using the available external documentation, then the external documentation should get updated.
Configuration questions regarding the strongSwn VPN settings can be directed to the `armada-network` squad
or the `#armada-strongswan` slack channel.

Additional troubleshooting can be found in the external documentation here:

- [Cannot establish VPN connectivity with the strongSwan Helm chart](https://console.bluemix.net/docs/containers/cs_troubleshoot_network.html#cs_vpn_fails)
- [Cannot install a new strongSwan Helm chart release](https://console.bluemix.net/docs/containers/cs_troubleshoot_network.html#cs_strongswan_release)

The fifth item in the above list deals with those cases in which the VPN connection was working fine, something was changed,
and now the VPN connectivity no longer works. Depending on the customer, this may be treated as a Sev 1/2 issue.
In most cases, these types of issues are the result of helm configuration settings not being updated after the
cluster has been modified. The rest of this runbook will focus on cluster and network changes that can break the
existing VPN connectivity.

### IKS worker node rebooted

IKS worker nodes will be performing one or more of the following functions:

- the node on which the VPN pod is running

  When the node is rebooted, VPN connectivity will be lost. Kubernetes will automatically reschedule the VPN pod
  to a new worker node in the cluster unless the `nodeSelector` option has been specified to restrict which nodes
  Kubernetes can use for the VPN pod. Depending on the setting of `nodeSelector` option and the nodes in the cluster,
  it is possible that the VPN pod will not be rescheduled until the rebooted worker node comes back up.

  When the VPN pod is rescheduled (onto the same node after the reboot OR onto a new node), the routes config map is
  updated and the strongswan-routes daemon set re-configures the routes on all of the worker nodes to send VPN traffic
  through the new VPN pod.

- the node on which the Load Balancer VIP (public IP for the VPN) is located

  If strongSwan is configured is "listening" mode (`ipsec.auto: add`), then the Load Balancer VIP is required. In these
  cases, VPN connectivity may be momentarily lost when the LB VIP is switched over to a different worker node. This
  switch of the VIP to a different worker node is fairly quick therefore the VPN outage should be brief (assuming that
  there is another worker node that is on the same public VLAN).

  If strongSwan is configured in "outbound connecting" mode (`ipsec.auto: start`), then the Load Balancer VIP is optional.
  If the public IP of the worker node is being used for the outbound connection, then the Load Balancer VIP is never used.
  If `loadBalancerIP` and `connectUsingLoadBalancerIP` are both configured, then the Load Balancer VIP will be used for
  the return traffic flow back to the cluster. Rebooting the worker node in this case is similar to rebooting the worker
  node when strongSwan is configured is "listening" mode.

- a cluster node that contains VPN routing information

  If the rebooted IKS worker node is NOT running the VPN pod or the Load Balancer VIP, then no VPN outage should occur.
  When the worker node is rebooted, the strongSwan remote subnet routes will be cleared. When the strongswan-routes
  daemon set is restarted, it will re-configure the remote subnet routes.

### IKS worker node added / removed

External troubleshooting information on what can happen when an IKS worker node is added/removed from the cluster:

- [strongSwan VPN connectivity fails after you add or delete worker nodes](https://console.bluemix.net/docs/containers/cs_troubleshoot_network.html#cs_vpn_fails_worker_add)

### IKS worker node tainted

When an IKS worker node is tainted:

- the strongSwan routes daemon will not be deployed onto that worker node. Since the route daemon is not deployed,
  the routes for the remote subnets will not be done. Without these routing table updates, all of the pods on that
  node will be unable to send/receive data over the VPN connection.

- the VPN strongSwan pod will not be deployed onto that worker node. If all of nodes in the cluster have been tainted,
  Kubernetes will be unable to schedule the VPN pod to any node.

The helm chart `tolerations` config option can be used to allow the strongSwan route daemon to be deployed onto a
tainted worker node. This option is only used by the route daemon. There is no helm chart config option to allow
the VPN pod to be deployed onto a tainted worker node.

### IKS "edge" node defined

If the administrator has defined any of the IKS workers to be an "edge" node, Kubernetes will force the load balancer VIP
to be placed on one of the edge nodes. As stated in the "edge" node documentation, the administrator must select at least
two workers nodes on each public VLAN to be used for the "edge" nodes. If this is not done, Kubernetes may not be able to
schedule the LB VIP pod onto an "edge" node (if there are no edge nodes defined for the public VLAN of the LB VIP).

The "edge" node documentation also describes how "taints" can be used to limit what pods can be scheduled/run on the edge
nodes. If the admin followed the "edge" node documentation and tainted the "edge" nodes, this will cause issues if the helm
chart has `enableSingleSourceIP: true` since this option results in `externalTrafficPolicy: "Local"` being set on the VPN service.
This options will force the LB VIP to be placed on the same node as the VPN pod. Since there is no way to add `tolerations` to the
VPN pod, the VPN pod will never be placed onto a tainted edge node. Since the LB VIP pod must be placed onto an edge node,
the the LB VIP pod will never be scheduled in this scenario.

The `enableSingleSourceIP` option defaults to `false`, but it MUST be set to `true` if there is an outgoing `ikev1` VPN
and both `loadBalancerIP` and `connectUsingLoadBalancerIP` are specified. Using `ikev1` and these settings is very common
configuration when connecting to on-premises hardware or a Vyatta since these options allow the public IP selected for
the outbound connection to be controlled.

Even if the "edge" nodes are not tainted, the `enableSingleSourceIP` can still cause issues with scheduling. Kubernetes
will always place the LB VIP pod onto an "edge" node, but if `externalTrafficPolicy: "Local"` is enabled on the service,
Kubernetes will also place the LB VIP pod onto the same node where the backend VPN pod is running.  If the backend
VPN pod is not running on an edge node, then the LB VIP pod can not be scheduled. Therefore, if you have "edge" nodes
defined -AND- you have `enableSingleSourceIP` enabled in the helm chart, then you should also configure the
`nodeSelector: dedicated=edge` in the helm configuration to force the VPN pod to be placed on an "edge" node.

### IKS cluster updated to MZR

Multi-zone region (MZR) clusters can lead to issues for the IKS load balancers since the load balancer is tied to a
specified public VLAN.  The public VLAN is only available in a single zone, therefore the load balancer is also limited
to a single zone. When the Kubernetes load balancer service is configured with `externalTrafficPolicy: "Local"`, the back end
service must also reside in that same zone.

When deploying strongSwan VPN in a MZR cluster, the `nodeSelector` option should be used to force the VPN pod to be
placed in the same region as the LB VIP. There are a few exceptions to this rule, but not many.

### SoftLayer maintenance done

Wherever SoftLayer does maintenance on the public or private routers, VPN connectivity into the cluster is usually lost.
VPN network connectivity is usually automatically restored once the maintenance window is done, however there have been
a few cases in which the cluster worker nodes had to be rebooted in order to pick up new routing information.  If the VPN
is configured in "listening" mode (`ipsec.auto: add`), then the VPN connection will need to be re-established by the
on-premises VPN endpoint.

## Troubleshooting - Collecting debug data

If the previous sections do not resolve the strongSwan VPN connectivity problem, debug data should be collected
from the customers/cluster. The items are listed in the order in which they have proven the most useful when debugging issues:

1. Ask the customer for the chart `config.yaml` which was used when the chart was installed
   - If the original `config.yaml` is not available, the customer can re-generate this information with `helm get values vpn`
2. Retrieve the cluster information
   - Cluster id / region/ data center
   - Public and private IP address of each of the worker nodes:  
   `ibmcloud ks workers --cluster <cluster>`
   - Public and private VLANs of each node + any node labels or taints that were applied:  
   `kubectl get nodes -L publicVLAN,privateVLAN,dedicated -o wide`  
   `kubectl get nodes -o yaml | grep -i taint`
3. Get list of services and strongSwan pods running in the cluster
   - Get list of services:  
   `kubectl get services --all-namespaces -o wide`
   - Get list of VPN pods:  
   `kubectl get pods --all-namespaces -l app=strongswan -o wide`
   - Get list of route pods:  
   `kubectl get pods --all-namespaces -l app=strongswan-routes -o wide`
4. Get logs from the VPN pod:  
`kubectl logs -n kube-system -l app=strongswan`
5. Get logs from the route pods:  
`kubectl logs -n kube-system -l app=strongswan-routes`
6. Get Kubernetes resource specifications
   - Get VPN pod deployment spec:  
   `kubectl get deploy --all-namespaces -l app=strongswan -o yaml`
   - Get VPN route daemon set spec:  
   `kubectl get ds --all-namespaces -l app=strongswan-routes -o yaml`
   - Get VPN config maps spec:  
   `kubectl get cm --all-namespaces -l app=strongswan -o yaml`
   - Get VPN service spec:  
   `kubectl get service --all-namespaces -l app=strongswan -o yaml`
7. Run the `vpnDebug` tool and get the results  
`kubectl exec -itn kube-system vpn-strongswan-xxxxxx -- vpnDebug`

## Escalation Policy

If unable to resolve problems with the strongSwan VPN service, involve the `armada-network` squad:

- Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
- Slack channels:
  - [#armada-strongswan](https://ibm-argonauts.slack.com/messages/armada-strongswan)
  - [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  - [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev)
  - [#conductors](https://ibm-argonauts.slack.com/messages/conductors)
- GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

- [IKS strongSwan external doc](https://console.bluemix.net/docs/containers/cs_vpn.html#vpn)
- [IKS strongSwan chart history](https://github.ibm.com/alchemy-containers/armada-strongswan/blob/master/helm/packages/change-history.md)
- [strongswan.org](https://strongswan.org/)
- [ipsec.conf](https://wiki.strongswan.org/projects/strongswan/wiki/IpsecConf)
- [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
