---
layout: default
title: cluster-squad - Red Alert
type: Alert
runbook-name: "cluster-squad - Red Alert"
description: Armada cluster - Errors that trigger red alerts from armada-cluster and armada-billing
service: armada-cluster
link: /cluster/cluster-squad-red-alert-provider-errors.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

These alerts are triggered when armada-cluster and armada-billing encounter situations
that need attention on first observation.
They typically represent an inconsistency in our metadata that may prevent
customers from performing certain operations.
This runbook describes the reason codes that trigger the generic ClusterSquadRedAlert alert.
Other reason codes can trigger more specific alerts that are covered by separate runbooks.

## Example Alert

```
Labels:
 - alertname = ClusterSquadRedAlert
 - alert_key = armada-cluster/red_alert/ErrorUnreconciledMetering/softlayer//free/
 - alert_situation = armada-cluster_red_alert_ErrorUnreconciledMetering_softlayer
 - carrier_name = prod-wdc06-carrier1
 - carrier_type = hub
 - crn_cname = bluemix
 - crn_ctype = public
 - crn_region = us-east
 - crn_servicename = containers-kubernetes
 - crn_version = v1
 - flavor = free
 - operation = prepareWorkerProvisioning
 - provider = softlayer
 - reason_code = ErrorUnreconciledMetering
 - service = armada-cluster
 - service_name = armada-cluster
 - severity = critical
 - tip_customer_impacting = false
Annotations:
 - description = Received an error with reason code classified as 'red alert'
 - runbook = https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster/cluster-squad-red-alert-provider-errors.html
 - summary = Received an error with reason code classified as 'red alert'
Source: https://alchemy-dashboard.containers.cloud.ibm.com/prod-wdc06/carrier1/prometheus/graph?g0.expr=armada_cluster%3Ared_alert+%3E+0&g0.tab=1
```

## Action to take

The reason code indicated by the alert determines diagnosis and resolution steps

### ErrorUnauthorised

This alert generally means that there is a problem with the IBM Cloud Infrastructure credentials used to test flavors and to order patrol workers.

1. Confirm that the alert is labelled `operation = probeFlavor` and establish whether the alert is firing in a region that is used for patrol clusters:

  - `eu-central` / `eu-de`
  - `uk-south` / `eu-gb`
  - `us-south`
  
  If the alert fires in another region (one that does not support patrol clusters) or is not for `probeFlavor` then do not raise a pCIE but jump to Step 3 for resolution.

2. If the alert is firing in a region listed in Step 1, raise a CIE for the affected regions with the following details:

  ~~~
  Title: Customers might be unable to request or manage IBM Cloud Kubernetes Service free clusters

  SERVICES/COMPONENTS AFFECTED:
  - IBM Kubernetes Service
  IMPACT:
  - Create new IBM Cloud Kubernetes Service free clusters
  - Reboot IBM Cloud Kubernetes Service free cluster workers
  - Reload IBM Cloud Kubernetes Service free cluster workers
  - Delete IBM Cloud Kubernetes Service free cluster workers
  STATUS:
  - 202x-xx-xx xx:xx UTC - INVESTIGATING - The operations team is aware and currently investigating.
  ~~~

3. Complete these resolution steps following normal SRE practices and approval processes for configuring production environments and managing secrets:

    1. The credentials used for free clusters in IBM Cloud Infrastructure can be found in armada-secure.
        - Navigate to `https://github.ibm.com/alchemy-containers/armada-secure/tree/master/secure/armada`
        - Select directory that corresponds to region
        - View `softlayer.yaml`
        - Identify the `SOFTLAYER_USERNAME`, and if necssary `SOFTLAYER_API_KEY`
    2. Review the status of the identified user in the IBM Cloud Infrastructure control panel
        - Unlock the user if it has been locked 
        - Re-add the user if it has been removed
        - Re-create the API key if it has been removed
    3. If either the username of API key gets changed, replace the values in armada-secure
        - Follow instructions in armada-secure to [update fields](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/README.md)
        - Work with the razee team to get the changes merged and promoted to production

4. To confirm resolution, run the following query in prometheus on a hub carrier in the affected region:

    - `count(cluster_worker_action_time{operation="probeFlavor",reason_code="ErrorUnauthorised"}) by (reason_code)`

    If the situation is resolved, this metric should trend towards 0. Escalate to the troutbridge squad the alert does not resolve with 1 hour.


