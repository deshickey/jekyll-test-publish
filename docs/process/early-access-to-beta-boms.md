---
layout: default
title: Early access to beta BOMs
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Overview

IBM Cloud Kubernetes Service may provide early access to beta releases and
associated features packaged via a bill-of-materials (BOM). Such BOMs are
subject to special terms and conditions. Providing early access to IBMers or
customers must follow the process outlined here.

## Terms and Conditions

Providing access to beta BOMs is done at the cluster owner level. Therefore,
the owner will be responsible for the following:

- Applying master and worker node patch updates in a timely manner
- Understanding that patch updates may include fixes for security vulnerabilities
- Notifying IBM when access to beta BOMs is no longer required
- Accepting, if applicable, IBM's non-disclosure agreement
- Accepting that beta BOMs are provided as-is and must not be used in production

The owner must agree to these terms and conditions in order to access beta BOMs.

## Process to Grant Access

1. Ensure owner agrees to the terms and conditions.

1. [Create an issue](#create-issue) noting that the owner has agreed to the
   terms and conditions. Include a link to an issue containing or copy of the
   owner agreement. You will be contacted later to provider the owner email
   address. However, do **NOT** include the owner email address or any other
   owner personal data in the issue created.

1. Once the issue is approved and completed, notify the owner that the request
   for accessing beta BOMs has been approved and processed.

## Process to Remove Access

1. Confirm that the owner does not have clusters currently using beta BOMs.
   Such clusters must be deleted before removing access to the beta BOMs.

1. [Create an issue](#create-issue) noting that the owner has verified no
   clusters are using beta BOMs. You will be contacted later to provider the
   owner email address. However, do **NOT** include the owner email address or
   any other owner personal data in the issue created.

1. Once the issue is approved and completed, notify the owner that the request
   for removing access to beta BOMs has been approved and processed.

## Approval Process

1. Confirm that the appropriate information has been provided in the issue per
   the request process. If not, reject the request and work with the submitter
   to correct the problem.

1. Obtain approval for the request from one of the following approvers.
   The approver must update the issue confirming their approval.
   - Richard Theis @rtheis
   - John McMeeking @jmcmeek
   - Bill Lynch @wmlynch
   - IBM Cloud Kubernetes Service management
   - IBM Cloud Kubernetes Service squad leader for associated features packaged
     in beta BOMs

1. Contact the person that created the issue to obtain the owner email address.
   Do **NOT** store the owner email address or any other owner personal data in
   the issue.

1. Translate the owner email address into an IBMID. This is done on the
   #xo-conductors Slack channel using the `@xo` app (use `@xo help` for details).
   Document the IBMID in the issue.

1. **This step must be done under a prod-train request.** Add/remove (depending
    on the request) the owner's IBMID to/from one of the following groups. If the
    group is new, it must be added to the
    [armada-api.master.bom.beta feature flag](https://app.launchdarkly.com/armada-users/production/features/armada-api.master.bom.beta/targeting).
    - [beta-bom-users group](https://app.launchdarkly.com/armada-users/production/segments/beta-bom-users/targeting)
    - [my-feature-beta group](https://app.launchdarkly.com/armada-users/production/segments/)

1. Close the issue as approved and completed.

## Create Issue

For general access to beta BOMs, create an
[armada-update issue](https://github.ibm.com/alchemy-containers/armada-update/issues).
For access to associated features packaged in beta BOMs, create an issue in the
appropriate squad's GHE repository.

## Questions

Go to the #armada-update Slack channel.

## Reviews

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
