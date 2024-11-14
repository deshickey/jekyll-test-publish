---
layout: default
title: "Dreadnought - How to scale a worker-pool"
runbook-name: "How to scale a worker-pool"
description: "How to scale a worker-pool.  The primary is to scale out.  The same process can be used to scale in as well."
category: Dreadnought
service: dreadnought
tags: dreadnought, pool resize, worker-pool resize, scale
link: /dreadnought/dn-worker-pool-scale.html
type: Informational
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

## Overview

When work pool workers are hitting high CPU and/or Memory usage on a regular basis it may become required to scale out a worker pool.  This is the process to handle a change in worker-pool size.

## Detailed Information

#### Prerequisite
- Get the Account ID for the account where the cluster exists.
    - If you are logged into the account you can execute `ic account show --output json | jq -r .account_id` to get the Account ID.
    - If logged into any account you can execute `ic account list --output json | jq -r '.[] | select( .Name=="<account name>") | .Guid'` (Replace `<account name>` with the name of the account)
- Get the Cluster Name
    - To list all clusters in the account: `ibmcloud oc cluster ls`
    - The name of the cluster is referenced as `$CLUSTER_NAME` below.
- Get the Worker Pool Name
    - To list the work pools for a cluster: `ibmcloud oc worker-pool ls --cluster $CLUSTER_NAME`.
    - The worker pool name is referenced as `$POOL_NAME` below.
- Get the Node Name
    - Get the IP address of the worker from the `ibmcloud oc worker ls --cluster $CLUSTER_NAME` from the `Primary IP` field as this is the `node name` inside the cluster.
    - The Node Name is referenced as `$NODE_NAME` below.

#### Steps
1. Raise a prod train using the below template in [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN)
    ```
    Squad: dreadnought_sre
    Service: dreadnought_sre
    Title: Manual scale out worker pool <pool name> in cluster <cluster> in account <account name> due to a high CPU utilization issue.
    Environment: <region>
    TestsEnvironment: stage
    Details: Increase the worker pool size by 1.
    Risk: low
    PlannedStartTime: now
    PlannedEndTime: start + 1h
    BackoutPlan: Manual repair by conductor
    Ops: true
    ServiceEnvironment: pre_prod
    ServiceEnvironmentDetail: Dreadnought staging
    PipelineName: manual
    PipelineVersion: 0.1
    ValidationRecord: CHG123
    CustomerImpact: no_impact
    DeploymentImpact: small
    DeploymentMethod: manual
    ```
1. Approve the train in [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN)
    ```
    approve <Train ID> “Required to fix worker issue.”
    ```
1. Direct message `Fat-Controller` the start train.
    ```
    start train <Train ID>
    ```
    - You can check the status in [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN) by running the `describe` command: `describe <Train ID>`
1. Log into the IBM Cloud account: `ibmcloud login -c $ACCOUNT_ID --sso`
1. Check the current worker pool size.
    1. `ibmcloud oc worker-pool get --cluster $CLUSTER_NAME --worker-pool $POOL_NAME`
1. Execute a worker pool resize on the worker pool adding 1 to the current size of the worker pool.
    1. `ibmcloud oc worker-pool resize --cluster $CLUSTER_NAME --size-per-zone $SIZE --worker-pool $POOL_NAME`
1. Validate the new worker is up and ready.  The add can take 10 minutes or more to complete.  If the add of the new worker takes more than 30 minutes you may consider opening a case for the worker add being slow for this worker.
    1. `ibmcloud oc worker ls --cluster $CLUSTER_NAME`
        - Example output when deploying the new worker:
        ```
        ID                                                       Primary IP      Flavor     State      Status               Zone         Version
        kube-cpl8n4ld0g17u5d567s0-testatsstsc-transit-0000331e   192.168.16.12   bx2.8x32   deploying   Starting worker deployment   us-south-1   -
        ```
            - There may be other states and status messages during the deployment stage before the worker goes to `Ready` status.  These could include `pending` and `critical`.  Give the worker some more time to go to `Ready` in these cases as they are normal.
        - Example output when the new worker is ready (and complete):
        ```
        ID                                                       Primary IP      Flavor     State      Status               Zone         Version
        kube-cpl8n4ld0g17u5d567s0-testatsstsc-transit-0000331e   192.168.16.12   bx2.8x32   normal      Ready                        us-south-1   4.14.33_1576_openshift
        ```
1. Direct message `Fat-Controller` the complete train
    ```
    complete train <Train ID>
    comment: just a comment
    ```

## Further Information

[OpenShift: Understanding how to evacuate pods on nodes](https://docs.openshift.com/container-platform/4.14/nodes/nodes/nodes-nodes-working.html#nodes-nodes-working-evacuating_nodes-nodes-working)
