---
layout: default
description: How to onboard a non-pipeline account
service: SOS onboarding
title: How development squads can onboard a non-pipeline account for use
runbook-name: "SOS onboarding"
tags: conductors support onboarding
playbooks: ["Runbook needs to be Updated with playbooks info (if applicable)"]
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
link: /development_onboard_non_pipeline_account.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details how to request a non-pipeline account to be used to test, develop or demo IKS

## Detailed information

The use of personal accounts is prohibited to develop, test or demo the IKS offering.  
This refers to the use of personal emails – i.e gmail or provider outside of ibm.com

The use of SRE owned pipeline accounts is the preferred location to create test clusters (i.e Alchemy Staging or Dev Containers) - details of this process is documented in [development account usage runbook](./development_account_usage.html)

Use of IBM accounts is permitted **but only with offical approval**.  
Accounts owned by taskids or individuals which are charged back to a manager in the IKS Tribe/department. (i.e. any ibm.com accounts)
The department could fail an audit if you are found to breach this rule and you continue to use a non-approved account


## Request approval to use a non-pipeline account

You cannot just use a non-pipeline account - documented approved is required.  

To request approval for the use of a non-pipeline account, fill out the [Non pipeline account request form](https://github.ibm.com/alchemy-conductors/security/issues/new?assignees=&labels=Non+pipeline+account+request&template=Non+pipeline+account+use+request.md&title=Non+pipeline+account+request+for+account%3A+) provided by the Security Compliance squad.

Once completed, this will go off for review and will be approved or rejected by a member of the IKS Security compliance squad.

### If rejected

If the request is rejected, please raise any questions about this with the reviewer.  

You must do the following if your request does get rejected:

- The account must not be used for IKS development, test or demo purposes.
- The account must have all IKS resources removed that relate to the development, testing or demonstration of IKS


### If approved

Upon approval, you are able to use the account for test, demo or development purposes.

The following rules are to be adhered to:

- The request template includes an agreement that account owner will keep the account and IKS clusters compliant. This covers the following four main points:
    - Confirmation that your squad will be responsible for this account and ensuring the required tooling is installed against any IKS clusters and all clusters are removed before non-compliance, or kept compliant using the IBM tooling (SOS and csutil).

    - Confirmation that your squad will be responsible for compliance and security of the account and that maintaining future compliance will not be an SRE responsibility. Compliance management includes frequent cluster and worker updates and ensuring that tooling is running without issues.

    - Confirmation that your squad will add SRE automation IDs to your account (conauto@uk.ibm.com and Alchemy.Access@uk.ibm.com) to help track compliance before the account is used for IKS related activities.

    - Confirmation in future, to maintain department compliance, if you have clusters in onboarded accounts that do not have exceptions raised against them, and report non-compliance, then you risk these clusters being automatically removed by SRE tooling.

- Remove clusters before they reach 7 days in age.

- Any clusters that are 7 days in age or older, **must** have [SOS csutil tooling installed](./development_onboard_sos_tools.html)

- Further exceptions would be needed if a cluster in an account cannot have the csutil tooling installed.  (a process will be defined for this). Unless absolutely essential, csutils will be expected to be installed onto any long running clusters.

- Any clusters which do not have an exception for no csutil and remain after 6 days will be candidate for auto cleanup (future SRE /Security compliance tooling) to help keep the department compliant.

- **DO NOT** create clusters in the approved account, and uses credentials set to target another IaaS account (for example dev containers 1186049).  All worker nodes should be placed into the IaaS account linked to the approved Cloud account.

### Post approval actions

As of December 2020, the SRE and IKS Security Compliance squad are working to define the exact steps needed to be run and will work directly with owners of approved accounts to get the correct steps followed post onboarding.  
As a result, the account owner should raise a [conductors team ticket](https://github.ibm.com/alchemy-conductors/team/issues/new) requesting SRE assistance to onboard the account.  Please link to approved `Security GHE ticket` in this new request.

Several actions will be needed, including:

- The account must have `conauto@uk.ibm.com` and `Alchemy.Access@uk.ibm.com` added - these will be needed by SRE/Security to track compliance.

- The account will be onboarded to Auditree - therefore several APIKeys will need to be generated (details to follow)


## Escalation and assistance

There is no formal escalation policy for this. If in doubt with any of these steps, please speak to the SRE Squad  
