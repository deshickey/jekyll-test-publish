---
layout: default
description: Satellite Network - Calico Hostendpoint Management On Satellite Cruiser Clusters Troubleshooting
title: Satellite Network - Calico Hostendpoint Management On Satellite Cruiser Clusters Troubleshooting
service: armada-network
runbook-name: "Satellite Network - Calico Hostendpoint Management On Satellite Cruiser Clusters Troubleshooting"
tags: alchemy, armada, network, satellite, cruiser, deployment, hostendpoint, 410
link: /satellite/armada-satellite-cruiser-hostendpoint_management.md
type: Troubleshooting
grand_parent: Armada Runbooks
parent: Satellite
---

Troubleshooting
{: .label .label-red}

## Overview

The main focus of the Calico Hostendpoint Management On Satellite Cruiser Clusters feature is to provide the option of creating global network policies using host interfaces to our users. The necessary calico hostendpoint resources are deployed on the cruiser cluster in cluster creation time for each workers's every real network interface. It is done automatically and managed through the cluster updater, the user doesn't have any control over these hostendpoint instances.

---

## Example alerts which would have brought you here

This is a general troubleshooting runbook and is not tied to any specific alerts

---

## Investigation and Action

### No hostendpoints are deployed on the cruiser cluster

Before any further steps the [armada-network-private-service-endpoint-operations](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations) Jenkins job should be run with the following parameters to validate that the HEPs are truly missing:
  - Region: customer's cluster region
  - Operation: `validate-calico-resources-for-satellite`
  - Cluster ID: customer's cluster ID
  - Is location: `false`

If they were missing then the following possibilities should be considered:

* This feature is only available for 4.12_x_xxxx_openshift or above versions and on CoreOS Enabled (Hypershift) locations's clusters.
    * Check the cruiser's master's and the workers' BOM versions.
        * Master BOM version check:
            * Get the `ActualMasterIDs` from the `@xo cluster <Sat-Cruiser-Cluster-ID>` command
            * Check the `AnsibleBomVersion` filed using the `@xo master <Sat-Cruiser-Cluster-ID>/<ActualMasterIDs-field>`
        * Workers' BOM version check:
            * Get the workers' BOM version from the `@xo clusterWorkers <Sat-Cruiser-Cluster-ID> fields=ActualAnsibleBomVersion`
    * Check if the cruiser's location is Hypershift (CoreOS flag was set to enabled at the location creation).s
        * Get the related satellite location's ID from the `MultishiftControllerID` field using `@xo cluster <Sat-Cruiser-Cluster-ID>` command.
        * Get the workers' Master IDs from the `@xo clusterWorkers <Sat-Location-Cluster-ID> fields=ActualAnsibleBomVersion`. If there is at least one worker with an openshift version, then it is a hypershift location.
* The cruiser cluster's worker aren't in a healthy state yet. (To check use the following command in armada-xo `@xo clusterWorkers <Sat-Cruiser-Cluster-ID>` and check the `Health State` column)
    * Wait for the worker nodes to become healthy.
* If every previous steps are done and still no hostendpoints are deployed perform the following steps:
    1. Raise a train request either in the `#cfs-prod-trains` Slack channel by copying in the following message (filling in the `###ENVIRONMENT###` and `###CLUSTERIDS###` entries)
        ```
        Squad: network
        Title: Fix Calico resources for Satellite cluster
        Environment: ###ENVIRONMENT###
        Details: |
        Fix Calico resources for Satellite cluster
        with ###CLUSTERIDS### by running this jenkins job:
        https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/
        Risk: low
        Ops: true
        PlannedStartTime: now
        PlannedEndTime: now + 1h
        BackoutPlan: re-run the jenkins job to fix issue
        ```
    2. Wait for notification via the `@Fat-Controller` slack app that your train has been approved, then use a Slack DM with the `@Fat-Controller` to start the train
    3. Go to the [armada-network-private-service-endpoint-operations](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/) Jenkins job and set the parameters mentioned [here](#fix-calico-resources-jenkins-job-parameters).
    4. Run the job and verify that it passes
    5. Use the `@Fat-Controller` app to complete the train.

### The policies created by the user doesn't work with the given interface hostendpoints

If the customer reports that a properly created global network policy doesn't work as expected with the given hostendpoints there is a possibility that the hostendpoint is invalid. To validate this use the [armada-network-private-service-endpoint-operations](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations) Jenkins job with these parameters:
  - Region: customer's cluster region
  - Operation: `validate-calico-resources-for-satellite`
  - Cluster ID: customer's cluster ID
  - Is location: `false`

Outcomes:
* Valid: the hostendpoints are created properly, the issue is not on our side. The user should double-check the created global network policies according to the [calico documentation](https://docs.tigera.io/calico/3.25/reference/resources/globalnetworkpolicy).
* Invalid: to fix the invalid/missing hostendpoints go to the [armada-network-private-service-endpoint-operations](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/) Jenkins job and set the parameters mentioned [here](#fix-calico-resources-jenkins-job-parameters)

---
## Fix Calico resources Jenkins Job parameters
  - Region: customer's cluster region
  - Operation: `fix-calico-resources-for-satellite`
  - Cluster ID: customer's cluster ID
  - Is location: `false`
  - Operation Type: `write`
  - Ops Train Ticket ID: the train ID

## Escalation Policy

Once the initial investigation is performed

* Notify `satellite-network` squad `@satmesh-squad` on the slack channel with the corresponding GHE issue - [#armada-network](https://ibm-argonauts.slack.com/archives/armada-network).

## Reference

* Slack channels: [#armada-network](https://ibm-containers.slack.com/archives/armada-network)
* Calico Hostendpoint Management On Satellite Cruiser Clusters feature concept Doc: [Concept Doc](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/satellite-networking-improvements.md)
* Jenkins job: https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations