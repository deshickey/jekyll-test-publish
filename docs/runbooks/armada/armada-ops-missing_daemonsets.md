---
layout: default
description: How to bring back daemonsets which are not running on all nodes
title: armada-ops - How to bring back daemonsets which are not running on all nodes
service: armada
runbook-name: "armada-ops - daemonsets which are not running on all nodes"
tags: armada, daemonsets
link: /armada/armada-ops-missing_daemonsets.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to bring back daemonsets which are not running on all nodes in the cluster.
We currently monitor the `node-exporter`, `docker-metrics-endpoint` and `fluentd` daemonsets.


## Example alerts

{% capture example_alert %}

Example PagerDuty titles:

- `#3475713: blumemix.containers-kubernetes.prod-dal10-carrier3.not_running_all_ibm-kube-fluentd_demonsets.us-south`
- `#3786454: blumemix.containers-kubernetes.prod-dal10-carrier3.not_running_all_node-exporter_demonsets.us-south`
- `#3786453: blumemix.containers-kubernetes.prod-dal10-carrier3.not_running_all_docker-metrics-endpoint_demonsets.us-south`
- `#3789453: blumemix.containers-kubernetes.prod-dal12-carrier2.node-exporter_daemonset_absent.us-south`

{% endcapture %}
{{ example_alert }}

## Automation

No automation is currently available

## Action to take

A common reason for daemonsets to not all be running.

- Node maybe out of disk space - an additional alert would be triggering for this scenario.
- Node has reached maximum number of pods

### Out of disk

This PD alert might be triggered at the same time as alerts for disk space.  If that is occurring, review this [filespace issues runbook](armada-carrier-node-filesystem-space.html)

This might auto-resolve if there have been disk space issues.
If after fixing disk issues the alert remains, go to the `Recovery plan` section.

### Daemonset is absent

If `node-exporter_daemonset_absent` triggers, it's suspected that the node-exporter daemonset has been removed.

To verify, run this command on the carrier-master-01 of the environment the alert is triggering from:

```
pcullen@prod-seo01-carrier4-master-01:~$ kubectl get ds -n monitoring
No resources found.
```

If the daemonset is absent, `No resources found` will be returned.

To resolve this, re-deploy the daemonset.

