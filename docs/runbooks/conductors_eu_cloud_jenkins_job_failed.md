---
layout: default
description: EU Cloud access, escalation and exception process
service: Conductors
title: EU Cloud access, escalation and exception process
runbook-name: EU Cloud access, Failure of jenkins pipeline Job for Revoking  emergency access to the EU . 
tags: conductors support eucloud eu-cloud 
link: /conductors_eu_cloud_jenkins_job_failed.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

The EU Managed Cloud requires that there is no access by IBM to client-owned
data from *outside* of the EU.

Non-EU engineers (including non-EU conductors) will not have access to: 

- Machines supporting Armada _eu-central_ region including all carriers
  (hubs, spokes and patrols)

## Detailed Information

The non-EU SRE granted 9 hours emergergency access to to EU cloud, revoke job was not initiated/failed after 9 hours of onboarding in iks-eu-de-all-eu-emergergency-pipeline

## Detailed Procedure
The PagerDuty alert is triggered as Jenkins job is failed or aborted.
We have to rerun the main job to revoke emergergency access of user whoe's access passed 9 hours time. This job will not afftcted any user whoe's access is still under 9 hours time frame.
Rerun the  Jenkins job [iks-eu-de-all-eu-emergergency](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/eu_emergency_access/job/iks-eu-de-all-eu-emergergency/). This will revoke the correct IAM access. Ensure that SAVE_REPORT_TO_GHE is set to true.
This will revoke **ROLE_IKS_SRE_eu_emerg**.

## Details of EU emergency access

[EU emergency access for IKS](./conductors_eu_cloud_iks.html) and [EU emergency access for Satellite](./conductors_eu_cloud_sat.html) runbooks

