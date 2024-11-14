---
layout: default
description: How to create ICD backup alerts for Activity Tracker in Satellite
service: Activity Tracker
title: How to create ICD backup alerts for AT in Satellite
runbook-name: "How to create ICD backup alerts for AT for in Satellite env"
link: /how_to_create_db_bak_alerts_satellite.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
This document describes how to create ICD backup alerts for Activity Tracker for Satellie Stage and Prod

## Detailed Information
The platform ActivityTracker instances (one per region) in the satellite production/stage account will be logging events from ICD backups. A PagerDuty alert need to be triggered if the backup fails. This runbook will provide steps on how to create PagerDuty Alert. The alerts will be configured one per region.

## Detailed Procedure

### Steps to create ICD backup alerts 
1. Access Activity Tracker instance from the [IBM Cloud AT Console](https://cloud.ibm.com/observe/activitytracker)
2. Select Softalyer Account "Satellite Prod 2094928" for Prod and "Satellite Stage 2146126" for Stage alert
3. Click on `Open dashboard` that is mentioned against `IKS-AT-platform-REGION` in Activity Tracker page <br>
   Replace `REGION` with the appropriate region name <br>
   Example: If the REGION is au-syd, the  Activity tracker would be  "IKS-AT-platform-au-syd" <br>
4. In the view `Everything`: <br>
   at the bottom search section, enter the phrase `action:databases-for-mongodb.backup-scheduled.create  source:ibm-cloud-databases-prod outcome:failure` 
   to retrieve ICD backup failures
5. Create a new view `ICD-backup-failure` to capture the ICD backup failure messages retrieved in Step 4 <br>
   (a) At the top available boxes, select `Unsaved view` --> in drop down window select `Save as new view` which takes to `Create new view` window <br>
   (b) In `Create new view` window, in the `Name` box enter the name of the view `ICD-backup-failure` <br>
   (c) In the `Alert` box, scroll down to select `View-specific alert` ---> select `pager duty`--> `Service` --> `Add Pagerduty`  <br>
   (d) Login to PagerDuty with `Sign in with Identity Provider` --> For `Enter the subdomain of your account` field, enter `IBM` <br>
   (e) Select the PagerDuty Service to which this alert need to be sent. Click on `Save view`
   
