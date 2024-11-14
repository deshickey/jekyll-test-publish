---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Access requests for dedicated eu-fr2 IKS SRE Squad.
service: Conductors fr2
title: Access requests for dedicated eu-fr2 IKS SRE Squad.
runbook-name: Access requests for dedicated eu-fr2 IKS SRE Squad.
link: /sre_access_requests_eu_fr2.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Access requests for dedicated eu-fr2 IKS SRE Squad

## Overview

This document pertains specific onboarding and offboarding instructions to a dedicated SRE to eu-fr2 region


### Prerequisites
You should begin by completing the [production onboarding checklist](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/process/production_onboarding.html).

[Access requests for IKS SRE Squad](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html) should be referenced for common onboarding and offboarding processes unless it is specified in this runbook.

Follow the [prerequisites](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#prerequisites) instruction from global SRE onboarding runbook.

### Before you begin notes
Follow the ["before you begin"](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#before-you-begin-notes) instruction from global SRE onboarding runbook.

## Detailed Information

### AccessHub request for an SOS IDMgt
Follow the [SOS IDMgt access request](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#accesshub-request-for-an-sos-idmgt) instruction from global SRE onboarding runbook. \
**Use the following values**

  - **Brand Type**: `BU044-ALC`
  - **Groups**: 
    - `BU044-ALC-Conductor_BNPP`
    - `BU044-ALC-Conductor`

#### Removal of AccessHub entitlements after period of SOS inactivity
Follow the [AccessHub entitlements removal](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html##removal-of-accesshub-entitlements-after-period-of-sos-inactivity) instruction from global SRE onboarding runbook.

### Setting up Global Protect VPN
Follow the [Global Protect VPN setup](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#setting-up-global-protect-vpn) instruction from global SRE onboarding runbook.

### Ticket for self-onboarding to Global Protect VPN profile
Follow the [Global Protect VPN self-onboarding](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#ticket-for-self-onboarding-to-global-protect-vpn-profile) instruction from global SRE onboarding runbook. \
**Use the following values**

  - **Groups**
    - **Preprod**: 
      - `ICCR-VPN-AD-preprod`
      - `IKS-VPN-AD-preprod` 
    - **Prod**:
      - `BNPP-DedOps`

### Enable U2F MFA on IBM Cloud Account
Follow the [U2F MFA enablement](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#enable-u2f-mfa-on-ibm-cloud-account) instruction from global SRE onboarding runbook.

### AccessHub request for IKS Access
Follow the [IKS access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#accesshub-request-for-iks-access) instruction from global SRE onboarding runbook. \
**Use the following values**

   - **Groups**:
     - `ROLE_IKS_SRE_member`
     - `ROLE_IKS_SRE-<your_country>_member`
     - `ROLE_ICCR_SRE_member`
     - `ROLE_ICCR_SRE-<your_country>_member`
     - `ROLE_RAZEE_SRE_member`
     - `ROLE_RAZEE_SRE-<your_country>_member`
     - `ROLE_IKS_SRE-BNPP_member`
     - `ROLE_ICCR_SRE-BNPP_member`

### AccessHub request for Launch Darkly
Follow the [Launch Darkly request](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#accesshub-request-for-launch-darkly).instruction from global SRE onboarding runbook

### Argonauts slack access
Follow the [Slack access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#argonauts-slack-access) instruction from global SRE onboarding runbook.

### SOS security center
Follow the [SOS security center access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#sos-security-center) instruction from global SRE onboarding runbook. \
**Use the following values**

  - **Brand Type**: `BU044-ALC`, `BU203-ARMADA` and `BU410-ALC_FR2`
  - **Groups**:
    - `BU044-ALC-SOS-SecurityCenter`
    - `BU203-ARMADA-SOS-SecurityCenter`
    - `BU410-ALC_FR2-SOS-SecurityCenter`

### SOS Inventory
Follow the [SOS inventory access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#sos-inventory) instruction from global SRE onboarding runbook. \
**Use the following values**

  - **Brand Type**: `BU410-ALC_FR2`
  - **Groups**:
    - `BU410-ALC_FR2-SOS-Inventory-Editor`
    - `BU410-ALC_FR2-SOS-Inventory-Reader`

### Armada Inventory
Follow the [Armada inventory access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#armada-inventory) instruction from global SRE onboarding runbook. \
**Use the following values**

  - **Brand Type**: `BU203-ARMADA`
  - **Groups**:
    - `BU203-ARMADA-containers-kubernetes-dev-SOS-Inventory-Reader`

### ServiceNOW
Follow the [ServicNOW access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#servicenow) instruction from global SRE onboarding runbook.

### VPN Access
Follow the [VPN access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#vpn-access) instruction from global SRE onboarding runbook. \
**NOTE**: this step is only required for `dev`, `stage` and `eu-fr2` environment

### CIEBot request
Follow the [CIEBot access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#ciebot-request) instruction from global SRE onboarding runbook.

### Pagerduty
Follow the [PagerDuty setup and access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#pagerduty) instruction from global SRE onboarding runbook. \
**NOTE**: the `eu-fr2` service policy only includes `dev`, `prestage`, `stage` and `eu-fr2`

### SRE & Container Meetings
Follow the [SRE & Container meetings](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#sre--container-meetings) instruction from global SRE onboarding runbook.

### Conductors Box Access
Follow the [Conductors Box access](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#conductors-box-access) instruction from global SRE onboarding runbook.

### Checklist

- Go to https://github.ibm.com/alchemy-conductors/documentation-pages/blob/master/docs/runbooks/sre_access_requests_bnpp.md#checklist
- Click edit and copy the below in to **YOUR** onboarding git issue created by your Team Lead
- Do **NOT** fill in the below.


- [ ] Access to Argonauts Slack - ibm-argonauts.slack.com
- [ ] Service Now > Incidents > Create New Incident
- [ ] TIP Access - In slack > ciebot > run `incb create -s containers-kubernetes -e london -j new user test`
- [ ] SOS Sec Center - Login to pimconsole.sos.ibm.com
- [ ] Successful login to IKS via Bastion
- [ ] Access to Conductors Box folder
- [ ] SOS Inventory Access
- [ ] Armada Inventory Access
- [ ] LaunchDarkly
- [ ] Successful connection of GLobal VPN 
- [ ] Successful connection to Tunnelblick
- [ ] Have physical possession of a yubikey
- [ ] Contact Softlayer to setup yubikey
- [ ] Access https://ibm.pagerduty.com part of Alchemy Team

