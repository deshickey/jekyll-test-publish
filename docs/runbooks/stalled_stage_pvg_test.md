---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Stalled Stage PVG Test"
type: Troubleshooting
runbook-name: "Stalled Stage PVG Test"
description: "Restart the stage tests when they haven't reported in more then 5 hours"
service: Razee
tags: razee, armada
link: stalled_stage_pvg_test.html
failure: ""
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

During some pvg tests, the test fails to clean up after itself, and prevents future tests from running. 
This runbook describes how to restore the process and allow tests to start running.

## Example Alerts

No alerts exists, but symptoms are:
 - Can see the age of 'inprogress' tests at https://github.ibm.com/alchemy-containers/DevOps-Visualization-Enablement/tags
 - People will notify us in the #razee channel when they haven't seen results in [razeedash](https://razeedash.oneibmcloud.com/v2/alchemy-containers/clusters/33a3ff83-c224-525b-854a-96842066745d/testResults) for a in a while

## Investigation and Action

1. Go to the Jenkins [armada-pvg-deploy job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/armada-gate/job/armada-pvg-deploy/)
1. Find and go to the most recent failing test (should be at the top of the list) then click `console output`
1. At the bottom of the logs, if there is a message such as `A previous armada-stage gate run is in progress. Try again once the previous run completes.` proceed to next steps. Otherwise there is a different issue, escalate to Razee.
1. Find and delete the tag `armada-stage.inprogress.{RunID}` in the [DOVE repo](https://github.ibm.com/alchemy-containers/DevOps-Visualization-Enablement/tags)
    - if you are unable to delete the tag due to insufficient permissions, see here for people who might be able to [help](https://github.ibm.com/alchemy-containers/DevOps-Visualization-Enablement/graphs/contributors) 
1. Return to the Jenkins [armada-pvg-deploy job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/armada-gate/job/armada-pvg-deploy/) and start a new test run `Build with Parameters` -> `Build`

## Escalation Policy

Contact the razee squad (#razee @razee-pipeline) for help.
Reassigned the PD incident to `Alchemy - Containers Tribe - Pipeline`
