---
layout: default
title: Cluster opt-out of automatic master patch updates
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Overview

Clusters may optionally opt-out of automatic master patch updates. However,
leveraging this capability must follow the process outlined here.

## Terms and Conditions

Opting-out of automatic master patch updates is done at the cluster owner
level. Therefore, the owner will be responsible for the following:

- Applying master patch updates in a timely manner
- (IBM owner) Accepting full responsibility (e.g. failing internal or external
  audits) for failing to apply master patch updates in a timely manner
- Understanding that the master patch updates may include fixes for security vulnerabilities
- Notifying IBM when the they would like to opt-in again
- (IBM owner) Providing a valid business justification for opting-out
- Managing the `Cluster master autoupdate` status for **every** cluster owned

The owner must agree to these terms and conditions in order to opt-out of
automatic master patch updates.

## Opt-Out Request Process

1. Ensure the owner agrees to the terms and conditions.

1. Create an [issue](https://github.ibm.com/alchemy-containers/armada-update/issues)
   noting that the owner has agreed to the terms and conditions. Include a link
   to an issue containing or copy of the owner agreement. You will be contacted
   later to provider the owner email address. However, do **NOT** include the
   owner email address or any other owner personal data in the issue created.

1. Once the issue is approved and completed, notify the owner that the request
   for opting-out of automatic master patch updates has been approved and
   processed. The owner must now go to the IBM Cloud UI `Overview` page for
   their cluster and select the `Disable` button for `Cluster master autoupdate`.
   This must be done for **every** cluster that the owner wishes to opt-out of
   automatic master patch updates.

## Opt-In Request Process

1. Verify the owner confirms that IBM Cloud UI `Overview` page for **every**
   cluster they own shows that `Cluster master autoupdate` is enabled (i.e. the
   `Disable` button is displayed)

1. Create an [issue](https://github.ibm.com/alchemy-containers/armada-update/issues)
   noting that the owner has verified the `Cluster master autoupdate` status for
   **every** cluster they own. You will be contacted later to provider the owner
   email address. However, do **NOT** include the owner email address or any
   other owner personal data in the issue created.

1. Once the issue is approved and completed, notify the owner that the request
   for opting-in to automatic master patch updates has been approved and processed.

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

1. Contact the person that created the issue to obtain the owner email address.
   Do **NOT** store the owner email address or any other owner personal data in
   the issue.

1. Translate the owner email address into an IBMID. This is done on the
   #xo-conductors Slack channel using the `@xo` app (use `@xo help` for details).
   Document the IBMID in the issue.

1. **This step must be done under a prod-train request.** Add/remove (depending
    on the request) the owner's IBMID to/from the
    [auto-update-optout group](https://app.launchdarkly.com/armada-users/production/segments/auto-update-optout/targeting).

1. Close the issue as approved and completed.

## Questions

Go to the #armada-update Slack channel.

### Reviews

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
