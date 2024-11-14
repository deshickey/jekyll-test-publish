---
layout: default
title: cluster-squad - Pricing generation faults
type: Alert
runbook-name: "cluster-squad - Pricing generation faults"
description: Armada cluster - Pricing generation faults that trigger armada-cluster PDs
service: armada-cluster
link: /cluster/cluster-squad-pricing-faults.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert triggers when the flavor pricing generation in armada-billing generates faults, and hence incomplete results. As more regions are suffering from pricing generation faults, there is an increased risk that some prices may not appear in the UI when the user creates a cluster or worker pool. Pricing faults may be also be related to resource controller or metering service alerts.


## Example Alert

  Example PD title:

  - `#3533817: bluemix.containers-kubernetes.prod-lon04-carrier1.armada-billing_billing_pricing_offering_generation_faults.eu-gb`


## Actions to Take

If pricing faults occur in less than three regions, raise a GHE to document the alert (see GHE link below), with the troutbridge squad to investigate. Due to redundancy and global aggregation, the is low risk that one or two regions suffering from a few faults will impact the prices displayed in the UI. Silence the alert. It may autoresolve and retrigger.

If pricing faults are affecting three or more regions then the risk of missing prices in the UI is increased so investigation is warranted. Escalate to the troutbridge squad.


### Logs

Pricing faults are investigated through LogDNA. 

- Use "EVERYTHING" view - *do not* use a view that filters JSON fields.
- Select logs from `armada-billing` app.
- Review the `offering` from the PD alert and search using `offering:roks` or `offering:iks` as applicable, or leave blank if have PDs from both offerings in region.

Look for recent messages that look something like `Generated XX worker pricings and YY contract pricings for ZZ flavors for offering roks with FF faults (total GG faults)`, where `GG` is not `0`. Review `allFaults` field, which summarises the natures of the faults and the affected resources.

- Add these filters to the search string: `level:error caller:fetcher`

This will highlight errors from the component that fetches plans from the BSS APIs and flavors from etcd. For example, a timeout may indicate slow BSS API or etcd performance, respectively. 
troutbridge squad: If BSS API returns 404 for a plan, check that the plan name is correct.

If no errors are found, replace `caller:fetcher` with `caller:pricing` in search string.

If still no errors founds, remove `caller:pricing` from search string. However, note that some errors from `caller:metering` package are normal during pricing.


## Escalation Policy

Escalate to the troutbridge squad so that they can assist in diagnosing the issue.

PagerDuty:
Escalate the issue via the [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) PD escalation policy

Slack Channel:
You can contact the dev squad in the #armada-cluster channel

GHE Issues Queue:
You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
