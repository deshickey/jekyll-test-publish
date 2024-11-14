---
layout: default
title: IBM Cloud App Configuration Startup & Shutdown procedures for Microservices
type: Informational
runbook-name: "IBM Cloud App Configuration Startup & Shutdown procedures for Microservices"
description: "IBM Cloud App Configuration service Startup & Shutdown procedures for Microservices"
service: App Configuration
tags: app-configurations
link: /app-configurations/bcdrrunbook.html 
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview 
# Startup & Shutdown procedures for Microservices

IBM Cloud App Configuration deploys microservices in IKS.  **kubectl** command is used to deploy / scale microservices. All microservices of the service are being deployed to "apprapp" namespace of the cluster. **apprapp-api-gateway** is the pod which is the entry to the service.  This should be scaled accordingly to startup or shutdown the service.

## Detailed Information
## Startup procedures for Microservices

Scale the "apprapp-api-gateway" pods to specified number (e.g. 3) in a specific region/cluster by executing the below command.

```kubectl scale deployment apprapp-api-gateway --replicas=3```

To verify access the health end point of the service https://<region>.apprapp.cloud.ibm.com/apprapp/v1/health/status to respond with the health check details with over all health to be live.

## Shutdown procedures for Microservices

Scale the "apprapp-api-gateway" pods to zero in a specific region/cluster by executing the below command.

```kubectl scale deployment apprapp-api-gateway --replicas=0```

To verify access the health end point of the service https://<region>.apprapp.cloud.ibm.com/apprapp/v1/health/status to throw an error.