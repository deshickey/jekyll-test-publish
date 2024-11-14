---
layout: default
description: solution for node-restriction forbidden user
title: node-restriction - forbidden user
service: armada-carrier
runbook-name: "node-restriction - forbidden user"
tags: carrier, conductors, worker
link: /armada/node-restriction.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

We’ve enabled the NodeRestriction admission controller for improved cluster security. NodeRestriction admission plugin limits a kubelet to modify only its own Node API object, and Pod API objects that are bound to their node. More details [here](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#noderestriction)

## Detailed Information

On carrier worker nodes we have set default kubeconfig as restricted-kubelet-kubeconfig for increasing security by giving restricted permissions to the user `system:node:<nodeName>`, earlier it was set to kubelet-kubeconfig.
You can check current kubeconfig using
~~~~~
echo $KUBECONFIG

/etc/kubernetes/restricted-kubelet-kubeconfig
~~~~~

### Permission Failure

On worker nodes you may see permission errors while running kubectl commands as mentioned below:
~~~~~
kubectl get al -n kube-system | grep action

Error from server (Forbidden): correctiveactions.workerrecovery.stable is forbidden: User "system:node:10.131.16.97" cannot list resource "correctiveactions" in API group "workerrecovery.stable" in the namespace "kube-system"
~~~~~

### Solution

Any one action can be taken from below:
- Run the commands on master node
- On worker node, switch to root user
  ~~~~~
  sudo su -
  kubectl get al -n kube-system | grep action

  action-label-10.130.231.140   15m
  action-label-10.130.231.188   23h
  action-label-10.131.16.55     45h
  ~~~~~
- On worker node, use kubelet kubeconfig
  ~~~~~
  kubectl --kubeconfig /etc/kubernetes/kubelet-kubeconfig get al -n kube-system | grep action

  action-label-10.130.231.140   19m
  action-label-10.130.231.188   23h
  action-label-10.131.16.55     45h
  ~~~~~


## Escalation Policy
In case of further issues, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [armada-carrier](https://github.ibm.com/alchemy-containers/armada-carrier/issues/new) Github repository for later follow-up.
