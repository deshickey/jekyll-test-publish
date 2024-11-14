---
layout: default
title: armada-cluster-squad - ProviderRiaasAPIClientServerError
type: Alert
runbook-name: "armada-cluster - ProviderRiaasAPIClientServerError"
description: "armada-cluster - Provider RIAAS API Server Error 500/503"
service: armada-cluster
link: /cluster/cluster-squad-provider-riaas-api-server-error.html
playbooks: []
failure: []
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert means that there is a large number of 5XX responses when requesting information from the VPC API

## Example Alert

Example PD title:
- `#30960XXX: bluemix.containers-kubernetes.prod-wdc07-carrier2.armada-cluster_provider_apiclient_5XX_errors_g2_500`
- `#30960XXX: bluemix.containers-kubernetes.prod-dal10-carrier4.armada-cluster_provider_apiclient_5XX_errors_g2_503`

## Actions to take

1. Identify the region
    - check the `crn_region` label of the alert for region
    - check the `status` label of the alert for the region

2. Raise a pCIE to document the potential but likely impact on customers:

    ```
    TITLE:   Delay with IBM Kubernetes cluster provisioning and worker node operations

    SERVICES/COMPONENTS AFFECTED:
    - IBM Kubernetes Service
    - OpenShift on IBM Cloud

    IMPACT:
    - IBM Kubernetes Service, using VPC Gen2 infrastructure
    - Users may see delays in provisioning workers for new or existing clusters
    - Users may see delays in provisioning persistent volume claims for existing clusters
    - Users may see delays in replacing, rebooting or deleting existing workers of clusters
    - Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

    STATUS:
    - 202X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
    ```

3. Check for a potential upstream CIE in the [#ipops-cases](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD) Slack channel:

    ```
    IKS SRE are observing a high number of 5xx failures from RIAS API in region <region>
    which are impacting IKS automation of customer infrastructure. Are you aware of any 
    ongoing outages that could explian these failures?
    ```
4. If ipops confirm that there is an ongoing outage skip to step 9
5. Open the LogDNA instance for the region affected.
    - Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment
    - In the left hand pane under `CLUSTER-SQUAD` there should be a view called `default-view`, open that view to display any clusters that have active work on more than 80 workers
    - Run the following query `"Non-success" -409 -404 -403 -400`
    - Expand a few of the returned items and capture the `req-id`, `statusCode` and `url` fields where the `statusCode` matches the `status` in the alert

6. Raise a support ticket from the Service account for the affected provider:
    - Log in to <https://cloud.ibm.com>
    - Switch to the relevant account
      - Gen 2: `IKS.Prod.VPC.Service` (bab556e1c47446ef8da61e399343a3e7)
    - Navigate to a https://cloud.ibm.com/unifiedsupport/cases/add and enter these details:

    ```
    Offering: Virtual Server for VPC
    Subject:  RIAS API for VPC Gen2 requests failing with 5xx status
    Description:

    The IBM Kubernetes Service IaaS automation is failing to manage infrastructure on behalf
    of customers due to a high number of 5xx responses from the RIAS API for VPC Gen2.

    This problem is impacting multiple customers in the following regions:

    - <region>
    - <url>
    - <req-id>
    - <statusCode>
    ```
    Choose the severity Sev1 vs Sev2 to match the severity of our pCIE raised in step 2. If unsure, start as Sev 2 and it can be raised later.

7. Raise a new issue in [replatforming-pm](https://github.ibm.com/ibmcloud/replatforming-pm/issues)
    - Include all of the details added to the support ticket raised in step 4
    - Tag the issue with `Service:IKS`

8. Follow up in the [#ipops-cases](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD) Slack channel:

    ```
    IKS SRE are observing a high number of 5xx failures from RIAS API in region <region>
    which are impacting IKS automation of customer infrastructure. We have raised a
    support ticket <ticket number>. Can someone help investigate urgently, please?
    ```
9. If the VPC SRE team confirm that they have a CIE, or if the alert metrics show that the problem is not reducing over a period of 60 mins, confirm the IKS/ROKS CIE.

10. If the VPC SRE team confirms there is no issue with RIAAS platform and suspecting a network issue, please open a severity 1 ticket to SL Network team and follow up with [#network_response_team](https://ibm-cloudplatform.slack.com/archives/G01CZ858J65) slack channel.

11. The alerts and CIE will resolve once the VPC team have resolved the issue

## Escalation Policy

If the VPC SRE team do not confirm that they have a CIE and the problem continues to impact our customers, page the troutbridge team to investigate [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98).

**Slack Channel**: You can contact the dev squad in the [#armada-cluster](https://ibm-argonauts.slack.com/archives/C54FV49RU) channel.

**GHE Issues Queue**: You can create a new issue [here](https://github.ibm.com/alchemy-containers/troutbridge/issues/new).
