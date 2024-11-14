---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to handle ICD backup alerts from Activity Tracker for Satellite
service: Activity Tracker
title: Handle ICD backup alerts from Activity Tracker for Satellite
runbook-name: "Handle ICD backup alerts"
link: /activity_tracker_icd_backup_alert.html
tags: compliance
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
This document describes how to handle ICD backup alerts from Activity Tracker for Satellie Stage and Prod

## Detailed Information
The platform ActivityTracker instances (one per region) in the satellite production account will be logging events from ICD backups. An alert for each
region will be triggered if the backup fails. This runbook will provide steps to create a ticket in Softlayer portal (cloud.ibm.com) to get ICD team help to resolve the backup failure.

## Detailed Procedure

### Steps to create Softlayer ticket 
1. Login to [IBM Cloud Web Page](https://cloud.ibm.com/)
2. Select Softalyer Account `Satellite Prod 2094928` for Prod and `Satellite Stage 2146126` for Stage alert
3. Click on `Support` option that is displayed on top of the page (next to `Manage`)
4. Click on `Create a case`
5. For the question `What category best relates to your issue?`, select `All products`
6. For `Topic`, select `Databases for MongoDB` and click `Next`
7. Fill the ticket with below details <br>
   (Replace the REGION word with region info from the alert's title. <br>
   Example: if the alert title is `ICD database backup failed for region: https://app.us-east.logging.cloud.ibm.com` the region here is `us-east`): <br>
   (a) Set `Subject` as `ActivityTracker: ICD backup failed for region REGION` <br>
   (b) Set `Description` as "The platform ActivityTracker instance IKS-AT-platform-REGION for REGION has ICD backup failure. The log details are -POST THE LOGS FROM THE ALERT'S LOGS SECTION-. Please investigate." <br>
   (c) Set `Severity` to `Serverity 2` <br>
   (d) Select `Data center settings"/"Select a datacenter` as per REGION from the alert (example: if region is `us-south` choose any of `Dallas 10/12/13/etc`) <br>
   (e) Submit the details <br>
8. Gather the Softalyer ticket number, that is created, and add it to the Alert
9. Resolve the alert

### Optional: Steps to access Activity Tracker and ICD logs in cloud.ibm.com
1. Access Activity Tracker instance from the [IBM Cloud Console](https://cloud.ibm.com/observe/activitytracker)
2. Select Softalyer Account `Satellite Prod 2094928` for Prod and `Satellite Stage 2146126` for Stage alerts
3. Click on `Open dashboard` that is mentioned against `IKS-AT-platform-REGION` in Activity Tracker page
   Replace "REGION" with the region information available from the title of this alert.
   Example: If the REGION is au-syd, the  Activity tracker would be  `IKS-AT-platform-au-syd`
4. Select the view `ICD backup failure` to review the failure logs
