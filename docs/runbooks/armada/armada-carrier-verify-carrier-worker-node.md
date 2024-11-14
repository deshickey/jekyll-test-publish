---
layout: default
description: Verifying a Carrier worker node
title: armada-carrier - Verifying the health of a worker node
service: armada-carrier
runbook-name: "armada-carrier - Verifying a Carrier worker node"
tags: alchemy, armada-carrier, carrier, master, worker
link: /armada/armada-carrier-verify-carrier-worker-node.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to easily and simply do a once-over on a worker node to verify that it is in a good working state.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

For quick view of any failed services:
~~~
> sudo systemctl list-units --state=failed
~~~

Generally, there are four services you should look for on a worker node to verify it's health:

* kubelet
* kube-proxy
* docker
* calico-node (runs in a pod so is checked differently)

The first three services above are managed by [systemd](https://en.wikipedia.org/wiki/Systemd) and their logs are placed in `journalctl`.  These services will be checked first, and then in a different section below instructions will be provided to check calico-node.

### Check Systemd Service Statuses

From the worker node, issue the following commands:

Note, these examples use `kubelet` as the target service:

~~~
armada@prod-dal10-carrier1-worker-02:~$ service kubelet status
● kubelet.service - Kubernetes Kubelet
   Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2017-05-09 17:33:21 UTC; 2 weeks 2 days ago
     Docs: https://github.com/kubernetes/kubernetes
 Main PID: 1338 (hyperkube)
    Tasks: 9661
   Memory: 175.2M
      CPU: 4w 2d 6h 34min 5.122s
   CGroup: /system.slice/kubelet.service
           ├─1338 /usr/local/bin/hyperkube kubelet --api-servers=https://10.176.31.244:443 --allow-privileged=true --cloud-provider=ibm --cloud-config=/etc/kubernetes/
           └─3247 journalctl -k -f
~~~

The service should be in `active (running)` state.  You can run the above `service SERVICE_NAME status` for each of the three vital systemd services on the node.

If any of the services aren't found to be in `active (running)` state, please check their logs:

~~~
journalctl -fu kubelet
~~~

For more details on how to use journalctl in Armada, please use [this runbook](armada-carrier-view-systemd-logs.html).

If you cannot find anything noticeably/obviously "wrong" in the logs, feel free to try and restart each of these three services:

~~~
service kubelet restart
~~~

This should restart the service.  Please verify that it is running.

If this fails to bring the node back to a healthy state, please follow the runbook for [properly rebooting a worker node](armada-carrier-node-troubled.html#rebooting-worker-node).

### Check calico-node Pod Status

Run `kubectl get pods -n kube-system -l k8s-app=calico-node -o wide | grep <WORKER_IP>`

If calico-node is not at `2/2    Running` status, use the [Kubernetes Networking Calico Node Troubleshooting Runbook](./armada-network-calico-node-troubleshooting.html) to get it running again.

Once calico-node is running, if you are concerned about a worker node being able to contact other worker nodes in this cluster, you can ssh to the worker node, install calicoctl and the necessary certs and calicoctl.cfg file, and then run: `sudo calicoctl node status`

This will show output such as the following:

~~~
+----------------+-------------------+-------+------------+--------------------------------+
|  PEER ADDRESS  |     PEER TYPE     | STATE |   SINCE    |              INFO              |
+----------------+-------------------+-------+------------+--------------------------------+
| 10.176.215.15  | node-to-node mesh | up    | 2017-07-13 | Established                    |
| 10.176.215.31  | node-to-node mesh | up    | 2017-07-13 | Established                    |
| 10.176.215.58  | node-to-node mesh | up    | 2017-07-13 | Established                    |
| 10.177.182.216 | node-to-node mesh | start | 2017-07-17 | Connect Socket: Connection     |
|                |                   |       |            | closed                         |
| 10.176.215.8   | node-to-node mesh | up    | 2017-07-13 | Established                    |
| 10.177.182.183 | node-to-node mesh | up    | 2017-07-13 | Established                    |
+----------------+-------------------+-------+------------+--------------------------------+
~~~

If you see any peers that are not "Established" in the INFO section, there is a problem with calico-node on that given peer, or the two workers can not connect to each other.  For more information on troubleshooting calico-node, see the [Kubernetes Networking Calico Node Troubleshooting Runbook](./armada-network-calico-node-troubleshooting.html)

## Escalation Policy

### Unique case affecting one customer or cruisers

If this is a unique issue affecting one customer, please involve the `armada-carrier` squad via Slack [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) or [create an issue for armada-carrier](https://github.ibm.com/alchemy-containers/armada-carrier/issues/new) to track.

Snooze the pagerduty and pass to the next SRE shift at handover.

### Affecting multiple customers or cruisers

If this is a critical outage affecting multiple customers and cruiser/patrol masters, please escalate to the `armada-carrier` squad using the `Alchemy - Containers Tribe - armada-carrier` escalation policy in Pager Duty.  See the [escalation policy](armada_pagerduty_escalation_policies.html) document for details of the policy to escalate to.
