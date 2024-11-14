---
layout: default
description: How to resolve automated tugboat worker action fail alerts
title: automated-tugboat-action-fail - How to resolve the armada etcd cluster related alerts
service: armada
runbook-name: "automated-tugboat-worker-action-failure - automated tugboat worker action failures"
tags:  armada, tugboat, worker-action, worker-reload, worker-replace
link: /armada/automated-tugboat-worker-action-failure.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--|--|--|
| `AutomatedWorkerActionFailure6+Hours`| Automated Tugboat Worker has been in a bad state for 6+ hours. WorkerIP: %s Reload Failed For Cluster %s | [Automated Worker Action Failure 6+ Hours](#automated-worker-action-failure-6-hours) |
| `AutomatedTugboatWorkerReloadFailure`| Automated Tugboat Worker %s Reload Failed For Cluster %s | [Automated Tugboat Worker Reload Failure](#automated-tugboat-worker-reload-failure) |
| `AutomatedTugboatWorkerReplaceFailure`| Automated Tugboat Worker %s Replace Failed For Cluster %s | [Automated Tugboat Worker Replace Failure](#automated-tugboat-worker-replace-failure) |

## Example Alert(s)

~~~~
Automated Tugboat Worker 10.95.133.227 Reload Failed For Cluster dev-tugboat-carrier100
SEE BELOW FOR MORE DETAIL
RUNBOOK=https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/tugboat_reload_fail.html
CLUSTER_NAME=dev-tugboat-carrier100
REGION=us-south
IBMCLOUD_WORKER_DETAILS=
~~~~

## Investigation and Action

## Actions to take

### Automated Worker Action Failure 6+ Hours

We need to find if the node is reporting ready. If the node is ready go to [resolution](#resolution)  
_Steps to find out if the node is ready or not can be found below_

1. Log into the hub for the tugboat region and invoke the tugboat  
_more info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_
1. Describe the node in the alert  
`kubectl describe node $NODE_IP`  
_for example:_
    ```
    kubectl describe node 10.95.190.20                        
    Name:               10.95.190.20
    -----
    CreationTimestamp:  Thu, 22 Aug 2019 14:37:29 -0500
    Taints:             multi-az-worker=true:NoSchedule
    Unschedulable:      false
    Conditions:
      Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
      ----             ------  -----------------                 ------------------                ------                       -------
      MemoryPressure   False   Tue, 10 Sep 2019 10:15:47 -0500   Sat, 07 Sep 2019 02:40:49 -0500   KubeletHasSufficientMemory   kubelet has sufficient memory available
      DiskPressure     False   Tue, 10 Sep 2019 10:15:47 -0500   Sat, 07 Sep 2019 02:40:49 -0500   KubeletHasNoDiskPressure     kubelet has no disk pressure
      PIDPressure      False   Tue, 10 Sep 2019 10:15:47 -0500   Sat, 07 Sep 2019 02:40:49 -0500   KubeletHasSufficientPID      kubelet has sufficient PID available
      Ready            True    Tue, 10 Sep 2019 10:15:47 -0500   Sat, 07 Sep 2019 02:40:49 -0500   KubeletReady                 kubelet is posting ready status
      System Info:
      -----
      Kubelet Version:            v1.14.6+IKS
      Kube-Proxy Version:         v1.14.6+IKS
      -----
      Events:     <none>
      ```
1. Verify the KubeletReady is `True`
1. If still unsure, do `kubectl get node $NODE_IP`
```
kubectl get node 10.209.96.121
NAME            STATUS   ROLES    AGE   VERSION
10.209.96.121   Ready    <none>   67d   v1.15.3+IKS
```
1. If worker shows NotReady, [reload the node](armada-carrier-node-troubled.html#tugboat-reloads)
    - Once Resolved go to [resolution](#resolution)

### Automated Tugboat Worker Reload Failure
1. If in the jenkins job you see `Pull is not possible because you have unmerged files` go [here](#reset-worker-info-dedicated-branch)
1. In the alert find the output of `kubectl describe node` and `ibmcloud ks worker get`, example PD https://ibm.pagerduty.com/incidents/PRNWOQ7
1. From the `ibmcloud ks worker get` output
    - if `state` contains `Waiting for IBM Cloud infrastructure`, go to [Softlayer Related Reload Failure](#softlayer-related-reload-failure)
    - if `state` contains `firewall`, go to [Firewall Related Reload Failure](#firewall-related-reload-failure)
1. Verify the following:
    - `Version` (from `ibmcloud ks worker get` output) = `ibm-cloud.kubernetes.io/worker-version` (from `kubectl describe` output)
         - Version could look like this: `Version:        1.12.10_1564 --> 1.14.6_1532 (pending)`, verify that the node is now `1.14.6`
    - `Status` = `Ready` (from `ibmcloud ks worker get` output)
    - `KubeletReady` and  `kubelet is posting ready status` (from `kubectl describe` output)  

    Example output:

   ```
   $ ibmcloud ks worker get --cluster dev-tugboat-carrier100 --worker kube-dal10-cr9d68885dd7394e35956cf5e1fe5b0f96-w14
    Retrieving worker kube-dal10-cr9d68885dd7394e35956cf5e1fe5b0f96-w14...       OK

    ID:             kube-dal10-cr9d68885dd7394e35956cf5e1fe5b0f96-w14   
    State:          normal   
    Status:         Ready   
      ...
    Private IP:     10.95.133.227
      ...
    Version:        1.15.3_1517


    kubectl describe node 10.95.133.227
    Name:               10.95.133.227
    Roles:              <none>
    Labels:             arch=amd64
      ...
    ibm-cloud.kubernetes.io/worker-version=1.15.3_1517
      ...              
    Conditions:
    Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
    ----             ------  -----------------                 ------------------                ------                       -------
      ...
    Ready            True    Tue, 24 Sep 2019 02:21:57 +0000   Sun, 22 Sep 2019 00:21:58 +0000   KubeletReady                 kubelet is posting ready status
   ```

1. If the worker IS ready AND at the desired version, go to [resolution](#resolution)
1. If the worker node is NOT ready or NOT at the desired version, go here [Automated Worker Reload Failure 6+ Hours](#automated-worker-action-failure-6-hours) to get the most up to date information
    - Once Resolved go to [resolution](#resolution)

### Reset Worker Info Dedicated Branch
From your local machine run:
1. `export CLUSTER_NAME=<CLUSTER_NAME>`  
_`$CLUSTER_NAME` is the IKS cluster name of the tugboat. eg **`prod-us-south-carrier100`**._

1. ~~~
   git clone git@github.ibm.com:alchemy-containers/tugboat-worker-info.git
   cd tugboat-worker-info
   git push -d origin $CLUSTER_NAME
   git checkout master
   git pull origin master
   git checkout -b $CLUSTER_NAME
   git push --set-upstream origin $CLUSTER_NAME
   ~~~

1. The branch is now in a reset state and future jobs will be able to complete - resolve the alert!

   **_Notes:_**
   - _The above steps do not delete any needed info, it only resets the state of the branch._
   - _The worker info file is recreated each run._
   - _The in-use file is used, but only for consecutive reloads._
   - _If its deleted, the reloader will pause until all workers are ready again_

### Automated Tugboat Worker Replace Failure
1. Go to the `BUILD_URL` listed in the alert to view the jenkins job and go to the console to view the logs
1. View the console logs to view on why it failed
1. View [escalation policy](#escalation-policy) for next steps

### Softlayer Related Reload Failure
1. If a worker reload has been stuck on `Waiting for IBM Cloud infrastructure` for a long time, a ticket must be raised with Softlayer to find the cause of the delay.
2. If the error message starts with something like `IBM Cloud infrastructure exception` (e.g. `IBM Cloud infrastructure exception: Unable to reload operating system at this time. Please try again later.`)
    * This means that the cluster has received an error from Softlayer. The machine will keep retrying to reload the machine until the message is marked as failed.
    * In order to find out more details from SoftLayer, raise a ticket with SoftLayer including the hostname details and the error message.
1. Once Resolved go to [resolution](#resolution)

### Firewall Related Reload Failure
1. Verify with netint team that outbound connectivity is open for the worker node in channel `#netint`.  
1. Once Resolved go to [resolution](#resolution)

### Resolution
The auto reloader will reload multiple workers in the same zone if the worker pool matches exactly "customer-workload". SZRs are limited to 1 node at a time due to -[a,b,c] appended to their "customer-workload" pool.

IF there is only one entry in the in-use file:
1. Once Resolved delete the in-use file in this repo [tugboat-worker-info](https://github.ibm.com/alchemy-containers/tugboat-worker-info). The directory and branch it is in will match the `CLUSTER_NAME` in the alert. Do not update the master branch.
    - commit directly to `CLUSTER_NAME` branch, this will allow the updates to continue

ELSE IF there are multiple workers in the file:
1. Once Resolved remove the worker from the in-use file in this repo [tugboat-worker-info](https://github.ibm.com/alchemy-containers/tugboat-worker-info). The directory and branch it is in will match the `CLUSTER_NAME` in the alert. Do not update the master branch.
    - commit directly to `CLUSTER_NAME` branch, this will allow the updates to continue

END IF
1. Manually resolve the PD alert.

## Escalation Policy
This automation is owned by the conductors squad. These alerts should not get escalated to a dev team during off hours. If you need support please ask in #iks-carrier-tugboat and wait till the team is available during normal hours.
See [this runbook](./tugboat-autoreloader.html) for more details on tugboat automation.
