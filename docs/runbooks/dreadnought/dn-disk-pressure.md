---
layout: default
title: "Dreadnought - How to handle a disk pressure alert."
runbook-name: "How to handle a disk pressure alert."
description: "How to handle a disk pressure alert."
category: Dreadnought
service: dreadnought
tags: dreadnought, disk pressure, disk, pressure
link: /dreadnought/dn-disk-pressure.html
type: Alert
grand_parent: Armada Runbooks
parent: Dreadnought
---

Alert
{: .label .label-purple}

## Overview

This runbook describes what to do if a Dreadnought worker is having disk pressure.

## Example alerts

Example PD Body:

`Node Disk Pressure in dn-prod-s-cpapi-extended (us-east) is Triggered`

Example Body:

```
Node Disk Pressure in dn-prod-s-cpapi-extended (us-east) is Triggered

Event Generated:

Severity:         High
Metric:
    kube_node_sysdig_disk_pressure = 1
Segment:
    kube_cluster_name = 'cpapi-eu-de-fra04-0001-cluster' and kube_node_name = '192.168.4.5'
Scope:
    Everywhere

Time:             05/24/2024 05:52 PM UTC
State:            Triggered
Notification URL: https://us-east.monitoring.cloud.ibm.com:443/api/oauth/openid/IBM/a708cf9c0032433782568b6baf876b14/c216a9d8-0350-4a1e-8ee6-f705ca644aa9?redirectRoute=%2Fevents%2Fnotifications%2Fl%3A2419200%2F27766548%2Fdetails

------

Triggered by Alert:

Name:         Node Disk Pressure in dn-prod-s-cpapi-extended (us-east)
Team:         Monitor Operations
Scope:
    Everywhere
Segment by:   kube_cluster_name, kube_node_name
Alert When:   sum(avg(kube_node_sysdig_disk_pressure)) > 0.0
For at least: 1 m
Alert URL:    https://us-east.monitoring.cloud.ibm.com:443/api/oauth/openid/IBM/a708cf9c0032433782568b6baf876b14/c216a9d8-0350-4a1e-8ee6-f705ca644aa9?redirectRoute=%2Falerts%2Frules%3FalertId%3D474277
```
## Automation

None

## Actions to take

1. Login to the Dreadnought cluster the alert is triggering for via bastion.
_Instructions to connect via bastion can be found [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/dreadnought/dn-bastion.html){:target="_blank"}_

2. Most of cases the pod which is causing the problem is 'kube-auditlog-forwarder' or 'sos-tool'.
  To find the pod name run the following command.<br>
  `kubectl get pods -n ibm-services-system -o wide | grep $NODE`

  For example:
  ``` shell
  kubectl get pods -n ibm-services-system -o wide | grep $NODE
  change-tracker-57z4m                         1/1     Running     0          10d   192.168.0.11    192.168.0.11    <none>           <none>
  crowdstrike-w2vmw                            1/1     Running     0          10d   172.17.34.67    192.168.0.11    <none>           <none>
  dlc-6546476dc6-zcswz                         1/1     Running     0          10d   172.17.34.84    192.168.0.11    <none>           <none>
  dlc-6546476dc6-zjhcp                         1/1     Running     0          10d   172.17.34.111   192.168.0.11    <none>           <none>
  kube-auditlog-forwarder-5565444b68-62sc5     1/1     Running     0          10d   172.17.34.87    192.168.0.11    <none>           <none>
  sos-nessus-agent-29jsg                       1/1     Running     0          10d   192.168.0.11    192.168.0.11    <none>           <none>
  syslog-configurator-jvddx                    1/1     Running     0          10d   172.17.34.117   192.168.0.11    <none>           <none>
  uptycs-osquery-psddh                         1/1     Running     0          10d   192.168.0.11    192.168.0.11    <none>           <none>
  ```

3. Restart the offending pod ('kube-auditlog-forwarder' or 'sos-tool'), where $NAMESPACE and $POD_NAME is found in the above output.<br>
  `kubectl delete po -n $NAMESPACE $POD_NAME`

  For example:
  ``` shell
  kubectl delete po -n ibm-services-system kube-auditlog-forwarder-5565444b68-62sc5
  ```

  Monitor the alert for a while to check whether it is resolved automatically.
  If it is not resolved move on to the next step for further investigation.

4. To get the `uptycs-osquery` pod that is running on the troubled node, and store the value in `$NODE`<br>
`UPTYCS_POD=$(kubectl get pods -n ibm-services-system -l name=uptycs-osquery -o wide | grep $NODE | awk '{print $1}')`

5. Run `kubectl -n ibm-services-system exec $UPTYCS_POD -- df -h`<br>
  Confirm the `/host/var/data` is the culprit<br>
  If it is **not** then involve development

6. To show you the top users<br>
`kubectl -n ibm-services-system exec $UPTYCS_POD -- du /host/var/data | sort -n -r | head -n 30`

7. Identify the pod; line starts with `/host/var/data/kubelet/pods/<guid>/...`

8. Find the pod  
`kubectl get po --all-namespaces -o yaml | grep -B15 "$GUID"`
9. Restart the offending pod, where $NAMESPACE and $POD_NAME is found in the above output<br>
`kubectl delete po -n $NAMESPACE $POD_NAME`
10. Recheck disk space, and replace the node if not resolved.  You can follow the directions [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/dreadnought/dn-worker-replace.html)

## Escalation Policy

[Escalate to Dreadnought](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/dreadnought/dn-escalation.html){:target="_blank"}

## Reference

Some other helpful links for csutils:

- [General Troubleshooting](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI/blob/master/troubleshooting.md){:target="_blank"}
- [Csutil CLI](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI){:target="_blank"}
- [Csutil Charts](https://github.ibm.com/ibmcloud/charts){:target="_blank"}
