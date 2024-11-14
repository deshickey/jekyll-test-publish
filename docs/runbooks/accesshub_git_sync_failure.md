---
layout: default
title: AccessHub/GHE permission synchronization failure
type: Informational
runbook-name: "AccessHub/GHE permission synchronization failure"
description: "AccessHub/GHE permission synchronization failure"
service: Conductors
link: /docs/runbooks/accesshub_git_sync_failure.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

A Jenkins Job that runs the tool to sync AccessHub/GHE permissions has failed. 

## Detailed Information

The purpose of this tool is to sync AccessHub permissions (that are stored in Git due to limitations of AccessHub) to multiple backend systems. (Bluemix, Softlayer, Bluegroup and Git). This tool is run in a jenkins job every 6 hours.

## Example Alert

https://ibm.pagerduty.com/incidents/PBV0MX3

## Investigation and Action:

1. Go to [GHE reports repository](https://github.ibm.com/argonauts-access/reports) and find latest report.  
   _Latest report are usually at the bottom._
1. Check for error at the bottom of the report.
1. Two types of common failure occure with this job.  
   - GHE rate limit exceed  
      Example Error:  
      ```
      Error Getting Team User list: No mail adddress found for user 0xc000516af0:GET https://github.ibm.com/api/v3/users/krglosse: 403 API rate limit of 5000 still exceeded until 2020-08-27 12:41:18 +0000 UTC, not making remote request. [rate reset in 30m51s]
      ```
      Rerun the job with same parameters when the API rate limit reset.  
      _TIP: The time of reset is in the error._
   - Softlayer API error  
      Example Error:
      ```
      ERROR - failed to process auth systems: SoftLayer_Exception: Failed to exchange token (HTTP 500)
      ```
      Rerun the job with same parameters after some time. 
   - If job runs successfully, then Resolve the PD.
1. If the error is not as described above or the job didn't run successfully, then create a team ticket with the title `Security - AccessHub access control failed` in our [team repo](https://github.ibm.com/alchemy-conductors/team/issues/new). Add the link to the jenkins job from the PD in the comment. Add the label `Security`.
1. Resolve the PD.

## Escalation Policy

If unable to resolve the issues above using the steps documented, and this is a production environment, then reach out to the #conductors-for-life channel in slack for team help.

## Automation

1. Jenkins job available to view [here](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-argonauts-access-reconcile-iks/)
