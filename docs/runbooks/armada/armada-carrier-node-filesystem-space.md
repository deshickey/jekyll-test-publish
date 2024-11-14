---
layout: default
description: How to handle a node which is running out of disk space.
title: armada-infra - How to handle a node which is running out of disk space.
service: armada
runbook-name: "armada-infra - How to handle a node which is running out of disk space"
tags: alchemy, armada, disk, filesystem
link: /armada/armada-carrier-node-filesystem-space.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with nodes which are running out of disk space, or the disk has become 100% full.

## Steps for cruiser clusters

If this alert is triggering for a cruiser cluster, please use the [following runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-node-filesystem-space.html)

Cruiser clusers will be identified by their alert names, for example:

`watson-bluemix.containers-kubernetes.prodwat-wdc06-cruiser1.10.188.77.16_node_scrape_failure.prodwat-wdc06-cruiser1`

The start of the title indicates the Squad, and the end indicates what cruiser cluster this is related to.

## Example alerts

Example PD title:

- `#3474841: dev.containers-kubernetes.10.130.231.176_disk_is_over_80_percent.mex01`
- `#3475713: dev.containers-kubernetes.10.130.231.176_disk_is_over_90_percent.mex01`


Example Body:

```
num_resolved     	  0

num firing       	  1

firing     	  

Labels:
 - alertname = DiskRunningOutOfSpace
 - alert_situation = 10.130.231.176_disk_is_over_80_percent
 - app = node-exporter
 - device = /dev/xvda2
 - fstype = ext4
 - hostname = 10.130.231.176
 - instance = 10.130.231.176:9100
 - job = kubernetes-service-endpoints
 - kubernetes_namespace = monitoring
 - mountpoint = /rootfs
 - name = node-exporter
 - service = armada-infra
 - service_name = node-exporter
 - severity = warning

Annotations:
 - description = The rootfs disk is 80.29156060891417%.
 - summary = Disk space is over 80% - consider an additional worker or free up space

Source: http://prometheus-4226581435-bgl4n:9090/graph?g0.expr=armada_infra%3Afilesystem_used_percentage+%3E+80&g0.tab=0

```

## Investigation and Action

## Actions to take for a Tugboat

1. Login to the tugboat the alert is triggering for  
_Instructions for this can be found [here](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/master/docs/runbooks/armada/armada-tugboats.md#access-the-tugboats)_

2. Most of cases the pod which is causing the problem is 'kube-auditlog-forwarder' or 'sos-tool'.
   To find the pod name run the following command.
   `kubectl get pods -n ibm-services-system -o wide | grep $NODE`

   For example:
   ``` shell
   kubectl get pods -n ibm-services-system -o wide | grep $NODE
   bes-local-client-l4d4z                     1/1     Running   0          15d     172.18.38.63     10.209.83.180    <none>           <none>
   change-tracker-82xh5                       1/1     Running   0          15d     172.18.38.62     10.209.83.180    <none>           <none>
   kube-auditlog-forwarder-685c8849b4-kp6zc   1/1     Running   0          7d18h   172.18.38.26     10.209.83.180    <none>           <none>
   syslog-configurator-jfmbg                  1/1     Running   0          15d     172.18.38.61     10.209.83.180    <none>           <none>
   ```

3. Restart the offending pod ('kube-auditlog-forwarder' or 'sos-tool'), where $NAMESPACE and $POD_NAME is found in the above output.
   `kubectl delete po -n $NAMESPACE $POD_NAME`

   For example:
   ``` shell
   kubectl delete po -n ibm-services-system kube-auditlog-forwarder-685c8849b4-kp6zc
   ```

   Monitor the alert for a while to check whether it is resolved automatically.
   If it is not resolved move on to the next step for further investiation.

4. To get the `bes-local-client` pod that is running on the troubled node, and store the value in `$NODE`  
`BES_POD=$(kubectl get pods -n ibm-services-system -l name=bes-local-client -o wide | grep $NODE | awk '{print $1}')`
5. Exec into the container to be able to run some diganostic commands.
   1. **PRIOR** to logging in, follow the steps to raise SOC notify as mentioned [here](https://w3.ibm.com/w3publisher/ibm-cloud-soc-public-documentation/slackbot-for-demisto)  
   ```
   I’m going to container exec for purposes of debugging.
   IBMid: <email>
   CRN App ID: bes-local-client
   Cluster: <tugboat cluster id>
   Namespace: ibm-services-system
   Pod: <$BES_POD>
   Justification: I need to exec into pod to resolve pd <pagerduty link>
   ```  
   _By execing into this pod, you will trigger a security alert, this will let soc know the activity is legitimate activity_  
   1. `kubectl -n ibm-services-system exec -it $BES_POD /bin/bash`

6. Run `df -h`<br>
   Confirm the `/host/var/data` is the culprit<br>
   If it is **not** then involve development

7. To show you the top users  
`du /host/var/data | sort -n -r | head -n 30`

8. Identify the pod; line starts with `/host/var/data/kubelet/pods/<guid>/...`
9. Exit out of the container
10. Find the pod  
`kubectl get po --all-namespaces -o yaml | grep -B15 "$GUID"`
11. Restart the offending pod, where $NAMESPACE and $POD_NAME is found in the above output  
`kubectl delete po -n $NAMESPACE $POD_NAME`
12. Recheck disk space, and reload node if not resolved.

## Actions to take for a Carrier worker node

1. Disable the node with `armada-cordon-node --reason <reason> <node>` so it no longer receives newly scheduled pods.
1. Optionally, if the filesystem is 100% full and there is evidence that existing pods are malfunctioning, drain the node with `armada-drain-node --reason <reason> <node>` so that they are rescheduled to other workers.

## Actions to take for the Carrier master

Because the Carrier master is more critical and can't be cordoned or drained, it's critical to resolve the disk issue as soon as possible.

### Check root password

The root password needs to be valid in order for the log rotater to function properly. See how to check it and change if needed [here](../change_root_password.html)

After verifying and/or changing the password, run the daily cron job manually.
1. Find cron job `cat /etc/cron.daily/logrotate`
1. Run the 2nd to last line in job. Should be: `test -x /usr/sbin/logrotate` then check return code `echo $?` if `0` continue below
1. Run the last line in job. Should be: `/usr/sbin/logrotate /etc/logrotate.conf`
1. The alert should resolve within a couple minutes, but can take up to 15m or longer depending on how many syslog files need to be zipped and how big those files are.

### Check logs

1. Check /var/log for anything using more than 2 GB:  
`find /var/log -size +2G`
1. Delete log files found in step 1 using  
`rm -f`
1. List size of backups directory  
`du -h backups`
1. Remove cruiser etcd backups over 21 days old  
`find /var/backups/cruiser* -mtime +22 -exec rm {} \;`
1. If there were no large log files found and after removing old backups the problem is still not resolved
   **escalate to the `armada-carrier` squad**

## Follow-up actions

[Create an issue for armada-carrier](https://github.ibm.com/alchemy-containers/armada-carrier/issues/new) to track.  Please include the affected worker node name and IP as well as output from `df -h`.

The `armada-carrier` squad needs to know about this incident so we can make updates to prevent it from happening in the future, whether it be additional log size limits or rotation, or reconfiguring hardware for future deployments.

## Escalation Policy

### For Tugboats

Since we can cordon and drain existing workers, this is not a critical issue.  
For Tugboat nodes, use the `iks-carrier-tugboats` channel for help.  

### For Legacy Carriers

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.
