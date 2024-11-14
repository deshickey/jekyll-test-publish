---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Runbook for VSI Bastion Re-deployment
type: Informational
runbook-name: "VSI Bastion Deployment"
description: "VSI Bastion Deployment"
service: Conductors
link: /docs/runbooks/vsi_bastion_redeployment.html
parent: Bastion
grand_parent: Armada Runbooks
---

Informational
{: .label }

# Runbook for VSI Bastion Re-deployment

## Prerequisites:

Before proceeding with the VSI re-deployment, ensure you have the following:

Access to create new bastion machines in cloud.ibm.com in the respective account.
Access to the latest VSI bundle files from the following URL: https://github.ibm.com/Privileged-Access/classic-bastion-bundles/releases (ex: VSI 7.0).
Necessary permissions and credentials to update configurations.
Access to get backend load balancers, account name, certificate name, hostname, port, and username from the IBM Cloud console (cloud.ibm.com) for the respective region databases.
Access to the Secret Manager Python module from https://github.ibm.com/Privileged-Access/bastion-secrets-module.

## Step 1: Create New 6 Bastion Machines
Create 6 new bastion machines using the Ubuntu20 image. Use the naming conventions "prod-region-infra-bastionx-11" to "prod-region-infra-bastionx-16" for the new bastion machines.

## Step 2: Get the Latest VSI Bundle
Download the latest VSI bundle files (VSI 7.0) from the following URL: https://github.ibm.com/Privileged-Access/classic-bastion-bundles/releases.

##   Step 3: Update vars_main.yaml
Open the vars_main.yaml file located at vsi_deploy/DockerScenarioAnsibleScripts/iaas_main_playbook/vars_main.yaml. Replace the existing set of IPs on the Bastion with the new IPs corresponding to the newly created bastion machines (prod-region-infra-bastionx-11 to prod-region-infra-bastionx-16). Also, add the backend load balancers, account name, certificate name, hostname, port, and username for the respective region databases.

##  Step 4: Update teleport-proxy.yaml
Modify the teleport-proxy.yaml file to update the following fields:
vsi_deploy/DockerScenarioAnsibleScripts/iaas_main_playbook/teleport-proxy.yaml
```
auth_servers
peers
tls_ca_file
username
public_addr
ssh_public_addr

```

## Step 5: Update teleport-auth-ent.yaml

Update the teleport-auth-ent.yaml file to update the following fields:
vsi_deploy/DockerScenarioAnsibleScripts/iaas_main_playbook/teleport-auth-ent.yaml
```
public_addr
cluster_name
peers
tls_ca_file
username
auth_servers
```

## Step 6: Update role-ibm-operator.yaml

vsi_deploy/DockerScenarioAnsibleScripts/iaas_main_playbook/role-ibm-operator.yaml
Check the URL https://github.ibm.com/alchemy-conductors/bastion-deployment-archive/blob/master/vsi-solution/releases/ap-south/vsi_deploy/DockerScenarioAnsibleScripts/iaas_main_playbook/role-ibm-operator.yaml#L35-L38 to get the updated role. Replace the role in the vsi_deploy/DockerScenarioAnsibleScripts/iaas_main_playbook/role-ibm-operator.yaml file.

## Step 7: Update the Secret Manager Python Module
Fetch the secret_manager Python module from https://github.ibm.com/Privileged-Access/bastion-secrets-module and update it in the appropriate location within the bundle.

## Step 8: Update ETCD Allowlist Configuration
For each bastion machine (prod-region-infra-bastionx-11 to prod-region-infra-bastionx-16), go to the IBM Cloud console (cloud.ibm.com) and update the allowlist configuration with the U20 bastion IPs.

## Step 9: Configure Passwordless SSH
Establish passwordless SSH access to all 6 bastion machines (prod-region-infra-bastionx-11 to prod-region-infra-bastionx-16) involved in the deployment.

## Step 10: Update CBR Configuration
Update the CBR configuration located at https://github.ibm.com/alchemy-conductors/cbr/blob/ce81d3775b433f9ffa27349567cdb3511f1ef98b/builder/etcd_builder.go#L38 as required for the updated setup. Refer to the example PR at https://github.ibm.com/alchemy-conductors/cbr/pull/109 for guidance.

## Step 11: Allowlist Update in alchemy-conductors/compliance-update-icd-cos-allowlists#235
Update the allowlist in alchemy-conductors/compliance-update-icd-cos-allowlists#235. Refer to the example PR at https://github.ibm.com/alchemy-conductors/compliance-update-icd-cos-allowlists/pull/243 for guidance.

## Step 12: Add IPs to Load Balancer in cloud.ibm.com
Add the IPs of bastion machines (prod-region-infra-bastionx-11 to prod-region-infra-bastionx-16) to the Load Balancer in the IBM Cloud console (cloud.ibm.com).

## Step 13: Export Environment Variables
Export the necessary environment variables on all bastion machines, including IAAS_CLASSIC_API_KEY, IBMCLOUD_API_KEY, ETCD_CERT, ETCD_PASS, and SM_API_KEY. Retrieve etcd_cert and etcd_pass from the database.

## Step 14 : Run Deployment

go to vsi_deploy/DockerScenarioAnsibleScripts/Prerequisites/

python3 provision_terraform.py --hostname 531277-xxx --sl_username 531277_user@ibm.com  --service_name containers-kubernetes --version 10.3.12.5  --vm_already_provisioned --vpn_enabled --oss_version 1.0.9.39 --ansible_user xxx --keep_ssh_enabled --skip_terraform --ingestion_key (get from logdna) --etcd_already_deployed
