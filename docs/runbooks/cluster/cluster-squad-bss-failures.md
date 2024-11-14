---
layout: default
title: armada-cluster - How to debug BSS Resource Controller or Metering failures
type: Alert
runbook-name: "armada-cluster - How to debug BSS Resource Controller or Metering failures"
description: armada-cluster - How to debug BSS Resource Controller or Metering failures
category: armada
service: armada-cluster
link: /cluster/cluster-squad-bss-failures.html
tags: armada-cluster, bss, metering
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

These alerts will trigger when more than 50 occurrences of an error from the BSS resource controller or BSS metering service occur within an hour.

## Example Alerts

There are **four alerts** that can indicate failures when interacting with the following BSS services:

- Metering service
- Resource Controller

### Metering service examples

PD title:

`#3533815: bluemix.containers-kubernetes.armada-cluster_error_metering_service.us-south`
`#3533816: bluemix.containers-kubernetes.armada-cluster_error_metering_service_cluster.us-south`
`#3533817: bluemix.containers-kubernetes.armada-billing_error_metering_service_ccontract.us-south`
`#3533818: bluemix.containers-kubernetes.armada-billing_error_metering_service_qnassignment.us-south`

### Resource Controller examples

PD title:

`#3533821: bluemix.containers-kubernetes.armada-cluster_error_resource_controller.us-south`
`#3533822: bluemix.containers-kubernetes.armada-cluster_error_resource_controller_cluster.us-south`
`#3533823: bluemix.containers-kubernetes.armada-billing_error_resource_controller_ccontract.us-south`
`#3533824: bluemix.containers-kubernetes.armada-billing_error_resource_controller_qnassignment.us-south`

## Actions to Take

The steps below describe the operations to perform to determine the appropriate action.

1. Review the alert from an affected region and make a note of the value in the `reason_code` field

