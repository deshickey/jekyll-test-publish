---
layout: default
title: Dreadnought Train Management
type: Informational
runbook-name: Dreadnought Train Management
description: How to manage trains for Dreadnought
category: Dreadnought
service: dreadnought
tags: dreadnought train, train, dreadnought change management
link: /dreadnought/dn-change-trains.html
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

## Overview

This document describes the process to manage all changes via trains.  The process allows the SRE team to control when a change is approved and may proceed in any Dreadnought environment.

Trains are a link between a change request in ServiceNow back to the approval flow by the SRE team including automatic and manual approvals.  The change request includes metadata for the change.  Here is an example of a [change request](https://watson.service-now.com/nav_to.do?uri=change_request.do?sys_id=bd6b0e4693f09a103a9ab4121bba10c2%26sysparm_view=Default%3Dview) created by a train created in the channel.

## Detailed Information

### Train Station (channel)

Channel: [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN)

### Creating a Train

Execute `@Fat-Controller train template` to get the current templates.

- Values to use for Dreadnought Operations:
  - Squad: dreadnought_sre
  - ConfigurationItem: dreadnought

Dreadnought Ops Template (Sept 2024)
```
Squad:              dreadnought_sre
Title:              Run <command> on <hostnames>
ConfigurationItem:  dreadnought
Environment:        <Region list ap-north ap-south br-sao ca-tor eu-central eu-es eu-fr2 jp-osa uk-south us-east us-south>
Details: |
  <specifics of the planned operational work>
ExceptionJustification: |
  'Justification for an exception: link to pre-approval slack thread/issue, link to CIE if this fixes an outage, etc.'
Risk:               <high|med|low>
OutageDuration:     ""
TestsPassed:        false
TestsEnvironment:   ""
BackoutPlan:        <if the change goes bad how will it be undone>
StageDeployDate:    ""
PlannedStartTime:   <YYYY-MM-DD HH:MM ZZZ|ZZZZ or now + 30m or asap>
PlannedEndTime:     <YYYY-MM-DD HH:MM ZZZ|ZZZZ or start + 30m>
Ops:                true
FixOnly:            false
SecurityOnly:       false
CustomerImpact:     <critical|high|moderate|low|no_impact>
PipelineName:       <name of deployment pipeline>
PipelineVersion:    <version of deployment pipeline>
ServiceEnvironment: <pre_prod|production>
ServiceEnvironmentDetail: |
  <describe briefly what the environment looks like> [Optional; only when ServiceEnvironment = pre_prod]
DeploymentImpact: |
  <small,large - small is e.g. a single microservice update, or small number of lines of code; large is everything else>
DeploymentMethod:   <manual,automated>
```

Sample Ops Template:
```
Squad: dreadnought_sre
Service: dreadnought_sre
Title: De-provisioning on DN bastion instances in production
Environment: us-south
TestsEnvironment: stage
Details: Detach clusters from Bastion instances and remove Bastion Teleport deployment include the cluster and associated resources
Risk: low
PlannedStartTime: asap
PlannedEndTime: start + 1h
BackoutPlan: Re-provision Bastion
Ops: true
ServiceEnvironment: production
ServiceEnvironmentDetail: Dreadnought production
PipelineName: manual
PipelineVersion: 0.1
CustomerImpact: no_impact
DeploymentImpact: small
DeploymentMethod: manual
```

### Trains with Outstanding Approvals
In the [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN) channel execute the command `oa` or `outstanding approvals` to get the list of approvals requiring approvals.

To approve all the trains, you can go into the thread and copy all the change requests in the `List` and execute `approve <paste list>`.

To reject trains, you can do the same as the approve but change the command to `reject <paste list> comment: <a comment>`

To reevaluate a train, you can run `reevaluate <change ID> [<change ID>]` to check if the train can now be auto approved.  This is typically following a CIE or incident that would block the change.

### Process the Train
Connect to the Fat-Controller Application in Slack.  You can do this by clicking on the `Fat-Controller` in the [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN) channel.

#### Start a Train
- Once a change is approved you can start the train.  To do so run the command from the `Fat-Controller` app in slack:
  - `start train <change ID>`

#### Abort a Train
- You can abort a train either before or after it is approved or even started. To do so run the command from the `Fat-Controller` app in slack:
  - `abort train <change ID> comment: <text>`

#### Complete a Train
- Once the change is completed you can complete the train. To do so run the command from the `Fat-Controller` app in slack:
  - `complete train <change ID>`

## Further Information

### Dreadnought Prod Trains Channels
- [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN) - Create and manage trains.
- [#dn-sre-prod-trains-autoapprovals](https://ibm.enterprise.slack.com/archives/C079TBP38LX) - Shows trains created and approval status.
- [dn-sre-trains-approvals (private and restricted)](https://ibm.enterprise.slack.com/archives/C07A14FGLH4) - Restricted
