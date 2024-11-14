---
layout: default
title: "Dreadnought PAG runbook"
runbook-name: "Accessing and Onboarding to PAG in dreadnought"
description: "Accessing and Onboarding to PAG in dreadnought"
category: Dreadnought
service: dreadnought
tags: dreadnought, dreadnought pag, pag, dreadnought pag access
link: /dreadnought/dn-pag-usage.html
type: Informational
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

# Privileged Access Gateway

## Overview
Privileged Access Gateway (PAG) is the managed service that replaces the custom Bastion solution.

## Detailed Information
### Access to GPVPN and Yubikey
- Register for a SoftLayer account ID by submitting an [IBM AccessHub request](https://ibm-support.saviyntcloud.com/ECMv6/request/applicationRequest?search=SWFhUyBBY2Nlc3MgTWFuYWdlbWVudA==) for new access to the IaaS Access Management application
- After your AccessHub request is approved, you receive an email that contains your account credentials
- Follow the instructions for [requesting a YubiKey](https://w3.ibm.com/w3publisher/ibm-cloud-yubikeys)

### Required Software
- A gpvpn client and an active softlayer credentials
- `ibmcloud` command line interface installed with `pag` plugin. It can be done using `ibmcloud plugin install pag`

### Connecting to clusters
1. Login to GPVPN
2. From terminal:
```
ibmcloud login --sso
ibmcloud pag gateway set <pag-endpoint>
ibmcloud pag oc config <cluster-name> --ticket-id <change-request-id> --passcode <passcode>
```
3. Run kubectl/oc commands

Note:
1. Set the `pag-endpoint` to the endpoint present in the pag instance of the account
2. The `passcode` mentioned above can be generate using the link [here](https://iam.cloud.ibm.com/identity/passcode)
3. The `change-request-id` can be generated using the @ciebot in slack `#dn-sre` channel

The pag endpoints for accounts in stage and prod are as below

**Production**

Account Name | PAG Endpoint |
--- | --- |
dn-prod-s-bluefringe | dn-prod-s-bluefringe.us-east.pag.appdomain.cloud |
dn-prod-s-cpapi-extended | dn-prod-s-cpapi-extended.us-east.pag.appdomain.cloud |
dn-prod-s-cpapi-extended-osa | dn-prod-s-cpapi-extended-osa.us-east.pag.appdomain.cloud |
dn-prod-s-cpapi-extended-tok | dn-prod-s-cpapi-extended-tok.us-east.pag.appdomain.cloud |
dn-prod-s-cpapi-extended-tor | dn-prod-s-cpapi-extended-tor.us-east.pag.appdomain.cloud |
dn-prod-s-dreadnought | dn-prod-s-dreadnought.us-east.pag.appdomain.cloud |

**Stage**

Account Name | PAG Endpoint |
--- | --- |
dn-stage-d-cd | dn-stage-d-cd.us-east.pag.appdomain.cloud |
dn-stage-d-global-catalog | dn-stage-d-global-catalog.us-east.pag.appdomain.cloud |
dn-stage-d-kms | dn-stage-d-kms.us-east.pag.appdomain.cloud |
dn-stage-d-scc | dn-stage-d-scc.us-east.pag.appdomain.cloud |
dn-stage-d-secrets-manager | dn-stage-d-secrets-manager.us-east.pag.appdomain.cloud |
dn-stage-s-bluefringe | dn-stage-s-bluefringe.us-east.pag.appdomain.cloud |
dn-stage-s-cpapi-core | dn-stage-s-cpapi-core.us-east.pag.appdomain.cloud |
dn-stage-s-cpapi-extended | dn-stage-s-cpapi-extended.us-east.pag.appdomain.cloud |
dn-stage-s-cpui | dn-stage-s-cpui.us-east.pag.appdomain.cloud |
dn-stage-s-dreadnought | dn-stage-s-dreadnought.us-east.pag.appdomain.cloud |

### Steps for PAG onboarding to an account

The complete instructions to onboard PAG service to an account are present in the link [here](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-requirements)

Here we are mentioning the details which are specific to dreadnought. The following steps should be followed after step 7 in the link provided above
1. Create a resource group in target account where pag is to be deployed with name `dn-pag-rg`
    - Log into the account
    - `Manage -> Account -> Resource groups`
    - Push the `Create +` button
    - Enter the name `dn-pag-rg` and push `Create`
2. Add access policies to the sDNLB Service ID in the same target account
    - Log into the account
    - Manage -> IAM -> Service IDs
    - search for sdnlb
    - Click on the sdnlb Service ID
    - Set the following Access Polcies
        - Update `VPC Infrastructure Services` as `Editor, Reader, Writer, Viewer`
        - Add `Resource group only` for the `dn-pag-rg` resource group as Viewer
        - Add `All Identity and Access enabled services` as `Viewer`
3. Login to the provisioning account and search in projects for the cabin sos name (eg: `cpapi-extended` or `cpapi-core`)
    - Login to the account
    - Click on the `hamburger menu` icon in top left corner
    - Select `projects` in the menu displayed
4. Create a `Key Protect for PAG` Key Protect instance in the same region being onboarded.
    - In the selected project, navigate to the `configurations` tab and click on `create +`
    - Select `DN Crew Catalog` in the top left drop box. search for `key management services` in the search bar next to the dropbox
    - Select the public available `Key Management Services` DA and click on `add to project`
    - Now select the appropriate environment in `Environment` dropbox and leave it empty if the required environment is not present
    - In the Authentication Section, select the appropriate api key of the target account where PAG needs to be deployed from the secrets manager
    - In the `Required` tab, Enter the `resource_group_name` to be `dn-pag-rg` and `region` to be `us-east`
    - In the `Optional` tab, change the
        - `use_existing_resource_group` to `true`
        - `prefix` to `dn`
        - `key_protect_instance_name` to `kms-pag-<env>-<sos_name>`
    - Now save the confiuration and validate it and verify the resources added and finally deploy it
5. Deploying the PAG instance
    - Navigate to the `projects -> <sos-name> -> configurations` section and click on `create +`
    - Now Select `DN Crew Catalog` in the top left drop box. search for `pag` in the search bar next to the dropbox
    - Select the `Privileged Access Gateway (internal)` and verify `sec044` mentioned in the variation and click on `Add to project`
    - Now select the appropriate environment in `Environment` dropbox and leave it empty if the required environment is not present
    - Move to the `Requried` tab and change
        - `region` to be `us-east`
        - `resource_prefix` to be `dn`
        - `secret_manager_crn` is the CRN of the secrets manager in the target account
            - Example: `crn:v1:bluemix:public:secrets-manager:us-south:a/2c2d3ba343274517a203f9e3a582b483:ab27f6a3-38bd-4970-8c31-356770873b52::` for the secret manager `cpapi-stage-eu-gb-secrets-manager` in account `dn-s-stage-cpapi-extended` account.
        - `secret_group_id` to the ID of the **sdnlb** group in the secrets manager.
        - `sdnlb_api_key_secret_id` to the ID of the secret itself in the same group above.
        - `production_flag_enabled` to be true
        - `sdnlb_endpoint_prefix` name to match the account name
            - Example: `dn-stage-s-cpapi-extended` so the hostname will be `dn-stage-s-cpapi-extended.us-south.pag.appdomain.cloud`
    - Move to the `Optional` tab and change
        - `create_resource_group` to `false`
        - `existing_resource_group_name` to `dn-pag-rg`
        - `skip_pag_cos_iam_auth_policy` to `false`
        - `pag_tags` leave as an empty array `[]`
        - `kms_endpoint_type` to `private`
        - `skip_cos_kms_auth_policy` to `false`
        - `pag_bucket_existing_kms_key_crn` to `NULL`
        - `vpc_flow_logs_existing_bucket_kms_key_crn` to `NULL`
        - `cos_instance_tags`, `pag_bucket_access_tags`, and `vpc_flow_logs_bucket_access_tags` to an empty array []
        - `management_endpoint_type_for_bucket`  to `private`
        - `object_locking_enabled` to `true`
        - `existing_pag_bucket_name` and `existing_pag_bucket_region` leave `NULL`
        - `existing_pag_bucket_type` to `region_location`
        - `existing_vpc_flow_logs_bucket_name` leave `NULL`
        - `target_crns` and `vpc_tags`  leave as an empty array []
        - `skip_vpc_cos_auth_policy` to `false`
        - `add_bucket_name_suffix` to `true`
        - `existing_cos_instance_crn` leave `NULL`
        - `skip_pag_sm_iam_auth_policy` set to `false`
    - Now click on `save` and `validate` the changes, when the validation is done `approve` the changes and `deploy` them
6. Once pag is deployed in the target account submit a `NetEngReq` ticket
    - While connected to GPVPN, create a [NetEngReq ticket](https://confluence.softlayer.local/display/NETGOVPUB/Requesting+Access+Permissions+for+GPVPN) - login using your Softlayer credentials
    - Update Destination Hostname(s): with the gateway address as decided when configuring the DA
    - Request from the development manager and security focal to add their written approval as a comment in the submitted ticket
