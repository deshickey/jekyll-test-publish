---
layout: default
description: How to troubleshoot errors thrown by armada-dnsman microservice.
title: armada-dnsman - How to troubleshoot errors thrown by armada-dnsman microservice.
service: armada
runbook-name: "armada-dnsman - How to troubleshoot errors thrown by armada-dnsman microservice"
tags: microservice
link: /armada/armada-dnsman-error.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to troubleshoot errors thrown by the armada-dnsman microservice. Alerts are triggered when specific errors are generated and aggregated across nodes. Too many errors generated over a minute will trigger the alert.

This component modifies CoreDNS configs with the end goal of "bypassing" private service endpoint in our infra and instead sending directly to the backend private IPs that the service endpoints ultimately route. It eliminates a network hop and helps to enable the allowlisting feature on the private service endpoints.

## Example alert

There are 4 kind of alerts currently:
- KubernetesServiceDown
- git_update_error
- cse_update_error
- dns_update_error

Example:
```
summary = "too many Git update errors have occurred over the last minute"
description = "5 Git update errors have occurred over the last minute. Dependency marked as git"
```

## Investigation and Action

Alerts in the armada-dnsman microservice are composed of two important pieces of information- the error description and the dependency associated with the error.  Operations in the armada-dnsman will retry 5 times before completely failing out.

### Where to Find Logs (Initial Troubleshooting)

Logs for the armada-dnsman microservice are published to Slack (similar to the way the armada-deploy squad posts their log messages):

- Pre-Production Alert [here](https://ibm-argonauts.slack.com/archives/G01QH74H95H)
- Pre-Production Update [here](https://ibm-argonauts.slack.com/archives/G01QA7T03JA)
- Production Alert [here](https://ibm-argonauts.slack.com/archives/C01F3V0E2AH)
- Production Update [here](https://ibm-argonauts.slack.com/archives/G01R6RLS7EC)

Visiting one of the above channels and looking entries will provide links to logs that can be vital in searching what happened to cause this failure.

### DNSMan Failures
#### Alert `KubernetesServiceDown` (startup failures)

Possible scenarios:
 * Environment configuration errors: `unable to process envs`
   * Some mandatory environment variables are missing or in wrong format. The microservice gets the its variables from armada-secure.
     The container log shows which environment variable is missing or has issues.

   Steps:
   1. Locate the carrier/tugboat where the error comes (based on the alert labels). The microservice runs on carriers and tugboats and with role hub and spoke.
   2. Get the logs of the armada-dnsman pods
   3. Identify which environment variable is missing from the logs
   4. Check if there was a new armada-secure rollout before the alert
   5. If there was a new rollout of armada-secure which breaks armada-dnsman, revert the change and notify the train requestor about the issue
   6. If you cannot decide about the problem, page out the network squad with the gathered logs
   
 * Kubernetes configuration error: `unable to init Kubernetes client`
   * The in-cluster Kubernetes configuration is missing or service account is misconfigured
 * Leader election is not able to initialize: `unable to init leader election manager`
   * This can fail for many reasons like service account or connectivity issues, logs help to detect actual problem.

   Steps:
   1. Locate the carrier/tugboat where the error comes (based on the alert labels). The microservice runs on carriers and tugboats and with role hub and spoke.
   2. Identify which `armada-dnsman` pod is the leader: `kubectl describe cm -n armada armada-dnsman-lock`
   3. Get the logs of the leader armada-dnsman pod
   4. If you cannot decide about the problem based on the logs, page out the network squad with the gathered logs

 * Initial Git clone fails: `unable to clone Git repository`
   * Usually there is some problem with `GIT_TOKEN`, `GIT_TARGET_DIRECTORY` is not writeable or the `GIT_URL` is not available.

   Steps:
   1. Check if there is a global maintenance of GHE.
   2. If yes, ignore the alert. Once the GHE comes back, armada-dnsman will clear the alert.
   3. If no, get the logs of the armada-dnsman pods. If the logs contain `panic: authentication required` is written, the GIT_TOKEN is revoked or not valid anymore.
   4. Update `armada-ghe-access.yaml` in armada-secure with the new GHE token (token shall be able to checkout and pull https://github.ibm.com/alchemy-containers/armada-envs, read-only)
   5. Rollout the armada-secure with the new GHE token

#### Alert `git_update_error`
 * Unable to update Git repository: `unable to update Git repository`
   * Usually there is some problem with `GIT_TOKEN` or the `GIT_URL` is not available.
   * The `git_update_error` does not cause outage. But if there is a change in region (e.g. new carrier is rolled out), its override won't be configured in CoreDNS.

   Steps:
   1. Check if there is a global maintenance of GHE.
   2. If yes, ignore the alert. Once the GHE comes back, armada-dnsman will clear the alert.
   3. Identify which `armada-dnsman` pod is the leader: `kubectl describe cm -n armada armada-dnsman-lock`
   4. Get the logs of the leader armada-dnsman pod. If the logs contain `panic: authentication required` is written, the GIT_TOKEN is revoked or not valid anymore.
   4. Update `armada-ghe-access.yaml` in armada-secure with the new read-only GHE token (token shall be able to checkout and pull https://github.ibm.com/alchemy-containers/armada-envs)
   5. Rollout the armada-secure with the new GHE token
 
#### Alert `cse_update_error`
 * Unable to fetch Cloud Service Endpoints: `unable to fetch CSE objects`
   * This can happen if given `CSE_API_KEY` is invalid or remote service is not available.
   * The `cse_update_error` does not cause outage. But if there is a change in the CSE configuration (e.g. Service or Endpoint addresses are changing), it won't be updated in carrier/tugboat CoreDNS configuration

   Steps:
   1. Connect to the region by SSH/TSH to a carrier master node, and run the `armada-cse-helper` tool with parameter `validate-region-config` on a carrier master and check if the Cloud Service Endpoint service is available
   2. If the tool reports errors about connecting the CSE service, consult with the CSE SREs (CSE SRE channel: https://ibm-cloudplatform.slack.com/archives/CDF38M7U0)
   3. If the tool reports the following error: `Cannot create CSE service API object Request failed with status code: 400, BXNIM0415E: Provided API key could not be found`. Then the CSE_API_KEY which is stored in `service-endpoint-secret` in the `service-endpoint-config.yaml` file. The API_KEY is maintainted by SRE team.

#### Alert `dns_update_error`
 * Unable to update CoreDNS entries: `unable to update CoreDNS entries`
  * This can fail for many reasons like connectivity or config map isses, logs help to detect actual problem.

  Steps:
  1. Locate the carrier/tugboat where the error comes. The microservice runs on carriers and tugboats and with role hub and spoke.
  2. Identify which `armada-dnsman` pod is the leader: `kubectl describe cm -n armada armada-dnsman-lock`
  3. Get the logs of the leader armada-dnsman pod
  4. If you cannot decide about the problem based on the logs, page out the network squad with the gathered logs

### Catch-All

For all other failures please reach out to the armada-network squad directly via Slack or create a new issue [here](https://github.ibm.com/alchemy-containers/armada-network/issues/new).  Network squad will add more scenarios to this runbook to help facilitate SRE debugging.

## Escalation Policy

Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
