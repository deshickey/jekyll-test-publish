---
layout: default
title: How to debug and repair chlorine bot
type: Informational
runbook-name: "How to debug and repair chlorine bot"
description: "How to debug and repair chlorine bot"
service: Conductors
link: /doc_updates/igorina.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
chlorine is a helpful bot that performns many tasks for Conductors and developers.
However, sometimes she can go wrong.  

This runbook is here to provide an understanding of chlorine, the deployment, and how to repair common issues.

## Detailed information

chlorine is a bot based on underling: https://github.ibm.com/sre-bots/underling  
They respond to task requests both on Slack and via a REST API.  


### Useful links:
* Chlorine [GHE repo](https://github.ibm.com/sre-bots/chlorine)
* 1337 secrets are defined in [GHE here](https://github.ibm.com/alchemy-1337/chlorine-bot-creds)
  * production values stored in folder: `/igorina-ha-bot-creds`
* Jenkins build & deploy job: [chlorine-ha-build](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/chlorine-ha-build/)
* Deploy defintion in the [charts repository](https://github.ibm.com/alchemy-conductors/charts/tree/master/igorina-ha)

* Runs on the `infra-Accessallareas` cluster in Fra02 (eu-central)
  * DO NOT delete Igorina Pods in this cluster - the runbook below will take you through fixing them.

### Deployment Description
Igorina production runs as 3 different shards: `green`, `blue` and `magenta`  
This is to allow us to deploy a new version of igorina without disrupting long running tasks she may be working on.

The shards are set up so that work is only performed by 1 shard at a time - it will be defined to be `master` and accepting new work `true`. The other shards will be not master, and not accepting new work.  

You can see how the shards are configured using: `botcontrol status`
```
Igorina bot (SRE)APP [10:03 AM]
BotID:`igorina-ha-green`, build:`0.0.0.0`, isMaster:`true`, jobCount:`9`, accepting new work:`true`
BotID:`igorina-ha-magenta`, build:`0.0.0.0`, isMaster:`false`, jobCount:`1`, accepting new work:`false`
BotID:`igorina-ha-blue`, build:`0.0.0.0`, isMaster:`false`, jobCount:`6`, accepting new work:`false`
```

### shutdown hooks
Igorina shards all have hooks in kubernetes to try to gracefully shutdown before they are killed.  This can take over 8 hours if Igorina is busy.

If igorina is taking a long time to shut down this is likely to be the reason.
Users will be notified that Igorina is shutting down, and a grace period will allow the majority of work to complete before the shard terminates.

### REST
Igorina's REST API is accessed over `https://igorina-ha.cont.bluemix.net`

* Fronted by a Proxy: https://github.ibm.com/sre-bots/underling-broadcast-proxy
  * It automatically handles complexity to do with igorina's sharding
* Proxy config: https://github.ibm.com/alchemy-1337/igorina-bot-creds/tree/master/igorina-broadcast-proxy-creds
* Proxy deploy config https://github.ibm.com/alchemy-conductors/charts/tree/master/igorina-broadcast-proxy

### What work is she performing?
Igorina will show all tasks that she is working on if you DM her with: `task status`  
To get details on a specific task, pass in the Ticket ID, eg:
`task status CHG0254275`
```
igorina-ha-magenta: I had a problem: I'm not working on: `CHG0254275`
igorina-ha-green:  (accepting new work) 
InProgress:[stage-dal12-carrier3-worker-1003]
Passed:[stage-dal12-carrier3-worker-02]
Failed:[]
Skipped:[]
Unstarted:[stage-dal12-carrier3-worker-01, stage-dal12-carrier3-worker-9002, stage-dal12-carrier3-worker-1002, stage-dal12-carrier3-worker-8001, stage-dal12-carrier3-worker-9001, stage-dal12-carrier3-worker-1001]
igorina-ha-blue: I had a problem: I'm not working on: `CHG0254275`
```
the responses show: 
* `igorina-ha-blue` and `igorina-ha-magenta` are not working on this task.
* `igorina-ha-green` is working on the task, has completed on one machine, is working on the second, and has 6 more to go.

### Audit log
Igorina logs ALL messages that she sends to users to an audit log in Slack:
`#bot-igorina-logging`
These are threaded by request - so if you need to know what she is working on check there.

## Common issues


### Igorina failed when looking up machine
If you get a response from igorina with the message: `I failed when looking up machine`
eg: `I failed when looking up machine prod-hou02-carrier6-worker-1141 (IP=10.76.204.191), returned 0 entrines (I'm expecting 1)`
  
This could be a problem with seer - try following the [seer runbook](./seer.html)


### A specific function has stopped working
If a function that has been working recently is suddenly not working it could be due to:
* The Igorina VPNs have failed
* A regression has been introduced
for both of these, [redeploying igorina](#redeploy-igorina) should fix it.


### Connection failures for reboot/reload attempts: `connect: connection timed out` or `err: cannot get master for worker`

This is likely a VPN problem.

- If it is happening for a single _VPN_ region, it could be the `prod-NNN-infra-vpn-NN` servers.
  - **Note that multiple regions are behind a single vpn; for example, lon, ams, mil, fra, prodfr2 are all behind the `prod-lon02-infra-vpn-NN` servers**
  - Try to reboot the VPN servers. Note that single chlorine is unable to reach them via VPN+SSH, it will reboot via SoftLayer.
- If it is happening against all regions, it is likely the `igoropenvpn` VPN password.
  - We raise a PD alert before the password is due to expire, so check for open alerts to see if it has expired already.
  - See https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_updating_igoropenvpn_password.html


### Reboot/reload errors `err: Post "http://igorina-broadcast-proxy.sre-bots.svc.cluster.local:10010/v1/new": context deadline exceeded (Client.Timeout exceeded while awaiting headers)`

If we see the following reply when chlorine is trying to reboot/reload, then it could be a bad worker in the `infra-accessallareas` cluster where the bots are running:

```
failed to check conflicting actions for machine prod-dal10-carrier2-worker-1001 (IP=10.171.78.72), err: Post "http://igorina-broadcast-proxy.sre-bots.svc.cluster.local:10010/v1/new": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
```

Move the `igorina-broadcast-proxy` pod to another worker:

1. Log into IBM Cloud via the cli: `ibmcloud login --sso`
1. Select the Support account `Alchemy Support (800fae7a41e7d4a1ec1658cc0892d233) <-> 278445`
1. Connect to the cluster: `ic ks cluster config -c infra-accessallareas`
1. Check which node the `igorina-broadcast-proxy` is running on: `kubectl get po -n sre-bots -owide | grep igorina-broadcast-proxy`
1. Check to see if the node is already cordoned: `kubectl get node` and see if it is `SchedulingDisabled`
1. Cordon the node: `kubectl cordon 10.123.185.214` (replace with actual IP)
1. Move the pod to a different node: `kubect -n sre-bots delete pod igorina-broadcast-proxy-7f9d8465b7-ckqgd` (replace with actual pod name)
1. Verify that it comes back up: `kubectl get po -n sre-bots -owide | grep igorina-broadcast-proxy`

The worker should be rebooted:

1. Drain the worker: `kubectl drain 10.123.185.214`
1. Find the worker hostname: `ic ks worker ls --cluster infra-accessallareas | grep 10.123.185.214`
1. Reboot the worker: `ic ks worker reboot --cluster infra-accessallareas --worker kube-fra05-cr19eef897d2934eb2914ca3486aa10276-w10`


### Igorina raises 2 or 3 trains for a single request
This will be because more than one shard is set to accepting new work.  You can check this by DMing Igorina the message: `botcontrol status`
you should get 3 responses, 1 for each different shard (BotID green/blue/magenta)
* 1 shard should be set to: `isMaster:true` AND `accepting new work:true`
the other 2 shards should be `false` for both.
If that is not the case, we need to set exactly 1 master. - follow the instructionsfor: `Set single master`

### Igorina is not responding.
The Easy fix should be to redeploy her using jenkins: [redeploy igorina](#redeploy-igorina)

### Igorina fails when raising a train
If you see errors like this from Igorina:
```
Post http://elba.sre-bots.svc.cluster.local:10090/v1/trains/prod: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
```
It means that the train/Change Request has failed.  This is either a problem with Elba or Servicenow.
Please see: <https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/elba_fat_controller.html> to try to fix that.
* If the above doesnt fix it, [a redeploy of Igorina](#redeploy-igorina) MIGHT fix it (but thats reasonably unlikely.)

### Need to stop Igorina working on a job

Igorina can be told to abort any task she is working on with:
* `task abort <taskID>`
she will finish the machine she is working on, and then abort the rest of the work.

If the job must be killed RIGHT NOW then see [Delete an Igorina POD](#delete-an-igorina-pod)

## Common fixes

### Set single master
This process is to ensure that the Chlorine/Igorina shards are configured correctly.

* DM Igorina: `botcontrol setmaster igorina-ha-green` 
  * or set to whichever shard you wish to be master (green is probably fine)
* check that ONLY the defined shard is now master and accepting new work
  * DM Igorina `botcontrol status`
  * only 1 shard should be set to: `isMaster:true` AND `accepting new work:true`
    * if thats not the case - see escalation policy

### Updating credentials

Credentials can expire.  A previous issue has been the IaaS APIKey being used was revoked.
The credentials are stored in [1337 repo here](https://github.ibm.com/alchemy-1337/chlorine-bot-creds/blob/master/igorina-ha-bot-creds/credentials.json)

Chlorine uses `sre.bot@uk.ibm.com` as the user which is connects to IaaS/Softlayer.  The credentials for this user are stored in thycotic and can be used to regenerated expired or revoked IaaS API Keys.

If credentials in 1337 are updated, then a standard re-deploy of chlorine will not re-deploy the secrets stored in kube.
Before running the re-deploy/re-promotion, the exists credentials need deleting.

Follow these steps to achieve this

1.  Use `ibmcloud ks cluster config --cluster infra-accessallareas` to get access to the cluster.
2.  Find the secrets for `igorina` using `kubectl get secret -n sre-bots igorina-ha-certs`
3.  Delete this secret using `kubectl delete secret -n sre-bots igorina-ha-certs`
4.  Find the latest build which is deployed and re-execute the promotion using the [chlorine HA Build jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/chlorine-ha-build/). 
_NB: a rebuild is not necessary when updating just the secrets in 1337_ 


### Redeploy Igorina
* try DMing her `botcontrol status` - she may be able to tell you what build is running - this number will help you find the right level to re-deploy.
* find the build in: <https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/chlorine-ha-build/>
* if you dont know what build to use - try the latest with a gold star against it.
* find the `promotion status` for that build, and run `re-execute promotion` for the `iks-igorina-ha-deploy` promotion.
* Igorina should then come back alive

If Igorina Still doesnt come back up, it might be that a regression has been introduced in the latest build and she is no longer working properly.
* check the (build history)[https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/chlorine-ha-build/] to see how recently the code has been changed
* if the current build is very new, try deploying the next older build with a gold star against it,


### Igorina working on Slack, but 404 with REST
This usually happens if a VPN container for Igorina is repeatedly restarting.  Kubernetes decides the container is unstable and disables the service for that igorina shard.

First [Login to the AAA cluster](#login-to-ibm-cloud-using-cli) then look at the Igorina shards:
* `kubectl -n sre-bots get pods | grep igorina-ha`
describe each of those shards and look at the VPN containers to see if any of them have restarted many times 
* `kubectl -n sre-bots describe pods <igorina pods> | grep "Restart Count:"`
If the restart count is >0 on any of those pods, there is a good chance the VPN servers may either be down, or the VPN configuration for Igorina may be broken.

You may be able to fix it by:
1) [Deleting the Igorina POD with most restarts](#delete-an-igorina-pod)
2) then [setting that pod to master](#set-single-master)
  
If that doesnt resolve the problem, it will need development assistance, raise an issue: <https://github.ibm.com/sre-bots/igorina> 
and notify the EU conductors in slack.


### Delete an Igorina POD

* generally there should be no reason to do this - the deploy job above, and taks abort will usually be enough.
If you need to kill her part way through running a task:
* Find out what shard is running the task:
run `botcontrol status`, find the task you are looking for, and note down the shard name.
  * NOTE: if the task you are interesed in is NOT listed, she is not working on it (this would normally only happen if she has delegated it to another bot - eg for smith-patch - in that case, you will need to look at smith-trigger-service)
  * killing that shard will also kill all other tasks listed by that shard
* Make a note of what the tasks are - and paste that list in #conductors-for-life slack channel including an `@eu-conductors` to notify the Igorina developers.
* Notify Igorina Users that you are restarting Igoirina.
  * DM her with `botcontrol broadcast WARNING: I'm being restarted by <your SlackID> your work might be lost`
  
* Connect to the AAA Cluster in fra02: [Login to IBM Cloud using CLI](#login-to-ibm-cloud-using-cli)
* Find the Igorina shards with: `kubectl get pods -n sre-bots | grep igorina`
The shards of interest are: `igorina-ha-blue-*`, `igorina-ha-green-*`, `igorina-ha-magenta-*`
* delete the appropriate pod with:
  * `kubectl delete pod -n sre-bots <pod-to-delete>`
The pod should be deleted, and a new one will be created.  
After a pod restarts, it will come back as not master, and not accepting new work.
Now check that Igorina is running correctly, by following the checks for [Set single master](#set-single-master)

# Collecting Debug Information
Instructions how to collect logs and other useful information needed for debugging Igorina issues.
Data collected below should be attached to GHE issue documenting the problem. 

GHE issues to track Igorina deficiencies go into https://github.ibm.com/sre-bots/igorina .

## Application logs

Steps to collect application logs are as follows:

### Use slack to determine which instance is serving your request

Run `botcontrol status` to show running instances. The command returns something like
```
BotID:`igorina-ha-green`, build:`150`, isMaster:`false`, jobCount:`0`, accepting new work:`false`
BotID:`igorina-ha-blue`, build:`147`, isMaster:`true`, jobCount:`2`, accepting new work:`true`
BotID:`igorina-ha-magenta`, build:`150`, isMaster:`false`, jobCount:`0`, accepting new work:`false`
```
Igorina has multiple instances running. One instance is the master and is actively serving new requests. 
Other instance are not accepting new work but might still be working on previous requests.
Check for `isMaster:true` to identify master instance (in above sample, `igorina-ha-blue` is the master).

You can use the ChangeID (`CHGxxxxx`) of a request to find the instance which is serving the request.
Run `task status CHGxxxxx` and check the result to see which instance is serving your request. 

Example
```
task status CHG0274849

igorina-ha-green:  (accepting new work) 
InProgress:[prod-dal10-carrier3-worker-1031]
Passed:[prod-dal10-carrier3-worker-1028, prod-dal10-carrier3-worker-1026, prod-dal10-carrier3-worker-1030]
Failed:[]
Skipped:[]
Unstarted:[prod-dal10-carrier3-worker-1033, prod-dal10-carrier3-worker-1034, prod-dal10-carrier3-worker-1035, prod-dal10-carrier3-worker-1039, prod-dal10-carrier3-worker-1040, prod-dal10-carrier3-worker-1032, prod-dal10-carrier3-worker-1036, prod-dal10-carrier3-worker-1038]
igorina-ha-magenta: I had a problem: I'm not working on: `CHG0274849`
igorina-ha-blue: I had a problem: I'm not working on: `CHG0274849`

```  
Above output suggests `igorina-ha-green` is serving request with ChangeID `CHG0274849`.

Run `task status` to see all ongoing requests on all instances. 

**If you cannot determine the instance which was serving your request, collect the logs of the master instance.** 

You have two options to collect application logs
- Use IBM CLoud Logs to get logs (preferred)
- Login to cluster and run `kubectl logs` to get logs

### Using IBM CLoud Logs to get logs

1. Log onto https://cloud.ibm.com/observability/logging using your IBM ID
2. Select account `278445 - IBM`
3. Select the log analysis instance and click on the `Cloud Logs` tab, then click on the Instance name.
4. In the navigation panel on the left click on `Views` icon, then click `SRE BOTS` and select the instance you want to see logs for.
5. Select relevant logs by entering a search term or timeframe in the search bar at the bottom (e.g. `CHG0274849` as search term, and/or something like `today 3:20pm to today 3:30pm`, `one hour ago to now` or `today 3:40pm to now` as timeframe). 


Copy & Paste relevant logs into GHE issue (only useful for limited number of log lines), or use IBM CLoud Logs's export feature to export logs and then attach the exported log file to GHE. Log export has an upper limit for the number log lines to export.

Instructions how to export logs from LogDNA can be found at https://docs.logdna.com/docs/export-lines .

If you not sure how to get relevant logs only, consider using `kubectl logs` to export all logs for a given instance (see instructions below).


### Using kubectl to get logs

#### Login to IBM Cloud using CLI

* Login to IBM Cloud CLI ` ibmcloud login --sso` 
* select account ` Alchemy Support (800fae7a41e7d4a1ec1658cc0892d233) <-> 278445`

* Set kubeconfig `ibmcloud cs cluster config  --cluster infra-accessallareas` 

Show Igorina pods `kubectl get po -n sre-bots | grep igorina-ha` , this returns something like

```
igorina-ha-blue-79dc9d4c5b-rsc96            7/7       Running   180        6d
igorina-ha-green-7fb96df65-4mdxd            7/7       Running   143        5d
igorina-ha-magenta-6b58d5776f-67kmx         7/7       Running   131        5d
igorina-ha-test-7fbd5557fc-vjc65            5/5       Running   75         5d
```

#### Get Application logs

You need to collect the logs of the instance which was serving your request (see above instructions to determine which instance was serving your request). Every instance is represented by a pod. Pod name starts with the instance name.

Example below assumes you identified instance `igorina-ha-blue` being the instance serving your request and pods are named as
shown above. The pod has multiple containers. Its sufficient to collect logs for the container named like
the master instance. 

`kubectl logs igorina-ha-blue-79dc9d4c5b-rsc96 -n sre-bots -c igorina-ha-blue --timestamps > igorina-logs.txt`

to limit timeframe you can use 

`kubectl logs igorina-ha-blue-79dc9d4c5b-rsc96 -n sre-bots -c igorina-ha-blue --timestamps --since=2h > igorina-logs.txt`

Replace pod name and container name. 

Attach logs to the GHE issue.


## Audit logs
Audit logs are available in slack channel #bot-igorina-logging .

Go to #bot-igorina-logging and type `ctrl-F / command-F` to open the search bar. Search for train ID, machine name/ip or your name to find logs related to the failing Igorina command. 

Attach link(s) to relevant slack message(s) to the GHE issue documenting the problem.

# Escalation Policy

There is no formal escalation policy.

This is an SRE owned tool so should be raised and discussed in either

- `#conductors` if you are not a member of the SRE Squad. (mention `@conductors-eu`)
- `#sre-cfs` or `#sre-cfs-patching` if you are a member of the SRE squad (these are internal private channels)
- Raise GHE issues in https://github.ibm.com/sre-bots/igorina
