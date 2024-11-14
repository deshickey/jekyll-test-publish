---
layout: default
title: armada-cluster - IBM Cloud infrastructure temporary connection problems
type: Troubleshooting
runbook-name: "armada-cluster - IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing worker or subnet operations"
description: "armada-cluster - IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing worker or subnet operations"
service: armada
link: /cluster/cluster-squad-ibmcloud-infrastructure-connection-problems.html
playbooks: []
failure: ["IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing worker operations", "IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing subnet operations"]
tags: [
  "ArmadaClusterErrorTemporaryConnectionProblemWorker",
  "ErrorTemporaryConnectionProblemWorker",
  "ArmadaClusterErrorTemporaryConnectionProblemSubnet",
  "ErrorTemporaryConnectionProblemSubnet",
]
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

  This alert is fired when the system detects that there have been more than 3 instances of TemporaryConnectionProblem error in a single region within 30 minutes when attempting to perform worker or subnet operations.

  In the past when we have been receiving a large number of these errors in a short time, it's been indicative of the underlying IBM Cloud infrastructure API experiencing an `unplanned event`

## Example Alerts

### Example Worker Alert

Example PD title:

- `#3533816: bluemix.containers-kubernetes.armada-cluster_error_temporary_connection_worker`

Example Body:

```yaml
Labels:
- severity = "critical",
- service = "armada-cluster",
- instance = "172.16.29.206:6970",
- hostname = "10.176.211.79",
- alert_situation = "armada-cluster_error-temporary-connection-worker"
Annotations:
- summary = "IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing worker operations"
- description = "IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing worker operations"
- runbook = "https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster/cluster-squad-ibmcloud-infrastructure-connection-problems.html"
```

### Example Subnet Alert

Example PD title:

- `#3533816: bluemix.containers-kubernetes.armada-cluster_error_temporary_connection_subnet`

Example Body:

```yaml
Labels:
- severity = "critical",
- service = "armada-cluster",
- instance = "172.16.29.206:6970",
- hostname = "10.176.211.79",
- alert_situation = "armada-cluster_error-temporary-connection-subnet"
Annotations:
- summary = "IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing subnet operations"
- description = "IBM Cloud Infrastructure temporary connection problems have been hit multiple times in the last 30 minutes when performing subnet operations"
- runbook = "https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster-squad-ibmcloud-infrastructure-connection-problems.html"
```

## Investigation and Action

  1. Check the following URLs to see if this is a problem that is hitting multiple regions:

      **For Worker Alerts**

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon04/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon04/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd04/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd04/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-tok02/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-tok02/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-wdc06/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-wdc06/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_worker+%3E%3D+3&g0.tab=1)
      
      **For Subnet Alerts**

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon04/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon04/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd04/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd04/carrier2/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-tok02/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-tok02/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1)

      - [https://alchemy-dashboard.containers.cloud.ibm.com/prod-wdc06/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-wdc06/carrier1/prometheus/graph?g0.expr=armada_cluster%3Aerror_temporary_connection_subnet+%3E%3D+3&g0.tab=1)


    * If multiple regions are seeing instances of this raise a pCIE and continue to the next task.
    * If only one region is hitting the problem, snooze the alert and review the situation after an hour. If the alert has not auto resolved, continue on to the next task. If the alert has resolved - stand down.


  2. From account 1185207 Raise a severity 1 ticket against IBM Cloud infrastructure indicating that their API may be experiencing problems. Use the following text when raising the issue:

      ```
      *Subject*: API Question
      *Severity*: Severity  1
      *Title*: Our requests to the IBM Cloud infrastructure API have been timing out
      *Details*:

      
      IBM Kubernetes Service system monitoring have picked up increased number of HTTP request time outs when invoking the IBM Cloud Infrastructure API.

      Some example API calls that the IBM  Kubernetes Service platform makes using the softlayer-go client are below:
      
      Post https://api.softlayer.com/rest/v3/SoftLayer_Virtual_Guest/XXXXXXXX/reloadOperatingSystem.json: net/http: request canceled (Client.Timeout exceeded while awaiting headers) 
      
      Get https://api.softlayer.com/mobile/v3/SoftLayer_Virtual_Guest/XXXXXXXX/rebootSoft.json: net/http: request canceled (Client.Timeout exceeded while awaiting headers)

      Post https://api.softlayer.com/mobile/v3/SoftLayer_Product_Order/placeOrder.json?objectMask=orderId: net/http: request canceled (Client.Timeout exceeded while awaiting headers) 

      Post https://api.softlayer.com/rest/v3/SoftLayer_Billing_Item/XXXXXXXX/cancelItem.json: net/http: request canceled (Client.Timeout exceeded while awaiting headers)

      Customer specific information has been removed from the URLs above. The IKS platform provides services that interact with IBM Cloud Infrastructure for many customer accounts.

      We've received a number of these failures within the last 30 minutes. Are you experiencing issues with the underlying API?
      ```

  3. Confirm the CIE with the following text in the notice:

  ```txt
   TITLE:   Delay with IBM Kubernetes cluster provisioning and worker node operations

   SERVICES/COMPONENTS AFFECTED:
   - IBM Kubernetes Service

   IMPACT:
   - IBM Kubernetes Service, using classic infrastructure
   - IBM Kubernetes Service, using VPC on Classic infrastructure
   - Users may see delays in provisioning workers for new or existing clusters
   - Users may see failures in provisioning portable subnets for new or existing clusters
   - Users may see delays in provisioning persistent volume claims for existing clusters
   - Users may see delays in reloading, rebooting or deleting existing workers of clusters
   - Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

   STATUS:
   - 201X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
   ```

  4. Continue to follow up with IBM Cloud infrastructure to determine when their API recovers from the problems being experienced.

## Resolution

The CIE can be considered resolved when IBM Cloud infrastructure have informed us that the problems with their API have been resolved.

An additional check that can be run is to review the Prometheus charts for our environments (accessible from https://alchemy-dashboard.containers.cloud.ibm.com/carrier) - US-South will be a reasonable carrier to check as it's one of our busier regions.

Enter the expression corresponding to the alert in the box and click `Execute`:

  - For `ArmadaClusterErrorTemporaryConnectionProblemWorker` use `sum(increase(cluster_worker_action_time{operation!="beginWorkerRebooting",reason_code="ErrorTemporaryConnectionProblem"}[30m]))`

    For US South you can use this [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.range_input=30m&g0.expr=sum(increase(cluster_worker_action_time%7Boperation!%3D%22beginWorkerRebooting%22%2Creason_code%3D%22ErrorTemporaryConnectionProblem%22%7D%5B30m%5D))&g0.tab=1)

  - For `ArmadaClusterErrorTemporaryConnectionProblemSubnet` use `sum(increase(cluster_subnet_action_time{reason_code="ErrorTemporaryConnectionProblem"}[30m]))`

    For US South you can use this [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal12/carrier2/prometheus/graph?g0.range_input=30m&g0.expr=sum(increase(cluster_subnet_action_time%7Breason_code%3D%22ErrorTemporaryConnectionProblem%22%7D%5B30m%5D))&g0.tab=1)

If the value from this expression is less than 3 the alert will stop firing and we can consider the CIE resolved.

## Escalation Policy

The escalation path for this runbook is entirely through IBM Cloud infrastructure, it will only fire when IBM Cloud infrastructure are experiencing consistent issues in their API processing path. There should be enough information in the runbook to avoid calling out the troutbridge squad.

Under extreme circumstances if further information is required that only the troutbridge squad can provide, escalate the page to them and bring them up to speed on the status of the CIE and any updates from IBM Cloud infrastructure.
