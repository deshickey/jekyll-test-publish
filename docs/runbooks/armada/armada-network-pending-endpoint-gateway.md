---
layout: default
title: armada-network - Worker Stuck in Pending Endpoint Gateway Creation
type: Troubleshooting
runbook-name: "armada-network - Worker Stuck in Pending Endpoint Gateway Creation"
description: "armada-network - Worker Stuck in Pending Endpoint Gateway Creation"
service: armada
link: /armada/armada-network-pending-endpoint-gateway.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Worker Stuck in Pending Endpoint Gateway Creation

## Overview

For new customer clusters or test clusters with VPC workers stuck in **provisioning** state with the status **Pending Endpoint Gateway Creation**, if that message has been there for more than 20 minutes, follow this runbook to determine what is wrong.

## Example Alert(s)

None right now, either the customer will report this or our automated tests will fail and the logs will show the workers in this state.

## Investigation and Action

When workers are stuck in this status for 20 minutes or more, it almost always means that as described, the VPE Gateway ("Endpoint Gateway") was not able to be created by the network microservice.  To find the cause of this, you can first look at the network microservice logs for the creation actions of this cluster.

### Finding Cause of Endpoint Gateway Creation Failure in Network Microservice Logs

Use the following steps to find the failure of the Endpoint Gateway creation

1. Search slack for the cluster ID and `cluster_create_trigger`, so the full search for example would be `c9g0p8al02vt251nat8g cluster_create_trigger`.  Most likely (if the VPE Gateway creation was in fact failing), you will see some of these in #armada-netms-alerts with the `Result: Attempted`, and if it has exhausted its retries you will see one in #netms-fails with `Result: trigger_failure`
2. Select one of the more recent `Result: Attempted` messages so you can see that slack message it in the #armada-netms-alerts channel (outside of the search results), because the link to the "Logs" inside the search results does not work (the URL is malformed in the search results).
3. Click the "Logs" link when viewing the `cluster_create_trigger` slack message `Result: Attempted` in the #armada-netms-alerts channel.
    * If the Logs page fails to appear and you see the error "AWS authentication requires a valid Date or x-amz-date header." then check the URL for `&amp;` and if you see those, you probably clicked the "Logs" link from within the search results.  Select the message so you can see it in the channel instead, and try the "Logs" link again
    * If the Logs page fails to appear and you see a different error, then you might need to connect to a VPN because the COS log retrieval might be restricted to certain source IPs
4. Look at the logs for the part where the VPE Gateway is created.  You should see something like:

```
Processing VPE creation for cluster: ...
...
Found 0 endpoint gateways to process
...
Creating EG - Name: ...
```

Right below this, you should see the results of the Endpoint Gateway creation.  See the next few sections for how to investigate the following errors

### VPCNotFound Error

If you see the following error or something like it (with "VPCNotFound"):

`VPE Create Failed with this Fault &{The VPC 'r018-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX' cannot be found. ErrorVPCNotFound <nil> [not_found: Service does not support VPE extensions. (400) not_found: Service does not support VPE extensions. 6b383caf-996c-4904-a40f-a920c104b3eb] map[] P4101: The VPC '{{.VPCID}}' cannot be found. map[VPCID:r018-0a178dca-e565-4828-91c9-32a77358e753]} and this Reasoncode: ErrorVPCNotFound`

Then that usually means that the VPE information did not get put into Ghost for this cluster.  To verify this skip to the **Check for VPE Information for This Cluster in Ghost** section below.

### Any Other Error

If there is any other error, then there are two likely causes.  First try to create a VPC cluster in the same production region the customer is having the problem in, and use ROKS or IKS to match what the customer is using.  While waiting to see if that test cluster creates successfully and the workers deploy successfully, move on to the next steps to check the two possible causes.

1. A bug that was recently introduced in a network-microservice update.  To check for this, look here in Razee https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-network-microservice at the bottom of the page to see if the network-microservice was just updated.  If it was recently updated, then use the escalation policy to contact the IKS/ROKS network team to see if the network-microservice should be reverted to the previous version.  Otherwise look at the second step.

2. The VPC IaaS API that the network microservice calls to create the VPE Gateway is down or malfunctioning.  In this case, we will need to transfer the ticket to the VPC Gateway team.  As part of that, they will want to know if the VPE Gateway info is in Ghost, so skip down to the next section to get that data:

### Check for VPE Information for This Cluster in Ghost

1. Run `@xo cluster <CLUSTER-ID>` to get the account ID and region.  If this is a stage cluster, the region for the main stage carrier0 is "stage-south".  Prod clusters are something like: "us-south, ap-north, ..."
2. Run `@xo queryGhostClusters <ACCT-ID> cluster=<CLUSTER-ID> region=<REGION>` to get Ghost data.  If needed, you can leave off region, but the output returns the data separately for each region and it can be hard to read.
    * Stage example: `@Armada Xo - Stage queryGhostClusters 1152aa1c1ec54274ac42b8ad8507c90c cluster=c9lrkli20k886n951e4g region=stage-south`
    * Production example: `@xo queryGhostClusters bdd96d55c7f54798a6b9a1e1bedec37c cluster=c679vtnw0tgvn4ta0040 region=us-east`
