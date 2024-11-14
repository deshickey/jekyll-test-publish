---
layout: default
description: "Armada - Satellite Network Information"
title: "Armada - Satellite Network Information"
runbook-name: "Armada - Satellite Network Information"
service: armada
tags: alchemy, armada, satellite, calico, network, location, vxlan, hostendpoint, coreos
link: /armada/armada-satellite-network-information.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

In order to use Satellite, a customer has to create at least one Satellite Location.  This Satellite Location is a cluster similar to our control plane Tugboats in that it hosts the customer's Satellite ROKS Cruiser cluster masters.  Old Satellite Locations run IKS, but newer Locations (that were deployed with `coreos-enabled`) run Openshift.


## Detailed Information

Satellite Location clusters and Satellite ROKS Cruiser clusters are very similar to regular IKS Tugboats and regular ROKS Cruiser clusters in terms of cluster networking, but there are some differences.  This runbook describes the similarities and differences.


## Satellite Location Cluster

A Satellite Location cluster acts as a Tugboat, but only for a single customer, and the workers for the Location cluster run where ever the customer provisions them (on-prem, in another cloud such as AWS, Azure, ...).  Location clusters are listed in etcd as being owned by a shared SRE account found here: https://github.ibm.com/alchemy-containers/armada-secure/blob/5df98b4cdd32fcf55f73e0b1e2223514cec440f8/secure/armada/us-south/armada-info.yaml#L67 , currently account e3feec44d9b8445690b354c493aa3e89.

### Satellite Location Cluster Masters

1. The master for the Location lives on a tugboat with `tugboat_purpose: CustomerWorkloadSatellite` or `tugboat_purpose: CustomerWorkloadSatelliteHypershift` (depending on whether they were deployed using Hypershift)
2. Older location masters runs the same IKS version as our own control plane Tugboats.
3. Hypershift deployed location masters run Openshift
3. Location clusters do have the "storage secret", which is created/updated by the network microservice
    - However the API Key in here is NOT for the IBM service account, it is an API key in the customer's account
    - Kodie added code here to do that:  https://github.ibm.com/alchemy-containers/armada-network-microservice/pull/1581/ and described it in this issue: https://github.ibm.com/alchemy-containers/satellite-planning/issues/420
    - The actual customer account for the Satellite Location can be found in the etcd data for the Location cluster, in the Cluster.MultishiftAccountID entry (accessible by a `xo cluster <Location-Cluster-ID> show=all`), see the `Example XO Output` below for details

4. The customer does NOT have k8s apiserver access to these Location clusters for the most part
    - customers can NOT restart pods, run the debug tool, get pod logs, list Calico policies, etc.  We need to do this if needed via GMI and the Calico leaked IP jenkins job (to run calicoctl commands)
    - customers can NOT do a cluster master refresh nor upgrade the master, this is managed by the SREs
    - master patch updates happen automatically along with all other clusters
    - master minor version upgrades are kicked off by SREs, at the same time they upgrade our carriers and tugboats


### Satellite Location Cluster Workers

