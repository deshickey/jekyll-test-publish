---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Hints and tips for Conductors handling support tickets.
service: Conductors
title: Hints and tips for Conductors handling support tickets.
runbook-name: "Hints and tips for Conductors handling support tickets."
link: /conductors_support_tickets_hints_and_tips.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Content

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

---

## Overview

This runbook has many hints and tips for investigating IBM Cloud support tickets.


## Related Information

The following [runbook](./conductors_support_tickets.html) provides details of the process for handling support tickets.


## Detailed Information

The document is designed to assist SRE engineers investigate Armada Customer tickets.

This is not an exhaustive set of steps, but should be used as a reference point to help an SRE engineer dig into a customer problem before handing it over to a development squad.


## Detailed Procedure

The following should be considered when investigation customer tickets.

1.  Has all the relevant information been provided? If not, return the issue to DSET.
1.  Check [armada-xo](https://ibm-argonauts.slack.com/messages/G53AJ95TP) - some example calls.
~~~
@xo cluster <id>
@xo cluster.Worker <worker id>
~~~
xo will help provide a variety of information about a cruiser such as `carrier` they are located on, `worker node` details, whether it's a `paid for` cluster.

1.  Check activity / discussions in the following channels for the dates/times reported by the customer ticket (NB: You'll likely have to match this to dates in ServiceNow when the ticket was opened, or specific dates mentioned by the user)
  - `containers-cie` channel - Do any CIEs match what the user is reporting.
  - `Conductors` channel - Any reported issues here for that date?
  - `armada-users` channel - any similar problems reported that have been addressed?

1. Check the [IBM Cloud Container service docs](https://console.bluemix.net/docs/containers/container_index.html#container_index)
1. Check the useful links below
1. Check / Search for [runbooks](/docs/runbooks/runbooks.html)


### Steps to check a cluster

If a cluster id is provided, it is possible to check the PODs and services running in this cluster by following these steps.

**PLEASE NOTE!**  Great care should be taken when interacting with a cluster of an external user as this is potentially a live production environment you are dealing with.  Destructive commands such as `kubectl delete` should **NOT** be executed without agreement of the customer via the support ticket.

1.  Find the carrier where the cluster is located (`@xo cluster <id>` contains this information)
1.  Log onto the carrier master - eg: `ssh my_user_id@prod-dal10-carrier3-master-01`
1.  Use `kubx-kubectl <clusterid>` instead of `kubectl` to interact with the cluster. For example:
~~~
kubx-kubectl <clusterid> -n kube-system get pods
~~~
1.  kubectl commands can be issued against the cluster to debug the problem further.
1.  After you've finished, exit the session or unset KUBECONFIG in the session.  


### Useful Links

- [Bluemix Status page](https://status.ng.bluemix.net/)
- [Armada architecture information](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/architecture.md)
- [Docs home page](https://console.bluemix.net/docs/containers/container_index.html#container_index)
- [Debugging worker nodes](https://console.bluemix.net/docs/containers/cs_troubleshoot.html#debug_worker_nodes)
- Debugging cruiser issues
  - [permission issues when ordering](/docs/runbooks/cluster/cluster-squad-common-troubleshooting-issues.html#troubleshooting-permissions-and-credentials)
  - [worker provisioning, reload and deletion problems](/docs/runbooks/cluster/cluster-squad-common-troubleshooting-issues.html#troubleshooting-worker-statuses)


## Specifically Mentioned Issues

This section should be added to when ever we can.
It contains useful information shared by dev squads which can be provided to DSET to help provide further information about problems being experienced:


### Node Port issues

If a node port isn't working on a single worker node in the future, the following can be tried to further narrow down the possible causes:

1. See if the node port is working on other worker nodes. Also check if other nodeport services are working when contacted through this worker. Create a simple nginx deployment with one pod and a nodeport service, and try to curl that service to see if it is even simple node ports that have this problem. If the problem is only for the one worker IP, then there is something wrong that is specific to this node. One option is to restart the worker node, and if that doesn't work reload the worker node to see if that clears up the problem.
1.  Do a `kubectl describe service...` for this nodeport service several times, waiting 30 seconds between calls, to make sure that there are pods that are backing this service, and that those pods are healthy and staying up.
1.  Do a `kubectl get pods -n <namespace> -l <label=value> -o wide` several times, waiting 30 seconds between calls, to make sure that those pods are healthy and staying up.
1.  Get the logs from these pods, and do other app level debugging to verify that the pod is responding to requests appropriately (or that no requests are reaching the pod).
1.  If the problem is still occurring, restart the pods and verify they start up correctly
Go back to step 2 `(kubectl describe service...)` and make sure the new pods show up as backing this service.
1. If connections to your worker nodes, or between your worker nodes (possibly workers on different subnets) are managed by a Vyatta, check if there have been any vyatta config changes recently, or if workers have recently been added to this cluster that the vyatta isn't handling properly.
