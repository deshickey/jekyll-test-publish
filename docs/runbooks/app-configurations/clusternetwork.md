---
layout: default
title: IBM Cloud App Configuration Cluster Network
type: Informational
runbook-name: "IBM Cloud App Configuration Cluster Network"
description: "IBM Cloud App Configuration Cluster Network"
service: App Configuration
tags: app-configurations
link: /app-configurations/clusternetwork.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview 
# Debugging Cluster Network 

As per the compliance we run our containers with minimal privileges and also with minimal tools.  "ping", "traceoute", or "mtr" are not available in the containers.  This section describes how these can be installed to check if the node level network is working fine. 

Note: In a normal condition these steps require CR as this is an update to the cluster enviornment. In a customer situation this atleast needs a GIT issue to track the changes.

## Detailed Information
## "traceroute" execution

Commands to be executed on the cluster

`kubectl debug node/<ip where the pod to be run> --image=icr.io/armada-master/alpine:latest -it`

This will directly give a exec to the node.  Now, execute `traceroute <node which should be pinged>` 

Sample execution script looks like this - 
```
jojustin@jojustin sbin % kubectl debug node/10.63.19.220 --image=icr.io/armada-master/alpine:latest -it
Creating debugging pod node-debugger-10.63.19.220-cfn6v with container debugger on node 10.63.19.220.
If you don't see a command prompt, try pressing enter.
/ # traceroute 10.195.8.163
traceroute to 10.195.8.163 (10.195.8.163), 30 hops max, 46 byte packets
 1  *  *  *
 2  *  *  *
 3^C
```

Refer [kubectl debug](https://cloud.ibm.com/docs/containers?topic=containers-cs_ssh_worker) for more details



## "mtr" (My Traceroute) execution
Commands to be executed on the cluster 

*Note: Preference is to execute this in "apprapp" namespace*

`kubectl run mtr --image=docker.io/lrottman/containerized-mtr:0.1 <Node ip which needs to be pinged>
`

For e.g. the above command for a specific ip could be 
`kubectl run mtr --image=docker.io/lrottman/containerized-mtr:0.1 10.195.8.162`

This will create a new pod 'mtr' in the namespace.  You can verify this by `kubectl get pods`

`kubectl logs -f mtr` will give the mtr output

Refer [containerized-mtr](https://gitlab.com/lyndell/containerized-mtr/) for more details.