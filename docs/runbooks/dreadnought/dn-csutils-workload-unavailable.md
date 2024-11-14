---
layout: default
title: "CSUtils workload pods unavailable for 15 minute"
runbook-name: "CSUtils workload pods unavailable for 15 minute"
description: "CSUtils workload pods unavailable for 15 minute."
category: Dreadnought
service: dreadnought
tags: dreadnought, csutils, unavailable, add-on
link: /dreadnought/dn-csutils-workload-unavailable.html
type: Alert
grand_parent: Armada Runbooks
parent: Dreadnought
---

Alert
{: .label .label-purple}

## Overview

- One or more of the csutils workload are offline in a cluster.
- This alert is after 15 minutes.
- Dreadnought clusters all use the CSUtils add-on and is configured at the time the cluster is created.

## Example alert

- Alert in Slack Channel [#dreadnought-prod-monitoring](https://ibm.enterprise.slack.com/archives/C059HL4RC92){:target="_blank"}:

> CSUtils workload pods unavailable for over 60 minutes for dn-prod-s-cpapi-extended (eu-de) is Triggered
> 
> Severity: `Low`
>
> Metric:
>   - `kube_workload_status_unavailable = 1.0522`
>
> Segment:  
>   - `kube_cluster_name = 'ckjnav8f02b8qjl537sg' and`
>   - `kube_namespace_name = 'ibm-services-system' and`
>   - `kube_workload_name = 'crowdstrike'`
>
> Scope:
>   - `kube_namespace_name in ('ibm-services-system')`
>
> Time: `05/05/2024 07:54 PM UTC`
>
> State: `Triggered`
>
> More info: [View notification](https://eu-de.monitoring.cloud.ibm.com/api/oauth/openid/IBM/a708cf9c0032433782568b6baf876b14/bfe2e99a-83c0-4064-b20d-311f0dc3a47a?redirectRoute=%2Fevents%2Fnotifications%2Fl%3A2419200%2F37080896%2Fdetails)
>
> Triggered by Alert:
> 
> Name: CSUtils workload pods unavailable for 15 minute for dn-prod-s-cpapi-extended (eu-de)
> 
> Team: Monitor Operations
>
> Scope:
>  - `kube_namespace_name in ('ibm-services-system')`
>
> Segment by:
>  - `kube_cluster_name, kube_namespace_name, kube_workload_name`
>
> Alert When:
>  - `avg(avg(kube_workload_status_unavailable)) > 1.0`
>
> For at least: `61 m`
>
> More info: [View alert](https://eu-de.monitoring.cloud.ibm.com/api/oauth/openid/IBM/a708cf9c0032433782568b6baf876b14/bfe2e99a-83c0-4064-b20d-311f0dc3a47a?redirectRoute=%2Falerts%2Frules%3FalertId%3D572094)

## Automation

- None

## Actions to take

- If the issue is persistent a replacement of the worker or csutils maybe required.
- [#sos-armada](https://ibm.enterprise.slack.com/archives/C7H1HAXT3){:target="_blank"}
- [CSUtils troubleshooting](https://github.ibm.com/ibmcloud/ArmadaCSutil/blob/master/Troubleshooting.md){:target="_blank"}
- <mark>DO NOT resolve the alert manually</mark> unless you replace the worker.

## Escalation Policy

- Escalate to the Dreadnought compliance team for investigation if an issue for more than 24 hours.
  - Compliance team should investigate if the SOS dashboard is receiving updates.

## Reference

Some other helpful links for csutils:

- [General Troubleshooting](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI/blob/master/troubleshooting.md){:target="_blank"}
- [Csutil CLI](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI){:target="_blank"}
- [Csutil Charts](https://github.ibm.com/ibmcloud/charts){:target="_blank"}
