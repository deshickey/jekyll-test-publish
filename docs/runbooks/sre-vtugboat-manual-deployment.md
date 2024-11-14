---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: This runbook provides the steps required to manually deploy a VTugboat using the Dreadnought runtime-core-module
service: Conductors
title: VTugboat manual deployment
runbook-name: VTugboat manual deployment
link: /sre-vtugboat-manual-deployment.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook provides detailed steps on how to manually deploy a vTugboat using the Dreadnought `runtime-core-module`, via Schematics.

---
## Detailed Information

### Access

This section defines all of the user permissions required to successfully deploy a vTugboat.

**NOTE**: Service ID's can _NOT_ be used! 

  Reference:
  ```text
  ℹ️ You can't use a service ID because of a limitation in IBM Kubernetes Service. 
  Run the automation with either a IBM Cloud user or functional ID.
  ```
- Create a GHE personal access token for the functional ID/user, which is used to clone Terraform module repos with full repo permissions:

    ![image.png](https://zenhub.ibm.com/images/5efb0acc2958342ba70c4174/6176ba49-6023-4864-9d1e-dbdcec7c59cd)
- Ensure the functional ID/user has all the access listed in [goldeneye-iam-permissions](https://github.ibm.com/GoldenEye/documentation/blob/master/goldeneye-iam-permissions.md) documentation.
- The functional ID/user also requires the following additional permissions:
   -  `IAM Identity Service` requires the User `API key creator` and `Service ID creator` permissions.
   -  `All Account Management services`  needs `Administrator` and `Operate`.
   -  `All Identity and Access enabled services` platform access needs to be increased to `Administrator`.

    ![image](https://media.github.ibm.com/user/110172/files/6f075c2f-6ba7-4a91-8fab-d589ee4f28f2)

---

### Steps to deploy

>😎 **_Pro-tip_**: If a job fails due to a config issue (such as forgetting to remove a resource group that was create in a previous run) the terraform code usually does not recover well, even after the config is fixed. It is recommended to delete the workspace, fix the issue and recreate a new work space.

#### Prerequisites

- IBM Cloud Account
- Schematics CLI plugin
- Secrets Manager Instance
- Resource Group - Each vTugboat requires a resource group to be deployed into

#### Steps

1. Login IBM Cloud Account with functional ID/user
2. Create a new API key:
   - CLI: `ibmcloud iam api-key-create vtugboat-deployment-apikey`
3. Create a [schematics-template.json](https://github.ibm.com/alchemy-containers/tugboat-gen2-deploy-module/blob/dreadnought-modules/schematics-template.json) in the following form, where `variablestore` should contain a list of all the variables and their values, if you wish to override the default module values:

   ```json
   {
     "name": "<dev-us-east-carrier000>",
     "type": [
       "<terraform-version>"
     ],
     "description": "<Description of the workplace>",
     "resource_group": "<schematics-workspace-resource-group>",
     "location": "<region>",
     "template_repo": {
       "url": "<github-repo>"
     },
     "template_data": [
       {
         "folder": "<specific-folder-path-in-repo>",
         "type": "<terraform-version>",
         "variablestore": [
           {
            "name": "ibmcloud_api_key",
            "secure": true,
            "type": "string",
            "value": "<IAM-API-KEY>"
           },
           {
             "name": "<variable-from-variables.tf>",
             "secure": <true/false>,
             "type": "<string/object/map>",
             "value": "<value>"
           }
         ],
         "env_values": [
           {
             "__netrc__": "[['github.ibm.com','<GHE-USER>','<GHE-TOKEN>']]"
           },
           {
             "API_DATA_IS_SENSITIVE": "true"
           }
         ],
         "has_githubtoken": true
       }
     ]
   }
   ```
**NOTE**: `You will need to add the <IAM-API-KEY>, <GHE-USER> and <GHE-TOKEN> for the functional ID/user being used`

4. Login to IBM Cloud with API key: `ibmcloud login --apikey <tugboat-gen2-deploy-apikey> -r <region> -a https://cloud.ibm.com`
5. Create a new schematics workspace (note the workspace will be created in either North America, Europe or BNPP, depending on which region you CLI is configured): `ibmcloud sch ws new -f schematics-template.json`
6. Verify workspace was created: `ibmcloud sch ws list`
7. Using the workspace ID from the previous command run a plan `ibmcloud sch plan --id <workspace-id>`
8. Apply the plan from the UI or CLI:
    - CLI: `ibmcloud sch apply --id <workspace-id>`
    - UI: click `Apply Plan` button
![image.png](https://zenhub.ibm.com/images/5efb0acc2958342ba70c4174/65634f2f-68b0-461b-ba73-67f46ada7264)
10. Success 😎 ⛵️