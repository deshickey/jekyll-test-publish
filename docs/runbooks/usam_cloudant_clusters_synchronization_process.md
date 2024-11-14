---
layout: default
description: How to synchronize the list of Cloudant clusters with the related USAM groups
service: Security
title: Cloudant Clusters syncrhonization with USAM groups
runbook-name: "Cloudant Clusters syncrhonization with USAM groups"
link: /usam_cloudant_clusters_synchronization_process.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

# Cloudant Clusters syncrhonization with USAM groups

## Overview
This runbook describes how to handle manual synchronization between the list of Cloudant clusters and the USAM groups used to track the owners of each cluster

## Example alerts
None

## Detailed Information
The list of clusters cannot be retrieved progammatically, but is kept up to date [here](https://github.ibm.com/alchemy-registry/registry-build-squad/blob/master/reference/cloudant_clusters.md)
This list must be used as a reference to update the related USAM groups, which are user to track owners of the clusters.


## Detailed Procedure

1. Access USAM to request a report of the details of the Argonauts System, at the following [url](https://usam.svl.ibm.com:9443/AM/reports/ViewSystemInfo?&systemid=5436&sysName=Argonauts)

2. In the web resulting web page, search for Cloudant Privileged Groups, using the `cloudant-ibm-alchemy` search string

3. Compare the list of such USAM groups with the list of *Old Style* clusters available [here](https://github.ibm.com/alchemy-registry/registry-build-squad/blob/master/reference/cloudant_clusters.md)
Each cluster must have a corresponding USAM group named `cloudant-<cluster_name>-owners` .
Compile a list of any mismatch found, indicating which USAM group is missing, and which USAM group must be removed because the related cluster no longer exists.

4. Attach the result of the analysis to the GHE issue that triggered this periodic activity, and notify the System administrators
Note: you can identify the system administrators for the Argonauts system by looking at the top of this [page](https://usam.svl.ibm.com:9443/AM/reports/ViewSystemInfo?&systemid=5436&sysName=Argonauts), and searching for `System administrators`

Note: *New Style* clusters are in the Registry IBM Cloud Accounts and controlled via Cloud IAM.

## Automation
None

