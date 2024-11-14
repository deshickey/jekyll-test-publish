---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Runbook detailing how to restore SOS IDMgt entitlements
service: Conductors
title: How to restore SOS IDMgt entitlements
runbook-name: How to restore SOS IDMgt entitlements
link: /sre_restoring_sos_idmgt_entitlements.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes how to restore SOS IDMgt entitlements that are removed by the SOS IDMgt account compliance tool.


## Detailed Information

#### Why was my entitlement(s) removed by the SOS IDMgt account compliance tool?

The SOS IDMgt account compliance tool checks for inactive Shared Operational Services (SOS) accounts and revokes their production access, as recommended by:

[https://pages.github.ibm.com/ibmcloud/Security/guidance/Access-Control.html#disabling-inactive-accounts](https://pages.github.ibm.com/ibmcloud/Security/guidance/Access-Control.html#disabling-inactive-accounts)

SOS accounts are considered inactive if, the account was created at least 90 days ago, **AND** they meet any of the following criteria:

- password is over 90 days old
    - checked via `pwdLastSetDate` LDAP attribute
- account `lastLogon` date is >= 90 days
    - checked via `lastLogon` and `lastLogonTimestamp` LDAP attributes

## Actions requires

Once your SOS IDMgt entitlements are revoked you will need to request access to the revoked entitlement via AccessHub.

### Steps

1. Login to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome) `https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome`
1. Select `Manage My Existing Access`
1. Search for `SOS IDMgt`
1. Click Modify
1. Ensure `BU044-ALC` brand is selected in Select Brand section
1. Tick checkbox `I confirm there are no SOD conflicts with this request`
1. Click Add
1. Search for entitlement group, then click select and Done
1. Scroll down and click Review & Submit button
1. Business Justification (For example: `IKS SRE EU`)
1. Check box to confirm that I have reviewed the access which is requested
1. Submit

If you require your access to be restored urgently please follow up with listed approver.
