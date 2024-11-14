---
layout: default
title: armada-network - Pod in ContainerCreating - error adding host side routes
type: Troubleshooting
runbook-name: "armada-network - Pod in ContainerCreating - error adding host side routes"
description: "armada-network - Pod in ContainerCreating - error adding host side routes"
service: armada
link: /armada/armada-network-pod-cant-get-IP.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

When pods are terminated unexpectedly (worker node crash, etc), calico data might not be cleaned up, resulting in an error trying to restart the pod.

## Example Alerts

When a pod is stuck in ContainerCreating state, doing a "describe pod" on that pod can show you the reason.  If the reason is old calico data that wasn't cleaned up properly, you will see something like the following:

~~~
$ kubectl describe pod -n <NAMESPACE> <POD_NAME>
...
Events:
  FirstSeen LastSeen Count  From                 SubObjectPath  Type        Reason      Message
  --------- -------- -----  ----                 -------------  --------	------		-------
  10s       10s      1      {default-scheduler } Normal         Scheduled	Successfully assigned <POD_NAME>
  to <WORKER_IP>
  7s        0s       3      {kubelet <WORKER_IP>}Warning        FailedSync	Error syncing pod, skipping:
  failed to "SetupNetwork" for "<POD_NAME>_<NAMESPACE>" with SetupNetworkError: "Failed to setup network for
  pod \"<POD_NAME>_<NAMESPACE>(<SOME_ID_HERE>)\" using network plugins \"cni\": error adding host side routes
  for interface: cali<INTERFACE_ID>, error: failed to add route file exists; Skipping pod"
~~~

## Investigation and Action

When this above error is seen, the fix is to manually remove the old calico "Workload Endpoint" that is associated with this pod

1. From the carrier master, run the following to get the necessary information (using the specific cali<INTERFACE_ID> from the error above):
   - For kube 1.9 or earlier (calico v2): `kubx-calicoctl <clusterID> get wep -o wide | grep cali<INTERFACE_ID>`

   - For kube 1.10 or newer (calico v3): `kubx-calicoctl <clusterID> get wep -o wide --all-namespaces | grep cali<INTERFACE_ID>`

1. Run the following using the values from the above get wep call:
   - For kube 1.9 or earlier (calico v2): `kubx-calicoctl <clusterID> delete --workload=<NAMESPACE>.<POD_NAME> --orchestrator=k8s --node=<NODE_NAME> wep <INTERFACE_NAME>`
     - `<NODE_NAME>` should match the NODE entry from the above `get wep` call, usually something like: *kube-dal12-cr301f4db223154e50be53d2cfd58b9019-w4.cloud.ibm*
     - `<INTERFACE_NAME>` should match the NAME entry from the above get wep call (*eth0* for non-baremetal worker nodes)
   - For kube 1.10 or newer (calico v3): `kubx-calicoctl <clusterID> delete wep -n <NAMESPACE> <WEP_NAME>`
     - `<WEP_NAME>` should match the NAME entry from the above `get wep` call, usually something like: *kube--dal12--cr301f4db223154e50be53d2cfd58b9019--w1.cloud.ibm-k8s-<POD_NAME>-eth0*


## Escalation Policy

If unable to resolve this problem, involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [Calico Architecture](https://docs.projectcalico.org/v3.1/reference/architecture/)
  * [Connecting Applications with Services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
  * [Calico bug report for this error](https://github.com/projectcalico/cni-plugin/issues/352)
  * [Calico PR to fix this error condition](https://github.com/projectcalico/cni-plugin/pull/358)
