---
layout: default
title: armada-cluster - ErrorUnreconciledMachineConfigVPC
type: Alert
runbook-name: "armada-cluster - ErrorUnreconciledMachineConfigVPC"
description: Armada cluster - ErrorUnreconciledMachineConfigVPC
service: armada-cluster
link: /cluster/cluster-squad-error-unreconciled-machine-config-vpc.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert means that there is something wrong with the underlying instance profile existing within VPC.

If the alert is for a `flavor`, then this may not be affecting a customer, as we pro-actively monitor and probe these instance profiles.
If the alert is for a `worker`, then it is affecting at least a single customer.

If either of the above happen (and it cannot be resolved in [Potential error messages](#potential-error-messages)), then a pCIE should be raised.

If both a `flavor` **AND** `worker` alert come in at the same time, this should be raised as a CIE.

## Example Alert(s)

Example PD title:
- `#30960XXX: bluemix.containers-kubernetes.prod-wdc07-carrier2.armada-cluster_red_alert_error_unreconciled_machine_config_gc_worker.us-east`
- `#30960XXX: bluemix.containers-kubernetes.prod-wdc07-carrier2.armada-cluster_red_alert_error_unreconciled_machine_config_gc_flavor.us-east`

## Actions to Take

Determine the VPC infrastructure provider _(found in the alert description under **provider**)_:

   - VPC Gen 1 = `vpc-classic` or `gc`
   - VPC Gen 2 = `vpc-gen2` or `g2`

Determine the zone _(found in the alert description under **zone**)_.

Determine the alert type _(found in the alert description under **operation**)_:

   - If the `operation` field value is `probeFlavor` go to [Flavor probe verification failure](#flavor-probe-verification-failure)
   - Otherwise go to [Worker failure](#worker-failure)

### Flavor probe verification failure

Identify whether there is a general problem with `flavor` using the Slack channel [#armada-xo](https://ibm-argonauts.slack.com/messages/G53AJ95TP), reviewing various fields in the results obtained form the following commands:

1. Please snooze the alert for an hour
   - This is a temporary action while the troutbridge squad fix this permanently.
1. Review the latest issues with `interrupt` labels in <https://github.ibm.com/alchemy-containers/troutbridge/issues>
   - The latest issue with a title starting `ErrorUnreconciledMachineConfig for flavor...` will likely correspond to the alert
   - There is a link direct to the XO output - open that link and skip to step 4
   - If the link did not work, note the `Provider`, `Zone` & `Flavor` from the issue
1. Query the flavor in armada-xo  
`@xo cluster.Flavor <provider>/<zone>/<flavor>`

   _Use the information from the raised issue, for example, the query for the alert above would be:_

   -  _`@xo cluster.Flavor gc/us-south-1/b2c.32x128` (for vpc-classic)_

   -  _`@xo cluster.Flavor g2/us-south-1/b2c.32x128` (for vpc-gen2)_

1. Review:
   - `LastErrorMessage` field  
_it will contain as JSON serialized `provider.Fault`_
   - `msg`, `code` & ,`ts` fields within `LastErrorMessage`.

1. Compare the `msg` field to the [Potential error messages](#potential-error-messages) below.

### Worker failure

If the alert is scoped to a single worker, the `operation` field in the alert will not be `probeFlavor`. This is likely an isolated incident for a worker.

1. Identify the affected worker
   - Check the logs in **LogDNA** for the affected environment to find out the failure that is being returned

      - Select the correct LogDNA instance for the region specified in the alert _Logs can be accessed through [the dashboard](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/process)._

      - In the left hand pane under `CLUSTER-SQUAD` there should be a view called `default-view`, use that view to search for lines including the code that relates to the alert.
1. Search the `default-view` for the text `ErrorUnreconciledMachineConfig`
   - This will highlight any workers that are experiencing this problem. An example message is:

   ```text
   engine/util.go:344 beginWorkerProvisioning bne28sqd0il7rdj04fd0 kube-bne28sqd0il7rdj04fd0-plexpencfee-default-000001e3 Operation attempt failed Deferring until next poll cycle
   ```

1. The affected worker will be the text beginning with `kube-`.

1. Query the worker in armada-xo:  
`@xo cluster.Worker <workerID>`

   _For example, the query for the log message above would be:_  
   _`@xo cluster.Worker kube-bne28sqd0il7rdj04fd0-plexpencfee-default-000001e3`_

1. From the xo output review:
   - `LastErrorMessage` field  
_it will contain as JSON serialized `provider.Fault`_
   - `msg`, `code` & ,`ts` fields within `LastErrorMessage`.
1. Take the following action
   - Acknowledge and snooze the alert, it will resolve after an hour.
   - There is automation to raise alerts for troutbridge squad to investigate during working hours. [example](https://github.ibm.com/alchemy-containers/armada-cluster/issues/3941)
1. If the alert has not resolved and there are additional alerts with the same symptoms affecting multiple workers in different clusters or where the operation is `probeFlavor`
   - Compare the `msg` field to the [Potential error messages](#potential-error-messages) below.

## Potential error messages

With the error message gathered from xo, look for the respective error message below.
_If you cannot find the error message below, page out the troutbridge squad, following the [escalation policy](#escalation-policy)!_

---

### Please check whether the resource you are requesting exists

This alert will raise issues within [troutbridge](https://github.ibm.com/alchemy-containers/troutbridge/issues) with the alert type and the cluster affected (e.g. `ErrorUnreconciledMachineConfig for bph7kl420flggoi5i16g`).

1. Open the respective issue and go to the `XO-link`, you'll want to gather the `LastErrorMessage`.

2. Reach out to the [VPC team](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD) and ask if there are any known issues and paste the results within `LastErrorMessage`. You will need to work closely with that squad to get the issue resolved.

3. Go to [Raising a Ticket with problems for VPC infrastructure](#raising-a-ticket-with-problems-for-vpc-infrastructure).

---

## Raising a Ticket with problems for VPC infrastructure

In some of the above cases it may be necessary for either us, or the user to speak with the VPC squad. For `ErrorUnreconciledMachineConfig` this is highly likely to affect all customers trying to create a worker in the region that is alerting, for at least one flavor.

The following conditions warrant a pCIE:
- A single probeFlavor alert is a pCIE
- A single worker alert is not a pCIE
- Multiple probeFlavor alerts is a pCIE
- Multiple worker alerts is a pCIE (likely cCIE)

The following conditions warrant a CIE:
- Multiple flavor and worker alerts is a CIE

1. Raise a pCIE in [containers-cie](https://ibm-argonauts.slack.com/messages/C4SN1JNG5) with the description:

   `Users may be unable to provision IKS workers on VPC Gen <X> infrastructure in <zone>`.

   _(The provider and zone are determined within the [Actions to take](#actions-to-take) section)._

2. Raise a support ticket against the VPC team following this [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-vpc-raise-support-ticket-for-worker.html).

**Do not resolve the alerts - they will autoresolve when the situation has been resolved.**

## Escalation Policy

If additional assistance is required, escalate to [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98).

  Slack Channel:
  You can contact the dev squad in the #armada-cluster channel

  GHE Issues Queue:
  You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
