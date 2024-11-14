---
layout: default
description: The knative addon
title: Knative Addon
service: armada-deploy
runbook-name: "Knative Addon"
tags: alchemy, armada, kubernetes, armada-deploy, knative, cruiser
link: /armada/armada-addon-knative.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes the Knative addon.

## Detailed Information

The Knative addon is an optional cluster managed feature.
[Knative community](https://www.knative.dev/) has full [docs](https://www.knative.dev/docs/).

Facts about Armada Knative:

* Knative is managed by Cluster Updater.  [CU addon doc](https://github.ibm.com/alchemy-containers/cluster-updater)
* Knative has many Custom Resource Definitions. `kubectl get crd -n knative-serving`
* Supported only for Cruisers
* [Knative build repo](https://github.ibm.com/alchemy-containers/addon-knative)

## Knative Addons

To tell which Istio addons are enabled for this cluster, run:

```
ibmcloud ks cluster-addons <CLUSTERID>
```

The following is the Knative addon.

### knative

* addon name: `knative`
* Runs in the following namespaces:
  * knative-build
  * knative-eventing
  * knative-monitoring
  * knative-serving
  * knative-sources

## Problems and Solutions:

TBD

## More Help
If you need any further instruction on this topic, please visit the following:

* Slack channel: [#knative](https://ibm-argonauts.slack.com/messages/CC0ER7LGZ)
