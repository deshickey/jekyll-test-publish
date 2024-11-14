---
layout: default
description: "[Troubleshooting] Cluster DNS"
title: "[Troubleshooting] Cluster DNS"
runbook-name: "[Troubleshooting] Cluster DNS"
service: armada
tags: armada, armada-network, containers, kubernetes, kube, kubectl, network, DNS, CoreDNS, KubeDNS, NodeLocal, cache
link: /armada/armada-network-dns-troubleshooting.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook covers troubleshooting legacy carrier, tugboat or cruiser
cluster DNS problems related to CoreDNS, KubeDNS or NodeLocal DNS Cache.
This runbook does NOT cover troubleshooting OpenShift cluster DNS.
Cluster DNS problems can manifest themselves in many ways so please note
the popular DNS haiku when reviewing this runbook. If unable to resolve the
cluster DNS problems, see the [escalation policy](#escalation-policy).

```
It's not DNS
There's no way it's DNS
It was DNS
```

## Example Alerts

This is a general troubleshooting runbook and is not related to any specific alerts.

## Investigation and Action

### Determine Cluster DNS Setup

There are several options for configuring the cluster DNS. Tugboat and cruiser
clusters run CoreDNS while legacy carriers currently run KubeDNS. Clusters can
optionally run NodeLocal DNS Cache on one or more nodes. There is also an
advanced Zone Aware DNS configuration. You can run the following commands to
determine the cluster DNS setup. For more information on these configuration options, see
[Configuring the cluster DNS provider](https://cloud.ibm.com/docs/containers?topic=containers-cluster_dns).

```
kubectl get services -n kube-system | grep dns
kubectl get deployments -n kube-system | grep dns
kubectl get daemonsets -n kube-system | grep dns
```

### Basic DNS Verification

1. Verify that the cluster DNS services exists. If either of the services do not
   exist then the cluster master needs to be refreshed via
   `ibmcloud ks cluster master refresh` for tugboats and cruisers or via
   [deploy for legacy carriers](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/).
   Once the refresh completes, the services should exist.

   ```
   kubectl get service -n kube-system kube-dns
   kubectl get service -n kube-system node-local-dns
   ```

1. Verify that the `kube-dns` service uses cluster IP address at index `10`
   in the Kubernetes service IP range. For reference, the `kubernetes` service
   uses cluster IP address at index `1`. If the `kube-dns` service is not
   using the correct cluster IP address then escalate per the policy.

   ```
   kubectl get service -n default kubernetes -o jsonpath={.spec.clusterIP}
   kubectl get service -n kube-system kube-dns -o jsonpath={.spec.clusterIP}
   ```

1. Verify that the cluster DNS services have valid endpoints. The endpoint IP
   addresses must match the pod IP addresses. If they do not match then
   [restart the cluster DNS pods](#restart-cluster-dns-pods). Once the restart
   has completed, the endpoint IP addresses should match.

   ```
   kubectl describe endpoints -n kube-system kube-dns
   kubectl describe endpoints -n kube-system node-local-dns
   kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
   ```

### Check DNS Pod Logs

Check recent pod logs for errors. If any errors are found then
[restart the cluster DNS pods](#restart-cluster-dns-pods).

Run the following command to check for CoreDNS errors.

```
timeout 60 kubectl logs -n kube-system -l k8s-app=kube-dns --timestamps=true --tail=100 | grep -i -e panic -e error
```

Run the following command to check for NodeLocal DNS Cache errors.

```
timeout 60 kubectl logs -n kube-system -l k8s-app=node-local-dns --timestamps=true --tail=100 | grep ERROR
```

### Verify DNS on a Node

You can use the following commands to run a basic DNS availability test on a
specific node. Use [Verify DNS on All Nodes](#verify-dns-on-all-nodes) if
you suspect cluster wide DNS problems.

Set `NODE_NAME` to the node name returned by `kubectl get nodes` then start the
test pod.

```
NODE_NAME="A.B.C.D"
POD_NAME="node-dns-test-${NODE_NAME}"
kubectl apply -f - << EOF
apiVersion: v1
kind: Pod
metadata:
  name: ${POD_NAME}
  namespace: kube-system
spec:
  nodeName: ${NODE_NAME}
  restartPolicy: OnFailure
  containers:
  - name: node-dns-test
    image: us.icr.io/armada-test/agnhost:2.43
    command:
    - /bin/sh
    - -c
    - sleep 1 ; while true ; do sleep 0.25 ; curl -k --max-time 10 --connect-timeout 7 https://kubernetes.default.svc.cluster.local/version && curl -k --max-time 10 --connect-timeout 7 https://storage.googleapis.com/kubernetes-release/release/stable.txt && echo DNS test on node ${NODE_NAME} was successful! ; done
EOF
```

Wait for the test pod to start running then let it run for a few minutes.
If the test pod never starts, consider the test a failure.

```
kubectl get pods -n kube-system "${POD_NAME}" --no-headers
sleep 180
```

Collect the test results (i.e. count of successful DNS requests) and delete the
test pod.

```
timeout 60 kubectl logs -n kube-system "${POD_NAME}" | grep -c successful
kubectl delete pod -n kube-system "${POD_NAME}" --wait=false --ignore-not-found=true
```

Run this test 3 to 5 times. If all of the test runs failed then the node should
be rebooted or reloaded. If at least one test run failed then
[restart the cluster DNS pods](#restart-cluster-dns-pods) and rerun the test.

### Verify DNS on All Nodes

You can use the following commands to run a basic DNS availability test on all
nodes in the cluster.

```
kubectl apply -f - << EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    run: node-dns-test
  name: node-dns-test
  namespace: kube-system
spec:
  selector:
    matchLabels:
      run: node-dns-test
  template:
    metadata:
      labels:
        run: node-dns-test
    spec:
      tolerations:
      - operator: "Exists"
      containers:
      - name: node-dns-test
        image: us.icr.io/armada-test/agnhost:2.43
        command:
        - /bin/sh
        - -c
        - sleep 1 ; while true ; do sleep 0.25 ; curl -k --max-time 10 --connect-timeout 7 https://kubernetes.default.svc.cluster.local/version && curl -k --max-time 10 --connect-timeout 7 https://storage.googleapis.com/kubernetes-release/release/stable.txt && echo DNS test was successful! ; done
EOF
```

Wait for the test pods to start running then let them run for a few minutes.
If some of the test pods never start, consider the test a failure for those nodes.

```
kubectl get pods -n kube-system -l run=node-dns-test --no-headers
sleep 360
```

Collect the test results (i.e. count of successful DNS requests) and delete the
test pods.

```
for POD_NAME in $(kubectl get pods -n kube-system -l run=node-dns-test --no-headers | awk '{print $1}'); do
    kubectl get pods -n kube-system "${POD_NAME}" -o wide --no-headers
    timeout 60 kubectl logs -n kube-system "${POD_NAME}" | grep -c successful
done
kubectl delete ds -n kube-system node-dns-test
```

If this test does not succeed on a small subset of nodes then follow
[Verify DNS on a Node](#verify-dns-on-a-node). If the test is failing on a large
number of nodes then [restart the cluster DNS pods](#restart-cluster-dns-pods)
and rerun the test. If the test still fails after the restart, there may be
an underlying networking problem or you may need to
[scale up the number of cluster DNS pods](#scale-up-cluster-dns). More
investigation is required. Escalate per the policy.

### Restart Cluster DNS Pods

Determine the cluster DNS deployments and daemonsets that need to have their
pods restarted. Only restart those resources that expect to have running pods.

```
kubectl get deployments -n kube-system | grep dns
kubectl get daemonsets -n kube-system | grep dns
```

Restart the cluster DNS deployments and daemonsets using the following commands:

```
CLUSTER_DNS_DEPLOYMENT="CHANGEME"
kubectl rollout restart deployment -n kube-system "${CLUSTER_DNS_DEPLOYMENT}"
kubectl rollout status deployment --watch=false -n kube-system "${CLUSTER_DNS_DEPLOYMENT}"
```

```
CLUSTER_DNS_DAEMONSET="CHANGEME"
kubectl rollout restart daemonset -n kube-system "${CLUSTER_DNS_DAEMONSET}"
kubectl rollout status daemonset --watch=false -n kube-system "${CLUSTER_DNS_DAEMONSET}"
```

If the rolling restarts do not complete after about 10 minutes then check the
status of the DNS pods that are not running. The cluster may have one or more worker
nodes that need to either be rebooted or reloaded before the restart will complete.

```
kubectl get nodes -o wide | grep -e NotReady -e SchedulingDisabled
kubectl get pods -n kube-system -o wide | grep dns | grep -v Running
kubectl describe pod -n kube-system POD_NAME
```

### Scale Up Cluster DNS

For cruiser clusters, see [Autoscaling the cluster DNS provider](https://cloud.ibm.com/docs/containers?topic=containers-cluster_dns#dns_autoscale).
Cluster DNS scaling for legacy carriers and tugboats is controlled via
configurations in [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure).

## Escalation Policy

If unable to resolve the cluster DNS problems, escalate to the `armada-network` squad:

  * Escalation Policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack Channels: [#armada-dev](https://ibm-argonauts.slack.com/archives/C56K90989), [#armada-network](https://ibm-argonauts.slack.com/archives/C53P0HNDS)
  * GHE Issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