### ErrorUnreconciledBootstrapMetadata

This reason code is routed to the bootstrap squad and is covered in a separate [run book](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-bootstrap-metadata-alert.html). 


### ErrorUnreconciledMachineConfig

This reason code is covered in a separate [run book](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster/cluster-squad-error-unreconciled-machine-config-softlayer.html). 


### ErrorUnreconciledMetering and ErrorUnreconciledPlanID

Example PD titles:

  - `#12345678: bluemix.containers-kubernetes.prod-lon04-carrier1.armada-cluster_red_alert_ErrorUnreconciledMetering_softlayer.uk-south`
  - `#14161173: bluemix.containers-kubernetes.prod-lon04-carrier1.armada-cluster_red_alert_ErrorUnreconciledPlanID_softlayer.uk-south`

These alerts indicate that either `armada-cluster` or `armada-billing` has been unable
to determine a critical aspect of the metering configuration for a worker, cluster,
dedicated host or other metered resource due to a fundemental problem in the data model.

Typically the alert indicates an inconsistency or corruption in the significant fields of
one or more of the following model objects:

 - model.Provider
 - model.Metro
 - model.Zone
 - model.Flavor
 - model.DedicatedHostFlavor
 - model.Cluster
 - model.WorkerPool
 - model.Worker
 - multishift.Controller
 - multishift.QueueNode
 - multishift.QueneNodeAssigment
 - dedicated.HostPool
 - dedicated.Host
 - model.CommittedCompute
 - model.CommittedContract
 
If the inconsistency or corruption is systemic, impact can affect multiple customers.
Affected customers might be impacted by newly requested resources failing to provision,
or might be continue to be charged for resources that have been removed from service.

