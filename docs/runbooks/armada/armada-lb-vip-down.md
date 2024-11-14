---
layout: default
title: Aramda Private/Public Loadbalancer VIP Down   
type: Troubleshooting
runbook-name: "armada-lb-vip-down"
description: "How to handle network monitoring alert for Aramda LB VIP down"
service: armada
tags: alchemy, armada, VIP, LB, private, public, down
link: /armada/armada-lb-vip-down.html
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Armada Private / Public LB VIP down alerts

## Overview

The alert is to monitor the network availability for our Satellite tugboats through checking Private & Public LB VIP.
The runbook contains steps to take when debugging LB VIP down failures. 

## Example alerts

Example:
```
labels:
      alert_situation: "lb_private_vip_reporting_down"
      alert_key: "armada-infra/lb_private_vip_reporting_down"
    annotations:
      summary: "LB private VIP {% raw %}{{ $labels.job }}{% endraw %} is reporting down for the past 25 minutes."
      description: "Armada LB private VIP {% raw %}{{ $labels.job }}{% endraw %} is reporting down for the past 25 minutes."

OR

labels:
      alert_situation: "lb_public_vip_reporting_down"
      alert_key: "armada-infra/lb_public_vip_reporting_down"
    annotations:
      summary: "LB prpublicivate VIP {% raw %}{{ $labels.job }}{% endraw %} is reporting down for the past 25 minutes."
      description: "Armada LB public VIP {% raw %}{{ $labels.job }}{% endraw %} is reporting down for the past 25 minutes."

```

## Investigation and Actions

1. Access the tugboat and check the VIP pods under `ibm-system` namespace

```
~$ kubectl get pod -n ibm-system
NAME                                                    READY   STATUS    RESTARTS   AGE
ibm-cloud-provider-ip-10-133-114-66-5b8b5d76d-bhzvx     1/1     Running   0          7d
ibm-cloud-provider-ip-10-133-114-66-5b8b5d76d-pb5jh     1/1     Running   0          6d22h
ibm-cloud-provider-ip-10-192-134-66-7b6b4b7c85-55phj    1/1     Running   0          6d18h
ibm-cloud-provider-ip-10-192-134-66-7b6b4b7c85-7kpgd    1/1     Running   0          6d20h
ibm-cloud-provider-ip-10-193-128-170-9d95dccc8-mns6l    1/1     Running   0          6d14h
ibm-cloud-provider-ip-10-193-128-170-9d95dccc8-qscr6    1/1     Running   0          6d16h
ibm-cloud-provider-ip-128-168-91-234-7b8cf869bf-gr4kq   1/1     Running   0          6d18h
ibm-cloud-provider-ip-128-168-91-234-7b8cf869bf-v4t68   1/1     Running   0          6d20h
ibm-cloud-provider-ip-161-202-153-178-b994bc57c-d954k   1/1     Running   0          6d22h
ibm-cloud-provider-ip-161-202-153-178-b994bc57c-l8m6v   1/1     Running   0          7d
ibm-cloud-provider-ip-165-192-85-66-6f8fdd9d7-lfsbd     1/1     Running   0          6d14h
ibm-cloud-provider-ip-165-192-85-66-6f8fdd9d7-x5ft4     1/1     Running   0          6d16h
```

2. If there is any pod is not in `Running` state, delete the pod to recycle. 

3. You can also try to delete the corresponding pods `ibm-cloud-provider-ip-<IP>-*` one by one or run `rollout restart` on the deployment to address the problematic LB. 

## Escalation Policy

Document all actions taken before escalating and provide a link to the documentation in the escalation. Escalate to the armada-infra squad.
[Alchemy - Containers Tribe - armada-infra](https://ibm.pagerduty.com/escalation_policies#PZRV4HB)
