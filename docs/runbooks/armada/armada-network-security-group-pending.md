---
layout: default
title: armada-network - Worker Stuck in Pending Security Group Creation
type: Troubleshooting
runbook-name: "armada-network - Worker Stuck in Pending Security Group Creation"
description: "armada-network - Worker Stuck in Pending Security Group Creation"
service: armada
link: /armada/armada-network-security-group-pending.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Worker Stuck in Pending Security Group Creation

## Overview

For new customer clusters or test clusters with VPC workers stuck in **provisioning** state with the status **Pending Security Group Creation**, if that message has been there for more than 20 minutes, follow this runbook to determine what is wrong.

## Example Alert(s)

None right now, either the customer will report this or our automated tests will fail and the logs will show the workers in this state.

## Investigation and Action

When workers are stuck in this status for 20 minutes or more, it almost always means that as described, that one or more of the Security Groups for the cluster was not able to be created by the network microservice.  To find the cause of this, you can first look at the network microservice logs for the creation actions of this cluster.

### Finding Cause of Security Group Creation Failure in Network Microservice Logs

Use the following steps to find the failure of the security group creation

1. Search slack for the cluster ID and `cluster_create_trigger`, so the full search for example would be `c9g0p8al02vt251nat8g cluster_create_trigger`.  Most likely (if the Security Group creation was in fact failing), you will see some of these in #armada-netms-alerts with the `Result: Attempted`, and if it has exhausted its retries you will see one in #netms-fails with `Result: trigger_failure`
2. Select one of the more recent `Result: Attempted` messages so you can see that slack message it in the #armada-netms-alerts channel (outside of the search results), because the link to the "Logs" inside the search results does not work (the URL is malformed in the search results).
3. Click the "Logs" link when viewing the `cluster_create_trigger` slack message `Result: Attempted` in the #armada-netms-alerts channel.
    * If the Logs page fails to appear and you see the error "AWS authentication requires a valid Date or x-amz-date header." then check the URL for `&amp;` and if you see those, you probably clicked the "Logs" link from within the search results.  Select the message so you can see it in the channel instead, and try the "Logs" link again
    * If the Logs page fails to appear and you see a different error, then you might need to connect to a VPN because the COS log retrieval might be restricted to certain source IPs
4. Look at the logs for any error messages during the Security Group creation process.
5. See the next few sections for how to investigate the following errors

### Quota Error

If you see an error indicating the customer has hit their security group quota, then let the customer know this.  There options are to either delete unused security groups in the VPC, request a quota increase for security groups in their VPCs and in their account as a whole, or delete this cluster and create a new cluster in a VPC that is not close to its security group quota.   If they choose to delete security groups or get a quota increase, then one they have done so, they should do a cluster master refresh which should successfully create the security group, and then provision the workers.

### General Error from Security Group Creation API

If there is any other error, then most likely the VPC IaaS API that the network microservice calls to create the security group is down or malfunctioning.  In this case, we will need to transfer the ticket to the VPC IaaS team.  Provide the error message from the security group creation API call, the account ID and cluster ID, and the time it was called.

## Escalation Policy
Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