1. Page the [Troutbridge squad](https://ibm.pagerduty.com/escalation_policies#PQORC98) for analysis and resolution.

2. Establish the following information from the alert details:

   - service
   - operation
   - provider (if applicable)
   - zone (if applicable)
   - flavor (if applicable)

3. Use the operation to determine the affected resource type and impact, for a pCIE:

--------- | ----------------- | --------------------
Operation |  Resource Type    | Impact for pCIE
--------- | ----------------- | --------------------
prepareWorkerProvisioning, probeFlavor | workers | Provisioning new workers using flavor <flavor> for new and existing clusters
prepareDedicatedHostCreation | dedicated hosts | Provisioning new dedicated hosts using dedicated host flavor <flavor>
prepareClusterRegistration | clusters | Creating new clusters and Satellite locations 
prepareQueueNodeAssignment | host assignments | Assigning hosts to new and existing Satellite locations and clusters

4. Raise a pCIE for the affected regions with the following details:

  ~~~
  Title: Customers might be unable to create <resource type from step 3> in <region>

  SERVICES/COMPONENTS AFFECTED:
  - IBM Kubernetes Service
  - Red Hat OpenShift on IBM Cloud
  IMPACT:
  - <impact from step 3>
  STATUS:
  - 202x-xx-xx xx:xx UTC - INVESTIGATING - The operations team is aware and currently investigating.
  ~~~

5. Confirm the pCIE as a CIE when either of the following is true:
    - there is a customer ticket or other evidence that an external customer has already been impacted, or
    - the troutbridge squad has confirmed that the alert is for a production flavor and that the logs show high risk of customer impact.

The following debug notes are primarily for the troutbridge squad but are included here for reference:

1. Gather the following information from the PD alert:
    - The `operation`, e.g. `probeFlavor` or `prepareWorkerProvisioning`.
    - The affected  `provider`, `zone` and `flavor`.

2. Review LogDNA for further details, such as any affected worker IDs, searching using:
    - `reasonCode:"ErrorUnreconciledMetering" OR reasonCode:"ErrorUnreconciledPlanID"`

3. Gather the following from LogDNA, and if necessary XO queries:
    - The values `Flavor` properties listed below.
    - For individual worker alerts:
        - The worker ID
        - The values of the `Worker` properties listed below.
        - The values of the `WorkerPool` properties listed below.
        - The values of the `Cluster` properties listed below.
    
4. Review gathered information for any missing or clearly invalid information, such as:
    - Bare metal worker requsted with `public` isolation.
    - `BillingConfiguration` does not contain plan that matches the criteria derived from the `Worker`, `WorkerPool` and `Cluster` properties.
    - Missing or bad Satellite host (`QueueNode`) labels.

Potential causes include (but are not limited to):

  - Missing or invalid properties of a `Flavor` such as: 
      - `BillingConfiguration`
      - `NumCores`
      - `ServerType`
      - `StorageConfiguration`
      - `SupportedIsolation`
  - Missing or invalid properties of a `Worker` such as:
      - `DesiredProvider`
      - `DesiredZone`
      - `DesiredFlavor`
      - `DesiredIsolation`
  - Invalid properties of a `WorkerPool` such as:
      - `OpenShiftLicenseSource`
      - `OperatingSystem`
  - Invalid properties of a `Cluster` such as:
      - `AccountID`
      - `ResourceGroupID`
      - `MultishiftAccountID`
      - `MultishiftControllerID`
      - `MultishiftServiceID`
      - `MultishiftType`
      - `OpenShiftLicenseType`
  - Invalid properties of a `QueueNode` such as:
      - `Labels`


### ErrorUnreconciledOSImage

This reason code is routed to the bootstrap squad and is covered in a separate [run book](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-bootstrap-unreconciled-osimage-alert.html). 


### ErrorUnreconciledServiceToken

This error indicates there is an issue with how the platform authenticates with IBM Cloud Classic Infrastructure.

This will (most likely) be effecting production and pre-production regions.

1\. Raise a pCIE for the affected regions with the following details:

```text
  Title: Customers might experience a delay in provisioning and reloading workers using IBM Cloud Classic Infrastructure.

  SERVICES/COMPONENTS AFFECTED:
  - IBM Kubernetes Service
  - Red Hat OpenShift on IBM Cloud
  IMPACT:
  - IBM Kubernetes Service, clusters using IBM Cloud Classic Infrastructure
  - Red Hat OpenShift on IBM Cloud, clusters using IBM Cloud Classic Infrastructure
  - Users might see delays in provisioning workers for new or existing clusters
  - Users might see delays in reloading existing workers of clusters
  STATUS:
  - 202x-xx-xx xx:xx UTC - INVESTIGATING - The operations team is aware and currently investigating.
```

2\. Page out the troutbridge squad as documented in [Escalation Policy](#escalation-policy).

3\. troutbridge squad will investigate if the service token has previously been rotated, and will determine if we need to engage with the SoftLayer support team.

### ErrorLedgerInsufficientPrivilege

This error indicates there is an issue with read and/or write access to the postgres database that contains the ledger in the region.

1\. This alert is expected during Postgres database migrations and should resolve within one hour of the migration being completed, so the first thing to do is to reach out to the Ballast squad in #armada-ballast and check if they're working on the database or are aware of any issues.

2\. If the Ballast team are not currently migrating the database and aren't aware of any issues raise a CIE for the region with the following details:
```text
  Title: Customers might experience a delay in provisioning and deleting workers and clusters or might be unable to provision or delete workers and clusters using IBM Cloud Kubernetes Service and RedHat OpenShift on IBM Cloud.

  SERVICES/COMPONENTS AFFECTED:
  - IBM Kubernetes Service
  - Red Hat OpenShift on IBM Cloud
  IMPACT:
  - IBM Kubernetes Service, clusters using IBM Cloud Classic Infrastructure and VPC Infrastructure
  - Red Hat OpenShift on IBM Cloud, clusters using IBM Cloud Classic Infrastructure and VPC Infrastructure
  - Users might see delays or be unable to provision workers for new or existing clusters
  - Users might see delays or be unable to delete workers and clusters
  STATUS:
  - 202x-xx-xx xx:xx UTC - INVESTIGATING - The operations team is aware and currently investigating.
```

3\. Page out the ballast squad for further assistance in debugging the instance

## Escalation Policy

PagerDuty:
  Escalate the issue via the [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) PD escalation policy

Slack Channel:
  You can contact the dev squad in the [#armada-cluster](https://ibm-argonauts.slack.com/archives/C54FV49RU) channel

GHE Issues Queue:
  You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