3. Look for data that looks something like this:

```
    "extensions": {
      "virtual_private_endpoints": {
        "dns_domain": "vpe.private.us-east.containers.cloud.ibm.com",
        "dns_hosts": [
          "c6789012345abcdefghi"
        ],
        "endpoints": [
          {
            "ip_address": "166.9.22.9",
            "zone": "wdc06"
          },
          {
            "ip_address": "166.9.24.4",
            "zone": "wdc07"
          },
          {
            "ip_address": "166.9.20.12",
            "zone": "wdc04"
          }
        ],
        "origin_type": "cse",
        "ports": [
          {
            "port_max": 25111,
            "port_min": 25161
          },
          {
            "port_max": 23111,
            "port_min": 23111
          }
        ]
      }
    },
```

4. If you find this section, it means the data is in Ghost.  In that case you should transfer the ticket to the VPC Gateway team, and in the ticket provide this Ghost VPE data, along with the VPC ID, Cluster ID, and whatever error we are getting in the network microservice log when we try to create the VPE Gateway.

5. If the `virtual_private_endpoints` section is not in the Ghost data, then most likely the tugboat this cluster master is on does not have the proper CSE information in armada-secure.  Check with the SREs if the tugboat (carrierXXX) this cluster master is on recently went live, and also look for the CSE data in the region the cluster is in in armada-secure.  For instance in us-east you would look at this file: https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/us-east/service-endpoint-config.yaml for the data in the `private-se-info.json` section.

### Fix VPE Data in armada-secure

If the correct VPE Data is not in armada-secure for this tugboat, then we need to add it to armada-secure, get that PR merged, and push armada-secure to at least this production region.   If this can't be done within a few hours, then this tugboat should be taken out of service temporarily with a config-pusher PR until a corrected version of armada-secure can be promoted.  This happened for tugboat prod-lon04-carrier109 recently, and was detailed in customer ticket: https://github.ibm.com/alchemy-containers/customer-tickets/issues/12341

Here are the PRs used to disable the tugboat temporarily, and then to fix the VPE / CSE data in armada-secure:

* Config Pusher PR to remove prod-lon04-carrier109 temporarily: https://github.ibm.com/alchemy-containers/armada-config-pusher/pull/1496/
* armada-secure PR to add VPE / CSE data for prod-lon04-carrier109: https://github.ibm.com/alchemy-containers/armada-secure/pull/5488/

### Recover Clusters if VPE Gateway Create API is Just Malfunctioning for a While

If the VPE Gateway Create API is just not working for a while, then VPC clusters created during this time will need to do a cluster master refresh (unless it is still retrying) so the network-microservice will try to create the VPE gateway again.  So if the workers are still in this state 10 minutes after the VPE Gateway Create API is back up, then have the customer run a cluster master refresh or use the jenkins job we have to run the cluster master refresh for the customer.

That jenkins job requires an ops train to run it on a prod cluster, and is at https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-master-refresh/.  To create the ops prod train, paste the following into the `#cfs-prod-trains` slack channel replacing `<REGION>` and `<CLUSTER-ID>`, and then once it is approved follow the instructions from the `@Fat-Controller` slack app to start the train.  If it isn't approved in 30 minutes, ping `@interrupt` in the `#conductors` slack channel and ask them to approve it.  Once you've started the train, enter the train ID into the jenkins job to run it, and after it is done and has succeeded, complete the train:

Ops Train Request to paste into `#cfs-prod-trains`

```
Squad: armada-network
Title: Run cluster-master-refresh jenkins job
Environment: <REGION>
Details: |
  Run the https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-master-refresh/
  jenkins job to do a cluster master refresh for cluster <CLUSTER-ID> to fix it.
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 2h
Ops: true
BackoutPlan: N/A
```

### Recover Clusters Created When armada-secure VPE Data Was Missing

If the problem was that the VPE data was completely missing from armada-secure, then when the correct data is added to armada-secure, there are a few steps to take to fix up any VPC clusters created while the data was missing:

1. Either have the customer run a cluster master refresh, or use the jenkins job we have to run it for the customer.  This should cause the API code to put the correct VPE data in Ghost, and cause the network-microservice to create the VPE Gateway
2. Once the VPE Gateway is successfully created, the flag in etcd for the cluster will be cleared, and the workers should be provisioned and added to the cluster

### Recover Clusters Created When armada-secure VPE IPs Were Wrong

If the problem was that the IPs in armada-secure were wrong, and the VPE Gateway was created using the wrong IPs, then the steps to fix up clusters created with the wrong IPs is the following:

1. Either have the customer run a cluster master refresh, or use the jenkins job we have to run it for the customer.  This should cause the API code to put the correct VPE data in Ghost
2. Have the customer delete the VPE gateway from their account.  It will have the name `kube-<CLUSTER-ID>`.  Once they delete the VPE gateway, then need to run a cluster master refresh again so the VPE Gateway will be recreated.

## Escalation Policy
Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
