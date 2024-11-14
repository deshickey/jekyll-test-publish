---
layout: default
description: What to do when prometheus enters rushed mode
title: armada-ops - What to do when prometheus enters rushed mode
service: armada
runbook-name: "armada-ops - What to do when prometheus enters rushed mode"
tags: alchemy, armada, prometheus
link: /armada/armada-ops-prometheus_rushed_mode.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes what to do when prometheus enters rushed mode.

If you attempt to action the alert but are unsure on a step, then please engage the armada-ops UK squad and do not continue.

This should only ever raise a low priority PD alert, and as we are integrated with virtual conductor, a GHE issue will automatically get raised against [armada-ops](https://github.ibm.com/alchemy-containers/armada-ops/issues/).

If we silently enter rushed mode then if prometheus restarts (possibly only in the next 48 hours - while this data is persisted) then it can take 45+ minutes to come back.

If we enter rushed mode, the armada-ops squad should schedule maintenance on the carrier which has entered rushed mode to prevent a situation where prometheus is terminated and takes 45+ minutes to come back due to performing a consistency check on its data.  

## Example alerts

Example PD title:

- `#3475713: blumemix.containers-kubernetes.prod-dal10-carrier3.prometheus_entered_rushed_mode.us-south`


## Investigation and Action

Checks to perform on the carrier reporting the issue.  

- NOTE:  A grafana dashboard called [Prometheus Health - example link to prod-dal10-carrier3](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier3/grafana/dashboard/db/prometheus-health?orgId=1&from=now-1h&to=now) displays a subset of the following queries.

The following queries can be run from prometheus or by interaction with the carrier using kubectl by logging into the carrier-master-01 node.
They will compliment the data seen on the dashboard.

### From the carrier-master node

- Verify the limits for memory on the pod is as it should be - 54Gi is our current setting as per 1337 project

  ```
  kubectl describe pod -n monitoring -l app=prometheus
  ```

  This should display info such as

  ```
  Name:		prometheus-1689618420-j184b
  Namespace:	monitoring
  Node:		10.176.215.34/10.176.215.34
  Start Time:	Wed, 04 Oct 2017 15:41:17 +0100
  Labels:		app=prometheus

  ....
  Limits:
     memory:	54Gi
   Requests:
     memory:		54Gi
   Readiness:		http-get http://:9090/ delay=0s timeout=1s period=10s #success=1 #failure=3
  ```

- Verify information about the node where prometheus has started on.  Use output from `kubectl describe node <ip address>`

  Verify that other services are not running on the same node as prometheus should end up on its own node with no other armada microservices.
  The best way to verify this is to take the `Node` information from the pod describe output, and perform a describe of the node it is on.

  The output should show similar to the example below and should contain this detail:

- Verify scheduler taint is present

  ```
  scheduler.alpha.kubernetes.io/taints=[{"key":"dedicated","value":"prometheus","effect":"NoSchedule"}]
  ```

  this means no other pods (apart from daemonsets) should land on this server.  If this taint is not in place, prometheus is on a node where other services such as `armada-api` or `armada-bootstrap` can run.  We've seen this occur in environments which have lots of 64GB RAM servers.  If one of these pods lands on a node where prometheus is running, it can cause performance issues and prometheus can end up in rushed mode as it's fighting for resource against other services.  Go to section `Actions to take if more pods are on the node running prometheus` and follow the steps documented here.

-  Verify non-terminated Pods should include just `prometheus`, `node-exporter`, `armada-fluentd` and `docker-metrics-endpoint` pods - any more, and actions should be taken.

- Verify that `memory:				65775100Ki` - should be this value as a minimum

  ```
    pcullen@pcullen-VirtualBox:~/armada-certs/prod-dal10-carrier3$ kubectl describe node 10.176.215.34
    Name:			10.176.215.34
    Role:			
    Labels:			arch=amd64
			beta.kubernetes.io/arch=amd64
			beta.kubernetes.io/os=linux
			kubernetes.io/hostname=10.176.215.34
    Annotations:		scheduler.alpha.kubernetes.io/taints=[{"key":"dedicated","value":"prometheus","effect":"NoSchedule"}]
			volumes.kubernetes.io/controller-managed-attach-detach=true
    Taints:			<none>
    CreationTimestamp:	Fri, 05 May 2017 17:14:55 +0100
    Conditions:
      Type			Status	LastHeartbeatTime			LastTransitionTime			Reason				Message
      ----			------	-----------------			------------------			------				-------
      OutOfDisk 		False 	Tue, 10 Oct 2017 10:32:28 +0100 	Mon, 07 Aug 2017 17:27:01 +0100 	KubeletHasSufficientDisk 	kubelet has sufficient disk space available
      MemoryPressure 	False 	Tue, 10 Oct 2017 10:32:28 +0100 	Fri, 05 May 2017 17:14:55 +0100 	KubeletHasSufficientMemory 	kubelet has sufficient memory available
      DiskPressure 		False 	Tue, 10 Oct 2017 10:32:28 +0100 	Fri, 05 May 2017 17:14:55 +0100 	KubeletHasNoDiskPressure 	kubelet has no disk pressure
      Ready 		True 	Tue, 10 Oct 2017 10:32:28 +0100 	Mon, 07 Aug 2017 17:27:01 +0100 	KubeletReady 			kubelet is posting ready status. AppArmor enabled
    Addresses:
      LegacyHostIP:	10.176.215.34
      InternalIP:	10.176.215.34
      ExternalIP:	10.176.215.34
      Hostname:	10.176.215.34
    Capacity:
     alpha.kubernetes.io/nvidia-gpu:	0
     cpu:					32
     memory:				65775100Ki
     pods:					110
    Allocatable:
     alpha.kubernetes.io/nvidia-gpu:	0
     cpu:					32
     memory:				65775100Ki
     pods:					110
    System Info:
     Machine ID:			d80f2122b9e3436bb2f0db84212ea495
     System UUID:			d80f2122b9e3436bb2f0db84212ea495
     Boot ID:			711318b3-3f2b-4e6d-afec-dc3763e056e1
     Kernel Version:		4.4.0-71-generic
     OS Image:			Ubuntu 16.04.2 LTS
     Operating System:		linux
     Architecture:			amd64
     Container Runtime Version:	docker://17.3.1-ce
     Kubelet Version:		v1.5.6-4+abe34653415733
     Kube-Proxy Version:		v1.5.6-4+abe34653415733
    ExternalID:			10.176.215.34
    Non-terminated Pods:		(4 in total)
      Namespace			Name					CPU Requests	CPU Limits	Memory Requests	Memory Limits
      ---------			----					------------	----------	---------------	-------------
      ibm-system			ibm-kube-fluentd-8ftf0			100m (0%)	1 (3%)		200Mi (0%)	1Gi (1%)
      monitoring			docker-metrics-endpoint-xnb7m		100m (0%)	0 (0%)		0 (0%)		0 (0%)
      monitoring			node-exporter-bq6zq			0 (0%)		0 (0%)		0 (0%)		0 (0%)
      monitoring			prometheus-1689618420-j184b		0 (0%)		0 (0%)		54Gi (86%)	54Gi (86%)
    Allocated resources:
      (Total limits may be over 100 percent, i.e., overcommitted.)
      CPU Requests	CPU Limits	Memory Requests	Memory Limits
      ------------	----------	---------------	-------------
      200m (0%)	1 (3%)		55496Mi (86%)	55Gi (87%)
  ```


- Navigate to the [Alchemy Prod dashboard](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/process/) and open prometheus for the carrier where the alerts are triggering.

On the `graph` page, query `prometheus_local_storage_rushed_mode{app="prometheus"}` and view as a graph over the past 48 hours. If rushed mode is 1 - this alert should be actively firing

- how long has it been like this?
  To understand how bad the problem is, further checks should be made.

  Check the urgency score for the carrier over the past 48 hours.

  `prometheus_local_storage_persistence_urgency_score{app="prometheus"}`

  rushed mode is if urgency is greater than 0.8, if it ever hits 1.0 then metrics are being dropped, and this is extremely serious.

  look at the memory usage of prometheus? - is it using it all?

  `container_memory_usage_bytes{pod_name=~"prometheus.*", image=~".*prometheus.*"}`

- look at where prometheus persists its metrics - this should be to a 4Tb NFS mount with 10 IOPS - is that the case?
   - Check by running these commands from the worker node where the prometheus POD is running.
   ~~~
   pcullen@prod-lon04-carrier1-worker-79:~$ mount -l | grep prometheus
   fsf-lon0401b-fz.adn.networklayer.com:/IBM02SEV531277_15422/data01 on /var/lib/kubelet/pods/05122941-b0f4-11e8-96be-065c4c8969a1/volumes/kubernetes.io~nfs/monitoring-prometheus-data-nfs type nfs4 (rw,relatime,vers=4.0,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.45.118.158,local_lock=none,addr=161.26.130.25)
   ~~~
  - Use the Softlayer mount name `IBM02SEV531277_15422` to find more information by visiting [IBM Softlayer](https://control.softlayer.com/).  Logging into the correct account (eg: 531277 for stage and production) and finding the mount details under `Storage` -> `File storage`

- Is this a worldwide problem? are all carriers starting to look bad? most of our carriers should be the same, and our fix strategies will impact all of them in the same way (cattle - not pets)

## Actions to take if the NFS mount is wrong

Raise a GHE ticket against [armada-ops](https://github.ibm.com/alchemy-containers/armada-ops/issues/new) with all the details about the NFS share and that it appears to be wrong.

The process to update the NFS share details, if incorrect, is handled by the SRE team, but usually the UK Squad, who have the main responsibility for armada-ops code.

## Actions to take if more pods are on the node running prometheus

For now, follow these steps and also raise an issue against `armada-ops` to continue investigation after stabilising prometheus

1.  If prometheus is on a node which does not have a prometheus only taint, cordon the node by follwing these steps
Log on to the node and issue `armada-cordon-node --reason "prometheus in rushed mode : <ADD YOUR NAME>" <node ip address>`

1. Once the node is cordoned, remove the armada-microservice pods that should not be on a node which prometheus is running on.
   - Only   `prometheus`, `node-exporter`, `armada-fluentd` and `docker-metrics-endpoint` pods should be on the node.
   - Remove any other pods - they will get automatically rescheduled else where by kube.
   - To find these pods by running `kubectl describe node <node ip>` and then use `kubectl delete pod -n <namespace of the pod> <pod name>`

1. Leave the node cordoned so that no new pods end up affecting prometheus.

Raise a GHE ticket against [armada-ops](https://github.ibm.com/alchemy-containers/armada-ops/issues/new) documenting all the steps you've taken.

## Actions to take if prometheus running on its own pod

### If the memory is less than 54Gi:

- Review the settings for `PROM_RESOURCE_LIMIT` in each LEET project - for example - [prod-us-south](https://github.ibm.com/alchemy-1337/environment-prod-us-south/blob/master/deploy/envrc.prod-us-south#L76)

- If this is not 54Gi, review the change history to find out why it has been changed

- If this is correctly set to 54Gi in the LEET projects, then the deployment has been manually changed on the carrier.

- On the master-01 server for the carrier, run these commands to debug further (NB: *MUST* be run on the carrier master)

-  `kubectl rollout history deployment -n monitoring prometheus`
   This should return:

```
    deployments "prometheus"
    REVISION	CHANGE-CAUSE
    13		<none>
    14		<none>
    15		<none>
    16		<none>
    17		<none>
    18		<none>
    19		<none>
    20		<none>
    21		<none>
    22		<none>
    23		<none>
```

- To view details of a revision, and see when memory was changed, run this command:
  `kubectl rollout history deployment -n monitoring prometheus --revision=23`

- To update the memory allocated to prometheus, follow this steps.

- Grab the current prometheus deployment spec - `kubectl get deployment -n monitoring prometheus -o yaml`
- Using the following [prometheus template](https://github.ibm.com/alchemy-containers/armada-ops/blob/master/manifests/prometheus/prometheus-depl.yaml), create a file on the carrier-master-01 server, and replace any variables with values the environment is currently using.  Ensure you set the value for `{{ PROM_RESOURCE_LIMIT }}` to be `54Gi`
- Apply the changes with `kubectl apply -f <filename>`

### If the memory IS 54Gi, and rushed mode is fixed at 1 for the last 48 hours, then we need to plan to do one of the following:

- reduce the number of metrics that we scrape
- increase the amount of memory we run prometheus on.

- From the prometheus dashboard, run `sum(scrape_samples_scraped) by (job, service_name)` and review the PODs with high samples being scraped.
    -  You may observe `{job="kubernetes-service-endpoints",service_name="nginx-ingress-stats-service"}` reporting scrapes in the millions.  If that is the case, log onto the carrier-master and restart the `nginx-ingress` pods one at a time with the below steps
        * Find all the pods - `kubectl get pods -n armada -l app=nginx-ingress`
        * Delete one pod at a time, ensuring the POD recreates successfully before moving on to delete the next pod - `kubectl delete pod -n armada <pod name>`
    - The deleting of the PODs should see a vast improvement of the number of samples scraped, but it may take several hours before it affects the urgency score.  (see below)


This should be a high priority development item for `armada-ops squad` - especially if the urgency score is edging towards 1.0

## Escalation Policy

As it is a low priority alert - no escalations should be necessary.
If you are unable to find a suitable way forward, then add to the automatically created GHE issue in [armada-ops](https://github.ibm.com/alchemy-containers/armada-ops/issues/) and post in the #armada-ops channel requesting for assistance.
