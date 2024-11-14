---
layout: default
title: Ghost Tagging problems
type: Informational
runbook-name: "Ghost Tagging problems"
description: "Ghost Tagging problems"
service: Conductors
link: /docs/runbooks/ghost-tagging-problems.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

A Jenkins Job with the purpose of ghost tagging of resources in IKS/Satellite/Registry IBM Cloud accounts has faced some errors.

## Detailed Information

The purpose of this [Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-GhoST-tag-resources/) is to make sure all the resources belonging to IKS/Satellite/Registry IBM Cloud accounts are properly tagged. This tool runs once every day in the morning. It goes through the accounts mentioned below and checks if all the resources have the required tags or not. If there is anything missing, the job will tag the resources appropriately. This tool is run in a jenkins job once every day. Here is the original [ticket](https://github.ibm.com/alchemy-conductors/team/issues/9762) for the job setup task.
Below are the accounts scanned by the job
```
659397 - Argonauts Dev 
1858147 - Argo Staging
278445 - Alchemy Support
1186049 - Dev Containers 
2146126 - Satellite 
1540207 - Armada Performance Prod
531277 - Argonauts Production 
2094928 - Satellite Production 
2051458 - IKS BNPP Prod
1185207 - Alchemy Productions Account
1926335 - IKS Prod VPC Classic Service
1926435 - IKS Prod VPC Classic Networks 
1984464 - IKS.Prod VPC.Network 
1457601 - registry-dev 
1687267 - registry-stage
1455723 - registry-prod
2118132 - IKS Registry Production EU-FR2
```
The criteria for tagging resources is based on configurations in the [configs](https://github.ibm.com/alchemy-conductors/compliance-GhoST-resources/tree/master/configs) folder. \
To find out more about the configuration structure and logic, see the [documentation](https://github.ibm.com/alchemy-conductors/compliance-GhoST-resources/blob/master/documentation/config.md).

## Default Rules
_**Please be aware that the single source of truth are the configuration files mentioned above, the default rules might get changed based on each account requirements.**_

 - If the account is non-prod, resources should be tagged with `fips-moderate` along with `ibm-metadata`
 - Prod accounts (non Registry accounts) can have `fips-high` and `fips-moderate` tags along with `ibm-metadata`
 - Prod accounts (non Registry accounts) that have worker machine (virtual servers) with customer data on it will have `client-metadata` tag. Example tugboat worker machines
 - In Prod accounts (531277 - Argonauts Production, 2094928 - Satellite Production, 2051458 - IKS BNPP Prod, 1185207 - Alchemy Productions Account), all the resources should be tagged with `iks-pop1` tag which is a BCDR requirement meaning `Power On Priority`
 - For Registry accounts please refer to this [issue](https://github.ibm.com/alchemy-conductors/team/issues/22453).

## Example Alert

[#71856591](https://ibm.pagerduty.com/incidents/Q1V0R3SL2WSP87) GhoST tagging job failed for 1186049/Dev Containers - moderate

## Investigation and Action:

1. Go to the jenkins [job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-GhoST-tag-resources/) console output mentioned in the PD. 
  
1. Search for the account mentioned in the PD that is having the issue and the relevant tag that is mentioned in the PD
1. Few common failure while ghost tagging are:  
   - `Error calling IMS REST API endpoint` \
      There is a known issue with resource deletion events not being fully reliable between IMS and GhoST, resulting in a potential one to two day delay in the status update for certain resources. For example, a resource may be deleted, but its status has not yet been updated in GhoST. This inconsistency can cause the IMS API to throw an error when our automation attempts to tag a deleted resource. 

      Typically, this affects only a small number of resources. If you see 5XX and `retry limit reached` error for a specific resource, first verify whether the resource is available. If it is not, this likely indicates a delay in database synchronization between IMS and GhoST. You can disregard this issue for now, but note that this behavior should not persist for more than two days. If it does, please escalate the issue as outlined in the following section. \
      There is a retry in place if 503 errors are returned by ghost tagging API as it might be related to rate limiting. Only escalade if you see `retry limit reached`
      Any other non 2XX http codes returned might indicate an issue with Ghost services. \
      **Escalation**: Please post the error in `#global-search-tagging` channel by specifying the `x-request-id` visible on the error log and escalate to the team.
   - `The provided auth token does not have permissions to perform the request` \
      This error happens when the API Key used by the job does not have sufficient permission to do the tagging. This need to be fixed by creating the right permissions for the api key.
      _TIP: You may need to raise a PR for the terraform config repo https://github.ibm.com/argonauts-access/access-group-config_ . _Example [PR](https://github.ibm.com/argonauts-access/access-group-config/pull/122/files) Here is also [documentation](https://cloud.ibm.com/docs/account?topic=account-access&interface=ui) related to permission for tagging resources_
   - `Error: Provided API key could not be found, Code: 400` \
      This error happens when the wrong API key is being used in the Jenkins job. Make sure the jenkins credentials being used in the job (Jenkinsfile) is the correct one. The api key should also be present in the account. In case if it is not found in the account, this error will appear. It is suggested to create a new api key with the proper permissions and update the [Jenkinsfile](https://github.ibm.com/alchemy-conductors/compliance-GhoST-resources/blob/master/Jenkinsfile) used by the job
1. Once the issue is addressed, in the next schedule(the next day) of the job the error should be resolved. \
   _TIP: The job can also be run manually for the faulty account(s)_ \
   **Manual Run**
    1. Set `ALL` to false (uncheck)
    1. Set `DRY_RUN` to false (uncheck)
    <img width="640" alt="build" src="https://media.github.ibm.com/user/432455/files/7e12d184-e6c0-4c8e-ae16-277e9d7670b4">
    1. Build
    1. The job will pause in `tagging resources` phase, hover over the phase, this action will open a pop-up asking you to chose from the list of accounts
    1. Chose the target account and `Proceed` \
    <img width="640" alt="select_account" src="https://media.github.ibm.com/user/432455/files/033f468f-f97b-45fc-bdba-859fbedb306c">

1. Resolve the PD.

## Escalation Policy

If unable to resolve the issues above using the steps documented, then reach out to the #conductors-for-life channel in slack for team help.

## Automation

1. Jenkins job available to view [here](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-GhoST-tag-resources/)

