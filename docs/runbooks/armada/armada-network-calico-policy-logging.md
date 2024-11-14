---
layout: default
description: "Armada - Calico Policy Logging"
title: "Armada - Calico Policy Logging"
runbook-name: "Armada - Calico Policy Logging"
service: armada
tags: alchemy, armada, calico, policy, log, logging, packet, containers, kubernetes, kube, network
link: /armada/armada-network-calico-policy-logging.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

Calico policies provide a way to log packets that meet a certain criteria.  This information is written to syslog on the worker node that the packet is being sent to (if logging ingress traffic) or to syslog on the worker node the packet is being sent from (if logging egress traffic).  This runbook describes how to create a policy that will log certain packets, and how to get those logs.

## Detailed Information

In addition to specifying "allow" and "deny" rules in policies which specifying certain traffic to allow/deny, you can also specify a "log" rule and specify the traffic you want to log.  This puts a LOG rule in iptables (similar to DROP and ACCEPT).  These log messages go to syslog, and there is no way in calico to get them to go to anywhere else, but in syslog config on the local system we could probably send these messages to a special file if we wanted to.

### Limitations

  - There is no easy way to turn on logging of all packets rejected or dropped by calico
  - There is no way to log packets to something other than syslog

### SSH Access to Worker Nodes
To get ssh access to the worker nodes (in order to look at syslog on the workers, or to look at the iptables log rules that are generated), use one of the following links to instructions:

* [Worker Node Access To All Nodes via DaemonSet](https://github.ibm.com/alchemy-containers/armada/wiki/SSH-into-any-worker-node)
  * Creates one pod for each worker node, so use this with caution (i.e. if there are 150 worker nodes in the cluster, it creates 150 pods)
* [Cruiser Worker Access Runbook](./armada-cruiser-worker-access.html)
  * Provides access to one worker node

### Running calicoctl commands

The calicoctl commands listed below can be run in one of two ways:

1. Configure your local workstation to run calicoctl, and create the calicoctl.cfg file that points to your cruiser/patrol cluster.  Instructions for how to do that are here: [https://console.bluemix.net/docs/containers/cs_security.html#adding_network_policies](https://console.bluemix.net/docs/containers/cs_security.html#adding_network_policies)   Note that there is a different calicoctl client binary depending on if the cluster you are targeting is running calico v2 (kube 1.9 and earlier) or calico v3 (kube 1.10 and newer).  

1. Run kubx-calicoctl from the carrier master node and specify the clusterID as the first parameter.  This script takes care of getting the correct calicoctl client binary, config file, and certs.

NOTE: The following examples assume you have calicoctl and /etc/calico/calicoctl.cfg configured on your local workstation.
  - If you are using `kubx-calicoctl` on the carrier master, replace `calicoctl` with `kubx-calicoctl <clusterID>`
  - If you are using `calicoctl` on your workstation, but have `calicoctl.cfg` somewhere other than `/etc/calico/`, then add `--config <calicoctl_config_file>` to the end of the parameter list of the command

### Example policy to log ssh packets

Here is a command that includes a sample calico policy that logs ssh connections into a worker node:

 - Calico v2 command (for kube 1.9 and earlier clusters)

~~~
calicoctl apply -f - <<EOF
apiVersion: v1
kind: policy
metadata:
  name: log-ssh
spec:
  ingress:
  - action: log
    destination:
      ports:
      - 22
    protocol: tcp
    source: {}
  - action: log
    destination:
      ports:
      - 22
    protocol: udp
    source: {}
  order: 10
  selector: ibm.role in { 'worker_public' }
EOF
~~~

- Calico v3 command (for kube 1.10 and newer clusters)

~~~
calicoctl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: log-ssh
spec:
  ingress:
  - action: Log
    destination:
      ports:
      - 22
    protocol: TCP
    source: {}
  - action: Log
    destination:
      ports:
      - 22
    protocol: UDP
    source: {}
  order: 10
  selector: ibm.role in { 'worker_public' }
EOF
~~~

  - This is a host policy, meaning it applies to traffic to/from one or more interfaces on the host itself.  Specifically, each armada worker node gets a host endpoint created for its public inteface that specifies this ibm.role=worker_public label.  So this policy will be applied to all traffic going to/from each worker node's public IP.  It will NOT apply to traffic on the private IP.

  - This policy will log whenever a udp or tcp connection is attempted that comes IN (ingress) to the worker's public interface on port 22

  - The order is set to 10 (range can be from 1 - 2000).  I set this low to give it a high priority.  If this is set high, say 1900, then that means that other host policies are applied before it, and if one of those policies allows the traffic, then this policy (and any other lower priority policies) will NOT be applied, and the logging will not happen.

  - This is just an example.  Policies can be created that apply only to certain pods (using a different selector), and that log different traffic (using different destination ports/IPs, specifying source destination/ports, specifying different protocols, etc).  See the References section below for links to more general calico policy docs and tutorials.

Once this policy is applied, it can be viewed using:
 - Calico v2 command (for kube 1.9 and earlier clusters): `calicoctl get policy log-ssh -o yaml`
 - Calico v3 command (for kube 1.10 and newer clusters): `calicoctl get GlobalNetworkPolicy log-ssh -o yaml`

### Other Example policies

TODO: put a policy here that denies certain traffic to a specific pod, and also logs those denied packets

### Examples of syslog entries

Here is a syslog entry generated by our example log-ssh policy:

```Sep  5 14:34:40 cruiser1-worker-1 kernel: [158271.044316] calico-packet: IN=eth1 OUT= MAC=08:00:27:d5:4e:57:0a:00:27:00:00:00:08:00 SRC=192.168.10.1 DST=192.168.10.5 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=52866 DF PROTO=TCP SPT=42962 DPT=22 WINDOW=29200 RES=0x00 SYN URGP=0
```

Note the "calico-packet" prefix.  This is a good way to search or filter for just the calico packet logging


## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [Calico Architecture](https://docs.projectcalico.org/v3.1/reference/architecture/)
  * [Calico Policy Tutorial](https://docs.projectcalico.org/v3.1/getting-started/kubernetes/tutorials/advanced-policy)
  * [Calico Policy Documentation](https://docs.projectcalico.org/v3.1/reference/calicoctl/resources/networkpolicy)
  * [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network) - Slack channel (use this for questions about calico policy logging)
