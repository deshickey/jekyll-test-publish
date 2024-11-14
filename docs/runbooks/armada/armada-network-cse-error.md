---
layout: default
description: How to troubleshoot errors thrown by armada-network microservice related to CSE.
title: armada-network - How to troubleshoot CSE errors thrown by armada-network microservice.
service: armada
runbook-name: "armada-network - How to troubleshoot CSE errors thrown by armada-network microservice"
tags: network, microservice, CSE, private, service, endpoint
link: /armada/armada-network-cse-error.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to troubleshoot Cloud Service Endpoint (CSE) related errors thrown by the armada-network microservice.
The CSE is an external service which is used by IKS. See more information about [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-service-endpoint-overview.html)

The armada-network-microservice has a feature which is able to apply ACL rules to help the customers to secure the cluster. 
With the ACL rules, the customer could limit the source IP addresses which could reach her cluster master services (Kubernetes API, OpenVPN, Etcd).
For this purpose, the armada-network-microservice shall need to communicate with the CSE service.

Alerts are triggered when specific errors are generated and aggregated per cluster. Too many errors generated over 5 minutes will trigger the alert.

## Example alert

```
summary = "CSE endpoint not found on carrier. Maybe need to update service-endpoint-config config map."
description = "could not connect to CSE for 5 minutes"
```

## Possible Common Error Scenarios

- Cloud Service Endpoint Failures

#### Cloud Service Endpoint Failures

Cloud Service Endpoint is an external dependecy of network microservice. It is used to configure allow listing service endpoint reachability. There are two kind of errors measured in alerts:

 * Configuration issues
   * Deployment could not connect to CSE (alert CseApiConnectionError)
   * Deployment failed to getting the CSE IDs for the Datacenter (alert CseIdError)
 * Connectivity or internal server errors
   * Service was unable to add items (alert CseAddError)
   * service was unable to remove items (alert CseRmError)

## Investigation and Action

##### Configuration issues

The microservice shall identify the CSE IDs for the datacenter where the master components of the customer cluster are running. 
The configuraton is stored in configmap on the carrier `service-endpoint-configmap`, and delivered through [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure).

Maybe there are some misconfiguration in the system. This can happen if service couldn't identify newly created Carrier in the datacenter. Or the Carrier is missing from `service-endpoint-configmap` config map.

 * Use XO bot for initial debuging:
    - `@xo cse.cluster CLUSTER_ID` could identify CSE related errors per cluster
    - `@xo cse.region REGION` could identify CSE related errors per region
 * Use the following Jenkins jobs to get further data: [armada-network-private-service-endpoint-operations](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-private-service-endpoint-operations/)
     - This Jenkins job is using the `armada-cse-helper` tool in an automated way
     - Please see the available OPERATIONS and select the right REGION for the Jenkins run
 * Check the logs on both network microservice and CSE (e.g. dump-cse-data operation)
 * Or use the `armada-cse-helper` tool directly, which is supposed to be installed on the carriers and provides a region configuration validation option: `armada-cse-helper validate-region-config`. See its helps for further options.
   * The tool will dump a JSON encoded result, where anything populated in the `errors` field suggests a misconfiguration of the region. Please consult the [README](https://github.ibm.com/alchemy-containers/armada-cse-helper/) of the tool.

##### Connectivity or internal server errors

The service is not able to add or remove items via CSE API. Add and remove operation errors can occure many times and they have several reasons like:

 * CSE hasn't responded in time
 * CSE server has some serious issue
 * Data is not available
 * Network error between the service and ETCD server

To detect the root cause of this type of error need to go through on the following list:

 * Check the logs on both side network microservice and CSE.
 * Make sure the network between service and CSE is working properly.

### Catch-All

For all other failures please reach out to the armada-network squad directly via Slack or create a new issue [here](https://github.ibm.com/alchemy-containers/armada-network/issues/new).  Network squad will add more scenarios to this runbook to help facilitate SRE debugging.

## Escalation Policy

Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
