---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How Activity Tracker backups are set up for Armada
service: cloud-audit
title: Activity Tracker Backup in Armada
runbook-name: "Backup of Activity Tracker in Armada"
link: /activity_tracker_backup.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
This document describes how to set up Activity Tracker for backups.

## Detailed Information
The backups are completed automatically by IBM CLoud Logs once set up. 
Each activity tracker instance must be configured for archiving logs.
This will ensure the logs will be backed up in a COS bucket at the end of the online retention period.

## Detailed Procedure

1. Access Activity Tracker instance from the [IBM Cloud Console](https://cloud.ibm.com/observe/activitytracker) and click `Open Dashboard`.
2. Choose the Settings cog in the left menu.
3. Choose the Archiving option from the Settings menu.
4. Follow the Instructions section to create a new COS bucket for archiving. Use an existing COS instance in the IBM Cloud Account. Ensure expiration rules are not set.
5. Complete settings for the COS bucket created earlier
    - Bucket
    - Endpoint
    - API Key
    - Resource Instance ID
6. Save




