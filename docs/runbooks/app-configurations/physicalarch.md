---
layout: default
title: IBM Cloud App Configuration Physical Architecture
type: Informational
runbook-name: "IBM Cloud App Configuration Physical Architecture"
description: "IBM Cloud App Configuration Physical Architecture"
service: App Configuration
tags: app-configurations
link: /app-configurations/physicalarch.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
# Physical Architecture

<img src="./assets/physicalarch.png" width="640" />

## Detailed Information
## Flow of a request

<img src="./assets/requestflow.png" width="640" />

## High Availability

High Availability within a region is inbuilt into the infrastructure.  Each microservice runs on a Multizone Regional (MZR) cluster with nodes distributed across three datacenters.  Minimum 3 replica-sets run distributed across the zones / datacenters.  

Availability for all the service components is managed by Kubernetes liveness checks. If any running component fails its liveness check, Kubernetes will reschedule and restart the component.

<!-- ## Disaster Recovery -->




