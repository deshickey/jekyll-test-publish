---
layout: default
title: armada-cluster - ErrorUnreconciledMachineConfigSoftLayer
type: Alert
runbook-name: "armada-cluster - ErrorUnreconciledMachineConfigSoftLayer"
description: Armada cluster - ErrorUnreconciledMachineConfigSoftLayer
service: armada-cluster
link: /cluster/cluster-squad-error-unreconciled-machine-config-softlayer.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert generally means that there is something wrong with an order for a classic worker or the verification of a classic flavor, be it a problem with the price items or a change to the product package.
It's highly likely that a CIE will be required, but the impact should be assessed and understood before a CIE is raised.

## Example Alert(s)

Example PD title:
- `#30960XXX: bluemix.containers-kubernetes.prod-wdc07-carrier2.armada-cluster_red_alert_error_unreconciled_machine_config_softlayer_worker.us-east`
- `#30960XXX: bluemix.containers-kubernetes.prod-wdc07-carrier2.armada-cluster_red_alert_error_unreconciled_machine_config_softlayer_flavor.us-east`

## Actions to Take

This alert is triggered when there is a mismatch between our metadata and the Infrastructure provider. There are two outcomes which trigger the alert:

  1. Flavor probe verification
  1. Worker provision

To identify the trigger in this case, look at the `operation` field within the PagerDuty alert:

- If the `operation` field value is `probeFlavor` go to [Flavor probe verification failure](#flavor-probe-verification-failure)
- Otherwise go to [Worker failure](#worker-failure)

### Flavor probe verification failure

Identify whether there is a general problem with `flavor` using the Slack channel [#armada-xo](https://ibm-argonauts.slack.com/messages/G53AJ95TP), reviewing various fields in the results obtained form the following commands:

1. Review the latest issues with `interrupt` labels in <https://github.ibm.com/alchemy-containers/troutbridge/issues>
   - The latest issue with a title starting `ErrorUnreconciledMachineConfig for flavor...` will likely correspond to the alert
   - There is a link direct to the XO output - open that link and skip to step 4
   - If the link did not work, note the `Provider`, `Zone` & `Flavor` from the issue
1. Query the flavor in armada-xo  
`@xo cluster.Flavor <provider>/<zone>/<flavor>`

   _Use the information from the raised issue, for example, the query for the alert above would be:_  
   _`@xo cluster.Flavor softlayer/mex01/b2c.32x128`_

1. **NOTE** If the zone is `mel01` and the flavor is `free`  
This alert is expected to fire until the production freeze is over and the corrective change can be promoted.
   - Acknowledge the alert and snooze as it will resolve after ~30 minutes  
   _before firing again after an hour_

1. Review:
   - `LastErrorMessage` field  
   _it will contain as JSON serialized `provider.Fault`_
   - `msg`, `code` & ,`ts` fields within `LastErrorMessage`.

1. Compare the `msg` field to the [Potential error messages](#potential-error-messages) below.

### Worker failure

If the alert is scoped to a single worker, the `operation` field in the alert will not be `probeFlavor`. This is likely an isolated incident for a single worker.

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

### Found no packages matching keyname: XXX

In this case, it is likely that the SoftLayer package we order our VSIs and Baremetal machines from is no longer accessible.

In this instance, perform the following diagnosis steps

1. Navigate to <https://api.softlayer.com/rest/v3/SoftLayer_Product_Package/getAllObjects> in a browser authenticating with a set of infrastructure API credentials.

2. From the list validate the following packages exist

    - ID: 801, Keyname: BLUEMIX_CONTAINER_SERVICE
    - ID: 46,  Keyname: CLOUD_SERVER
    - ID: 995, Keyname: 2U_BARE_METAL_CONTAINER
    - ID: 997, Keyname: BARE_METAL_CONTAINER_EDGE

Make a note of the missing package details, then a ticket should be raised with IBM Cloud infrastructure support. The details for how to raise this can be found [here](#raising-a-ticket-with-problems-for-classic-infrastructure).

The ticket should be along the lines of:

  ```txt
  SUBJECT: Missing SoftLayer package
  DETAILS: The package list at https://api.softlayer.com/rest/v3/SoftLayer_Product_Package/getAllObjects does not include package details for our service. The missing packages are: <missing packages>.

  This change to the catalog is causing our production system to fail to order servers for our customers, because we are unable to select the correct package.
  ```

---

### 'classic' infrastructure exception: XXX cannot be ordered with location XXX.

(Formerly "IBM Cloud classic infrastructure exception: XXX cannot be ordered with location XXX.")

In this case, it is likely that the flavor (machine type) specification is not valid for this specific zone (datacenter).
* Reassign the alert to the [troutbridge squad](#escalation-policy)  
_So that a decision can be made about whether this flavor should be deprecated for this zone, as the message indicates that users would not be able to order machines of this machine type in this zone successfully._

---

### The location provided for this order is invalid

This means that SoftLayer have removed a zone from our packages (causing all provisioning to fail for that zone). 

1. Provide the following information in a pCIE following the [raising a ticket](#raising-a-ticket-with-problems-for-classic-infrastructure) process.

`pCIE text`:
```
   Customers unable to order workers in <zone>
```

`SoftLayer ticket text`:
```
   SUBJECT: Regions missing from IKS specific packages
   DETAILS: The zone <zone> has been removed from one or more of the IKS specific packages. The IKS packages are:
      ID: 801, Keyname: BLUEMIX_CONTAINER_SERVICE
      ID: 46, Keyname: CLOUD_SERVER
      ID: 995, Keyname: 2U_BARE_METAL_CONTAINER
      ID: 997, Keyname: BARE_METAL_CONTAINER_EDGE

   Please escalate this ticket to SoftLayer OM team.
```

---

### Bootstrap init URL not defined

There is a possibility that the problem is with the carrier config maps, and that the value for `ARMADA_BOOTSTRAP_URL` in the `armada-info-configmap` is invalid. As the bootstrap URLs are provided by the bootstrap squad in the `BootstrapMetaData`...
* Escalate to the [bootstrap squad](https://ibm.pagerduty.com/escalation_policies#P42TSXQ) so they can review the metadata.

---

### 'classic' infrastructure exception: Invalid URL provided for a provisioning script

(Formerly "IBM Cloud classic infrastructure exception: Invalid URL provided for a provisioning script")

See [Bootstrap init URL not defined above](#bootstrap-init-url-not-defined).

---

## Raising a Ticket with problems for classic infrastructure

In some of the above cases it may be necessary for either us, or the user to raise a SoftLayer ticket. For `ErrorUnreconciledMachineConfig` this is highly likely to affect all customers trying to create a worker in any region, for at least one machine type.

If the issue exists in multiple production environments then you will also need to raise a pCIE.

1. Raise a `Sev1` support ticket against [IBM Cloud classic infrastructure](https://control.softlayer.com) account **531277 - Alchemy Production's Account**.

2. Provide the affected devices with IDs, credentials, etc provided where necessary.

3. Raise a pCIE in [containers-cie](https://ibm-argonauts.slack.com/messages/C4SN1JNG5) mirroring the information in the SoftLayer ticket.

4. Escalate the issue with the TAM to ensure a quick response from the support team.

5. Monitor the situation until all alerts have resolved.

If the issue is not affecting all production environments then the severity of the ticket should be lowered, but the information given in the ticket will stay the same.

**Do not resolve the alerts - they will autoresolve when the situation has been resolved.**

## Escalation Policy

If additional assistance is required, escalate to [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98).

Slack Channel: You can contact the dev squad in the #armada-cluster channel

GHE Issues Queue: You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
