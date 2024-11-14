---
layout: default
description: How to handle a carrier component which is troubled.
title: armada-carrier - How to handle a carrier component which is troubled.
service: armada
runbook-name: "armada-carrier - How to handle a carrier component which is troubled"
tags: alchemy, armada, node, down, troubled, apiserver, controller-manager, scheduler, etcd, size, defrag
link: /armada/armada-carrier-carrier-component-troubled.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# How to handle a carrier component which is troubled

## Overview

| Alert_Situation | Info | Start |
| --- | --- | --- |
| `CarrierEtcdServerCritical`| The carrier etcd servers are in a critical state. It is down and needs to be restored. | [Etcd](#etcd-debugging) |
| `CarrierEtcdServerUnhealthy`| The carrier etcd servers are in an unhealthy state. It is still running, but not at full capacity for an extended amount of time. | [Etcd](#etcd-debugging) |
| `CarrierAPIServerCritical`| The carrier API servers are in a critical state. Its either not running or very close to not running. | [API Server](#apiserver-debugging) |
| `CarrierAPIServerUnhealthy`| The carrier API servers are in an unhealthy state. It is still running, but not at full capacity for an extended amount of time. | [API Server](#apiserver-debugging) |
| `CarrierSchedulerServerCritical`| The carrier schedulers are in a critical state. Its either not running or very close to not running. | [Scheduler](#scheduler-debugging) |
| `CarrierSchedulerServerUnhealthy`| The carrier schedulers servers are in an unhealthy state. It is still running, but not at full capacity for an extended amount of time. | [Scheduler](#scheduler-debugging) |
| `CarrierControllerManagerServerCritical`| The carrier controller-managers are in a critical state. Its either not running or very close to not running. | [Controller-manager](#controller-manager-debugging) |
| `CarrierControllerManagerServerUnhealthy`| The carrier controller-managers servers are in an unhealthy state. It is still running, but not at full capacity for an extended amount of time. | [Controller-manager](#controller-manager-debugging) |
| `CarrierETCDSizeCritical` | The carrier etcd instance is hitting a warning size which is getting close to capacity | [Etcd-size](#etcd-size) |
| `CarrierETCDSizeUnhealthy` | The carrier etcd instance is hitting a critical size which is getting close to capacity | [Etcd-size](#etcd-size) |
| `CarrierEtcdDefragHasNotRunInAWeek` | The etcd defrag cronjob has not successfully ran in a week | [Etcd-defrag](#etcd-defrag) |

## Example Alert(s)

```text
Labels:
 - alertname = carrier_etcd_server_critical
 - alert_situation = carrier_etcd_server_critical
 - service = armada-carrier
 - severity = critical
 - environment = xxxxxxxxxxx
```

## Actions to take

## Before starting

<span style="color:red">Look at the alertname and follow the table of contents above.</span>  
These checks all assume that all the masters are up. If any master is down, these alerts will trigger, so first work on getting the master(s) back.

Additionally, check all the related alerts for the specific carrier it is being triggered for. The alerts should be inhibited based on higher priority ones.

### The alert priority is as follows

1. [Etcd Servers:](#etcd-debugging) `CarrierEtcdServerCritical`, `CarrierEtcdServerUnhealthy`
1. [API Servers:](#apiserver-debugging) `CarrierAPIServerCritical`, `CarrierAPIServerUnhealthy`
1. [Scheduler](#scheduler-debugging), [Controller-Manager](#controller-manager-debugging) Servers: `CarrierSchedulerServerCritical`, `CarrierSchedulerServerUnhealthy`, `CarrierControllerManagerServerCritical`, `CarrierControllerManagerServerUnhealthy`

### Etcd debugging

1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region.  
_More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_
1. Run the following command to find the member list and status of cluster health (started/unstarted) of etcd, endpoint:  
   ```bash
   source /opt/bin/etcd-rc; /opt/bin/etcdctl member list
   ```
   
   A good output should look like this:

   ```bash
   source /opt/bin/etcd-rc; /opt/bin/etcdctl member list
   513da4863eb225c0, started, etcd2, https://10.195.19.243:2380, https://10.195.19.243:4001
   783ebfd9c82c3d73, started, etcd1, https://10.63.49.21:2380, https://10.63.49.21:4001
   b0dad792876b6fb5, started, etcd0, https://10.138.6.6:2380, https://10.138.6.6:4001
   ```

   A bad output would look like this:

   ```bash
   source /opt/bin/etcd-rc; /opt/bin/etcdctl member list
   513da4863eb225c0, started, etcd2, https://10.195.19.243:2380, https://10.195.19.243:4001
   783ebfd9c82c3d73, started, etcd1, https://10.63.49.21:2380, https://10.63.49.21:4001
   b0dad792876b6fb5, unstarted, etcd0, https://10.138.6.6:2380,
   ```

   To get the endpoint health, this script:
   ```bash
   source /opt/bin/etcd-rc; /opt/bin/etcdctl --cluster=True endpoint health
   https://10.195.19.243:4001 is healthy: successfully committed proposal: took = 34.347983ms
   https://10.138.6.6:4001 is healthy: successfully committed proposal: took = 45.335463ms
   https://10.63.49.21:4001 is healthy: successfully committed proposal: took = 47.990187ms
   ```
   If only 1 etcd member is unhealthy, proceed with below steps to replace unhealthy member. If more than 1 etcd member is unhealthy, further investigation is required by checking etcd status and logs.
   
   To remove the unstarted member shown in the "bad output" above, this script can be used:
   ```bash
   source /opt/bin/etcd-rc; /opt/bin/etcdctl member remove b0dad792876b6fb5
   ```
   Stop etcd service on master on which etcd is unhealthy  
   ```bash
   sudo systemctl stop etcd
   ```
   Move etcd data
   ```bash
   sudo mv /var/etcd/data /var/etcd/data.20210616.broken
   ```
   To add a new member (etcd0, etcd1, etcd2) depending on issue experienced on etcd, they can be added:
   ```bash
   source /opt/bin/etcd-rc; ETCDCTL_API=3; /opt/bin/etcdctl member add etcd0 --peer-urls "https://IP:port"
   example: source /opt/bin/etcd-rc; ETCDCTL_API=3; /opt/bin/etcdctl member add etcd0 --peer-urls "https://10.138.6.6:2380"
   ```
   Start etcd
   ```bash
   sudo systemctl start etcd
   ```

1. Investigate the master that it is on.  
The master IP will be the one returned from `cluster-health`, so from the example above the unreachable master is `10.131.16.5`. Log into it
1. See if etcd is running  
   `sudo service etcd status`  
   If not try to start it  
   `sudo service etcd start`  
   If unable to start gather all info so far and [escalate](#escalation-policy)

### APIServer debugging

1. To find the downed apiserver, first log into prometheus and run this query  
`up{job=~"carrier-api-server-.*"} == 0`  
_More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)_
1. If nothing is returned, the alert should resolve soon
1. If a value is returned, look at the `job` label. It will contain the IP of the downed apiserver
1. SSH to that IP retrieved from above
1. Check to see if the apiserver is running  
`sudo crictl ps -a | grep kube-apiserver`  
Example:

   ```bash
   sudo crictl ps -a | grep kube-apiserver
   a99ab2b01a812       0b2cae5d07cda       13 days ago         Running             kube-apiserver                  0                   f4c4e06860127
   ```

1. If the apiserver is running, gather some logs  
   `sudo crictl logs --tail=1000 $CONTAINER_ID`  
   for later use. Try to restart it  
   `sudo crictl restart $CONTAINER_ID`
1. If no apiserver is running, try restarting the kubelet  
   `sudo service kubelet restart`
1. Wait a few minutes (1-2) and see if the apiserver container is running
1. If none of this resolved the issue then gather all info so far and [escalate](#escalation-policy)

### Scheduler debugging

1. To find the downed scheduler, first log into prometheus and run this query  
`up{job=~"carrier-scheduler-server-.*"} == 0`  
_More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)_
1. If nothing is returned, the alert should resolve soon
1. If a value is returned, look at the `job` label. It will contain the IP of the downed scheduler
1. SSH to that IP retrieved from above
1. Check to see if the scheduler is running  
   `sudo crictl ps -a | grep kube-scheduler`  
   Example:

   ```bash
   sudo crictl ps -a | grep kube-scheduler
   c77c6fd22a848       0b2cae5d07cda       13 days ago         Running             kube-scheduler                  0                   ebc7d3a824088
   ```

1. If the scheduler is running, gather some logs  
   `sudo crictl logs --tail=1000 $CONTAINER_ID`  
   for later use. Try to restart it  
   `sudo crictl restart $CONTAINER_ID`
1. If no scheduler is running, try restarting the kubelet  
   `sudo service kubelet restart`
1. Wait a few minutes (1-2) and see if the scheduler container is running.
1. If none of this resolved the issue then gather all info so far and [escalate](#escalation-policy)

### Controller-manager debugging

1. To find the downed controller-manager, first log into prometheus and run this query  
`up{job=~"carrier-controller-manager-server-.*"} == 0`  
_More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)_
1. If nothing is returned, the alert should resolve soon
1. If a value is returned, look at the `job` label. It will contain the IP of the downed controller-manager
1. SSH to that IP retrieved from above
1. Check to see if the controller-manager is running  
   `sudo crictl ps -a | grep kube-controller-manager`  
   Example:

   ```bash
   sudo crictl ps -a | grep kube-controller-manager
   d73c102a8ebfb       0b2cae5d07cda       13 days ago         Running             kube-controller-manager         0                   640cfabac1110
   ```

1. If the controller-manager is running, gather some logs  
   `sudo crictl logs --tail=1000 $CONTAINER_ID`  
   for later use. Try to restart it  
   `sudo crictl restart $CONTAINER_ID`
1. If no controller-manager is running, try restarting the kubelet  
   `sudo service kubelet restart`
1. Wait a few minutes (1-2) and see if the controller-manager container is running.
1. If none of this resolved the issue then gather all info so far and [escalate](#escalation-policy)

### Etcd size

1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region.  _More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_
1. Get current etcd size, if it is under the 6.5Gb threshold the alert should resolve. If not continue on. (size is the 4th column, 393MB in the example below)
   `source /opt/bin/etcd-rc; /opt/bin/etcdctl endpoint status`  

   ```bash
   source /opt/bin/etcd-rc; /opt/bin/etcdctl endpoint status
   https://172.20.0.1:4001, 99ab51d40e2fb677, 3.2.14, 393 MB, true, 16, 195142845
   ```

1. Verify the etcd defrag microservice has been running. Verify it has ran and completed in the past day (1/1) will be in the second column
   `kubectl get job -n armada -l job-name=armada-carrier-etcd-defrag`

   ```bash
    kubectl get job -n armada | grep armada-carrier-etcd-defrag
    armada-carrier-etcd-defrag-1558039201      1/1           20s        52m
    armada-carrier-etcd-defrag-1558039200      1/1           22s        11m
   ```

1. If everything above checks out, create an issue and wait until the Devs come back online to page out to determine next steps. [escalate](#escalation-policy)

### Etcd defrag

1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region. To access a tugboat you can find detailed instructions here: [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats).

1. Look to see the failed jobs that have been happening
   `kubectl get job -n armada | grep armada-tugboat-etcd-defrag`

   ```bash
    kubectl get job -n armada | grep armada-tugboat-etcd-defrag
    armada-tugboat-etcd-defrag-1589184000        0/1           11h        11h        
   ```

Where the column names are `NAME`, `COMPLETIONS`, `DURATION`, and `AGE`. The failed job will show as 0/1 in the `COMPLETIONS` column.

1. Try and find the failed pod, where job name is retrieved from the previous step.
    `kubectl get pods -n armada -l job-name=$JOB_NAME`

    ```bash
    kubectl get pods -n armada -l job-name=armada-tugboat-etcd-defrag-1589184000
    NAME                                          READY   STATUS      RESTARTS   AGE
    armada-tugboat-etcd-defrag-1589184000-9q2br   0/2     DeadlineExceeded   0          11h
    armada-tugboat-etcd-defrag-1589184000-lqjbn   0/2     DeadlineExceeded   0          10h
    ```

1. Grab the pod logs, where job name is retrieved from the previous step. You need to specify that you want the logs from the `-c armada-tugboat-etcd-defrag` container.
   `kubectl logs -n armada -l job-name=$JOB_NAME -c armada-tugboat-etcd-defrag`

1. If there aren't any immediately obvious and fixable errors then create an issue and wait until the Devs come back online to page out to determine next steps. [escalate](#escalation-policy)

#### Run a manual etcd defrag

1. Targeting the tugboat run the command `kubectl create -n armada job manual-defrag-$(date +%s) --from=cronjob/armada-tugboat-etcd-defrag`

1. Verify the defrag job ran successfully `kubectl get pods -n armada | grep manual-defrag` example output: ```kubectl get pods -n armada | grep manual-defrag
manual-defrag-1605037683-m9djb                    0/1     Completed                    0          4m44s```

1. Delete the manual defrag job when it is done `kubectl delete job -n armada <manual-defrag-1605037683>`

### Restoring Etcd (Should only be done after dev escalation and when all machines have failed and cannot boot)

1. First verify all 3 masters are reachable (SSH and ping)
1. If there is at least 1 etcd member running (from previous steps), run [backup/restore jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/build?delay=0sec) with these parameters (if not specified use default):
   - Environment: environment in the alert i.e. (dev-mex01)  
   Its a drop down so should be easy to find
   - Carrier: carrier in the alert i.e. (carrier11)  
   Its a drop down so should be easy to find
   - TARGET_BOM_OVERRIDE : armada-ansible-bom-1.10.yml
   - CUSTOM_PLAYBOOK: backup-restore-etcd-carrier.yaml
   - [Example job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/5691/console)
1. If there are no etcd member running (from previous steps), run [restore jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/build?delay=0sec) with these parameters (if not specified use default):
    - Environment: environment in the alert i.e. (dev-mex01)  
    Its a drop down so should be easy to find
    - Carrier: carrier in the alert i.e. (carrier11)  
    Its a drop down so should be easy to find
    - CUSTOM_PLAYBOOK: restore-only-etcd-carrier.yaml
    - [Example job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/5691/console)
1. Wait for the job to complete. If successful the alert should auto resolve.  
   If not gather all info so far and [escalate](#escalation-policy)


## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.
