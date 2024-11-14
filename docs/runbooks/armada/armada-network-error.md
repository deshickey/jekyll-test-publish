---
layout: default
description: How to troubleshoot errors thrown by armada-network microservice.
title: armada-network - How to troubleshoot errors thrown by armada-network microservice.
service: armada
runbook-name: "armada-network - How to troubleshoot errors thrown by armada-network microservice"
tags: network, microservice
link: /armada/armada-network-error.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to troubleshoot errors thrown by the armada-network microservice. Alerts are triggered when specific errors are generated and aggregated across nodes. Too many errors generated over a minute will trigger the alert.

## Example alert

```
summary = "too many Error Setting Processed Key errors have occured over the last minute"
description = "20 Error Setting Processed Key errors have occured over the last minute. Dependency marked as etcd"
```

## Investigation and Action

Alerts in the armada-network microservice are composed of two important pieces of information- the error description and the dependency associated with the error.  Operations in the network-microservice will retry 50 times before completely failing out.

## Where to Find Logs (Initial Troubleshooting)

Logs for the network microservice are published to Slack (similar to the way the armada-deploy squad posts their log messages):

- Pre-Production Successes [here](https://ibm-argonauts.slack.com/archives/CED7WDR55)
- Pre-Production Failures [here](https://ibm-argonauts.slack.com/archives/C015MBFJBR7)
- Pre-Production Attempts [here](https://ibm-argonauts.slack.com/archives/C01DN4VP1J9)
- Production Successes [here](https://ibm-argonauts.slack.com/archives/CEDC62E9M)
- Production Failures [here](https://ibm-argonauts.slack.com/archives/C0158UWLDJ7)
- Production Attempts [here](https://ibm-argonauts.slack.com/archives/C01EF2ZS16U)


Visiting one of the above channels and searching for the Cluster ID will provide links to logs that can be vital in searching what happened to cause this failure.

## Possible Common Error Scenarios

- Cluster Secret Update Errors
- LBaaS Delete Failures
- "networkViewer" Failures (Generic error with armada-provider library)
- Create calicocfg failures

### Cluster Secret Errors

```
50 Error creating the cluster secret errors have occurred over the last minute.
```

If you see these errors, this is most likely the result of a failure to POST the cluster secret to the armada cluster-store.

Please verify that the `cluster-store` pods are running in the armada namespace on the carrier in question.

The network microservice retries this operation 3 times per attempt and 50 attempts are made with 15 minute sleeps between each attempt.  If the cluster-store pods are troubled and return to a good state, the operation will complete itself and resolve the alert.

If the alert does not resolve, escalate to the network squad escalation policy.

### LBaaS Deletion Errors

LBaaS deletion failures are largely dependent on conditions in the customer account.  They happen after clusters have reached a `ActualState: deleted` state.

#### networkViewer Failures

```
12 networkViewer fault occurred errors have occurred over the last minute.
```

Depending on the specific error (see above about microservice logs), these can mean different things.

Known Scenarios:

- `error	fault found	{"fault": {"msg":"The IAM token exchange request failed with the message: Provided API key could not be found","code":"ErrorFailedTokenExchange"`

If this error occurs, the IAM Token exchange has failed because of a possible suspended account or bad permissions.  The problem is largely out of our (IKS) hands and the IAM credentials problem will have to be worked by the customer.

Please create an issue [here](https://github.ibm.com/alchemy-containers/armada-network/issues/new) with the Cluster ID and the network squad will take action by contacting the cluster owner.

### Create Calicocfg Failures

```
42.66666666666667 Failed to create calicocfg errors have occurred over the last minute.
```

Depending on the specific error (see above about microservice logs), these can mean different things.

Known Scenarios:
- `error missing info needed to create rest config (CACert,AdminCert,ServerURL,AdminKey) can not set labels without them cluster: <clusterID>`

If this error occurs, it generaly means that either the cluster is in too early of a deploying stage to have those values filled in etcd or cluster failed to properly deploy and we need to reach out to either deploy/update team to figure out why these values are not filled??

- Permission denied to create/write/close /tmp directory or file errors:
```
{"level":"warn","ts":1647885968.2815156,"caller":"common/common.go:179","msg":"There was an error in creating NetworkLogsDir: mkdir /tmp: permission denied\n","crn":"crn:v1:staging:public:containers_kubernetes:CRN_REGION:CRN_INFRA_ID:containers_kubernetes:CRN_SERVICE_ID:log","podName":"armada-network-666f4c6879-6z5vx","ServiceName":"armada-network-orchestrator","UUID":"69f7947e-e1c7-45ea-abbe-cd2bcce38cdc"}
```
```
{"level":"error","ts":1647885971.5635953,"caller":"common/common.go:317","msg":"Unable to create temp calico configuration file","crn":"crn:v1:staging:public:containers_kubernetes:CRN_REGION:CRN_INFRA_ID:containers_kubernetes:CRN_SERVICE_ID:log","podName":"armada-network-666f4c6879-6z5vx","ServiceName":"armada-network-orchestrator","UUID":"69f7947e-e1c7-45ea-abbe-cd2bcce38cdc","stacktrace":"github.ibm.com/alchemy-containers/armada-network-microservice/common.CreateCalicoCfg\n\t/home/travis/gopath/src/github.ibm.com/alchemy-containers/armada-network-microservice/common/common.go:317\ngithub.ibm.com/alchemy-containers/armada-network-microservice/jobs.(*HostEndpointCleanupJob).Run\n\t/home/travis/gopath/src/github.ibm.com/alchemy-containers/armada-network-microservice/jobs/host_endpoint_cleanup_job.go:119\ngithub.ibm.com/alchemy-containers/armada-utils/routinepool.(*worker).Start.func1\n\t/home/travis/gopath/pkg/mod/github.ibm.com/alchemy-containers/armada-utils@v1.9.13/routinepool/worker.go:52"}

{"level":"error","ts":1647885971.5636518,"caller":"common/handlers.go:32","msg":"Failed to create calicocfg","crn":"crn:v1:staging:public:containers_kubernetes:CRN_REGION:CRN_INFRA_ID:containers_kubernetes:CRN_SERVICE_ID:log","podName":"armada-network-666f4c6879-6z5vx","ServiceName":"armada-network-orchestrator","UUID":"69f7947e-e1c7-45ea-abbe-cd2bcce38cdc","error":"open /tmp/calicfg1987579734: no such file or directory","stacktrace":"github.ibm.com/alchemy-containers/armada-network-microservice/common.(*FailHandler).FailJob\n\t/home/travis/gopath/src/github.ibm.com/alchemy-containers/armada-network-microservice/common/handlers.go:32\ngithub.ibm.com/alchemy-containers/armada-network-microservice/jobs.(*HostEndpointCleanupJob).Run\n\t/home/travis/gopath/src/github.ibm.com/alchemy-containers/armada-network-microservice/jobs/host_endpoint_cleanup_job.go:124\ngithub.ibm.com/alchemy-containers/armada-utils/routinepool.(*worker).Start.func1\n\t/home/travis/gopath/pkg/mod/github.ibm.com/alchemy-containers/armada-utils@v1.9.13/routinepool/worker.go:52"}
```

If this error occurs, there was a permission change in network-microservice image or deployment either through a new code change or manually by SREs/someone else that is preventing the network-microservice to create temporary files to store the logs and post it to the COS. If the cause was a new code change, escalate to the network-squad as it will need to be reverted or a new code change will be required to rectify this. If not figure out what happened to the image permissions.

- One of the other causes of this error could be that `Kubectl` commands are not working on this cluster due to other unknown reasons and network-microservice is having trouble generating the calico/kube config for the cluster. In that case, try to start the investigation with [armada network troubleshooting runbook](./armada-network-initial-troubleshooting.html).

### Catch-All

For all other failures please reach out to the armada-network squad directly via Slack or create a new issue [here](https://github.ibm.com/alchemy-containers/armada-network/issues/new).  Network squad will add more scenarios to this runbook to help facilitate SRE debugging.

## Escalation Policy

Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
