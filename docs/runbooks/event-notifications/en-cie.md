---
layout: default
title: "IBM Cloud Event Notifications CIE"
runbook-name: "IBM Cloud Event Notifications CIE"
description: "IBM Cloud Event Notifications CIE Severity Criteria"
category: Event Notifications
service: Event Notifications
tags: event-notifications
link: /event-notifications/en-cie.html
type: Informational
grand_parent: Armada Runbooks
parent: Event Notifications
---

Informational
{: .label }

# Severity Criteria

<b>Important : When in doubt about the severity of a CIE, always pick Sev 2.</b>

## Overview
CIE - Customer Impacting Event - is an incident that must be opened when customers of a cloud service can’t use the service, as advertised. The service can either be completely unavailable or some of the key functionality may be impacted. In both of these scenarios, a CIE incident is opened by the on-call production maintenance personnel for the Cloud service.

## Detailed Information
This document defines when such a CIE must be opened and what should be the severity of the incident in a given scenario

## What is the time frame for opening a CIE?

Pager Duty is set up for monitoring failures on the cloud service. The on-call support person receives the alert from pagerduty. As soon as that alert is received, it must be acknowledged. That is a proof that we are aware of the issue and the investigation has begun.

Post that, the CIE must be opened within 15 minutes, if the service cannot be recovered within that 15 minute window.  

If you are unsure about what the problem is - as in, you cannot readily determine if the problem is with our service alone or is due to a dependent service like IKS, ICD PostgreSQL etc, always start with a Sev 2 issue.

If you unsure if the service is down or feature in question is down, start by creating a Potential CIE. It can later be convered to a Confirmed CIE, if its confirmed that the service is affected.

Sometimes, a restart of a component may bring the service back up. If it was a cloud dependent service layer issue (Kubernetes, Postgres, Redis etc) and if any of them recover, resulting in our service functionality being restored within the 15 minute window, then no CIE needs to be opened. 


## What should be the severity of the CIE?

A CIE can occur due to various reasons. Always keep this in mind when you must open a CIE:

If the Entire IBM Cloud is done, CIE must not be opened for individual services.
* SEV 1:
   * If the service goes down due to a deployment gone wrong and cannot be recovered in 15 minutes.
   * Service is entirely down, dashboard is not accessible, CLI/Terraform nothing is working OR notifications are not sent at all.
* Sev 2:
   * If the service is down due to an issue in the dependent service like IKS, Postgres, Redis etc
   * Dashboard is down but the CLI and backed APIs continues to function normally
   * Less than 10% of the customers are impacted - For instance, several (3 or more) destinations may not receive notifications apart from Push notifications in all regions.
   * 503 - intermittent issues accessing  the service - not a permanently down situation but has network/connectivity issues
* Sev 3:
  * Provisioning failures - new instance of the service cannot be created. If the problem persists for over 24 hours, make it a Sev 2
  * Cannot create new destinations/subscriptions/topics but existing destinations/subscriptions/topics works ok.
  * Dashboard works well but just the CLI is not functioning 
* Sev 4:
  * A minor issue that requires action but does not impact functionality or usage.
  * For instance, one of the containers failed to accept the request, but the other containers are accepting the requests, and the functionality/usage is not affected.

  
Also refer to the [AVM FAQ](https://pages.github.ibm.com/toc-avm/avm/faq/#cie-mgt-Pro-2)


## When is it not a CIE for our service?

1. When the entire IBM Cloud is down and you are unable to login to cloud.ibm.com, do not create a CIE as the problem is much larger and is not affecting our cloud service alone. Wait for the overall cloud issue to resolve. Even after the IBM Cloud is back up and allowing a successful login, if our service continues to have a problem - that is when a CIE must be opened. 
2. If the metering is not working (Redis down scenario), it is not a CIE as customers can continue to use our service functionality. An internal Sev 1 case must be opened for support, against Redis team for investigation and fixing the problem.


## What must be done during a CIE?

Once a CIE is opened by the on-call support personnel, the #event-notifications-cie channel must be kept up to date, add a comment every 5 minute once on the progress of investigation and corrective action being considered/taken.

An AVM - Availability Manager engages on the CIE channel. Work with them to post a clear and concise message that will be communicated to the customers, announcing the service downtime. Do not share any internal details on it, keep it to a high level for eg : 
* Customers of Event Notifications service may face errors sending Email Notifications
* Customers of Event Notifications service may face errors trying to create new destinations/topics
* Customers of  Event Notifications service may face intermittent errors trying to launch and work with the service dashboard

Secondly, you will need to work with the AVM to ensure the parent CIE is set to the dependent service’s incident number, in case our service is impacted due to the dependent service being down like IKS, Postgres etc

Once you determine the problem is possibly due to an underlying service, open a Sev 1 case against them immediately from the production or stage cloud account underSupport Tab of cloud.ibm.com - Please open the case under Notifications-Prod or event notifications cloud account only for premium support.

## What access is required to open a CIE?

If you are trying to open a CIE from the event-notification-cie or event-notification-svc channel channel, you can do so by typing a command 

@ciebot cie
- Select the service name as event-notifications, select an appropriate severity, title and open the CIE

If you see an unauthorised error, it is best to open an incident directly on service now but for future, open an access request using the information in this document https://github.ibm.com/cloud-sre/ToolsPlatform/wiki/API-Platform-Usage under the section: How to Join in API Platform


## What are the other channels that I can keep an eye on?

| Slack  | Dependency | 
| :--- | :--- | 
| cli-cie | CLI related issues |
| containers-cie | IKS related issues |
| databases-cie | Postgres/redis related issues |
| iam-cie | IAM related issues |
| ibmcloud-cie | Larger issues impacting the entire cloud |
| mhub-cie | Event Streams related issues |
| console-cie | For any IBM Cloud Console related issues |
| cp-sre | Reliability Engineering in Dibbe's Org |

