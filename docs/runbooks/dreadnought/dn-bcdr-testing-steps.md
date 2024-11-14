---
layout: default
title: "Dreadnought BCDR Testing Steps"
runbook-name: "Dreadnought BCDR Testing Steps"
description: "Dreadnought testing of BCDR against a ROKS on VPC Cluster worker down."
category: Dreadnought
service: dreadnought
tags: dreadnought bcdr, bcdr, bcdr roks
link: /dreadnought/dn-bcdr-testing-steps.html
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

## Overview

Business Continuity and Disaster Recovery test for Dreadnought includes the testing out a failure of 1 worker in a zone.

## Detailed Information

The steps to complete this test are the following:

#### Prerequisite

What is the account information where the test will be completed

| Required information | (Your data) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
| ---- | ---- | 
| Account: | |
| Region: | |
| Cluster Name: | |
| Pool to remove a worker: | | 

### Steps

1. Log into the account via the UI.
1. Click on the Openshift UI
1. Select the cluster to use in the region to use.  Filter if necessary.
1. Delete 1 worker in the worker pool to use. In the delete UI `uncheck` the box next to `"Create a new worker node in place of each deleted one to rebalance the worker pool."`
    - This will create an unbalanced worker pool and is expected.
1. Wait for the Alert in Pager Duty (production account only) or Slack channel for the down worker.  This could take 5 minutes or more.

#### Process Alert and Recover.

1. Once the you receive the alert, acknowledge and resolve the alert.
   1. Select Observability -> Monitoring Instances
   1. Select `Open Dashboard` for the corresponding instance for the region of the cluster.
   1. Click on `Alerts`
   1. Click on `Triggering`
   1. Find the "Host Down in ..." alert
   1. Click the bell on the left side of the table.
   1. Click `"Go To Event Details"`
   1. Click on `Take Action` and select `Manually Resolve`
1. Balance the pool to add the worker back into the cluster.
    1. Select `Worker pools`
    1. From the menu for the pool select `Rebalance`
    1. Wait for the worker to return to `Normal` status

## Further Information

- Slack Channels:
  - Development: [#dreadnought-dev-monitoring](https://ibm.enterprise.slack.com/archives/C05KP3NFP1Q)
  - Stage: [#dreadnought-stage-monitoring](https://ibm.enterprise.slack.com/archives/C05LDK055FW)
      - [Sample Alert in Slack](https://ibm-cloudplatform.slack.com/archives/C05LDK055FW/p1726520669557449)
      - [Sample Resolve in Slack](https://ibm-cloudplatform.slack.com/archives/C05LDK055FW/p1726520737970769)
  - Production: [#dreadnought-prod-monitoring](https://ibm.enterprise.slack.com/archives/C059HL4RC92)

- PagerDuty for Production (only): 
  - [Dreadnought Service](https://ibm.pagerduty.com/service-directory/P1A9W8N)
    - [Sample Incident](https://ibm.pagerduty.com/incidents/Q3ZGTKF0YJ38HC)
