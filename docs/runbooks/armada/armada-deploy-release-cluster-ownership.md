---
layout: default
description: How to respond to a customer ticket requesting enablement of ROKS cluster telemetry data in customer's Red Hat account
title: Enabling ROKS cluster telemetry data in customer's Red Hat account
runbook-name: Enabling ROKS cluster telemetry data in customer's Red Hat account
service: armada-deploy
tags: alchemy, armada-deploy, Red Hat, ROKS, OpenShift, telemetry
link: /armada/armada-deploy-release-cluster-ownership.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to respond to a customer's request (via a support case) to enable telemetry data from one of their ROKS clusters to be sent to their Red Hat account.

## Detailed Information

ROKS clusters have the ability to transmit telemetry data to a Red Hat account. That transmission of telemetry data also creates an ownership relationship between the Red Hat account and the ROKS cluster whose telemetry data it receives. ROKS clusters which were created prior to 29 Feb 2024 were configured to send this telemetry data to an IBM account. As of 29 Feb 2024, that telemetry data was no longer sent; however, the ownership relationship it established remained. As a result, if a customer wishes to have the ROKS cluster send its telemetry data to their own Red Hat account instead, IBM must first release its ownship claim of that cluster. The remainder of this document is applicable only to ROKS clusters version 4.13 or ealier, or version 4.14 clusters that were created before 29 Feb 2024.

## Actions to take

1. Create an allowlist entry in the pd-tools GHE repo to enable ownership of the cluster to be released: https://github.ibm.com/alchemy-containers/pd-tools/blob/master/allowlist-jenkins/armada-deploy-release-ocp-cluster.txt. The deploy or update squad will need to approve the PR to add the entry before you can proceed.
1. Raise an ops prod train; sample prod train (replace CLUSTERID and TICKETNUMBER as appropriate):
  ```
  Squad: SRE
  Title: Run the armada-deploy-release-ocp-cluster job in production for cluster CLUSTERID
  Environment: us-south
  Details: |
    Run the job https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-release-ocp-cluster/
    in production on cluster CLUSTERID to allow cluster to be transferred to owner's Red Hat account at their request. Related
    customer ticket: https://github.ibm.com/alchemy-containers/customer-tickets/issues/TICKETNUMBER
  Risk: low
  PlannedStartTime: now
  PlannedEndTime: now + 30m
  Ops: true
  BackoutPlan: n/a
  ```
1. Run the [armada-deploy-release-ocp-cluster](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-release-ocp-cluster/) Jenkins job to release ownership of the ROKS cluster.
1. Once the Jenkins job completes successfully, notify the customer via the customer ticket that telemetry has been enabled for the ROKS cluster to send to their Red Hat account and that they have 7 days to complete the setup, as documented in the instructions at https://cloud.ibm.com/docs/openshift?topic=openshift-telemetry.

## Escalation Policy

If the Jenkins job does not complete successfully and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
