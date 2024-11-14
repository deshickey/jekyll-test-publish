---
layout: default
title: armada-ops - Carrier Node Tainted With Node Eviction Parameter
type: Troubleshooting
runbook-name: "armada-ops - Carrier Node Tainted With Node Eviction Parameter"
description: "armada-ops - Carrier Node Tainted With Node Eviction Parameter"
service: armada
link: /armada/armada-ops-carrier-taint-runbook.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Carrier Node Tainted With Node Eviction Parameter

## Overview

This alert fires when a node in the carrier is tainted with a [Node Eviction Taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/#taint-based-evictions). These taints are applied to nodes that the Node controller deems unhealthy.
It will cause pods to schedule there but eventually evict off the node if the taint remains on the node for an extended period of time. This node needs to be diagnosed
if it is healthy or what the problem is that is causing the node to be tainted. If the node is healthy, the taint should be removed. If the node is not healthy, the node
should be cordoned while the conductors work on bringing the node to a healthy state.

| Alert_Situation | Info | Start |
|--
| `NodeTaintedWithUnschedulableTaint`| <node>  has a taint that will cause pods to get evicted after 5 minutes. | [actions-to-take](#investigation-and-action) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = <node>_evicttaint
 - alert_situation = <node>_evicttaint
 - service = armada-ops
 - severity = critical
 - node = <node>
 - key = <key>
~~~~


## Investigation and Action

In the alert labels section, there will be a label called `node` and a label called `key`. The `node` label will contain the IP of the node that has the taint applied to it and
the `key` label will have the taint that is applied to the node. The node should be examined if it is healthy

1) get on the carrier master this node belongs to and check to see if the node is in ready state (sub the node in the label in place of <node>).
The carrier can be found in the alert.

    ```
    NODE_NAME=<node>
    kubectl get node $NODE_NAME
    example) kubectl get node 10.130.231.186
             NAME             STATUS    ROLES     AGE       VERSION
             10.130.231.186   Ready     <none>    58d       v1.8.13-2+e478967b11e322
    ```

    - Also describe the node and look at the recent events.
    
        ```
        kubectl describe node $NODE_NAME
        ```
        
        - example
            
            ```
            kubectl describe node 10.130.231.186
            Name:               10.130.231.186
            Roles:              <none>
            Labels:             arch=amd64
                                beta.kubernetes.io/arch=amd64
                                beta.kubernetes.io/os=linux
                                failure-domain.beta.kubernetes.io/region=us-south
                                failure-domain.beta.kubernetes.io/zone=mex01
                                ibm-cloud.kubernetes.io/worker-version=1.8.13_1514
                                kubernetes.io/hostname=10.130.231.186
            Annotations:        node.alpha.kubernetes.io/ttl=0
                                volumes.kubernetes.io/controller-managed-attach-detach=true
            Taints:             <none>
            CreationTimestamp:  Thu, 24 May 2018 22:33:44 +0000
            Conditions:
              Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
              ----             ------  -----------------                 ------------------                ------                       -------
              OutOfDisk        False   Sun, 22 Jul 2018 22:08:46 +0000   Thu, 24 May 2018 22:33:44 +0000   KubeletHasSufficientDisk     kubelet has sufficient disk space available
              MemoryPressure   False   Sun, 22 Jul 2018 22:08:46 +0000   Tue, 10 Jul 2018 20:04:11 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
              DiskPressure     False   Sun, 22 Jul 2018 22:08:46 +0000   Tue, 10 Jul 2018 20:04:11 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
              Ready            True    Sun, 22 Jul 2018 22:08:46 +0000   Tue, 10 Jul 2018 21:29:29 +0000   KubeletReady                 kubelet is posting ready status
            Addresses:
              InternalIP:  10.130.231.186
              ExternalIP:  10.130.231.186
              Hostname:    10.130.231.186
            Capacity:
             cpu:     8
             memory:  32946384Ki
             pods:    110
            Allocatable:
             cpu:     8
             memory:  32434384Ki
             pods:    110
            System Info:
             Machine ID:                 030c5f4ae91c433aa8c2acb7bb0af021
             System UUID:                2C1F7D88-0EFC-FD1E-64CE-748EB11AC5DC
             Boot ID:                    98543554-c0c9-4d45-9c25-cbe8b6634bae
             Kernel Version:             4.9.0-6-amd64
             OS Image:                   Debian GNU/Linux 9 (stretch)
             Operating System:           linux
             Architecture:               amd64
             Container Runtime Version:  docker://18.3.1
             Kubelet Version:            v1.8.13-2+e478967b11e322
             Kube-Proxy Version:         v1.8.13-2+e478967b11e322
            ExternalID:                  10.130.231.186
            Non-terminated Pods:         (13 in total)
              Namespace                  Name                                                        CPU Requests  CPU Limits  Memory Requests  Memory Limits
              ---------                  ----                                                        ------------  ----------  ---------------  -------------
              ...
              kube-system                calico-node-ptcpt                                           250m (3%)     0 (0%)      0 (0%)           0 (0%)
              ...
            Allocated resources:
              (Total limits may be over 100 percent, i.e., overcommitted.)
              CPU Requests  CPU Limits  Memory Requests  Memory Limits
              ------------  ----------  ---------------  -------------
              900m (11%)    2 (25%)     4348Mi (13%)     6Gi (19%)
            Events:         <none>
            ```
    
    - If the node is `Ready` (Check conditions -> Ready = true)  and has `calico-node` running on it (look at the `Non-terminated Pods` section) the node is likely healthy. 

2) Check the nodes status in calico

    ```
    sudo su
    /opt/bin/calicoctl node status
    ```
    
    - example
    
        ```
        Calico process is running.
        
        IPv4 BGP status
        +---------------+-------------------+-------+------------+-------------+
        | PEER ADDRESS  |     PEER TYPE     | STATE |   SINCE    |    INFO     |
        +---------------+-------------------+-------+------------+-------------+
        | 10.140.28.148 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.136 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.151 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.153 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.142 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.186 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.157 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.185 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.164 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.158 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.172 | node-to-node mesh | up    | 2018-07-19 | Established |
        | 10.140.28.140 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.149 | node-to-node mesh | up    | 2018-07-02 | Established |
        | 10.140.28.170 | node-to-node mesh | up    | 2018-07-03 | Established |
        | 10.140.28.174 | node-to-node mesh | up    | 2018-07-03 | Established |
        +---------------+-------------------+-------+------------+-------------+
        
        IPv6 BGP status
        No IPv6 peers found.
        ```
        
    - Check the node IP that has the taint to ensure calico is healthy by checking the `STATE` field. If the worker node is up then the taint should be removed.

    - The taint needs to be removed since the node is healthy. (sub the key in the label in place of <key>). Note the `-` is a constant and is used to specify
    that the taint needs to be removed.
    
        ```
        TAINT_KEY=<key>
        kubectl taint node $NODE_NAME $TAINT_KEY-
        ```
        
        - example 
            
            ```
            kubectl taint node 10.130.231.197 node.alpha.kubernetes.io/unreachable-
            node "10.130.231.197" untainted
            ```
        
    - This alert should auto resolve once the taint is removed.

If the node is in a bad state, conductors need to take action to bring the node back to a good state. The best way to investigate is to
ssh into the node that is having the problem (IP is in the alert) and investigate. For more in depth debugging steps see the [verify carrier worker node runbook](./armada-carrier-verify-carrier-worker-node.html)


## Escalation Policy

Escalate the issue to the armada-ops squad as per their [escalation policy](./armada_pagerduty_escalation_policies.html)

