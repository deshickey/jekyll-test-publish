---
layout: default
title: Sysdig monitoring on ICD databases
type: Informational
runbook-name: "Security alert from Sysdig monitoring on ICD databases"
description: Security alert from Sysdig monitoring on ICD databases
category: armada
service: sre_operations
link: /iks-icd-sysdig-ops.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes on how to handle Security alert on ICD PostgreSQL/MongoDB/Redis/Etcd databases.

The alert will be triggerred when the ICD PostgreSQL/MongoDB/Redis/Etcd database is showing anomalous excessive database activity on CPU or Memory or I/O.
The database activity could be part of normal activity to be handled by capacity management, or Data mining/exfiltration. We need to determine the cause of the activity, take actions and implement preventive measures.

## Example Alerts

Example:

- https://ibm.pagerduty.com/incidents/Q3N157X059YK4G

Triggering condition: ([guideline](https://github.ibm.com/cloud-governance-framework/security-governed-content/blob/50f354172e2f6740846e3793daba495a6b150326/procedures/detect/detect.md#steps))

- ibm_databases_for_[database]_disk_io_utilization_percent_average_5m
- ibm_databases_for_[database]_memory_used_percent
- ibm_databases_for_[database]_cpu_used_percent (if no dedicated CPU is assigned, no metrics available)
- ibm_databases_for_[database]_disk_used_percent

## Detailed Information

## Investigation and Actions

#### 1. Pagerduty(PD) Alert

PD Alert will be triggered on anomalous excessive database activity. (Data mining/exfiltration vs Capacity management)

#### 2. Check the trend

Check the trend of the alert metrics data by following the steps below.

- 2-1. Click the Sysdig link from the `Alert URL:` secion in the PD alert.
- 2-2. To view the trend of the metrics data, open the alert by clicking the Pencil button. Alternatively you can check the trend in the `<Database> dashboard` in Dashboards under the same Sysdig instance.
  - To access the dashboards:
    - Go to 1185207 - Alchemy Production’s Account:
    - Monitoring Instances: https://cloud.ibm.com/observability/monitoring
    - Find instance for region, example or us-south: `sysdig-IKS-platform-us-south`
    - Open Dashboard
      - Then search for the [database] in the dashboards list

```text
PostSQL dashboard or Databases for PostgreSQL - Overview
MongoDB dashboard or Databases for MongoDB - Overview
Redis dashboard or Databases for Redis - Overview
Etcd dashboard or Databases for Etcd - Overview
```

```text
Note: Pay attention to sudden spikes, prolonged high utilization, or abnormal wait times, as they may indicate data mining attempts or resource-intensive queries.
```

#### 3. Collect information from IBM CLoud Logs 

Collect information from the relevant Platform IBM CLoud Logs by filtering Apps with `ibm_service_instance` value in the PD alert.

- Recommended duration of logs would be plus one min around the incident, which will be 7 min before and 1 min after from the alert triggered time (alerts duration is usually 6 mins).

For example if the alert was triggered at 10:00am, the log to be collected between 9:53-10:01am at least
Check if there was any unusual activity during the time. (Further investigation to be continued in Step 5)

- Example: IBM CLoud Logs instances under `1185207 Alchemy Production` account

| Region   | Platform Sysdig instance           | IBM CLoud Logs instance                        |
|----------|------------------------------------|----------------------------------------|
| [region] | sysdig-IKS-platform-[region]       | kubx-masters-platform-logging-[region] |
|==========|====================================|========================================|
{:.table .table-bordered}

#### 4. Create git issue to the owner team

Database owner team for each databases are shown in the following table.

| Account                      | Database   | Database name                                 | Owner team     |
|------------------------------|------------|-----------------------------------------------|----------------|
| 1185207 Alchemy Production   | PostgreSQL | [region]-armada-microservices-postgres        | armada-ballast |
| 531277 Argonauts Production  | Etcd       | prod-[region]-sb-carrier[NNN]-etcd            | IKS SRE India  |
| 2094928 Satellite Production | Etcd       | etcd-prod-[prod]-bastionx-infra or ...etcd... | IKS SRE India  |
| “                            | MongoDB    | satellite-link-mongodb[NN]-[region]           | Satellite-link |
| “                            | MongoDB    | Razee-Hosted-MongoDB-Prod-[region]            | Razee          |
| “                            | Redis      | Razee-Hosted-Redis-Prod-[region]              | Razee          |
| 2051458 BNPP Prod            | Etcd       | etcd... or  bastionx-prod-[regiion]           | IKS SRE BNPP  |
| “                            | PostgreSQL | [region]-armada-microservices-postgres        | IKS SRE BNPP   |
|==============================|============|===============================================|================|
{:.table .table-bordered}

##### 4.1. Create git issue

Create git issue in the gollowing Github repo to the database owner team for further investigation.

- [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast/issues)
- [Razee](https://github.ibm.com/alchemy-containers/satellite-config/issues)
- [Satellite-link](https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/issues)
- [IKS SRE India](https://github.ibm.com/alchemy-conductors/team/issues) with label `SRE_India`
- [IKS SRE BNPP](https://github.ibm.com/alchemy-conductors/team/issues) with label `SRE_BNPP`

Example:

```text
*Title:*
[Security Alert] PostgreSQL Memory over threshold is Triggered <copy from PD alert title>

*Body:*
Pagerduty alert: <link to the PD alert>
Runbook: https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/iks-icd-sysdig-ops.html

- ibm_location = <au-syd>
- ibm_service_instance = <2b0c755f-3669-4c37-a864-c3c6b6eb1994>
- ibm_service_instance_name = <au-syd-armada-microservices-postgres>

- <Copy the IBM CLoud Logs logs collected in step 3>
```

##### 4.2. Reach out to the owner team

Reach out to the database owner team in the following Slack channel.

- armada-ballast: `#armada-ballast`
- Razee: `#satellite-config`
- Satellite-link: `#satellite-link`
- IKS SRE India: contact `@conductors-in` in `#conductors-for-life` internally, or contact IKS SRE team `@interrupt` in the `#conductors` from external
- IKS SRE BNPP: contact `@conductors-dublin-bnpp` in `#conductors-for-life` internally, or contact IKS SRE team `@interrupt` in the `#conductors` from external

#### 5. Work with the owner team

Work with the owner team to determine whether it is part of normal activity to be handled by capacity management (Case 1), or Data mining/exfiltration (Case 2).

##### Case 1. Normal operation

If the activity is concluded as part of a normal operation and capacity management,

- Adjust the thresholds if necessary to adapt to the changing workload patterns or performance requirements.
- The current alert thresholds were established on a baseline from the metrics during normal operating conditions for a certain period of time. If the threshold to be increased, the database owner team should submit request to the IKS SRE team. Please raise a git issue in the [alchemy-conductors](https://github.ibm.com/alchemy-conductors/team/issues/) git repository including info collected (owner team Git issue link) and the *new threshold value*.

##### Case 2. Data mining or exfiltration

If the activity is concluded (possibly) as part of a malicious Data mining and exfiltration,

- Work with the database owner team (e.g. Postgresql: `armada-ballast`) or data user team (e.g. Postgresql: `armada-cluster(troutbridge)`) and continue further investigation on the details of activity. Suspend or terminate the data mining process, if applicable, and revoke any unauthorized access privileges.
- Refer to the [Cybersecurity & Data Incidents](https://w3.ibm.com/w3publisher/cybersecurity/report-a-cyber-issue) page, and report the Security incident to the [CSIRT](https://engagementform.csirt.ibm.com/incident/new/) home page directly.
- Document the incident, including the actions taken and any preventive measures implemented.

## Automation

- Sysdig monitoring [automation repository](https://github.ibm.com/alchemy-conductors/iks-sysdig-monitoring-sync) (config as code)

## Reference

- Security item [ENS-High op.mon.3.r5](https://github.ibm.com/cloud-governance-framework/security-governed-content/blob/50f354172e2f6740846e3793daba495a6b150326/procedures/detect/detect.md)
- [Cyber Security incident process](https://w3.ibm.com/w3publisher/cybersecurity/report-a-cyber-issue)
- [Sysdig Monitoring](https://cloud.ibm.com/docs/databases-for-postgresql?topic=databases-for-postgresql-monitoring)

## Escalation Policy

- For escalation about the Sysdig monitoring configuration, contact @conductors-aus in #conductors-for-life internally, or contact IKS SRE team @interrupt in the #conductors from external.
- For escalation about the database alert, contact the following database owner team.
- armada-ballast: `#armada-ballast`
- Razee: `#satellite-config`
- Satellite-link: `#satellite-link`
- IKS SRE India: contact `@conductors-in` in `#conductors-for-life` internally, or contact IKS SRE team `@interrupt` in the `#conductors` from external
- IKS SRE BNPP: contact `@conductors-dublin-bnpp` in `#conductors-for-life` internally, or contact IKS SRE team `@interrupt` in the `#conductors` from external
