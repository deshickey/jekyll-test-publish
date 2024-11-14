---
layout: default
description: How to run commands on Armada workers.
title: How to run commands on Armada workers.
service: armada-bootstrap
runbook-name: "How to run commands on Armada workers."
tags: alchemy, armada, worker, security, compliance, patch, nessus, qradar, health, check, healthcheck
link: /armada/armada-run-commands-on-workers.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes how the SRE team can safely and correctly gain access to an IKS/ROKS worker node.

## Detailed Information

## runon is no longer allowed

In the past, tools such as `runon` or creating priviledged contianers have been allowed.  The runon tool will pull in images from external sources which have not been scanned by the compliance tooling we have.  This breaks our `fs-cloud` compliance and therefore these tools are no longer allow to be used to assist debugging.


## The new approach

Instead of using runon, we can now make use of PODs already deployed to all of our IKS clusters.

Note: LinuxONE worker does not support `sos-nessus-agent`. Please refer [Armada - Access Cruiser Worker Nodes](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-cruiser-worker-access.html), access to the worker and then run commands instead.

### Pre-reqs

Use the `/notifysoc` tool in [#soc-notify slack channel](https://ibm-argonauts.slack.com/archives/C4BHPCX89) to inform the Security Operations Center team that you able about to exec into a node.
You need to provide the crn, clusterid, cluster name, POD details and business justification for this.

For example:

- CRN: `containers-kubernetes-tugboat`
- Clusterid: `brggn0qd0l9d4h0thrk0`
- Clustername: `prod-us-south-c-carrier113`
- POD: `sos-nessus-agent`
- Justification: `Execing to POD to debug issues on the worker nodes in this cluster`

### Accessing the node

All IKS clusters in our accounts should have `csutil` installed, and as a result we can make use of one of these PODs to connect to local worker nodes.

You can use the `sos-nessus-agent` pod and `nsenter`, to gain access to a `tugboat` worker node with the following commands:

```bash
export NODE=<node_ip>; kubectl -n ibm-services-system exec -it $(kubectl describe node $NODE|grep sos-nessus-agent|awk '{print $2}') -- nsenter -t 1 -m -u -i -n -p bash
```

For example:

```bash
[prod-dal10-carrier113] awtabner@prod-dal12-carrier2-worker-8025:~$ export NODE=10.208.88.227; kubectl -n ibm-services-system exec -it $(kubectl describe node $NODE|grep sos-nessus|awk '{print $2}') -- nsenter -t 1 -m -u -i -n -p bash
[root@kube-brggn0qd0l9d4h0thrk0-produssouth-custome-0000a569 /]# id
uid=0(root) gid=0(root) groups=0(root) context=system_u:system_r:unconfined_service_t:s0
[root@kube-brggn0qd0l9d4h0thrk0-produssouth-custome-0000a569 /]# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda2       24G  4.8G   18G  22% /
```

This example is when connected to a tugboat in US South using [invoke-tugboat](./armada-tugboats.html).  Similar can be achieved for other clusters SRE are responsible for (i.e. Standard IKS clusters in the Support Account)

## More Help
Speak to your squad lead for further guidance and information


