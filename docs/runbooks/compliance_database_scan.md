---
layout: default
title: Overview of Database Scanning
type: Informational
runbook-name: "Overview of Database Scanning"
description: "Overview of Database Scanning"
service: Conductors
link: /compliance_database_scan.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document describes the scanning of databases and how the [Database healthcheck policy](https://pages.github.ibm.com/ibmcloud/Security/guidance/Vuln-Management.html#secure-configuration-scanning-health-checks--databases) is applied.

The healthcheck scans are run from Tenable's Nessus scanners and configured and viewed in the Security Center. 

The scans are configured to run weekly and form part of the compliance squad's [weekly compliance checks](https://github.ibm.com/alchemy-conductors/security-docs/blob/master/Compliance-Review.md) (note that this document is only available to approved people). Issues are raised for any valid vulnerabilities.

## Detailed information

These sections detail our use of the Nessus security scanning tooling provided by SOS.

### How to get access to Security Center

Access to the Security Center is via AccessHub. See the database scanning documentation [requesting access](https://pages.github.ibm.com/ibmcloud/Security/guidance/database-scan.html#apply-for-accesshub-role).

The security center used is the SC04 Console [https://w3sccv4.sos.ibm.com](https://w3sccv4.sos.ibm.com).

### How to setup scans

See [how to setup scanning](https://pages.github.ibm.com/ibmcloud/Security/guidance/database-scan.html) for the instructions on how to get access to the Security Center and how to configure scans.

For the database scans we use:
- Database admin credentials to ensure that all the health checks are completed.
- Separate scan per database to avoid known problems with false failures. See [issue 13938](https://github.ibm.com/alchemy-conductors/team/issues/13938) for more details.

### Databases in scope

The [policy scope](https://pages.github.ibm.com/ibmcloud/Security/guidance/Vuln-Management.html#secure-configuration-scanning-health-checks--databases) is:
> All production database instances for in-scope databases 

All databases provisioned on ICD in production will have scans configured. As per the policy,
>  For compliance purposes only those databases with a published [CIS](https://www.cisecurity.org/cis-benchmarks/) benchmarks at the version level in use that have an [audit file available from Nessus](https://www.tenable.com/downloads/database-audit-policies) that is categorized as a database are considered in scope. 

For IKS this includes:
- Postgres database

This excludes:
- ETCD deployments

### Postgres databases

There are a number of limitations with the Postgres database scans which lead to a number of vulnerabilities being reported as false positives or requiring further manual review.

The CIS benchmarks include healthchecks that are not valid for a hosted Postgres database. 
- Linux healthchecks are not valid. 
- Some manual checks are not valid. See [https://ibm-argonauts.slack.com/archives/C8YC87U4X/p1634241211041600](https://ibm-argonauts.slack.com/archives/C8YC87U4X/p1634241211041600).

Some of the healthchecks require manual review of the output. 



The following table shows the known vulnerability reports and action to take:

Plugin | Plugin Name | Comment | PCE
-- | -- | -- | --
1095408 | 3.1.3 Ensure the logging collector is enabled | Does not apply to ICD hosted database. | PCE-ALL-000117
1095410 | 3.1.5 Ensure the filename pattern for log files is set correctly | Does not apply to ICD hosted database. | PCE-ALL-000117
1095412 | 3.1.7 Ensure 'log_truncate_on_rotation' is enabled | Does not apply to ICD hosted database. | PCE-ALL-000117
1095414 | 3.1.9 Ensure the maximum log file size is set correctly | Does not apply to ICD hosted database. | PCE-ALL-000117
1095417 | 3.1.12 Ensure the correct messages are written to the server log | Does not apply to ICD hosted database. | PCE-ALL-000117
1095427 | 3.1.22 Ensure 'log_line_prefix' is set correctly | Does not apply to ICD hosted database. | PCE-ALL-000117
1095431 | 3.2 Ensure the PostgreSQL Audit Extension (pgAudit) is enabled - pgaudit   installed | Enabled, but audit sees wrong value. Check manually that the output value   includes `pgaudit`. Example good output `ibmclouddb:   "pg_stat_statements,pgaudit,supautils"` | NA
1095433 | 4.7 Ensure the set_user extension is installed | Does not apply to ICD hosted database. | PCE-ALL-000117
1095441 | 6.9 Ensure the pgcrypto extension is installed and configured correctly | Not recommended for ICD hosted database. | PCE-ALL-000117
1095434 | 4.8 Make use of default roles | Does not apply to ICD hosted database. | PCE-ALL-000117
1095435 | 6.2 Ensure 'backend' runtime parameters are configured correctly | Does not apply to ICD hosted database. | PCE-ALL-000117
1095436 | 6.3 Ensure 'Postmaster' Runtime Parameters are Configured | Does not apply to ICD hosted database. | PCE-ALL-000117
1095437 | 6.4 Ensure 'SIGHUP' Runtime Parameters are Configured | Does not apply to ICD hosted database. | PCE-ALL-000117
1095438 | 6.5 Ensure 'Superuser' Runtime Parameters are Configured | Does not apply to ICD hosted database. | PCE-ALL-000117
1095439 | 6.6 Ensure 'User' Runtime Parameters are Configured | Does not apply to ICD hosted database. | PCE-ALL-000117
1095442 | 7.1 Ensure a replication-only user is created and used for streaming   replication | Does not apply to ICD hosted database. | PCE-ALL-000117
1095443 | 8.1 Ensure PostgreSQL configuration files are outside the data cluster | Does not apply to ICD hosted database. | PCE-ALL-000117
1095444 | 8.2 Ensure PostgreSQL subdirectory locations are outside the data cluster | Does not apply to ICD hosted database. | PCE-ALL-000117
1095445 | 8.4 Ensure miscellaneous configuration settings are correct | Does not apply to ICD hosted database. | PCE-ALL-000117
1095446 | 4.4 Ensure excessive DML privileges are revoked | Does not apply to ICD hosted database. | PCE-ALL-000117
1095447 | 4.5 Use pg_permission extension to audit object permissions | Does not apply to ICD hosted database. | PCE-ALL-000117
1095448 | 4.6 Ensure Row Level Security (RLS) is configured correctly | Does not apply to ICD hosted database. | PCE-ALL-000117
1095449 | 6.1 Ensure 'Attack Vectors' Runtime Parameters are Configured | Does not apply to ICD hosted database. | PCE-ALL-000117
1095450 | 7.2 Ensure base backups are configured and functional | Does not apply to ICD hosted database. | PCE-ALL-000117
1095451 | 7.4 Ensure streaming replication parameters are configured correctly | Does not apply to ICD hosted database. | PCE-ALL-000117
1095454 | 4.3 Ensure excessive function privileges are revoked | Does not apply to ICD hosted database. | PCE-ALL-000117
1095432 | 4.2 Ensure excessive administrative privileges are revoked | Users other than `admin`, `ibm`, `ibm-replication` and `repl`, should not have any admin privileges. Example output for other user `"ibm_cloud_adcae0e6_6534_44d3_abf0_592dc22ea08b", 24996, f, f, f, f, ********, NULL, {role=ibm-cloud-base-user}` | PCE-ALL-000117



## Escalation Policy

There is no formal escalation policy.

Reach out to the IKS SRE Security Compliance Lead in one of the channels below to ask further questions

- `#conductors` if you are not a member of the SRE Squad.
- `#sre-cfs` or `#conductors-for-life`  if you are a member of the SRE squad (these are internal private channels)


