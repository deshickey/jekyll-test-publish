---
layout: default
title: "Introduction to Dreadnought"
runbook-name: "Introduction to Dreadnought"
description: "An introduction to Dreadnought."
category: Dreadnought
service: dreadnought
tags: dreadnought
link: /dreadnought/dn-general-info.html
type: Informational
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

## Overview
Dreadnought is the IBM Cloud instantiation of a secure and compliant managed IBM Cloud enterprise account for IBM services. The enterprise account is constructed of many sub-accounts and IBM Cloud resources. The accounts and their resources are built and managed via IBM Goldeneye Terraform Modules to provide internal IBM services with managed IBM CD Toolchains, IBM Security Compliance Center, VPC, and RedHat OpenShift infrastructure.

## Detailed Information
For more details, refer to the ["What is Dreadnought" topic](https://test.cloud.ibm.com/docs-internal/dreadnought?topic=dreadnought-dreadnought){:target="_blank"}.

The Dreadnought architectures are a deployment of single and multiple zone Red Hat (ROKS) clusters in VPC for dev, staging, and production environments.  View the Dreadnought user documentation for [Learning about Dreadnought architecture and workload isolation](https://test.cloud.ibm.com/docs-internal/dreadnought?topic=dreadnought-learningdreadnoughtarchitecture){:target="_blank"}.

_**The Platform SRE team is responsible for all services deployed and live (receiving customer traffic) in Dreadnought production environments.**_

## Further Information

### Conductors supported Dreadnought accounts

| Enterprise | Account Name & Account ID | Regions | Compliance Slack Channel | Conductors Live Date | Cabins |
| ---- | ---- | ---- | ---- | ---- | ---- |
| `dn-ent-prod` | `dn-prod-s-cpapi-extended` `a708cf9c0032433782568b6baf876b14` | `au-syd`, `eu-de`, `us-east` | [#dn-s-cpapi-extended-compliance-monitoring](https://ibm.enterprise.slack.com/archives/C06DEFEU21Z) | Oct. 10, 2024 | [ai-assistant](https://github.ibm.com/dreadnought/cabin-config/blob/main/docs/ai-contextual-help/definition.json), [cost-management](https://github.ibm.com/dreadnought/cabin-config/blob/main/core-platform/cost-management/definition.json), [projects](https://github.ibm.com/dreadnought/cabin-config/blob/main/core-platform/projects/definition.json) |
| `dn-ent-prod` | `dn-prod-s-bluefringe` `05211d7f973e4628b18e1ebc29910200` | `au-syd`, `eu-de`, `us-east` | [#dn-s-bluefringe-compliance-monitoring](https://ibm.enterprise.slack.com/archives/C06DH2GDV1A) | Oct. 16, 2024 | [partner-center-sell](https://github.ibm.com/dreadnought/cabin-config/blob/main/core-platform/partner-center-sell/definition.json) |

### Additional Links

[Dreadnought Squads](https://ibm.box.com/s/1i5h6smbbvjylkvl2xqohinlcxo04zni)

[Dreadnought User Documentation](https://test.cloud.ibm.com/docs-internal/dreadnought){:target="_blank"}

[Dreadnought Repository](https://github.ibm.com/dreadnought){:target="_blank"}

[GoldenEye Repository](https://github.ibm.com/GoldenEye){:target="_blank"}

#### Required Slack Channels

##### Dreadnought Main Channels
- [#dreadnought-users](https://ibm.enterprise.slack.com/archives/C03G356K11N)

##### Platform CIE
- [#platform-cie](https://ibm.enterprise.slack.com/archives/C073H0ZF2PQ) - Used by the Platform SRE team to declare a CIE when there is a base issue in a Dreadnought.  Not for a cabin CIE.
- [#dreadnought-support-cie](https://ibm.enterprise.slack.com/archives/C04U1E4VDQA) - This is specific to Dreadnought and also shows some Dreadnought related PagerDuty alerts.

##### Platform Compliance
- [#platform-sre-compliance](https://ibm.enterprise.slack.com/archives/C074M97DFTL)

##### Platform SRE
- [platform-sre-dn (private)](https://ibm.enterprise.slack.com/archives/C06TS78V01Z) - Primary SRE channel for Dreadnought issues and discussions
- [#dn-sre](https://ibm.enterprise.slack.com/archives/C06FXM85EMN) - Use to create an incident via cie-bot for Bastion connection.

##### Dreadnought Prod Trains
- [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN) - Create ana manage trains.
- [#dn-sre-prod-trains-autoapprovals](https://ibm.enterprise.slack.com/archives/C079TBP38LX) - Shows trains created and approval status.
- [dn-sre-trains-approvals (private and restricted)](https://ibm.enterprise.slack.com/archives/C07A14FGLH4) - Restricted

##### Production Monitoring and Compliance channels
- [#dreadnought-prod-monitoring](https://ibm.enterprise.slack.com/archives/C059HL4RC92)
- [#dn-prod-account-violations](https://ibm.enterprise.slack.com/archives/C06530B19GS)
- Dreadnought/SOS Application Compliance and Monitoring<br>
These channels show compliance information and some automation updates for the associated cabin teams.  SOS applications are found in the [compliance-config.json](https://github.ibm.com/dreadnought/cabin-config/blob/main/compliance-config.json).
  - [#dn-s-cpapi-extended-compliance-monitoring](https://ibm.enterprise.slack.com/archives/C06DEFEU21Z)
  - [#dn-s-bluefringe-compliance-monitoring](https://ibm.enterprise.slack.com/archives/C06DH2GDV1A)

#### Optional Slack Channels

##### Dreadnought Prod Testing Only Trains
- [#dn-sre-test-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7LJM89H)
- [#dn-sre-test-prod-trains-autoapprovals](https://ibm.enterprise.slack.com/archives/C07AA8U4C68)

##### Dreadnought Stage Trains
- [#dn-sre-stage-trains](https://ibm.enterprise.slack.com/archives/C07AACP45UL)
- [#dn-sre-test-stage-trains](https://ibm.enterprise.slack.com/archives/C07AA867A5A)

##### Dreadnought Operations
- [#dn-operation-notifications](https://ibm.enterprise.slack.com/archives/C06D02K2CG7)
