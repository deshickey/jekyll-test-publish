---
layout: default
description: How to deal with pods stuck in various 'bad' states.
title: armada-carrier - How to deal with pods stuck in various 'bad' states.
service: armada-carrier
runbook-name: "armada-carrier - How to deal with pods stuck in various 'bad' states."
tags: armada, kubernetes, runtime, unknown, terminating, error, wanda
link: /armada/armada-carrier-pods-in-bad-state.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with pods that are stuck in various 'bad' states.  These include pods that have been stuck in `Unknown`, `Terminating`, `Error`, etc state for a few days.

## Example alerts

None

## Investigation and Action

The first thing to do is to identify the busted node.  You could do this by running `kubectl get pods -o wide` or `kubectl describe pod`. The `STATUS` column is where you would see these various 'bad' states mentioned above.  Once the node is identified, follow the [runbook for recycling a node][runbook for recycling a node] for said node.

~~~
# kubectl get pods -o wide
NAME                       READY     STATUS    RESTARTS   AGE       IP               NODE
alpine-3835730047-pz60m    1/1       Running   0          2d        172.16.252.155   10.176.170.206
alpine2-1750440163-dtnkj   1/1       Running   0          2d        172.16.185.225   10.171.220.205
nginx-701339712-mmvh9      1/1       Running   0          2d        172.16.112.167   10.176.31.241
nginx2-2903152804-r52hj    1/1       Running   0          8d        172.16.242.156   10.176.31.230
~~~

~~~
# kubectl describe pod
Name:       alpine-3835730047-pz60m
Namespace:  default
Node:       10.176.170.206/10.176.170.206
Start Time: Wed, 19 Apr 2017 21:14:48 +0000
Labels:     pod-template-hash=3835730047
        run=alpine
Status:     Running
IP:     172.16.252.155
Controllers:    ReplicaSet/alpine-3835730047
Containers:
  alpine:
    Container ID:   docker://47411d805fad3e6ed9bd131711f4c935ec8b23834e6cf625cf1d59172a71696d
    Image:      alpine
    Image ID:       docker-pullable://alpine@sha256:58e1a1bb75db1b5a24a462dd5e2915277ea06438c3f105138f97eb53149673c4
    Port:       
    Args:
      sh
    State:      Running
      Started:      Wed, 19 Apr 2017 21:15:05 +0000
    Ready:      True
    Restart Count:  0
    Volume Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-hf35f (ro)
    Environment Variables:  <none>
Conditions:
  Type      Status
  Initialized   True
  Ready     True
  PodScheduled  True
Volumes:
  default-token-hf35f:
    Type:   Secret (a volume populated by a Secret)
    SecretName: default-token-hf35f
QoS Class:  BestEffort
Tolerations:    <none>
No events.
~~~


## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.

## Automation

None

## References
[runbook for recycling a node]: armada-carrier-node-troubled.html#rebooting-worker-node
