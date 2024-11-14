---
layout: default
description: How to re-install csutil onto a tugboat
title: How to re-install csutil onto a tugboat
service: Conductors
runbook-name: "How to re-install csutil onto a tugboat"
tags:  armada, carrier, general, tugboat
link: /armada/tugboat_install_csutil.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

How to re-install csutil onto a tugboat

## Detailed Information

1. If re-installing on a stage/prod tugboat, then raise an ops train, wait for approval before proceeding.
   ```
   Squad: Conductors
   Title: Run bootstrap-minimal-tugboat jenkins job to reinstall csutils on prod-syd01-carrier105
   Environment: ap-south
   Details: |
    Run bootstrap-minimal-tugboat jenkins job to reinstall csutils for cluster prod-syd01-carrier105 / brf99rcs0fo5l1tjoju0.
    https://ibm.pagerduty.com/incidents/Q37HN3Q4T6SXSU
   Risk: low
   PlannedStartTime: now
   PlannedEndTime: now + 2h
   Ops: true
   BackoutPlan: NA
   ```

2. Find the clusterID of the tugboat that you want to reinstall - using one of these methods:

    - [tugboat-cluster-update-monitor](https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/maps.json) repo. 
    - DM Victory bot with `@victory tugboat-list`
    - DM Chlorine with `lookup <tugboatname>` found next to  `carrier_name` in the firing PD - i.e `lookup prod-lon04-carrier106`

3. Use the [Bootstrap-minimal-tugboat](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/bootstrap-minimal-tugboat/build?delay=0sec) Jenkins job and provide the following parameters:

    - `CLUSTER_ID` : clusterID of tugboat
    - `REGION` : one of `us-south`, `us-east`, `uk-south`, `eu-central`, `eu-fr2`, `ap-north`, `ap-south`
    - `PIPELINE_ENV` : one of `dev`, `prestage`, `stage`, `prod`, `prodfr2`  
    _For performance, the number needs to be appended. eg: `stage2`, `stage5`_
    - `KUBE_VERSION` : leave blank
    - `CUSTOM_PLAYBOOK` is `reinstall_addon_csutil.yaml`
    - `TRAIN` : Change request raised (stage/prod only)

### Reviewing job completion

If the job passes, no further actions are needed, otherwise, if the job fails, investigate why!  
_Do reach out to other SREs for help if required_

Some typical failures are:

- Clean-up of a previous install may hang or fail if nodes in the tugboat are in a `NotReady state` - fix these nodes and retry the csutil reinstall

## Related information and useful links

### Related repos and tools

The certificates used by this process are kept and managed in Secrets Manager and are no longer stored in GHE in the `cruiser-onboard-containers-kubernetes` repository.

Please see the [csutil SOS VPN Certificate management runbook](../csutil_certificate_management.html) which has details of the way Secrets Manager stores the csutil certificates and how they can be downloaded for use.

The code which drives the re-install can be found in the [tugboat-bootstrap GHE repo](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/)

## Escalation

Reach out to other SREs for assistance if you are stuck fixing an issue.  
_Whilst SRE now own csutil skills are still limited in this area!_

Slack channel [#armada-csutils](https://ibm-argonauts.slack.com/archives/GTKGH57SP) for questions. This is a private channel, reach out in #conductors-for-life if you need access.

Try posting to the [#iks-carrier-tugboats](https://ibm-argonauts.slack.com/archives/GL8SG4E2Y) (private channel). If help is needed with tugboat related issues or code related issues with the tugboat bootstrap code.  
