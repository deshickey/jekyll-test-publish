---
layout: default
description: COS CBR/Allowlist automation
service: Security
title: COS CBR/Allowlist automation
runbook-name: "COS CBR/Allowlist automation"
link: /compliance-update-cos-allowlists.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# COS CBR/Allowlist automation

## Overview

This runbook gives some background information on the COS CBR/Allowlist automation and how to address the associated PagerDuty incidents.

## Detailed Information

This section covers some background information on the COS CBR/Allowlist automation. If you were brought here to address a Pager Duty incident please feel free to skip straight to the [Actions required](#actions-required) section.

### Notice Q1 2024: Migration of Firewall (legacy) to CBR

Migration is complete from legacy allowlist system (aka `Firewall (legacy)`) to CBR, tracked in this [issue](https://github.ibm.com/alchemy-conductors/development/issues/1089)

In particular, the jenkins URLs are different for the new CBR system.

- Legacy COS: <https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-cos-allowlists>
- CBR COS: <https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-cos-cbr>

### Background

This section attempts to cover all of the necessary COS CBR/Allowlist automation background through a series of questions. If you feel that we are missing any information please open a GHE issue in the [conductors repo](https://github.ibm.com/alchemy-conductors/team/issues/new).

- What is COS?
  - Cloud Object Storage. [COS Documentation](https://cloud.ibm.com/docs/cloud-object-storage)
- What is an allowlist?
  - A list of IP addresses and subnet ranges that are allowed to access a specified resource. In this case, the resource is a COS bucket.
  - This is now referred to as `Firewall (legacy)`
- What is CBR?
  - CBR (Context-Based Restrictions) give account owners and administrators the ability to define and enforce access restrictions for IBM Cloud® resources based on a rule's criteria
  - It is a replacement for the allowlist system (aka `Firewall (legacy)`)
  - For more background see <https://github.ibm.com/alchemy-conductors/cbr/blob/main/concept-context-based-restrictions-IKS-Allowlist-COS-ICD.md>
- How is an allowlist applied to a COS instance?
  - CBR rules are applied via the [CBR API](https://github.com/IBM/platform-services-go-sdk/tree/main/contextbasedrestrictionsv1)
- What is the maximum number of allowlist entries for an COS bucket?
  - 1000
- What does the COS allowlist automation do?
  - A scheduled Jenkins job clones the [compliance-iam-account-allowlist](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-iam-account-allowlist/) and [network-source](https://github.ibm.com/alchemy-netint/network-source) repositories, generates a current allowlist for a given `region` in a given cloud `account`. If this new allowlist differs from the existing allowlist, then existing allowlist is overwritten with the new allowlist.
- What IP's and subnets are included in the allowlist?
  - It depends on the specific COS bucket but the following are typically included:
    - account subnets from network-source repository
    - [GPVPN](https://ibm.ent.box.com/notes/777691610859?s=q0tq6gd951vmubvf00l5jkbidgh9s9mt)
    - [CICD](https://cloud.ibm.com/docs/ContinuousDelivery?topic=ContinuousDelivery-troubleshoot-delivery-pipeline#troubleshoot-firewall-configuration)
    - [Cloud CLI](https://cloud.ibm.com/docs/cloud-shell?topic=cloud-shell-cs-ip-ranges)
    - Containers and Registry DNS addresses
    - [GlobalPAT](https://ibm-cloudplatform.slack.com/archives/C01Q83CBEET/p1616034108007900)
    - [Jenkins](https://github.ibm.com/TAAS/network-reports/blob/master/outbound_ip.md)
    - LogDNA
    - [Private-Service](https://github.ibm.com/alchemy-containers/armada-calico-policies/blob/master/private-network-isolation/eu-fr2/allow-private-services-pods.yaml)
    - SysDig
    - Travis
- Why do we need allowlists on our COS buckets?
  - As part of Financial Services Cloud MFA Guidance, we need to enable allowlisting on dependent services for production accounts. See: AC-17 - [Security Attributes guidance](https://ibm.ent.box.com/notes/777691610859?s=q0tq6gd951vmubvf00l5jkbidgh9s9mt)
- Where is the code repository?
  - [cbr](https://github.ibm.com/alchemy-conductors/cbr)
- How is the automation run?
  - There are currently over 20 daily scheduled Jenkins jobs to update COS buckets in each region. Some COS buckets are not region specific, the Jenkins jobs for these buckets, have the _Region_ parameter set to `global`. Each time an allowlist job is run, it will compare the existing allowlist on each COS bucket to the newly generated allowlist. If there are differences between the too, the existing allowlist will be overwritten by the new allowlist. Otherwise the job will  move on to the next bucket in that region or complete successfully.
- How are the alerts configured?
  - If a Jenkins job fails for any reason the [failure](https://github.ibm.com/alchemy-conductors/cbr/blob/main/Jenkinsfile.COS#L333) section of Jenkinsfile.COS will trigger the [cos.notify.sh](https://github.ibm.com/alchemy-conductors/cbr/blob/main/jenkins/cos.notify.sh) script.
  - This notify script takes in the following parameters:
    - PagerDuty integration keys for [Allowlist-Alerts](https://ibm.pagerduty.com/service-directory/P1A9HVP) and [Allowlist-Alerts - stage](https://ibm.pagerduty.com/service-directory/P7MDC7L)
    - Dryrun variable
    - Jenkins job BUILD_URL
    - Account
  - The notify script then CURL's the PagerDuty API on the `https://events.pagerduty.com/v2/enqueue` endpoint
- When is the automation run?
  - Daily, as configured in the [trigger](https://github.ibm.com/alchemy-conductors/compliance-update-icd-cos-allowlists/blob/160bb23aa417c69d8bb90e13a578add22cf64837/Jenkinsfile.COS#L34) section of the Jenkinsfile.COS file.
- What cloud accounts does the automation run against?
  - Argo Staging - Account 1858147
  - Argonauts Production - Account 531277
  - Alchemy Production - Account 1185207
  - Satellite Stage - Account 2146126
  - Satellite Production - Account 2094928
  - Razee Stage - Account 2017792
  - IKS BNPP Prod - Account 2051458

### Actions required

If you receive a PagerDuty alert with title `COS Allowlist - failed to update allowlist`, go to [Jenkins Job failures](#jenkins-job-failures).

For all other alert types below, a **pCIE must first be raised**. Please follow the steps in the [Raise a pCIE](#raise-a-pcie) section first, then follow the specific section of the runbook corresponding to the alert.

- If you receive a PagerDuty alert with title `allowlist-alert-REGION` and the alert body contains `AccessDenied` go to [Delete COS Resource Allowlist](#how-to-manually-delete-allowlist) section.

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

1. Go to the [compliance-update-cos-cbr](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-cos-cbr) Jenkins job
1. Click `Build with Parameters` button
1. Account: Select the cloud account you wish to affect. One of following
   - `argo-staging-1858147`
   - `argonauts-production-531277`
   - `satellite-stage-2146126`
   - `satellite-prod-2094928`
1. Region: Select the cloud region you wish to affect.
1. Delete: Select `false` to add the newly generated allowlist(s)
1. Dry run: Select `true` to generate allowlist(s) without attempting to apply them to the db buckets
1. Click run to begin the job
1. Before the allowlist can be applied a `VendoredNonbuilt` train will be raised. For stage account these will be auto approved, however production accounts will require approval.
1. Please reach out to [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK) Slack channel for approval.

### How to manually delete allowlist

1. [Raise a pCIE](#raise-a-pcie) for the alert and then return here.
1. Go to the [compliance-update-cos-cbr](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-cos-cbr) Jenkins job
1. Click `Build with Parameters` button
1. Account: Select the cloud account you wish to affect. For COS, choose one of following
   - `argo-staging-1858147`
   - `argonauts-production-531277`
   - `satellite-stage-2146126`
   - `satellite-prod-2094928`
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

1. If it was a transient jenkins failure, e.g. networking problems, failure to clone repos, failure to get train approval.
   - If so, `Rebuild` the job and check if it runs successfully.
   - If the re-run is successful, no further action is required.
1. Otherwise for other failures (including re-run failures), disable the Jenkins job
1. Go to [Escalation Policy](#escalation-policy)

### How to monitor for allowlist issues in a region

1. Go to [activity tracker](https://cloud.ibm.com/observe/activitytracker) in account `531277`
1. Select `Open dashboard` for the for the region you wish to view.
1. Search for `reason.reasonType:AccessDenied` in the search bar.
1. For a current role out check the date for any results returned, to see if they match up with the date the allowlist was applied
1. Expand the log entry and check the `name` field to see if it matches the bucket/bucket name, the which the allowlist was applied too
1. If the time stamp and bucket/bucket name correlate with the applied allowlist please remove the updated allowlist immediately using the steps in 'How to manually delete allowlist' section above

## Escalation Policy

1. Raise a team GitHub issue: [ICD or COS allowlist update](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=&template=icd_cos_allowlist.md&title=) to track.
1. Add information on all debug done so far.
1. Notify in [#iks_cos_allowlist](https://ibm-argonauts.slack.com/archives/C02PZ56C5AL) slack channel with GHE issue raised.
