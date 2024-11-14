---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Virtual Private Cloud (VPC) - How to rotate the API key for VPC related service accounts
service: armada-vpc
title: VPC - ow to rotate the API key for VPC related service accounts
runbook-name: "VPC - ow to rotate the API key for VPC related service accounts."
link: /armada/armada-vpc-rotate-service-id-api-key.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

This runbook describe the process for SRE to follow to successfully rotate the API key for a service ID within our VPC Classic or VPC Gen2 service accounts.


## Detailed Information

There are several distinct phases that need to be successfully completed before an API Key can be deleted from the service account. 

## Detailed Procedure

### Log in to the desired account

- Log in to <https://cloud.ibm.com> (or <https://test.cloud.ibm.com> for stage)
- Switch to the desired account
  - Pre-prod
    - VPC Gen2
      - IKS.Dev.VPC.Service (e2523561f3864f058711d94392c19e9b)
      - IKS.Stage.VPC.Service (082541494a42444e8fe08083f3bbb869)
    - VPC Classic
      - IKS Dev VPC Classic Service (feef7d57b47e4410a7f390488f388dbe)
      - IKS Stage VPC Classic Service TEST (7103ff0b5d4a4c68ac1c27894993d5b9)
    - Prod
      - VPC Gen2
        - IKS.Prod.VPC.Service (bab556e1c47446ef8da61e399343a3e7)
      - VPC Classic
        - IKS Prod VPC Classic Service cloudID (9751a0d772e5457eb52eb4c747f1c1b7)

### Add an additional API Key to the Service ID

- Navigate to `Manage` -> `Access (IAM)` -> `Service IDs`
- Select the Service ID for the region where the API Key needs to change
- Select `API keys` tab
- Create a new key
  - The name should follow the format `<env>-<region>-vpc-<classic/gen2>-apikey-<YYYY-MM-DD>`. For example: `dev-us-south-vpc-gen2-apikey-2020-01-24` or `prod-us-south-vpc-gen2-apikey-2020-01-22`
  - Make a note of the new API Key from a priviliged machine

### Manually test the new API Key

Before the key can be added to the production configuration, the key will need to be tested to ensure it can query resources inside the service account.

- Download an access token for the API Key by running the following command
  - Pre-Prod - `curl -X POST 'https://iam.test.cloud.ibm.com/identity/token?grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=<api_key>'` (replacing the `<api_key>` with the actual API Key)
  - Prod - `curl -X POST 'https://iam.cloud.ibm.com/identity/token?grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=<api_key>'` (replacing the `<api_key>` with the actual API Key)
  - From the output, copy the value for the `access_token`
- Run the following command to list the VPCs in the account - replacing `<access_token>` with the value copied from the previous step
  - Pre-prod
    - VPC Gen2
      - Dev, Prestage & Stage: `curl -X GET 'https://us-south-stage01.iaasdev.cloud.ibm.com/v1/instances?version=2020-01-01&generation=2' -H 'Authorization: Bearer <access_token>'`
    - VPC Classic
      - Dev, Prestage, Stage: `curl -X GET 'https://private-us-east-stage02.iaasdev.cloud.ibm.com/v1/instances?version=2020-01-01&generation=1' -H 'Authorization: Bearer <access_token>'`
  - Prod
    - VPC Gen2
      - US-South: `curl -X GET 'https://us-south.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=2' -H 'Authorization: Bearer <access_token>'`
      - US-East: `curl -X GET 'https://us-east.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=2' -H 'Authorization: Bearer <access_token>'`
      - EU-Central: `curl -X GET 'https://eu-de.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=2' -H 'Authorization: Bearer <access_token>'`
      - EU-GB: `curl -X GET 'https://eu-gb.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=2' -H 'Authorization: Bearer <access_token>'`
      - JP-Tok: `curl -X GET 'https://jp-tok.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=2' -H 'Authorization: Bearer <access_token>'`
      - AU-Syd: `curl -X GET 'https://au-syd.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=2' -H 'Authorization: Bearer <access_token>'`
    - VPC Classic
      - US-South: `curl -X GET 'https://us-south.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=1' -H 'Authorization: Bearer <access_token>'`
      - US-East: `curl -X GET 'https://us-east.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=1' -H 'Authorization: Bearer <access_token>'` Note: This URL is not yet active.
      - EU-Central: `curl -X GET 'https://eu-de.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=1' -H 'Authorization: Bearer <access_token>'`
      - EU-GB: `curl -X GET 'https://eu-gb.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=1' -H 'Authorization: Bearer <access_token>'`
      - JP-Tok: `curl -X GET 'https://jp-tok.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=1' -H 'Authorization: Bearer <access_token>'`
      - AU-Syd: `curl -X GET 'https://au-syd.iaas.cloud.ibm.com/v1/instances?version=2020-01-01&generation=1' -H 'Authorization: Bearer <access_token>'`
- A successful test should output a list of 1 or more server instances in the account

### Add new key into armada-secure configuration

Once the previous test has passed, the API Key needs to be added into the armada-secure configuration.

**DO NOT REPLACE THE EXISTING KEY** Add a new one

- Follow the instructions to [encrypt the key](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/README.md#defining-a-new-secure-environment-variable)
  - Name the key using the following format - `<provider>_WORKER_SERVICE_ACCOUNT_API_KEY_<accountID>_<env>_YYYY-MM-DD`
    - For example: `G2_WORKER_SERVICE_ACCOUNT_API_KEY_082541494a42444e8fe08083f3bbb869_STAGE_2020-01-23`
  - The encrypted key should be saved to the `build-env-vars/vpc-riaas/` folder
- Update the `vpc-riaas.yaml` in the `secure/armada/<region>` folder for the environment where the key is being updated
  - For VPC Classic, the `GC_WORKER_SERVICE_ACCOUNT_ID` variable value needs to point to the new key
  - For VPC Gen2, the `G2_WORKER_SERVICE_ACCOUNT_ID` variable value needs to point to the new key
- Once merged, this change can be rolled through to production using [razeeflags](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-secure)
- Provision a VPC Classic or VPC Gen 2 cluster depending on the key change in the desired region
- Monitor the provisioning cluster for problems - in particular any issues provisioning workers
  - If there are issues provisioning, work with the armada-cluster squad to determine if the key change was the problem

### Remove old key from armada-secure configuration

- Once the key has been tested in the production configuration, remove the old key from armada-secure
- Merge the change and promote armada-secure into production
- Repeat the cluster provision test from the previous step
- Once the cluster has provisioned proceed to the next step

### Delete old API Key from Service ID in IAM

- [Log back in to IBM Cloud](#log-in-to-the-desired-account)
- Navigate to `Manage` -> `Access (IAM)` -> `Service IDs`
- Select the Service ID for the region where the API Key needs to change
- Select `API keys` tab
- Delete the replaced key

### Escalation

There is no formal escalation policy for this.
Any issues discovered during execution of this process should be discussed with the person who raised the request to generate the key.
