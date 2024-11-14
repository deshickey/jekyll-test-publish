---
layout: default
description: Tips for investigating cluster master operation request failures in the armada-deploy microservice.
title: Armada-Deploy Operation Failures
service: armada-deploy
runbook-name: "Armada-Deploy Operation Failures"
tags: armada-deploy, cruiser, master
link: /armada/armada-deploy-operation-failures.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This runbook describes the process of investigating Master Operation failure alerts from the *armada-deploy* microservice.

Armada-deploy is in charge of many different operations on a customer cluster's master pod. If any master operation fails, a pagerduty alert will be raised that leads you to this runbook.

**Important Note**

- Most master operation failure alerts are **High Priority**.
- If the cause of this alert can not be fixed using the remaining information in this runbook, then See the [Escalation Policy](#escalation-policy) section on how to escalate this PD alert.
- Failed Master Operations directly and adversely impact the customer cluster in some way.
- To ensure the customer's cluster is fixed, the master operation must be re-triggered after the underlying problem is resolved. This runbook will guide you when it is appropriate to re-trigger the master operation.
- Multiple Failed Master Operations that occur at a high rate is a symptom of a much bigger problem (CIE).
- `WHEN IN DOUBT, ESCALATE!`

## Example Alert(s)
[https://ibm.pagerduty.com/alerts/PZJ5FZ7](https://ibm.pagerduty.com/alerts/PZJ5FZ7)

## Actions to take

Follow the steps below to investigate the problem.

### 1) Locate the Failed Master Operation slack message

To investigate this failure, you will first need to review the Failed Master Operation slack message.

1. Make note of the Request ID in the PD alert details. It will look similar to this example:

   ~~~
   - request = ffa52190-a17d-461c-a218-1ea1fa0f048f
   ~~~
1. Navigate to the [armada-deploy-failure](https://ibm-argonauts.slack.com/messages/C9XGSR292) slack channel.
1. Locate the slack message that contains the same request ID (`ReqID:`) listed in the PD alert details. The slack message will look similar to this example:

   ~~~
   *FAILED* *deploy* on Carrier: *stage-dal09-carrier0* (10.143.139.204) at 2018-03-30T16:05:12+0000 - Region: *us-south*, Cluster: *9850e23241564d3b93831b50ac5d1de7*, Master: *stage-dal09-9850e23241564d3b93831b50ac5d1de7-m1*, BOM: *1.8.8_1507*, IsPaid: *false*, ReqID: *ffa52190-a17d-461c-a218-1ea1fa0f048f*, Attempts: *5*, Elapsed Time: *3535.64* seconds
   Logs
   ~~~

See the [Detailed Slack Message Information _(in this page, below)_](#detailed-slack-message-information) for more background information regarding the master operation slack message.

### 2) Review the Failed Master Operation Slack Message Thread

Every Failed Master Operation slack message will have a thread started by the victory slack bot that provides useful debug determination information related to the failure. You will see:

- The victory slack bot will:
  - look up the current on call personnel and create slack mentions in the thread
  - scan the log for known failure search phrases and provide a link to specific actions you must take if the search phrase is found
  -  gather master pod information for the cluster related to the Failed Master Operation and post a link in the thread.
<br><br>

### 3) Search the Failed Master Operation Log

Go to the [Armada-Deploy Manual Logsearch Instructions page](https://pages.github.ibm.com/alchemy-containers/armada-deploy/logsearch-manual-lookup.html) for instructions on how to use Victory to scan the master operation logs and the list of runbook phrases for manual lookup.
<br><br>

### 4) Search the Get-Master-Info results for the failed master

Go to the [Armada-Deploy Manual MasterInfo Search Instructions page](https://pages.github.ibm.com/alchemy-containers/armada-deploy/masterinfo-search-manual-lookup.html) for instructions on how to use Victory to scan the get-master-info results and the list of runbook phrases for manual lookup.
<br><br>

## Escalation Policy

~~~
!!! You are here after following the runbook information and
    were unable to resolve the PD alert
~~~

- `IF` the Failed Master Operation is a `delete` failure:
  - Check for any open issues for the cluster in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issues }}) using the cluster ID.
  - `IF` an issue does not exist, create a new issue in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) repo.
  - Add a link to the PD alert in the GHE issue.
  - Assign the GHE issue to the deploy member on call. The deploy member on call should be listed in the failed master operation slack message thread. If not, contact `@deploy` and `@update` on the `#armada-deploy` channel.
  - Manually resolve the PD alert.

- `ELSE IF` this is a CIE:
  - `Immediately Escalate the Alert` directly to the squad by using the armada-deploy PD [escalation policy](https://ibm.pagerduty.com/escalation_policies#PT2ZIIQ)

- `ELSE IF` this is during normal business hours:
  - Contact the deploy member on call via slack for assistance. The deploy member on call should be listed in the failed master operation slack message thread. If not, contact `@deploy` and `@update` on the `#armada-deploy` channel.

- `ELSE` this is not a CIE and not during normal business hours:
  - Check for any open issues for the cluster in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issues }}) using the cluster ID.
  - `IF` an issue does not exist, create a new GHE issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) repo.
  - Add a link to the PD alert.
  - Assign the GHE issue to the deploy member on call. The deploy member on call should be listed in the failed master operation slack message thread. If not, contact `@deploy` and `@update` on the `#armada-deploy` channel.

