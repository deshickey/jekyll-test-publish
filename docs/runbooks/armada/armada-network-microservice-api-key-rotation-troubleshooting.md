---
layout: default
description: How to verify armada-network microservice is functioning when customers issue API Key Reset commands.
title: armada-network - How to verify armada-network microservice is functioning when customers issue API Key Reset commands.
service: armada
runbook-name: "armada-network - How to verify armada-network microservice is functioning when customers issue API Key Reset commands"
tags: network, microservice
link: /armada/armada-network-microservice-api-key-rotation-troubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook is written for both an ACS team member and a member from the Network squad to follow. It describes how to verify that network-microservice is functioning properly when a customer is running an `ibmcloud ks api-key reset` command and claims that the API key is not working for them.

## Example Alerts

An often difficult to troubleshoot issue is when a customer encounters errors in their cluster such as `SoftLayer_Exception_User_Customer_Unauthorized` or `Invalid API key` when trying to take action against their cluster or within workload on their cluster.

## Investigation and Action

Before continuing, check to see where the customer is reporting seeing an API key error message. If it is coming from an add-on or component owned by another squad, the customer ticket should first go to that squad to investigate to understand why the error message is occurring. You will also find instructions on how to reset an API Key correctly, which might be helpful to the customer (depending on if we believe this customer has (or has not) properly rotated their API key already).

### API Key Reset Troubleshooting

This most likely means the customer has done one of two things:

1. Accidentally deleted their `containers-api-key` API Key from their IBM Cloud Account, and will now need to run an `ibmcloud ks api-key reset --region <REGION>`.
   - The `ibmcloud ks api-key info --cluster <cluster_name_or_ID>` command can be used to find information about the `containers-api-key` associated with the cluster. If this command fails to find the API key, it means the API key has been deleted.
2. The customer has recently run the `ibmcloud ks api-key reset --region <REGION>` command and (a) did not target the correct region and resource group and/or (b) ran the command signed into the `ibmcloud` CLI as a user who didn't have enough authority and the API Key that was created lacks the necessary permissions.
3. In some rare cases, the customer might have a Classic Infrastructure Key set for the region their cluster is in that overrides the Containers Kubernetes API Key for some SoftLayer (Classic Infrastructure) resources. This runbook will help you check that with the customer.

There is code in the `network-microservice` that runs _each_ time that a user runs this `ibmcloud ks api-key reset` command to populate the Storage Secret on the Classic/VPC cluster with the new IAM API Key.

This runbook can be used when dealing with a customer ticket related to an API Key Reset issue, and to prove that `network-microservice` is properly updating the Storage Secret with the correct IAM API Key.

### Steps to Successfully Run an API Key Reset Command

Public Docs: https://cloud.ibm.com/docs/containers?topic=containers-access-creds

Doing an API Key reset is scoped to the region **and** the right resource group. Performing an API Key Reset should be done in the following order.

1. Log into the `ibmcloud` CLI (**must log into an account with the necessary permissions, see note below**).
   - Unless a customer knows what they are doing, we should recommend to the customer that they log into the CLI as the **account owner**.
   - The customer can run `ibmcloud ks infra-permissions get` once logged-in to ensure no Classic infrastructure permissions are missing.
2. Determine the Resource Group and Region of your cluster by running `ibmcloud ks cluster get --cluster <cluster_name_or_ID>`.
   - Make note of the `Resource Group ID` value and the `Worker Zones` (to know the region).
3. Target the right region that the cluster is in by running `ibmcloud  target -r <region>`.
4. Target the right resource group that the cluster is in by running `ibmcloud target -g <resource-group>`.
5. Run `ibmcloud target` to double-check that:
   - a. You are signed into the correct account.
   - b. You are targeting the correct region.
   - c. You are targeting the correct resource group.
6. If you were targeting the wrong resource group or region, reset your API Key again by running `ibmcloud ks api-key reset --region <region>`. If you were targeting the correct resource group and region, there is no need to reset your key again so skip the remaining steps.
7. Wait 60 seconds.
8. Verify that the new API key is set up by running `ibmcloud ks api-key info --cluster <cluster_name_or_ID>`.
   - You can also run `ibmcloud iam api-keys` to ensure a `containers-kubernetes-key` API Key is present in the list that has a `Created At` date from the last few minutes.
9. Wait **up to 30 minutes** for the storage secret to get updated in the clusters in that region and resource group to be updated.

### Steps to Verify Classic Infrastructure Credentials Are Valid

