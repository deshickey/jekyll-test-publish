---
layout: default
title: Patching procedure
type: Informational
runbook-name: "Patch procedure runbook"
description: "This runbook explains the procedure to follow when patching all IKS machines."
service: Conductors
link: /patching_rollout_procedure.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document describes the operations required for running `smith` patching through smith-red-pill  

## Detailed Information

Patching is critical process for keeping the OS stable and secure, but if not implemented in a controlled manner can create lots of problems with the applications running on the machine. This process defines a patching strategy to minimize disruption to customers and increase the stability of our application. 


# 1. Execution  of `smith` patching

The document structure is :

1. **This overview**

1. **Process flow**  
_Overview of the end-to-end patch process_

   - **Useful config links**  
   _Links to the config we use for patching_

1. **Pre-patching checks**  
_Checks to make before kicking off patching_

1. **Roll out process**  
_Describes the phases and the sequences involved in performing patching_

   - **How to patch the IKS/Argonauts environments**  
   _The approach to take to roll out patch updates across all our estate_
   
1. **Reboot process**

1. **Supplementary materials**  
_There are various tools to assist when manually patching or when diagnosing the state of the system_

# 2. Process flow

The [Applying new patches section of the patching process runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/patch_process_runbook.html#applying-new-patches) describes the process we follow - please ensure you are familiar with this process before commencing patching.

If unsure, discuss in the [#sre-cfs-patching](https://ibm-argonauts.slack.com/archives/G53A0G8CU) channel.

## 2.1 Useful config links :  

The configuration files used in the patching process are:

- [Red pill Patching configuration files](https://github.ibm.com/alchemy-1337/smith-red-pill-creds/tree/master/smith-red-pill-test/smith-red-pill-test-configurations)  
_these detail which regions to kick off and the post patching tests/steps to execute_
- [Trigger service configuration files](https://github.ibm.com/alchemy-conductors/smith-trigger-service/tree/master/phases)  
_these detail the exact machines/sets of machines to patch/reboot and in what order. These files are referenced from the red-pill config files_


# 3. Pre-patching

A new Smith Build is created weekly via the [SmithPackageBuilder-V2](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SmithPackageBuilder-V2) Jenkins Job.

After a successful build of the SmithPackageBuilder-V2 job, it will raise a new templated epic issue in [smith-trigger-service/issues](https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues) with title `BUILD #nnnn : Tracking Patching for Worldwide Rollout`. This is the epic used for tracking the rollout. It contains checklists to guide the manual steps.

After a successful build of the SmithPackageBuilder-V2 job, the new smith build must be synced to the worldwide mirror hosts (`dev-mon01-infra-apt-repo-mirror-01`, `prestage-mon01-infra-apt-repo-mirror-01`). The Builder job kicks off the [SmithPackageSync-V2](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SmithPackageSync-V2/) job automatically.

After a successful build of the SmithPackageSync-V2, a comment is added to the GHE epic issue.

A number of other jobs are also kicked off to validate that the build and sync were successful. Links to these jobs must be added to the GHE epic issue, per the template.

A high-level overview of the builds is maintained in this [box note](https://ibm.ent.box.com/notes/686790031517): each week a link to the GHE epic and the kernel version is added.

## 3.1 Verify that the build succeeded and created an epic in smith-trigger-service/issues

Check in [smith-trigger-service/issues](https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues) for an issue with title `BUILD #nnnn : Tracking Patching for Worldwide Rollout`.

The issue should be created by a successful run of [SmithPackageBuilder-V2](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SmithPackageBuilder-V2) - Jenkins build create the new `apt` repo

A comment should be added to the epic by [SmithPackageSync-V2](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SmithPackageSync-V2/) - Jenkins build to `rsync` the `apt` repo to the mirrors

## 3.2 Ensure that patching bags are valid

Review the latest output from [armada-server-patching-gap-checker jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Security-Compliance/job/armada-server-patching-gap-checker/)  
_The job compares Softlayer and our patching bags in [smith-trigger-service phases](https://github.ibm.com/alchemy-conductors/smith-trigger-service/tree/master/phases)_

If any problems are discovered use the runbook [sre_patch_gap_issues](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_patch_gap_issues.html)  
_NB: Any updates to patching bags will require a re-build and re-deploy of smith-trigger-service.<br>See [smith-trigger-service for details](https://github.ibm.com/alchemy-conductors/smith-trigger-service/blob/master/README.md)_

Add a link to the GHE epic - see the details in the epic.

## 3.3 Check the Mirror Status

The sync job also kicks off the following job, which reports a success/fail of the sync to all mirrors:
- [**SMITH MIRRORS - Report Mirror Status**](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Report%20Mirror%20Status/)
- Investigate any failures and re-run the sync job if required

### 3.3.1 Monitoring the progress of the jobs
Progress of building & synching can be monitored via the cloud.ibm.com. The job's output can been followed using the [kubernetes dashboard](https://eu-de.containers.cloud.ibm.com/kubeproxy/clusters/19eef897d2934eb2914ca3486aa10276/service/#!/overview?namespace=default) for the Access All Areas cluster, specifically [**Workloads > Jobs**](https://eu-de.containers.cloud.ibm.com/kubeproxy/clusters/19eef897d2934eb2914ca3486aa10276/service/#!/job?namespace=default)
1. Navigate to https://cloud.ibm.com/  
_Ensure that you select the account `278445 - Alchemy Support`_

1. Navigate to **Kubernetes > clusters**

1. Choose **infra-accessallareas** cluster from the list

1. On **infra-accessallareas** cluster page, navigate to the **Kubernetes dashboard**  
_It should open a new browser page presenting options for viewing many aspects of the k8s cluster_

1. In the **Jobs** section, find the job that you wish to investigate  
_use the logs symbol (shown in the red box in the image below) to get the logs from that job_
   <img width="1000" alt="Screenshot 2020-05-12 at 10 29 38" src="https://media.github.ibm.com/user/246531/files/4c766e80-943c-11ea-8799-fbf8cdb5e067">

1. Within the **Logs** page, a paginated view of the logs is available - pagination controls on the bottom right. There drop down menu on the top left can be used to select the logs for the specific **container** (i.e. VPN region) that you want to view logs for.

1. To allow you so see **recent** completed `rsync` runs, use the following URL:  
[LogDNA _(with a selection filter of "GOOD rsync completed cleanly")_](https://app.us-south.logging.cloud.ibm.com/ca1620a740/logs/view?q=GOOD%20rsync%20completed%20cleanly)  
_**NB.** For the link to work correctly, you'll need to:_  
   - _have your `cloud.ibm.com account` set to `278445` (the support account)_  
   _It doesn't appear possible to change is **on** the LogDNA page!_
   - _**possibly** use the URL twice as sometimes the URL's `query string` is lost_ 

## 3.4 Management of `apt-repos`

There are two sets of storage associated with `smith` which hold the Ubuntu APT repos:
- **4TB** _main_ storage located in the AAA cluster in account xxxxx  
_Where builds are created and replication occurs **from**_

- **2TB** _mirror_ storage located in each VPN region required  
_Where builds are replicated **to** and where machines in the region reference for `apt`_

Old builds are purged from the source 4TB disk on a weekly basis via the [SmithPackagePurge-V2](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SmithPackagePurge-V2/) job.

### 3.4.1 Manual build management

_Note: the `SmithPackagePurge-V2` job means that manual build management should not needed. Leaving these notes in place in case manual intervention is required._

To assist with managing builds on the 4TB main storage (and hence what can be synced to the 2TB) a scripted solution has been implemented `smithpurge.sh`  
_See https://github.ibm.com/alchemy-conductors/smith-packages/tree/master/scripts/purge_

By design the script is stored in the 4TB disk and hence can be used by any pod which has mounted the 4TB disk.

The script has been created to help with the manual purging of old builds whilst reducing the errors possible with the previous commandline based approach.  
`TODO : MAKE INTO A LINK --> _NB. The old manual steps have been moved to section [6.1.5](./patching_rollout_procedure.md#615-manual-steps-to-manage-the-apt-repos) below_`

_Note that build management only needs to take place on `AAA` 4TB disk as **replication** "automatically" sorts out the mirror machines!_

---
> ### _PRE-REQs_
> To make use of the script, a suitable pod (with the 4TB disk mounted) needs to be running in the `AAA` cluster.  
> _Typically, we use the `smith-builder` pod for such work - but any suitable pod would do._

---

Access to a suitable pod
1. Login to cloud.ibm.com and select account 278445  
`ibmcloud login -sso`
   
1. Connect to the AAA cluster  
`ibmcloud ks cluster config -c infra-accessallareas`

#### Steps to purge builds
_Discuss with the squad which builds can be archived if you are **at all** unsure!_  
_NB. Whilst working in this area it is possible to make a non-recoverable error - be **very careful**_

To purge builds run `smithpurge.sh` with the **purge flag** and a list of builds (within quotes for multiple builds) you want to purge:  
`kubectl exec smith-builder -- /scripts/smithpurge.sh -p "BUILD NUMBER [BUILD NUMBER ...]"`  
_The example assumes that the **`smith-builder`** pod is available!_

## 3.5 Obtain package lists of new build

We need to save and store the package lists from the apt repository we have built and are intending patch with.

These must be attached to the GHE EPIC created earlier.

View the latest [getPackageListsAndCompare](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/getPackageListsAndCompare/) jenkins job (which was automatically executed after the SmithPackageSync-V2 job) and attach the artifacts to the EPIC.  The artifacts will include the package lists for the new repo, and the differences versus the current `prod` repo.
  - Download all the artifacts by viewing `Last Successful Artifacts` and selecting `All files in zip`
  - Review the `...ubuntu16_diff.txt` and `...ubuntu18_diff.txt`files. You can search for `linux-virtual` to determine if there is a kernel package

# 4. Roll out process

How to patch the IKS / Armada fleet using Smith-Red-Pill.

Patching of the armada fleet using smith-red-pill manually involves running the program multiple times, each with a separate configuration file, outlined below:

Details of each [yaml] config file can be found in [smith-red-pill-creds](https://github.ibm.com/alchemy-1337/smith-red-pill-creds) and appropriate steps to follow described below.

## 4.1 Manual preparation

Verify that a new epic was created in [smith-trigger-service/issues](https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues) with title `BUILD #nnnn : Tracking Patching for Worldwide Rollout`.

## 4.2 Overview of pre-production testing

The new build will be rolled out to increasing sets of pre-production machines:

- Stand-alone test machine(s) in dev
  - Patch + reboot + healthcheck is performed
- A subset of 15-20 machines (including carrier masters) in dev, prestage, stage
  - A total of around 60 machines across the environments will be patched, rebooted and healthchecked. This is to give us confidence that the latest smith build is safe to roll out to all of production.
- The remainder of dev, prestage, stage
  - Patch + reboot if necessary is performed

This allows the build to be fully tested before releasing to production.

## 4.3 Build Testing and Validation (dev to stage)
Validate the smith build by executing _patch+reboot+healthcheck_ on a subset of machines in each of the environments from development through to stage clusters.

_Reboots *will* occur if required (os flag determines if a reboot is necessary)_ 

The following actions will be taken:

1. A dedicated dev machine will be patched + rebooted + healthchecked

1. 15-20 **dev** machines patched + rebooted (if necessary) + healthchecked

1. 15-20 **prestage** machines patched + rebooted (if necessary) + healthchecked

1. 15-20 **stgiks** machines patched + rebooted (if necessary) + healthchecked

1. The remainder of **dev, prestage and stgiks** machines will be patched + rebooted (if necessary)

### 4.3.1 Execute the patching

Issue the command to submit patching (from [#redpill bot](https://ibm-argonauts.slack.com/archives/D02JVCZ8GUW))   
`patch <apt-repo-number> config:buildTestDevToStage`  

For example: `patch 725 config:buildTestDevToStage`

You're expecting to see a response like:
   > `starting project ID: 1929 patch 725 onto config buildTestDevToStage`

- Notes:
   - This command will chain together patching and roll it through all environments up to, and including a stage clusters.
   - Monitor the progress via the GHE tickets created in [smith-trigger-service GHE repo](https://github.ibm.com/alchemy-conductors/smith-trigger-service).
   - **Remember** to manually add all GHE tickets created to the GHE EPIC tracking the rollout of the new apt-repo.

### 4.3.2 Actions to take if there are failures

The `buildTestDevToStage` config has acceptable failure rates built into each environment.

Individual machines may fail to patch or reboot or fail healthchecks for a variety of reasons:

- problems with IaaS networking or compute
- problems with dependent services (e.g. chlorine, lookup service)
- problems with one of the deployment jenkins jobs (e.g. bastion, armada deploy)

Individual machine failures should be examined by checking the [debugging problems with machines failing to patch](#614-debugging-problems-with-machines-failing-to-patch) section. We may need to re-run the patching, or reboot, or healthchecks manually. Or if the machine is unhealthy, it may need to be reloaded via chlorine.

A small number of individual machine failures is generally not indicative of a _problem with the smith build itself_. They should be investigated but generally should not hold up the rollout. By comparison, a _failed healthcheck on every machine_ would indicate a problem.

If unsure, discuss in the [#sre-cfs-patching](https://ibm-argonauts.slack.com/archives/G53A0G8CU) channel.

If the phase itself fails, or needs re-running, we may need to re-issue the `buildTestDevToStage` config:
   - We can issue a particular `step` of the config by using the optional `step` argument to red-pill.
     - Use `showconfig CONFIG_NAME` to see the list of steps in each config.
     - For example `patch 1359 config:buildTestDevToStage step: rebootPrestageOnly : reboot prestage`
     - Issue `help` as a DM to red-pill to see further help details.
   - When **re-running** such a config, please ensure that you:
      1. close the **previous** instance of the GHE
      1. link the **new** GHE to the same epic as the previous "child" GHE is linked to

##   ------------------ HARD STOP ------------------

### 4.3.3 Wait 24 hours in stage

 Wait 24 hours after the start of `rebootStgiksOnly : remainder of stage` before proceeding to Worldwide roll-out.

## 4.4 Production rollout
Submitting patching of production machines consists of:

1. Setting the `prod` [symlink] level  
   _This operation should be performed once we are certain that the current level IS going out to production machines_

1. Patch + reboot (if necessary) a single prod region and review

1. Patch + reboot (if necessary) remaining prod regions

We can proceed with the steps _Patch Production_ and _Update and roll out immutable image_ in parallel.

### 4.4.1 Updating the prod symlink

---
> ### _PRE-REQs_
> - **All** `buildTestDevToStage` steps have **successfully** completed

---

Once production patching is **initiated** (i.e. we **intend** to use the `smith` build currently being rolled-out into production **for** production), update the `prod` symlinks being used.

As this is changing a value in production, it requires a train to be raised.

1. Raise `VendoredOrNonBuilt` trains for all of the prod regions to request changing the prod symlink. Use the follow train template, filling in the values:  
   - `AAAA` is current smith _prod_ build.
   - `BBBB` is the _latest_ smith build, which will become the new prod version.
   - `CCCC` is the issue number of the `smithBuildTest` epic for this build.
   - In `StageDeployDate` assing the date, in `YYYY-MM-DD` format, of when the `stage-patch` issue was created, e.g. https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues?q=is%3Aissue+is%3Aclosed+label%3Astage-patch. For example for [this `stage-patch` issue](https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/16300), the date to insert would be `2024-03-28`.
   ```
   Squad: conductors
   Service: redpill
   Title: Update the smith-patching prod symlink from AAAA to BBBB
   Environment: eu-central us-east us-south uk-south ap-north ap-south jp-osa ca-tor br-sao eu-fr2 eu-es
   Details: |
    Testing has been completed from dev to stage in this epic https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/CCCC
    To update the prod symlink, run this jenkins job https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Update%20PROD%20symlink/
   Risk: low
   DeploymentImpact: small
   DeploymentMethod: automated
   PlannedStartTime: now
   PlannedEndTime: now + 1h
   StageDeployDate: YYYY-MM-DD
   VendoredOrNonBuilt: true
   SecurityOnly: true
   BackoutPlan: Revert to previous value
   ```
1. Start the trains, once approved
1. Update the `prod` **_symlinks_** to point to the _latest_ build
   - Execute the Jenkins job [SMITH MIRRORS - Update PROD symlink](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Update%20PROD%20symlink/build?delay=0sec)  
   _The job takes just one parameter, **build number**_
   - Monitor the job to confirm a successful run  
   _There are separate **log** files stored against the job for each `mirror` machine processed_
1. To complete the `VendoredOrNonBuilt` trains, we must provide evidence that the change has completed successfully.  
   - Create a new file in the conductors team repo in the [team/train_evidence/smith-prod-symlink](https://github.ibm.com/alchemy-conductors/team/tree/master/train_evidence/smith-prod-symlink) folder.
   - Use the filename `smith-prod-symlink-BBBB-evidence.txt`, where `BBBB` is the new prod symlink version (matching the details in the trains)
   - For the file contents, copy in the _URL of the specific jenkins job used to update the symlink_, together with the _output of that job_. See example below:
     ```
     Job: https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Update%20PROD%20symlink/183/console
     
     Started by user patrick.doyle@ibm.com
     Running as SYSTEM
     [EnvInject] - Loading node environment variables.
     Building remotely on docker-003zv0a7tz746 on Alchemy Private Swarm (dockerbuild-golang-latest-bx) in workspace /home/jenkins/workspace/Conductors/Conductors-Infrastructure/SMITH MIRRORS - Update PROD symlink
     [ssh-agent] Looking for ssh-agent implementation...
     [ssh-agent]   Exec ssh-agent (binary ssh-agent on a remote machine)
     ...
     etc
     ...
     Archiving artifacts
     [description-setter] Description set: UPDATING  PROD SYMLINK TO 1268
     Finished: SUCCESS
     ```
1. Once the evidence file has been committed, send a DM to the [fat-controller](https://ibm-argonauts.slack.com/archives/D01B2KNAL5V) bot to complete the train.  
   Use the following template, replacing the values as required:
   ```
   complete train CHG001 CHG002 CHG001 CHG001 CHG001 CHG001 CHG001 CHG001 CHG001 CHG001
   testURL: https://github.ibm.com/alchemy-conductors/team/blob/master/train_evidence/smith-prod-symlink/smith-prod-symlink-BBBB-evidence.txt
   testPassed: true
   ```
   _**NOTE:** Slack may automatically add a formatted URL for the `testURL` value (blue, underlined); if so, please remove it so that the value is just plain text_

### 4.4.2 Patch + Reboot `ap-south` production as a Canary region

To further validate the new build, we will patch and reboot a single production region first, before rolling out to all of worldwide.

1. Issue the command to submit patching (from [#redpill bot](https://ibm-argonauts.slack.com/archives/D02JVCZ8GUW))   
`patch <apt-repo-number> config:rebootProductionAPSouth`  
_e.g. `patch 725 config:rebootProductionAPSouth`_  
_You're expecting to see a response like_
   > `starting project ID: 929 patch 725 onto config rebootProductionAPSouth`
1. Monitor the progress via the GHE tickets created in [smith-trigger-service GHE repo](https://github.ibm.com/alchemy-conductors/smith-trigger-service).
1. Review the completed patch for potential issues.

### 4.4.3 General `armada` patching + rebooting

If there were no issues arising from patching of `ap-south`, then proceed with the rest of production patching.

1. For each of the prod regions below, issue the commands to submit patching _in parallel_ (from [#redpill bot](https://ibm-argonauts.slack.com/archives/D02JVCZ8GUW))   
   `patch <apt-repo-number> config:CONFIG_NAME`
1. Prod regions:
   _Note: there is built in protection in the reboot config files so that MZRs are patched and rebooted in series_
   ```
   rebootProductionAPNorth
   rebootProductionEUCentral
   rebootProductionEUEs
   rebootProductionUKSouth
   rebootProductionJPOsa
   rebootProductionCATor
   rebootProductionUSEast
   rebootProductionUSSouth
   rebootProductionBRSao
   rebootProductionEUFr2
   supportOnly
   ```

- Notes:
  - Monitor the progress via the GHE tickets created in [smith-trigger-service GHE repo](https://github.ibm.com/alchemy-conductors/smith-trigger-service).
  - **If failures occur, these _`MUST`_ be investigated and fixed prior to continuing further!**
   
### 4.4.4 Haproxy patching

Note that haproxy patching is now performed as part of each regional rollout, e.g. `rebootProductionAPSouth`, `rebootProductionAPNorth` etc. It is the last step in each of the regional configs.

# 5. Dealing with Reboot Failures

Any failures in rebooting must be investigated, and all machines must be rebooted to avoid any gaps in our patch level.

If the initial run of reboots fails, kick off that specific configuration again via redpill TEST bot. The different configurations can be found by running `listconfigs` in Redpill.

If the second attempt at rebooting fails, some investigation will need to be carried out to avoid continued failures
- Search for the failed machine or the change request mentioned in the rebooting GHE in the [#bot-chlorine-logging](https://ibm-argonauts.slack.com/messages/CDG1R2D5Y) channel to understand where the reboot failure occurred.

- If no obvious issues can be identified from searching in Slack, attempt to ssh to the machine and ensure it is pingable  
_If it can't be accessed or pinged, it may require a reload_

- Attempt to reboot the failed machine by itself via Chlorine bot

- Work with the SRE squad to understand the error and fix any issues with the machine.

# 6. Supplementary materials 

## 6.1 Useful debug tools

### 6.1.1 Check the smith-red-pill and smith-trigger-service pods

We can check whether the _smith_ pods are running, when they were last restarted, and whether they are producing logs.
- Note that there is no mechanism to save state between instances of the pods, so if they are restarted any `smith-red-pill` _projects_ or `smith-trigger-service` patch jobs are lost.

   1. Login to cloud.ibm.com account 278445, for example using SSO  
   `ibmcloud login -sso`
   1. Connect to the AAA cluster  
   `ibmcloud ks cluster config -c infra-accessallareas`
   1. Check if the pods are running, and when they were restarted:  
   `kubectl get po -n default -owide | grep -e smith-trigger -e smith-red`
   1. Optionally check logs to see if the pods appear to be responding, for example:  
   `kubectl -n default logs smith-trigger-service-prod-78b9fdd795-stj84 -c smith-trigger-service-prod --tail=20 -f`
   1. Optionally check the service to see what ports are in use:  
   `kubectl describe service smith-trigger-service-prod`

#### Building and deploying the pods

The `smith-trigger-service` pod deployment process is described here: [https://github.ibm.com/alchemy-conductors/smith-trigger-service#build-and-deploy-in-iks](https://github.ibm.com/alchemy-conductors/smith-trigger-service#build-and-deploy-in-iks)

The `smith-red-pill` pod deployment process is described here: [https://github.ibm.com/alchemy-conductors/smith-red-pill#building-red-pill](https://github.ibm.com/alchemy-conductors/smith-red-pill#building-red-pill)

#### Check projects via port forwarding

Normally we can query `smith-red-pill` projects by issuing `task status` against the Slack bot.

If Slack is unavailable:

- Log into 278445 and `infraaccessallareas` as noted above.

- Set up port foward  
`kubectl port-forward service/smith-red-pill 11240:11240`

- manually get the status of:  
_(e.g. when slack is down)_

   - a single project  
   `curl --write-out "HTTPSTATUS:%{http_code}" --request GET http://127.0.0.1:11240/v1/queryproject/<Project ID> -H Accept:application/jsonpe:application/json`
   
   - all ongoing projects  
   `curl --write-out "HTTPSTATUS:%{http_code}" --request GET http://127.0.0.1:11240/v1/queryproject/ -H Accept:application/jsonpe:application/json`
   
- Manually get the Audit log (if you need more details)  
`curl --write-out "HTTPSTATUS:%{http_code}" --request GET http://127.0.0.1:11240/v1/queryproject/<Project ID>/audit -H Accept:application/jsonpe:application/json`

### 6.1.2 Debugging Build and Sync issues using LogDNA

[LogDNA](https://app.us-south.logging.cloud.ibm.com/ca1620a740/logs/view) can be used to investigate issues encountered with the build and sync jobs.
1. Navigate to https://cloud.ibm.com/  
_Ensure that you select the account `278445 - Alchemy Support`_

1. Navigate to **observability**

1. Choose **Logging**

1. On the **Logging** page, choose **IBM Log Analysis with LogDNA-pgt**

1. Use the **all apps** dropdown menu to select the appropriate sync/build job

### 6.1.3 Rectifying a failed sync to a specific environment

To successully `smith` patch all machines, all mirrors need to have the latest builds available, and need to have sync'd successfully - prior to patches being rolled out to all environments. If one or more mirrors fail to sync, each mirror needs to be corrected prior to patching in each affected region.

To manually recover a mirror that has failed to sync properly, the following needs to be done:

1. Create a suitable target (for fast synching)  
_To allow the minimum amount of network traffic to be used_

1. Perform the full sync  
_Without "automatic" acceleration in operation on the Jenkins - it is achieved manually_

1. Recreate a next directory if necessary

#### Steps to follow:
1. Create a suitable target on the mirror to help peform a fast sync by renaming the `next` directory to the **new** build  
   1. If a `next` directory is not already present on the mirror, create one using [SMITH MIRRORS - Ensure that a NEXT directory is present](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Ensure%20that%20a%20NEXT%20directory%20is%20present/)  
   _The "next" dir process is required as post-processing is performed on the `next` dir to minimize the need for `rsync` to replace [otherwise] identical files_
   1. Create the target by renaming the mirror's `next` directory to the required target build using [SMITH MIRRORS - Rename directory to `next`](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Rename%20directory%20to%20%60next%60/).
   - `directory_to_rename` should be set to `next`  
   - `new_directory_name` should be set to the new build number.  
   
   Run the job in **read only** mode first to check that it is going to do what is expected. Once the **read only** job has finished and the output been checked, re-run the job, this time un-ticking the **read only** option.
1. Perform a sync using [SmithPackageSync-V2](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SmithPackageSync-V2/)  
_Leave the `MAKE_USE_OF_NEXT_DIR_ACCELERATION` **unticked** so that a automated "accelerated sync" isn't run_ 
1. Create a new `next` directory (if required) by duplicating the new build that has just synced to the mirror using [SMITH MIRRORS - Ensure that a NEXT directory is present](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Ensure%20that%20a%20NEXT%20directory%20is%20present/)  



### 6.1.4 Debugging problems with machines failing to patch

All machines **must** be patched (which sometimes needs a reboot to be complete) for **compliance** reasons - no "gaps" can be left.

Below are options for patching machines which failed to be patched during normal RedPill operation:
- The patch can be re-attempted via Igorina  
`smith-patch <build-number> machines: <machine-name/IP> outage:0`  
_if this attempt fails, try one of the steps below_
 

If a machine fails to patch, this should be investigated and resolved to avoid leaving any gaps.

There are several things to check when trying to determine the cause of the failure:
- **Re-attempt via Chlorine Bot**  
The patch can be re-attempted via Igorina (if this second attempt fails, the steps below can help further investigation)

- **Manually investigate and take appropriate actions if possible**  
_NB. A jenkins job is **under development** to simplify this process - [PurgeOldKernels](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/PurgeOldKernels/)_
  1. Attempt to SSH to the failed machine  
  _If you are not able to do this the machine may require a reload or bootstrap_
  
  1. Review the contents of the file `/opt/smith-agent.log` to see if there is information about the failure  
  `cat /opt/smith-agent.log`
  
  1. If the `smith-agent.log` file suggests that the patching failed on **purging old kernels** (i.e. `Error encountered purging kernels! exit status 100`), these should be manually purged and patching re-started via Igorina, use the following command:  
  ```sudo purge-old-kernels```
  
- The [#bot-igorina-logging](https://ibm-argonauts.slack.com/archives/CDG1R2D5Y) channel can be used to check for error messages for specific machines

- Reloading a _worker_ via chlorine may be required if it is `NotReady`. **NB**: generally non-workers should **not** be reloaded via chlorine; see machine-type-specific runbooks for help (e.g. carrier masters, syslog, bastionx etc).

### 6.1.5 Manual steps to manage the `apt-repos`

The instructions below were the previous "completely manual" approach to maintainin the 4TB main disk. To reduce the likelihood of damaging errors, the `smithpurge` script wsas created and should be used instead of the steps presented below. See details above in [section 3.4](#34-management-of-apt-repos).

These **_legacy_** instructions have been moved here for record keeping and to be used as a backup if the smithpurge script no longer runs

1. To be able to manage the contents of the master disk from an Ubuntu command line, login to the `smith-builder` pod  
   _Prior to executing the `exec` command below it is **required to notify `cloud security`** via Slack_  
   _use Slack [template example in #soc-notify](https://ibm-argonauts.slack.com/archives/C4BHPCX89/p1588671343408600)_  
   
   1. Login to cloud.ibm.com account 278445, for example  
   `ibmcloud login -sso`
   
   1. Connect to the AAA cluster  
   `ibmcloud ks cluster config -c infra-accessallareas`
   
   1. Get a cmd line and go to the directory where builds are stored  
   `kubectl exec -it smith-builder bash`  
   **`  - WARNING: You are logged-on as root!!`**  
   `cd /build/.aptly/public`

1. List the `smith` builds on the AAA 4TB disk  
   
   1. Live builds, ie. the builds will be available to the mirrors  
   `ls -lart`  
   _Listing the builds oldest to newest_
   
   1. Archived builds  
   `ls -lart ../../archive/`  

1. Purging:

   1. _[Optional]_ Delete any archived builds which are no longer required  
   `<command to be listed here>`
   
   1. Archive a live build, i.e. remove it from the **live** builds  
   `mv <build number> ../../archive/`  
   _Archived builds will be removed from **mirrors** at the next `sync` run_

1. Confirm the `smith` builds again **_as per earlier step_**  
   `ls -lart`  
   _Listing the builds oldest to newest_


## 6.2 Additional useful tools

There are several Jenkins job located at [Jenkins>Conductors>Conductors>Conductors-Infrastructure>Smith Patching](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/) which you may find useful.
- [**PatchFailedMachineHealthReport**](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/PatchFailedMachineHealthReport/)  
Report on the _`smith`_ status of machine  
_Useful for machines which appear to have failed to patch_
- [**SMITH MIRRORS - Report Mirror Status**](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/SMITH%20MIRRORS%20-%20Report%20Mirror%20Status/)  
Report on the status of the `apt` report mirror machines  
_Useful for determining whether directories contain the appropriate entries_
