---
layout: default
description: Jenkins Job to run barge cluster upgrade failed
title: Barge Upgrade Automation Failure
service: Conductors
runbook-name: "Barge Upgrade Automation Failure"
tags: barge
link: /barge-upgrade-automation-failure.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview

This alert is triggered when jenkins job to upgrade barge cluster fails. More details about automation in [repository](https://github.ibm.com/alchemy-containers/vcarrier-upgrade-automation).

## Example Alert(s)

This is an example [PageDuty Alert](https://ibm.pagerduty.com/incidents/Q008L6MZ7HK04K) and it contains link to the build of the [Jenkins job](https://alchemy-testing-jenkins.swg-devops.com/job/Conductors/job/dev-barge-pipeline/job/IN/job/vcarrier-automated-patch-upgrades-child/) which is triggered automatically for patch upgrades or [job](https://alchemy-testing-jenkins.swg-devops.com/job/Conductors/job/dev-barge-pipeline/job/IN/job/vcarrier-upgrade-pipeline/) is triggered manually.

## Investigation and Action

Find the barge cluster name from Alert details. Login to barge and run command `oc adm upgrade`. Sample output:
```
oc adm upgrade
Failing=True:

  Reason: ClusterOperatorNotAvailable
  Message: Cluster operator image-registry is not available

Error while reconciling 4.14.6: the cluster operator image-registry is not available
```
If the output contains `Failing=True` like above, it means one or more cluster-operators are failing. The cluster-operators in `Message` will need to be debugged further.

## Actions to take

Check above section. More details will be added in this section with common failure scenarios.

## Escalation Policy
This automation is owned by the conductors/SRE squad. 
