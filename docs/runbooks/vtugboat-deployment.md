---
layout: default
title: VPC replatforming - vtugboat deployment 
type: Informational
runbook-name: "How to deploy vtugboat in VPC replatform account"
description: "Instruction how to deploy vtugboat"
service: Conductors
link: /doc_updates/vtugboat-deployment.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

VPC Replatforming deploys IKS tugboat on VPC gen2 leveraging VPC infrastructure. It is a ROKS cluster that control plane is located in a regional barge cluster using RHCOS (RedHat coreOS). vTugboat deployment pipeline is using armada api (IKS API) to provision a cluster along with dependencies. 

## Detailed information

There are multiple types of vTugboat per a tugboat purpose. A VPC is provisioned for a purpose to separate deployment of vtugboat

|Purposes  |cluster_type  | 
|----------|--------------|
|MicroserviceAndEtcd | hub |
|CustomerWorkloadCruiser | spoke |
|CustomerWorkloadOpenShift | spoke |
|CustomerWorkloadSatellite | spoke |
|SatelliteConfig | satellite-config |
|LinkApiSatellite | link |
|LinkTunnelSatellite | link |

In a high level overview, there are 4 processes to be completed to deploy a vTugboat into a VPC. 

1. Create a VPC (if not present) and subnets for vTugboat 
2. Create a vTugboat deployment artifact using an automation 
3. Run a jenkins pipeline to deploy a vTugboat
4. Review and apply PRs 


## Execution Process

### VPC/Subnet deployment 

A VPC, if not present, needs to be provisioned for a vTugboat purpose and a cluster needs subnets & address-prefixes to be acquired before executing a terragrunt template. 

For further detailed instruction, the following references can be used. 

- [VPC Deployment Pipeline Automation](https://github.ibm.com/alchemy-containers/vpc-deploy-module)
- [vpc-deploy-pipeline Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/stable-region-rollout/job/vpc-deploy-pipeline/)
- [VPC region rollout runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/vpc_region_rollout.html)

### Create a vTugboat terragrant template

vTugboat deployment is leveraging GoldenEye OCP module with the terragrunt as IaC. It is a configuration driven that JSON files need to be updated to populate a scaffolding terragrunt template. This is the same approach with the `Account setup automation` IKS SRE is using to set up new IBM Cloud account. By updating JSON configuration files for a vtugboat in https://github.ibm.com/alchemy-conductors/vtugboat-inventory, an associated terragrunt template is populated in https://github.ibm.com/alchemy-containers/vtugboat-deploy/. 

#### Update JSON configuration

There are 2 JSONs files that one `account_config.json` is for a terraform/terragrunt bootstrap to set up remote state management with IBM Cloud Object storage. 
`vtugboat_hub.json` as an example, is for microservice vTugboat that mainly VPC and VPC subnets information needs to be updated. In order to improve ease of updating configuration, only resource names need to be added then resource IDs are injected into terragrant files. 

You can find JSON files in https://github.ibm.com/alchemy-conductors/vtugboat-inventory/tree/main/accounts/ROKS.Dev.ControlPlane as a reference. 

eg) vtugboat_hub.json
```
{
    "account_target": "test.cloud.ibm.com",
    "vtugboats":
    [
        {
            "name": "dev-dal10-carrier1000",
            "region": "us-south",
            "resource_group_name": "dev-us-south-hub01-resource-group",
            "disable_public_endpoint": true,
            "vpc_name": "dev-us-south-hub01-vpc",
            "vpc_subnets":[
                {
                    "vtugboat_subnet_name": "edge",
                    "subnets":[
                        {
                            "subnet_name": "dev-us-south-hub01-dev-dal10-carrier1000-edge-subnet-1"
                        },
                        {
                            "subnet_name": "dev-us-south-hub01-dev-dal10-carrier1000-edge-subnet-2"
                        },
```
terragrunt.hcl after popluated by automation, which is stored in https://github.ibm.com/alchemy-containers/vtugboat-deploy. 
```
inputs = {
    ibmcloud_api_key     = "${local.environment_vars.locals.ibm_testcloud_login_api_key}"
    cluster_name         = "${local.cluster_name}"
    resource_group_id    = "739c19b3b48e4c15b4ec8599c6bf70bf" 
    region               = "${local.region}"
    force_delete_storage = true
    disable_public_endpoint =  true
    cluster_config_endpoint_type = "private"
    vpc_id               = "r134-8822f81a-8dd5-486d-80db-d7fcce975139"
    vpc_subnets          = { 
        edge    = [ 
            {
                cidr_block = "192.168.40.0/25"
                id         = "0716-f6565317-ba18-4fba-9657-4d1e9cbef786"
                zone       = "us-south-1"
            },
        
            {
                cidr_block = "192.168.42.0/25"
                id         = "0726-ad365634-7ed2-40b1-8ef5-a06bc3e3302c"
                zone       = "us-south-2"
            },
```

JSON file can be updated based on JSON schema file - https://github.ibm.com/alchemy-conductors/boundary-account-tg-builder/blob/main/schemas/vtugboatconfigschema.json. 

#### Release management

When configuration files are ready, the build pipeline can create a new PR using a release tag - https://github.ibm.com/alchemy-conductors/vtugboat-inventory/tags (vX.X.X)

Once a build completed successfully, you should be able to see a new PR in https://github.ibm.com/alchemy-containers/vtugboat-deploy. After reviewing and merging the PR, your change is ready to be deployed. 


### Deploy via a jenkins pipeline

After a terragrunt template is populated in https://github.ibm.com/alchemy-containers/vtugboat-deploy, a provisioning can be executed via https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/vtugboat-pipeline/job/vtugboat-deploy/


If a new account needs to be onboarded, you can reach out to IKS SRE to set a new account for the automation. 

### Follow up armada-secure & other PRs

[TBD]


## Escalation Policy

There is no formal escalation policy.

This is an SRE owned tool so should be raised and discussed in either

- `#conductors-for-life` if you are not a member of the SRE Squad. (mention `@conductors-aus`)
- Raise GHE issues in https://github.ibm.com/alchemy-conductors/team/issues
