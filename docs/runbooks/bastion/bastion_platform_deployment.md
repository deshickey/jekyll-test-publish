---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Bastion platform deployment
type: Informational
runbook-name: "Bastion platform deployment"
description: "Bastion platform deployment"
service: Conductors
link: /docs/runbooks/bastion_platform_deployment.html
parent: Bastion
grand_parent: Armada Runbooks
---

Informational
{: .label }

# Bastion platform deployment [Draft]

## Overview

This document describes the procedure to deploy bastion **platform deployment** onto bare-metal servers or VMs

## Detailed Information

### Request bastion installation package

Create a service now ticket by following guideline provided at [Open an IBM Bastion Host Deployment ticket](https://test.cloud.ibm.com/docs/bastionx?topic=bastionx-open-an-ibm-bastion-host-deployment-ticket)

**NOTE:** Make sure to set following as described below.
- `__isHamilton (true or false)__ : true`
- `__isIKS (true or false)__: false`

For the `isHamilton` parameter:

- if set to `true`, the Bastion team configures to have the _ibmoperator_ configuration and stores the group names in their database
- if set to `false`, multiple steps including the oss plugin steps are skipped

### Deployment pre-requisites

1. Create one public + one private VLAN for bastion in each DC
   - This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3706) can be used as a reference.
1. VMs should be provisioned and available to install teleport solution on it.
   - 2 per DC. Example hostnames:
   ```
   dev-dal10-infra-bastionx-01
   dev-dal10-infra-bastionx-02
   dev-dal12-infra-bastionx-03
   dev-dal12-infra-bastionx-04
   dev-dal13-infra-bastionx-05
   dev-dal13-infra-bastionx-06
   ```
1. Create resource group if not present
   - Go Manage > Account > Account resources > Resource groups
   - Create a resource with following naming convention: `bastion-env-region` (example: `bastion-stage-us-south`)
1. Create and _ICD for ETCD_ instance
   - Go Resource list > Create resource > _type `etcd` to search_ > Select `Databases for etcd`   
   - Use the following parameters:
     - Service name: `etcd-env-region-bastionx-infra` (example: `etcd-stage-us-south-bastionx-infra`)
     - Select the appropriate region
     - Select resource group created in the previous step
     - Endpoint: private network
1. Raise GHE issues over [alchemy-netint/firewall-requests](https://github.ibm.com/alchemy-netint/firewall-requests/issues) for below firewall setup and make sure they are finished.
   - _Port 3023_ should be open from vpn to bastion hosts.  
      This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3524) can be used as a reference.
   - _Port 3022_ should be open from all bastion hosts to all nodes that should be behind bastion.  
      This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3525) can be used as a reference.
   - _Port 3025_ should be open on load balancers and from all nodes to load balancers. Port 3080, 3022, 3023, and 3024 should be open on load balancers in each zone.  
      This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3526) can be used as a reference.  
   - We also need cross-subnet connection on port 3025, 3080, 3023, 3022, and 3024  
      This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3806) can be used as a reference.
   - Ensure that bastion nodes can reach the container registry.  
      This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3734) can be used as a reference.  
   - _Port 123_ should be open from bastion hosts to **time.service.networklayer.com** for protocol UDP  
      This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3778) can be used as a reference.  
   - Add GP VPN IPs to Vyatta  
      This [example issue](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3810) can be used as a reference.
1. ensure bastion VMs are correctly provisioned and bootstrapped
1. Bastion deployment package.  
   _You will get the package when the service now ticket is finished by bastion team_
1. Open the IAM settings for the relevant account (e.g. 1858147 for staging) in https://cloud.ibm.com/, and if necessary:
   - under `Access groups`, create the group name used in the ServiceNow ticket; for example `ap-south_bast_admin`
   - add yourself and any other users to the group

(Needs a functional user, and needs to find out a function user id which can be used for bastion deployment)

### Deployment process

1. Download and install the bundle https://github.ibm.com/Privileged-Access/classic-bastion-bundles/releases
    - Use the latest release unless advised to use a specific version
1. Copy your SSO ssh private and public key to `DockerScenarioAnsibleScripts/terraform_LBs/id_rsa` and `DockerScenarioAnsibleScripts/terraform_LBs/id_rsa.pub` respectively
    - Note that you **must** have **password-less** ssh available for this to work - i.e. your public key must be deployed on the hosts
    - Test with `ssh -i ../terraform_LBs/id_rsa <bastion_vm_private_ip>`
1. `cd DockerScenarioAnsibleScripts/prerequisites`
1. `pip3 install -r requirements.txt`
1. Update `iaas_main_playbook/vars_main.yaml` with following information:
   1. Update load-balancers as pre-provisioned. Skip this step if LBs are already provisioned.
   1. Update teleport IPs with bastion private IPs:
      ```
      teleport:
        az1_cluster1_public_ip: xxx
        az1_cluster2_public_ip: xxx
        az2_cluster1_public_ip: xxx
        az2_cluster2_public_ip: xxx
        az3_cluster1_public_ip: xxx
        az3_cluster2_public_ip: xxx
      ```
   1. Update role with IAM group provided in the SN ticket. For example:
      ```
      value_roles:
      - roles:
        - ssh-admin
        - ssh-user
        value: ap-south_bast_admin
      ```
   1. Update `oss_image` variable with region-specific container registry. For example:
      ```
        oss_image: au.icr.io/bastion-prod/oss-api-plugin
      ```
   1. Update `teleport_image` variable with region-specific container registry. For example:
      ```
        teleport_image: au.icr.io/bastion-prod/teleport-ent
      ```
