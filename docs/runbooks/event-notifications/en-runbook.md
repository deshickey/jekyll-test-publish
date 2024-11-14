---
layout: default
title: "IBM Cloud Event Notifications runbook"
runbook-name: "IBM Cloud Event Notifications runbook"
description: "IBM Cloud Event Notifications Monitoring Procedures"
category: Event Notifications
service: Event Notifications
tags: event-notifications
link: /event-notifications/en-runbook.html
type: Informational
grand_parent: Armada Runbooks
parent: Event Notifications
---

Informational
{: .label }

## Overview
# Event Notifications Monitoring Procedures

IBM Cloud Event Notifications service is used to alert your users to critical events happening in your IBM Cloud account. You can send filtered notifications to a set of your users via a notification channel destination of choice. These users need not be IBM Cloud users.

## Detailed Information
Summary: IBM Cloud Event Notifications Service is down

Dependencies: IBM Cloud Platform, ICD PostgreSQL, Elastic Search, COS, Key Protect, Event Streams, ICD Redis, & CIS

Slack Channel: #event-notifications-monitoring

## Runbooks 
Following are the various runbooks used to maintain the service.  

## Service Verification Steps and how to handle incidents

This runbook is used to verify the service functionlity and dependencies
Refer [Service Verification Steps](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-serviceverify.html)

## CIE & Severity Information

Refer [CIE & Severity Information](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-cie.html)

Refer [Get Help from services we depend on](https://pages.github.ibm.com/ids-sre/runbooks/docs/runbooks/incident-management/dependency-escalations.html) for specific dependency based help.

Refer [CIE Troubleshooting runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-cierunbook.html)


### Informational Runbooks

* [BCDR Runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-bcdr.html)


### Escalation Policy

* [Escalation Policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-escalation-policy.html)
