---
layout: default
description: Requesting quota increase for the IKS on VPC Gen 2 Service Account
title: cluster-squad-resize-quota-for-service-account - Requesting quota increase for the IKS on VPC Gen 2 Service Account
service: armada-cluster
runbook-name: "cluster-squad-resize-quota-for-service-account - Requesting quota increase for the IKS on VPC Gen 2 Service Account"
tags:  armada, quota, cluster, vpc, g2, cores, memory, instance storage, volumes
link: /cluster/cluster-squad-resize-quota-for-service-account.html
type: Alert
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert is fired when we hit a specified threshold for `cores`, `memory`, `instance storage` or `volumes` for the VPC Service Account.

The fix is increasing the quota for this account.


## Example Alert(s)

- `#3533XXX: bluemix.containers-kubernetes.armada-cluster_error_temporary_connection_worker_service_cores_quota_usage_gc`
- `#3533XXX: bluemix.containers-kubernetes.armada-cluster_error_temporary_connection_worker_service_memory_quota_usage_g2`
- `#3533XXX: bluemix.containers-kubernetes.armada-cluster_error_temporary_connection_worker_service_instance_storage_quota_usage_g2`


## Actions to take

Gather the severity from the PagerDuty alert description.

If the alert is triggered against the staging environment, go to the [staging alert](#staging-alert) section.

If it affects production, then depending on the severity of the issue, read the corresponding sections ([warning](#warning-alert) or [critical](#critical-alert)).


---
## Staging Alert

For staging, we will not need to increase the quota, but please do the following to resolve the alert:

1. Post in the [#armada-vpc](https://ibm-argonauts.slack.com/archives/CEGC4CC3W) channel, asking users to clear out any VPC Gen 2 clusters that are no longer required.

    ```
    @leads we've just received an alert for high usage of <cores/memory/instance storage/volumes> in the VPC Service Account in stage. The stage environment we’re using has limited capacity. Please clear out any clusters you do not need. Also - Only provision the larger flavors for long term testing only if necessary.
    ```

1. The development squads will reach out to you and remove unnecessary clusters clearing the alert. If necessary, this chat may be moved into the leads slack channel for some more traction.

    **NOTE:** The alert will only auto-resolve once the some of the clusters have been cleared out.

---
## Warning Alert

A warning alert will fire against the troutbridge squad if one of the following conditions are met:

- The total amount of `cores`, `memory`, `instance storage`, `optimised instance storage`, `volumes` or `gpus` being used in the VPC Service Account **exceeds 60%**.

You will then need to do the following: 

1. Raise a new issue in the [Troutbridge repo](https://github.ibm.com/alchemy-containers/troutbridge/issues/new/choose) using the `Interrupt Tracking of Quota Increase` template to track the quota increase.

1. Follow the prometheus link within the alert to see the current percentage of the quota that is being used within the region.
    - If the alert has triggered for `cores`, then modify the prometheus query to `armada_provider_riaas:service_account_volumes_quota_usage:g2` to check whether the volumes alert is also close to triggering (at 60% usage) in this region.
    - If the alert has triggered for `volumes`, then modify the prometheus query to `armada_provider_riaas:service_account_cores_quota_usage:g2` to check whether the cores alert is also close to triggering (at 60% usage) in this region.
    In these cases, if the second resource type is also close to alerting, please request an increase for *both* `cores` and `volumes` for the region simultaneuously.
        
1. Raise an SRE team [ticket](https://github.ibm.com/alchemy-conductors/team/issues/). Refer to [Ticket Template](#ticket-template) to fill out this issue. Add link to the ticket and check item in the tracking issue from step 1 when complete.

1. Message SRE in the [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK) slack channel to let them know about the issue. SRE will then request approval for the issue and when that is granted, they will raise a `Severity 2` ticket against the VPC team. Add link to the slack message and check item in the tracking issue from step 1 when complete.

1. Request approval from Lewis Evans. If Lewis is not available, revert to the standard SRE approval process from one of the SRE Leads.

1. Once the Conductors issue has been approved, and a ticket raised with VPC, then troutbridge squad can [suppress the alert](#suppress-an-alert). Once the alert suppression has been set up, the firing alert can be resolved.

1. Chase the SRE team to monitor the ticket to resolution and report back to the troutbridge squad when the VPC ticket has been completed.

1. Verify that the quota has been increased as expected, by viewing the [VPC Ops Dashboard](https://opsdashboard.w3.cloud.ibm.com/ops/accounts/bab556e1c47446ef8da61e399343a3e7).

1. Once the SRE ticket has been completed, troutbridge squad must set the new quota values in [armada-provider-riaas](https://github.ibm.com/alchemy-containers/armada-provider-riaas/blob/master/provider/servicemetrics/service_quota_limits.go) for the respective region. Add PR link and check item in the tracking issue from step 1 when complete.

1. troutbridge squad verify the alert has resolved. Check final item and close the the tracking issue from step 1 once this is complete.

---
## Critical Alert

A critical alert will fire against the SRE squad if either the `cores`, `memory`, `instance storage`, `gpus` or `volumes` within the VPC Service Account **exceed 80%**. You will need to do the following:

1. Open the alert and visit the `Source` link from the alert, this will take you to the prometheus metric for this alert

1. Adjust the expression by removing the `> 80` suffix for the alert
    - Switch from the prometheus `Table` to the `Graph` view and extend the time to 2d

1. If the graph is showing significant spikes similar to [this](https://media.github.ibm.com/user/14254/files/715acc00-a10f-11ec-8e67-00e0765d7fdb)
    - please raise a new issue on [Troutbridge](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
    - Name the issue `Service account <core/memory/volume/gpu> usage spiking in <region>` deleting as appropriate
    - Provide a link to the alert
    - Acknowledge the alert and stop.

1. If the graph is not showing a spike, continue through the runbook

1. SRE squad acknowledge the alert

1. A Increase Service Account Quota ticket needs to be created or the existing one escalated as appropriate.  
Therefore, search for a recent [Increase Service Account Quota ticket](https://github.ibm.com/alchemy-conductors/team/issues?q=is%3Aissue+is%3Aopen+%22Increase+Service+Account+Quota%22) in the team board.

   - If found, chase up this ticket, by re-requesting approval if approval is still outstanding, or requesting an update on the Service Now ticket, if it has already been raised.
   
   - **If there is not an existing ticket**, raise a new one using the [Ticket Template](#ticket-template).

1.  Raise a new issue in the [Troutbridge repo](https://github.ibm.com/alchemy-containers/troutbridge/issues/new/choose) using the `Interrupt Tracking of Quota Increase` template so that the troutbridge squad can track the quota increase, adding a link to the Conductors issue that has been raised in the description. The alert can then be snoozed while waiting for approval on the ticket.

    **NOTE:** The alert will only auto-resolve once the quota has been increased by VPC, and in armada-provider-riaas, and this has been promoted to production.

---

## Suppress an alert

**You should only go through this section if you are redirected from `Warning Alert`.**

1. Open the low level alert that is firing
1. Navigate to the impacted technical service
1. Open the `Settings` tab for the service
1. Open the `Basic Service Event Rules` in the `Event Management` section
1. Create a `New Event Rule`
1. Fill in the event rule template sections
    1. `When events match these conditions`
        1. The field name is `alertname`, take the value from the alert
        1. The field name is `provider`, take the value from the alert
        1. The field name is `region`, take the value from the alert
    1. `Do these things`
        1. Suppress the alert
    1. `At these times`
        1. Select `At a scheduled time`
        1. Set the end date for 1 week from now
    1. Save the rule


## Ticket Template

**You should only go through this section if you are redirected from either `Warning Alert` or `Critical Alert`.**

1. The ticket template will be in relation to one or more resource types (`cores`, `memory`, `instance storage`, `volumes`). Regardless, the ticket will always begin with the following:

    ### Title: Increase VPC Service Account Quota in <region>

    ```
    
     We need to request quota increases in our production account for VPC Gen2.

     Justification: Service account consumption in this region is hitting the <60%/80% (WARNING/CRITICAL, DELETE ACCORDINGLY)> threshold of available <CORES/MEMORY/INSTANCE STORAGE/VOLUMES> quota.
    
     Please follow the instructions below.
    
    1. Add the `APPROVAL_NEEDED` label to this issue, to request approval for this quota increase.
    
    2. Once the approval has been given, log in to https://cloud.ibm.com
    
    3. Switch to the account
    `IKS.Prod.VPC.Service - bab556e1c47446ef8da61e399343a3e7`
    
    4. Navigate to a https://cloud.ibm.com/unifiedsupport/cases/add and select the following…
    
        - Select Case Type: Virtual Server
        - Business Impact Severity 2
        - Subject - IKS Production account gen2 quota increase
    
     Please paste and complete the following information into the description section:
    
        Additional quota is needed to support demand for Kubernetes and OpenShift service in VPC Gen2.
        
        Account ID: bab556e1c47446ef8da61e399343a3e7
        Environment:  Production
        Generation:  Gen 2
        Regions: <REGION>
        Quota of the Resources to be changed:
        
        <REPLACE WITH THE CORRESPONDING RESOURCE(S) BELOW>
        
     Once raised - please inform us of the ticket number in this issue.
    
    5. Request approval @lewis.evans or approvers listed on the [SRE Approvals list](https://ibm.ent.box.com/notes/772700662990)
    ```

    From the alert name you should be able to determine what the resource is (`cores`, `memory`, `instance storage`, `optimised instance storage`, `volumes` or `gpus`).

1. Complete the ticket with the corresponding information from below. The current quota limits can be found in [armada-provider-riaas](https://github.ibm.com/alchemy-containers/armada-provider-riaas/blob/master/provider/servicemetrics/service_quota_limits.go) for the respective region. 

    - If the alert triggered relates to `cores`, add the following into the ticket description (after the inital text):

    ```
    Please increase the max vCPU to <CALCULATE 100% HIGHER THAN THE CURRENT QUOTA LIMIT> for the region.
    ```

    - If the alert triggered relates to `memory`, add the following into the ticket description (after the inital text):

    ```
    Please increase the max memory to <CALCULATE 100% HIGHER THAN THE CURRENT QUOTA LIMIT> for the region.
    ```

    - If the alert triggered relates to `instance storage`, add the following into the ticket description (after the inital text):

    ```
    Please increase the max instance storage to <CALCULATE 100% HIGHER THAN THE CURRENT QUOTA LIMIT> for the region.
    ```

    - If the alert triggered relates to `optimised instance storage`, add the following into the ticket description (after the inital text):

    ```
    Please increase the max (ox2) optimised instance storage to <CALCULATE 100% HIGHER THAN THE CURRENT QUOTA LIMIT> for the region.
    ```


    - If the alert triggered relates to `gpus`, add the following into the ticket description (after the inital text):

    ```
    Please increase the max GPU to <CALCULATE 100% HIGHER THAN THE CURRENT QUOTA LIMIT> for the region.
    ```

    - If the alert triggered relates to `volume`, add the following into the ticket description (after the inital text):

    ```
    Please increase the max volumes to <CALCULATE 100% HIGHER THAN THE CURRENT LIMIT> for the region (divided equally between the zones).

    Additional information for volumes request:
    1) What is the use case for the additional volumes request?
    Answer: Additional boot volumes required to provision Kubernetes and OpenShift service worker VSIs
    2) How many extra Block volumes are needed by type, size, IOPS, and location?
    Answer: Please increase the regional quota for block volumes as described above. The number will be divided equally between the zones in the region.
    All the volumes will be used as the boot volume at 100 GB each with the default IOPS set for boot volume.
    3) Provide an estimate of when you expect or plan to provision all of the requested volume increase.
    Answer: In the next 3 months
    4) Provide a 90-day forecast of expected average capacity usage of these volumes.
    Answer: 100%

    ```

1. Resume steps in the previous alert section:
    - troutbridge squad, go to step 4 in [Warning Alert](#warning-alert).
    - SRE squad, go to step 3 in [Critical Alert](#critical-alert).

---
## Escalation Policy

  **DO NOT** reassign the alert, as the troutbridge squad do not have the permissions to raise the ticket in Service Now.

  **Escalation for the troutbridge squad:**
  1. If the VPC team deny the quota increase, we'll need to escalate this request with the VPC OM team. Inform Lewis Evans & Chris Rosen of the current situation - they will be able to escalate to the VPC OM Team.

  **Escalation for the SRE squad:**
  1. If the VPC team close the ticket without answer, please re-open. - if the ticket needs escalating SRE can escalate to the troutbridge squad.

  1. If the VPC team deny the quota increase, escalate to the troutbridge squad informing them of this decision.
