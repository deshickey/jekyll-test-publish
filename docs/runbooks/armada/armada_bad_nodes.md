---
layout: default
description: How to action an alert for Armada - Bad nodes found
title: Armada - Bad nodes found
service: armada
runbook-name: "Armada - Bad nodes found"
tags:  armada, worker
link: /armada/armada_bad_nodes.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

An alert was generated when the number of unhealthy pods on any single node exceeded a certain threshold. The current threshold is [here](https://github.ibm.com/alchemy-conductors/armada_find_bad_nodes/blob/master/k8s_find_bad_nodes.sh#L4)

The job runs every 6 hours across all of the production environments. 

This is the [GHE repo](https://github.ibm.com/alchemy-conductors/armada_find_bad_nodes)

This is the armada_bad_nodes [Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/job/armada-bad-nodes/).  

## Example Alert(s)

This is an example [PageDuty Alert](https://ibm.pagerduty.com/incidents/P4DFRO8) and it will link to the console of the build of the [Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/job/armada-bad-nodes/).  

The affected nodes are listed in the Jenkins job buid's console output. This is an example of the final output of the job which can be found near the bottom of the console page:

~~~~
15:17:34 ***************************************
15:17:34 Runbook: (This IS the runbook)
15:17:34 The following machines most likely will require an osreload:
15:17:34         "10.171.78.71 has 14 bad pods"
15:17:34 ---------------------------------------
~~~~


## Investigation and Action

Since the job is a scheduled job, it will run without care for any other external factors.

Therefore,  some awareness of the current situation is needed. Is there a CIE in progress? Is an update in an environment ? And so on.

In most cases, a simple [os reload](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-node-troubled.html#reloading-worker-node) via the slack bot igorina is sufficient.

If an os reload fails, eg  the drain failed, refer to the [troubled node runbook ](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-node-troubled.html#debugging-the-troubled-node) for the situation before attempting another os reload. Note that AutoRecovery may also pick up the node for os reload and igorina will then reject your Change Request as a duplicate. This is acceptable.


## Actions to take

See the above paragraph on Investigation before proceeding. If there is no external factors,  proceed with the [os reload](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-node-troubled.html#reloading-worker-node) using igorina, the slack bot

## Escalation Policy
This automation is owned by the conductors/SRE squad. 
