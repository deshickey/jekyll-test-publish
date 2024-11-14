---
layout: default
description: ICD CBR/Allowlist automation
service: Security
title: ICD CBR/Allowlist automation
runbook-name: "ICD CBR/Allowlist automation"
link: /compliance-update-icd-allowlists.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# ICD CBR/Allowlist automation

## Overview

This runbook gives some background information on the ICD CBR/Allowlist automation and how to address the associated PagerDuty incidents.

## Detailed Information

This section covers some background information on the ICD CBR/Allowlist automation. If you were brought here to address a Pager Duty incident please feel free to skip straight to the [Actions required](#actions-required) section.

### Notice Jan 2023: Migration of Firewall (legacy) to CBR

Work is underway to migrate from the legacy allowlist system (aka `Firewall (legacy)`) to CBR, tracked in this [issue](https://github.ibm.com/alchemy-conductors/development/issues/1089)

In particular, the jenkins URLs are different for the new CBR system.

- Legacy ICD: <https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-icd-allowlists>
- CBR ICD: <https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-icd-cbr>

### Background

This section attempts to cover all of the necessary ICD CBR/Allowlist automation background through a series of questions. If you feel that we are missing any information please open a GHE issue in the [conductors repo](https://github.ibm.com/alchemy-conductors/team/issues/new).

- What is ICD?
  - IBM Cloud Databases. ICD has provides a number of DB options. This automation currently supports the following:
    - IBM Cloud Databases for [PostgreSQL](https://cloud.ibm.com/docs/databases-for-postgresql)
    - IBM Cloud Databases for [MongoDB](https://cloud.ibm.com/docs/databases-for-mongodb)
    - IBM Cloud Databases for [RedisDB](https://cloud.ibm.com/docs/databases-for-postgresql)
    - IBM Cloud Databases for [ETCD](https://cloud.ibm.com/docs/databases-for-postgresql)
- What is an allowlist?
  - A list of IP addresses and subnet ranges that are allowed to access a specified resource. In this case, the resource is a ICD instance.
  - This is now referred to as `Firewall (legacy)`
- What is CBR?
  - CBR (Context-Based Restrictions) give account owners and administrators the ability to define and enforce access restrictions for IBM Cloud® resources based on a rule's criteria
  - It is a replacement for the allowlist system (aka `Firewall (legacy)`)
  - For more background see <https://github.ibm.com/alchemy-conductors/cbr/blob/main/concept-context-based-restrictions-IKS-Allowlist-COS-ICD.md>
- How is an allowlist applied to a ICD instance?
  - CBR: rules are applied via the [CBR API](https://github.com/IBM/platform-services-go-sdk/tree/main/contextbasedrestrictionsv1)
  - Legacy: ICD allowlists are applied via the [ICD API](https://cloud.ibm.com/apidocs/cloud-databases-api/cloud-databases-api-v5) using the `SetIPAddresses` function. This function allows us to apply the whole list of IP/Subnets in one go.
- What is the maximum number of allowlist entries for an ICD instance?
  - 100
- What does the ICD allowlist automation do?
  - A sheduled Jenkins job clones the [compliance-iam-account-allowlist](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-iam-account-allowlist/) and [network-source](https://github.ibm.com/alchemy-netint/network-source) repositories, generates a current allowlist for a given `ResourceType`, `region` in a given cloud `account`. If this new allowlist differs from the existing allowlist, then existing allowlist is overwritten with the new allowlist.
- What ICD resource types are used in the allowlist automation?
  - PostgreSQL, MongoDB, RedisDB and ETCD
- What IP's and subnets are included in the allowlist?
  - It depends on the specific ICD instance but the following are typically included:
    - account subnets from network-source repository
    - [GPVPN](https://ibm.ent.box.com/notes/777691610859?s=q0tq6gd951vmubvf00l5jkbidgh9s9mt)
    - [ICD-Scanner](https://pages.github.ibm.com/SOSTeam/SOS-Docs/sca/Public-vs.-Private-address-scanners/#public)
    - [CICD](https://cloud.ibm.com/docs/ContinuousDelivery?topic=ContinuousDelivery-troubleshoot-delivery-pipeline#troubleshoot-firewall-configuration)
    - [Cloud CLI](https://cloud.ibm.com/docs/cloud-shell?topic=cloud-shell-cs-ip-ranges)
    - Containers and Registry DNS addresses
    - [GlobalPAT](https://ibm-cloudplatform.slack.com/archives/C01Q83CBEET/p1616034108007900)
    - [Jenkins](https://github.ibm.com/TAAS/network-reports/blob/master/outbound_ip.md)
    - LogDNA
    - [Private-Service](https://github.ibm.com/alchemy-containers/armada-calico-policies/blob/master/private-network-isolation/eu-fr2/allow-private-services-pods.yaml)
    - SysDig
    - Travis
- Why do we need allowlists on our ICD instances?
  - As part of Financial Services Cloud MFA Guidance, we need to enable allowlisting on dependent services for production accounts. See: AC-17 - [Security Attributes guidance](https://ibm.ent.box.com/notes/777691610859?s=q0tq6gd951vmubvf00l5jkbidgh9s9mt)
- Where is the code repository?
  - [compliance-update-icd-cos-allowlists](https://github.ibm.com/alchemy-conductors/compliance-update-icd-cos-allowlists)
- How is the automation run?
  - There are currently over 20 daily sheduled Jenkins jobs to update ICD instances in each region. Each time an allowlist job is run, it will compare the existing allowlist on each ICD instance to the newly generated allowlist. If there are differences between the too, the existing allowlist will be overwritten by the new allowlist. Otherwise the job will  move on to the next bucket in that region or complete successfully.
- How are the alerts configured?
  - If a Jenkins job fails for any reason the [failure](https://github.ibm.com/alchemy-conductors/compliance-update-icd-cos-allowlists/blob/160bb23aa417c69d8bb90e13a578add22cf64837/Jenkinsfile.ICD#L251) section of Jenkinsfile.ICD will trigger the [icd.notify.sh](https://github.ibm.com/alchemy-conductors/compliance-update-icd-cos-allowlists/blob/160bb23aa417c69d8bb90e13a578add22cf64837/jenkins/icd.notify.sh) script.
  - This notify script takes in the following parameters:
    - PagerDuty integration keys for [Allowlist-Alerts](https://ibm.pagerduty.com/service-directory/P1A9HVP) and [Allowlist-Alerts - stage](https://ibm.pagerduty.com/service-directory/P7MDC7L)
    - Dryrun variable
    - Jenkins job BUILD_URL
    - Account
  - The notify script then CURL's the PagerDuty API on the `https://events.pagerduty.com/v2/enqueue` endpoint
- When is the automaiton run?
  - Daily, as configured in the [triggers](https://github.ibm.com/alchemy-conductors/compliance-update-icd-cos-allowlists/blob/160bb23aa417c69d8bb90e13a578add22cf64837/Jenkinsfile.ICD#L39) section of the Jenkinsfile.ICD file.
- What cloud accounts does the automation run against?
  - Argo Staging - Account 1858147
  - Argonauts Production - Account 531277
  - Satellite Stage - Account 2146126
  - Satellite Production - Account 2094928

### Actions required

If you receive a PagerDuty alert with title `ICD allowlist - failed to update allowlist`, go to [Jenkins Job failures](#jenkins-job-failures).

For all other alert types below, a **pCIE must first be raised**. Please follow the steps in the [Raise a pCIE](#raise-a-pcie) section first, then follow the specific section of the runbook corresponding to the alert.

If you receive a PagerDuty alert with title `postgres-allowlist-alert` and the alert body contains `ErrorBillingLedgerConnectionFailed`, go to [Delete Postgres Resource Allowlist](#how-to-manually-delete-allowlist) section.

### Raise a pCIE

In all alert scenarios, a pCIE must be raised at a minimum. Engage the cluster squad to determine if the alert should be confirmed.

Note the region from the alert.

```txt
TITLE: Customers may experience delays when managing clusters

SERVICES/COMPONENTS AFFECTED:
- IBM Kubernetes Service
- Red Hat OpenShift on IBM Cloud

IMPACT:
- Users may see delays in provisioning workers for new or existing Kubernetes clusters
- Users may see delays in provisioning portable subnets for new or existing Kubernetes clusters
- Users may see delays in provisioning persistent volume claims for existing Kubernetes clusters
- Users may see delays in reloading, rebooting or deleting existing workers of Kubernetes clusters
- Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

STATUS:
- 20XX-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
```

### How to manually update allowlist

To update ICD resources such as Postgre, Etcd, Mongo DB or Redis DB, follow steps below:

1. Go to the [compliance-update-icd-allowlists](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-icd-allowlists/) or [compliance-update-icd-cbr](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-icd-cbr) Jenkins job, depending on whether the alert source was from Allowlist or CBR.
1. Click `Build with Parameters` button
1. Resource type: Select resource type to update
1. Account: Select the cloud account you wish to affect. One of following
   - `argo-staging-1858147`
   - `alchemy-productions-1185207`
   - `satellite-stage-2146126`
   - `razee-stage-2017792` (Only for Redis DB Satellite Stage allowlist)
   - `satellite-prod-2094928`
1. Region: Select the cloud region you wish to affect.
1. Delete: Select `false` to add the newly generated allowlist(s)
1. Dry run: Select `true` to generate allowlist(s) without attempting to apply them to the db buckets. Select `false` to apply allowlist(s)
1. Click run to begin the job
1. Before the allowlist can be applied a `VendoredNonbuilt` train will be raised. For stage account these will be auto approved, however production accounts will require approval.
1. Please reach out to [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK) Slack channel for approval.

### How to manually delete allowlist

1. [Raise a pCIE](#raise-a-pcie) for the alert and then return here.
1. Go to the [compliance-update-icd-allowlists](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-icd-allowlists/) or [compliance-update-icd-cbr](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-icd-cbr) Jenkins job, depending on whether the alert source was from Allowlist or CBR.
1. Click `Build with Parameters` button
1. Resource type: Select `ICD-for-DB_NAME`
1. Account: Select the cloud account `alchemy-productions-1185207`.
1. Region: Select the cloud region you wish to affect.
   - Search for `region` in the `log lines` section of the PD alert, e.g. `ca-tor` etc
   - Alternatively look for the `SOURCE` field in the PD alert, e.g. `SOURCE	https://app.ca-tor.logging.cloud.ibm.com`
1. Delete: Select `true` to remove allowlist(s)
1. Dry run: Select `false` to insure that the allowlists are removed
1. Click run to begin the job. There are no trains to be approved
1. Disable the jenkins job
1. Go to [Escalation Policy](#escalation-policy)


### Jenkins Job failures

For failures of the jenkins job, we need to do the following:

1. If you see error phrase `A cluster with the same name already exists. Choose another name.`, it means there is test cluster present with same name, possibly due to clean up failed with earlier run.
   1. Check the `Account` Parameter on job.
      - If the parameter is `argo-staging-1858147` then log into [test.cloud.ibm.com](https://test.cloud.ibm.com/) and select `IKS.Stage.VPC.Network TEST` account
      - If the parameter is `alchemy-productions-1185207` then log into [cloud.ibm.com](https://cloud.ibm.com/) and select `1984464 - IKS.Prod.VPC.Network` account
   1. Look for cluster with name `postgre-test-<region>` and delete it.
   1. Once cluster is fully deleted, `Rebuild` the job and check if it runs successfully.
1. If it was a transient jenkins failure, e.g. networking problems, failure to clone repos, failure to get train approval.
   - If so, `Rebuild` the job and check if it runs successfully.
   - If the re-run is successful, no further action is required.
1. Otherwise for other failures (including re-run failures), disable the Jenkins job
1. Go to [Escalation Policy](#escalation-policy)

### How to monitor for ICD allowlist issues in a region

1. Go to [LogDNA](https://cloud.ibm.com/observe/logging) bucket for the affected region in account `1185207`

## Escalation Policy

1. Raise a team GitHub issue: [ICD or COS allowlist update](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=&template=icd_cos_allowlist.md&title=) to track.
1. Add informaiton on all debug done so far.
1. Notify in [#iks_cos_allowlist](https://ibm-argonauts.slack.com/archives/C02PZ56C5AL) slack channel with GHE issue raised.
