---
layout: default
description: "[Informational] Armada - Request to increase Private Service Endpoint Allowlist rule limit"
title: "[Informational] Armada - Request to increase Private Service Endpoint Allowlist rule limit"
runbook-name: "[Informational] Armada - Request to increase Private Service Endpoint Allowlist rule limit"
service: armada
tags: allowlist, network, acl, private, quota
link: /armada/armada-network-cse-acl-rule-limit.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

Private Service Endpoint Allowlist is deprecated and will be unsupported on or around February 10th, 2025.  It is being replaced by CBR rules.  Our docs have been updated (or will be when PR https://github.ibm.com/alchemy-containers/documentation/pull/13379 merges) so they no longer say that private service endpoint allowlist limits can be increased.  However we might still get a request or two from customers that know that this used to be an option.

If we do get a request to increase the private service endpoint allowlist limit, we should point customers at these docs:

- IKS: [https://cloud.ibm.com/docs/containers?topic=containers-access_cluster#private-se-allowlist](https://cloud.ibm.com/docs/containers?topic=containers-access_cluster#private-se-allowlist)
- ROKS: [https://cloud.ibm.com/docs/openshift?topic=openshift-access_cluster#private-se-allowlist](https://cloud.ibm.com/docs/openshift?topic=openshift-access_cluster#private-se-allowlist)

that say that private service endpoint allowlist is deprecated, and they should migrate to CBR, where the limits are much larger, 200 subnets for private rules and 500 subnets for public rules.

I'll leave the instructions for how to increase the allowlist limit in this runbook for now, under "Detailed Information", but it should only be used if we are escalated and our management tells us we have to increase the limits.  Otherwise the answer is to refer to the docs above with how customers can switch to CBR.


## Detailed Information

NOTE: Read the "Overview" section above first.  We should NOT be increasing this limit for customers unless we are escalated and our management tells us we have to.

To increase the customer's rule limit, you will need one train request per region, but you can use a single train request for multiple clusters in the same region.  So for each region that the customer has clusters in that they are requesting a limit increase, do the following:

1. Depending on the cluster environment, raise a train request either in the `#cfs-prod-trains` or `#cfs-stage-trains` Slack channel by copying in the following message (filling in the `###ENVIRONMENT###` and `###CLUSTERIDS###` entries)
```
Squad: network
Title: Increase Private Service Endpoint ACL quota for custom subnets
Environment: ###ENVIRONMENT###
Details: |
  Increase Private Service Endpoint ACL custom subnets quota
  for ###CLUSTERIDS### by running this jenkins job:
  https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/
Risk: low
Ops: true
PlannedStartTime: now
PlannedEndTime: now + 1h
BackoutPlan: re-run the jenkins job to fix issue
```
2. Wait for notification via the `@Fat-Controller` slack app that your train has been approved, then use a Slack DM with the `@Fat-Controller` to start the train
3. Go to the [armada-network-private-service-endpoint-operations](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/) Jenkins job and set the following parameters:
  - Region: customer's cluster region
  - Operation: `set-custom-acl-limit`
  - Cluster ID: customer's cluster ID
  - ACL Limit: whatever the customer requests (max of 75)
  - Operation Type: `write`
  - Ops Train Ticket ID: the train ID from step 2
4. Run the job and verify that it passes
5. Repeat steps 3 and 4 for any other clusters in that region
6. Use the `@Fat-Controller` app to complete the train.
7. Reply to the customer ticket with something like the following:

```
@support
The limit has been increased for cluster(s) <PUT-CLUSTERID-HERE>

Please also tell the customer the following:

The limit for clusters <PUT-CLUSTERID-HERE> has been increased.  This private-service-endpoint-allowlist feature has already been deprecated and will be unsupported on February 10, 2025.  At that point you will not be able to modify your allowlist, you will only be able to disable it (and will not be able to enabled it again).  You need to migrate to CBR rules instead. CBR rules are better for several reasons:

1. The ability to target all clusters in an account at once (and not have to set the list one by one), or for a specific cluster
2. Allow access from specific VPCs (not just IPs/Subnets)
3. Higher IP/Subnet limits (up to 200 private IPs/Subnets, 500 public IPs/Subnets)
4. Web UI to create/delete/modify CBR rules at cloud.ibm.com, as well as an API and CLI
5. The ability to restrict public access via CBR (private service endpoint allowlist only restrict private service endpoint traffic)

You can learn about CBR rules at:

https://cloud.ibm.com/docs/containers?topic=containers-pse-to-cbr-migration
https://cloud.ibm.com/docs/containers?topic=containers-cbr&interface=ui
https://cloud.ibm.com/docs/containers?topic=containers-cbr-tutorial
https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis

Once you have added these private "api-type:cluster" CBR rules for the kubernetes service that mirror your current private service endpoint allowlist rules, you can then disable your private service endpoint allowlist since all the traffic not allowed by your CBR rules on the private service endpoint will be blocked by CBR.
```

## Escalation Policy
Contact armada network squad on Slack (#armada-network)

## References

- [Private Service Endpoint Allowlist](https://cloud.ibm.com/docs/containers?topic=containers-access_cluster#private-se-allowlist)


