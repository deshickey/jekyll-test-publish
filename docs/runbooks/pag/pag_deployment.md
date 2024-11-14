---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Privileged Access Gateway(PAG) deployment for IKS/SAT accounts
type: Informational
runbook-name: "Privileged Access Gateway(PAG) deployment for IKS/SAT accounts"
description: "Privileged Access Gateway(PAG) deployment for IKS/SAT accounts"
service: Conductors
link: /docs/runbooks/pag/pag_deployment.html
grand_parent: Armada Runbooks
parent: PAG
---

Informational
{: .label }

# Privileged Access Gateway(PAG) deployment for IKS/SAT accounts

## Overview
This document describe the procedure to deploy PAG for IKS/SAT accounts

## Detailed Information
a PAG instance depends on the following resources
- Resource group
- ServiceID and APIKey for SDNLB actions
- Secret Manager(SM) instance to store the APIKey
- KMS(KP) instance
- ATracker instance (optional)
- Monitoring instance (optional)

## Dependencies

**NOTE**: All resources must be created in the same account where the PAG instance is to be deployed.

### 1. Resource Group
Created via automation ([sample PR](https://github.ibm.com/argonauts-access/access-group-config/pull/541))

### 2. ServiceID for SDNLB
Created via automation ([sample PR](https://github.ibm.com/argonauts-access/access-group-config/pull/541))

### 3. APIKey
The APIKey is used for SDNLB actions (creation, deletion, switching between pool members when one proxy is down and during updates).

```
# ic iam service-api-key-create sdnlb-apikey ${ENV}-pag-sdnlb-service-id
```
**Variables** \
`ENV`: one of `dev`, `stage` or `prod`
### 4. Importing API key to SM
The SM instance is used to store the APIKey as an `ArbitrarySecret`.

1. **Create a secret group**
```
ic sm secret-group-create --region ${REGION} --name pag --instance-id ${SM_INSTANCE_ID}
```
2. **Create the secret**
```
ic sm secret-create --region ${REGION} --instance-id ${SM_INSTANCE_ID} --arbitrary-payload "${API_KEY}" --secret-name pag-sdnlb-apikey --secret-group-id ${SECRET_GROUP_ID} --secret-type arbitrary
```
**Variables** \
`SM_INSTANCE_ID`: Target SM instance ID \
`API_KEY`: The value of the API created in step 3 \
`SECRET_GROUP_ID`: Secret group ID for the group created above \
`REGION`: The region where the SM instance is deployed \
3. **Key rotation**
Use secret-rotator to rotate the initial API key created above. (Sample secret-rotator [issue](https://github.ibm.com/alchemy-containers/secret-rotate-metadata/issues/10636))

### 5. SDNLB Onboarding
For SDNLB onboarding, you need to provide a ServiceID plus additional information (Service name, accountID,...) to the SDNLB team by creating a Jira ticket (Sample [issue](https://jiracloud.swg.usma.ibm.com:8443/browse/RNOS-12742)) and reaching out in [#ibmcloud-service-dnlb](https://ibm.enterprise.slack.com/archives/C01C0MC0UPK) (Sample [thread](https://ibm-cloudplatform.slack.com/archives/C01C0MC0UPK/p1726381453769979))

The ServiceID will be considered onboarded when it's merged in the SDNLB whitelisting repo. (Sample [PR](https://github.ibm.com/nextgen-environments/global-prod/pull/2223)) 

### 6. PAG instance deployment (JJ)
The PAG instance is deployed via this [JJ](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/All/job/pag-deployment/)
The variables for each of the instances are situated in `tf/com_ibm_cloud/$INSTANCE_NAME/variables.tfvars` \
**Variables**
Please refer to the PAG module variable [definitions](https://github.ibm.com/alchemy-conductors/pag-automation/blob/main/tf/modules/pag/variables.tf)

1. **Redeployment** \
Modify the `variables.tfvars` file with the proper values and run the [automation](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/All/job/pag-deployment/) by specifyin the target `DEPLOYMENT` (e.g. `dev-us-east`) in the job's parameters.

2. **New deployment** \
For new deployments please reach out to the code [owners](https://github.ibm.com/alchemy-conductors/pag-automation/blob/main/.github/CODEOWNERS).

### 7. SoftLayer GPVPN access request
The access to the PAG endpoint needs to go through GPVPN
Create a ticket with SL to allow the proper AD group access to the endpoint ([Sample issue](https://jira.softlayer.local/browse/NETENGREQ-18526))

### 8. NetInt firewall request (IKS ONLY)
Create a NetInt firewall request to allow access to port `TCP 22` from PAG VPC subnets to classic machines. (Sample [issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/5635))

### 9. Access check
To validate your access to the PAG gateway, please run the following commands after connecting to GPVPN and check if the result is successful.
```
### MacOS
❯ nc -v -G 2 -w 2 ${ENDPOINT} 7200
❯ nc -v -G 2 -w 2 ${ENDPOINT} 7201
❯ nc -v -G 2 -w 2 ${ENDPOINT} 7202

### Linux
❯ nc -v -w 2 ${ENDPOINT} 7200
❯ nc -v -w 2 ${ENDPOINT} 7201
❯ nc -v -w 2 ${ENDPOINT} 7202
```

Sample
```
❯ ENDPOINT="iks-dev.us-east.pag.appdomain.cloud"; nc -v -G 2 -w 2 ${ENDPOINT} 7200
Connection to iks-dev.us-east.pag.appdomain.cloud port 7200 [tcp/fodms] succeeded!
```

In case of confirmed access issue, reach out to SoftLayer in [Jira](https://jira.softlayer.local) and open a `NETENGREQ` ticket asking them to investigate.


## Further Information
- [Privileged Access Gateway official documentation](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-requirements)
- [PAG Sec044 Architecture](https://test.cloud.ibm.com/docs/privileged-access-gateway?topic=privileged-access-gateway-pag-sec044-architecture)




