---
layout: default
title: cluster-squad - Worker provisioning region throttle threshold breached
type: Alert
runbook-name: "cluster-squad - Worker provisioning region throttle threshold breached"
description: armada-orchestrator - worker provision region throttle threshold breached
service: armada-cluster
link: /cluster/cluster-squad-region-throttle-threshold-breached.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert is triggered when the number of workers that have [`model.Worker.InitialProcessingPending`](https://github.ibm.com/alchemy-containers/armada-model/blob/0034913ba5c06f3388c91b2354c450f080db32f0/model/structs.go#L971-L975) set to true has exceeded the [configured limit for the region](https://github.ibm.com/alchemy-containers/armada-orchestrator/blob/8af45140ed8d66b95320d064de7a5b12403792e9/services/armada-orchestrator/deployment.yaml#L352-L353) for at least 30 minutes.

This runbook describes avenues of investigation and courses of action that can be taken to remediate the situation.

## Action to take

1. Raise a CIE with the [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK). CIE impact detailed in [CIE details](#cie-details)
2. Engage the troutbridge squad via the [escalation policy](#escalation-policy) for further assistance

### Debug steps for troutbridge squad

This scenario has been hit previously under situations attributed to malicious users or unintended provision requests. The steps in this section provide some hints about where to look to see if you can get to the cause of the blockage in the provisioning pipeline.

#### Identify any noisy clusters

1. Check the logs in **LogDNA** for the affected environment to determine if this is being caused by one or more noisy clusters
    - Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment.
    - In the left hand pane under `CLUSTER-SQUAD` there should be a view called `HighWorkloadClusters`, open that view to display any clusters that have active work on more than 80 workers.

1. Review the output of the logs.
    - This log view will show you any clusters that have 80+ workers awaiting processing, it will refresh frequently.
    - It's likely you'll need to monitor the logging in LogDNA for a period of time to assess the situation (at least 15mins).
    - A single cluster appearing on this list isn't usually an issue unless it has 200+ workers or stays on the list for a couple of hours.
    - If we're seeing larger numbers than 200, or multiple clusters reporting large numbers, this usually indicates a problem. 
    - If there are multiple clusters appearing on this view, then we may notice a bit of an impact on armada-cluster

If there is a noisy cluster or set of noisy clusters, gather the account details for the clusters in question and assess their account status using xo. The `@xo bssAccountState bssAccount=<accountID1>,<accountID2>` will give you this information. If the accounts are internal, work with the account owner to understand what they're trying to achieve and request they temporarily scale down their provision requests to allow the region to recover. 

If the account and usage appear to be malicious or suspicious, work with the SRE team to request that the account is suspended. This would cause the workers in the provisioning phase to move to provision failed or deleting and unblock the provisioning critical path.

#### Inspect armada-orchestrator logs

1. Search the general armada-orchestrator logs looking for issues relating to the `instanceGroupResize` callback. Is this failing consistently and why?

#### Inspect armada-cluster logs

1. Search the general armada-cluster logs looking for issues relating to the `prepareWorkerProvisioning` or `beginWorkerProvisioning` operations.
1. Are these operations failing consistently and failing to clear the [`model.Worker.InitialProcessingPending`](https://github.ibm.com/alchemy-containers/armada-model/blob/0034913ba5c06f3388c91b2354c450f080db32f0/model/structs.go#L971-L975) field?

#### Check the Grafana dashboard

Open Grafana for the affected carrier, select the `Armada Cluster` dashboard (browse dashboards and search for `cluster`). Click on the `Worker Op Counts` panel, and click `view` to expand it. This will show a history graph of the number of workers in each state. You can look at `g2.provision_pending` and `softlayer.provision_pending` to get a view of where the hold up is coming from, whether it's a spike or gradual increase, and how long it's been occurring.

### Mitigation

The situation can be temporarily mitigated by altering the threshold value in the armada-orchestrator deployment yaml. This will require the SRE to interact directly with the microservices carrier for the region via kubectl.

1. Request SRE [lock the carrier configuration](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster-updater-using-launchdarkly.html) to prevent cluster-updater reverting any changes
2. Request the SRE update the `REGION_WORKER_THROTTLE` to a new value in the `armada-orchestrator` deployment
3. Restart the `armada-orchestrator` pods

The troutbridge squad member can then review the armada-orchestrator logs and cpo channels for the region to determine if provisioning is proceeding with the mitigation.

If this mitigation needs to be in place for more than a few hours, the troutbridge squad should release a hotfix of armada-orchestrator with the new value to production. This will then allow the region to be managed by normal means.

### CIE details

Title: Worker provisioning is stalled in affected region

Impact:

* Requests for new workers will be accepted by the API but not actioned by the automation
  * Affects workers created as part of a new cluster
  * Affects workers added to an existing cluster
  * Affects workers added due to worker replacement
* Worker reboot, reload and delete operations are unaffected
* Existing customer workloads are not impacted

## Escalation Policy

PagerDuty:
  Escalate the issue via the [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) PD escalation policy

Slack Channel:
  You can contact the dev squad in the [#armada-cluster](https://ibm-argonauts.slack.com/archives/C54FV49RU) channel

GHE Issues Queue:
  You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