1. Edit the `iaas_main_playbook/role-ibm-operator.yaml` file, with all of the IAM groups which need `ssh-admin` access. For example:
    ```
      - claim:
        roles:
        - ssh-admin
        value: ap-south_bast_admin
    ```
1. Connect to the relevant OpenVPN before running the playbook
1. Export some shell variables for secrets:
    ```
    export SM_API_KEY=xxxxx
    export IBMCLOUD_API_KEY=xxxx ( using alchcond user key for now)
    export ETCD_PASS=xxxx
    export IAAS_CLASSIC_API_KEY=xxxx
    export ETCD_CERT=xxxx (base64 encoded cert)
    ```
1. In the `python3` command-line below, use the following:
    - `THE_HOSTNAME`: from the `#bastion-notification` channel
    - `SOFTLAYER_USERNAME`: e.g. `1858417_user.name@ibm.com`
    - `THE_VERSION`: teleport version, currently 13.1.5.0
    - `YOUR_USER`: sso username (for ssh)
    - `OSS_VERSION`: OSS plugin version, currently 1.0.10
    - add `--skip_terraform` if the LBs have already been created, or if running a version upgrade
1. Execute the provision playbook:
    ```
    python3 provision_terraform.py --hostname THE_HOSTNAME --sl_username SOFTLAYER_USERNAME --service_name containers-kubernetes --version THE_VERSION --vm_already_provisioned --vpn_enabled --ansible_user YOUR_USER --oss_version OSS_VERSION --keep_ssh_enabled
    ```
    - If that fails because of missing package dependency, install additional packages
      - Need to install `ansible`, `astroid`
    - On MacOS, you may get a pop-up warning about the `terraform` bundle and see this error `Error: Failed to instantiate provider "ibm" to obtain schema: Unrecognized remote plugin message`
      - If so, click `Cancel` on the pop-up windows and `Ctrl+c` the `python3` command-line
      - Go to Mac System Preferences > Security & Privacy > General tab and click to allow the terraform bundle
      - Re-run the `python3` command-line and click `Open` if there is a new pop-up window about the terraform bundle
    - If above fails during terraform provision, use `--force_local_tfstate` flag for subsequent runs until terraform provision is passed. Once terraform provision is passed, use `--skip_terraform` flag on subsequent runs to skip terraform step and save time.
1. If the installation fails, we need to:
    - stop it _Ctrl+c quickly!_
    - investigate
    - then clean up using the following:
    1. Edit `../iaas_client_playbook/hosts` with the 6 teleport nodes
    2. Run the following:
      ```
      cd DockerScenarioAnsibleScripts/iaas_clean_playbook
      ansible-playbook -i ../iaas_client_playbook/hosts ./iaas_clean.yml -u YOUR_SSO_USERNAME --private-key ../terraform_LBs/id_rsa
      ```
    - _as a last resort_, if the deployment did not work and we cannot connect via either ssh or teleport, then the nodes will have to be os-reloaded and start over
      - **NB:** this should never be used to fix problems once the deployment is successful

### Post-deployment manual fixes

The following steps are required for post-installation fixes.

1. Configure `chrony` to use local NTP server. 
   - This is no longer required.
1. Configure `teleport-proxy` to use local BE load-balancer on each bastion nodes. 
   - Configure `auth_servers:` CLB order on `teleport-proxy.yaml` and `teleport-auth-ent.yaml` file in a way that local AZ gets a first preference.  
     For example, Nodes in `fra02` AZ would have clb in `fra02, fra04, fra05` order.
     ```
         auth_servers:
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-0-531277-fra02.clb.appdomain.cloud:3025
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-1-531277-fra04.clb.appdomain.cloud:3025
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-2-531277-fra05.clb.appdomain.cloud:3025
     ```
     Nodes in `fra04` AZ would have clb in `fra04, fra02, fra05` order.
     ```
         auth_servers:
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-1-531277-fra04.clb.appdomain.cloud:3025
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-0-531277-fra02.clb.appdomain.cloud:3025
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-2-531277-fra05.clb.appdomain.cloud:3025
     ```
     Nodes in `fra05` AZ would have clb in `fra05, fra04, fra02` order.
     ```
         auth_servers:
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-2-531277-fra05.clb.appdomain.cloud:3025
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-1-531277-fra04.clb.appdomain.cloud:3025
         - BE-531277-xhvr3ksnx8z15tfj8g39w09xt-0-531277-fra02.clb.appdomain.cloud:3025
     ```
   - Restart `teleport-auth` docker container and wait for a minute.
   - Restart `teleport-proxy` docker container and wait for a minute.
1. Increase max connection from 3 to 6 for roles in Bastion: 
   1. Go to Bastion Web UI > Resources dropdown > Select Management
   1. Select Roles on left panel
   1. Edit `ssh-admin` and `ssh-user` roles
      1. In the yaml view look for `max_connections: 3` and update it to `max_connections: 6`
      1. Save changes.
1. Increase max connection to 10000 in bastion proxy and auth: 
   - Update `max_connections:` on `teleport-proxy.yaml` and `teleport-auth-ent.yaml` files.
   - Restart `teleport-auth` docker container and wait for a minute.
   - Restart `teleport-proxy` docker container and wait for a minute.
   - Repeat the process for all bastion infra nodes.
