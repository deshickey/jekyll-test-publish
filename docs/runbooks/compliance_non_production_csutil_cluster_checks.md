---
layout: default
description: compliance_non_production_csutil_cluster_checks
service: Security
title: Non production csutil cluster check automation
runbook-name: "Non production csutil cluster check automation"
link: /compliance_non_production_csutil_cluster_checks.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Compliance non-production csutil cluster check automation

## Overview

The runbook provides an overview on tooling which assists with the compliance tracking of IKS/ROKS clusters deployed in the following non-production accounts

- DEV_CONTAINERS - 1186049
- SUPPORT - 278445
- ARGONAUTS_DEV - 659397
- STGIKS - 1858147
- SATELLITE_STAGE - 2146126
- ALCHEMY_STAGING - stage account in `test.cloud.ibm.com`


## Why the tooling was created

Since the introduction of FS-Cloud rules, non-production account compliance status is just as important as the status of our production environments.

Our non-production pipeline accounts are not monitored (via prometheus and pagerduty) as closely, therefore, many issues are being raised by the Compliance team very close to the due date/time.

As a result, the compliance automation team have generated some basic monitoring of non-production IKS and ROKS clusters, in order to reduce the amount of issues being observed in our non production accounts.

The tooling covers the following;

1.  Will raise an issue if a csutil VPN certificate has not been reserved for a cluster
1.  Will raise an issue if csutil has not been deployed to a cluster
1.  Will raise an issue and will attempt to reload worker nodes in a cluster which are in a critical / non running state
1.  Will check csutil pod status, attempt basic self healing (pod restarts) and raise an issue to track

These are the common scenarios where we were seeing a number of compliance tickets being raised - example: A worker node is critical and has not been spotted, so the tooling stops working and the node stops checking into SOS.


## Detailed Information

- The jenkins job runs several times each day per account
- The job uses configuration in GHE to try and work out where it needs to raise the tracking issues (either by cluster name or resource group)
- GHE templates are used to provided detailed information to the squad in order for them to action any tickets that the self healing cannot fix

## Actions to take if tickets are raised against a squad

It is the responsibility of the owning squad to keep the cluster in good health.  Issues raised by the tooling should be directed to the correct squads report.  Any clusters which are not looked after run the risk of being removed to help maintain compliance.

Any clusters missing a csutil deployment risk being automatically cleaned up, without warning, but with prior approval from a compliance or SRE lead.

Any issues with csutil should be directed to the `IKS SRE squad` to help debug if the documentation on csutil does not help fix the issue.

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
