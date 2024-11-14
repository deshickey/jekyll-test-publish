---
layout: default
title: armada-cluster-squad - Common Troubleshooting Issues
type: Troubleshooting
runbook-name: "armada-cluster - Common Troubleshooting Issues"
description: "armada-cluster - Common Troubleshooting Issues"
service: armada-cluster
link: /cluster/cluster-squad-common-troubleshooting-issues.html
playbooks: []
failure: []
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

  This runbook describes some common troubleshooting issues that users may hit, related to the armada-cluster microservice, often related to the IaaS provider. This runbook aims to help diagnose the problem and the next steps for the user to take.


## Troubleshooting Permissions and Credentials
  
### Example error messages

- Cannot create IMS portal token, as no IMS account is linked to the selected BSS account
- Provided user not found or active
- The infrastructure user is not authorized to create the worker node instance. Review '<provider>' infrastructure user permissions
- '<provider>' infrastructure exception: This cancellation could not be processed please contact support
- '<provider>' infrastructure exception: Request not authorized
- The '<provider>' infrastructure user credentials changed and no longer match the worker node instance infrastructure account.
- The worker node instance cannot be identified. Review '<provider>' infrastructure user permissions
- The worker node instance cannot be found. Review '<provider>' infrastructure user permissions

### Action

In these situations, the user should refer to the [permissions troubleshooting topic in our external documentation](https://cloud.ibm.com/docs/containers?topic=containers-cluster_infra_errors#cs_credentials).


## Why has a cluster or worker been deleted?

If a customer wants to learn why a worker in their cluster was deleted, they should first consult their Activity Tracker logs
for events such as cluster deletion, worker pool scaling, worker pool zone removal. In some cases, the automation may emit worker deletion events
that include a "reason for delete" value.

SRE can also view the `Cluster.ReasonForDelete` and `Worker.ReasonForDelete` fields using armada-xo.

Likely "reason for delete" values include:

   - `account_canceled` - User account is in cancelled state
   - `resource_controller_requested` - Resource deletion request by the Resource Controller
   - `metering_failure` - Worker destroyed during provisioning due to failure during metering
   - `provisioning_error`- Worker destroyed during provisioning due to incorrect infrastructure configuration
   - `terms_violation`
   - `trial_expired`
   - `user_requested` - Resource deletion request from user via external API
   - `worker_replaced` - Worker deleted for "worker replace" operation
   - `contract_expired` - Worker deleted because reservation contract expired
   - `ca_requested` - Cluster autoscaler requested worker deletion


## Troubleshooting worker statuses

There will be additional details visible to the user, if they expand the node in the UI, or perform  
`ibmcloud ks worker get --cluster <cluster-id> --worker <worker-id>`

in the CLI. For example:  
`ibmcloud ks worker get  --cluster 000 --worker kube-ams03-pa000-w1`

If the user has not passed on the details message that they are seeing, or if they have only provided a cluster ID, rather than an individual worker ID, then query the `clusterWorkers` using armada-xo, and look at the `Status` fields. 

_Armada-xo is a Slackbot which is available only in private channel #armada-xo within the Argonauts Slack team. If you need to access armada-xo and are not currently a member of the channel, then a Conductor should be able to invite you._

For example:  
`@xo clusterWorkers bn68fk4htjcngjx4hkfi`

For a given worker ID you can then query `cluster.Worker`, and look at the `Status`, `ErrorMessage` and `LastErrorMessage` fields.

For example:  
`@xo cluster.Worker kube-bn68fk4htjcngjx4hkfi-abc-def-0001`

---

### Infrastructure operation: Cancelled

If a worker remains in this state for a period of time, then it is possible that the order has been manually cancelled outside of the IKS automation, and not sufficiently updated to allow IKS to progress. 

In the case of a classic worker:

Review the logs for the worker using the CLUSTER-SQUAD->default-view.
Use the search term: "workerID":<workerID> AND "Examining order"
Review the log entry, in particular the order details.
An incorrectly cancelled order will have an entry at order.items[0] that looks like the following...
{
  "id": 754372884,
  "provisionTransaction": {
    "id": 208954106,
    "transactionStatus": {
      "friendlyName": "Cancelled",
      "name": "CANCELLED"
    }
  }
}
A correctly cancelled order will have an entry at order.items.[0] that looks like the following...
{
  "cancellationDate": "2020-10-28T06:29:03-05:00",
  "id": 756212324,
  "provisionTransaction": {
    "id": 209150706,
    "transactionStatus": {
      "friendlyName": "Complete",
      "name": "COMPLETE"
    }
  }
}
The support ticket will need to be routed to the Classic infrastructure team for them to add a cancellationDate to the parent billing item on the order for the worker in question.

### Infrastructure operation: XXX

(Formerly "IBM Cloud classic infrastructure operation: XXX")

See [below](#infrastructure-instance-status-is-xxx).

### Operation pending while instance status is 'XXX'

(Formerly "Currently unable to perform operation. IBM Cloud classic infrastructure operation: XXX")

See [below](#infrastructure-instance-status-is-xxx).

### The operation cannot complete while the infrastructure instance status is 'XXX'  

See [below](#infrastructure-instance-status-is-xxx).

### The operation cannot complete due to the infrastructure resource state  

See [below](#infrastructure-instance-status-is-xxx).

### Operation pending due to infrastructure resource state  

See [below](#infrastructure-instance-status-is-xxx).

### Infrastructure instance status is 'XXX'  

#### For classic infrastructure (SoftLayer) workers

In this message, the `XXX` identifies the infrastructure operation (a.k.a transaction) that is currently being performed, for example `Infrastructure operation: Cloud Template Transfer`, or `Infrastructure operation: Setup provision configuration` (NOTE: these are just examples, this runbook applies to other variations of `Infrastructure operation` errors as well). IKS is waiting for this operation to complete before moving to the next step in provisioning, reloading or deleting a worker.

These messages are generally expected, and are only a problem if a worker has been stuck in this status for a long time. However, it should be remembered that particular physical machines can take significantly longer to provision or reload when compared to virtual machines. 

If a user is concerned about the length of time an operation is taking, ask them to [raise a support ticket](#raising-a-support-ticket) against their IBM Cloud classic infrastructure account, including:

  - The full worker ID (with the `kube-` prefix) as the infrastructure VSI or bare metal machine hostname.
  - The operation name quoted in the message (i.e. `XXX` value).

#### For VPC infrastructure (vpc-classic, vpc-gen2) workers

This message identifies the status (`XXX`) of the infrastructure compute instance for the IKS worker in IBM Cloud VPC. IKS is waiting for this operation to complete before moving to the next step in provisioning, reloading or deleting a worker.

These messages are generally expected, and are only a problem if a worker has been stuck in this status for a long time. 

If a user is concerned about the length of time an operation is taking, [raise a support ticket](#raising-a-support-ticket) against our "IBM Cloud VPC on Classic" or "IBM Cloud VPC Gen 2" infrastructure service account as applicable, including:

  - The full worker ID (with the `kube-` prefix) as the compute instance hostname.
  - The content of this instance status or action status message.

---

### Pending network creation with first worker

This message is expected to occur when no VLANs were specified on worker pool creation, for a short time.

In this scenario, the first worker to attempt provisioning, orders VLANs that can then be used by subsequent workers in the worker pool. However, in the scenario where the first worker has failed to provision, and the VLANs are not successfully ordered, the instance group gets stuck waiting and the state becomes unrecoverable.

The advice in this scenario is as follows:

```txt
  This scenario has arisen because the first worker to attempt provisioning in this zone has not completed successfully. If the worker is still attempting to provision, allow it to continue and if successful, the message should resolve.

  If the first worker has failed to provision, the user could instead manually create the VLANs to use in their cluster within IBM Cloud Infrastructure. They would then need to either:
  - delete the "Pending" workers (`ibmcloud ks worker rm`), update the zone VLANs to the ones that were manually created (`ibmcloud ks zone network-set`) and then rebalance (`ibmcloud ks worker-pool rebalance`)
  or
  - delete the zone from the worker pool (`ibmcloud ks zone rm`) and recreate using the VLANs that were manually created (`ibmcloud ks zone add`)
```

---

### Temporarily backing off provision attempts

  If we experienced a timeout on our request to order a worker from the IaaS provider, armada-cluster will not attempt to re-order the worker for a period of 2 hours. This is a defensive mechanism to prevent erroneously provisioning duplicate workers when a re-order is attempted during an extended outage in an IaaS provider.

  The user can be advised that provisioning will automatically resume after at most 2 hours, and there is no action that they need to take.

---

### Failed to register the worker with the resource controller

(Formerly "Failed to register worker")

Consider the message within the `LastErrorMessage` field in `armada-xo` for the `cluster.Worker` (see [here](#troubleshooting-worker-statuses)).

#### The resource group XXXXXXXXXXXXXXXXXXXX is inactive with state: SUSPENDED

In this case, raise a new issue for BSS at https://github.ibm.com/BSS/issues/issues/new. 
Include the following information:
- Customers account ID - this can be found by searching for the cluster using armada-xo
- Resource group ID - from the `LastErrorMessage`
- Any `wrapped` elements within the LastErrorMessage

The BSS team will then review why the resource group for the customer is in suspended state. The customer will have to wait for a resolution to the issue before trying to provision a worker again.

#### Unexpected resource registration status
In this case the response for the user is:

```txt
The cause of this situation is a problem where a previously deleted worker ID being re-used. This can happen when a cluster has been scaled down and then scaled back up after a period of time.

You should continue to add workers into the cluster, until the addition of a worker is successful. You will not be billed for the workers that reach Failed to register. Once you have a successful worker, the ones that failed can be deleted.

A new cluster and worker naming scheme has been released which has addressed this issue, however it is only applicable for new clusters.
```

#### Other worker registration failures
Other errors messages are likely to be the cause of a problem with the BSS metering service, for example if there has been a recent CIE. 
- If the worker is still in `provisioning` state, then it will automatically retry, which could resolve the problem if the BSS problems are now resolved.
- If the worker has reached `provision_failed`, then the user will not have been charged for this worker. The user can retry adding a new worker, and delete the failed one.
- The ['How to debug BSS Resource Controller or Metering failures'](./cluster-squad-bss-failures.html) runbook may give further explanation on outages that could have occurred, if required.

---

### Temporarily backing off after repeated deployment attempts and reloads

If the user has manually requested several reloads, then this is expected behaviour and no action is needed. The backoff will be released when the timeout has expired.

Otherwise the machine must be hitting multiple bootstrap failures or timeouts. [This text](https://github.ibm.com/alchemy-containers/armada-bootstrap-squad/blob/master/ticketresponses/firewall) needs to be copied to the customer and a response received. Then visit the [bootstrap troubleshooting runbook](../armada/armada-bootstrap-failures.html) in order to diagnose this further, and escalate to the bootstrap squad if necessary.

---

### Hostname does not match worker

See [below](#hostname-and-domain-do-not-match-worker).

### Hostname and domain do not match worker

These statuses suggest that the name of the machine within the IaaS provider has had it's name changed from the name that IKS originally created it with.

For example, for `softlayer` (classic) workers, the hostname must be the worker ID, and:
- If the worker ID is of the form `kube-zone-clusterID-workerNumber`, then the domain must be `cloud.ibm`.
- If the worker ID is of the form `kube-clusterID-clusterName-workerPoolName-workerNumber`, then the domain must be `iks.ibm`.

The hostname and domain of the machine must be reverted to the original values that IKS set them to, otherwise IKS will not recognise the machine. Once this has been completed, directly within the IaaS provider, the user can re-attempt the worker operation.

---

### 'classic' infrastructure exception: Unable to order worker nodes in the specified location

  (Formerly "IBM Cloud infrastructure exception: Unable to order worker nodes in the specified location")

  This error message has been previously seen when the user's account was not eligible to order machines from the correct package in a particular location.

  For `patrol` workers, the user needs to [raise a support ticket](#raising-a-support-ticket) in their IBM Cloud infrastructure account:

  ```txt
  SUBJECT: Unable to order machines
  DETAILS: I am trying to order a machine in '<datacenter>' location but I'm receiving the error 'SoftLayer_Exception_Order_InvalidLocation: The location provided for this order is invalid. (HTTP 500)'.
  
  Please escalate this ticket and assign it to BSS Catalog Management so they can verify that my account's brand is setup correctly for ordering from the 'BLUEMIX_CONTAINER_SERVICE', 'BARE_METAL_CONTAINER_EDGE', and '2U_BARE_METAL_CONTAINER' packages in location '<datacenter>'.
  ```
 
  If the issue is being seen when creating patrols, a Conductor will need to [raise a support ticket](#raising-a-support-ticket) for the IBM Cloud infrastructure account for the environment, in which the issue is being seen.

  The text to enter on the ticket is:

  ```txt
  I am trying to order a machine in '<datacenter>' location but I'm receiving the error 'SoftLayer_Exception_Order_InvalidLocation: The location provided for this order is invalid. (HTTP 500)'.
  
  Please escalate this ticket and assign it to BSS Catalog Management so they can verify that my account's brand is setup correctly for ordering from the 'CLOUD_SERVER' package in location '<datacenter>'.
  ```
---

### 'classic' infrastructure exception: Your account is currently prohibited from ordering 'Computing Instances'. If you have any questions please open a sales ticket.

  (Formerly "IBM Cloud infrastructure exception: Your account is currently prohibited from ordering 'Computing Instances'. If you have any questions please open a sales ticket.")

  This error message has been previously seen when the user's account restricted from ordering machines by IBM Cloud infrastructure. In this case, the user  (or Conductor, in the case of `patrol` workers) needs to [raise a support ticket](#raising-a-support-ticket):
  
  ```txt
  SUBJECT: Prohibited from ordering machines
  DETAILS: The following error was received when trying to order a machine: `'classic' infrastructure exception: Your account is currently prohibited from ordering 'Computing Instances'. If you have any questions please open a sales ticket.`
  
  Why is this account currently prohibited from ordering machines? Can this restriction can be lifted, please?
  ```

---

### 'classic' infrastructure exception: Could not place order. There are insufficient resources behind router 'router_name' to fulfill the request for the following guests: 'worker_id'

(Formerly "IBM Cloud classic infrastructure exception: Could not place order. There are insufficient resources behind router 'router_name' to fulfill the request for the following guests: 'worker_id'")

See [below](#classic-infrastructure-exception-there-is-insufficient-capacity-to-complete-the-request).

### 'classic' infrastructure exception: Could not place order. There is insufficient capacity to complete the request.

(Formerly "IBM Cloud classic infrastructure exception: Could not place order. There is insufficient capacity to complete the request.")

See [below](#classic-infrastructure-exception-there-is-insufficient-capacity-to-complete-the-request).

### 'classic' infrastructure exception: Could not place order. There are insufficient resources in 'location' to fulfill the request for the following guests: 'worker_id'

(Formerly "IBM Cloud classic infrastructure exception: Could not place order. There are insufficient resources in 'location' to fulfill the request for the following guests: 'worker_id'")

See [below](#classic-infrastructure-exception-there-is-insufficient-capacity-to-complete-the-request).

### 'classic' infrastructure exception: There is insufficient capacity to complete the request.

  (Formerly "IBM Cloud classic infrastructure exception: There is insufficient capacity to complete the request.")
  
  This error message indicates that there is no space available within the IBM Cloud infrastructure datacenter to provision the worker machines. In this situation the user may need to consider creating their cluster in a different datacenter. Otherwise they would need to open a ticket with IBM Cloud infrastructure to find out if/when additional capacity may become available.

---

### 'classic' infrastructure exception: As an active participant of the Technology Incubator Program, you may not combine these discounts with any reseller discounts. Please check with the sales team to verify that your account is setup correctly.

  (Formerly "IBM Cloud classic infrastructure exception: As an active participant of the Technology Incubator Program, you may not combine these discounts with any reseller discounts. Please check with the sales team to verify that your account is setup correctly.")
  
  This error describes an IBM Cloud infrastructure account configuration issue. In this case, the user meeds to [raise a support ticket](#raising-a-support-ticket) in their IBM Cloud infrastructure account, quoting the error string, in order to resolve the configuration problem.

---
  
### Request rate limit exceeded for `<provider>` infrastructure
  
  (Formerly "IBM Cloud classic infrastructure rate limit exceeded")
  
  This is a temporary exceptions, and armada-cluster will automatically retry, and hopefully succeed on the next attempt.

---

### Worker properties incomplete

  This should never happen - if it does, create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new).

---


## Raising a support ticket

In some of the above cases it may be necessary for either us, or the user to contact the IaaS provider directly.

1. For `patrol` workers using the `softlayer` (classic) provider, raise a support ticket against [IBM Cloud classic infrastructure](https://control.softlayer.com) account **1185207 - Alchemy Production's Account**. Usually the 'Subject' will be `API Question`.

1. For other workers using the `softlayer` (classic) provider, the *user* will need to raise a support ticket directly against [their IBM Cloud classic infrastructure](https://control.softlayer.com) account.

1. For workers using the `g2` VPC Gen 2 provider
    1. Where we have an existing customer support ticket, request that ACS forward the ticket on to the VPC Support Team.
    1. Where we do not have a customer support ticket, please follow [this runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-vpc-raise-support-ticket-for-worker.html) to raise a support ticket for the VPC team


## Example Alerts

Not applicable


## Investigation and Action

Not applicable


## Escalation Policy

For any other issues, if the error message does not make it clear how to resolve, or if it is not listed in the above messages, then escalate to the troutbridge team for further investigation.
