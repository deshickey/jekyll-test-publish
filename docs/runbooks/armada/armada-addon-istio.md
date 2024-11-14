---
layout: default
description: The Istio addon control and data planes
title: Istio Addon
service: armada-deploy
runbook-name: "Istio Addon"
tags: alchemy, armada, kubernetes, armada-deploy, istio, cruiser
link: /armada/armada-addon-istio.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes the Istio addon.

## Detailed Information

The Istio addon is an optional cluster managed feature.
[Istio community](https://istio.io/) has full [docs](https://istio.io/docs/concepts/what-is-istio/).

Facts about Armada Istio:

* Istio is managed by the [istio-operator](./armada-addon-catalogsource.html).
* The istio-operator is managed by [OLM](./armada-deploy-olm.html).
* The istio-operator runs in the `ibm-operators` namespace.
* Only supported on IKS 1.16+.
* Customization are not currently allowed.
* Patch updates are handled automatically (e.g. 1.4.0->1.4.1).
  * These are implemented as a new version of the `istio-operator` which handles the update.
* To check the version of the operator:
  * Check the version of the csv associated with the operator
  ```
  kubectl -n ibm-operators get csv -o jsonpath='{.spec.version}'
  ```
* Istio has many Custom Resource Definitions. `kubectl get crd`
* Supported only for Cruisers, but can work in a Patrol for now.
* [Istio build repo](https://github.ibm.com/alchemy-containers/addon-istio)
* [Istio operator repo](https://github.ibm.com/alchemy-containers/addon-istio-operator-data)

## Istio Addons

To tell which Istio addons are enabled for this cluster, run:

```
ibmcloud ks cluster addons <CLUSTERID>
```

If no Istio addons are installed, it was probably installed manually from the community.
The following are the Istio addons.

### Istio

* addon name: `istio`
* Runs in the `istio-system` namespace
* has these pods running:
  * istio-egressgateway
  * istio-ingressgateway
  * istiod

## Istio Control Command

Istio provides a CLI, `istioctl`, that allows easier viewing of some of the Istio
resources.

For example, to view the Istio virtual services:

`istioctl get virtualservices`

## Problems and Solutions:
### Diagnose deployment

`IF` this is a ROKS cluster, `THEN` triage as any other ROKS issue. Addon-istio is not on ROKS clusters. This runbook does not apply.

`ELSE`, `IF` Addon-istio is not enabled, `THEN` this is not an addon-istio issue. The customer is using their own istio which is not supported as part of addon-istio.
```
ibmcloud ks cluster addon ls --cluster <CLUSTERID>
or check armada-xo with `addon <CLUSTERID>/addon-istio`
```

`ELSE`
Get the addon version and the list of supported versions
```
ibmcloud ks cluster addon ls --cluster <CLUSTERID>
or check armada-xo with `addon <CLUSTERID>/addon-istio`
ibmcloud ks addon-versions --addon istio
```

`IF` the addon version is not supported, `THEN` have the user upgrade to a supported version. N+1 upgrades are supported.
`IF` they are at the latest unsupported version, `THEN` they can do an N+1 upgrade
```
ibmcloud ks cluster addon update istio --version <NextVersion> -c <CLUSTERID>
```
`ELSE` they are too old for an N+1 upgrade to get on a supported version. The user would need to disable the old version, wait for it to uninstall, and then install the new version.
```
ibmcloud ks cluster addon disable istio -c <CLUSTERID>
ibmcloud ks addon-versions --addon istio
ibmcloud ks cluster addon enable istio --version <Version> -c <CLUSTERID>
```

`ELSE`, since addon-istio is enabled and is on a supported version, check the control plane pods are ready and the istio operator is present and running
```
# List addon-istio deployment pods and resources
# Control plane pods. There are usually 2 of each but there can be more.
kubectl get pod -n istio-system -l istio=pilot -o wide # Finds the istiod pods
kubectl get pod -n istio-system -l istio=egressgateway -o wide
kubectl get pod -n istio-system -l istio=ingressgateway -o wide
# Istio Operator
kubectl get csv -n ibm-operators -l addon.name=istio
kubectl get pod -n ibm-operators  -l name=managed-istio-operator
kubectl get iop -n ibm-operators managed-istio 
kubectl get cm -n ibm-operators  managed-istio-custom 
```
`IF` one of these problems, `THEN` go to that section
<br/>[Is the operator pod missing?](#istio-operator-pod-is-missing)
<br/>[Is the IOP missing?](#istiooperator-cr-is-missing)
<br/>[Is a gateway pod missing?](#istio-gateway-pod-is-missing)
<br/>[Are the control plane pods not ready?](#are-the-control-plane-pods-not-ready)

`ELSE`, addon-istio looks fine. The problem is elsewhere

### Istio operator pod is missing
Check for the install path resources
`IF` the version of addon-istio is 1.10+ `THEN`
Resource listed in reverse order
```
# Istio Operator
kubectl get deploy -n ibm-operators addon-istio-operator
```

`IF` the deployment for the istio operator is missing `THEN` Check cluster updater for errors. Cluster Updater is responsible for laying down the Deployment. Razee team owns cluster updater errors. `IF` cluster updater has no problems `THEN` contact armada-istio-team in #managed-istio during normal business hours.

`ELSE` Since the version of addon-istio is in the range 1.4 thru 1.9 `THEN`
Resource listed in reverse order
```
# OLM pods
kubectl get pod -n ibm-system -l app=olm-operator
kubectl get pod -n ibm-system -l app=catalog-operator
# Addon catalog source pod
kubectl get catsrc -n ibm-system addon-catalog-source
kubectl get cm -n ibm-system addon-catalog-manifests
kubectl get pod -n ibm-system -l olm.catalogSource=addon-catalog-source
# Istio Operator 
kubectl get subscriptions.operators.coreos.com -n ibm-operators istio
kubectl get csv -n ibm-operators -l addon.name=istio
kubectl get deploy -n ibm-operators managed-istio-operator 
```
`IF` The OLM pods not ready? `THEN` Describe the pod and get its logs.
```
kubectl describe pod podName -n ibm-system
kubectl logs podName
```
From the events in the describe or the errors in the logs you might identify the problem.
`IF` you don't identify the problem, `THEN` ask the user to do a master refresh.
`IF` the pods OLM pods don't become ready, `THEN` contact armada-istio-team in #managed-istio during normal business hours.


`ELSE` `IF` the addon catalog source pod is not ready. `THEN` Describe the addon catalog source pod and get the logs of the catalog source pod and the catalog-operator pod. From the events in the describe or the errors in the logs you might identify the problem. `IF` you don't identify the problem, `THEN` Delete the addon catalog source pod to see if the problem persists. `IF` the addon catalog source pod does not become ready, `THEN` contact armada-istio-team in #managed-istio during normal business hours.


`ELSE` `IF` the OLM pods ready and the addon catalog source pod is ready but the CSV is not present? `THEN` Delete the subscription
```
kubectl delete subscriptions.operators.coreos.com -n ibm-operators istio
```
Cluster Updater will regenerate the subscription. That might get a new CSV.


`IF` the CSV is still missing `THEN` the addon catalog source pod and the catalog operator pod are having trouble communicating. This could be a network issue. Get the logs of the catalog operator pod. Add the catalog operator logs to the ticket. Check for network issues. Contact armada-istio-team in #managed-istio during normal business hours.

### IstioOperator CR is missing
Check cluster updater for errors. It is responsible for laying down the IOP. Razee team owns cluster updater errors. `IF` cluster updater has no problems `THEN` contact armada-istio-team in #managed-istio during normal business hours.

### Istio gateway pod is missing
The default istio-egressgateway and istio-ingressgateway pods can be disabled by a customization. Check the customizations in the data field of the managed-istio-custom configmap in the ibm-operators namespace.
```
# You can read the documentation with this command
kubectl describe cm -n ibm-operators managed-istio-custom
# You can see the configs without the documentation with this command
kubectl get cm -n ibm-operators managed-istio-custom -o json | jq 'del(.data."_example").data'
# These key value pairs disable the default egress and ingress respectively
istio-egressgateway-public-1-enabled: "false"
istio-ingressgateway-public-1-enabled: "false"
# Also check the IstioOperator custom resource (the iop for short) to see the configs in the iop.
kubectl get iop -n ibm-operators managed-istio -o json | jq .spec.components.ingressGateways[].name
kubectl get iop -n ibm-operators managed-istio -o json | jq .spec.components.ingressGateways[].enabled
kubectl get iop -n ibm-operators managed-istio -o json | jq .spec.components.egressGateways[].name
kubectl get iop -n ibm-operators managed-istio -o json | jq .spec.components.egressGateways[].enabled
```

If all those configs are valid (see the documentation) then they get passed on to the istio operator by cluster updater updating the IstioOperator CR (the iop) and the istio operator pod reconciling the IOP. If the configs are not valid, then the current configurations might not reach the istio operator. The user is responsible for the configurations being valid.

If the istio-egressgateway or istio-ingressgateway are missing because they are disabled, that is okay.
If they are not set to be disabled but are not present, then either something is invalid in those configs or either the istio operator pod or IOP are missing.
<br/>[Is the operator pod missing?](#istio-operator-pod-is-missing)
<br/>[Is the IOP missing?](#istiooperator-cr-is-missing)

If the istio operator pod and the IOP are both present, and the gateway is missing, but not disabled, check if the istio operator pod is able to reconcile the IstioOperator CR. 
```
kubectl  get iop -n ibm-operators managed-istio -o json | jq .status
kubectl logs <operator-pod>  -n ibm-operators | grep -i error
```
`IF` the error is not similar to "failed to merge base profile with user IstioOperator CR managed-istio". `THEN` contact armada-istio-team in #managed-istio during normal business hours.
`ELSE` the error is similar to "failed to merge base profile with user IstioOperator CR managed-istio"
```
Example 1:
error        installer        failed to merge base profile with user IstioOperator CR managed-istio, unknown field "ExampleFieldName" in v1alpha1.GlobalConfig
Example 2:
error        installer        failed to merge base profile with user IstioOperator CR managed-istio, failed to unmarshall mesh config: unknown value "ExampleValue" for enum
```
To find these unknown fields / values look at the IstioOperator CR managed-istio's yaml. The error message tells you where to look.
The first error means there is an unknown field "ExampleFieldName" under the global section of the IOP's spec. If the field was elsewhere the error would mention the immediate parent section.
The second error means the value of the meshConfig field was an invalid value. If the value was elsewhere, the error would mention the immediate parent section.
```
kubectl get iop managed-istio -n ibm-operators -o yaml
```
These both mean the spec of the IstioOperator CR (the iop) has an invalid config. That could be caused by the user's customizations in the customization configmap.Tell the user where the invalid field/value was in the IOP. Tell the user to backup their configs from the customization configmap and delete the customization configmap. When it regenerates they can read the documentation and add the configs back. This will remove the zone labels from the customization configmap. The user should add them back as part of adding the configs back, or you can [restart the job that added them](#zone-labels-missing-from-customizations).


`THEN`
Once the config has been fixed, check whether the gateway pod starts coming up. There is a delay as the configs get reconciled by Cluster Updater, and then reconciled by the istio-operator.
```
kubectl get pod -n istio-system`
```
`IF` The control plane pods being created but are not ready, `THEN` go to [Are the control plane pods not ready?](#are-the-control-plane-pods-not-ready).
`ELSE` `IF` the pods are still missing despite not being disabled and the istio operator successfully reconciling the IstioOperator, `THEN` contact armada-istio-team in #managed-istio during normal business hours.

### Are the control plane pods not ready

Describe the pod to get the events and get the logs of the not ready pod(s)
```
kubectl describe pod <podname> -n istio-system
kubectl logs <podname> -n istio-system
```
`IF` the ingressgateway pod does not match the node selector, like in the example below, `THEN` the zone customization might not be set. Go to [zone labels missing from customizations](#zone-labels-missing-from-customizations) and return.
```
Warning  FailedScheduling  25s (x4 over 3m15s)  default-scheduler  0/3 nodes are available: 3 node(s) didn't match node selector.
```
`ELSE` try deleting the pod. It should come back from the deployment.
```
kubectl delete pod <podname> -n istio-system
```

`IF` the pod does not come back ready, `THEN` try deleting the old replicasets for the pod. Then delete the deployment. Don't delete the replicset of any ready pod, just the old replicasets that don't have pods and the replicaset corresponding to the pods that are not ready.
```
kubectl get deploy -n istio-system
kubectl get replicaset -n istio-system
```

`IF` the pod does not become ready, `THEN` contact armada-istio-team in #managed-istio during normal business hours.  This is a problem with the user resources or with networking/load balancers. We will need to ask istio-opensource-team to help identify what is wrong.


### Zone labels missing from customizations
Check the customizations in the data field of the managed-istio-custom configmap in the ibm-operators namespace.
```
# You can read the documentation with this command
kubectl describe cm -n ibm-operators managed-istio-custom
# You can see the configs without the documentation with this command
kubectl get cm -n ibm-operators managed-istio-custom -o json | jq 'del(.data."_example").data'
# In Managed Istio 1.8+ ingress requires zone key value pairs
istio-ingressgateway-zone-1: "dal10" # As an example.
```


`IF` the zone key value pairs are missing on Managed Istio 1.8+, `THEN` run these steps and continue with the runbook
```
1. kubectl get secret -n istio-system istio.istio-citadel-service-account # Ignore not found
2. kubectl delete secret -n istio-system istio.istio-citadel-service-account --ignore-not-found
3. kubectl get pod -n ibm-system -l addon.cleanup=istio
4. kubectl delete pod -n ibm-system -l addon.cleanup=istio
5. kubectl get job -n ibm-system -l addon.cleanup=istio
6. kubectl delete job -n ibm-system -l addon.cleanup=istio
7. Cluster Updater will regenerate the job and pod that will add the zone labels to the customization configmap. 
8. Return to previous section.
```

### Istio-operator still running in ibm-operators namespace after disable

Istio is now deployed by the `istio-operator` which exists as a pod running in the `ibm-operators` namespace. 

After disabling the Istio addon on a cluster, the `istio-operator` will continue running and will not be removed automatically.

`IF` the operator needs to be removed `THEN` The cluster owner is able to delete the operator by following the [ibmcloud docs for uninstalling the addon istio operator](https://cloud.ibm.com/docs/containers?topic=containers-istio#istio_uninstall_operator).

### Workers not Available and istio-system namespace stuck in terminating

Istio installs a webhook to handle sidecar proxy injection.  This can effect other
pods and prevent workers from coming online.

This may also prevent the istio-system namespace from terminating.

With the sidecar injection enabled, but no Istio pods running to handle the webhook, the cluster
cannot start any pods.

A workaround is to temporarily modify the istio-sidecar-injector mutating webhook configuration so that it ignores and not fails. Follow these steps.

* View the information for the cluster.  Use the [armada-deploy-get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job

* Check the **MUTATING WEBHOOK CONFIGURATIONS** section
```
Name:         istio-sidecar-injector
...
  Failure Policy:  Fail
```

If no `istio-sidecar-injector` are present, this is some other issue.

* Check the **CLUSTER NAMESPACES** section, the namespace may be terminating

```
NAME             STATUS        AGE
...
istio-system     Terminating   2d17h
```

If the namespace is terminating, probably want to remove the MutatingWebhookConfiguration

`kubectl delete MutatingWebhookConfiguration istio-sidecar-injector`

The namespace should finish terminating after this webhook is removed.

* Check the **CLUSTER DEPLOYMENTS** section, no pods available for `istio-sidecar-injector`

```
NAMESPACE      NAME                                             READY   UP-TO-DATE   AVAILABLE
...
istio-system   istio-sidecar-injector                           0/1     0            0
```

If the pod is not available, try updating the web hook to allows pods to start.

```
kubectl edit MutatingWebhookConfiguration istio-sidecar-injector
```

Change failurePolicy to **Ignore**, save, and close.

The istio-system namespace will terminate.  The workers will go to Ready.

## More Help
If you need any further instruction on this topic, please visit the following:

* [Wiki](https://github.ibm.com/alchemy-containers/armada-istio/wiki)
* Slack channel: [#managed-istio](https://ibm-argonauts.slack.com/messages/CFB9LETDF)
