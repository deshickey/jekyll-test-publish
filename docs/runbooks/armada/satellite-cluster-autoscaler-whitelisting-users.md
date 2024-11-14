---
layout: default
description: How to process whitelisting requests for Satellite Cluster Autoscaler (Beta) Release.
title: whitelisting requests for Satellite Cluster Autoscaler (Beta) Release
service: armada-cluster-autoscaler
category: cluster-autoscaler
runbook-name: "How to process whitelisting requests for Satellite Cluster Autoscaler (Beta) Release."
tags: alchemy, armada, kubernetes, kube, kubectl, cluster-autoscaler, CA, satellite
link: /armada/armada-cluster-autoscaler-troubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes what needs to be done if a customer requests to get whitelisted for using satellite cluster-autoscaler.

## Example Alerts?
1. Sample SRE ticket: https://github.ibm.com/alchemy-conductors/team/issues/14894

## Investigation and Action
1. If there is any customer ticket with below errors on satellite clusters while trying to enable cluster-autoscaler addon version >= 1.1.0

```
$ibmcloud ks cluster addon enable cluster-autoscaler -c bha-satellite-ibm-cluster --version 1.1.0
Enabling add-on cluster-autoscaler(1.1.0) for cluster bha-satellite-ibm-cluster...
The add-on might take several minutes to deploy and become ready for use.
FAILED
The 'cluster-autoscaler' add-on is not supported on satellite clusters. (Ef255)
```

2. Any request from internal team against [conductors](https://github.ibm.com/alchemy-conductors/team/issues/)

**Action:**
For both the above cases, SRE team needs to redirect the request in [#razee](https://ibm-argonauts.slack.com/archives/C5X987RU0) channel by tagging @razee-pipeline.
For processing the request Account Owner details are mandatory and can be retrived from below command output.
```
$ibmcloud account show
```

In #razee chaneel, please add the request in below format:
- For whitelisting in stage env
```
@razee-pipeline could you please whitelist user <Account Owner> to use cluster-autsocaler.
Feature flag gate: https://app.launchdarkly.com/armada-users/preprod/features/armada-api.satellite-autoscaling/targeting
GHE: <GHE or CS ticket details>
```
- For  whitelisting in prod env
```
@razee-pipeline could you please whitelist user <Account Owner> to use cluster-autsocaler.
Feature flag gate: https://app.launchdarkly.com/armada-users/production/features/armada-api.satellite-autoscaling/targeting
GHE: <GHE or CS ticket details>
```
[Here](https://ibm-argonauts.slack.com/archives/C5X987RU0/p1646132654941619) is an example for whitelisting user in stage env.

## Escalation Policy
Please ping in [#armada-node-autoscale](https://ibm-argonauts.slack.com/archives/C90D3KZUL) in case of any queries or issues.

## Automation
None
