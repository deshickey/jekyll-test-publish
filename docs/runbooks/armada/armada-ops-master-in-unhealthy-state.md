---
layout: default
description: How to handle masters are in unhealthy state.
title: armada-ops - How to handle masters are in unhealthy state.
service: armada-ops
runbook-name: "armada-ops - How to handle masters are in unhealthy state."
tags: armada-ops, master, health
link: /armada/armada-ops-master-in-unhealthy-state.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle alert which reports masters are in unhealthy state. The health state of a master will be marked as unavailable if there are timeout errors when do the kubectl to get the node list. The health state of a master will be marked as error if there are other errors when do the kubectl to get the node list. 

## Example alerts

The alert you received should look similar to:

{% capture example_alert %}
~~~
Labels:
- alertname = MasterInUnhealthyState
- alert_situation = master_in_unhealthy_state
- environment = prod-dal12-carrier2
- service = armada-ops
- severity = warning
~~~
{% endcapture %}
{{ example_alert }}

## Actions to take

### Before starting 

First, check to see if any of the following alerts are triggering and follow the runbook associated to it as it should take priority. Only return to this alert once the high percentage issue has been resolved. 
- `high_percentage_master_in_unhealthy_state`
    * [high_percentage_master_in_unhealthy_state](armada-ops-high-percentage-master-in-unhealthy-state.html)
- `high_percentage_high_availability_master_in_unhealthy_state`
    * [high_percentage_master_in_unhealthy_state](armada-deploy-high-percentage-high-availability-cluster-master-critical.html)
    
### Check master health state in etcd

Get the master id from the alert (ex: `master_id = kube-lon02-64ae1a448e89431f9dc306c4356d618d-m1`). Check the master health status using xo, e.g. `@xo master kube-lon02-64ae1a448e89431f9dc306c4356d618d-m1`. 
- If it shows `"HealthState": "normal"`, snooze the alert for 6 hours. The alert is caused by stale metrics (armada-usage updates metrics every 6 hours). We are working through to make the metrics keeping sync with etcd. 
- If the HealthState is `unavailable` or `error`, continue following instructions to resolve the issue. 
    
### Check errors and events in the master pod

Get the cluster id from the alert (ex: `3dab9ce28c30481183a5c15c944e62ab`). Run following commands to get the pod name
~~~
export MASTER_ID=master-3dab9ce28c30481183a5c15c944e62ab
kubectl get pods -n kubx-masters -l app=${MASTER_ID}
~~~

Sample output
~~~
NAME                                                     READY     STATUS             RESTARTS   AGE
master-3dab9ce28c30481183a5c15c944e62ab-2686662830-xf7ts   6/6      Running           12         21m
~~~

Check what's the error when run the kubectl get node command. Debug based on the output. If this is an HA master (3 pods), any pod will work for the following steps.
~~~
kubectl -n kubx-masters exec master-3dab9ce28c30481183a5c15c944e62ab-2686662830-xf7ts kubectl get node
~~~

If there is no useful info in above output, collect the api server log and check if there are any errors reported
~~~
kubectl -n kubx-masters logs master-3dab9ce28c30481183a5c15c944e62ab-2686662830-xf7ts -c apiserver > apiserver.log 2>&1
~~~

Describe the pod, take a look at any errors in the `events` section of this command. 
~~~
kubectl -n kubx-masters describe pod master-3dab9ce28c30481183a5c15c944e62ab-2686662830-xf7ts 
~~~

#### For HA Masters (The containers `etcd`, nor a `konnectivity` or `openvpn` are present in master pod)
If the apiserver logs show issues connecting to `etcd`, please follow this [runbook](armada-cluster-etcd-unhealthy.html) for troubleshooting ha cruiser/patrol problems.

### Delete the master pod

If none of the above known issues apply to your particular alert scenario, the one thing that you can try is just simply deleting the master pod.  Kubernetes will automatically recreate the pod once it is deleted.

#### For Non-ha masters (The `etcd` and a `konnectivity` or `openvpn` containers are present in master pod)
Run following commands to delete the pod
~~~
kubectl delete pod -n kubx-masters -l app=${MASTER_ID}
~~~

#### For HA Masters (The containers `etcd`, nor a `konnectivity` or `openvpn` are present in master pod)
Delete one pod at a time, and wait for them to come up, before deleting the next one
~~~
kubectl delete pod -n kubx-masters ${POD_ID}
~~~

After the pod is recreated, rerun kubectl get node command, see if you can get the correct result. 
~~~
kubectl -n kubx-masters exec master-3dab9ce28c30481183a5c15c944e62ab-2686662830-xf7ts kubectl get node
~~~

Correct result example
~~~
kubectl -n kubx-masters exec master-3dab9ce28c30481183a5c15c944e62ab-2686662830-xf7ts kubectl get node
Defaulting container name to kube-addon-manager.
Use 'kubectl describe pod/master-3dab9ce28c30481183a5c15c944e62ab-2686662830-xf7ts -n kubx-masters' to see all of the containers in this pod.
NAME           STATUS     ROLES     AGE       VERSION
10.93.203.17   Ready      <none>    44d       v1.9.3-2+0b1ffe38401940
10.93.203.23   Ready      <none>    44d       v1.9.3-2+0b1ffe38401940
10.93.203.24   Ready      <none>    43d       v1.9.3-2+0b1ffe38401940
~~~

## Automation
None

## Escalation Policy
If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
