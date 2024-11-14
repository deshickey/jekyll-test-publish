---
layout: default
title: cluster-squad - ErrorNoPlanDeploymentForSatelliteLocation
type: Alert
runbook-name: "cluster-squad - ErrorNoPlanDeploymentForSatelliteLocation"
description: Armada cluster - ErrorNoPlanDeploymentForSatelliteLocation
service: armada-cluster
link: /cluster/cluster-squad-error-registering-satellite-resources.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

The ErrorNoPlanDeploymentForSatelliteLocation alert fires when resources deployed to a Satellite Location cannot be registered with the Resource Controller. The underlying cause might be that the Location state is not accurately reflected in GhoST or there are permissions issues between the Resource Controller and the Global Catalog.

Likely symptoms include:

- Cluster registration stalls in `registering` state.
- Master deployment stalls, pending Cluster registration.
- Worker creation stalls in `provision_pending` state.


## Example Alert

PD title:

- `bluemix.containers-kubernetes.prod-lon04-carrier1.armada-billing_error_no_plan_deployment_for_satellite_location_cluster.eu-gb`
- `bluemix.containers-kubernetes.prod-lon02-carrier2.armada-cluster_error_no_plan_deployment_for_satellite_location_worker.eu-gb`

## Actions to Take

1. Check the logs in **LogDNA** for the chosen region

    1. Select the correct LogDNA instance for the region specified in the alert  
    Logs can be accessed through [the dashboard](https://alchemy-dashboard.containers.cloud.ibm.com) 
    1. In the left hand pane under `CLUSTER-SQUAD` open `default-view`
    1. Use that view to search for lines containing the value for the `ErrorNoPlanDeploymentForSatelliteLocation` field

1. Look at responses returned by `armada-billing` (or `armada-cluster` depending on the PD service field), you should see the Resource Controller returning an error during registration, of the form `No RC deployments for plan: containers-kubernetes-satellite-roks-cluster with target satloc_dal_cd3f3oh10i6un1lvusug`.

    ```json
    {
      "level": "error",
      "ts": "2022-10-13T20:17:45.890Z",
      "caller": "engine/cluster_register.go:140",
      "msg": "Error registering resource",
      "visitor": "armada-billing-f887ffbb7-vkq5m:3687",
      "region": "us-south",
      "clusterID": "cd468e110kolsmljpa6g",
      "action": "beginClusterRegistration",
      "req-id": "d08dbf94-2dcd-43c3-9456-8d4e1fa23fcf",
      "registrationStatus": "",
      "error": {
        "Fault": {
          "msg": "The satellite location satloc_dal_cd3f3oh10i6un1lvusug is not ready for resource registration.",
          "code": "ErrorNoPlanDeploymentForSatelliteLocation",
          "wrapped": [
            "No RC deployments for plan: containers-kubernetes-satellite-roks-cluster with target satloc_dal_cd3f3oh10i6un1lvusug"
          ],
          "properties": {
            "AccountID": "048412671ddeb8ad98e6a614bc99fc8f",
            "BSSTransactionID": "d08dbf94-2dcd-43c3-9456-8d4e1fa23fcf",
            "Operation": "RegisterResource",
            "PlanID": "containers.kubernetes.satellite.roks.cluster",
            "RegionID": "satloc_dal_cd3f3oh10i6un1lvusug",
            "StatusCode": "400"
          },
          "user_error": {
            "code": "P0104",
            "description": "The satellite location {{.Location}} is not ready for resource registration.",
            "type": "General",
            "rc": 503
          },
          "vars": {
            "Location": "satloc_dal_cd3f3oh10i6un1lvusug",
            "Message": "No RC deployments for plan: containers-kubernetes-satellite-roks-cluster with target satloc_dal_cd3f3oh10i6un1lvusug",
            "PlanID": "containers-kubernetes-satellite-roks-cluster",
            "Status": 400
          }
        }
      }
    }
    ```

1. From the output JSON, construct the following xo queries to verify the location exists within GhoST via [armada-xo](https://ibm-argonauts.slack.com/archives/G53AJ95TP):

    ```text
      @xo queryGhostControllers <accountID> controller=<controllerID> region=<region>
    ```

    The controllerID is derived from the target, e.g. if the target is `satloc_dal_cd3f3oh10i6un1lvusug`, the controllerID is `cd3f3oh10i6un1lvusug`

1. If xo does not find the location, page out the GhoST team (see [GhoST Escalation](#ghost-escalation))
1. If the location is found, we need the assistance of the Resource Controller team to further analyse the issue.
    1. Gather the `req-id` (`BSSTransactionID`) from the LogDNA output, i.e. `d08dbf94-2dcd-43c3-9456-8d4e1fa23fcf`
    1. Page out the Resource Controller (BSS) team (see [BSS Escalation](#bss-escalation))

## Escalation Policy

### GhoST Escalation

PagerDuty:
Escalate the issue via the [GhoST](https://ibm.pagerduty.com/escalation_policies#PIIBNSN) PD escalation policy

Slack Channel:
Engage the GhoST squad [#global-search-tagging channel](https://ibm-cloudplatform.slack.com/archives/C11F8KA1Z)

### BSS Escalation

PagerDuty:
Escalate the issue via the [bss](https://ibm.pagerduty.com/escalation_policies#PGPNMQI) PD escalation policy

Slack Channel:
Engage the BSS squad [#bss channel](https://ibm-cloudplatform.slack.com/archives/C081NLV9U/p1588695106425000)