1.  Logon to [razeeflags](https://razeeflags.containers.cloud.ibm.com/alchemy-containers)
2.  Search for the carrier and check what armada-ops version is deployed in the monitoring namespace.
3.  Go to [Armada-ops build and deploy in jenkins](https://alchemy-containers-jenkins.swg-devops.com/view/Alchemy-Containers/job/Armada-Microservices/job/armada-ops/)
4.  Find the build number and click on promotion status for that build.
5.  Re-promote that build to the carrier where the daemonset is missing

*_Note:_* This may cause some additional alerts as it will re-deploy all armada-ops components (eg: alertmanager and prometheus)


### Daemonsets are missing

If this alert is firing on its own, then follow these steps to understand the issue.

1. Log onto the master node for the carrier environment mentioned. (eg. prod-dal10-carrier3)
1. Examine the daemonsets that are running:  

```
kubectl get ds --all-namespaces
NAMESPACE    NAME                      DESIRED   CURRENT   READY     NODE-SELECTOR   AGE
ibm-system   ibm-kube-fluentd          49        49        49        <none>          4d
monitoring   docker-metrics-endpoint   49        49        49        <none>          131d
monitoring   node-exporter             49        48        48        <none>          36m
```

Compare the 'desired' and 'current' values against the number of nodes present in that environment.
The following command returns the number of nodes in that env, `kubectl get nodes --no-headers=true | wc -l`

We've seen scenarios where:

- The desired number and current number match, but more nodes are present in the environment - this is a bug in kubernetes where when nodes are full of PODs they are not being correctly counted/reported.  If you observe this, go to the `Nodes are full / at maximum POD capacity` section.

- The current number is zero. The daemonsets are not running on any node. If you observe this, go to the `Daemonsets are not running on any node` section.

- The desired number matches the number of nodes in the environment, but the current and ready values do not, and the current number is large than zero. This means that node-exporter is not functioning / running, please follow below instructions to further debug.

1. Use the output from that command to check to see if any events have happened to that daemonset - For example: `kubectl describe ds node-exporter --namespace=monitoring`
1. Find out which node is not running a daemonset, eg, node-exporter: `kubectl get pods -n monitoring -o wide -l app=node-exporter|grep -iv running`. Cross referenece the node list for cordoned nodes, eg, `kubectl get nodes -a|grep SchedulingDisabled`
1. Describe the pod to see if any events have occurred - eg: `kubectl describe pods -n monitoring node-exporter-04hk8`
1. Grab the logs for the failing POD and investigate the errors - eg: `kubectl logs -n monitoring node-exporter-04hk8`

### Daemonsets are not running on any node

Examine the daemonsets, if the daemonsets are not running on any node as shown below, please follow the instructions in this section.   
Note: The desired number may match the number of nodes in the environment, or is zero.  

```
kubectl get ds -n monitoring
NAME            DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
node-exporter   39        0         0         0            0           <none>          72d
```

1. Log onto the master node for the carrier environment mentioned (eg. prod-dal10-carrier3-master-01), and find out the kube controller manager container.
1. Check if any error in the controller manager
`docker logs <kube-controller-manager-container-id>`
1. If we see the similar error as below, restart the controller manager container

~~~
 *E0306 07:20:29.673155       1 daemon_controller.go:263] monitoring/node-exporter failed with : failed to construct revisions of DaemonSet: controllerrevisions.apps “node-exporter-b5dbf585b” is forbidden: User “system:serviceaccount:kube-system:daemon-set-controller” cannot get controllerrevisions.apps in the namespace “monitoring”*
~~~

- Use command  `docker restart <kube-controller-manager-container-id>` to restart the container.

This should restart the daemonset set, but it sometimes causes the daemonset to be removed.  If this occurs, the `node-exporter_daemonset_absent` alert will fire.  Follow the steps above to resolve the absent daemonset issue.

### Nodes are full / at maximum POD capacity

- Nodes may be full - we saw issues in January 2018 when the workers in carrier3 in Amsterdam were rebooted for security updates.  Some worker nodes came back up, and were filled up with kubx-masters and / or armada PODS, but the daemonsets did not start here.  We then observed that `kubectl get ds --all-namespaces` output, returned that it was running the desired number of daemonsets, howerver, this was much lower than the actual number of PODs in the carrier, hence why we had this alert triggering.  

1. Log onto the master node for the carrier environment mentioned. (i.e. prod-dal10-carrier1)
1. Examine the daemonsets that are running: `kubectl get ds --all-namespaces` compare the 'current' to the number of nodes present `kubectl get nodes`
1. Use the output from that command to check to see if any events have happened to that daemonset `kubectl describe ds <daemonset_name> --namespace=<namespace>`
  1. For example: `kubectl describe ds node-exporter --namespace=monitoring`
1. Find out which nodes are not running the daemonset by comparing the list of nodes to the list of nodes running daemonsets:
~~~
MISSING_DS=node-exporter
MISSING_DS_NAMESPACE=monitoring
# First arg is all nodes running the DS
# Second arg is all nodes in cluster
diff  <(kubectl get pods -l app=$MISSING_DS -n $MISSING_DS_NAMESPACE -o json | jq -r '.items[] | .spec.nodeName' | sort ) <(kubectl get nodes -o json | jq -r '.items[]|.metadata.name' | sort)
~~~

To check whether a node is full, run this command against all nodes.
~~~
kubectl describe node <Node IP address>
~~~

Look for the output for Non-terminated PODs.

~~~
Non-terminated Pods:		(31 in total)
~~~

As of January 2018, there is a limit of 31 PODs per node.  Check the list of running PODs on machines which are full, and if the daemonsets are missing, then follow the recovery plan.


## Recovery plan

### If nodes are full

Begin by performing a reapply:
  * Setup kubectl to point to the right cluster - use the tool: at [carrier_cert_tool](https://github.ibm.com/alchemy-conductors/conductors-tools/tree/master/armada/carrier_cert_tool)
  * List the daemonsets with: `kubectl get ds -n monitoring` that will return something like:

If a node is full, perform these actions before re-applying the daemonsets

1. Log onto the node
1. use `armada-cordon-node` or igor-bot to cordon the node.
1. Query the PODs on that node using `kubectl describe node <ip address>`
1. It's likely that the node has a large number of kubx-masters on it - delete around 4 or 5 master PODs so they get re-scheduled onto another node using `kubectl delete pod -n kubx-masters <POD name from above describe output>`
1. Monitor output from `kubectl describe node <ip address>` and only proceed further when the `Non-terminated Pods:` size reduces.
1. Once there is POD space on the node, follow the reapply steps.
1. Use `armada-uncordon-node` or igor-bot to uncordon the node after you've finished.


###  Performing a reapply of the daemonset

NB: These steps use node-exporter as an example - this can be replaced with other daemonset names and the namespace they run in.

- Log into the carrier master for the environment where the alert is triggering (eg. prod-dal10-carrier3)

- Get the daemonset yml configuration with:

```
kubectl get ds -n monitoring node-exporter -o yaml > node-exporter.yaml
```

- Remove any status sections from the configuration file. In particular:

~~~  
    status:
      currentNumberScheduled:
      desiredNumberScheduled:
      numberMisscheduled:

    resourceVersion:
    selfLink:
    uid:

    annotations
~~~

For `node-exporter` It should look like:
[node-exporter-ds.yaml]({{ site.data.teams.armada-ops.link }}/blob/master/manifests/exporters/node-exporter-ds.yaml)
(any other daemonset should have the same structure).

- Remove the old daemonset definition but without removing the pods

~~~
kubectl delete ds -n <namespace> <daemonset-name> --cascade=false
~~~

- Reapply the daemonset using the following command, referencing the yml file you created and edited in an earlier step.

~~~
kubectl apply -f node-exporter.yaml
~~~

- Check that the daemonsets have been recreated on the nodes that were missing them by re-running the steps in the actions to take section.

## Escalation policy

For `node-exporter` - escalate to [{{ site.data.teams.armada-ops.escalate.name }}]({{ site.data.teams.armada-ops.escalate.link }})

For `fluentd` escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})
