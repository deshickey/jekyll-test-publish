---
layout: default
title: Softlayer Maintenance automation process
type: Informational
runbook-name: "Softlayer Maintenance automation process"
description: Information about Softlayer Maintenance automation process and Troubleshooting steps 
category: armada
service: sre_operations
link: /softlayer_maintenance_automation.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes the process of Softlayer Maintenance automation and provide Troubleshoting steps.

Softlayer will be migrating VSIs to new hosts. We need to migrate the impacted nodes ahead of the schedule so that they can be drained and migrated gracefully to prevent service disruption which can cause CIE.

## Repository

#### Jenkins Jobs:
- Part1 - https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/sl-maintenance-auto/job/sl-maintenance/ (scheduled daily)

   : collects the Softlayer maintenance events for the account and generates internal Git issues.

- Part2 - https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/sl-maintenance-auto/job/sl-maintenance-migrate/ (scheduled hourly)

   : monitoring the internal Git issues related to SL maintenance tasks and perform SL migration actions.

#### SL tasks:
- https://github.ibm.com/alchemy-conductors/sl-maintenance-tasks/issues

   : Tasks with `sl-bot` label are processed by the automation.

## Information about the automation

Flags checked by the automation:

```
- readyflag: flag whether node is Ready status or not using kubectl command checked via `Chlorine healthcheck`
- pendingflag: flag whether the node has any pending migration. checked via `slcli call-api SoftLayer_Virtual_Guest getPendingMigrationFlag --id $vsi_id`
- last_transaction: last transaction performed on the node. checked via `slcli call-api SoftLayer_Virtual_Guest GetLastTransaction --id $vsi_id`
- transactionflag: flag whether the last transaction above was "Cloud Migrate"
```

Tags added by SL Bot:
```
- BotMigrate: bot issued migration
- BotVerified: all verification conditions are met, tick the box
- NoPendingMigration: pending migration not true, but verification conditions not met
- BotNodeNotReady: node is not ready
- BotAsksManualMigrate...: manual migration required for the special nodes (e.g. -master-, -infra- nodes)
```

## Detailed Information

## Troubleshooting

### 1. Find out the items to take action 
using one of methods below (1-1 or 1-2 or 1-3).

##### 1-1. Starting from Pagerduty alert.
Interrupt will get Pagerduty alerts when auto approval is enabled. All details will be included in the PD alert.
Go to Step 2.

##### 1-2. Starting from Jenkins Job.
Find any “not completed” items, from the [Part2 Jenkins Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/sl-maintenance-auto/job/sl-maintenance-migrate/) execution. 
Go to Step 2.

example:
   ~~~shell
   readyflag: False, pendingflag: False, transactionflag: True, last_transaction: Cloud Migrate, processedgrpflag: True ...
   The node has been processed but not completed
   - [ ] [kube-ca6gkq2w0htf856miqsg-produseastc-custome-0000032f](https://cloud.ibm.com/gen1/infrastructure/virtual-server/130674032/details) 10.140.104.231 BotMigrate...
   ~~~

##### 1-3. Starting from Git tasks.
Find any “not completed” items, from each [git issues](https://github.ibm.com/alchemy-conductors/sl-maintenance-tasks/issues?label%3Asl-bot).
Go to Step 2.

example:
   ~~~shell
   AlConBld commented 

   https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/sl-maintenance-reboot/818/
   Items processed but not completed:
   kube-ca6gkq2w0htf856miqsg-produseastc-custome-0000032f 10.140.104.231 BotMigrate...
   readyflag: False, pendingflag: False, transactionflag: True, last_transaction: Cloud Migrate
   ~~~

### 2. Investigate the issue
Investigate the issue why those are not completed yet by searching the node IP address in the slack (mainly appears in #bot-chlorine-logging).

example:
   ~~~shell
   Chlorine bot (SRE)APP 
   CHG3829414 slmigrate: (kube-bofo5oed00km5g506qvg-produssouth-custome-000231e0) Draining node kube-bofo5oed00km5g506qvg-produssouth-custome-000231e0 (10.74.224.81) failed, investigation required, err: command armada-drain-node --reason "Chlorine migrating on behalf of slmigrate}" 10.74.224.81 failed, err=ssh cmd 'source invoke-tugboat-jenkins prod-dal10-carrier106 1,2>/dev/null ; armada-drain-node --reason "Chlorine migrating on behalf of slmigrate}" 10.74.224.81' on 10.184.18.166:22 (684841) failed, err:Process exited with status 2,
   stdout: node/10.74.224.81 already c

   Chlorine bot (SRE)APP 
   CHG3829414 slmigrate: (kube-bofo5oed00km5g506qvg-produssouth-custome-000231e0) 0xc0254df8b0: {"NodeIP":"10.74.224.81","Action":"drain","TimeStamp":"2022-06-19T08:25:17+0000","Status":"unsuccessful","Success":false}

   Chlorine bot (SRE)APP
   CHG3829414 slmigrate: (kube-bofo5oed00km5g506qvg-produssouth-custome-000231e0) InProgress:[]
   Passed:[]
   Failed:[kube-bofo5oed00km5g506qvg-produssouth-custome-000231e0]
   Skipped:[]
   Unstarted:[]
   ~~~

From the example above `Chlorine migrate` failed during drain.

### 3. Steps to fix the issue
For the blocked item with the worker node IP address, find/search the related git issue in the [repo](https://github.ibm.com/alchemy-conductors/sl-maintenance-tasks/issues) and take action.

- For the example above, `Chlorine migrate` failed during drain. 

(1) Drain the node manually (e.g. `armada-drain-node`). 

(2) In the body of the git issue, change the following line by removing “Bot”, which will send the line back to the SL bot to process it on the next round.
```
BEFORE: - [ ] kube-bofo5oed00km5g506qvg-produssouth-custome-000231e0 10.74.224.81 BotMigrate...
AFTER: - [ ] kube-bofo5oed00km5g506qvg-produssouth-custome-000231e0 10.74.224.81 Migrate...
```

#### ***Depending on the situation found from 2. take action to resolve the situation.

- For example, if the worker node is not ready after softlayer migration, 

check the runbook on [how to to handle a worker node which is troubled](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-node-troubled.html). 

- For example, if the worker node line is tagged `BotNotReady`, 

check the node is currently ready and recover if not ready, then send the line back to the SL bot as in 3-(2).

## Reference

Any bug or enhancement request about `Softlayer Maintenance Automation` can be submitted in the [project repo issues](https://github.ibm.com/alchemy-conductors/sl-maintenance/issues) with a label `project-issue` or `enhancement`.

## How to stop 

If we need to stop the SL automation, disable Jenkins Jobs or comment out the scheduling configured in the Configure - Build Triggers.

## Escalation

For escalation, contact @conductors-aus team in #conductors-for-life slack channel if you are IKS SRE memeber, or contact @interrupt in #conductors channel if you are outside IKS SRE team.
