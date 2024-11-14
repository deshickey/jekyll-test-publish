---
layout: default
description: "armada-deploy - fragmented etcd database near max size"
title: armada-deploy - fragmented etcd database near max size
service: armada-deploy
runbook-name: "armada-deploy - fragmented etcd database near max size"
tags: etcd, etcdserver, database, space
link: /armada/armada-deploy-fragmented-etcd-near-max-size.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Cruiser etcd Size Near Max runbook

## Overview

This alert fires when a cruiser's etcd database is approaching the maximum allowable size (4294967296 bytes) with a significant portion of that size not in active use but taken up due to database fragmentation. Defragmentation of the cluster is necessary to avoid exceeding the maximum database size and rendering the control plane inoperable.

## Example Alerts

`bluemix.containers-kubernetes.prod-fra02-carrier106.cruiser_etcd_size_near_max.eu-de`

## Actions to Take

- Run the [armada-defrag-cluster-etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-defrag-cluster-etcd/) Jenkins job on the `cluster_id` in the alert to reclaim unused space in the etcd database. Note that this job requires a prod train: a prod train template is available [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-deploy-etcd-db-space-exceeded.html#prod-trains-template). **Important:** this step **must** be taken every time a **new** alert fires for a cluster, regardless of whether there is an existing Github issue opened for that cluster in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository
- After the job completes successfully, the alert should clear on its own within a few minutes
- Notify the deploy squad of the issue for further investigation by posting in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or creating a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
