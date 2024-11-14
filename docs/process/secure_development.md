---
layout: default
title: Secure development for Argonauts Squads
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Process: secure development

## Brief scope

This process covers how we manage changes and separate duties so that a single user cannot make a code change, approve their own code change, and push to production without interaction and review/approval from others. This process describes how we implement the [IBM Cloud Change Management Policy](https://ibm.ent.box.com/s/z0nklp949ztsjm4vqn0gvo5k4bjx8eya).

For details of how we ensure the development of good quality code with respect to security, refer to the [vulnerability management process](./vulnerability_management.html).

## Roles

- Developer (Development Squad Member)

- Code Reviewer (Development Squad Member)

- SRE Squad Member

## Trigger: A code change is required for a bug fix, new function or configuration change

- A developer makes a code change in Github in one of the repositories in the organizations we own.

- The developer submits a pull request to ask for the change to be merged onto the master code branch.

- A code reviewer with the correct authority on that Github repository will review the requested change. The code reviewer must not be the developer, unless either of the following conditions are met:
    - The code is for a non-production internal tool where problems do not impact customers.
    - It is an emergency change (e.g. for a CIE or security incident) and a manager or SRE squad member gives verbal approval. In this case the code must be retrospectively reviewed as soon as possible and the review recorded on the pull request.

    Each master branch in github source control is protected with the `Require pull request reviews before merging` option which means the user requesting the change cannot approve and merge their own change. Use of a pull request builder with the `Require status checks to pass before merging` option is also strongly recommended so that tests can be run against each proposed change before merging; development squads must use this for high-risk components.

    The reviewer must ensure that the code changes are of acceptable quality and that appropriate tests have been added and executed. High-risk changes (as defined by the team) should additionally be reviewed by another SME.

    - If the review is rejected, the developer must re-work the change and we restart this process. In this case, no change is merged into the master branch in GHE.

    - If the review is approved, the update can be merged into the master branch.

- The change will automatically be built and promoted into the development and pre-staging environments where further testing occurs.

- When the developer's testing has completed successfully, the code can be deployed into the staging environment as follows.

## Trigger: A change needs to be made to staging environments

- Developer completes their testing and validation of the code change and requests deployment to staging environment.

    The developer will either send an [API request](https://github.ibm.com/alchemy-conductors/elba/blob/master/example/request_body.json) to the Elba service or post a request in the `#cfs-stage-trains` Slack channel providing the following details:
    ```
    Squad: Name of squad
    Title: Summary of change
    Environment: stage-us-south (or similar)
    Details: Detailed description of change
    Risk: high|medium|low
    PlannedStartTime: (e.g. now)
    PlannedEndTime: (e.g. now +1h)
    BackoutPlan: How the change will be reverted if any problems occur
    ```

    All change requests will be logged in [ServiceNow], regardless of how they were opened.

    The on-call SRE engineer(s) will monitor the #cfs-stage-trains Slack channel for deployment approval requests. If a squad is in the approval whitelist, their requests will be automatically approved - otherwise manual approval is required.

    If manual approval is required, the on-call SRE engineers will review the request and either approve or reject the change  based on the current stability of the regions where the change is being requested.
  
    **PLEASE NOTE:** If trains are stopped or if there is a stage environment change freeze window then no pushes are allowed for the environment unless they are required to fix an outage or are otherwise urgent. Automatic approvals are also stopped during this time and only emergency fixes which are manually approved will be allowed to be pushed to a stage environment.

    The developer must act accordingly on the approver's response:
    - If the approval is refused, the developer must re-work the change and we restart this process. In this case, no change is delivered into the staging environment.
    - If the approval is granted, the developer can deploy their update to the staging environment.

- The developer triggers the deployment into the staging environment and monitors the environment to ensure successful deployment. The next step depends on the staging deployment outcome:
    - If the deployment fails, the developer must address the cause of the failure. Any re-work to the original changes means we must restart this process.
    - If the deployment succeeds, we continue to the next step.

- When the developer's testing has completed successfully, the code can be deployed into the production environment as follows.

## Trigger: A change needs to be made to production environments

- Developer requests deployment to the production environment. The developer will either send an [API request](https://github.ibm.com/alchemy-conductors/elba/blob/master/example/request_body.json) to the Elba service or post a request in the `#cfs-prod-trains` Slack channel providing the following details:
    ```
    Squad: Name of squad
    Title: Summary of change
    Environment: us-south (or similar)
    Details: Detailed description of change
    Risk: high|medium|low
    StageDeployDate: date this went to stage in YYYY-MM-DD format
    Tests: URL link to tests run and their results
    TestsPassed: true|false
    TestsEnvironment: environment tests were run in, should be stage
    OutageDuration: duration of service outage eg: 1h or 5m30s or 0s
    OutageReason: reason for outage if OutageDuration
    PlannedStartTime: (e.g. YYYY-MM-DD HH:MM -ZZZZ or now)
    PlannedEndTime: (e.g. YYYY-MM-DD HH:MM -ZZZZ or now +1h)
    BackoutPlan: How the change will be reverted if any problems occur
    ```

    All change requests will be logged in [ServiceNow], regardless of how they were opened.

    The change request is subject to two approvals:
    1. Approval of the change. This is granted by the Change Review Board in accordance with the change management policy. ServiceNow is configured to automatically approve changes which are within the policy.
    2. Approval to deploy, which is granted by the on-call SRE engineers.

    The on-call SRE engineers will monitor the #cfs-prod-trains Slack channel for deployment approval requests. If a squad is in the approval whitelist, their requests will be automatically approved - otherwise manual approval is required.
  
    If manual approval is required, the on-call SRE engineers will review the request and either approve or reject the change   based on the current stability of the regions where the change is being requested and the requirements of the change management policy.
  
    **PLEASE NOTE:**  If trains are stopped for a critical impact event (CIE) or for a change freeze window then no deploys are  allowed for the environment unless they are required to fix an outage or are otherwise urgent. Automatic approvals are also stopped during this time and only emergency fixes which are manually approved will be allowed to be pushed to a production environment.

    The developer should act accordingly on the approvers response:
    - If the approval is refused, the developer must re-work the change and we restart this process. In this case, no change is delivered into the production environment.
    - If the approval is granted, we continue to the next step.

- The developer triggers deployment into the production environment and monitors the environment to ensure successful deployment. The next step depends on the production deployment outcome:
    - If the deployment fails, the developer must address the cause of the failure. Any re-work to the original changes means we must restart this process.
    - If the deployment succeeds, the process is complete.

## How to collect evidence

For code review, each Github Enterprise repository will have a history of reviews under the `Pull Request` tab. This will have history of the developer requesting the change and the review of the change.

For change requests for Stage and Production, all requests will be logged in [ServiceNow].

The Staging and Production whitelists for automatic deployments will be reviewed at least annually by the SRE squad and development squad leads.

## Where to store evidence

Evidence of code reviews will be stored in GHE organizations individual repositories.
In each repository, code pull requests and reviews will be stored under the `Pull Request` tab and will remain there for the lifetime of the repository.

The orgs we will track against are:

- [Containers GHE]
- [Conductors GHE]
- [Registry Squad GHE]
- [Vulnerability Advisor Squad GHE]
- [SRE Bots GHE]
- [Netint GHE]

For change requests for Stage and Production, all changes will be stored in [ServiceNow].

Evidence of whitelist reviews will be stored as a GHE issue in [Conductors team issues].

## How long to keep evidence

In GHE, code reviews and pull requests will be kept for the lifetime of that repository.

In GHE, allowlist reviews will be kept as an issue in [Conductors team issues] and will remain there for the lifetime of this repository.

## Reviews

Last review: 2024-07-11 Last reviewer: Hannah Devlin Next review due by: 2025-07-10

[Conductors team issues]: https://github.ibm.com/alchemy-conductors/team/issues
[ServiceNow]: https://watson.service-now.com/nav_to.do?uri=%2Fchange_request_list.do%3Fsysparm_userpref_module%3D3264ded3c611227a019523c8448d2d91%26sysparm_clear_stack%3Dtrue
[Containers GHE]: https://github.ibm.com/alchemy-containers
[Conductors GHE]: https://github.ibm.com/alchemy-conductors
[SRE Bots GHE]: https://github.ibm.com/sre-bots
[Registry Squad GHE]: https://github.ibm.com/alchemy-registry
[Vulnerability Advisor Squad GHE]: https://github.ibm.com/alchemy-va
[Netint GHE]: https://github.ibm.com/alchemy-netint
