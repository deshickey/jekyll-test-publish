---
layout: default
title: IBM Cloud App Configuration Service Dependencies
type: Informational
runbook-name: "IBM Cloud App Configuration Service Dependencies"
description: "IBM Cloud App Configuration Service Dependencies"
service: App Configuration
tags: app-configurations
link: /app-configurations/dependencies.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
# Service Dependencies

Service dependencies are divided in-to two major categories - 

* Runtime Dependencies
* Non Runtime Dependencies
<!-- * Dependencies on third-party libraries  -->

Below picture depicts the service dependency map -

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/dependencymap.png" width="640" />

## Detailed Information

## Runtime Dependencies

### Dependencies on IBM Owned services

| Name | Description | Dependency Type |  Private in Production? | Client Owned Data? | SOC2 compliant | FS Cloud Validated | 
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| IBM® Cloud Databases for Postgres | Persistent Data Storage  | Hard | Enabled | Yes | Yes | TBD | 
| IBM® Cloud Databases for Redis | Cache | Hard | Enabled | Yes | Yes | TBD | 
| IBM® Event Streams for IBM Cloud | Queues | Hard | Planned | Yes | Yes | Yes | 
| IBM Cloud Object Storage | Backup buckets | Soft | Enabled | Yes | Yes | Yes | 
| IBM Cloud Kubernetes Service | Control Plane | Hard | Planned | Yes | Yes | Yes | 
| IBM Cloud Container Registry | Image repository | Update | Excluded | No |Yes | Yes | 
| IBM Cloud CLI | Runtime | Soft | Excluded | No | Excluded | Excluded |
| IBM Cloud Catalog | Runtime | Hard | Excluded | No | No | No |
| IBM Resource Controller | Provisioning | Hard | Excluded | No | Excluded | Excluded | 
| IAM | Access Control | Hard | Excluded | No | Yes | Yes |
| IBM BSS | Billing | Hard |  Excluded | No | Excluded | Excluded | 
| IBM Secrets Manager | Secrets and Certificate management | Soft | Excluded | No | Yes | No |
| IBM Cloud App Configuration | Feature releases | Soft | Enabled | No | Yes | FS Cloud validated |

