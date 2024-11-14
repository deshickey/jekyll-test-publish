---
layout: default
title: armada-orchestrator - Callback errors
type: Alert
runbook-name: "armada-orchestrator - Callback errors"
description: armada-orchestrator - Callback errors
service: armada-orchestrator
link: /cluster/cluster-squad-orchestrator-callback-errors.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

  This alert will fire when errors repeatedly occur within an armada-orchestrator callback

## Example Alert

  Example PD title:

  - `#60048810 staging.containers-kubernetes.stage-dal10-carrier103.DeleteClientID_callback_action_time_errors.us-south`

  Example Body:

  ```text
  - alert = ClusterSquadOrchestratorCallbackActionTimeErrors
  - alert_key = cluster_squad/orchestrator_callback_action_time_errors/DeleteClientID/ErrorUnclassified
  - alert_situation = DeleteClientID_callback_action_time_errors
  - carrier_name = stage-dal10-carrier103
  - carrier_type = hub-tugboat-etcd
  - crn_cname = staging
  - crn_ctype = public
  - crn_region = us-south
  - crn_servicename = containers-kubernetes
  - crn_version = v1
  - operation = DeleteClientID
  - reason_code = ErrorUnclassified
  - region = us-south
  - service = armada-orchestrator
  - service_name = armada-orchestrator
  - severity = warning
  - tip_customer_impacting = false
  ```

## Actions to Take

1. First check the alert to see which `operation` and `reason code` is causing the issue.
1. Check the logs in **LogDNA** for **each** region the alert is firing in

    1. Select the correct LogDNA instance for the region specified in the alert  
    Logs can be accessed through [the dashboard](https://alchemy-dashboard.containers.cloud.ibm.com) 
    1. In the left hand pane under `CLUSTER-SQUAD` there should be a view called `default view`
    1. Enter `callbackName:<operation> reasonCode:<reason_code>` to the search bar in LogDNA
1. Check the error message in the log, and see if it matches any of the scenarios below.

## ErrorUnclassified in DeleteClientID
### 403 BXNIM0515E: You are not authorized to manage this Client ID.

In this situation the IAM API key which is in use for this resource group (in the SRE account) does not have authority to delete the client ID.
This may mean that a user in the SRE account has regenerated the IAM API key without logging in as a Tugboat Functional ID first.

In this scenario SRE can:
1. log in to the affected environment
1. run `ibmcloud target -c <account>` with the `MULTISHIFT_SRE_ACCOUNT_ID` from the `armada-info-configmap` for this environment (which can be found in `armada-info.yaml` in `armada-secure`)
1. run `ibmcloud target -g <resource_group>` with the `MULTISHIFT_SRE_RESOURCE_GROUP_ID` from the `armada-info-configmap` for this environment (which can be found in `armada-info.yaml` in `armada-secure`)
1. run `ibmcloud ks api-key info --cluster <controllerid>` with a controller ID from one of the error logs to see which API key is currently in use for this resource group

If the API key is **not** a tugboatmX functional ID user, then we need an **owner** of the tugboatmX functional ID user (likely Ralph or Troy) to:
1. log in to the affected environment as the tugboatmX functional ID user
1. run `ibmcloud target -c <account>` as above
1. run `ibmcloud target -g <resource_group>` as above
1. run `ibmcloud ks api-key info --cluster <controllerid>` with a controller ID from one of the error logs to see which API
1. reset the IAM API key while logged in as tugboatmX using `ibmcloud ks api-key reset`.

Once  the reset is completed:
1. The IDs that were created using the incorrect api-key will then need to be corrected manually by IAM. 
  - Raise an issue in the [Troutbridge repo](https://github.ibm.com/alchemy-containers/troutbridge/issues/new/choose) using the `Cleanup Client IDs` template, ensuring that you complete the `Environments affected` field. 
  - The Troutbridge team can then follow up in this and complete the steps in normal working hours.

## Escalation Policy

For any other issues, or if the error message does not make it clear how to resolve, or if it is not listed in the above messages, then escalate to [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98)
