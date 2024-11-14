---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Steps
service: Conductors
title: New Control Plane on VPC rollout
runbook-name: "Rollout new vpc only region "
link: /vpc_region_rollout.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Runbook pertains details of manual steps & automation to run in order to set-up a new control plane on platform VPC 

## Detailed Information
Control Plane on VPC G2 platform would be consisted of Barges and vTugboats. 
Barge [Concept Doc](https://github.ibm.com/alchemy-containers/armada/pull/3067)
vTugboats [Concept Doc](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/concept-tugboat-gen2.md)

### Pre-requisite
NOTE, 
- (per deploy) each time barge is deployed
- (per region account set up) each time account is setup 
- ( ) a once-off and handled by other automation/manual setup
- (A) automated
- (M) manual

1. ( ) each VPC account has sufficient IAAS resources 
1. (per deploy) It is confirmed which account is going to be used
1. (per region account set up)(M) A VPC in IKS VPC Service account for DEV/Prod. The VPC is to hold all VSIs of control plane clusters. example [GHE request](https://github.ibm.com/alchemy-conductors/team/issues/22966) 
1. (per region account set up)(A) A RG `Default` is created. The value needs to be set in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/29bdfb20c59ec9e9a29ffae5f049ac13938e7357/scripts/getResourceKeyCredentials.py#L82)
1. ( ) elba_apikey_secretID is present in Jenkins and it is referenced in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/Jenkinsfile)
1. (per region account set up)(A) A Key Protect instance in an account where COS for tfstate is created. Resource Group is `Default`. The instance ID and a region need to be set in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/scaffold/dev/us-east/env.hcl)
1. (per region account set up)(A) A COS Instance to archive tf state files from barge deploy pipeline in 278445 `Support` Account. Plan is standard, Resource Group is Default. The COS instance needs to have an `reader` access to KP in `support` account. The instance ID needs to be set in barge-deploy-module at [env.hcl](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/scaffold/dev/us-east/env.hcl) and [terragrunt.hcl](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/post-ipi-install/terragrunt.hcl)

   ```
   Access details:
   Resource Type: `COS`
   Target Instance ID string equals `<KP_instance_name>`

   ```

1. ( )(M) registry APIkey `<env>-<region>-barge-registry-apikey` is created and stored in Jenkins Vault. The cred ID needs to be set in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/Jenkinsfile)
📔 API Key is shared across multiple regions in platform Classic. We are keeping same parity in platform VPC https://github.ibm.com/alchemy-conductors/barge-deploy/issues/357

1. ( )(A) A Secret Manager instance in `support` account. Resource Group is `Default`. The instance ID needs to be set in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/Jenkinsfile)   
📔 Secrets that can be shared across multiple barge deployments are stored. example, an api key to deploy all barges in the region, vpn config files of each barge and vtugboat, redhat ocm token, gitHub token
 
1. (per region account set up)(A) A Secret Manager instance in `new` account. Resource Group is `Default`. The instance ID needs to be set in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/Jenkinsfile)
📔 Secrets that are specific to the region are stored. example, client and server cert, admin kubeconfig

1. ( ) A security group created to a Secret Manager instance in support account - pre-req 7.
    - `barge-vpn-configs` secret group
 
   ```
     The `barge-vpn-configs` secret group currently has access set to allow dev to view the VPN config secrets.

   Access details:

   IAM Group: `IKS View Only` 
   IAM group access policies: `SecretsReader, Viewer` on Secrets Manager Service 
   Resource Type: `secret-group`
   Instance ID string: <secret_manager_instance_name_in_support_account>
   Resource string: `3a930832-62e8-910b-dbaa-1ea6a76540e7`

   ```

