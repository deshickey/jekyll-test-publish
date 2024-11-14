---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Description of CIT concepts and implementation in armada worker nodes
service: armada-bootstrap
title: Bootstrap CIT Troubleshooting Guide
runbook-name: "bootstrap-cit-troubleshooting"
link: /bootstrap-cit-troubleshooting.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

This runbook describes [Cloud Integrity Technologies (CIT)](https://github.com/opencit) components deployed in Armada Workers and common issues that may arise during the life cycle of deployment of Armada Workers with these components.

Note: The Trusted Computing project is an ongoing project in multiple phases. This document will be updated as we make changes to the architecture of the project.

Current Phase: Phase 1

## Detailed Information

The goal of the project is to use Trusted Platform Module (TPM) Chips available in certain bare metal machines as the root of a trusted security chain; the TPM module is used to perform measurements of various software components (BIOS, kernel, individual application components etc.) and those measurements are compared with the measurements obtained from a "Gold Standard" machine to attest the components running on the bare metal machine. If there is a measurement mismatch, the machine loses its "trusted" status and trusted workloads must not be scheduled on that machine.

In the context of [Armada](https://github.ibm.com/alchemy-containers/armada), the "trusted" status of a node in Kubernetes is exposed to the users via a "trusted" label on the nodes (concretely: `ibm-cloud.kubernetes.io/is-trusted: "true"`). Users will then target their kubernetes workloads to run *only* on nodes that have that label (using [nodeSelectors](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector)).

For this mechanism to reliable, we require components to monitor/measure every kubernetes node and apply the label iff the node is deemed to be trusted (and conversely to remove the label if the node loses its trusted status). For this purpose, we use a CIT Trust Server, running on master nodes and a CIT Trust Agent, running on the worker nodes. The Trust Server talks to the Trust Agents on every node. The armada-bootstrap service polls the Trust Server and applies the `"true"` label to the node if it is attested and `"false"` if its not. NOTE: if the CIT server returns `None` or an invalid response, the label is not changed. We will need to change this behavior once the CIT server becomes more reliable. Ideally, the labeling would be done by the CIT Server itself.

Note that as of phase 1, only boot time measurements are taken from the worker nodes. The plan is to take additional measurements of other runtime components in future stages.

### Trust Agent

The [trust agent](https://github.com/opencit/opencit-trustagent/tree/v3.2.1) is process that runs on the worker. Armada builds a [custom docker image](https://github.ibm.com/alchemy-containers/armada-cit-build/blob/master/cit-trust-agent/Dockerfile) which is run within a pod in `kubx-cit` namespace in the worker node. The deployment role is [here](https://github.ibm.com/alchemy-containers/armada-ansible/tree/master/kubX/roles/setup-cit-trust-agent). This component talks to the tpm module to read the various measurement from the TPM chip that were recorded at boot time. (The actual communication is done via the [tcsd agent](https://www.ibm.com/support/knowledgecenter/en/ssw_aix_72/com.ibm.aix.cmds5/tcsd.htm)).

### Boot Sequence

The following steps are required to establish a trusted node:
1. A bare metal machine with TPM/TXT enabled (and TPM ownership cleared) is selected when ordering new workers.
2. The machine is booted into a tboot enabled kernel by armada-bootstrap automation. If successful, it executes a `measured launch`.
3. Once bootstrap automation completes and the worker joins as a node in the kubernetes cluster, the trust agent pod is deployed to it.
4. The trust agent waits for the CIT server to be responsive.
5. Once it gets a response, it takes ownership of TPM chip sends the measurements taken at boot time to the CIT server in a signed packet.

## Detailed Procedure

In this section, we document the common issues with CIT-enabled clusters and attempt to provide solutions. The most common method is to simply reload the worker; this resolves 90% of the issues. The following are issues that cannot be resolved by worker reloads.

### The bare metal worker does not execute a measured launch.
See [here](./armada/armada-tpm-ownership.html)

### The tcsd agent does not start or operate correctly
The tcsd agent runs in its own container (`tcsd-daemon`). It relies on a file at `/var/libm/tpm/system.data` to persist ownership data across node reboots and possibly reloads as well.

Check the following:

1. `init-tcsd` init container has run successfully
2. `tcsd-daemon` container is running correctly

#### `init-tcsd` init container has run successfully

Check the status of the container by getting the status of the whole pod first:

```bash
$ kubectl -n kubx-cit describe po cit-trust-agent-85wcg
```
if the `init-tcsd` container has not reached:

```bash
State:          Terminated
Reason:       Completed
```

Check the logs like so:

```bash
$ kubectl -n kubx-cit logs -f  cit-trust-agent-85wcg -c init-tcsd
```
You should see a very detailed output, detailing exactly what might have gone wrong

#### `tcsd-daemon` container is running correctly

If the `init-tcsd` daemon has completed successfully, now we need to examine the container running the actual `tcsd` daemon.

Check the status of the container by getting the status of the whole pod first:

```bash
$ kubectl -n kubx-cit describe po cit-trust-agent-85wcg
```
if the `tcsd-daemon` container has not reached:

```bash
State:          Terminated
Reason:       Completed
```

Check the logs like so:

```bash
$ kubectl -n kubx-cit logs -f  cit-trust-agent-85wcg -c tcsd-daemon
```

You should see a very detailed output, detailing exactly what might have gone wrong.


### The node does not have the trusted label set to true
This is usually a sign that the trustagent did not spin up and communicate with the master.
Check the following:

1. Trust agent has successfully spun up; See the section above  
2. CIT Server has successfully spun up; See [here](https://github.ibm.com/alchemy-containers/armada-cit-build/wiki/CIT-Server)
3. Trust agent/ CIT Server can talk to each other

#### Trust agent/ CIT Server can talk to each other
You will need to make an HTTP request to the trust agents HTTP endpoint. The request looks like:

```bash
curl -o /dev/null -s -L -i -k -w "%{http_code}" -u "${MTWILSON_API_USERNAME}":"${MTWILSON_API_PASSWORD}" "https://${MTWILSON_SERVER}:${MTWILSON_SERVER_PORT}/mtwilson/v2/tpm-endorsements" -o /dev/null | grep -q "200"
```
Where the variables in capital letters must be specified. These values can be found in the `cit-server-info` configmap and secret for the cluster. e.g.

```bash
$ kubectl -n kubx-cit get cm cit-server-info -o yaml
apiVersion: v1
data:
  MTWILSON_API_USERNAME: agent
  MTWILSON_SERVER: 169.55.8.94
  MTWILSON_SERVER_PORT: "24239"
  TRUSTAGENT_ADMIN_USERNAME: tagentadmin
  server_url: https://169.55.8.94:24239
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"MTWILSON_API_USERNAME":"agent","MTWILSON_SERVER":"169.55.8.94","MTWILSON_SERVER_PORT":"24239","TRUSTAGENT_ADMIN_USERNAME":"tagentadmin","server_url":"https://169.55.8.94:24239"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"cit-server-info","namespace":"kubx-cit"}}
  creationTimestamp: 2018-03-14T17:51:13Z
  name: cit-server-info
  namespace: kubx-cit
  resourceVersion: "268970"
  selfLink: /api/v1/namespaces/kubx-cit/configmaps/cit-server-info
  uid: 49ab7c3f-27b0-11e8-a79f-3e461ae3134b
```
and

```bash
$ kubectl -n kubx-cit get secrets cit-server-info -o yaml
apiVersion: v1
data:
  MTWILSON_API_PASSWORD: xxx
  TPM_OWNER_SECRET: xxx
  TRUSTAGENT_ADMIN_PASSWORD: xxx
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"MTWILSON_API_PASSWORD":"QUQwQ0I4NDBEMkRBMDZCQTE5NjJCODVFMUU4QjlFODNFNUUxMURBRg==","TPM_OWNER_SECRET":"NzdDREE2RkExNzczM0EyMzZCODcxNENBMkExRTUxREZFQkY4OTRCRg==","TRUSTAGENT_ADMIN_PASSWORD":"NkY1MzVBN0QwRkFERTQyQTQyQjRGOUJGQTYyQzVCOTEwQUE4RUE3MA=="},"kind":"Secret","metadata":{"annotations":{},"name":"cit-server-info","namespace":"kubx-cit"}}
  creationTimestamp: 2018-03-14T17:51:13Z
  name: cit-server-info
  namespace: kubx-cit
  resourceVersion: "268971"
  selfLink: /api/v1/namespaces/kubx-cit/secrets/cit-server-info
  uid: 49af0627-27b0-11e8-a79f-3e461ae3134b
type: Opaque
```

NOTE: the secret values will be [base64 encoded](https://kubernetes.io/docs/concepts/configuration/secret/#decoding-a-secret). Decode them using the `base64 -d` command.


### The trust agent pod is not visible in the worker node

1. Check if you're using the right namespace: `kubx-cit` (e.g. `kubectl -n kubx-cit get po`)
2. Check if the daemonsets are deployed:
```bash
$ kubectl -n kubx-cit get ds
NAME              DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                              AGE
cit-trust-agent   1         1         1         1            1           ibm-cloud.kubernetes.io/tpm-enabled=true   19d
```
3. Check if any of your nodes have the right flag: `ibm-cloud.kubernetes.io/tpm-enabled=true`. This is used by the daemonset to deploy pods; if that label is absent the trust agent pods will not be deployed.

### The trust agent does not successfully spin up
There are several scenarios why the trust agent may not spin up

1. The tcsd agent is not up or working; see the section about tcsd agent above
1. CIT Server is not ready; see [here](https://github.ibm.com/alchemy-containers/armada-cit-build/wiki/CIT-Server)
1. Machine has not executed measured launch; See [here](./armada/armada-tpm-ownership.html)
1. TPM ownership was not successfully acquired; See [here](./armada/armada-tpm-ownership.html)

If all of these seem to be successful, check the logs from the `run-trust-agent` container of the `cit-trust-agent-xxxxx` (NOTE: `xxxxx` is a placeholder. Real pods will look like e.g. `cit-trust-agent-gvqx5`) pods in the `kubx-cit` namespace like so:

```bash
kubectl -n kubx-cit logs -f cit-trust-agent-xxxxx -c run-trust-agent
```
