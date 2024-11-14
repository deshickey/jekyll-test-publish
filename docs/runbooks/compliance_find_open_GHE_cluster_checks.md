---
layout: default
description: compliance_find_open_GHE_cluster_checks
service: Security
title: Tooling that finds open GHE issues which were raised by the Compliance teams automation
runbook-name: "Tooling that finds open GHE issues which were raised by the Compliance teams automation"
link: /compliance_find_open_GHE_cluster_checks.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Find open issues for non-production clusters

## Overview

This specific runbook describes a jenkins job created to help the Compliance squad keep track of the issues raised by the tooling against clusters in the below accounts.

- DEV_CONTAINERS - 1186049
- SUPPORT - 278445
- ARGONAUTS_DEV - 659397
- STGIKS - 1858147
- SATELLITE_STAGE - 2146126
- ALCHEMY_STAGING - stage account in `test.cloud.ibm.com`

Since the introduction of FS-Cloud rules, non-production account compliance status is just as important as the status of our production environments.

The tooling finds all the issues raised by the tooling described in [cluster checks runbook](./compliance_non_production_csutil_cluster_checks.html) and reports them to the `IKS Compliance squad` who can then follow up on the issues.


## Detailed Information

- The jenkins job runs each day
- If issues are found, they are emailed to the `Compliance squad`
- Any issues that are critical and need a review are also alerted in slack to the `@compliance` slack handle in the [Compliance squads automation channel](https://ibm-argonauts.slack.com/archives/C7X2SL6NR)

## Actions to take

The Compliance squad will review these tickets and take appropriate action to chase IKS tribe members.  If csutil issues are not resolved, the clusters in question run the risk of being removed without warning.


## Useful links

- [Cluster check GHE Code](https://github.ibm.com/alchemy-conductors/automation-team/tree/master/utils/cluster_checks)
- [Cluster check Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/check-non-prod-clusters-csutil-status/)
- [GHE issue tracker jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/find-non-prod-csutil-open-ghe-issues/)
    - This was written to help track and alert the compliance squad on the issues being raised by the tooling.

Useful links for csutil debugging and support
- [#sos-armada slack channel](https://ibm-argonauts.slack.com/archives/C7H1HAXT3)
- [Debugging csutil pod issues](./armada/tugboat_debug_csutil.html) - documentation produced by SRE to help debug csutil issues on tugboats but the theory on any IKS cluster is the same
- [Official csutil troubleshooting documentation](https://github.ibm.com/ibmcloud/ArmadaClusterSetupCLI/blob/master/troubleshooting.md)


## Escalation
If you are unsure what to do, or have exhausted all the invesigation steps detailed in this runbook, then reach out to the wider SRE squad for further help or post in the [#iks-sre-compliance](https://ibm-argonauts.slack.com/archives/C02HNQGGM8V) slack channel for assistance.

Consider reaching out to the SRE Security Compliance Squad to help investigate this further.

If you are unsure about running any of these steps, don't! Seek help and guidance.
