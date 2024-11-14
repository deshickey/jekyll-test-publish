---
layout: default
description: How to troubleshoot OLM issues
title: armada-deploy-olm-troubleshooting - How to resolve OLM issues 
service: armada-deploy-olm-troubleshooting
runbook-name: "armada-deploy-olm-troubleshooting -  How to resolve OLM issues"
tags:  armada, olm, armada-deploy-olm-troubleshooting
link: /armada/armada-deploy-olm-troubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

### Detailed Information

This runbook describes the process of investigating Operator Lifecycle Manager (OLM) issues on customer clusters. The [OLM community](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/README.md) has full documentation.

OLM is comprised primarily of two pods running in the `ibm-system` namespace. These pods are the `olm-operator` pod and the `catalog-operator` pod. There may also be another pod associated with OLM found in the cluster which is defined by a `CatalogSource` kubernetes resource. An example of this is found in the `ibm-system` namespace and is called `addon-catalog-source`. 

All operators created via OLM and Catalog and managed by IBM will be created in the `ibm-operators` namespace.

### Links to addon runbooks

- [Istio](./armada-addon-istio.html): Istio 1.4+ are operator-based and managed by OLM
- [Knative](./armada-addon-knative.html): Knative is not currently managed by OLM

## Example Alert(s)
OLM is a very recent addition and there are no example alerts available yet.

## Investigation and Action

### Get OLM and Catalog logs

Check that all OLM and Catalog pods are running:

~~~
kubx-kubectl <CLUSTER_ID> -n ibm-system get pod -l app=olm-operator
kubx-kubectl <CLUSTER_ID> -n ibm-system get pod -l app=catalog-operator
kubx-kubectl <CLUSTER_ID> -n ibm-system get pod -l olm.catalogSource=addon-catalog-source
~~~

If any of the above pods are not running, run:

~~~
kubx-kubectl <CLUSTER_ID> -n ibm-system describe pod <POD_NAME>
~~~

To find the pod logs for OLM, catalog-operator, and catalog-source, ssh into the proper carrier master and run the following commands:

~~~
kubx-kubectl <CLUSTER_ID> -n ibm-system logs <POD_NAME>
kubx-kubectl <CLUSTER_ID> -n ibm-system logs <POD_NAME>
kubx-kubectl <CLUSTER_ID> -n ibm-system logs <POD_NAME>
~~~

### Restarting OLM and Catalog

The `olm-operator`, `catalog-operator`, and `addon-catalog-source` can all be restarted by deleting their respective pods. 

Example:
~~~
    kubx-kubectl <CLUSTER_ID> -n ibm-system delete pod <POD_NAME>
~~~

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
