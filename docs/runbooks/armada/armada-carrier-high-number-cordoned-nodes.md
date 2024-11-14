---
layout: default
description: How to deal with a high number of cordoned nodes
title: How to deal with a high number of cordoned nodes
service: armada-carrier
runbook-name: "How to deal with a high number of cordoned nodes"
tags: alchemy, armada, kubernetes, armada-carrier, microservice, cordoned, cordon, nodes
link: /armada/armada-carrier-high-number-cordoned-nodes.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes how to deal with a high number of cordoned nodes as a percentage of available nodes.

## Detailed Information

If nodes are cordoned, then work is unable to be scheduled onto the node.

This may be fine in the short term, but if nodes are left cordoned for an extended period of time, it can lead to problems in the environment, especially with the remaining nodes being over utilised.

## Example alert(s)

These alerts have been created.

1.  High number of cordoned nodes - when over 10% of nodes in a carrier have been cordoned for over 24 hours.
1.  Critical number of cordoned nodes - when over 25% of nodes in a carrier have been cordoned for over 3 hours.
1.  Armada - Stale Cordoned Nodes - when a node or nodes have been cordoned for longer than 48 hours

PD alert examples:

- `bluemix.containers-kubernetes.prod-dal10-carrier3.high_number_cordoned_nodes.us-south`
- `bluemix.containers-kubernetes.prod-dal10-carrier3.critical_number_cordoned_nodes.us-south`
- `Armada - Stale Cordoned Nodes`

## Automation

None

## Actions to take

### Gather nodes status for the carrier

1.  Determine what carrier to review by finding the carrier name in the alert title. 
    - For example: `bluemix.containers-kubernetes.prod-dal12-carrier2.high_number_cordoned_nodes.us-south` would be `prod-dal12-carrier2`

1. Gather the cordoned nodes status and the reasons why they have been cordoned to determine which, if any, can be uncordoned.
    - Log onto one of the master nodes for the carrier  
    `ssh prod-dal12-carrier2-master-01`
    - Use an `armada-tools` command to see the details about cordon notes:  
    `armada-get-cordoned-nodes`  
    _Below is an example of the output_
    ~~~
    pcullen@prod-dal12-carrier2-master-01:~$ armada-get-cordoned-nodes 
    NODE             node.cordon.reason
    10.185.16.143    2018-08-30T21:40:02+00:00 Help scheduling of evictions from busy nodes
    10.185.16.150    2018-08-29T19:45:36+00:00 baaad noode
    10.185.16.170    2018-09-06T20:01:17+00:00  draining (cordoning if required) for: richmole
    10.185.16.224    2018-08-30T21:39:30+00:00 Help scheduling of evictions from busy nodes
    ~~~

1. Gather nodes status to see node state (Read/NotReady)  
`armada-get-nodes`

### Take actions on the cordoned nodes

Analyse each cordoned node using the gathered node status from the previous step.

1. Review node status
    -  `NotReady`  
    Leave any `NotReady` nodes cordoned and move onto next cordoned node.
  
    - `Ready`  
    If cordoned reason is by an automation bot, such as `igorina` or `redpill` and the action that bot was taking has completed, uncordon the node  
    If the cordoned reason is by an engineer/human and less than 48 hours, go to the next step. If more than 48 hours, investigate. Continue reading for more possible solutions.

1. Check node health to determine if the node can now be un-cordoned.
  - Use victory-bot  
  `@victory validate-worker <ip>`  
  or  execute this manually using the [validate worker health runbook](./armada-carrier-verify-carrier-worker-node.html)  
  If victory returns good health for the node, then uncordon the node.

If you are unable to uncordon enough nodes to drop the alert below it's trigger point,  or you are in doubt whether the nodes can be uncordoned, then proceed to the escalation section of this runbook.

### Commands to uncordon a node

- From the carrier master node execute the following command to uncordon  
`armada-uncordon-node <ip address>`

- From slack, use igorina to uncordon using this syntax  
`worker <name or ip> uncordon outage:0`

If you are able to uncordon nodes so that cordoned nodes drop below percentage the alert will auto-resolve.

If you are unable to uncordon enough nodes,  or you are in doubt whether the nodes can be uncordoned, then proceed to the escalation section of this runbook.

### OS reload

Our worker nodes are now cattle. This means if there is a problem with one node we can easily and quickly reload them (including tugboats). The quickest and simplest method is to tell igorina `reload <name or ip> outage:0s`.
If the osreload fails. Investiage the pods on the node.

If a master pod or pods is suspect, this runbook is a good starting point:  [armada-deploy - How to handle a cruiser master not in ready state.](./armada-deploy-cruiser-master-not-in-ready-status.html). Note that sometimes, a master pod or pods could also fail because of unhealthy etcd pod(s), if so, see the next runbook below.

If an unhealthy etcd pod or pods is suspect, then this runbook is a good starting point:  [armada-cluster-etcd-unhealthy - How to resolve etcd cluster related alerts](./armada-cluster-etcd-unhealthy.html) . 

If neither the master pod(s) or etcd pod(s) can be fixed with the above runbook, maybe they reside on a bad node - [Armada - Bad nodes found](./armada_bad_nodes.html)

General runbook for troubled nodes: [armada-carrier - How to handle a worker node which is troubled](./armada-carrier-node-troubled.html#debugging-the-troubled-node)


## Additional information

The timings were chosen for the following reasons.

- For `high` - to account for any nodes which are having issues in the short term, 24 hours for 10% seemed like a sensible starting point.

- For `critical` - we sometimes cordon multiple nodes during CIEs or during maintenance activities, so a 3 hour maximum window was decided that multiple nodes that cause in excess of 25% of nodes to be cordoned to remain cordoned.  After this, alerts will fire to reduce the likelihood that a node remains cordoned after maintenance is complete.

## Related checks and runbooks

Node NotReady situations are covered by seperate alerting and this [runbook](./armada-carrier-node-troubled.html)

Any nodes cordoned for over 48 hours will be picked up by [armada stale cordoned nodes jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/job/armada-stale-cordoned-nodes/) 

## Escalation Policy

Before calling out development, discuss this problem further with the SRE Squad.  This may not be possible if you are actioning this alert at the weekend.

If you believe the nodes that are cordoned cannot be uncordoned and CIE has been raised, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.
