---
layout: default
title: armada-cluster-squad - ProviderRiaasAPIClientServiceAccountAuthorisationError
type: Alert
runbook-name: "armada-cluster - ProviderRiaasAPIClientServiceAccountAuthorisationError"
description: "armada-cluster - Provider RIAAS API Forbidden Error 403"
service: armada-cluster
link: /cluster/cluster-squad-provider-riaas-api-account-auth-error.html
playbooks: []
failure: []
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert means that the Service ID used by the IKS automation is not authorized to manage the resources in the service account, as we are seeing a large number of 403 responses from the VPC API

## Example Alert

Example PD title:
- `#30960XXX: bluemix.containers-kubernetes.prod-wdc07-carrier2.armada-cluster_provider_apiclient_auth_errors_g2_403`

## Actions to take

1. Confirm that the issue is affecting VPC Gen 2, and the region:
  - check the `provider` label of the alert - `g2` = Gen 2
  - check the `crn_region` label of the alert for region

2. Raise a pCIE to document the potential but likely impact on customers:

```
TITLE:   Issue with IBM Kubernetes cluster provisioning and worker node operations

SERVICES/COMPONENTS AFFECTED:
- IBM Kubernetes Service
- OpenShift on IBM Cloud

IMPACT:
- IBM Kubernetes Service, using VPC Gen2 infrastructure
- Users may see delays or be unable to provision workers for new or existing clusters
- Users may see delays or be unable to provision persistent volume claims for existing clusters
- Users may see delays or be unable to replace, rebooting or deleting existing workers of clusters
- Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

STATUS:
- 202X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
```

3. Review the configuration of the service account (`IKS.Prod.VPC.Service` (bab556e1c47446ef8da61e399343a3e7)), and the ServiceID (this will be different for each region, but should follow a pattern similar to: `prod-ca-tor-VPC-G2-ServiceID`). 
   
   In order to do this, log in to <https://cloud.ibm.com>, switch to the `IKS.Prod.VPC.Service` account, navigate to `Access (IAM)` from the `Manage` dropdown menu at the top, and verify the following:
  - The ServiceID for the region exists.
  - Is the API Key for the ServiceID unlocked and present?
  - Has the API Key been revoked?
  - Does the ServiceID have the correct permissions for its purpose? 
    - The ServiceID for the region should be a part of an access group granting permissions to `VPC Infrastructure Services`, 
    - It should have visibility of the regional resource group.

4. If the above checks did not help identify the cause, review the logging to find an occurrence of the issue.
  - Go to logs in affected region and switch to `cluster-squad/default-view`
  - Search for `app:armada-provider-riaas riaasIsServiceAccount:==true statusCode:==403` around the time the alert has fired. 
  - Gather: `req-id`, `endpoint`, `path` and `time`

5. Raise a support ticket from the Service account:
  - Log in to <https://cloud.ibm.com>
  - Switch to the `IKS.Prod.VPC.Service` (bab556e1c47446ef8da61e399343a3e7) account
  - Navigate to a https://cloud.ibm.com/unifiedsupport/cases/add and enter these details:
``` 
Offering: Virtual Server for VPC
Subject:  RIAS API for VPC Gen2 requests failing with 403 status
Description:

The IBM Kubernetes Service IaaS automation is failing to manage infrastructure on behalf
of customers due to a high number of 403 responses from the RIAS API for VPC Gen2.

This problem is impacting multiple customers in the following regions:

- <region>

Sample failing request details:
- Account: bab556e1c47446ef8da61e399343a3e7
- Endpoint: 
- Path: 
- Request ID: 
- Time: 
```

6. After the cause has been rectified, the system should start operating normally and the alert will resolve within an hour.
   
7. If the alert has not resolved within 90 minutes from the point it started, confirm the CIE.

## Escalation Policy

If the VPC SRE team do not confirm that they have a CIE, the steps outlined above did not rectify the issue, and the problem continues to impact our customers, page the troutbridge team to investigate [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98).

  Slack Channel:
  You can contact the dev squad in the #armada-cluster channel

  GHE Issues Queue:
  You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new)
