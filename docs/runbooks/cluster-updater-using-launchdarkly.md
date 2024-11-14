---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Lock cluster deployments in LaunchDarkly"
type: Operations
runbook-name: "Lock cluster deployments in LaunchDarkly"
description: "Lock cluster deployments in LaunchDarkly without cluster-updater enforcing the old version."
service: cluster-updater
tags: razee, armada, launchdarkly
link: cluster-updater-using-launchdarkly.html
failure: ""
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Use this runbook when an emergency fix needs to be rolled out and the normal CI/CD pipeline
cannot be used.
The cluster must be locked in LaunchDarkly before making any manual changes.

If the cluster is not locked in LaunchDarkly then cluster-updater will
override any manual changes and the current configured version in LaunchDarkly is reapplied to the cluster.

## Detailed Information

This applies to any situation in which there is an issue on a cluster that needs to be fixed and the CI/CD process must be bypassed until the proper solution can be coded and deployed.

You must be a `writer` on LaunchDarkly to be able to complete the procedure.
[How to request access to LaunchDarkly](./launchdarkly-access.html).

The first time you access LaunchDarkly use the link [https://ibm.biz/armada-ld](https://ibm.biz/armada-ld) which will create your user in LaunchDarkly.

## Detailed Procedure

1. Ensure a prod/stage train has been raised and approved before making any changes.  
    Sample train template:
    ```
    Squad: conductors
    Title: lock cluster-updater on microservices tugboat $TUGBOAT_NAME
    Environment: $REGION
    Details: |
      Set the 'cluster-lock' feature flag to true to disable cluster-updater-applied changes to the tugboat. 
      This is needed to prevent mitigation actions for CIE $INC_NUMBER from being reverted.
      cluster-updater will be scaled back up once the build with the permanent fix is promoted to this region.
    Risk: low
    PlannedStartTime: now
    PlannedEndTime: now + 30m
    Ops: true
    BackoutPlan: revert feature flag change
    ```
1. Find the carrier in the list of [LaunchDarkly contexts](https://app.launchdarkly.com/projects/default/contexts) and view the details for the carrier. eg. [dev-dal10-carrier104](https://app.launchdarkly.com/projects/default/contexts/kinds/user/instances/bm2170gd060v5sou9f30)
    - tip: when searching for a cluster, type the region shorthand followed by a space and the type. eg. `dal09 carrier0`
1. Update the `cluster-lock` feature flag
    - DM `@Fat-Controller` to start your train
    - Type `cluster-lock` in the "Expected flag variations" search box
    - Change the `cluster-lock` flag variation to `true`
    - Click the "Review and save" button
    - Paste the change request number and description into the "Comment" field
    - Click "Save changes"
    - DM `@Fat-Controller` to complete your train
1. Manually adjust the necessary configuration on the carrier using kubectl commands as appropriate
    - Configuration changes will require a restart of the microservices pod. Please work with the dev squad who have requested the changes to determine if a restart is required.
1. Submit a PR with the necessary changes to the necessary repo(s)
1. Once the PR is merged and built, roll the version to the impacted carrier/region
1. Raise and get approval for a train to unlock the cluster.  
    Sample train template:
    ```
    Squad: conductors
    Title: unlock cluster-updater on microservices tugboat $TUGBOAT_NAME
    Environment: $REGION
    Details: |
      Set the 'cluster-lock' feature flag to false to re-enable cluster-updater now that
      the permanent fix for CIE $INC_NUMBER has been promoted to the region.
    Risk: low
    PlannedStartTime: now
    PlannedEndTime: now + 30m
    Ops: true
    BackoutPlan: revert feature flag change
    ```
1. Follow the "Update" steps, as before, to set the `cluster-lock` flag variation to `false`

### Escalation

Contact the razee squad (#razee @razee-pipeline) for help.
Reassign the PD incident to `Alchemy - Containers Tribe - Pipeline`