1. Check the logs in **LogDNA** for the chosen region

    1. Select the correct LogDNA instance for the region specified in the alert  
    Logs can be accessed through [the dashboard](https://alchemy-dashboard.containers.cloud.ibm.com) 
    1. In the left hand pane under `CLUSTER-SQUAD` there should be a view called `MeteringErrors`, open that view
    1. Enter the reason code from the alert to the search bar in LogDNA
    1. Use that view to search for lines containing the value for the `reason_code` field in the alert

1. Check whether the failure is affecting more than one user

   Here is an example message:

   ```text
      May 31 08:19:16 armada-cluster-7ddc797fcf-4ltrd armada-cluster error engine/workers_util.go:305 pollWorkerDeleting

      ErrorMeteringServiceFailure: Worker action callback failed: ErrorMeteringServiceFailure  The usage recording request failed. (202)
      Wrapped Errors: ["db_error: Error while logging output (500)"]

      AccountID: abac0df06b644a9cabc6e44f55b3880e
      Worker:  caaiip3f0fpo87n90eg0 / kube-caaiip3f0fpo87n90eg0-pvdscdocped-transit-00000981
      Properties: {
      "AccountID": "abac0df06b644a9cabc6e44f55b3880e",
      "BSSTransactionID": "da77f4b6-87b2-4086-99e7-b388bcbbe336",
      "PlanID": "containers.kubernetes.vpc.gen2.roks",
      "RegionID": "eu-de",
      "StatusCode": "202"
      }
      TransactionID: 8500be76-f481-4dc4-a561-9975f66cfdae
   ```

   - Determine whether the failures are all associated with a **single** user account within the selected region, use:  
   `AccountID`   _(located in the properties)_

1. Copy an entire log message example from logDNA as per the example above.

1. Add the log message as a note on the alert.

1. If the alert has fired on the 1st of the month, contiue to [BSS troubleshooting](#bss-troubleshooting), otherwise continue to the next step.

1. If more than one account is affected, contact the on call AVM to establish if there are known issues with the BSS systems (Resource Controller, Metering Collector and Account Manager)

1. If more than one region is affected, go to [Actions to Take](#actions-to-take) and repeat the above steps for the other affected regions until it's established whether multiple accounts are impacted. If so, go to [Escalation Policy](#escalation-policy)

1. If the message associated with the error is `The account ID in the payload does not match the account ID in the resource group.`, go to [Shared Resource Groups](#shared-resource-groups)

1. Otherwise, if no escalation is required at this time, [raise an issue](https://github.ibm.com/alchemy-containers/troutbridge/issues) documenting your findings and tag `@troutbridge` in `#armada-cluster` for investigation in office hours.

## Shared Resource Groups

As per [Ironsides#7309](https://github.ibm.com/alchemy-containers/armada-ironsides/issues/7309) it looks like it is possible for enterprise accounts to share a resource group across sub-accounts. This is not a scenario that is supported by IKS or ROKS. 

**Actions**

Acknowledge the alert, when the cluster has reached a failed state the alert will resolve shortly afterwards. _This is not a pCIE of cCIE situation and should not require escalation to the development squads outside of office hours._

**Resolution**
Requests to create clusters using a resource group outside of their account will be accepted by the API, but the cluster will eventually reach a failed state. The cluster will need to be deleted and the customer will need to retry the cluster provision targeting a resource group within the same account.


## BSS troubleshooting

These steps should only be followed if you were redirected here from [Actions to Take](#actions-to-take).

Changes to existing BSS plans get promoted on the 1st of each month.
If these alerts fire in multiple regions for the same plan on the 1st of the month, please engage with the BSS team.

1. Gather your log message gathered in [Actions to Take](#actions-to-take) and reach out to [#bss](https://ibm-cloudplatform.slack.com/archives/C081NLV9U) to check if there are any current issues:

   Here is an example message:

   ```text
      Hey team, we are experiencing issues submitting metering for a specific plan: <PLAN_ID> across multiple regions.
      Would someone from the BSS team be able to review recent plan promotions to ensure everything was promoted successfully.
      Are you able to check the following Transaction ID: 8500be76-f481-4dc4-a561-9975f66cfdae?
   ```

   ```text
      May 31 08:19:16 armada-cluster-7ddc797fcf-4ltrd armada-cluster error engine/workers_util.go:305 pollWorkerDeleting

      ErrorMeteringServiceFailure: Worker action callback failed: ErrorMeteringServiceFailure  The usage recording request failed. (202)
      Wrapped Errors: ["db_error: Error while logging output (500)"]

      AccountID: abac0df06b644a9cabc6e44f55b3880e
      Worker:  caaiip3f0fpo87n90eg0 / kube-caaiip3f0fpo87n90eg0-pvdscdocped-transit-00000981
      Properties: {
      "AccountID": "abac0df06b644a9cabc6e44f55b3880e",
      "BSSTransactionID": "da77f4b6-87b2-4086-99e7-b388bcbbe336",
      "PlanID": "containers.kubernetes.vpc.gen2.roks",
      "RegionID": "eu-de",
      "StatusCode": "202"
      }
      TransactionID: 8500be76-f481-4dc4-a561-9975f66cfdae
   ```

1. If the BSS team are unable to help, or the issue isn't on their side, go to [Escalation Policy](#escalation-policy).
---
### Single account - not a CIE

On occasion we have seen failures being returned for a single IBM Cloud account, because the account is not configured correctly.

| Message | Action |
| -- | -- |
| `Default resource group does not exist` | [Escalation Policy](#escalation-policy) |
| `The resource group XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX is inactive with state: DELETED` | [Escalation Policy](#escalation-policy) |
| `expired_usage: Usage should be submitted within 8640000000ms (400)` | [Escalation Policy](#escalation-policy) |

For any other messages - [Escalation Policy](#escalation-policy)

### Multiple accounts - pCIE

1. Has there been an ETCD restore?
   - If **yes** - Was a backup performed first? If any data loss occurred, then it is likely we're hitting data inconsistency issues. In this case escalate to troutbridge team for them to verify that this is the situation, providing details of the etcd data loss that has occurred.
   - If **not** - continue below.

1. Send a high priority alert, containing the log message making sure to include the `TransactionID`, `AccountID` & `Wrapped Errors`, to the BSS team for them to investigate the failure. The PagerDuty alert will determine where this issue should get escalated to:

   | Alert | Channel | Escalation Policy |
   | -- | -- | -- |
   | `armada-cluster_error_metering_service` <br> `armada-cluster_error_metering_service_cluster` <br> `armada-cluster_error_metering_service_ccontract` <br> `armada-cluster_error_metering_service_qnassignment` | [#metering-adopters](https://ibm-cloudplatform.slack.com/archives/C9UGSQW8K) | [Bluemix BSS Metering](https://ibm.pagerduty.com/escalation_policies#PICP7UN) |
   | `armada-cluster_error_resource_controller` <br> `armada-cluster_error_resource_controller_cluster` <br> `armada-billing_error_resource_controller_ccontract` <br> `armada-billing_error_resource_controller_qnassignment` | [#rc-adopters-behind](https://ibm-argonauts.slack.com/archives/C7LRSJYSW) | [Bluemix BSS Provisioning and Resource Controller](https://ibm.pagerduty.com/escalation_policies#PGPNMQI) |

   **NOTE:** You won't need to page out the troutbridge squad.

1. As this is affecting multiple accounts, a **pCIE** should be raised and then confirmed as a **CIE**.

   The impact on users will be that they are unable to provision or delete workers, as we are unable to guarantee that we have successfully started/stopped metering for the workers.  
   The notice for the CIE can be:

   ```text
   TITLE:   Issue with IBM Kubernetes cluster provisioning and worker node operations

   SERVICES/COMPONENTS AFFECTED:
   - IBM Kubernetes Service
   - Red Hat OpenShift on IBM Cloud

   IMPACT:
   - Users may be unable to provision new Kubernetes clusters
   - Users may be unable to provision workers for existing Kubernetes clusters
   - Users may be unable to remove workers for existing Kubernetes clusters

   STATUS:
   - 201X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
   ```

1. The alerts will automatically resolve within an hour of the underlying issue being fixed
---

## Escalation Policy

If assistance is required during UK business hours, please inform the troutbridge squad in #armada-cluster.

Otherwise, if help is required outside UK business hours, escalate to [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) through PagerDuty.