## Other Helpful Items
1. Master operations slack messages are logged into a few slack channels:
   - [#armada-deploy-alerts](https://ibm-argonauts.slack.com/messages/C54FY4EKG) - Master operations in all prod envs.
   - [#armada-deploy-failure](https://ibm-argonauts.slack.com/messages/C9XGSR292) - Master operation failures in prod envs.
   - [#armada-preprod-alerts](https://ibm-argonauts.slack.com/messages/C6UHQH932) - Master operations in pre-prod envs (dev, prestage, stage).
   - [#armada-stage-fails](https://ibm-argonauts.slack.com/messages/CBVLKM88N) - Master operation in stage envs.
1. The [HMS Victory](https://ibm-argonauts.slack.com/team/W5CTGNHJR) slack bot can be a very helpful tool in problem determination for particular cluster. Use  `@victory help` for a complete command list.

### Detailed Slack Message Information

Everything you need to know about a particular operation request can be found in the slack message, including the cluster ID, operation type,carrier, region the operation was performed on, etc.

Breakdown of log parts:

| FIELD     | VALUE                                           | DESCRIPTION                                                                   |
| :---------|:------------------------------------------------| :-----------------------------------------------------------------------------|
| status    | FAILED                                          | The status of this request.                                                   |
| operation | deploy                                          | The operation type of this request. (deploy, delete, upgrade, etc.)           |
| region    | us-south                                        | The region in which the requested operation was performed.                    |
| carrier   | stage-dal09-carrier0                            | The carrier in which the requested operation was performed.                   |
| node      | stage-dal09-carrier0                            | The node IP in which the requested operation was perfromed.                   |
| date/time | 2018-03-30T16:05:12+0000                        | The date/time that the operation finished.                                    |
| clusterID | 9850e23241564d3b93831b50ac5d1de7                | The ID of the cluster the requested operation was performed on.               |
| masterID  | stage-dal09-9850e23241564d3b93831b50ac5d1de7-m1 | The ID of the master the requested operation was performed on.                |
| attempts  | 5                                               | The number of attempts it took for the operation to reach its current status. |
| duration  | 3535.64 seconds                                 | The total amount of time the operation took to complete.                      |
{:.table .table-bordered .table-striped}

#### Included Slack Message Links
The Failed Master Operation slack message will contain the following links:

- `Logs` This is a link to the master operation execution log.
- `Get Master Info` This is a link to the [armada-deploy-get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) jenkins job. The job collects a wide range of useful information about the cluster's master pod.  Here are the detailed usage steps:
  1. Make note of the `Clusterid` in the Failed Master Operation slack message.
  1. Click on the `Get Master Info` link.
  1. Click `Build with Parmeters` and enter the cluster id in the `CLUSTER` parameter.
  1. Click the `Build` button.
  1. Review the console output once the job completes.

#### Automated Slack Message Thread Entries
Automated tooling exists to react to a Failed Master Operation slack message to provide additional information.

- `HMS Victory` slack mentions:  The `victory` slack bot will look up the current on call personnel and create slack mentions in the thread.
- `HMS Victory` worker validation: The `victory` slack bot will perform carrier worker node validation for the worker that ran the Failed Master Operation and post results in the thread.
- `HMS Victory` master information results: The `victory` slack bot will gather master pod information for the cluster related to the Failed Master Operation and post a link in the thread.


### Operation Retrigger

The Failed Master Operation slack thread will have a retrigger message, `To retrigger this operation, click here`, which will bring you to the [armada-deploy-operation-retrigger](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-operation-retrigger/) jenkins job.

  - After clicking on the link, you will need to click the `Proceed` button on the web page to start the job.
  - The job attempts to re-initiate the master operation. A message will appear in the slack thread with the result of the job.
  - If the job is successfully retriggered, a [second job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-monitor-retrigger/) will automatically be kicked off to monitor the retriggered operation, and post back to the thread if the operation fails or succeeds.
  - `NOTE:` A successful retrigger does not mean that the operation will pass, it just means that it has been triggered to run again.  You may recieve another failure just like it in a few minutes if there is still a problem.
  - `NOTE:` This should ONLY be used when you are confident the underlying issue has been resolved.  Blindly retriggering without prior investigation/fixing will most likely not help resolve the problem and could actually result in you receiving another PD alert for the same failure.  If unsure, plesase ask for assistance/advice from the armada-deploy team before issuing the retrigger.  Escalate the alert if required.

### Key Protect troubleshooting

If you got here, most likely the cluster has Key Protect enabled and there is a Key Protect related issue that is keeping the `kms` container from starting properly or encrypting / decrypting secrets. Key Protect and the `kms` container are being used to encrypt and decrypt secrets in the cluster's etcd.

Get the logs for the `kms` container instance.
1. Find this message in the `#armada-deploy-failure` thread: "Please _review the results_ of running the Get-Master-Info Jenkins job for this cluster."
1. Search the plain text logs for `-c kms` until you get to a line starting `MASTER CONTROL PLANE CONTAINER LOGS`
1. Look for error messages that are shown below.

#### Which KMS provider is being used

IKS supports two KMS providers - each is a separate IBM Cloud service offering:
- Key Protect - the standard provider that we document.  This can be configured using the UI or CLI.
- Hyper Protect Crypto - a dedicated key management service and hardware security module (HSM) that supports the Key Protect APIs.
To configure Hyper Protect Crypto you must use the `ibmcloud` CLI and specify the proper endpoint.

To determine the provider being used by a cluster get the endpoint from `xo-secure`
private channel. You may need conductors to look this up.
- Go to the `#xo-secure` channel.  This is a private channel.
- Run `@xo cluster CLUSTERID show=all`
- Look for the `KPInfo` field. This is a JSON structure. The endpoint is the `url` field of this structure.

If you (or conductors) do not have access to `xo-secure`, you can also use the `armada-data` tool
on a hub carrier master in the same region:
`armada-data get Cluster -pathvar ClusterID=$ClusterID -field KPInfo`

<a name="kp_provider_table">See the table below</a> for example endpoints and the associated Slack channels.

Provider | Example endpoints | Slack channel
--- | --- | ---
Key Protect | https://us-south.kms.cloud.ibm.com or https://keyprotect.us-south.bluemix.net | `#key-protect` in our Argonauts workspace
Hyper Protect Crypto | https://api.us-south.hs-crypto.cloud.ibm.com:PORT/ | `#hp-crypto-kms` in the IBM Cloud Platform workspace (ibm-cloudplatform.slack.com). For escalation information see note below this table.

*Contacting Hyper Protect Crypto support:* (from their SREs)

If you think it is an urgent issue and needs to be taken care of right away, you can trigger page duty alert by send an email to "global-sre-sev1@ibm.pagerduty.com", otherwise send a Slack message and we can take care within business hour. Slack id: `@hpcs-sre`, channel: `#hp-crypto-kms`, IBM Cloud Platform workspace (ibm-cloudplatform.slack.com).

*Endpoints for each provider:*

A complete list of KP endpoints is at https://cloud.ibm.com/docs/services/key-protect?topic=key-protect-regions#connectivity-options

A complete list of Hyper Protect Crypto endpoints is at https://cloud.ibm.com/docs/services/hs-crypto?topic=hs-crypto-regions#service-endpoints


#### KMS Implementation Version

Determining which KMS implementation version you are dealing with will help you resolve KMS errors.

KMS V2.0 path
* KMS logs will contain the message: `KMS V2.0 path, WDEK will be loaded from mounted secret file: /tmp/kms/wdek`
* The WDEK that is used for encryption is stored as a secret on the carrier/tugboat for the cluster. The state of the WDEK is also stored in the secret and indicates if the WDEK is enabled or disabled. Further details relating to the v2.0 path can be found in the [armada-deploy wiki](https://github.ibm.com/alchemy-containers/armada-deploy/wiki/BYOK-Key-Protect).

KMS V1.0 path and Legacy Path
* KMS logs will not contain the `KMS V2.0 path` message and may or may not contain the `KMS V1.0 path, WDEK will be generated.` message.
* The WDEK that is used for encryption is generated each time the container starts.

#### Error messages

~~~
Error getting DEK and wrapped DEK for Root Key:'***Value redacted***'","error":"Unauthorized: user does not have access to provided resources.`
~~~

This indicates that the cluster API does not have `Reader` service access role to the `Key Protect` instance.
This is something the customer must fix.
This error is still being investigated by the armada-api squad, but we believe this occurs when the APIKey is associated
with one user (an account administrator), but the Key Protect instance is owned by another user in the account (presumably
the person who created the service).  Possible solutions:
1. Grant the API key `Reader` service access role to the Key Protect service instance.
   1. Grant access to the Kubernetes Service: https://cloud.ibm.com/docs/key-protect?topic=key-protect-grant-access-keys
   1. After the customer has corrected the permissions, retrigger the failing operation - typically `kms_update`.
1. Create a new API key and set it for all clusters in the resource group.
   1. Login as the desired owner, account, and resource group: `ibmcloud login` .
   1. Reset the api-key: `ibmcloud ks api-key reset --region`. Note, this affects all clusters in the resource group.
   1. After the customer has completed the reset, update the master deployment using the "Follow-up actions" as described in [KMS API Key Missing](https://pages.github.ibm.com/alchemy-containers/armada-deploy/message-templates/kms-apikey-missing.html#follow-up-actions) runbook.

~~~
Unauthorized: The user does not have access to the specified resource
~~~

If the log entry that contains the error also contains `Unwrap WDEK failed` and the KMS log contains the phrase `Service to service authentication will be used`, then the user is missing the service authorization policy (service to service) between the Kubernetes Service and the Key Protect Service. This policy is automatically created for the user when KMS is enabled if not already present. The policy can be recreated by the user as documented in the [VPC worker nodes](https://cloud.ibm.com/docs/containers?topic=containers-encryption#worker-encryption-vpc) section or using the steps below.
1. Go to [service authorization policies in IBM Cloud IAM](https://cloud.ibm.com/iam/authorizations)
1. Set the Source service to Kubernetes Service.
1. Set the Target service to your KMS provider, such as Key Protect.
1. Include at least Reader service access.
1. Enable the authorization to be delegated by the source and dependent services.

~~~
This operation cannot be completed. Please try your request at a later time. If the issue persists, please contact IBM KeyProtect
or
This operation cannot be completed. Please try your request at a later time. If the issue persists, please contact Key Protect.
~~~

Contact the team for the endpoint being used (Key Protect or Hyper Protect Crypto). See [table](#kp_provider_table) in the "Which KMS provider is being used" section for a list of providers and associated Slack channels. 

Once the problem is resolved, the `kms` container should start running normally, but you will still need to retrigger the failing operation to allow the
apiserver to complete encrypting or re-encrypting secrets.

~~~
BXNIM0410E Provided user not found or active
~~~

This indicates that the user associated with the cluster API key is no longer a member of the account (i.e. an IBMer who has left IBM or perhaps changed jobs).

To correct this problem, the user will need to do the following:
1. Determine a new owner and grant proper access: https://cloud.ibm.com/docs/key-protect?topic=key-protect-grant-access-keys
1. Run `ibmcloud target -g RESOURCE_GROUP`
1. Run `ibmcloud ks api-key reset --region <region>` to create a new api-key and assign the key to all cluster's in the resource group and region.

Once completed, update the master deployment using the "Follow-up actions" as described in [KMS API Key Missing](https://pages.github.ibm.com/alchemy-containers/armada-deploy/message-templates/kms-apikey-missing.html#follow-up-actions) runbook.

~~~
BXNIM0415E Provided API key could not be found
~~~

See the armada-deploy runbook page for [KMS API Key Missing](https://pages.github.ibm.com/alchemy-containers/armada-deploy//masterinfo-search-actions/kms-api-key-missing.html)

~~~
error during request to KeyProtect correlation_id='a72fd89c-71c7-45a9-a0c1-4feecdc39039': Post https://api.us-south.hs-crypto.cloud.ibm.com:8451/api/v2/keys/13b69934-96b4-4d30-8a9d-9a4f406c5ef3?action=wrap: dial tcp 169.63.25.194:8451: connect: connection refused
~~~

If this is a Hyper Protect Crypto instance (look at the Post URL), this might indicate that the Hyper Protect Crypto instance has been deleted.
In that case the cluster owner can only delete the cluster; no recovery is possible.
Post the error message in the `#hp-crypto-kms` channel to confirm the problem. Use Slack handle `@hpcs-sre`.

~~~
KEY_DELETED_ERR: Key has already been deleted. Please delete references to this key.
~~~

See the armada-deploy runbook page for [KMS Key Protect secret has been deleted](https://pages.github.ibm.com/alchemy-containers/armada-deploy/masterinfo-search-actions/kms-kp-secret-deleted.html)

~~~
Conflict: Unwrap with key could not be performed: Please see `reasons` for more details (KEY_ACTION_INVALID_STATE_ERR)', reasons='[KEY_ACTION_INVALID_STATE_ERR: Key is not in a valid state]
~~~

The Key Protect root key has been disabled.
See the armada-deploy runbook page for [KMS Key Protect key invalid state](https://pages.github.ibm.com/alchemy-containers/armada-deploy/masterinfo-search-actions/kms-kp-key-invalid-state.html)


##### `failed to get CRN token from IAM`

This indicates a failure to get a token from IAM. This can occur if the IAM service is down or degraded. Check in the [#iam-issues](https://app.slack.com/client/T4LT36D1N/C3C46LY7N) Slack channel to see if there are any known problems with the IAM service.

#### References

- [Encrypting Kubernetes secrets by using Key Protect](https://cloud.ibm.com/docs/containers?topic=containers-encryption#keyprotect)
- [Assigning cluster access](https://cloud.ibm.com/docs/containers?topic=containers-users#users)
- [(Key Protect) Managing user access](https://cloud.ibm.com/docs/services/key-protect?topic=key-protect-manage-access)


### Webhooks Causing Failures

<b>This section is primarily for developer use.</b>

If you find update/upgrade failures which have not already been covered in the extensive
list above, you can check if a webhook, specifically the webhook for
[Container Image Security Enforcement](https://console.bluemix.net/docs/services/Registry/registry_security_enforce.html#security_enforce)
(CISE) is causing the failure.

Verify if the CISE webhook has been enabled in the cluster by checking the logs from the
[Get Master Info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info)
job, searching for <code>CLUSTER WEBHOOKS</code> section.

```bash
CLUSTER WEBHOOKS:

VALIDATING WEBHOOK CONFIGURATIONS

Name:         image-admission-config
Namespace:
Labels:       app=ibmcloud-image-enforcement
              chart=ibmcloud-image-enforcement-0.2.3
              heritage=Tiller
              release=cise
...
```

You can also check the carrier directly:

```bash
$ kubx-kubectl <cluster-id> get ValidatingWebhookConfiguration,MutatingWebhookConfiguration | grep image-admission-config
```

You may also see that a number of pods are not being scheduled to run, which is because
the CISE pods, which approve other pods, are not running themselves. Thus preventing any
approval for itself or other pods.

<b>Note:</b> <code>cis-ibmcloud-image-enforcement</code> <b>pods are not running as mentioned above</b>

```bash
NAMESPACE             NAME                                             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
ibm-system            cise-ibmcloud-image-enforcement                  3         0         0            0           7d13h
ibm-system            ibm-cloud-provider-ip-158-175-84-222             2         0         0            0           174d
ibm-system            ibm-cloud-provider-ip-158-176-91-14              2         0         0            0           143d
ibm-system            ibm-cloud-provider-ip-159-8-190-230              2         0         0            0           108d
kube-system           calico-kube-controllers                          1         0         0            0           175d
kube-system           heapster                                         1         0         0            0           174d
kube-system           ibm-file-plugin                                  1         0         0            0           174d
kube-system           ibm-storage-watcher                              1         0         0            0           174d
kube-system           ibmcloud-container-scanner-cluster               1         0         0            0           91d
kube-system           ibmcloud-object-storage-plugin                   1         0         0            0           173d
kube-system           kube-dns-amd64                                   2         0         0            0           174d
kube-system           kube-dns-autoscaler                              1         0         0            0           174d
kube-system           kubernetes-dashboard                             1         0         0            0           174d
...
```


If you find that these webhooks do exist on the cluster, check if the owner is an IBMer.
If the owner is not an IBMer, open a GHE issue in regard to the failure, make note of
your findings and the customer will have to open an issue against IKS to proceed. You
can follow the rest of this section once they do.

If the owner is an IBMer, follow one of the two paths below.

First, you can ask the IBM owner to simply modify the existing webhooks to "fail open"
rather than closed, following the
[Troubleshooting pods do not restart](https://console.bluemix.net/docs/services/Registry/ts_index.html#ts_pods).
You can then [Retrigger](#operation-retrigger) the operation and once it completes
successfully, ask the IBM owner to return the webhooks back to "fail closed" per the
documentation.

Otherwise, you can ask the IBM owner to remove the webhooks following the
[Removing CISE](https://console.bluemix.net/docs/services/Registry/registry_security_enforce.html#remove)
instructions, specifically just for the webhooks (helm chart can be left as-is).
You can then [Retrigger](#operation-retrigger) the operation and once it completes
successfully, ask the IBM owner to re-run the CISE helm chart to add the webhooks back.
