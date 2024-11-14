---
layout: default
description: Kube CBR/Allowlist automation
service: Security
title: Kube CBR/Allowlist automation
runbook-name: "Kube CBR/Allowlist automation"
link: /compliance-update-kube-allowlists.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Kube CBR/Allowlist automation

## Overview

This runbook gives some background information on the kube CBR/Allowlist automation and how to address the associated PagerDuty incidents.

## Detailed Information

This section covers some background information on the kube CBR/Allowlist automation. If you were brought here to address a Pager Duty incident please feel free to skip straight to the [Actions required](#actions-required) section.

### Notice Q3 2024: Migration of Prod Systems to CBR

Migration is ongoing for Prod Tugboats to CBR (expected date of completion: 23rd Nov 2024), tracked in this [issue](https://github.ibm.com/alchemy-conductors/team/issues/23271)

Jenkins URLs that build and apply kube CBR

- CBR kube: <https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-kube-cbr/>

### Background

This section attempts to cover all of the necessary kube CBR/Allowlist automation background through a series of questions. If you feel that we are missing any information please open a GHE issue in the [conductors repo](https://github.ibm.com/alchemy-conductors/team/issues/new).

- What is kube?
  - Kube here stands for Kubernetes Service, and in particular this automation is only responsible for applying CBR rules for Private endpoints of IKS and Satellite Tugboats.
- What is an allowlist?
  - A list of IP addresses and subnet ranges that are allowed to access a specified resource. In this case, the resource is a IKS & Satellite Tugboat.
- What is CBR?
  - CBR (Context-Based Restrictions) give account owners and administrators the ability to define and enforce access restrictions for IBM Cloud® resources based on a rule's criteria
  - For more background see <https://github.ibm.com/alchemy-conductors/team/issues/23271>
- How is an allowlist applied to a kube instance?
  - CBR rules are applied via the [CBR API](https://github.com/IBM/platform-services-go-sdk/tree/main/contextbasedrestrictionsv1)
- What is the maximum number of allowlist entries for an tugboat?
  - 200 Subnets/IPs (For Private Endpoints)
- What does the kube allowlist automation do?
  - A scheduled Jenkins job clones the [compliance-iam-account-allowlist](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-iam-account-allowlist/), generates a current allowlist for a given `region` in a given cloud `account`. If this new allowlist differs from the existing allowlist, then existing allowlist is overwritten with the new allowlist.
- What IP's and subnets are included in the allowlist?
  - We currently have the following included:
    - [GPVPN](https://ibm.ent.box.com/notes/777691610859?s=q0tq6gd951vmubvf00l5jkbidgh9s9mt)
    - [Cloud Shell](https://cloud.ibm.com/docs/cloud-shell?topic=cloud-shell-cs-ip-ranges)
    - [Jenkins](https://github.ibm.com/TAAS/network-reports/blob/master/outbound_ip.md)
    - [Travis](https://github.ibm.com/alchemy-conductors/compliance-iam-account-allowlist/blob/master/addresses/Travis.lst)
    - Worker IPs Subnet (10.0.0.0/8)
- Where is the code repository?
  - [cbr](https://github.ibm.com/alchemy-conductors/cbr)
- How is the automation run?
  - There are multiple scheduled Jenkins jobs to update tugboat CBR rules in each region account-wise.
  - We use Resource-Groups to target the tugboats in the account that belong to IKS and Satellite Infrastructure. Each time an allowlist job is run, it will compare the existing allowlist on each Resource Group based allowlist to the newly generated allowlist. If there are differences between the two, the existing allowlist will be overwritten by the new allowlist. Otherwise the job will  move on to the resource group in that region belonging to tugboats or complete successfully.
- How are the alerts configured?
  - If a Jenkins job fails for any reason the [failure](https://github.ibm.com/alchemy-conductors/cbr/blob/main/Jenkinsfile.Kube) section of Jenkinsfile.Kube will trigger the [kube.notify.sh](https://github.ibm.com/alchemy-conductors/cbr/blob/main/jenkins/kube.notify.sh) script.
  - This notify script takes in the following parameters:
    - PagerDuty integration keys for [Allowlist-Alerts](https://ibm.pagerduty.com/service-directory/P1A9HVP) and [Allowlist-Alerts - stage](https://ibm.pagerduty.com/service-directory/P7MDC7L)
    - Dryrun variable
    - Jenkins job BUILD_URL
    - Account
  - The notify script then CURL's the PagerDuty API on the `https://events.pagerduty.com/v2/enqueue` endpoint
- When is the automation run?
  - Daily, as configured in the [trigger section of Jenkinsfile](https://github.ibm.com/alchemy-conductors/cbr/blob/main/Jenkinsfile.Kube) section of the Jenkinsfile.Kube file.
- What cloud accounts does the automation run against?
  - Argonauts Dev - Account 659397
  - Argo Staging - Account 1858147
  - Argonauts Production - Account 531277
  - Satellite Stage - Account 2146126
  - Satellite Production - Account 2094928

### Actions required
If you receive a PagerDuty alert with title `kube Allowlist - failed to update allowlist`, go to [Jenkins Job failures](#jenkins-job-failures).

If you receive a PagerDuty alert with title `kube Allowlist Entry Warning`, go to [Allowlist limit reached](#allowlist-limit-reached).

### How to manually update allowlist

1. Go to the [compliance-update-kube-cbr](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-update-kube-cbr/) Jenkins job
1. Click `Build with Parameters` button
1. Account: Select the cloud account you wish to affect. One of following
   - `argonauts-dev-659397`
   - `argo-staging-1858147`
   - `argonauts-production-531277`
   - `satellite-stage-2146126`
   - `satellite-prod-2094928`
1. Region: Select the cloud region you wish to affect.
1. Delete: Select `false` to add the newly generated allowlist(s)
1. Dry run: Select `true` to generate allowlist(s) without attempting to apply them to the tugboats
1. Click run to begin the job
1. Before the allowlist can be applied a train will be raised. For stage/prod it will be autoapproved.

### Jenkins Job failures

For failures of the jenkins job, we need to do the following:

1. If it was a transient jenkins failure, e.g. networking problems, failure to clone repos, failure to get train approval.
   - If so, `Rebuild` the job and check if it runs successfully.
   - If the re-run is successful, no further action is required.
1. Otherwise for other failures (including re-run failures), disable the Jenkins job
1. Go to [Escalation Policy](#escalation-policy)

### Allowlist limit reached

This alert usually means the allowlist (network zone) used in CBR to restrict IPs that can access the IKS & Satellite Tugboats; is reaching its limitation of number of Subnets/IPs that it can enlist. Since we're restricting the Private Endpoint of Kubernetes service, the limitation is set to 200.
Pls refer here for the limitation: https://cloud.ibm.com/docs/containers?topic=containers-cbr&interface=cli#cbr-limitations

Pls raise a issue for the India SRE Squad to take a look, follow [Escalation Policy](#escalation-policy)

## Escalation Policy
1. Raise a team GitHub issue: [kube allowlist update](https://github.ibm.com/alchemy-conductors/team/issues) to track. Add the label `SRE_India`
1. Notify @conductors-in in conductors-for-life channel
1. Add debug information done so far if any.
