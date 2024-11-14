---
layout: default
title: IBM Cloud App Configuration architecture
type: Informational
runbook-name: "IBM Cloud App Configuration architecture"
description: "IBM Cloud App Configuration service architecture"
service: App Configuration
tags: app-configurations
link: /app-configurations/architecture.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview 
# Architecture

## Service Architecture Basics

Service would be a regionally deployed service.  

Following are the components of the service that would be deployed in each region - 

* Cluster 
* Edge networking 
* Dependencies to the service
* Microservices
* Monitoring tools like Sysdig

Common components would be - 

* Global Catalog entries
* RMC entries
* Other onboarding entries
* DevOps Pipeline
* Monitoring tools like IBM Synthetics

## Detailed Information
## Architecture Details 

The sections below discuss the architecture of IBM Cloud App Configuration in detail - 

* [Logical architecture](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/logicalarch.html)

* [Physical architecture](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/physicalarch.html)