1. (per region account set up)(A) A service ID `ServiceID-<env>-barge-user-management` in `new` account for user recon to Barge. APIKEY does not need to be stored. 
1. (per region account set up)(A) A service ID `ServiceID-<env>-global-barge-ipi-install` in `support` account for barge automation to access IKS resources (ie, COS, SM, KP) in `support` account. API key is stored in Jenkins Vault. The cred ID needs to be set in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/Jenkinsfile)
1. (per region account set up)(A) A service ID `ServiceID-<env>-<region>-barge-deployment-automation` for Barge deploy automation pipeline in `new` account. The service ID is to access IKS resources (ie, SM) in `new` accountAPI key is stored in SM in `support`. The secret ID needs to be set in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/Jenkinsfile#L3)
1. ( ) IAM groups by RBAC set up in `new` account where SM is provisioned in pre-req 8. This is required to control SM access
1. (per region account set up) SDNLBs in `new` account require a dedicated service ID. 
    - A Service ID, `ServiceID-<env>-<REGION>-sDNLB-armada-api`, is configured with a SDNLB to microservice endpoint
    - A Service ID, `ServiceID-<env>-<REGION>-sDNLB-masters`, is configured with a SDNLB to master endpoint
    The following Access Polices will need to be added to both of the ServiceIDs above.

    📔 Each service ID access policies are to be same as provisioned service ID in [Setup SDNLB pre-req](https://github.ibm.com/alchemy-conductors/barge-deploy/issues/80#issuecomment-63514081)

   ```
   VPC Infrastructure Services - Administrator
   Catalog Management - Viewer,Editor
   All Account Management services - Viewer
   All Identity and Access enabled services - Viewer
   Resource group only - All resource groups in the account - Viewer
   ```

1. (per region account set up)(A) private catalog entities are created in `new` account 
      - catalog name: `<env>-<region>-hub-sdnlb`,  `<env>-<region>-spoke-sdnlb`,  `<env>-<region>-satellite-sdnlb`
      
      ```
      |_ dev-us-south-hub-sdnlb
           |_ VPE objects of Barge, ETCD vTug
      |_ dev-us-south-spoke-sdnlb
           |_ VPE objects of IKSmasters vTug & ROKSmasters vTug
      |_ dev-us-south-satellite-sdnlb
         |_ VPE objects of satellite vTugs
      ```
1. (per deploy) Refer to the [Barge and VPC deployment](https://github.ibm.com/alchemy-conductors/barge-deploy/wiki/Barge-and-VPC-deployment#information-to-be-gathered-before-starting) and use [subnet.py](https://github.ibm.com/alchemy-containers/vpc-deploy-module/blob/main/scripts/subnet.py) to generate the required CIDR ranges for the subnets of the barge.

1. (per region account set up) A Service ID `ServiceID-<env>-<region>-barge-upgrade-automation` for Barge Upgrade Automation in `new` account. Apikey to be stored in Jenkins Credentials.
   Access details:
   ```
   Secrets Manager: Service access{Reader, SecretsReader}
   VPC Infrastructure Services: Service access{Reader}, Platform access{Viewer}
   ```

### Pre-requisite for PR automation
1. (per region account set up) An ICD for ETCD is allowlisted in `new` account. It is visible in catalog. 
1. (per region account set up)(A) A Key Protect instance in 'new' account. Resource Group is `Default`. The instance name shoud be set as the following naming convention for automation to identify the instance. `Key Protect-<env_lowercase>` for preprod and `Key Protect-<region>` for prod
```
 - Key Protect-prestage
 - Key Protect-eu-de
 - Key Protect-stage
 - Key Protect-dev
```

### Table of content

| Order | Task |
| -- | -- |
| 1.0 | [Planning](#planning) |
| 2.0 | [Vlan/Subnets](#vlansubnets) |
| 3.0 | [Openvpn](#openvpn) |
| 4.0 | [InfraMachineOrder](#inframachineorder) |
| 5.0 | [Bastion](#bastion) |
| 6.0 | [SDNLB](#sdnlb) |
| 6.0 | [ServiceEndpoint/VPE](#serviceendpoint) |
| 7.0 | [ETCDInstanceSetup](#etcdinstancesetup) |
| 8.0 | [CreateArmadaClusterSecrets](#createarmadaclustersecrets) |
| 9.0 | [Useronboarding](#useronboarding) |
| 10.0 | [BargePipelineAutomation](#bargepipelineautomation) |
| 11.0 | [StatusCakeSetup](#statuscakesetup) |
| 12.0 | [observability](#observability) |
| 13.0 | [BargeDeprovisioning](#bargedeprovisioning) |
| 14.0 | [Bootstrap](#bootstrap) |

### Detailed Procedure

### Planning
The projected capacity of the VPC region rollout needs to consider VPC [Quotas and service limits](https://cloud.ibm.com/docs/vpc?topic=vpc-quotas) per region/account. The baseline resource capacity projection is an estimate from an existing classic prod region.  
- (per region account set up) The VPC resource capacity planning of quotas such as CPU, memory from largest Classic regions(us-south and eu-de) can be referenced. The maximum VPC resource capacity can be planned and requrested during an account set-up. 
- (per deploy) The capacity planning of control plane size can start with smaller to medium sized control plane WP size and scale up/down Barge WPs with [automation](https://github.ibm.com/alchemy-containers/barge-deploy-module/tree/main/worker-pool).  

### VlanSubnets
(per deploy)(A) This is provisioned by VPC deployment automation. Each time a barge is deployed, new set of VLANs and subnets are to be defined. 

### OpenVPN
Barge access is via a client-to-site VPN server in the VPC environment with a self-signed cert. The access is controlled by a pre-existing secret group to help limit access to certain secret types. The access is RBAC. 

(per deploy)(A) The certs created in `new` account. The VPN config files with client cert are uploaded to a Secret Manager in `support` account- pre-req 7. The secret group is automatically mapped to the certs during uploading. 
- The `barge-vpn-configs` secret group is used to allow product teams to access the VPCs VPN config file, which is currently required to access each barge.
- config file is uploaded to a SM with naming convention of `<env>-<region>-barge<num>-vpn-config` 
ie. dev-us-east-barge1-vpn-config

### InfraMachineOrder
(per deploy)(A) This is provisioned by barge deployment automation. Masters and workers in workers pools are provisioned with RHCOS.

### Bastion
PAG is planned to rollout in Q3/2024.

### sDNLB
#### 1. SDNLB pre-req
1. Service ID for Each SDNLB in new account is created in pre-req. 
1. After Service IDs are created, get service account/IDs authorized by sDNLB team so that sDNLB operations are allowed. Request can be raised in #ibmcloud-service-dnlb. SDNLB request PR needs to be merged before proceeding in https://github.ibm.com/nextgen-environments/global-prod 
1.  secret for SDNLB is created by [Barge deploy automation](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/module/sdnlb-kube-secret-module/main.tf#L17-L34) 

#### 2. SDNLB for microservice
   - Deploying SNNLB for microservice is collaboration between SRE and Network team.
   - (per region account set up)(A) a private catalog & VPE object is created by Barge deploy automation 
      - catalog name: pre-prod sdnlb, prod sdnlb
      - VPE objects in catalog: <ENV>_V<barge number>_SDNLB_VPE_<region>
   - (per region account set up)(A) Istio/Ingress team deploys SDNLB 
   - (per region account set up)(M) SRE creates VPE GW

#### 3. SDNLB for masters
   - Deploying SDNLB for masters needs to be set up by SRE
   - (per deploy) (A) VPE object in a shared private catalog is created post Barge deploy 
   - (per deploy) (A) SDNLB service is deployed in namespace `kube-config`
  

#### 4. Reference
   - SDNLB DOC - https://test.cloud.ibm.com/docs/service-dnlb?topic=service-dnlb-dnlb-getting-started#dnlb-before-you-begin
   - barge example onboard request: https://ibm-cloudplatform.slack.com/archives/C01C0MC0UPK/p1695928516198299
   - SDNLB Concept Doc:https://github.ibm.com/alchemy-containers/armada/blob/df4a758375628efe30987c86ccfa51ac30d5da24/architecture/guild/concept-docs/concept-network-sdnlb-ipi-cluster.md

### Serviceendpoint
VPE for IBM cloud services are stored in [barge-deploy-module](https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/29bdfb20c59ec9e9a29ffae5f049ac13938e7357/scaffold/dev/us-east/env.hcl#L45)
VPE for armada-api and masters are created as part of SDNLB set-up.
- VPE for masters is `v<num>-<region>.private.containers.cloud.ibm.com`
- VPE for microservice is `<region>.private.containers.cloud.ibm.com`

 ```
 ### dev-south barge1   '*.private.containers.dev.cloud.ibm.com'
 VPE for master : v1-us-south.private.containers.dev.cloud.ibm.com
 VPE for microservice : us-south.private.containers.dev.cloud.ibm.com

 ### prestage-south barge1 '*.private.containers.pretest.cloud.ibm.com'
 VPE for master : v1-us-south.private.containers.pretest.cloud.ibm.com
 VPE for microservice : us-south.private.containers.pretest.cloud.ibm.com

 ### stage-south barge 1 '*.private.containers.test.cloud.ibm.com'
 VPE for master : v1-us-south.private.containers.test.cloud.ibm.com
 VPE for microservice : us-south.private.containers.test.cloud.ibm.com

 ### prod-south barge 1 '*.private.us-south.containers.cloud.ibm.com'
 VPE for master : v1.private.us-south.containers.cloud.ibm.com
 VPE for microservice : private.us-south.containers.cloud.ibm.com

```

### ETCDInstanceSetup
(per region account set up) Details in armada-etcd set up [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/etcd-setup-new-region.html)

#### 1. CreateICDInstance
   - (per region account set up)(A) PR automation for ETCD and KP are integrated into barge deployment pipeline. 
   - Corresponding PRs to be manually approved and promoted to env where Barge is deployed.

#### 2. COSCredentialsSetup
   - This remains manual step. details in armada-etcd set up [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/etcd-setup-new-region.html)

#### 3. CreateCOSConfigfile
   - This remains manual step. details in armada-etcd set up [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/etcd-setup-new-region.html)

#### 4. ETCDMigraion
   - This remains manual step. details in armada-etcd set up [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/etcd-setup-new-region.html)

### CreateArmadaClusterSecrets

- (per region account set up)(A) Config-Pusher PR automation. This is a standard practice when setting up a new environment inorder to capture the infrastructure utilisation metrics. The automation is work is planned.</br>
SRE is expected to raise a PR with the skeleton strucuture, sample PR https://github.ibm.com/alchemy-containers/armada-config-pusher/pull/1910

### Useronboarding
(A) The users are assigned to a openshift role based on IAM groups. IAM groups are pre-defined in role-config. The changes are needed to be made to configure in [barge-user-sync](https://github.ibm.com/alchemy-conductors/barge-user-sync/tree/main/deployment/overlays)

Use following guide to define values in configmap.yaml

`user-sync.yaml`
- `account_id`: Account id where barge is deployed
- `users`: Map of users configuration for kind of users (i.e. sre, viewer)
   - user-type:
      - `group`: An OpenShift group to be defined in barge cluster
      - `access_group`: Corresponding access group/s on the cloud account

`group-sync.yaml`
- `groups`: OpenShift group mapping with appropriate access  
   _This list needs to match with groups defined in user-sync.yaml_
   - `name`: An OpenShift group name defined in user-sync.yaml
   - `clusterRoles`: List of clusterroles to bind to the OpenShift group

### BargePipelineAutomation

1. Phase : VPC Creation
 The input values are controlled by config file version control. 

```
### VPC Creation
VPC Name: <hub-vpc, spoke-vpc, satellite-vpc> # RG with a same name is created
ENV: 
# change management (ops train)
TODO details to follow
```

1. Phase: Barge Deploy
The stable deploy pipeline is located in [containers prod Jenkins](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/stable-barge-pipeline/)
The input parameters

```
region: <us-south, us-east..>
env_level: <dev, prestage, stage, prod>
barge_number: <single digit, example, 1 >
openshift_bom: <major version, example, 4.15>

# PR automation 
CU : true # per barge deploy
KP : true # per first barge of the region deploy
ETCD : true # per first barge of the region deploy
Runbook: true # per barge deploy

# change management (ops train)
train_title: <description of barge deploy> # this creates the train
train_details: <Github issue with new environment BOM>
exception_justification: <""> # left blank unless it's an emergency rollout
test_url: TODO ( may not need)

####################################
Example: barge1 in dev-south
####################################
region: < us-south >
env_level: < dev >
barge_number: < 1 >
openshift_bom: < 4.15 >

# PR automation 
CU : true 
KP : true 
ETCD : true 
Runbook: true 

# change management (ops train)
train_title: A control plane set up in dev-south with barge1
train_details: ""
exception_justification: ""
test_url: ""
```

### StatusCakeSetup
Replaced by IBM Cloud Synthetics [GHE Issue](https://github.ibm.com/alchemy-conductors/development/issues/1188) to track rollout 

### Observability
[sysdig set up GHE issue](https://github.ibm.com/alchemy-conductors/barge-deploy/issues/265)
[armada - dashboard setup GHE issue](https://github.ibm.com/alchemy-conductors/barge-deploy/issues/296)

### BargeDeprovisioning
Dangerous! Proceed with caution. This will delete everything about Barge. Use the jenkins job https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Barge/job/barge-pipeline-cleanup/

### Bootstrap

machineconfig is used

