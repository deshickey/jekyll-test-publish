---
layout: default
description: How to resolve quota tickets [E60b6 error code]
title: armada-api - handling quota tickets [E60b6 error code]
service: armada-api
runbook-name: "armada-api - quota changes"
tags: alchemy, armada, quota, ticket
link: /armada/armada-api-quota.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

This runbook describes how to handle customer quota requests which will come in as customer tickets.

## Example Alerts

There are no alerts for this runbook. You will find customer tickets [here](https://github.ibm.com/alchemy-containers/customer-tickets)

## Detailed Information

**IMPORTANT:** Updating a customer quota requires _approval_ and _Prod Trains_ when the update is executed!

- For size increases of up to 150 clusters and 1000 workers - an SRE Lead must approve before it can be actioned.
   - Work with your squad lead to review
- For sizes above this, Ralph Bateman needs to approve
   - Tag Ralph in the ticket and request his approval.
   - DM Ralph a link to the ticket in slack so he can review and approve/reject as appropriate.

Refer to https://ibm.ent.box.com/notes/772700662990?s=yib8bgk88yxb468hxs1g1gv1e8xv8ell for the latest info on who can approve.

Customer tickets that involve quota requests will normally be identified by the quota exceeded error code (E60b6). If the customer
ticket doesn't mention the error code but still requests a quota change that is OK.


## Detailed Procedure

Collect the new quota limits from the customer. The customer can specify quotas for several providers, `classic_clusters`, `classic_workers`, `vpc-classic_clusters`, `vpc-classic_workers`, `vpc-gen2_clusters`, `vpc-gen2_workers`, `vpc-gz_clusters` and `vpc-gz_workers` and make quota requests per region. Since the concept of regions no longer exists for customers it may be more helpful to see what metros the user wants a quota increase in then we do the metro-region translation ourselves. 
The resource types are workers and clusters. A typical quota increase would be the current quota plus 20%. 

All updates to an account's quota require an approval from the relevant approver (see above) plus an OPS CHG Train. Here's an example of a train request:

```
Squad: Conductors
Service: Armada
Title: Increase classic cluster worker quota to nnn for account xxx (account name)
Environment: us-south
Details: Account xxx (account name) has requested a quota increase. Approval has been added to the customer ticket https://github.ibm.com/alchemy-containers/customer-tickets/issues/yyy
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 60m
Ops: true
BackoutPlan: Delete custom quota for this account
```

Use xo to query the quota of the account first to verify settings prior to changes

```
@xo getAccountQuota <ACCOUNT ID>
```

The results from this command can also be used to obtain valid region IDs and quota types for use with the `updateAccountQuota` command described below. These are not hard coded in armada-xo to allow new regions to be enabled without updates to armada-xo.

The `updateAccountQuota` command is used to update account quotas. Use the help command if you are unsure of options
  For example:
```
@xo help

updateAccountQuota account=<accountid> region=<region> type=<type> value=<value>. THIS COMMAND REQUIRES A PROD TRAIN TO USE.
```
- **NB** The **`updateAccountQuota`** command is **only** available in the [**`xo-conductors`**](https://ibm-argonauts.slack.com/archives/G90E71LSV) channel.

Suppose a user wants to request a quota of 100 `vpc-gen2_workers` resources in `us-south`, you would need to use @xo command:

```
@xo updateAccountQuota account=<ACCOUNT ID> region=us-south type=vpc-gen2_workers value=100
```

To verify that the quota was set you can use this command:

```
@xo getAccountQuota <ACCOUNT ID>
```



For more info consult the help text for the updateAccountQuota command.

## Escalation Policy

No PD escalations are needed. If you have questions, please reach out to the @ballast handle in #armada-ballast.
