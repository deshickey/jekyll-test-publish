---
layout: default
title: "Dreadnought - How to replace a worker"
runbook-name: "How to replace a worker"
description: "How to replace a worker."
category: Dreadnought
service: dreadnought
tags: dreadnought, worker replace, bad worker, replace worker
link: /dreadnought/dn-worker-replace.html
type: Informational
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

## Overview

Some issues can only be fixed with a worker replace.  This runbook describes the process to replace a worker.  This is a manual operation.

## Detailed Information

#### Prerequisite
- Get the Account ID for the account where the cluster exists.
    - If you are logged into the account you can execute `ic account show --output json | jq -r .account_id` to get the Account ID.
    - If logged into any account you can execute `ic account list --output json | jq -r '.[] | select( .Name=="<account name>") | .Guid'` (Replace `<account name>` with the name of the account)
- Get the Cluster Name
    - To list all clusters in the account: `ibmcloud oc cluster ls`
    - The name of the cluster is referenced as `$CLUSTER_NAME` below.
- Get the Worker Name
    - To list the workers for a cluster: `ibmcloud oc worker ls --cluster $CLUSTER_NAME` from the `ID` field.
    - The worker ID is referenced as `$WORKER_ID` below.
- Get the Node Name
    - Get the IP address of the worker from the `ibmcloud oc worker ls --cluster $CLUSTER_NAME` from the `Primary IP` field as this is the `node name` inside the cluster.
    - The Node Name is referenced as `$NODE_NAME` below.

#### Steps
1. Raise a prod train using the below template in [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN)
    ```
    Squad: dreadnought_sre
    Service: dreadnought_sre
    Title: Manual replace of worker <worker> in cluster <cluster> in account <account name> due to a worker issue.
    Environment: <region>
    TestsEnvironment: stage
    Details: cordon, drain, and replace worker
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
1. Log into the Cluster via Bastion following the [Dreadnought Bastion Access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/dreadnought/dn-bastion.html){:target="_blank"}
1. Cordon and Drain the worker.
    1. `oc adm drain $NODE_NAME --force --delete-emptydir-data --ignore-daemonsets=true`
1. Execute a worker replace on the bad worker.
    1. `ibmcloud oc worker replace --cluster $CLUSTER_NAME --worker $WORKER_ID -f`
1. Validate the new worker is up and ready.  The replace can take 10 minutes or more to complete.  If the delete of the old worker takes more than 30 minutes you may consider opening a case for the worker delete being slow for this worker.
    1. `ibmcloud oc worker ls --cluster $CLUSTER_NAME`
        - Example output when deleting: 
        ```
        ID                                                       Primary IP      Flavor     State      Status               Zone         Version
        kube-cpl8n4ld0g17u5d567s0-testatsstsc-transit-00002948   192.168.16.10   bx2.8x32   deleting   Worker is deleting   us-south-1   4.14.33_1576_openshift
        ```
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
