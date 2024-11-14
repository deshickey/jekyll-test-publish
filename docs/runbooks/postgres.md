---
layout: default
title: How to create Postgres instances
type: Informational
runbook-name: "Postgres new instance"
description: How to create Postgres instances for IKS billing
category: Armada
service: Postgres
tags: alchemy, armada, postgres, ballast
link: /postgres.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

PostgreSQL is a powerful, open source object-relational database that is highly customizable.

Currently, Postgres is used by armada-billing-ledger and storage billing services as backend storage.

## Detailed Information

### Create database instance

Following accounts should be used for IBM Cloud service that we create like IBM Cloud Logs / SysDig / KeyP etc.

- For development and prestage，please use 1186049 Dev Containers account, user alchdev@uk.ibm.com can be used if you have access else just use your own login to create this in PreProd.
- For stage, please use 1858147 - Argo Staging account, user argostag@uk.ibm.com
- For production, please use 1185207 - Alchemy Production's Account, user alchcond@uk.ibm.com

1. Create resource groups (skip for Migration)

    Create resource groups for each region, and use the naming convention as below:

    - ICD-Prod-au-syd
    - ICD-Prod-br-sao
    - ICD-Prod-ca-tor
    - ICD-Prod-eu-de
    - ICD-Prod-eu-es
    - ICD-Prod-eu-gb
    - ICD-Prod-jp-osa
    - ICD-Prod-jp-tok
    - ICD-Prod-us-east
    - ICD-Prod-us-south
    - ICD-Prestage-us-south
    - ICD-stage

1. Create access groups (skip for Migration)

    Create reader and writer access groups:

    - ICD-Prod-reader
    - ICD-Prod-writer

1. Create postgres instances

    Search `Databases for PostgreSQL` from the Catalog.

    - Use the following naming convention:
    - PROD: REGION-armada-ms-postgres-vXX
        - where REGION is:
            - PROD: the prod region (ap-south)
            - PREPROD PreStage: prestage-us-south
            - PREPROD Stage: stage-103-us-south, where 103 is the carrier number
        - where XX is the Postgres database version used.
    - Example:
        - PROD: `ap-south-armada-ms-postgres-v15`
        - PREPROD PreStage: `prestage-us-south-armada-ms-postgres-v15`
        - PREPROD Stage: `stage-103-us-south-armada-ms-postgres-v15`
        - PREPROD Stage performance carrier: `stage-501-us-south-armada-ms-postgres-v15`
    - Select the correct region and resource group
    - Select the resource allocation. For migration use the same as the existing instance, or what's used for the instance in us-south
    - Select latest version (v15 or greater)
    - Select Endpoint
      - PROD: `Private network`
      - PREPROD: `Both public & private network`

1. Enable Logging and Metric dashboards for the new instances

    - Verify Ballast can get to the database logs and metric dashboard for the new instances.

1. Run the Postgres Credentials job to generate new creds and the Seure PR

    - The job is located [here](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-postgres-pr/)

    - Job Parameters
        - BRANCH: master (Don't change this)
        - POSTGRES_REGION: Select the Region where the Postgres instance resides
        - POSTGRES_CRN: Enter the Postgres instance CRN
        - BALLAST_ISSUE: Optional issue or text to reference in the Secure PR description

    - Run the job and review the end of the console log for the Secure PR created

1. Ping Ballast and Troutbridge for Secure PR approvals

1. For migration instances, **WAIT** on Merge and Promote Secure PR to production.

### Migration (skip if new region)

Ballast squad will walk through the migration job.

### After Promotion Steps

The Postgres instance is now created and configured for IKS.

1. The [billing maintenance job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-billing-maintenance/) can be run in DRY RUN mode to verify the new Postgres instance and armada-secure credentials are working. Run the job by selecting the `BILLING_REGION` and leave other fields as default.

1. The next step is for Ballast or Troutbridge to run the [billing maintenance job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-billing-maintenance/) to create the schemas and tables or the migration job to migration an older existing instance.

1. Setup database compliance scans. [Instructions](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/compliance_database_scan.html)
