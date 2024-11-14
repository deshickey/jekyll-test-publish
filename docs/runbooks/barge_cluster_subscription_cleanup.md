---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to clean up Barge cluster subscriptions
service: Conductors
title: Barge cluster subscription cleanup 
runbook-name: "Barge cluster subscription cleanup"
link: /barge_cluster_subscription_cleanup.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

This runbook provides detailed steps for IKS SRE to follow to clean up Barge cluster subscriptions in the Argo Dev account

## Detailed Information
The current Barge cleanup Jenkins job appears to leave cluster subscriptions intact even after they are completely removed. To ensure we do not use all of our capacity on deleted clusters, please use the steps outlined in this runbook to archive the cluster.

### Steps

#### Pre-requisites 

- Cluster ID.
- [Brew](https://brew.sh/).
- OpenShift Cluster Manager API command-line interface (ocm).
- Conauto_RedHat_API_Token from [dev_us-east_secretsmanager](https://cloud.ibm.com/services/secrets-manager/crn%3Av1%3Abluemix%3Apublic%3Asecrets-manager%3Aus-east%3Aa%2Fdd8764ef7e84d59c23228ee806ecffd2%3Aeafd9ee5-e538-425e-86b9-ea7febc69e0f%3A%3A?paneId=manage#/manageSecrets).
- All the below commands will be run on your local machine in the terminal.

1. Run the command `brew install ocm`.
1. Go to [dev_us-east_secretsmanager](https://cloud.ibm.com/services/secrets-manager/crn%3Av1%3Abluemix%3Apublic%3Asecrets-manager%3Aus-east%3Aa%2Fdd8764ef7e84d59c23228ee806ecffd2%3Aeafd9ee5-e538-425e-86b9-ea7febc69e0f%3A%3A?paneId=manage#/manageSecrets) (in IBM Cloud web) and once in there, you will see a list of `Secrets`, search for `Conauto_RedHat_API_Token` and on the very right of this item, click on the `⋮` and select `view secret`, then copy the `Secret value`.
1. Login to ocm by running: `ocm login --token="<Conauto_RedHat_API_Token>"`.
1. The following command will retrieve a subscription ID: `ocm get subscriptions -p search="external_cluster_id = '<ID_OF_CLUSTER_TO_BE_ARCHIVED>'" | jq -r '.items[].id'`. Copy the output and keep it somewhere.
1. Create a new file named `archive.json` and add the following to that file:
    ```json
    {
      "status":"Archived"
    }
    ```
    Save the changes.
1. Update the subscription by running the following command: `ocm patch "/api/accounts_mgmt/v1/subscriptions/<SUBSCRIPTION_ID_FROM_EARLIER>" --body="archive.json"`.
1. The output of the last command you ran (`ocm patch`) is in JSON, look for the key `status` by the end of said output and check that its value is `"status":"Archived"`, this confirms that the cluster is now archived.
