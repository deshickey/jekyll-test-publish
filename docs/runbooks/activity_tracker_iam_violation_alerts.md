---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to handle IAM violation alerts from Activity Tracker
service: Activity Tracker
title: Handle IAM violation alerts from Activity Tracker
runbook-name: "Handle IAM violation alerts"
link: /activity_tracker_iam_violation_alerts.html
tags: compliance
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
This document describes how to handle IAM violation alerts from Activity Tracker

## Detailed Information
The platform ActivityTracker instances in Frankfurt in key IBM Cloud accounts will be logging events of IAM use. 
An alert will be triggered if a login for a service id has come from an IP that is not on the IAM allowlist. 
This runbook describes the steps to take when receiving this alert.

Note: This is potential security breach and therefore it is important to find the cause of the alert.

## Detailed Procedure

1. Identify the account that has triggered the alert
  - The account is in the title of the alert
2. Identify the serviceid that has triggered the alert
  - The serviceId identifier is in the body of the alert on one of the log lines
  - To find the name of the service id log into the alerting IBM Cloud account and navigate to `https://cloud.ibm.com/iam/serviceids/ServiceId-3a69d34a-af9d-4512-bd46-9bcf4104c6f5` replacing the ServiceID identifier with the one in the alert
3. Is the problem still happening? 
   - Follow the link in the alert to view Activity Tracker and see if there are continuing attempts to log in with this serviceId. Use the query `notification.details:ip_address_restriction_violation initiator.name:ServiceId` in [IBM CLoud Logs](https://cloud.ibm.com/observability/activitytracker).
4. What is the source IP address?
   - Look for the source IP address for any log lines found. 
   - Search for this IP address in slack and netmax to see if the request is coming from a known source. For example, the IP may be a newly added to Jenkins or travis without the allowlist being updated correctly. Or there may have been a failure in the [IAM allowlist update automation](https://github.ibm.com/alchemy-conductors/compliance-iam-account-allowlist)
5. If the source IP cannot be identified, raise this issue with other SREs and squad leads.
6. If a security incident is suspected then:
  - Disable the ServiceId that caused the alert by removing the ServiceId in [IBM Cloud ServiceID management page](https://cloud.ibm.com/iam/serviceids). Note this is serious and is likely to cause a CIE therefore please ensure agreement from squad lead first. 
  - Raise a security incident


### Steps to access Activity Tracker  in cloud.ibm.com
1. Access Activity Tracker instance from the [IBM Cloud Logs](https://cloud.ibm.com/observability/activitytracker)
3. Click on `Open dashboard` that is mentioned against `IKS-AT-platform-eu-de` in Activity Tracker page
4. Select the view `IAM Violation` to review the failure logs
