---
layout: default
title: cluster-squad - IBM Cloud infrastructure temporary connection problems have been hit multiple times in the last hour when ordering workers
type: Troubleshooting
runbook-name: "cluster-squad - IBM Cloud infrastructure temporary connection problems have been hit multiple times in the last hour when ordering workers"
description: "cluster-squad - IBM Cloud infrastructure temporary connection problems have been hit multiple times in the last hour when ordering workers"
service: armada
link: /cluster/cluster-squad-bluemix-infrastructure-unplanned-event.html
playbooks: []
failure: ["IBM Cloud infrastructure temporary connection problems have been hit multiple times in the last hour when ordering workers"]
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This alert is fired when the system detects that there have been more than 3 instances of TemporaryConnectionProblem error in a single region within 2 hours when attempting to create worker instances using the appropriate infrastructure API. If there is a high number of these errors in a short time, it is indicative of the underlying infrastructure API experiencing problems.

The automation will reattempt the operation in due course, but in this particular situation there is ambiguity whether the original create worker instance request is still pending in the infrastructure API. To reduce the possibility of duplicate instances, the automation waits to see if the original request shows up before repeating the request. This can represent significant delays for the user and a CIE might be necessary, as described below.

## Example Alert

Example PD title:

- `#3533816: bluemix.containers-kubernetes.armada-cluster_ambiguous_provision_worker_softlayer`

Key alert labels:

- `provider` identifies the infrastructure provider
  - `softlayer` - IBM Cloud classic infrastructure (`classic`)
  - `g2` - IBM Cloud VPC infrastructure(`vpc` next gen)

## Investigation and Action

This situation may represent a CIE. Please follow these steps to determine impact and report to infrastructure support if necessary.

1. Note the affected infrastructure provider from the `provider` label, as described above.

1. Determine whether this is a pCIE:

   - If multiple regions are experiencing the problem, raise a pCIE and continue to the next task.
   - If only one region is hitting the problem, snooze the alert and review the situation after one hour.
   - If the alert does not auto-resolve within an hour, raise a pCIE and continue to the next task.
   - If the alert has resolved, stand down.

1. If the alert's `provider` label is `softlayer`, raise a support ticket against [IBM Cloud classic infrastructure](http://cloud.ibm.com/unifiedsupport/) account **1185207 - Alchemy Production's Account**, as follows:

   ```txt
   SUBJECT:  API Question
   SEVERITY: Severity  1
   TITLE:    IKS requests to placeOrder API are timing out
   DETAILS:

   IBM Kubernetes Service (IKS) automation requests to the IBM Cloud infrastructure
   SoftLayer_Product_Order/placeOrder API to provision resources in our customers' accounts are
   failing to respond within 120s, causing our client to experience a timeout.

   This is a CIE impacting multiple IKS customers.

   The resulting ambiguity in whether the order has been accepted represents significant disruption to
   IKS users because our automation must wait a significant amount of time before another attempt, to
   reduce the possibility of duplicate resources.

   We have experienced a significant number of these failures in multiple regions in the last hour.

   Past occurrences of this situation have been related to load and delays in IMS, resulting in it
   being unable to serve SoftLayer_Product_Order/placeOrder API requests in a reasonable time.

   The IKS control plane is hosted within IBM Cloud datacenters and uses URLs according to user
   credential, e.g.

   https://api.softlayer.com/mobile/v3/SoftLayer_Product_Order/placeOrder.json?objectMask=orderId
   https://api.softlayer.com/rest/v3/SoftLayer_Product_Order/placeOrder.json?objectMask=orderId
   ```

1. If the alert's `provider` label is `g2` (indicating vpc-gen2), open a support case against [IBM Cloud VPC Infrastructure](https://cloud.ibm.com/unifiedsupport/cases/add) account **IKS.Prod.VPC.Service (bab556e1c47446ef8da61e399343a3e7)**, as follows:

   ```txt
   TYPE OF SUPPORT: Technical
   CATEGORY: VPC/Compute
   SUBJECT: IKS request to POST compute instance API are timing out
   DESCRIPTION:

   IBM Kubernetes Service (IKS) automation requests to the IBM Cloud VPC infrastructure
   POST compute instance API to provision resources in our service accounts are
   failing to respond within 120s, causing our client to experience a timeout.

   This is a CIE impacting multiple IKS customers.

   The resulting ambiguity in whether the order has been accepted represents significant disruption to
   IKS users because our automation must wait a significant amount of time before another attempt, to
   reduce the possibility of duplicate resources.

   We have experienced a significant number of these failures in multiple regions in the last hour.

   Note: The IKS control plane is hosted within IBM Cloud datacenters.
   ```