Public Docs: https://cloud.ibm.com/docs/containers?topic=containers-classic-credentials

If the customer is reporting that an `ibmcloud ks api-key reset ...` command isn't resetting their API Key and is seeing errors similar to `SoftLayer_Exception_User_Customer_Unauthorized`, it is possible that they have saved a Classic Infrastructure API Key to their cluster. An Infrastructure (SoftLayer) API Key will always take precedence over the `containers-kubernetes-key` which is the cloud platform API key that is reset via `ibmcloud ks api-key reset ...` for certain SoftLayer (Classic Infrastructure) resources. Not many customers use this approach, but it is a valid use case.

The public docs linked above are a good starting point. 

The customer can run `ibmcloud ks credential get --region <region>` to see if a Classic Infrastructure key is set for the region their cluster is in. If a Classic Infrastructure API Key **is** set, then it is likely the customer (or someone with access to the customer's account) deleted this API Key. The public docs linked above step through how to re-create and re-link a Classic Infrastructure API key. This will need to be attempted first to see if a new Classic Infrastructure API Key resolves the problem.

---

**At this point the customer has attempted an API Key Reset and it has confirmed that they (a) aren't using a Classic Infrastructure API Key or (b) have re-created and re-set it, a member from the Network squad will need to be engaged to determine if `network-microservice` is functioning properly. Please follow the Escalation Policy outlined at the end of this runbook.**

---

### Verifying that `network-microservice` is Updating Storage Secret

When a ticket comes into ACS or gets routed to the Storage Team to look into these SoftLayer (SL) permissions issues, there are likely going to be statements that `network-microservice` is "broken", "not updating the Storage Secret on a cluster properly", or "has bad encryption/decryption logic." 

The steps below can be followed to ensure network microservice is updating the storage secret correctly.

1. Search for the `clusterID` in Slack. Look for successful (or failed) messages for the `cluster_secret_update` job in our `#armada-netms-alerts` or `#netms-fails` channels. There should be a `cluster_secret_update` Slack message for each time the customer ran the `ibmcloud ks api-key reset` command.
   - Obviously, if the job is failing, evaluate the logs to determine why. This might explain why a Storage Secret on a cluster is not being updated.
   - The more difficult case will be evaluating the logs for successful jobs to ensure `net-ms` is behaving correctly. Open the logs and look for these phrases to help confirm that `net-ms` is properly getting the updated secret properly:
      - "Successfully populated secret information from network.toml"
      - "Updating the cluster secret"
      - "Storage Encryption is enabled.  Encrypting Bluemix.IAMAPIKey"
      - "Successfully Uploaded config to cluster updater within 5s with StatusCode: 200"
      - "About to send the credential Audit event for cluster secret update
      - You'll also see the resource group and targeted `clusterID` in the our logs. Confirm that those are the expected values.

2. Ensure that `cluster-updater` is functioning properly on the master for the customer's cluster.
   - In the `MASTER CONTROL PLANE RESOURCES` section of any GMI for the cluster, ensure that the `cluster-updater` pod is running and hasn't had a high number of restarts (which would indicate that it is crashing).
   - In the `MASTER CONTROL PLANE CONTAINER LOGS` section of any GMI for the cluster, ensure that the `cluster-updater` pod logs don't show any panics or errors around the `storage-secret`.
      - Typically we only show the last 100 lines of logs by default. If you want all of the logs, run a fresh GMI with `cluster-updater` specified in the `MCP_LOGS` build parameter field.

3. In your personal production account, create the same type of cluster (Classic or VPC) in the same production region as the customer and run an `ibmcloud ks api-key reset` command to verify functionality of `net-ms`. 
   - 1. Create a cluster in your personal production account.
   - 2. Wait for the cluster to become normal. 
   - 3. Run `ibmcloud ks cluster config --admin --cluster <clusterID>` to pull the admin `kubeconfig` for your cluster.
   - 4. Make note of your **encrypted** IAM API Key in your Storage Secret.
      - For Classic Clusters: `kubectl get secret storage-secret-store -n kube-system -o yaml | grep slclient.toml: | awk '{print $2}' | base64 --decode | grep iam_api_key`
      - For VPC CLusters: `kubectl get secret storage-secret-store -n kube-system -o yaml | grep slclient.toml: | awk '{print $2}' | base64 --decode | grep g2_api_key` OR `vpcctl get-api-key`
         - If you use `vpcctl` (from your local machine only), there are several helpful commands you might be interested in:
            - `vpcctl get-secret` - will display the entire storage secret including encrypted API key
            - `vpcct get-api-key` - will display the plain text API key
            - `vpcctl get-sdnlb-secret` - will display the `kube-system / sdnlb-config` secret
            - `vpcctl get-sdnlb-api-key` - will display the plain text sDNLB API key
         - If a customer has Debug Tool enabled on their VPC cluster, they can run `vpcctl get-resource-group`
    - 5. Follow the steps in the `## Steps to Successfully Run an API Key Reset Command` section above to run an API Key reset.
    - 6. Repeat step 3d from above and ensure that your storage secret has a **new** API key value. This proves that `net-ms` is properly updating the storage secret with the API Key that is stored in `etcd`. 

In most cases, this should be enough proof that `network-microservice` is properly updating the Storage Secret on the cluster.

### Validate API Key in `etcd` Matches Storage Secret on Cluster

**This should be the absolute last resort for "extreme" customer tickets where another squad or a customer wants 100% confidence that the API Key in `etcd` matches what is in the Storage Secret on the cluster and won't accept our own validation (as described in the `## Verifying that network-microservice is Updating Storage Secret` section above). These steps should not be taken unless all of the above steps have been followed and there is proof that network-microservice is not functioning properly (i.e. a failed job).**

**Note:** This will require a team-lead or an SRE that has access to the `@xo-secure` channel.

1. In the `@xo` Slack channel run `@xo cluster <clusterID> show=all`.
2. Pull the values from the `AccountID` and the `ResourceGroupID` fields.
3. Run `@xo resourceGroup <accountID>/<resourceGroupID>` with the values from the step above.
   - There will be a Slack message from `@xo` for _each_ resource group in _each_ region that the customer has. Ensure that the cluster(s) of interest are actually in that account and the expected resource group.

If the clusters exists in the correct account and resource group, you will now need someone with access to the `@xo-secure` channel. 

1. Give the person with the access to `@xo-secure` channel the following command to run `@xo resourceGroup <accountID>/<resourceGroupID> show=all region=<region>` (use the values that you pulled for the customer's cluster from the previous steps).
   - This will return a link to a COS bucket that contains the plain-text API key.
2. In order to view the COS Bucket, connect to the GlobalProtect VPN.
3. Once connected to the VPN, you will want to open the COS Bucket and find the value in the `IAMAPIKey` field. The COS Bucket contents should look something like the following:

```
{
    "Region": "us-south",
    "AccountID": "<ACCOUNT-ID>",
    "ResourceGroupID": "<RESOURCE-GROUP-ID>",
    "Canceled": null,
    "Name": "<VPC-ID>",
    "SLUser": "XXXXXX", # This was null in one pre-prod region, non-null in another, so maybe this is the key that is set via: `ic ks credential set...` ???
    "SLAPIKey": "XXXXXX",  # Same as SLUser, was null in one pre-prod region, non-null in another
    "RefreshToken": null,
    "IAMAPIKey": "XXXXXXXXXXX",
    "IAMAPIKeyUUID": "ApiKey-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    "Clusters": "{...}",
    ....
```

To prove that `network-microservice` is properly encrypting this API Key, you could decrypt the IAM Key from the Storage Secret by:

1. Clone `https://github.ibm.com/alchemy-containers/armada-data/`
2. Navigate to the root of this directory wherever you cloned it on your machine. 
3. Run `cd decrypt`.
4. To decrypt the IAM API KEY run `echo "<ENCRYPTED_STORAGE_SECRET_IAM_API_KEY>" | go run main.go <DECRYPTION_KEY>`
   - Replace `<ENCRYPTED_STORAGE_SECRET_IAM_API_KEY>` with the **encrypted** IAM API key from the customer's cluster's Storage Secret. (See the `## Verifying that network-microservice is Updating Storage Secret` section above for the `kubectl `command to get that.)
   - Replace `<DECRYPTION_KEY>` with the correct decryption key. (For what I hope to be obvious reasons, I am not going to list that here. If you are unsure of what this is, ask one of the team leads from the Network Squad.)
5. The output from running the command in step 4 is the **plain-text** IAM API Key. It should match the value that was pulled from the `@xo-secure` COS Bucket.

If those match, that proves beyond a doubt that `network-microservice` is functioning properly and that the API Key is bad in some way.

If those don't match, then we would likely need to pull in the `Ironsides` team as they would own the `ibmcloud ks api-key reset` command that populates the field in `etcd`.

## Escalation Policy

Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
