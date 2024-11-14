---
layout: default
description: Handling long running pod alerts
title: Handling long running pod alerts
service: armada
runbook-name: Handling long running pod alerts
tags: alchemy, armada, cloud-functions, cruiser
link: /armada/sre-long-running-pods-alerts.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook details how to look after long running Kubernetes pods we are monitoring.

We are responsible for reacting to long running pod alerts, assisting the squads to avoid aged containers or images.

## Detailed Information

The following sections contain detailed information on how to support the squads.


## Handling alerts

Use the runbook link in the alert you have received to work on the issue.

Each runbook has a link on what SRE should do to investigate and resolve the problem.


## Checking the pod's and image's age

The pod's and image's age could be checked via the following methods

1. Use `kubectl get pods --all-namespaces -o wide` to list the pods infos including the pod age.

2. Use `kubectl describe pod -n <NAMESPACE>`` <POD_NAME>`.


Get in contact with the squads, rebuilding the image to guarantee including the newest software updates and restart the pod.


or

- [IBM Cloud UI](https://console.bluemix.net)

- Interact with the cluster using regular `ibmcloud ks` commands.  

- Use `ibmcloud ks cluster config` to obtain the kubeconfig so kubectl commands can be executed.
