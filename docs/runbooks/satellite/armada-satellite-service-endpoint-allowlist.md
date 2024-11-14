---
layout: default
description: Satellite Network - Satellite Service Endpoint Allowlist Troubleshooting
title: Satellite Network - Satellite Service Endpoint Allowlist Troubleshooting
service: armada-network
runbook-name: "Satellite Network - Satellite Service Endpoint Allowlist Troubleshooting"
tags: alchemy, armada, network, satellite, location, deployment, subnet, endpoint, allowlist, 413
link: /satellite/armada-satellite-service-endpoint-allowlist.md
type: Troubleshooting
grand_parent: Armada Runbooks
parent: Satellite
---

Troubleshooting
{: .label .label-red}

## Overview

The main focus of the Satellite Service Endpoint Allowlist feature is to restrict the ingress traffic of the satellite location master service endpoints ( KubeAPI, OpenshiftAPI, Konnectivity, Ignition ) by adding Calico GlobalNetworkPolicies and GlobalNetworkSet resources.
It can be managed by the user, with `ibmcloud ks cluster master satellite-service-endpoint allowlist` CLI command group on per cluster level.
Mentionable Note: If the feature set to enable, by default it blocks every traffic including the satellite location infrastructure and cluster workers as well, so the CIDR should be added from where the satellite workers connect to the location (it could be the workers own public IPs, or a Gateway)

---

## Example alerts which would have brought you here

This is a general troubleshooting runbook and is not tied to any specific alerts

---

## Investigation and Action

### The feature cannot be enabled

This feature is supported only for Satellite cruiser clusters that are on CoreOS Enabled, and it must be enabled for every satellite cluster separately

