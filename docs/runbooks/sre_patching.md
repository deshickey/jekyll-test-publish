---
layout: default
title: How to kick off and monitor patching
type: Informational
runbook-name: "How to kick off and monitor patching."
description: "How to kick off and monitor patching"
service: Conductors
link: /sre_patching.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The [patch process runbook] should be consulted for end to end process of patching.

This document details how to specifically kick off manual patching of a machine, or set of machines, and **NOT** how to build a new apt repository and safely patch our entire estate 

We patch against a known production ready apt repo called `prod`

## Detailed information

You'll be reading this if you want to manually patch a machine, or set of machines.

Usual reasons for this are:
- Patching previously failed on a machine and needs re-executing
- The machine has been osreloaded and needs patching

## Submitting a patch request.

In slack, start a DM to `igorina` and use the `smith-patch` command to request patching of a machine, or set of machines.

The command is made up of

~~~
smith-patch prod machines: <machine list> outage:0
~~~

The machine list can be

1. space separated list of machines or IP addresses that reside in the same region. i.e. `prod-lon04-carrier3-worker-01 prod-lon04-carrier3-worker-02 prod-lon04-carrier3-worker-8001` 
2. A regular expression of machines which should match via the machine lookup service i.e. `prod-lon02-carrier2-worker-*`
3. a single machine or ip address 


When a patch request is submitted, a ServiceNow change request is returned to the caller once any stage or prod trains are approved.

For example:

~~~
smith-patch 725 machines: prod-syd05-carrier1-worker-1005 outage:0


Igorina bot (SRE)APP [10:43 AM]
Raising a new change request.
Change request raised: `CHG0268453` waiting for approval
~~~

Here are some examples, with explanations of what they will kick off.


### Single machine

~~~
smith-patch prod machines: prod-dal10-carrier3-worker-11 outage:0
~~~

Will patch prod-dal10-carrier3-worker-11 only.

### Regular expression on machines

~~~
smith-patch prod machines: prod-dal10-carrier3-worker-* outage:0
~~~

Will patch all workers in prod-dal10-carrier3.  It'll use the machine lookup service to discover the machine(s)
It will run the patch request in series.

### Multiple machines

~~~
smith-patch prod machines: prod-dal10-carrier3-worker-1001 prod-dal10-infra-test-02 outage:0
~~~

Will patch just these machines in series.

## Tracking patch progress

Use igorina and the ServiceNow change request number to track progress.

~~~
smith-status CHG0268453


Igorina bot (SRE)APP [11:35 AM]
Master, I'm trying to get patch status from smith instance in dev
project `CHG0268453` not running in smith instance in dev
Master, I'm trying to get patch status from smith instance in prod
Project: CHG0268453 Patch: ap-south prod-syd05-carrier1-worker-1005 with Build `725`
TOTALS: Pass: 1, Failed NONE, Unstarted NONE

 *Phase 0*, prod-syd05-carrier1-worker-1005, `complete` Pass: 1, Fail: 0 Unstarted: 0
   Bag: *prod-syd05-carrier1-worker-1005* - CTASK0348812, State: `complete` MachineCount: 1 Pass:1 Fail:0
~~~


## Debugging failures

If a machine fails to patch, it's advised to check the following to help determine the cause of the patch failure and what action to take.

- Consult [#bot-igorina-logging slack channel](https://ibm-argonauts.slack.com/messages/CDG1R2D5Y)
  - Search the channel for the machine and examine the thread which is created to see why the issue occurred.

- Execute is a jenkins job called  [PatchFailedMachineHealthReport](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/Smith%20Patching/job/PatchFailedMachineHealthReport/)
  - The job takes a machine, or set of machines as an input, and then checks various things on each machine, producing individual log files with the information/output.
  - In this, will be output from `/opt/smith-agent.log` which is where the smith patch process logs its execution to. This should be examined as there could be an issue with the machine which needs correcting.

- Obtain the smith-trigger-service bot logs.
  - Igorina calls smith-trigger-service to execute patching.

  - Log into the bots cluster
    - login with  
    `bx login --sso`
    - choose account  
    `IBM (800fae7a41e7d4a1ec1658cc0892d233) <-> 278445`
    - Get access to the appropriate cluster  
    `bx cs cluster-config infra-accessallareas`  
    _export the `KUBECONFIG` provided_
  - Grab the logs for smith-trigger-serivce-prod (for logs from stage and production) or smith-trigger-service-dev (for dev/prestage logs)  
  `kubectl logs -l app=smith-trigger-service-prod -c smith-trigger-service-prod`  
  _NB:  The logs can be quite big, so consider limiting the logs using flags such as `--since=1h` to get the last 1 hours worth of log entries._

- If the information in slack from the BOT logs doesn't help determine why the process failed, find the change request in [ServiceNow](https://watson.service-now.com/navpage.do)
  - In the ServiceNow change request and review the change tasks for additional information.

- If you are still stuck with determining why patching has failed, proceed to the escalation section.

## Escalation Policy

There is no formal escalation policy.

This is an SRE owned process so should be raised and discussed in either

- [`#conductors`](https://ibm.enterprise.slack.com/archives/C54H08JSK) if you are not a member of the SRE Squad.
- [`#sre-cfs`](https://ibm.enterprise.slack.com/archives/C542S3W1L), [`#conductors-for-life`](https://ibm.enterprise.slack.com/archives/G53NY6QH0) or [`#sre-cfs-patching`](https://ibm.enterprise.slack.com/archives/G53A0G8CU) if you are a member of the SRE squad (these are internal private channels)


[patch process runbook]: https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/patch_process_runbook.html
