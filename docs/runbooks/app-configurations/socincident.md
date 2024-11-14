---
layout: default
title: IBM Cloud App Configuration SOC Incident
type: Informational
runbook-name: "IBM Cloud App Configuration SOC Incident"
description: "IBM Cloud App Configuration SOC Incident"
service: App Configuration
tags: app-configurations
link: /app-configurations/socincident.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
# Deverloper's Runbook 

## Detailed Information
## Cluster Exec - Security Incident

Service aligns with [Audit and Accountability Policy Requirements](https://pages.github.ibm.com/ibmcloud/Security/policy/Audit-and-Accountability.html) including ensuring that any occurrence of any security defined events such as intrusion detections via PD alerts is identified, assessed within 7 calendar days and tracked to remediation.

Cluster exec should not be performed unless there is a reason for the same. Since this can lead to a security incident and is tracked at the IBM Cloud level, it is important to track this when a developer / support is performing a exec into the cluster with the required permissions.   If any one who has the access is performing a exec, one should follow the process mentioned below.  

1. Create an issue in our planning repo with the template "Exec to clusters".  Directly [link](https://github.ibm.com/devx-app-services/planning/issues/new?assignees=&labels=exec&template=exec-template.md&title=Exec+to+cluster+-+Cluster+name) to the template can also be used.
2. Provide the details in the issue 
3. For every 2 hours of exec, either update the same or create a new issue according to the individual preference. 

