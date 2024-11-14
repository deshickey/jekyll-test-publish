---
layout: default
description: Instructions for reloading a carrier master
title: Reloading a Carrier Master Node
service: armada-carrier
runbook-name: "Reloading a Carrier Master Node"
tags: armada-carrier, carrier, master, reload
link: /armada/armada-carrier-reload-carrier-masters.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook provides steps for reloading an existing carrier master. It covers manual steps needed to do a master reload.

## Note

For master reloads.

1. If you are reloading all 3 masters , Alaways reload masters in the sequence of master03, master02 and then master01.
2. Notify interrupt in #sre-cfs channel with the master node details that that will undergo reload .
3. Keep the status of master reloads like the number of reloads that have been completed and the number that are still pending in Handover notes.

## Assumptions

All work in production needs to have prod-trains approval. Please make sure that the on-call conductors have cleared you for performing the work outlined in the steps below.

## Detailed Information

### Manual reload steps

1. Ensure that the other 2 masters are healthy, and that there are no alerts for the environment, before reloading the 3rd. Execute the steps in [Validate master section](#master-validation) and [Validate etcd health section](#validate-etcd-health) on each master node before continuing.

2. Issue a reload via IBM Cloud Infrastructure, and wait for completion.
   1. Log into [IBM Cloud](https://cloud.ibm.com/login) and switch to the correct account.
   1. Click on **Classic Infrastructure**
   1. Select the appropriate machine from the list
      _The `OS Reload` option isn't available from the machines list screen_
   1. Go to `Actions -> Load from image`.
   1. Select the **second-most-recent image** from the list of images based on created date, e.g. `armada-worker-20220728.1`.
   _Do not select the most recent, as it may still be under test_
   1. You need to update the **post-provision script** field to point to the correct `bootstrap-one` endpoint.
   _If you are unsure, [see bootstrap-one](https://github.ibm.com/alchemy-conductors/bootstrap-one#os-reload) repo for full details of the endpoint to use._
   _**NB. Remember to select** : the `jenkins` ssh key!_
   1. Leave `OS Reload with Disk Preservation` unchecked.
   1. Agree to any confirmation pop ups and then wait for it to complete.

3. Monitor progress of the reload action

   Monitor the progress of the reload in the [IBM Cloud Infrastructure](https://cloud.ibm.com/classic) portal.

   A timer icon will appear when a reload transaction is in progress. Once this disappears, the reload would have completed.

   _**If, after several hours, the timer icon is still present, hover over it to get status and raise a support case against IBM Cloud Infrastructure to investigate why the reload has stalled.**_

4. Once the above steps are complete, we need to confirm that **bootstrap** and **smith patching** have completed successfully.
Run the Jenkins Job [check-bootstrap-and-smith](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/job/check-bootstrap-and-smith/build), and search in the log results for following the following phrases:
   _NB. you will see a "skipped machines" list if the Jenkins couldn't `ssh` to any of the machines specified in the Job's parameter_
   - `error bootstrap did not pass`
   - `error smith did not pass`

   **Note: this is a simple job. It is possible for the job to succeed, and the machines not be bootstrapped/smith-patched. You must look at logs to determine status**
   **If any issues are hit with bootstrap or smith patching, further investigation will be needed.**
   **Seek assistance from other SREs if you are unsure!**

5. Once confirmed that the machine is bootstrapped and patched, **reboot the machine via IBM Cloud Infrastructure** to ensure that it comes up with the latest patches and kernel.

   **Note: if this step is missed, the machine will not be fully patched and is a compliance risk**

6. Add node to bastion

   After a successful patch and reboot, we must add the node to bastion.

   1. Go to this job [bastion-register-nodes-ww](https://alchemy-containers-jenkins.swg-devops.com/job/armada-ops/job/bastion-register-nodes-ww/) and `Build with parameters`

   2. Enter `TARGET_HOSTS_IP` as the node IP which need to be registered to bastion.

   3. Enter `TARGET_HOSTNAME` as the hostname of the machine you are registering or one hostname from the same region. Example: if the node region is `prod-wdc06` then pick one of worker of that region ie `prod-wdc04-carrier1-worker-1001`. This is used to figure out which bastion to add the target node to.

   4. Leave `Branch` field unselected, default is `master`

   5. Monitor the output of jenkins job and make sure it succeeds. If it fails for some reason, open a [conductors team issue](https://github.ibm.com/alchemy-conductors/team/issues) with output of jenkins job and label the issue as `bastion`.

7. Deploy the reloaded master node back into the cluster.
   - Find recent [deploy job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/) by sre.bot in #armada-runtime.
   _Match environment. ie if its prod, select a prod deploy to use as template_
      - `Environment` and `Carrier` to match your carrier
      - remove any workers listed in `WORKERS`
      - select box `SKIP_WORKERS`
   - If deploy job fails for etcd health check ,follow the steps mentioned [etcd failure recovery](#etcd-failure-recovery)
      - Then re-run the [deploy job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/) to complete the deployment

8. [Redeploy armada-data](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-redeploy-data-cli/)
   - This job **must only be run if a `-master-01` node is reloaded**, as they are the only masters which have the `armada-data` tool. The specific masters are in the [envs](https://github.ibm.com/alchemy-containers/pd-tools/blob/master/envs/prod-regions) files.
   - This job also runs a quick smoke test to make sure the cli is working.
   - Prod trains are automatically handled by this job using the most recent deployment in the region.

9. [Validate master](#master-validation) is now running and part of the cluster.

10. [Validate etcd health](#validate-etcd-health) to confirm etcd cluster is healthy.

## Master Validation

We validate that a master is successfully running after a reload and re-deploy by ensuring that the following containers are running on the node:

- kube-scheduler
- kube-controller-manager
- calico-node
- kube-apiserver
- node-exporter

Ensure the following command, run on the master, returns `success`

```text
if [[ $(sudo crictl ps | grep -E "kube-scheduler|kube-controller-manager|calico-node|kube-apiserver|node-exporter" -c) -eq 5 ]]; then echo success; else echo failure; fi
```

If something other than `success` is returned, further investigation is required.

## Validate etcd health

Check etcd health of the master nodes by running the steps in [this runbook](./armada-carrier-carrier-component-troubled.html#etcd-debugging)

We expect output like this

```text
member 121204475412c6fd is healthy: got healthy result from https://10.95.59.98:4001
member 391975749cdc87e4 is healthy: got healthy result from https://10.185.132.132:4001
member d59a97d23c8ef0db is healthy: got healthy result from https://10.209.87.109:4001
cluster is healthy
```

## etcd-failure-recovery

Steps to be followed in case when 1 etcd members of etcd-cluster is not healthy.
**Note**: DO NOT follow these steps if more than 1 etcd member is unhealthy
List etcd members

```text
source /opt/bin/etcd-rc; ETCDCTL_API=3; /opt/bin/etcdctl member list
```

Remove unhealthy etcd member found in above list

```text
source /opt/bin/etcd-rc; ETCDCTL_API=3; /opt/bin/etcdctl member remove <member-id>
```

Perform the following steps on master on which etcd is unhealthy
Stop etcd service

```text
sudo systemctl stop etcd
```

Move etcd data

```text
sudo mv /var/etcd/data /var/etcd/data.20210616.broken
```

Add etcd member

```text
source /opt/bin/etcd-rc; ETCDCTL_API=3; /opt/bin/etcdctl member add etcd0 --peer-urls "https://IP:port"

example: source /opt/bin/etcd-rc; ETCDCTL_API=3; /opt/bin/etcdctl member add etcd0 --peer-urls "https://10.138.6.6:2380"
```

Make sure etcd service config is consistent with output from above command.

```text
cat /usr/lib/systemd/system/etcd.service
```

In the output check for `--initial-cluster` and `--initial-cluster-state` which should look something like this:

```text
--initial-cluster "etcd0=https://10.130.231.164:2380,etcd1=https://10.130.231.247:2380,etcd2=https://10.130.231.254:2380" \
--initial-cluster-state existing \
```

(If not), update etcd.service then run 
```text
`sudo systemctl daemon-reload`
```

Start etcd

```text
sudo systemctl start etcd
```

## Escalation Policy

If you are unable to perform the above steps and a CIE has been raised, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.

## Related runbooks

- [Reload Carrier Worker Node](./armada-carrier-reload-carrier-workers.html) - this has detailed information about reload steps for a worker node and may help with steps in this runbook.
