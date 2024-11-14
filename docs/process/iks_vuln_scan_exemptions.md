---
layout: default
title: IKS Vulnerability Scan Exemptions
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# IKS Vulnerability Scan Exemptions Process

## Purpose

We run regular automated Vulnerability Advisor scans of the container images for the IBM Cloud Kubernetes Service (IKS) control plane and the cruisers clusters. In some cases there will be vulnerability findings which need exemptions, for example:

- If an image is found to be running on a carrier that is no longer supported as we have deprecated the Kubernetes Version. This scenario is covered by RSK100019065.

- If an image is found to be running on a carrier and we have rolled out a later Armada-master BOM such that only those that have "opted out" have not been updated.

- If an image has already been granted an exemption, newly identified vulnerabiliites for that image need exemption as part of regular on-going maintenance.

There may be other reasons for needing an exemption; this is not an exhaustive list. All requests opened under this process must clearly state the reason for the request.

This process describes how these exemptions are managed.

## Scope

This policy applies to the infrastructure required to support the development and operations of IKS.

## Process

### Roles

- IKS development squads opens the request.
- IKS management approve each request.
- The Security Compliance Squad processes each approved request.
- The SRE squad manages the change requests used to deploy approved exemptions.
- Regular (on-going) maintenance of image/CVE exemptions

### Important: Due Dates

This process must be executed in a timely manner, in accordance with IBM security policies.

Vulnerability Advisor exemptions relate to specific container images with specific vulnerabilities (CVEs).

Each vulnerability has a severity rating which is determined by the vuln scan tool based on the CVSS score of the vulnerability: e.g. High, Medium or Low. The due date to resolve the vulnerability is determined by [ITSS](https://pages.github.ibm.com/it-standards/main/2015/01/24/itss.html) section 6.7.3 (internet-facing machines) based on the vulnerability severity rating.

For example, image *armada-master/hyperkube-amd64:armada_1.10-303-v1.10.13-base* is subject to vulnerability *CVE-2019-3462* which has a CVSS score of 8.1, which is a High severity issue (as shown in the summary issue [here](https://github.ibm.com/alchemy-containers/compliance-vuln-scan-carrier/issues/137)). Per ITSS section 6.7.3, the internet-facing target for High severity vulnerabilities is within 7 days, so the due date for resolution of the related issues is 7 days from the issue being raised.

How to resolve a vulnerability depends on the issue, but could include:

- producing a new container image with the vulnerability fix

- marking the container image as exempt from VA reporting on the basis that it has been superseded by a newer container image with the fix (i.e. following this process)

- requesting a formal risk to extend the due date because more time is required, e.g. due to technical issues

Note that there is a lead time of at least 2 days to obtain an exemption: when an exemption is needed, you must request it in good time before the due date. Missing a due date is likely to cause an audit failure, and could lead to loss of security certifications, reduced customer satisfaction, revenue loss and significant audit re-testing costs.

### Actioning a first time image exemption

If an exemption request is for an image that is not currently exempted...

1. An IKS employee opens an exemption request [here](https://github.ibm.com/alchemy-conductors/security/issues/new/choose), filling out the template. The resulting issue must be a [security issue](https://github.ibm.com/alchemy-conductors/security/issues) with the `Compliance` and `Risk Request` labels.

    - Related images may be grouped together provided they need an exemption for the same reason, for example if several old unsupported versions of armada-master/hyperkube-amd64 have the same set of vulnerabilities then they can be grouped into a single request issue. Likewise, when the same image has been pushed into different regional registries then all of the copies of the image can be grouped into a single issue.

    - To help manage the backlog, remember to include the string `Due Date: YYYY-MM-DD` in the issue text, replacing `YYYY-MM-DD` with the ISO 8601 due date.

2. An IKS manager updates the issue to indicate their approval for the exemption. This step can be skipped if the request was opened by an IKS manager; a request created by a manager is implicitly considered to be approved.

3. A member of the Security Compliance Squad ("the assignee") self-assigns the issue and reviews it. If the assignee has any questions or concerns they will discuss those with the originator before proceeding to the next step.

4. The assignee compiles a list of image/CVE pairs from the request and updates the [master CSV file](https://github.ibm.com/alchemy-conductors/compliance-exceptions/blob/master/vulnscan-exemptions/exemptions.csv) in the private compliance-exceptions repository. The changes must be made using a Pull Request.

5. Assignee logs in to IBM Cloud, e.g. `ibmcloud login --sso`: account `Alchemy Production's Account (cc7530878c499d74ad77f31c918c626e) <-> 1185207`.
   
6. Runs the [add script](https://github.ibm.com/alchemy-conductors/compliance-exceptions/blob/master/vulnscan-exemptions/add.sh) to add the new exemptions:  
   `./add.sh -f new_exemptions_file.csv 2>&1 | tee new_exemptions_logfile.log` 
   
   NOTE: If the `new_exemptions_file.csv` has been created on Windows, first use `dos2unix new_exemptions_file.csv` to correct the line endings in the file, or all attempts to add will fail.

7. After the additions are complete, the assignee:
   1. Confirms there are no failures in the `new_exemptions_logfile.log`. If there are these should be re-run.
   2. Closes the request issue to indicate that the exemptions were added successfully and attaches the log file created from running the command as proof.

8. The requester adds the `vuln:addressed` label to the vulnscan tracking issues that relate to the exemption to record that action has been taken (e.g. for Carriers see [query](https://github.ibm.com/alchemy-containers/compliance-vuln-scan-carrier/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3Avulnerability)).

9. After the exemptions are deployed, the next run of the vulnerability scan tool automatically will pick up the changes. If fast resolution is required, the IKS employee who requested the exemption should manually trigger a re-run of the vuln scan tool.

=======
### Example Change Request

Here is an example change request in fat-controller bot template format to seek approval to deploy new approved exemptions:
```
Squad: Security Compliance Squad
Title: Promote approved hyperkube VA exemptions into production
Environment: ap-north ap-south eu-central uk-south us-east us-south 
Details: |
  Our Armada container image VA scans need to exclude certain findings for known issues where the
  container image is unsupported or an exception exists. Adding VA exemptions for the known issues
  allows us to see which remaining issues need further action.

  ADD REQUEST ISSUE URL HERE

Risk: Low
PlannedStartTime: now+30m
PlannedEndTime: now+2h
Ops: true
BackoutPlan: In the event of a problem, the exemptions can easily be removed again.
```

### Regular (on-going) maintenance of vulnerability exemptions

When an image has already gone through the above review/approval steps and been added to the [master CSV file](https://github.ibm.com/alchemy-conductors/compliance-exceptions/blob/master/vulnscan-exemptions/exemptions.csv) for the first time, new vulnerabilities (i.e. CVEs) applicable to that image do not need go through the review/approval process.

Automated regular maintenance of vulnerability exemptions is
- documented in the [vulnscan-exemptions Readme](https://github.ibm.com/alchemy-conductors/compliance-exceptions/tree/master/vulnscan-exemptions)
- implemented using the [compliance-vuln-exempt-update](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-vuln-exempt-update/) Jenkins job

The Jenkins job runs twice daily processing the images listed in the [master CSV file](https://github.ibm.com/alchemy-conductors/compliance-exceptions/blob/master/vulnscan-exemptions/exemptions.csv).  It will check for new vulnerabilities and then add those to the master CSV file.  The images are then updated exempting the new vulnerabilities. 

See the [vulnscan-exemptions Readme](https://github.ibm.com/alchemy-conductors/compliance-exceptions/tree/master/vulnscan-exemptions) for more detail.

## Process review

The process will be reviewed by Security Compliance squad management at least annually.

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
