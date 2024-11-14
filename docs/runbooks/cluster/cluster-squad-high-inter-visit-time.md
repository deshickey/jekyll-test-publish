---
layout: default
title: armada-cluster - How to debug high inter visit time alert
type: Alert
runbook-name: "armada-cluster - How to debug high inter visit time alert"
description: armada-cluster - How to debug high inter visit time alert
service: armada-cluster
link: /cluster/cluster-squad-high-inter-visit-time.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

These alert will trigger when the average time between visits of armada-cluster to individual workers has exceeded 300 seconds for 2 hours.

It is known to be caused by the following...

- A noisy cluster
- ETCD instability

## Example Alerts

Example PD title:
- `#3533816: bluemix.containers-kubernetes.prod-fra02-carrier2.armada-cluster_high_inter_visit_time.eu-de`

## Actions to Take

1. If the alert has only been raised by carriers in the hkg02 region, then it can be ignored. This is because hkg02 is on standby, so results are easily skewed, and if there were a problem, we would expect the alert to also fire in tok02.
1. Recycle the pods within the affected region, monitor prometheus and see if the inter_visit time drops. If it drops, the alerts will auto resolve and no pCIE is required.
1. Raise a pCIE in the affected region
    - Title: Delay with IBM Kubernetes cluster provisioning and worker node operations
    - Use the [notification template](#cie-notification-template)


## Diagnosis steps

The steps below describe the operations to perform to determine **which** is the appropriate action.

1. Check the logs in **LogDNA** for the affected environment to determine if this is being caused by one or more noisy clusters
    - Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment.
    - In the left hand pane under `CLUSTER-SQUAD` there should be a view called `HighWorkloadClusters`, open that view to display any clusters that have active work on more than 80 workers.

1. Review the output of the logs.
    - This log view will show you any clusters that have 80+ workers awaiting processing, it will update very regularly.
    - It's likely you'll need to monitor the logging in LogDNA for a period of time to assess the situation (at least 15mins).
    - A single cluster appearing on this list isn't usually an issue unless it has 200+ workers or stays on the list for a couple of hours.
    - If we're seeing larger numbers than 200, or multiple clusters reporting large numbers, this usually indicates a problem. 
    - If there are multiple clusters appearing on this view, then we may notice a bit of an impact on armada-cluster

If the above steps have **NOT** identified problematic clusters then follow the steps in [**Engage the troutbridge squad**](#engage-the-troutbridge-squad) below

If the above steps have identified problematic cluster(s):

1. Reviewing the information from the previous steps will help answer the following questions
    - Is it a single cluster?
    - Is it a group of clusters?
      - If it's a group, is it from the same account?
    - Is the workflow progressing?
        - Select a worker or two and monitor it's progress

1. Use `xo-secure` channel to lookup more detailed information about the clusters flagged in the previous step(s) - _NB: xo-secure is a private channel, an SRE will be needed to run this step_.
    - `@xo cluster <clusterid> show=all` will give output which should include `ownerEmail` and `accountID`
    - `@xo account <accountid> show=all` will give further info about the account.
    - Query all clusters reporting as there could be a common trend, such as all owned by the same email or be from the same account.

1. If ....
    - It is a single (or group of) clusters or the workflow is stuck (BM provisions perhaps?), consider executing the [throttling mechanism](#executing-the-throttling-mechanism) on the culprit clusters.
      - If fraudulent activities are suspected, the throttling period should be set to a large number, such as 24hours.
      - If a single noisy neighbour is suspected, smaller values such as 3 hours, can be used for throttling. 
    - Raise a follow on issue in the [troutbridge](https://github.ibm.com/alchemy-containers/troutbridge/issues/new) repo to de-throttle the throttled cluster or clusters.

1.  If any fraudulent or suspicious activity is occurring, or suspected, contact the [IBM Trust Enablement squad](https://ibm-cloudplatform.slack.com/archives/C6HRD1G1F).
    - Post in slack if this is occurring during the monitored hours (which are detail in the channel details)
    - Provide the account ID and clusterids retreived from armada-xo.
    - If occurring outside of slack monitored hours, the enablement squad should be engaged via [pager duty](https://ibm.pagerduty.com/services/PC1M5OP)

### Engage the troutbridge squad

If the above checks do not point at a problem account or cluster, then engage the troutbridge squad.

1. Escalate the alert to the troutbridge squad as described in [**Escalation Policy**](#escalation-policy) below, but continue the remaining steps whilst you await a response.

1. Review the grafana dashboard for Armada Cluster
    - Access grafana by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `grafana` icon in the alerted environment. Select one of the `HUB` options from the drop down.
    - Open the `Armada Cluster` view

1. Review the `Worker Ops Thread% & CPU (stacked)` chart.
    - Are we seeing thread saturation? The left hand column will be 75%+ if we are.
    - Are we seeing a single operation consuming most of the threads?
    - How long has it been going on?
    - Is the workflow progressing?

1. If it doesn't look like a noisy cluster
    - Confirm the pCIE raised earlier. Use the [notification template](#cie-notification-template)
    - Work with SRE to involve the wider tribe (API, Deploy) to determine if they too are affected and work to determine the cause

### Deleting the fraudulent clusters

**These steps need approval from Ralph Bateman**

If fraudulent activities are discovered, and BSS / Trust Enablement cancel the account, it may be necessary to delete the clusters and the resources associated with them.

- Raise a conductors team ticket detailing the clusters which require deletion and why
- Get approval from Ralph
- Get these clusters deleted - exact commands/process to be determined.

### CIE Notification template

   ```txt
   TITLE:   Delay with IBM Kubernetes cluster provisioning and workers node operations

   SERVICES/COMPONENTS AFFECTED:
   - IBM Kubernetes Service

   IMPACT:
   - Users may see delays in provisioning workers for new or existing Kubernetes clusters
   - Users may see failures in provisioning portable subnets for new or existing Kubernetes clusters
   - Users may see delays in provisioning persistent volume claims for existing Kubernetes clusters
   - Users may see delays in reloading, rebooting or deleting existing workers of Kubernetes clusters
   - Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

   STATUS:
   - 20XX-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
   ```

### Executing the throttling mechanism

This process is documented [here](https://github.ibm.com/alchemy-containers/troutbridge/wiki/Cluster-throttling-mechanism).

## Escalation Policy

   Escalate the issue via the [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) PD escalation policy

**Slack Channel**: You can contact the dev squad in the #armada-cluster channel

**GHE Issues Queue**:  You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
