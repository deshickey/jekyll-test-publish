---
layout: default
title: SRE compliance documentation links
type: Informational
runbook-name: Compliance documentation contents
description: Useful links for SREs for compliance related information
category: Armada
service: NA
tags: GITHUB, compliance
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This table helps SREs understand what we are responsible for with regards to compliance of the IKS environments.

## Detailed Information

These tables help SRE find security and compliance documentation

### SOS

Generic [SOS documentation is here](https://pages.github.ibm.com/SOSTeam/SOS-Docs/)  
These sections detail our use of the various SOS tools


### Handling compliance team tickets

We receive  a variety of team tickets with the `COMPLIANCE` label on them.  These tickets should be handled immediately by the SRE team. The following table should help with some of the more commonly raised tickets

| Process | Brief overview | Useful links |
| ------- | -------------- | ------------ |
| Machine not checked into bigfix for 3+ days | How to investigate and resolve issues when nodes stop checking into bigfix | [Addressing bigfix compliance issues](./compliance_bigfix_team_issue.html) |
| How to address the bootloader healthcheck failure | Details on how to debug and fix the bootloader healthcheck failure | [Investigating bootloader healthcheck failure](./compliance_handle_bootloader_healthcheck_issue.html) |
|Systems reporting as not scanned in X days | Details on how to debug and fix systems reporting as not scanned in X days | [Investigating Systems reporting as not scanned](./compliance_systems_not_scanned.html) |
|Systems reporting as not scanned in over a year | Details on how to debug and fix systems reporting as not scanned in over a year | [Investigating Systems reporting as not scanned in over a year](./compliance_systems_not_scanned_over_year.html) |
|Systems reporting offline in FIM | Details on how to debug and fix systems reporting as offline in FIM | [Investigating Systems reporting as offline in FIM](./compliance_fim_issues.html) |
|ALC Systems reporting EDR issues | Details on how to debug and fix ALC systems reporting EDR | [Investigating Systems reporting EDR issues](./compliance_alc_edr_errors.html) |
|ARMADA Systems reporting EDR issues | Details on how to debug and fix ARMADA systems reporting EDR | [Investigating Systems reporting EDR issues](./compliance_armada_edr_errors.html) |
|Clusters not forwarding kube-audit-logs | Details on how to debug and fix clusters not forwarding kube-audit-logs | [Investigating clusters not forwarding kube-audit-logs](./compliance_kube_audit_log_failures.html) |
| Qradar checkin issues | How  to debug problems related to qradar logging and systems that haven't checked in | [Qradar logging issues runbook](./qradar_gap_check.html) |

### Nessus

Nessus overview and setup documentation

| Process | Brief overview | Useful links |
| ------- | -------------- |  ------------ |
| Nessus overview | Information about our use of nessus and the scans performed | [Overview of IKS use of Nessus scanning](./compliance_nessus_overview.html)
| Ordering and setting up nessus | How setup nessus | [Ordering a new nessus scanner and setting up new scan zones](./sre_nessus_scanner.html) |


This table has links to help SREs deal with problems reported by the scanner and the results of scans.  Has links to runbooks covering the alerting and how to resolve problems raised.

| Process | Brief overview |  Useful links |
| ------- | -------------- | ------------ |
| Security Center Access | How to request access to Security Center |  [Access control SOS Security Center](../process/access_control_sos_security_center.html) |
| Handing nessus vulnerabilities | Handing nessus vulnerabilities |  [Handing nessus vulnerabilities](./Handling_Nessus_Vulnerabilities.html) |
| Nessus IP list generator | Resolving issues with Security Center asset list updater automation | [Nessus scanner IP List generator](./compliance_nessus_scan_ip_list_generator.html) |
| Nessus VLAN classifier tool | Understanding how VLANs are associated with our nessus scanzones | [Nessus VLAN classifier](./compliance_sos_vlan_scan_zone_classifier.html) |
| Handling nessus scan alerts| Handling PDs related to nessus scans failing to run | [Handling nessus scan compliance alert](./nessus_scan_compliance_alert.html)|
| General Nessus server troubleshooting | Troubleshooting problems with the nessus server (infra-nessus) | [Nessus server troubleshooting](./nessus_troubleshooting.html) |
{:.table .table-bordered .table-striped}


### Bigfix

- The only checks we have for Bigfix are for patching compliance
- SRE and Security & Compliance Squad are setting up auditree to help with bigfix compliance checks


### Qradar

#### How to enable/disable IPMI access

Access (`eg: ssh`) to all qradar hosts are restricted to the SOS SIEM (QRadar) team.
SRE administering the systems as these nodes are residing in account only SRE have access.

To turn on/off the `Management port`, run the following.

_Step 1._ Collect the machine `IDENTIFIER` after logging into the account where the host resides

```
ibmcloud sl hardware -H <host-name>
```
`(For eg: <host-name> is prod-fra02-infra-qradar-01)`
  
_Step 2._ Enable/disable IPMI access
  
```
ibmcloud sl hardware toggle-ipmi --disable <IDENTIFIER>
```

User can confirm the access (before and after running --disable ). If `enabled/disabled` the following command return success or time out respectively.
```
nc -vz <management-IP> 22
nc -vz <management-IP> 443
```

Qradar logging info

| Process | Brief overview | Main Owner  | Useful links |
| ------- | -------------- | ----------- | ------------ |
| Process for deploying a HA pair of qradar EPs for an environment | How to build deploy a HA pair of qradar EPs for an environment | SRE | [QRadar EP deployment documentation](./qradar_ep_deploy.html) | 
| Process for deploying infra-syslog servers | Building and deploying new or osreloaded syslog servers | SRE | [Syslog server deplpyment documentation](./syslog_server_deploy.html)
| Handling servers not checking into qradar | Debugging problems related to qradar logging | SRE | [Qradar logging issues runbook](./qradar_gap_check.html) | 
| syslog server alerting | alerts relating to the uptime of the syslog (qradar) servers in our environments | SRE | [Handling uptime issues with syslog servers](./syslog_alert.html) |
{:.table .table-bordered .table-striped}



### Old SOS alerting alerting

Some automation existed but has been removed, referencing here as we would like this to be moved to the checks run in `auditree`


| Process | Brief overview | Useful links |
| ------- | -------------- | ------------ |
| Deprecated healthcheck alert - under 100% | old alert which reports under 100% healthchecks | [healthcheck under 100%](./compliance_gap_alert_bigfix_healthcheck_below_100.html) |
| Deprecated healthcheck alert - no healthcheck result | old alert which reports systems reporting no healthchech data | [no healtcheck results](./compliance_gap_alert_bigfix_no_healthcheck_results.html) |
| Deprecated - Handling scan gaps  | Dealing with PDs reporting nessus scan gaps - this automation no longer runs and is replaced by auditree checks but the runbook has some useful info | [Handling nessus scan gap alerts](./nessus_scan_gap_alert.html) |
{:.table .table-bordered .table-striped}


## Managing SRE owned clusters

SRE own and have to manage a number of clusters in various accounts, i.e.

1. Alchemy Support account (278445) 
2. Dev containers (1186049)
3. Prod EU-FR2 (2051458)
4. Dev (659397)

Here are some useful links to keep various aspects of these clusters compliant

| Process | Brief overview |  Useful links |
| ------- | -------------- |  ------------ |
| csutil install on SRE owned clusters | How csutil is managed on SRE owned clusters (on non-tugboat custers workers) |  [Managing csutil on SRE owned clusters](./compliance_csutils_updates_sre.html) |
| Reload worker nodes of SRE owned clusters | How to keep worker nodes compliant in SRE owned accounts (on non-tugboat clusters workers) | [Keeping worker nodes compliant](./compliance_worker_updates_sre.html) |
{:.table .table-bordered .table-striped}

## Compliance team automation

Automation has been written to help review the required compliance tooling (csutil) in Non production accounts

The tooling does the following
- Checks several non-production pipeline accounts and ensure clusters have a reserved csutil VPN cert (needed to deploy csutil), has csutil running and the csutil PODs are healthy
- If any problems are found, GHE issues get raised (code tries to determine correct GHE ownership - defaults to SRE if unknown)
- Alerts compliance team of open issues
- Looks for issues which have been reviewed and clusters approved for automated clean-up

The links below are to details of this tooling, how it works and how to deal with issues raised by the tooling

| Tool | Brief overview |  Link |
| ------- | -------------- |  ------------ |
| Non Production account csutil compliance checks | Monitoring for csutil compliance in non-production cloud accounts |  [Non Production account csutil compliance checks](./compliance_non_production_csutil_cluster_checks.html) |
| IaaS device check | Keeping the 1186049 dev containers and 1185207 Alchemy Productions accounts compliant | [IaaS containers device check](./compliance_devices_check.html) |
| Find open GHE issues | Find and report all of the issues created by the Non Production account csutil compliance check tooling | [Find open GHE issues](./compliance_find_open_GHE_cluster_checks.html) |
| Automated cluster removal process | How the automated cluster removal process works  | [Automated cluster removal process](./compliance_automated_cluster_removal_process.html) |
{:.table .table-bordered .table-striped}


## Tugboat compliance

How SRE keep tugboats compliant.

| Process | Brief overview | Useful links |
| ------- | -------------- | ------------ |
| Upgrade kube version for tugboats | Kick off jenkins job and monitor progress |  [update_tugboat_kube_version](./armada/update_tugboat_kube_version.html) |
| Reinstall csutil onto a tugboat | Kick off jenkins job and monitor progress |  [reinstall csutil ](./armada/tugboat_install_csutil.html) |
| Fix csutil alerts onto a tugboat | Fix non running pods |  [debug csutil](./armada/tugboat_debug_csutil.html) |
| Investigating SOS compliance issues reported against tugboats | Useful information and links to investigating issues reported against tugboats.  This covers all of the SOS reporting on [SOS dashboard](https://w3.sos.ibm.com/inventory.nsf/compliance_portal.xsp?c_code=armada) such as delayed scans, healthcheck failures and patching issues  | [SOS tugboat compliance runbook](./armada/armada-tugboats-sos-troubleshooting.html)|
| IKS worker node compliance | Dealing with issues raised by the compliance team about IKS worker nodes | [Resolving IKS worker image issues](./armada/armada-worker-compliance-issues.html) |
{:.table .table-bordered .table-striped}


## Keeping non-production accounts compliant

This covers
- Auditree
- Removal of `test.cloud.ibm.com` patrols (free clusters) after 6 days


| Process | Brief overview | Useful links |
| ------- | -------------- | ------------ |
| Auditree - overview of our current use | Details the auditree setups we have and what they are used for | To be written |
| Auditree - defining environment variables when setting up travis | What values to set and where to obtain the keys and passwords from | [compliance auditree config runbook](./compliance_auditree_config.html) |
| SEC043:  Keeping non-prod free clusters compliant | Internal users can create `test` patrol clusters against the `test.cloud.ibm.com` endpoint, this runbook details how SRE keep these clusters compliant | How to clean-up test patrols [runbook](./sre_cleanup_patrol_clusters.html) |
{:.table .table-bordered .table-striped}
