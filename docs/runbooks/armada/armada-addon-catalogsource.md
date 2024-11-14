---
layout: default
title: How OLM Catalog provides an Operator
type: Informational
runbook-name: "How OLM Catalog provides an Operator"
description: How OLM CatalogSource is used to setup an Operator
service: armada-deploy
tags: alchemy, armada, kubernetes, armada-deploy, olm, OLM, catalog, operator, istio, cruiser
link: /armada/armada-addon-catalogsource.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes the interconnection between the resources needed to get an Operator deployed from the Catalog and then trigger the Operator with its CustomResource.

OLM is only available on clusters with a kube version of 1.16 or later.

Istio is the only operator based addon at this time.

[OLM](https://github.com/operator-framework/operator-lifecycle-manager)
[Operator SDK](https://github.com/operator-framework/operator-sdk)


## Detailed Information
The Catalog Operator along with the OLM Operator is responsible for installing Operators and CustomResourceDefinitons for Operators the cluster has a Subscription for. OLM uses ClusterServiceVersions as a representation for an Operator's deployment yaml with some other information baked in to make OLM's job easier.


### The CatalogSource
The CatalogSource is responsible for correlating Operators with a channel that a Subscription can reference. The IKS CatalogSource is named "addon-catalog-source" and has a ConfigMap named "addon-catalog-manifests" which contains ClusterServiceVersions (CSV), CustomResourceDefinitons (CRD), and Packages for each Operator. Each Package has a Channel which references a CSV by version. Each CSV has a section referencing all the CRDs it owned. This lets the CatalogSource correlate the Channel to the CSV and CRDs it references.

### The Subscription
The Subscription is responsible for telling Catalog Operator which Operator to install from its CatalogSource by referencing a channel in Catalog Source. The Subscription finds the CatalogSource by namespace and name, then it queries the CatalogSource by package and channel. If the Subscription finds the CatalogSource, and the CatalogSource finds the channel, then the CatalogSource will tell Catalog Operator the CSV and CRDs to install. The Subscription will check back on the CatalogSource every so often to see if there is a relevant change to the channel.

### The Custom Resource
Once an Operator is installed, its Custom Resource is used to trigger the Operator to setup whatever it needs to. The Operator is watching a namespace for CustomResource(s) of the type(s) specified by the owned & required CRDs in the CSV the Operator came from. Once the CR exists, the Operator should see it and act to setup that CustomResource. Consider Istio, istio-operator, and its CR IstioControlPlane:

## How to Verify IstioControlPlane is working
You can verify the IstioControlPlane named managed-istiocontrolplane got setup correctly by checking its logs. The status fields at the bottom status.status._____.statusString will describe which components of the control plane are Healthy or not.


`$ kubectl get <CR Kind> -n ibm-operators <CR Name> -o yaml`

`$ kubectl get icp -n ibm-operators managed-istiocontrolplane -o yaml`
```
apiVersion: install.istio.io/v1alpha2
kind: IstioControlPlane
status:
  status:
    Citadel:
      status: 2
      statusString: HEALTHY
```

## How to Verify OLM and Catalog is working
You can verify everything is working by checking which CustomResources exist on the cluster in the ibm-operators and ibm-system namespaces.

`$ kubectl get crd   -o name | cut -d/ -f2 | xargs -n 1 kubectl get --show-kind --ignore-not-found -o name -n ibm-system`
```
catalogsource.operators.coreos.com/addon-catalog-source
meshpolicy.authentication.istio.io/default
operatorgroup.operators.coreos.com/olm-operators
```
`$ kubectl get crd   -o name | cut -d/ -f2 | xargs -n 1 kubectl get --show-kind --ignore-not-found -o name -n ibm-operators`
```
clusterserviceversion.operators.coreos.com/istio-operator.v0.0.1
installplan.operators.coreos.com/install-2g59v
istiocontrolplane.install.istio.io/managed-istiocontrolplane
meshpolicy.authentication.istio.io/default
operatorgroup.operators.coreos.com/ibm-operators
subscription.operators.coreos.com/istio
```
It is expected to find a CatalogSource in the ibm-system namespace and all three of Subscription, CSV, and IstioControlPlane in the ibm-operators namespace. 

You can verify CatalogSource is setup correctly by checking if it's pod is Running and if the CatalogSource CR itself is READY. In testing it took 2 minutes for CatalogSource to become ready after the cluster was deployed and in Normal state and the addon-catalog-manifests ConfigMap existed.<br>

`$ kubectl get -n ibm-system pod -l olm.catalogSource=addon-catalog-source`
```
NAME                         READY   STATUS    RESTARTS   AGE
addon-catalog-source-2bzh8   1/1     Running   0          78m
```
`$ kubectl get -n ibm-system catalogsource addon-catalog-source -o yaml`
```
status:
  connectionState:
    address: addon-catalog-source.ibm-system.svc:50051
    lastConnect: "2019-11-06T17:36:34Z"
    lastObservedState: READY
```

If CatalogSource is not ready, you can check its logs for information on what it considers invalid about its ConfigMap.

`$ kubectl logs -n ibm-system -l olm.catalogSource=addon-catalog-source`
```
time="2019-11-06T17:34:04Z" level=info msg="Using in-cluster kube client config"
time="2019-11-06T17:34:04Z" level=info msg="loading CRDs" configmap=addon-catalog-manifests ns=ibm-system
time="2019-11-06T17:34:04Z" level=info msg="loading Bundles" configmap=addon-catalog-manifests ns=ibm-system
time="2019-11-06T17:34:05Z" level=info msg="loading Packages" configmap=addon-catalog-manifests ns=ibm-system
time="2019-11-06T17:34:05Z" level=info msg="extracting provided API information" configmap=addon-catalog-manifests ns=ibm-system
time="2019-11-06T17:34:05Z" level=info msg="serving registry" configMapName=addon-catalog-manifests configMapNamespace=ibm-system port=50051
```
`$ kubectl get -n ibm-system catalogsource addon-catalog-source -o yaml`
```
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  annotations:
    version: 1.0.0_567
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
  name: addon-catalog-source
  namespace: ibm-system
spec:
  configMap: addon-catalog-manifests
status:
  connectionState:
    address: addon-catalog-source.ibm-system.svc:50051
    lastConnect: "2019-11-06T17:36:34Z"
    lastObservedState: READY
```

You can verify Subscription is setup correctly by checking if the Operator has been installed.

`$ kubectl get -n ibm-operators pod -l name=<operator's name>`

`$ kubectl get -n ibm-operators pod -l name=istio-operator`
```
NAME                              READY   STATUS    RESTARTS   AGE
istio-operator-66ddf49685-gz7qj   1/1     Running   0          103m
```

If the Operator is installed but is not running, you can check it logs.

`$ kubectl logs -n ibm-operators -l name=<operator's name>`

`$ kubectl logs -n ibm-operators -l name=istio-operator`
```
2019-11-06T17:39:25.152776Z	warn	retrieving resources to prune type extensions/v1beta1, Kind=DaemonSet: no matches for kind "DaemonSet" in version "extensions/v1beta1" not found
2019-11-06T17:39:27.360312Z	warn	retrieving resources to prune type extensions/v1beta1, Kind=Deployment: no matches for kind "Deployment" in version "extensions/v1beta1" not found
2019-11-06T17:39:29.579871Z	warn	retrieving resources to prune type certmanager.k8s.io/v1beta1, Kind=Certificate: no matches for kind "Certificate" in version "certmanager.k8s.io/v1beta1" not found
2019-11-06T17:39:31.753108Z	warn	retrieving resources to prune type certmanager.k8s.io/v1beta1, Kind=Challenge: no matches for kind "Challenge" in version "certmanager.k8s.io/v1beta1" not found
2019-11-06T17:39:33.952831Z	warn	retrieving resources to prune type certmanager.k8s.io/v1beta1, Kind=Issuer: no matches for kind "Issuer" in version "certmanager.k8s.io/v1beta1" not found
2019-11-06T17:39:36.161619Z	warn	retrieving resources to prune type certmanager.k8s.io/v1beta1, Kind=Order: no matches for kind "Order" in version "certmanager.k8s.io/v1beta1" not found
2019-11-06T17:39:38.360447Z	warn	retrieving resources to prune type rbac.istio.io/v1alpha1, Kind=AuthorizationPolicy: no matches for kind "AuthorizationPolicy" in version "rbac.istio.io/v1alpha1" not found
2019-11-06T17:39:40.579672Z	warn	retrieving resources to prune type certmanager.k8s.io/v1beta1, Kind=ClusterIssuer: no matches for kind "ClusterIssuer" in version "certmanager.k8s.io/v1beta1" not found
2019-11-06T17:39:40.861219Z	info	end pruning
2019-11-06T17:39:40.905566Z	info	end reconciling resources
```

If the Operator is not installed, you can check the Subscription's logs to see if Subscription found a valid CatalogSource.

`$ kubectl get -n ibm-operators Subscription <subscription's name> -o yaml`

`$ kubectl get -n ibm-operators Subscription istio -o yaml`
```
status:
  catalogHealth:
  - catalogSourceRef:
      apiVersion: operators.coreos.com/v1alpha1
      kind: CatalogSource
      name: addon-catalog-source
      namespace: ibm-system
      resourceVersion: "267708"
      uid: 1886cd3c-d87c-4413-bc4f-81e546b86393
    healthy: true
    lastUpdated: "2019-11-06T17:35:25Z"
  conditions:
  - lastTransitionTime: "2019-11-06T17:35:25Z"
    message: all available catalogsources are healthy
    reason: AllCatalogSourcesHealthy
    status: "False"
    type: CatalogSourcesUnhealthy
```

If the Subscription did not find a valid CatalogSource, then check the references of the Subscription, CatalogSource, and Package (package is inside the Configmap named "addon-catalog-manifests").
- Subscription.spec.channel == Package.channels.-.name
- Subscription.spec.name == Package.packageName
- Subscription.spec.source == CatalogSource.metadata.name
- Subscription.spec.sourceNamespace == CatalogSource.metadata.namespace
- Package.channel.-.currentCSV == ClusterServiceVersion.metadata.name

`$ kubectl get -n ibm-operators Subscription istio -o yaml`
```
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
spec:
  channel: istio-operator-beta
  name: istio
  source: addon-catalog-source
  sourceNamespace: ibm-system
```
`$ kubectl get -n ibm-system catalogsource addon-catalog-source -o yaml`
```
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: addon-catalog-source
  namespace: ibm-system
```
`$ kubectl get -n ibm-system configmap addon-catalog-manifests -o yaml`
```
apiVersion: v1
data:
  packages: |
    - packageName: istio
      channels:
      - currentCSV: istio-operator.v0.0.1
        name: istio-operator-beta
      defaultChannel: istio-operator-beta
```
```
apiVersion: v1
data:
  clusterServiceVersions: |
    - apiVersion: operators.coreos.com/v1alpha1
      kind: ClusterServiceVersion
      metadata:
        name: istio-operator.v0.0.1
```

If the CatalogSource pod is in a CrashLoopBackOff, delete the CatalogSource pod.
```
kubectl delete pod -n ibm-system -l olm.catalogSource=addon-catalog-source
```

## Use Istioctl to see dashboards
Download Istioctl for 1.4.0.
```
curl -sL https://raw.githubusercontent.com/istio/istio/1.4.0/release/downloadIstioCtl.sh | sh - && export PATH=$PATH:$HOME/.istioctl/bin 
```
Then open the dashboards using the following syntax.
```
istioctl dashboard prometheus
istioctl dashboard kiali
istioctl dashboard grafana
istioctl dashboard controlz <PodName> -n <PodNameSpace>
istioctl dashboard envoy <PodName> -n <PodNameSpace>
istioctl dashboard jaeger
istioctl dashboard zipkin # Not Available
```
To learn how to use these dashboards, go here.
`https://istio.io/docs/ops/diagnostic-tools/`

## Kiali Dashboard has no metrics
Assuming the cluster has Kiali enabled, if you went into Kiali and found it had no metrics, it might be a problem with Istio-Telemetry. Go check Istio-Telemetry's logs.
<br>`$ kubectl log -n istio-system -l app=telemetry -c mixer`
If you see something like the following error message, then restart the Istio-Telemetry pod.
```
Mixer Report failed with: UNAVAILABLE:upstream connect error or disconnect/reset before headers. reset reason: connection failure
```
<br>`$ kubectl delete pod -n istio-system -l app=telemetry`

## Further Information
- The [OLM community](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/README.md) has full documentation.
- [Operator SDK](https://github.com/operator-framework/operator-sdk)

If you need any further instruction on this topic, please visit the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel.