*Note: Compliance status of each dependency is available [here](https://www.ibm.com/cloud/compliance/global)  Please refer this for the latest information*

### Dependencies on IBM owned components/tools

| Name | Description | Dependency Type |  Client Owned Data? | 
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Liberty Build Pack | Runtime | Packaged | No | 
| IBM JDK | Runtime | Packaged | No |
| IBM Cloud API Explorer | Documentation | Soft | No |
| IBM Cloud Docs | Documentation | Soft | No | 

### Dependencies on Third-party services

| Name | Type | Dependency Type | Private in Production? | Client Owned Data? | 3rd party Approved? | Compliant? | Data Flow Verified? | Comments | 
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| lets-encrypt | Certificate management | Soft | Excluded | No | Yes | Yes | Yes | Migrating to Secrets Manager | 
| DigiCert | Certificate management | Soft | Excluded | No | Yes | Yes | Yes | Migrating to Secrets Manager | 
| IBM Cloud Internet Services (CIS) | Edge | Hard | Excluded | No | Yes | No | Yes | [Allows client metadata](https://pages.github.ibm.com/ibmcloud/Security/guidance/external-service-usage-requirements.html#cloudflare)
| Activity Tracker | Monitoring | Soft | Enabled | No | Yes | Yes |  Yes | [Allows client metadata](https://pages.github.ibm.com/ibmcloud/Security/guidance/external-service-usage-requirements.html#activity-tracker-with-logdna)
| IBM SysDig | Monitoring | Soft | Enabled | No | Yes | Yes | Yes | [Internal Metrices are however allowed to contain "Regulated Data", "CIA impacting data" and "Personal Information"](https://pages.github.ibm.com/ibmcloud/Security/guidance/external-service-usage-requirements.html#monitoring-powered-by-sysdig)
| LogDNA | Logging | Soft | Enabled | No | Yes | Yes | Yes | [Allowed to contain "Regulated Data", "CIA impacting data" and "Personal Information"](https://pages.github.ibm.com/ibmcloud/Security/guidance/external-service-usage-requirements.html#log-analysis-powered-by-logdna) |

Apart from the above listed service-specific dependencies, service also depends on the third-party service requirements mentioned [here](https://pages.github.ibm.com/ibmcloud/Security/guidance/Cloud-Security-Requirements-for-3rd-Parties-Cheatsheet.html#third-party-service-requirements-matrix)


### Dependencies on Third-party components/tools

| Name | Type | Dependency Type | Client Owned Data? |
| :--- | :--- | :--- | :--- | 
| lets-encrypt | Certificate management | Soft |  No |
| Tennable | Compliance  | Soft | No |
| Nessus Update service | Configuration Management | Soft | No | 
| QRadar | Compliance  | Soft | No |
| CrowdStrike(EDR) | Vulnerability Management | Soft | No |
| NPM | Runtime  | Hard | No |
| Node.js | Runtime | Packaged | No |
| GoLang | Runtime | Packaged | No |


Apart from the above listed service-specific dependencies, service also depends on the third-party service requirements mentioned [here](https://pages.github.ibm.com/ibmcloud/Security/guidance/Cloud-Security-Requirements-for-3rd-Parties-Cheatsheet.html#third-party-service-requirements-matrix)


## Non Runtime Dependencies

### Dependencies on IBM Owned services

| Name | Description | Dependency Type |  Client Owned Data? | SOC2 compliant | FS Cloud Validated | 
| :--- | :--- | :--- | :--- | :--- | :--- | 
| Scorecard | Monitoring | Soft | No | Excluded | Excluded |
| CISO signing service | Image signing | Update | No | No | No |
| OSS EDB | Monitoring | Soft  | No | No | No |
| IBM Cloud Compliance and Security Center (SCC) | Security | soft | No | No | No |
| Technical Integration Point (TIP) | Monitoring | Soft | No | No | No |
| IBM Cloud Dev-Ops Continous Delivery | Toolchain | Update | No | No | No |
| IBM Synthetics | Monitoring / Compliance |  Soft | No | Excluded | Excluded | 

### Dependencies on Third-party components

| Name | Type | Dependency Type | Client Owned Data? |
| :--- | :--- | :--- | :--- | 
| Maven | Software Project Management  | Update | No |
| Terraform | Automation  | None | No | 
| Service Now | Monitoring / Change Management  | None | No |
| Tekton | Build, Deploy, Compliance / Monitoring / Alerting Jobs  |  Update | No |
| Travis | Toolchain |  None | No |
| Artifactory | Toolchain  |  Update | No |
| Android Studio | Development  |  Update | No |
| Eclipse | Development |  Update | No |
| VS Code | Development | Update | No |
| AppScan (ASoC) | AppScan | None | No |
| OWASP | Build-time Vulnerability | None | No |
| SonarQube | Build-time Vulnerability | None | No |
| WhiteSource scanning | Build-time Vulnerability | None | No |
| IBM GitHub Enterprise | Toolchain / Documentation | Update | No |
| Amplitude  | Monitoring/Compliance  | None | No |
| Slack | Monitoring  | None | No |
| PagerDuty | Monitoring  | Soft | No |
| SOS Tooling  | Compliance  | None | No |
| PSIRT | Vulnerability Management | None | No |
| IBM Cloud Vulnerability Advisor | Vulnerability Management | Soft | No | 
| IBM CRA | Vulnerability Management | Soft | No |


<!-- | Xcode | Development  | Y | Update | No | -->
Apart from the above listed service-specific dependencies, service also depends on the third-party service requirements mentioned [here](https://pages.github.ibm.com/ibmcloud/Security/guidance/Cloud-Security-Requirements-for-3rd-Parties-Cheatsheet.html#third-party-service-requirements-matrix)


### IBM Corporate services

| Name | Type | Dependency Type | Client Owned Data? | 3rd party Approved? |
| :--- | :--- | :--- | :--- | :--- |
| IBMid | Security | Soft | No | Yes |
| W3Id | Security | Soft  | No | Yes |

**Legand:**

Dependency Type:

* Hard: a production outage would cause a customer-visible outage of the control and/or data plane
* Soft: a production outage would not cause a customer-visible outage of the control and/or data plane
* Update: a production outage would not occur, but updates to VPC/NG services may be unable to be deployed.
* Packaged: packaged as part of the container and there is no downtime for this runtime
* None: service is not used in production


Private in Production?:

* *enabled*: production deployments access the service exclusively over IBM's private network
* *planned*: production deployments have not yet transitioned to the service's private endpoint
* *blocked*: production deployments cannot transition since a private endpoint is not available
* *excluded*: production deployments cannot transition, requirement is excluded

Client Owned Data?:
* yes: processing or storing of [client-owned data](https://pages.github.ibm.com/CloudEngineering/system_architecture/eu_cloud/client_data.html) with the service
* no: do not process or stores client-owned data


3rd party approved?:
* yes: this service is documented at External Services: [3rd Parties and Corporate Services](https://pages.github.ibm.com/CloudEngineering/system_architecture/security/external_services.html)
* no: approval not granted; remediation required


Compliant?:
* yes: usage of the external service is compliant with the data privacy and availability usage requirements discussed in the External Service Usage Requirements.
* tbd: not compliant and a public cloud security exception must be filed.
* exception granted: not compliant but the exception has been filed and the non-compliant condition(s) have been waived.

Data Flow Verified?:

* yes: the data flows match the documented service usage and data flow mappings
* tbd: the data flows have not been verified
* missing: the data flows are not yet documented to verify against
* None : Data does not flow through this tools