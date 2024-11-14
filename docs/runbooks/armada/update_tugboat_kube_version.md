---
layout: default
description: General information for upgrading tugboat kubernetes version
title: General info for updating armada tugboat carriers
service: Conductors
runbook-name: "General information info for updating armada tugboat carriers"
tags:  armada, carrier, general, tugboat
link: /armada/update_tugboat_kube_version.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

General information for upgrading tugboat kubernetes version for major releases e.g. 1.12 --> 1.13

## Detailed Information

### Update Masters

1. If updating a stage/prod tugboat, then raise the appropriate train, wait for approval, and use the appropriate Jenkins job deploys in stage to provide as tests.

e.g.
```
Squad: Conductors
Title: Upgrade us-east prod-mon01-carrier102 tugboat to Kubernetes 1.14
Environment: us-east
Details: upgrading masters and workers from 1.12 to 1.14 https://github.ibm.com/alchemy-containers/armada-runtime/issues/268#issuecomment-14393811
Risk: low
StageDeployDate: 2019-08-26
TestsEnvironment: stage
Tests: https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/bootstrap-minimal-tugboat/20261/
TestsPassed: true
PlannedStartTime: now
PlannedEndTime: now + 24h
OutageDuration: 0
OutageReason: None
BackoutPlan: Manual intervention
```

2. Find the clusterID of the tugboat that you want to upgrade in the [tugboat-cluster-update-monitor](https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/maps.json) repo. This should also help you determine other parameters for next step.

3. Use the [Bootstrap-minimal-tugboat](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/bootstrap-minimal-tugboat/build?delay=0sec) Jenkins job and provide the following parameters.

- `CLUSTER_ID` clusterID of tugboat
- `REGION` is one of `us-south`, `us-east`, `uk-south`, `eu-central`, `eu-fr2`, `ap-north`, `ap-south`
- `PIPELINE_ENV` is one of `dev`, `prestage`, `stage`, `prod`, `prodfr2`. For performance, the number needs to be appended. eg: `stage2`, `stage5`
- `KUBE_VERSION` desired kube version. `ibmcloud ks versions`
- `CUSTOM_PLAYBOOK` is `update_masters.yaml`

4. If the job passes, the worker updates will be kicked off automatically. See below for details.

### Update workers

1. Worker updates will be kicked off automatically by the Jenkins jobs that live [here](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/automated-worker-reloads/) There is a job for each tugobat.
- The job will not update any prod workers unless the same worker version is fully deployed to stage-dal10-carrier100 for 24h

1. You can verify that all the workers have been updated by finding the respective `worker-info.json` file in the [tugboat-worker-info](https://github.ibm.com/alchemy-containers/tugboat-worker-info) repo for the cluster that is being updated. This file will contain info on each workers' desired(targetVersion) kube version and the actual(kubeVersion) version. If there are any issues with workers not updating, a PD should be generated automatically. To resolve these type of issues you can refer to this [troubleshooting runbook](../armada/tugboat_action_fail.html)
