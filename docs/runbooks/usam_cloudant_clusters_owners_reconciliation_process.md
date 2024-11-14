---
layout: default
description: How to perform manual reconciliation of Cloudant clusters owners
service: Security
title: Cloudant Clusters owners manual reconciliation
runbook-name: "Cloudant Clusters owners manual reconciliation"
link: /usam_cloudant_clusters_owners_reconciliation_process.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

# Cloudant Clusters owners manual reconciliation

## Overview 
This runbook describes how to handle manual reconciliation of Cloudant clusters owners

## Example alerts
None

## Detailed Information
The automatic USAM reconciliation cannot be performed on Cloudant clusters owners groups because of missing APIs at the Cloudant datasource. Currently the list of clusters owners can be only retrieved by sending a request (via email) to the Cloudant support.

## Detailed Procedure
1. Send an email to the Cloudant Support `support@cloudant.com` copying Stuart Hayton (`stuart.hayton@uk.ibm.com`) and requesting the list of owners for all the IBM Alchemy clusters, which you can extract from [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/blob/master/reference/cloudant_clusters.md) .

2. Access USAM to request a report of the details of the Argonauts System, at the following url: [USAM Argonauts system](https://usam.svl.ibm.com:9443/AM/reports/ViewSystemInfo?&systemid=5436&sysName=Argonauts) and search for the `System administrators` section.

3. Contact the system administrators asking them to extract for you the list of active members for the Argonauts system, subscribed to the `cloudant-ibm-alchemy-*-owners` groups.

3. Once you received the list of current clusters owners from the Cloudant support, and the list of USAM members from the System Administrators, you can proceed comparing the lists. Compile a list of any mismatch found, indicating which owner is missing from which list.

4. Attach the result of the analysis to the GHE issue that triggered this periodic activity, and notify the USAM System Administrators for the Argonauts system


## Automation
None
