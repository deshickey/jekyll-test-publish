---
layout: default
description: Information on what accounts dev squads should use to create test/dev/demo clusters
service: onboarding
title:  Information on what accounts dev squads should use to create test/dev/demo clusters
runbook-name: "account usae"
tags: conductors support onboarding
playbooks: ["Runbook needs to be Updated with playbooks info (if applicable)"]
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
link: /development_account_usage.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details what accounts a member of the IKS tribe use when creating short lived test clusters.

## Detailed information

This document covers the accounts where IKS tribe members should create clusters, and the rules they need to follow when creating clusters

This covers creating clusters against both `test.cloud.ibm.com` and `cloud.ibm.com` api endpoints

## Requesting access

Developer access will be granted to the accounts via AccessHub membership to `ROLE_IKS_Developer` role - see [AccessHub access control for IKS documentation](./../process/access_control_using_accesshub.html) for further details

## Accounts to use
The below sections go into further details about each account to use

### test.cloud.ibm.com accounts to use

Preproduction `(targeting test.cloud.ibm.com)`
- IKS & ROKS on VPC Gen 2 - IKS.Stage.VPC.Network TEST (1152aa1c1ec54274ac42b8ad8507c90c)
- IKS & ROKS on Classic - Alchemy Staging's Account (43c2cf73620ae552587a136bd0d6d6a0)


**Please note:** 
- **DO NOT** run `credential set` in the Alchemy Staging's Account.  This action may break cluster creation.
- SRE will perform a regular credentials set in Alchemy Staging's Account to ensure the correct credentials are in place - Jenkins job to be created to do this.
- The `default` resource group should be used by all - this is due to staging restrictions and linking to infrastructure


### cloud.ibm.com accounts to use

Production `(targeting cloud.ibm.com)`

- IKS & ROKS on VPC - IKS VPC NextGen Development (bdd96d55c7f54798a6b9a1e1bedec37c) <-> 1879101
- IKS & ROKS on Classic - Dev Containers (47998ac029ed4ca69cf807338b7dbd2e) <-> 1186049

When using the `Dev Containers` account;

- Provision your clusters into specific resource group – a new RG will be setup for each squad; examples below:
    - Armada-bootstrap
    - Armada-network
    - Armada-ironsides

- It is the Development squads’ responsibility to set the correct credentials in their own RG

## Your responsibilities 

By using these accounts and this process, you are agreeing to keeping clusters you create in complaince, according to IBM security rules [see documentation here for full details](https://test.cloud.ibm.com/docs/service-framework?topic=service-framework-security-sec-)

The SRE and Security squads will monitor for compliance, but will **NOT** be responsible for addressing compliance related issues found. Any clusters found to be out of compliance will be candidate for removal by automation.

## General rules to follow

- Cleanup clusters before they get to 7 days in age (reasons include)
    - To remain compliant, SOS scans need to occur against all servers after they exist for 7 days.  This requires `csutil` tooling to be installed.  To avoid this, decommission the cluster asap after use.
    – Save the department money! VSIs and baremetals can become expensive and these are all charged back to our department

- If you need the cluster over 7 days, you **MUST** [install csutil](./development_onboard_sos_tools.html) 

- It is the cluster owners responsibility (not SREs) to keep the cluster compliant 
    - Perform regular worker reloads
    - Perform regular kube updates
    - This can be avoided by deleting clusters and recreating them when required.

- Don't create clusters in your own account and workers in 1186049 using credentials set.  These will be candidate for deletion without warning.

- Don't leave clusters hanging about for future use – clean-up and save the department money

## Tips For Developers

The network team created a script that will log you in to the proper account via `ibmcloud login` based on the environment
and type of cluster you want to work with.  It also provides example commands to create clusters.  That script can be found here: https://github.ibm.com/alchemy-containers/armada-network/blob/master/tools/iks-login.sh

There are already the max of 10 VPCs created in stage.  As more developers use this shared account for VPC clusters we will probably need to delete the ones that are there and create some general use ones, for instance:

1. A VPC for general use, with a subnet in each zone that has a public gateway, and a subnet in each zone without a public gateway
2. Some special-use VPCs for anyone (test accounts, for instance) that might have special requirements
3. A few VPC spots that can be reserved for a short amount of time for developers doing work that requires a specific configuration for a VPC (i.e. certain IP address prefix ranges for use with a VPN, etc)

I also created a box note to list what scenarios currently can not be done by clusters in the shared account: https://ibm.box.com/s/gumdul1ymeinfaxq8yfxcktasoepz1ys   This box note also has a few tips for how to workaround some of those limitations.

## Need a dedicated account?

If a squad cannot use the approaches defined in this runbook, the an option is to request onboarding of a non-pipeline account.  
Please read [development onboard non-pipeline account runbook](./development_onboard_non_pipeline_account.html) which explains the process to follow.

## Account api-key and credentials set information

###  1186049 cloud.ibm.com account

The SRE squad have executed `ibmcloud ks api-key reset` as user `conttest@us.ibm.com` in the following regions against the following resource groups

#### Resource Groups
- armada-ingress
- armada-cluster
- armada-deploy
- armada-carrier
- armada-docs
- armada-ironsides
- armada-ui
- armada-storage
- netint
- armada-update
- armada-kedge
- armada-bootstrap
- armada-network
- armada-performance
- armada-hybrid
- armada-ballast


#### Regions
- au-syd
- jp-osa
- jp-tok
- eu-de
- eu-gb
- ca-tor
- us-south
- us-east

The credentials for `conttest@us.ibm.com` are stored in thycotic and can be access by any SRE to re-run any of these commands if required

### test.cloud.ibm.com accounts

In the `Alchemy Staging's (43c2cf73620ae552587a136bd0d6d6a0)` account, SRE have created a [jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/Compliance/job/stagingAccountAPIKeyReset/), which on a daily basis will execute the following `credential set` command

```
ibmcloud ks credential set classic --infrastructure-username conttest@us.ibm.com --infrastructure-api-key ${IBMCLOUD_CONTTEST_DEV_CONTAINERS_INFRA_API_KEY} --region us-south

```

Running this, ensure that all classic clusters in the staging account, have worker nodes provisioned as `conttest@us.ibm.com` in 1186049.


## Escalation and assistance

For discussions on the process, see [dev-cluster-management-discuss slack channel](https://ibm-argonauts.slack.com/archives/C01GDABS26A)

There is no formal escalation policy for this. If in doubt with any of these steps, please speak to the SRE Squad  