1. Confirm the CIE ([SRE - raising a CIE](../sre_raising_cie.html)) with the following text in the notice:

   ```txt
   TITLE:   Delay with IBM Kubernetes cluster provisioning and worker node operations

   SERVICES/COMPONENTS AFFECTED:
   - IBM Kubernetes Service
   - Red Hat OpenShift on IBM Cloud

   IMPACT:
   - IBM Kubernetes Service, using classic infrastructure
   - IBM Kubernetes Service, using VPC infrastructure
   - Users may see delays in provisioning workers for new or existing clusters
   - Users may see failures in provisioning portable subnets for new or existing clusters
   - Users may see delays in provisioning persistent volume claims for existing clusters
   - Users may see delays in reloading, rebooting or deleting existing workers of clusters
   - Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

   STATUS:
   - 201X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
   ```

1. Continue to follow up with raised ticket(s) IBM Cloud infrastructure to determine when the problems being experienced are mitigated.

### Footnote

In the past, infrastructure support have responded to us opening tickets for placeOrder API timeouts with a message similar to the following:

```txt
In order for us to properly troubleshoot the connection timeouts we need some additional information.

1. The IP address api.softlayer.com resolves to.  For example,
run "host api.softlayer.com"
2. Your IP address.( remote IP )   See: http://ifconfig.me/ip
3. An MTR from remote IP to your server
4. curl https://api.softlayer.com/rest/v3/SoftLayer_Product_Order/placeOrder.json

If your operating system is Windows, then you may use WinMTR. You may get WinMTR from the URL below:
http://winmtr.net/
http://winmtr.net/how-to/
From a Linux operating system, you may run the following command: mtr -r -c 100 <IP or Domain Name>
```

This message appears to be pro forma and following these instructions on the IKS control plane is unlikely to produce useful diagnostics.
If the ticket is updated with a similar message, please stress that this situation is being experienced by IKS automation running within
the IBM Cloud infrastructure datacenters, and that historical evidence points to a problem within infrastructure's IMS system, and not the
API transport layer.

### Additional Diagnostics

   - Use these metrics to assess the trend of occurrences:

      - [prod-fra02/carrier2](https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aambiguous_provision_worker+%3E%3D+3&g0.tab=1)
      - [prod-dal12/carrier2](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aambiguous_provision_worker+%3E%3D+3&g0.tab=1)
      - [prod-lon04/carrier1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon04/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aambiguous_provision_worker+%3E%3D+3&g0.tab=1)
      - [prod-syd04/carrier2](https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd04/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aambiguous_provision_worker+%3E%3D+3&g0.tab=1)
      - [prod-tok02/carrier1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-tok02/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aambiguous_provision_worker+%3E%3D+3&g0.tab=1)
      - [prod-wdc07/carrier2](https://alchemy-dashboard.containers.cloud.ibm.com/prod-wdc07/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aambiguous_provision_worker+%3E%3D+3&g0.tab=1)

      Note these metrics do not account for all errors in a region.

   - To view live ErrorTemporaryConnection errors for all armada-cluster operations, go to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier), select *logDNA* for the impacted region to view the carrier logs, and click

      `CLUSTER-SQUAD -> ErrorTemporaryConnectionProblem`

       This view shows all ErrorTemporaryConnectionProblems for all operations and is likely to be busy if the alert has been raised. An example that may trigger this alert might look something like this:

      ```txt
      Connection to IBM Cloud infrastructure has failed: Post https://api.softlayer.com/rest/v3/SoftLayer_Product_Order/placeOrder.json?objectMask=orderId: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
      ```

      Note that a single occurrence can be logged multiple times in this view. The view might also show a general background of timeouts
      for `rebootSoft.json`, which is normal background when user's workers are not responding to soft reboot requests.

## Resolution

The CIE can be put into monitoring status when IBM Cloud infrastructure have informed us that the problems with their API have been resolved.

Monitor a sample of impacted regions using Prometheus metrics (via https://alchemy-dashboard.containers.cloud.ibm.com/carrier). Enter the expression corresponding to the alert in the box and click `Execute`:

- For `ArmadaClusterAmbiguousProvisionWorker` use `armada_cluster:ambiguous_provision_worker >= 3`

The expected count is 0. When the the metrics are stable and the alert has stopped firing, close the CIE.

## Escalation Policy

The escalation path for this runbook is entirely through IBM Cloud infrastructure, it will only fire when IBM Cloud infrastructure are experiencing consistent issues in their API processing path. There should be enough information in the runbook to avoid calling out the troutbridge squad.

If further information is required that only the troutbridge squad can provide, escalate the page to them and bring them up to speed on the status of the CIE and any updates from IBM Cloud infrastructure.
