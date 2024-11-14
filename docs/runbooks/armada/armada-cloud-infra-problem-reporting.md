---
layout: default
title: Reporting Likely Problems in Pre-production or Production Cloud Infrastructure
runbook-name: "Reporting Likely Problems in Pre-production or Production Cloud Infrastructure"
tags: cloud infrastructure problems issues report
description: "Reporting Likely Problems in Pre-production or Production Cloud Infrastructure"
service: armada
link: /armada/armada-cloud-infra-problem-reporting.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes the process to follow when IKS/ROKS SREs or developers encounter a problem in our pre-production or production environment and think that it is a problem with the cloud infrastructure.  This process describes how to request that someone on those teams investigate the problem.

Note that if an IKS/ROKS customer (or several) have reported it already in a customer ticket, then follow the process here: [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-customer-ticket-process-for-infra-issues.html](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-customer-ticket-process-for-infra-issues.html)

## VPC Cloud Infrastructure Significant Issues

The VPC infrastructure teams keep lists of the top issues they are working on.  If you are troubleshooting an issue in VPC, these links might be useful:

* Top5 and Top15 Issue Lists: [https://github.ibm.com/Zack-Grossbart/release-timelines/tree/master/top5#top5-dashboards](https://github.ibm.com/Zack-Grossbart/release-timelines/tree/master/top5#top5-dashboards)

* Description of the Top5 and Top15 lists, and the process used to add issues to them: [https://github.ibm.com/cloudlab/srb/blob/master/architecture/release/top5.md](https://github.ibm.com/cloudlab/srb/blob/master/architecture/release/top5.md)

## VPC Cloud Operations Dashboard (Requires GlobalProtect VPN Connection)

1. Prod environment dashboard:  [https://opsdashboard.w3.cloud.ibm.com/ops](https://opsdashboard.w3.cloud.ibm.com/ops)
2. Stage environment dashboard: [https://staging.opsdashboard.w3.cloud.ibm.com/ops/](https://staging.opsdashboard.w3.cloud.ibm.com/ops/)

## Overall IBM Cloud Dashboards

1. Cloud status page: [https://cloud.ibm.com/status](https://cloud.ibm.com/status)
2. CIE dashboard: [https://watson.service-now.com/x_ibmwc_cie_pub_app#!/dashboard](https://watson.service-now.com/x_ibmwc_cie_pub_app#!/dashboard)
3. Smoke dashboard: [https://9.114.87.41:8300/summary/smoke-prod/graphs/?runs=12](https://9.114.87.41:8300/summary/smoke-prod/graphs/?runs=12)
4. Availability dashboard: [https://performance.w3.cloud.ibm.com/grafana/d/availability/availability-dashboard?orgId=1&from=now-6h&to=now&var-Interval=5m&refresh=5m](https://performance.w3.cloud.ibm.com/grafana/d/availability/availability-dashboard?orgId=1&from=now-6h&to=now&var-Interval=5m&refresh=5m)

## Detailed Information

## Reporting a Problem with Resources in IKS/ROKS Production Accounts

For problems with a resource in one of our own IKS/ROKS/Satellite accounts (for instance if our tugboat workers in a given VLAN all go offline, we can't provision tugboat workers in a certain region), or we are having problems connecting to IAM or other services, the following runbook should be used: [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster/cluster-squad-error-temporary-connection-problems.html#services](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/cluster/cluster-squad-error-temporary-connection-problems.html#services)

## Reporting a Problem with Customer VPC Cluster Workers Stuck Provisioning or Deleting

Follow this runbook: [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-vpc-raise-support-ticket-for-worker.html](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-vpc-raise-support-ticket-for-worker.html)

## Reporting a General Problem in the VPC Cloud Infrastructure

For more general problems that aren't specific to our own IKS/ROKS resources, for instance if our test clusters are unable to create LBaaS instances in a certain production region, or if portable VLANs can't be successfully ordered for test clusters in stage, use the following process.

NOTE: We want to get to the point where we are creating support tickets using either the functional accounts that our testing is using (for test failures), or the shared production account if we have to recreate it ourselves manually.  However right now developers (and maybe SREs) don't have access to create tickets from those accounts.  Once we get that resolved, we should use those accounts to recreate and to create support tickets.

### Production VPC Problems

1. Try to recreate the problem using our production VPC network account
    * `IKS VPC NextGen Development (bdd96d55c7f54798a6b9a1e1bedec37c)`
    * Access can be requested via AccessHub
        * IKS Access role `ROLE_IKS_Developer_member`
2. If you are on one of the IKS network squads and the problem is not urgent, create a GHE issue in https://github.ibm.com/alchemy-containers/iks-vpc-defect-triage.  Skip step 3 below and put as much information as you can gather from step 4 into the GHE.  Eventually there will be a template to fill out, but that is not ready yet.  Then skip the rest of the steps related to the incident as well.
3. Create a production support ticket here: [https://cloud.ibm.com/unifiedsupport/cases/form](https://cloud.ibm.com/unifiedsupport/cases/form).  Make sure you are in account `IKS VPC NextGen Development` and choose:
    * Topic:
        * `Cloud Load Balancer` for VPC Load Balancer issues
        * `Direct Link` for Directlink issues
        * `Virtual Private Cloud` for everything else
    * Subtopic:
        * `LBaaS for VPC` if it is a Load Balancer issue
        * `Direct Link with IKS` or `Other` for Directlink issues depending on whether it is specific to IKS/ROKS
        * `Provisioning` if it is related to VPC worker node issues
        * `Networking` for VPC network issues
        * `VPN` if is related to a VPC VPN
        * Or one of the other subtopics if those fit better
    * Subject: Short description of the problem
4. For the description, provide as much detail as you can about the problem, including:
    * trace id, reference id, or error id if applicable
    * resource id
        * If a problem with a VPC cluster worker, provide the worker hostname, private IP, zone,instance-id, and VPC Subnet (can get from kubectl describe node which is available in get-master-info)
        * If a problem with LBaaS, provide the LBaaS ID and name, and the VPC ID the LBaaS was created in
    * Account id of the account where this problem happened
    * Detailed description of the issue
    * Steps to replicate the issue
    * Screenshots/ logs of errors
    * How were you interacting with the system (cli, ui, api)?
    * Time frame the issue was detected.
    * Region/zone
    * Has it ever worked or is it the first time seeing this issue?
    * How urgent it is?
5. If you created a support ticket (and not a GHE issue), post the ticket ID in the appropriate slack channel
    * For VCP LBaaS issues, post in the [#ibmcloud-lbaas](https://ibm-cloudplatform.slack.com/archives/C4YHGMBC7) and [#ipops-cases](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD) channels
    * For VCP VPN issues, post in the [#ibmcloud-vpn](https://ibm-cloudplatform.slack.com/archives/CHP8X9FML) channel
    * For VPC Directlink issues, post in the [#hybrid-nw-escalations](https://ibm-cloudplatform.slack.com/archives/CKMMAEBDK) channel
    * For Other VPC issues, post in the [#ipops-production](https://ibm-cloudplatform.slack.com/archives/CQWH66SBY) channel

### Stage VPC Problems

1. If the problem is NOT due to a failure in an automated test, try to recreate the problem using our shared VPC account `IKS.Stage.VPC.Network TEST (1152aa1c1ec54274ac42b8ad8507c90c)`.   Otherwise just continue on (because the automated tests in stage already do use the shared VPC account)
2. If you are on one of the IKS network squads and the problem is not urgent, create a GHE issue in https://github.ibm.com/alchemy-containers/iks-vpc-defect-triage.  Skip step 3 below and put as much information as you can gather from step 4 into the GHE.  Eventually there will be a template to fill out, but that is not ready yet.  Then skip the rest of the steps related to the incident as well.
3. Create an Incident using the link here: [https://watson.service-now.com/nav_to.do?uri=%2Fincident.do%3Fsys_id%3D-1%26sysparm_query%3Dactive%3Dtrue%26sysparm_stack%3Dincident_list.do%3Fsysparm_query%3Dactive%3Dtrue](https://watson.service-now.com/nav_to.do?uri=%2Fincident.do%3Fsys_id%3D-1%26sysparm_query%3Dactive%3Dtrue%26sysparm_stack%3Dincident_list.do%3Fsysparm_query%3Dactive%3Dtrue) and set the following values.  NOTE: if you can't set some of the values listed below, you will need to request access using the instructions in the **Request Access to Containers Assignment Group in ServiceNow** section below.  If you have any questions, you can look at this example: [INC5015664](https://watson.service-now.com/nav_to.do?uri=%2Fincident.do%3Fsys_id%3Dde952edc475785101b4482b5536d43a9%26sysparm_record_target%3Dincident%26sysparm_record_row%3D1%26sysparm_record_rows%3D1%26sysparm_record_list%3Dactive%253Dtrue%255EnumberSTARTSWITHINC5015664%255Ecmdb_ci.u_tribe.u_segment.u_type%253Dcloud%255EORDERBYDESCnumber)
    * Severity: Use your best judgement
    * Detection Source: "IBM Staff", "Monitoring Tool", or "Customer" depending on who/what detected the problem
    * Affected Activity: You can click on the Affected Activity title/heading link to get a description of each.  Choose the one that best matches the problem you are seeing
    * Configuration Item and Assignment Group
        * For VPC LBaaS issues:
            * CI: `is-load-balancer`
            * AG: `is-load-balancer`
        * For VPC VPN issues:
            * CI: `is-vpn`
            * AG: `VPC VPN`
        * For VPC Directlink issues:
            * CI: `directlink`
            * AG: `Hybrid Networking - Dev DirectLink2.0`
        * For other VPC issues:
            * CI: `is-vpc`
            * AG: `is-ng-vpc`
    * Environment, click the padlock icon to open it up, and choose `IBM Yellow Staging 0 (YS0) STAGING`
    * Short Description: Use "IKS-Incident: " and then a short summary of the problem, for example: `IKS-Incident: VSI failed to get network access after successfully provisioning`
    * Fill out any of the other fields if you have useful information to put there
4. For Description, provide as much detail as you can about the problem, including:
    * trace id, reference id, or error id if applicable
    * resource id
        * If a problem with a VPC cluster worker, provide the worker hostname, private IP, zone,instance-id, and VPC Subnet (can get from kubectl describe node which is available in get-master-info)
        * If a problem with LBaaS, provide the LBaaS ID and name, and the VPC ID the LBaaS was created in
    * Account id of the account where this problem happened
    * Detailed description of the issue
    * Steps to replicate the issue
    * Screenshots/ logs of errors (it looks like you can click the paperclip icon in the upper right to attach screenshots and other relevant files)
    * How were you interacting with the system (cli, ui, api)?
    * Time frame the issue was detected
    * Region/zone
    * Has it ever worked or is it the first time seeing this issue?
    * How urgent it is?
5. To create the Incident, click Submit in the upper right and copy the created incident number.  It will be something like "INC4907902"
6. If you created an Incident, post the Incident number in the appropriate slack channel
    * For VCP LBaaS issues, post in the [#ibmcloud-lbaas](https://ibm-cloudplatform.slack.com/archives/C4YHGMBC7) and [#ipops-staging](https://ibm-cloudplatform.slack.com/archives/CQGSRSGV9) channels
    * For VCP VPN issues, post in the [#ibmcloud-vpn](https://ibm-cloudplatform.slack.com/archives/CHP8X9FML) channel
    * For VPC Directlink issues, post in the [#hybrid-nw-escalations](https://ibm-cloudplatform.slack.com/archives/CKMMAEBDK) channel
    * For Other VPC issues, post in the [#ipops-staging](https://ibm-cloudplatform.slack.com/archives/CQGSRSGV9) channel

### Production Classic Problems

If it is related to our own control plane resources, refer to `Reporting a Problem with Resources in IKS/ROKS Production Accounts` above.  Otherwise we need a ServiceNow ticket that one of our customers has created, and then we can post that in the [#sl-compute-sre](https://ibm-cloudplatform.slack.com/archives/C5WRPN2HE) slack channel as a starting point.

### Stage Classic Problems

1. Try to recreate the problem using our shared Classic account `Alchemy Staging's Account (43c2cf73620ae552587a136bd0d6d6a0)`.
2. Create an Incident using the link here: [https://watson.service-now.com/nav_to.do?uri=%2Fincident.do%3Fsys_id%3D-1%26sysparm_query%3Dactive%3Dtrue%26sysparm_stack%3Dincident_list.do%3Fsysparm_query%3Dactive%3Dtrue](https://watson.service-now.com/nav_to.do?uri=%2Fincident.do%3Fsys_id%3D-1%26sysparm_query%3Dactive%3Dtrue%26sysparm_stack%3Dincident_list.do%3Fsysparm_query%3Dactive%3Dtrue) and set the following values.  NOTE: if you can't set some of the values listed below, you will need to request access using the instructions in the **Request Access to Containers Assignment Group in ServiceNow** section below.
    * Severity: Use your best judgement
    * Detection Source: "IBM Staff", "Monitoring Tool", or "Customer" depending on who/what detected the problem
    * Affected Activity: You can click on the Affected Activity title/heading link to get a description of each.  Choose the one that best matches the problem you are seeing
    * Configuration Item: `iaas-compute-general`, `iaas-compute-provisioning`, `iam`, or another that matches the problem you are reporting
    * Assignment Group: `iaas-sre` or another one that better matches what you are reporting
    * Environment, click the padlock icon to open it up, and choose `IBM Yellow Staging 0 (YS0) STAGING`
    * Short Description: Use "IKS-Incident: " and then a short summary of the problem, for example: `IKS-Incident: VSI failed to get network access after successfully provisioning`
    * Fill out any of the other fields if you have useful information to put there
3. For Description, provide as much detail as you can about the problem, including:
    * trace id, reference id, or error id if applicable
    * If related to a specific classic cluster worker, include the region, zone, worker-id, private IP privateVLAN, public IP and publicVLAN (if node has a public IP).  All this is available in `kubectl describe node` in get-master-info
    * Account id of the account where this problem happened
    * Detailed description of the issue
    * Steps to replicate the issue
    * Screenshots/ logs of errors (it looks like you can click the paperclip icon in the upper right to attach screenshots and other relevant files)
    * How were you interacting with the system (cli, ui, api)?
    * Time frame the issue was detected.
    * Region/zone
    * Has it ever worked or is it the first time seeing this issue?
    * How urgent it is?
4. Click Submit in the upper right and copy the created incident number.  It will be something like "INC4907902"
5. Post the Incident number in the [#sl-compute-sre](https://ibm-cloudplatform.slack.com/archives/C5WRPN2HE) slack channel


## Request Access to Containers Assignment Group in ServiceNow

Use these steps to request access to create an Incident as described above, go to: [https://watson.service-now.com/ess_portal?id=sc_cat_item&sys_id=9a1240ebdbcdef0472583c00ad9619ad](https://watson.service-now.com/ess_portal?id=sc_cat_item&sys_id=9a1240ebdbcdef0472583c00ad9619ad) and specify:

* Person Needing Access: "For Myself"
* Access Type: "Join a Licensed Assignment Group (requests will be routed to the group manager)"
* Cloud Role: "Person supporting/operating Cloud Services"
* Assignment group to join: "Containers Dev" or "Containers SRE" depending on your role
* Business Justification: "Member of IKS team that needs to be able to generate incidents for alerting teams of issues"

Click "Submit" and it will go to Ralph Bateman for approval on the IKS side.  Once he approves it will go to someone on the ServiceNow side for approval, and then you will have access.  We worked with michael.gardner@ibm.com and kylie.c.gallagher@ibm.com but were not able to come up with a way to request access for the whole tribe at once, so we will have to request access individually.

## To View Specific Incidents

You should get E-mails when your Incident is updated, but if you need to look one up, go to [https://watson.service-now.com/nav_to.do?uri=%2Fincident_list.do%3Fsysparm_query%3Dactive%253Dtrue%26sysparm_first_row%3D1%26sysparm_view%3D%26sysparm_choice_query_raw%3D%26sysparm_list_header_search%3Dtrue](https://watson.service-now.com/nav_to.do?uri=%2Fincident_list.do%3Fsysparm_query%3Dactive%253Dtrue%26sysparm_first_row%3D1%26sysparm_view%3D%26sysparm_choice_query_raw%3D%26sysparm_list_header_search%3Dtrue) and put the incident name in the "Number" search box column header (for instance "INC4907902").


## Further Information
Please contact Brad Behle or Lewis Evans if you have questions or feedback about this process
