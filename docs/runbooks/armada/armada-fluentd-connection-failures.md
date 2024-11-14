---
layout: default
description: How to debug and resolve the "ibm-kube-fluentd Connection Issues" pager
title: Runbook for pager "Imb-Kube-Fluentd Connection Issues"
service: armada-fluentd
runbook-name: "Ibm-Kube-fluentd Connection Issues"
tags: wanda, armada, metrics, down, alertmanager
link: /armada/armada-fluentd-connection-failures.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Fluentd Connection issues

## Overview
This incident is triggered whenever ibm-kube-fluentd can't connect to the IBM Activity Tracker service on multiple nodes in the given Carrier.

## Example alert

* A pager duty incident was generated for the `fluentd_audit_connection_down_for_multiple_nodes` alert

The threshold for these alerts is connectivity loss on >= 20% of Carrier workers.  Follow the steps below.

## Action to take
 
1. Determine whether there are active incidents for the Activity Tracker Service. Look in the **in the alert region** for policy [{{ site.data.teams.activity-tracker.escalate.name }}]({{ site.data.teams.activity-tracker.escalate.link }}) - see entries in the **Inbound Services** panel of the escalation policy

   If there **are** active incidents for the alerting region :
      - **then**  escalate to [{{ site.data.teams.activity-tracker.escalate.name }}]({{ site.data.teams.activity-tracker.escalate.link }})
      - **else**  continue

1. Determine whether there are active incidents for the Logging Service **in the alert region** for policy [{{ site.data.teams.logging-service.escalate.name }}]({{ site.data.teams.logging-service.escalate.link }}) - see entries in the **Inbound Services** panel of the escalation policy

   If there **are** active incidents for the alerting region :
      - **then**  escalate to [{{ site.data.teams.logging-service.escalate.name }}]({{ site.data.teams.logging-service.escalate.link }})
      - **else**  continue

1. Need to restart the fluentd pods

   1. [Restart all fluentd pods](#restart-fluentd-pods)
   1. Wait a few minutes for the fluentd pods to restart
   1. If the alert hasn't resolved, continue

1. Either there are no active incidents and/or restarting fluentd didn't resolve the alert

   1. Reach out to the Activity Tracker Service's `!oncall` member via [{{ site.data.teams.activity-tracker.comm.name }}]({{ site.data.teams.activity-tracker.comm.link }}) and ask them to investigate connection issues. 
   1. Reach out to the Logging Service's `!oncall` member via [{{ site.data.teams.logging-service.comm.name }}]({{ site.data.teams.logging-service.comm.link }}) and ask them to investigate any issues with that Logging stack and restart the Lumberjack servers as necessary. You can find the logging stack in Kibana by targeting the `ArmadaEvents*` space for the alert region, and then clicking on the `Admin` tab. The stack name will be listed as `Cluster` under `ElasticSearch Cluster`.
   1. Monitor the alert 
   1. If the alert doesn't resolve,  
   Escalate the alert to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

### Restart Fluentd Pods	

 Run the following to restart all fluentd pods slowly:	
```	
kubectl -n kube-system get pods -l app=ibm-kube-fluentd | grep -v NAME > fluent_pods.txt	
 while read line; do	
  name=$(echo $line | cut -d ' ' -f1 | xargs)	
  kubectl -n kube-system delete pod $name	
  sleep 3	
done <fluent_pods.txt	
 echo "pods are all updated, waiting for a bit then checking status"	
sleep 15	
kubectl -n kube-system get pods -l app=ibm-kube-fluentd	
```	

 If there are relatively few nodes in the cluster (<20ish), you can restart all pods more simply:	
```	
kubectl -n kube-system delete pods -l app=ibm-kube-fluentd	
```	
In most Carrier, this isn't a problem.  However, in some large clusters (e.g. Watson/WDP), this can overwhelm the Logging/Metrics services Lumberjack stacks with	
too many new connection.

## Automation 
None

## Escalation Policy

[{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})