1. Workers are NOT in IBM Cloud (or at least most aren't), the customer decides where to provision the workers
2. Workers communicate with the master over the worker's default network interface
    - This is the interface specified by the default route in the worker's routing table
    - This interface must have public connectivity in order to get to the master
    - See full worker network requirements in this doc: https://cloud.ibm.com/docs/satellite?topic=satellite-reqs-host-network


### Calico Configuration for Locations

1. Calico uses vxlan for encapsulation (not the typical IPinIP that we use for IKS/ROKS).  We set this because it is more reliable/standard than IPinIP since we don't have any control over the customer's worker to worker network.
2. Calico HostEndpoints (HEPs) are created for each location worker's default interface
    - they are labeled with: `ibm.role: satellite_controller_worker`
    - calico-extension gets the default interface name in order to create this HEP
3. We only add a single Calico Global Network Policy to Location clusters, allow-all-public-satellite, which allows all ingress and egress and targets the HEPs we create using the `ibm.role: satellite_controller_worker` label


### Example XO Output

1. `xo cluster <CLUSTERID>` will show something like:
    - DefaultProvider: upi
    - Datacenter: tor01
    - ActualDatacenterCluster: prod-tor01.carrier105
    - ServerURL: https://c105.ca-tor.satellite.cloud.ibm.com:32504
    - AccountID: e3feec44d9b8445690b354c493aa3e89  # IBM Satellite Production Account
    - MultishiftType: multishift_controller
    - MultishiftAccountID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # Customer's account number
    - MultishiftControllerID: null

2. `xo master <MASTERID>` will show the IKS or Openshift master BOM version being used


### Get-Master-Info Should Work

The https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/ Jenkins job should work on these location clusters just fine, since kubx-kubectl, kubx-calicoctl, ... should work.  The following might not work:

1. Getting Calico Mesh status under BIRD LOGS didn't work on the test I ran on a Satellite Location, I'm not sure why
2. When I ran GMI on `coreos-enabled` location ci08ncef08th481bp510, I didn't get any output for any of the calicoctl commands run for GMI (calicoctl get nodes, calicoctl get heps, ...), not sure why
    - See https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/116184/ for an example


## Satellite ROKS Cruiser Clusters

A Satellite ROKS Cruiser cluster is just a ROKS cluster where the master is running on the customer's Satellite Location cluster.  Also, the ROKS cluster workers are running wherever the customer wants (on-prem, in another cloud such as AWS, Azure, ...).   The benefit of this is that the customer has complete control over where the ROKS master and workers run.


### Satellite ROKS Cruiser Cluster Masters

Satellite ROKS Cruiser Cluster Masters are very similar to regular ROKS cruisers.  The differences are:

1. The master for this cluster runs on the customer's Location cluster.  So the master components run on Location workers that are either on-prem or on a cloud the customer chose, NOT on our IBM Cloud tugboats
2. These clusters do NOT have a "storage secret" updated by the network microservice.  Since the workers aren't in IBM Cloud there is no need for an IBM Cloud API Key.
3. The master is accessible/exposed via NodePort on the Satellite Location cluster
    - The master does not use a "LoadBalancer" since Location workers aren't in IBM Cloud
    - I believe a hostname for the Location is registered in DNS and resolves to a few of the location workers

Similar to a regular ROKS cluster, the customer does have kubectl (apiserver) access to this Satellite ROKS cruiser cluster, so they can run their workload.  I'm not sure if they can do a cluster master refresh or cluster upgrade the master.  They probably can, not sure if it is a slightly different API/CLI call though.  I'm also not sure about master patch updates, if they still happen automatically along with all other clusters.


### Satellite ROKS Cruiser Cluster Workers

1. Workers are NOT in IBM Cloud (or at least most aren't), the customer decides where to provision the workers.  This could be on-prem, in another cloud, etc.
2. Workers communicate with the master over the worker's default network interface
    - This is the interface specified by the default route in the worker's routing table
    - See full worker network requirements in this doc: https://cloud.ibm.com/docs/satellite?topic=satellite-reqs-host-network
3. ROKS Cruiser cluster worker names are the node host names (at least in the example I looked at) instead of the worker IP address as in regular clusters


### Calico Configuration for ROKS Cruisers

1. Calico uses vxlan for encapsulation (not the typical IPinIP that we use for IKS/ROKS).  We set this because it is more reliable/standard than IPinIP since we don't have any control over the customer's worker to worker network.
2. For old (non- `coreos-enabled`) ROKS Satellite Cruisers, no Calico HostEndpoints (HEPs) are created
3. For coreos-enabled ROKS Satellite Cruisers, Calico HostEndpoints (HEPs) are created, but they are different from what we do in standard ROKS clusters.  See https://cloud.ibm.com/docs/openshift?topic=openshift-satellite-network-customization for details
4. We do add the same default Calico Global Network Policy as regular ROKS clusters, but we shouldn't since they don't have any HostEndpoints to apply to so they do nothing.


### Example XO Output

1. `xo cluster <CLUSTERID> show=all` will show something like:
    - DefaultProvider: upi
    - Datacenter: upi
    - ActualDatacenterCluster: prod-tok02.carrier114 (this is the Satellite tugboat the Location cluster's master is running on)
    - ServerURL: https://k6b881a7a9e7d56aa7eee-6b64a6ccc9c596bf59a86625d8fa2202-c000.jp-tok.satellite.appdomain.cloud:30828   (none of this contains the cluster ID).  The port (30828 in this case) refers to the NodePort service created for the kube-apiserver in the Satellite Location cluster.  The hostname part is the ingress domain and should resolve to either one or more of the Satellite Location workers, or in some cases to a custom DNS entry (typically a VIP) that eventually routes to the node port service in the location.
    - MultishiftType: multishift_cruiser
    - MultishiftAccountID: 0bb9eaf903ea48c1a70a634b1df9c088  # Customer account number
    - MultishiftControllerID: ci08ncef08th481bp510  # Satellite Location this cluster master is on

2. `xo master <MASTERID>` will show the ROKS master BOM version being used


### Get-Master-Info Should Work

The https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/ Jenkins job should work on at least some of these Satellite ROKS Cruiser clusters, since kubx-kubectl, kubx-calicoctl, ... should work.  But if the ROKS Cruiser apiserver NodePort (on the Location cluster) isn't publicly accessible, then it might not work at all.  Also, the following might not work:

1. Getting Calico Mesh status under BIRD LOGS didn't work on the test I ran on a Satellite ROKS Cruiser, I'm not sure why
2. Getting Calico data also didn't work on the test I ran on a Satellite ROKS Cruiser, I'm not sure why
    - See https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/116241/ for an example


## References
  * [Satellite Host Requirements](https://cloud.ibm.com/docs/satellite?topic=satellite-host-reqs)
  * [Satellite Host Network](https://cloud.ibm.com/docs/satellite?topic=satellite-reqs-host-network)
  * [Satellite Host Troubleshooting Steps](https://ibm.biz/sat-host-debug)
  * [Satellite Error Messages](https://cloud.ibm.com/docs/satellite?topic=satellite-ts-locations-debug)
  * [Satellite MustGather](https://github.ibm.com/ACS-PaaS-Core/MustGathers/tree/master/Satellite)