* Check if the location [is Hypershift](#how-to-decide-if-a-location-is-hypershift-or-not) (CoreOS flag was set to enabled at the location creation)
* The satellite cluster id should be used at the cli command (not the location ID)

### ACL limit reached, cannot add new subnet to the allowlist

Error Message: _"Maximum allowed Satellite Service Endpoint ACL rules has been reached."_

By default 100 CIDRs can be added to a cluster's allowlist.

* Try to combine subnets in the allowlist and reduce their numbers (like avoid using /32 subnets)
  * The applied CIDRs can be checked by the user via the cli command `ibmcloud ks cluster master satellite-service-endpoint allowlist get -c <clusterID>`, or from the `armada-xo` app by getting the cluster config (`@xo cluster <sat-roks-cruiser-cluster-id> show=all`) and check the `ActualSatelliteACLList` field
* If the above solution is not rideable, then the cluster's limit can be raised in 100 steps up to 500. It could be done via a jenkins job based on user initiated support ticket. Run [this job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/build?delay=0sec) with the `set-satellite-acl-limit` operation and set the `SAT_ACL_LIMIT` to the wanted value. (OPS ticket is needed for running this job. [Click here for help](#how-to-create-ops-ticket-for-increase-satellite-acl-limit))
  * After the limit is raised the new CIDRs can be added.

### Location Action Needed, Satellite Cluster nodes not ready

As mentioned in the overview, the feature blocks every traffic to the location master service endpoints by default including the cluster worker nodes. The user's responsibility is to add all the cluster worker source address / subnet to the allowlist. Also make  sure that the correct CIDR has been added. If the nodes were connected to the location through a gateway then the gateway address should be added to the allowlist instead of the nodes address

What can be done:

* Check if the cluster nodes' addresses are in the allowlist. For this a new armada-xo command was created, `sat.acl.nodes-check`
  * Note: this only checks if the cluster nodes' addresses are in the allowlist, or not. If the nodes are behind a gateway than this check could be false positive.
* To test if the allowlist is the problem here, the user may disable the allowlist or add a wide range subnet (like 0.0.0.0/1 and 128.0.0.0/1), and check if the node become ready.
* Check if the Calico Policies are delivered correctly
  * Log into the location cluster and check. These should exist if the feature is enabled ([Example resource YAMLs in the Concept Doc](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/satellite-service-endpoint-restriction.md#solution-summary)):
    * Calico Hostendpoint resources for every real interfaces of every location worker.  
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get hostendpoints.crd.projectcalico.org` in the location cluster
        ```
        > kubectl get hostendpoints.crd.projectcalico.org 
        NAME                                              AGE
        calico-hostendpoint-node-<locationWorkerID1>-eth0   7h28m
        calico-hostendpoint-node-<locationWorkerID1>-eth1   7h28m
        calico-hostendpoint-node-<locationWorkerID2>-eth0   7h28m
        calico-hostendpoint-node-<locationWorkerID2>-eth1   7h28m
        calico-hostendpoint-node-<locationWorkerID3>-eth0   7h21m
        calico-hostendpoint-node-<locationWorkerID3>-eth1   7h21m
        ```
        </details>

    * Calico GlobalNetworkPolicy for every satellite cluster where the feature is enabled. The 4 nodeport services (KubeAPI, OpenAPI, Konnectivity, Ignition) port number should be in the GlobalNetworkPolicy. (these nodeports can be checked in the `master-<clusterID>` namespace)
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get globalnetworksets.crd.projectcalico.org` in the location cluster
        ```
        $> kubectl get globalnetworkpolicies.crd.projectcalico.org 
        NAME                                           AGE
        block-master-<clusterID>                       2s      <---- This is what we need
        default.allow-all-outbound                     8h
        default.allow-all-private-default              8h
        default.allow-all-public-satellite             8h
        default.allow-bigfix-port                      8h
        default.allow-icmp                             8h
        default.allow-local-ops-nodeexporter-traffic   8h
        default.allow-node-port-dnat                   8h
        default.allow-sys-mgmt                         8h
        default.allow-vrrp                             8h
        default.deny-ops-nodeexporter-traffic          8h
        ```
        </details>
    * Calico GlobalNetworkSet for every satellite cluster where the feature is enabled. All the CIDRs in the allowlist should be in this GlobalNetworkSet
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get globalnetworkpolicies.crd.projectcalico.org`
        ```
        $> kubectl get globalnetworksets.crd.projectcalico.org 
        NAME                              AGE
        <clusterID>-satellite-allowlist   4m38s
        ```
        </details>

  * If something is wrong in the above mentioned resources:
    * wait a bit. New CIDRs can take up to 5-10 min to be applied.
    * run [this jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/build?delay=0sec) with `fix-calico-resources-for-satellite` operation, which trigger the microservice to redeploy all the connected resources again.

### Satellite link not working/broken totally or just partially (1 of the workers)

As mentioned in the overview, when enabled without any CIDRs, the feature blocks every incoming connection to the location master service endpoints by default. The satellite link endpoint (named `openshift-api-<clusterID>`) connection is also an inbound connection so this is also blocked. The user's responsibility is to add all the location's workers to the allowlist.

What can be done:

* Check if the location's worker nodes' addresses are added to the allowlist.
* Check if the Calico Policies are delivered correctly
  * Log into the location cluster and check. These should exist if the feature is enabled ([Example resource YAMLs in the Concept Doc](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/satellite-service-endpoint-restriction.md#solution-summary)):
    * Calico Hostendpoint resources for every real interfaces of every location worker.  
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get hostendpoints.crd.projectcalico.org` in the location cluster
        ```
        > kubectl get hostendpoints.crd.projectcalico.org 
        NAME                                              AGE
        calico-hostendpoint-node-<locationWorkerID1>-eth0   7h28m
        calico-hostendpoint-node-<locationWorkerID1>-eth1   7h28m
        calico-hostendpoint-node-<locationWorkerID2>-eth0   7h28m
        calico-hostendpoint-node-<locationWorkerID2>-eth1   7h28m
        calico-hostendpoint-node-<locationWorkerID3>-eth0   7h21m
        calico-hostendpoint-node-<locationWorkerID3>-eth1   7h21m
        ```
        </details>

    * Calico GlobalNetworkPolicy for every satellite cluster where the feature is enabled. The 4 nodeport services (KubeAPI, OpenAPI, Konnectivity, Ignition) port number should be in the GlobalNetworkPolicy. (these nodeports can be checked in the `master-<clusterID>` namespace)
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get globalnetworksets.crd.projectcalico.org` in the location cluster
        ```
        $> kubectl get globalnetworkpolicies.crd.projectcalico.org 
        NAME                                           AGE
        block-master-<clusterID>                       2s      <---- This is what we need
        default.allow-all-outbound                     8h
        default.allow-all-private-default              8h
        default.allow-all-public-satellite             8h
        default.allow-bigfix-port                      8h
        default.allow-icmp                             8h
        default.allow-local-ops-nodeexporter-traffic   8h
        default.allow-node-port-dnat                   8h
        default.allow-sys-mgmt                         8h
        default.allow-vrrp                             8h
        default.deny-ops-nodeexporter-traffic          8h
        ```
        </details>
    * Calico GlobalNetworkSet for every satellite cluster where the feature is enabled. All the CIDRs in the allowlist should be in this GlobalNetworkSet
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get globalnetworkpolicies.crd.projectcalico.org`
        ```
        $> kubectl get globalnetworksets.crd.projectcalico.org 
        NAME                              AGE
        <clusterID>-satellite-allowlist   4m38s
        ```
        </details>

  * If something is wrong in the above mentioned resources:
    * wait a bit. New CIDRs can take up to 5-10 min to be applied.
    * run [this jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/build?delay=0sec) with `fix-calico-resources-for-satellite` operation, which trigger the microservice to redeploy all the connected resources again.

### Cluster services (Kubernetes API, Openshift API, etc) not reachable from an allowed source, or reachable but should not be

User should double check their source IP address(VPN, NAT, different computer).

* some "What is my IP" webpage, or like `curl ifconfig.me`
  
SRE can do:

* Ask the user to create a backup of the allowlist, and may try to disable the feature and try to access the location.
* Check if the subject source address is allowlisted. XO command `sat.acl.ip-check`
* Check if the Calico Policies are delivered correctly
  * Log into the location cluster and check. These should exist if the feature is enabled ([Example resource YAMLs in the Concept Doc](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/satellite-service-endpoint-restriction.md#solution-summary)):
    * Calico Hostendpoint resources for every real interfaces of every location worker.  
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get hostendpoints.crd.projectcalico.org` in the location cluster
        ```
        > kubectl get hostendpoints.crd.projectcalico.org 
        NAME                                              AGE
        calico-hostendpoint-node-<locationWorkerID1>-eth0   7h28m
        calico-hostendpoint-node-<locationWorkerID1>-eth1   7h28m
        calico-hostendpoint-node-<locationWorkerID2>-eth0   7h28m
        calico-hostendpoint-node-<locationWorkerID2>-eth1   7h28m
        calico-hostendpoint-node-<locationWorkerID3>-eth0   7h21m
        calico-hostendpoint-node-<locationWorkerID3>-eth1   7h21m
        ```
        </details>

    * Calico GlobalNetworkPolicy for every satellite cluster where the feature is enabled. The 4 nodeport services (KubeAPI, OpenAPI, Konnectivity, Ignition) port number should be in the GlobalNetworkPolicy. (these nodeports can be checked in the `master-<clusterID>` namespace)
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get globalnetworksets.crd.projectcalico.org` in the location cluster
        ```
        $> kubectl get globalnetworkpolicies.crd.projectcalico.org 
        NAME                                           AGE
        block-master-<clusterID>                       2s      <---- This is what we need
        default.allow-all-outbound                     8h
        default.allow-all-private-default              8h
        default.allow-all-public-satellite             8h
        default.allow-bigfix-port                      8h
        default.allow-icmp                             8h
        default.allow-local-ops-nodeexporter-traffic   8h
        default.allow-node-port-dnat                   8h
        default.allow-sys-mgmt                         8h
        default.allow-vrrp                             8h
        default.deny-ops-nodeexporter-traffic          8h
        ```
        </details>
    * Calico GlobalNetworkSet for every satellite cluster where the feature is enabled. All the CIDRs in the allowlist should be in this GlobalNetworkSet
        <details>
          <summary>Command & example output (click on me)</summary>

        call `kubectl get globalnetworkpolicies.crd.projectcalico.org`
        ```
        $> kubectl get globalnetworksets.crd.projectcalico.org 
        NAME                              AGE
        <clusterID>-satellite-allowlist   4m38s
        ```
        </details>

  * If something is wrong in the above mentioned resources:
    * wait a bit. New CIDRs can take up to 5 min to be applied.
    * run [this jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/build?delay=0sec) with `fix-calico-resources-for-satellite` operation, which trigger the microservice to redeploy all the connected resources again.

### Newly added / removed allowlist are not working ( also enable/disable command )

Every change in the allowlist may take 5-10 minutes to be applied
If it is not effective even later:

* Check location master health ( Cluster updater deploys the resources for the feature )
* Check location cluster healthy (XO `cluster` command)
* Check satellite cruiser healthy (XO `cluster` command)

Resource will be deployed only if the location cluster and satellite cruiser are healthy

---

## How to create OPS ticket for increase Satellite ACL limit

1. Depending on the cluster environment, raise a train request either in the `#cfs-prod-trains` or `#cfs-stage-trains` Slack channel by copying in the following message (filling in the `###ENVIRONMENT###` and `###CLUSTERIDS###` entries)
```
Squad: network
Title: Increase Satellite Service Endpoint ACL quota for custom satellite location cruiser
Environment: ###ENVIRONMENT###
Details: |
  Increase Satellite Service Endpoint ACL quota for custom satellite location cruiser
  for ###CLUSTERIDS### by running this jenkins job:
  https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/
Risk: low
Ops: true
PlannedStartTime: now
PlannedEndTime: now + 1h
BackoutPlan: re-run the jenkins job to fix issue
```
2. Wait for notification via the `@Fat-Controller` slack app that your train has been approved, then use a Slack DM with the `@Fat-Controller` to start the train
3. Go to the [armada-network-private-service-endpoint-operations](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/) Jenkins job and set the following parameters:
    - Region: customer's cluster region
    - Operation: `set-satellite-acl-limit`
    - Cluster ID: customer's location cruiser cluster ID
    - SAT ACL Limit: whatever the customer requests (max of 500)
    - Operation Type: `write`
    - Ops Train Ticket ID: the train ID from step 2
4. Run the job and verify that it passes
5. Repeat steps 3 and 4 for any other clusters in that region
6. Use the `@Fat-Controller` app to complete the train.
---

## How to decide if a location is Hypershift or not?

The easiest way as of now to decide if a location is Hypershift is to check it's workerpools. If the location has a workerpool where the Operating System is RHCOS, then it is a Hypershift location
Steps:
1. Get the location cluster's workerPools
    - `@xo cluster <locationClusterID>`
    - Find the worker pools in the xo output. `WorkerPoolIDs` field
2. Check if one of the worker pools Operating System is RHCOS.
    - `@xo workerPool <locationClusterID>/<workerPoolID>`
    - check the `OperatingSystem` field for RHCOS


## Escalation Policy

Once the initial investigation is performed

* Notify `satellite-network` squad `@satmesh-squad` on the slack channel with the corresponding GHE issue - [#armada-network](https://ibm-argonauts.slack.com/archives/armada-network).

## Reference

* Slack channels: [#armada-network](https://ibm-containers.slack.com/archives/armada-network)
* Satellite Service Endpoint Allowlist feature concept Doc: [ConceptDoc](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/satellite-service-endpoint-restriction.md)
* CLI doc: [ibmcloud kc cluster master satellite-service-endpoint allowlist]()
* Jenkins job: https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations
