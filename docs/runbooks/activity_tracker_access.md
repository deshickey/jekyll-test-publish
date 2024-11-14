---
layout: default
description: Activity tracker access
title: Activity tracker access
service: cloud-audit
runbook-name: "Access to activity tracker and COS backups"
tags: compliance
link: /activity_tracker_access.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document describes how the access to activity tracker is controlled.


## Detailed Information

See [Using AccessHub to request, remove and maintain access for services](../process/access_control_using_accesshub.html) for information on how AccessHub is used to request roles.

Access to Activity Tracker and the COS Buckets used for backup is separated into:

- Viewer: Provided to ROLE_IKS_Developer to be able to view audit logs in the audit tracker. 
- Writer: Provided to ROLE_IKS_SREs to be able to setup and maintain the audit tracker and COS buckets holding the backups.

