---
layout: default
title: How to deal with Alerts from deprovision tool when it fails to remove patrol cluster(s)
type: Informational
runbook-name: "How to remove patrol clusters older than 6 days"
description: "How to remove patrol clusters when deprovision tool fails"
service: Conductors
link: /sre_cleanup_patrol_clusters.html
parent: Armada Runbooks

---

Informational
{: .label }

# How to remove patrol cluster(s) older than 6 days

## Overview

This document details how to address patrol cluster(s) reporting as failed to remove by deprovision tool.

## Useful links

- [Patrol cluster deprovision Jenkins Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/patrols-deprovision-tool/)  
is the source of this alert, i.e. jenkins job which runs daily to check and remove patrol clusters that are older than 6 days and doesn't have `csutils` installed on them.


## Detailed information

This runbook will guide you through getting the failed to clean patrol cluster(s) by deprovion tool to be removed manually.


### Investigation and Action

Please consult this runbook: [How to access tugboats](./armada/armada-tugboats.html#access-the-tugboats)   
_**NB.** Tugboats have a **carrier** number greater or equal to 100!_

1. connect to one of the `stgiks` worker node using [bastion](./bastion/access_hosts_behind_bastion.html)
1. connect to stage HUB tugboat where the `armada-api` resides
   ```bash
   invoke-tugboat stage-dal10-carrier103
   ```
1. Enable port-forwarding to the `armada-api` kubernetes service and run in background.
   ```bash
   kubectl port-forward svc/armada-api -n armada 6969 > /dev/null 2>&1 &
   ```
1. mark the patrol cluster(s) which failed to delete through deprovision tool as deleted due to `trial_expired`. Replace `<clusterid>` with the patrol clusterID which failed to delete in Jenkins Job.
   ```bash
   curl --location --request DELETE 'http://localhost:6969/internal/clusters/<clusterid>?reasonForDelete=trial_expired'
   ```

## Escalation Policy

There is no formal escalation policy.

This is an SRE owned process so should be raised and discussed in either

- `#conductors` if you are not a member of the SRE Squad.
- `#sre-cfs`, `#conductors-for-life` if you are a member of the SRE squad (these are internal private channels)

If you have any concerns, please raise them with Paul Cullen (Compliance Lead) or SRE Leads.
