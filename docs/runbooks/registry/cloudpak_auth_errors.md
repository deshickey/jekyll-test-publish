---
layout: default
description: How to deal with cloudpak auth errors.
title: registry - dealing with cloudpak auth errors.
service: registry
runbook-name: "Dealing with cloudpak auth errors"
tags: alchemy, registry, cloudpak auth
link: /registry/cloudpak_auth_errors.html
type: Alert
grand_parent: Armada Runbooks
parent: Registry
---

Alert
{: .label .label-purple}

## Overview

This alert means that customers of `cp.icr.io` are having trouble authentication, and may be expericing problems pulling Cloudpak content. `cp.icr.io` uses non-IAM authorization service owned by the Service Aggregation and API Squad. This alert does not usually indicate a problem with the registry service, but will impact Cloudpak customers. `cp.icr.io` is served from `wdc` for US customers, and `lon` for all others.

## Example alert(s)

- The 5xx error rate for cloudpak auth is over 1%

## Automation

None

## Actions to take
Check for planned maintenance in these Slack channels:
- [#m-sa-api-support](https://ibm-argonauts.slack.com/archives/C9MDHSV5L)
- [#m-ssm-support](https://ibm-cloudplatform.slack.com/archives/CA5F81JBW)

**If there is planned maintenance AND is is before the scheduled end time**

> 1. Make a note in on-call handover that there is planned maintenance affecting cloudpak auth. Include:
>   - link to the alert
>   - link to the Slack maintenance message
>   - end time
> 2. Post in the [#registry channel](https://ibm-argonauts.slack.com/archives/C51A6BYRM):
>   ``` text
>   Users may be seeing issues with Cloudpak auth for the Registry. This is due to
>   planned maintenance so disruption is expected. See here: <link to maintenance message>
>   ```
> 3. Snooze the alert until the end of the maintenance window

**If there is planned maintenance AND the scheduled end time has passed**

> 1. Escalate to the [IBM MarketPlace API team](https://ibm-argonauts.slack.com/archives/C9MDHSV5L) team asking for an update

**If there is NO planned maintance**

> 1. Follow the steps in the Reference section, these will make sure you escalate to the correct team

## Reference

Follow these steps to diagnose what is causing the errors.

Before you start, look at the alert to see which `region` it is from. You will need to know whether it's `lon` or `wdc` so you can open the matching LogDNA instance.

### Gather information from LogDNA

NOTE: If LogDNA in having an outage, it is possible to gather information [from prometheus](#accessing-prometheus)

1. Log into <https://cloud.ibm.com/observe/logging> with the registry-prod account:
    - account ID `ff47a8ba7d6531bd285bb85e6a12abd3`

1. Open a LogDNA instance to authenticate with the service:
    - Go to <https://cloud.ibm.com/observe/logging>
    - Click `Open Dashboard` next to either the global (`logDNA-registry-va-prod-global-STS`) or uk-south (`logDNA-registry-va-prod-eu-gb-STS`) instances

1. Go to `Cloudpak debug` board in the desired LogDNA instance
   - [global](https://app.us-south.logging.cloud.ibm.com/13f886d510/graphs/board/15d846689e)
   - [uk-south](https://app.eu-gb.logging.cloud.ibm.com/f8b4728ca3/graphs/board/e5bcea5a69)
1. View the error rate using the `SUCCESS VS ERRORS` graph to get an idea of the error rate
1. View the `COMMON ERRORS` graph to get an idea of what error messages we are seeing. You should see a spike in specific errors in this graph.
   - If there are no spikes, then we are likely seeing errors we haven't seen before. Once you find the error messages in the next step, please add them to the graph to help future users.
1. View the `PER AZ ERROR RATE` to understand if this is affecting all of the registry zones, or just specific ones
1. In another tab, go to the `Cloudpak errors` LogDNA view 
   - [global](https://app.us-south.logging.cloud.ibm.com/13f886d510/logs/view/db6fa58cfd?q=MyIBMauth%20level%3Aerror%20%20%22attempt%203%22)
   - [uk-south](https://app.eu-gb.logging.cloud.ibm.com/f8b4728ca3/logs/view/e533c5598e?q=MyIBMauth%20level%3Aerror%20%22attempt%203%22)
1. Gather examples of the error messages we're seeing, in the format of `MyIBMauth: request attempt 3, error: <error message>`

Keep these pages open in tabs for future reference - you will need them to continue monitoring the problem.

If `SUCCESS VS ERRORS` is trending down and there are no spikes, errors could have been caused by a network blip. Monitor the error rate until it there are no more errors, when the alert will auto-resolve. If the alert fires persistently, please escalate by following the steps in the Escalation Policy section of this runbook.

**After reviewing the graphs, escalate to [Container Registry](https://ibm.pagerduty.com/escalation_policies#PVHCBN9) IF**:
1. The COMMON ERRORS graph has unknown errors and a consistent error rate.
1. The PER AZ ERROR RATE graph is not affecting all zones

Otherwise, please escalate by following the steps in the Escalation Policy section of this runbook.

### Accessing Prometheus
This alert is triggered by Prometheus on Container Registry clusters and can give you an alternative view of the error rates to LogNDA. The alert will contain a `Source` field which is a link to the Prometheus query which fired the alert.

This can give you a closer to real-time view of the error rates (LogDNA has a delay due to ingestion) which is helpful for determining if the errors have stopped. But it's worth noting that this will only give you the view of 1 AZ - LogDNA will give you a clearer picture of the total error rate across all 3 AZs and so should be used for determining the error rate.

If you feel like you need to access the prometheus instance (e.g. in the situation where there is a LogDNA outage), do the following:
1. Access the Registry cluster from which the alert is originating using teleport following [these instructions](https://pages.github.ibm.com/alchemy-registry/operational-docs/runbooks/cr/bastion/#how-to-log-in)
   - NOTE: The registry cluster can be determined from the `alertname` field in the alert e.g. `Cloudpak auth 5xx rate in prod-lon06-az2` indicates `registry-prod-uk-south-az2`
   - `prod-lon0X-azY` > `registry-prod-uk-south-azY`
   - `prod-wdc0X-azY` > `registry-prod-global-azY`

2. Run `kubectl port-forward -n monitoring svc/prometheus-registry 9090:9090`
3. Access the prometheus dashboard by going to [localhost:9090](http://localhost:9090/) in your browser
4. Take the `Source` field in the alert and replace the `registry-prometheus-0` part of the URL with `localhost` - this should now show you a graph which correlates to the triggered alert
   - Note: the units of the graph are in decimal, such that 0.01 = 1%.
   - You can also remove the `> 0.01` from the end of the expression and hit `Execute` to view the total error level without the threshold.

## Escalation Policy
1. Check for open customer tickets 
1. In the slack channel [#m-sa-api-support](https://ibm-argonauts.slack.com/archives/C9MDHSV5L) make a post showing the error messages, and include images of the `SUCCESS VS ERRORS` graph to illustrate:

    ``` text
    The Registry is experiencing a high number of the following error message(s) since
    <approximate start time, based on graphs>. Could someone please assist.
    <error message(s)>
    <graph screenshot>
    ```

1. Send an email to `critical-sp@ibm.pagerduty.com` with:
    - Subject: `Service aggregation API failing`
    - Body:
    ``` text
    Hi,
    The container registry is getting errors from the Service Aggregation API.
    For more details we can connect on slack channel #m-sa-api-support
    thanks
    ```

1. Wait for the engineer to confirm if there is an issue their end

1. Check [#registry](https://ibm-argonauts.slack.com/archives/C51A6BYRM), [#registry-ibm-image](https://ibm-argonauts.slack.com/archives/C543T384B) and [#registry-va-users](https://ibm-argonauts.slack.com/archives/C53RR7TPE) - if there are reports of issues with `cp.icr.io` or `cp.stg.icr.io` inform that we are aware and investigating.

1. If the engineer confirms no issue with the MarketPlace API, [post your findings to Slack](https://ibm-argonauts.slack.com/archives/C51A6BYRM) and [escalate](https://ibm.pagerduty.com/escalation_policies#PVHCBN9) 
 