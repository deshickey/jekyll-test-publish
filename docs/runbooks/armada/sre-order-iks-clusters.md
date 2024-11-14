---
layout: default
description: This runbook includes information on how to order dev clusters
runbook-name: "order-iks-clusters"
title: "How to Order IKS Clusters"
service: armada
link: /armada/sre-order-iks-clusters.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook includes information on how to order iks clusters

## Pre-Req
- The IAM user should have permission to create clusters in the desired account.(more details in point #2 below)
- The IAM user's Infrastsructure API key  (Refer the section [Using functional Ids](#using-functional-ids))
- Install ibmcloud cli and iks plugin: https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install

## Detailed Information

1. Use account with necessary permissions. User IAM account should have Administrator and Manager privileges. If not, follow the steps below.
   - Please obtain approval from the manager of the account to upgrade the Access Policy of the IAM user
   - Login to [prod](https://cloud.ibm.com) or [test](https://test.cloud.ibm.com) ibmcloud portal (depending on your intended environment) as owner of the account. Refer the section [Using functional Ids](#using-functional-ids)
   - Select the following options in the order: 
     - _Manage_ 
     - _Access(IAM)_ 
     - _Users_ 
     - "<_select your user_>"
     - _Access Policies_ 
     - _Assign access_ 
     - _IAM Services_ 
     - _Kubernetis Service_
   - And grant Administrator and Manager Permissions

2. Login to the correct api endpoint:

   - prod: `ibmcloud login -a cloud.ibm.com --sso --no-region`
   - pre-prod: `ibmcloud login -a test.cloud.ibm.com --sso --no-region`

   Do not open the URL in the default browser. Copy the url and open in private/incognito browser. 
   For the credentials, you have to give the IAM user for username and the corresponding password(API Key).
   Refer the section [Using functional Ids](#using-functional-ids)

   _Note: all pre-prods (dev/stage/prestage) uses test.cloud.ibm.com_

3. Select account:
   - pre-prod: <_pre-prod-specific-intended-account_>
   - prod: <_prod-specific-intended-account_>

4. Ensure credentials are correct:

   `ibmcloud account show` will provide output similar to: _Retrieving account $ACCOUNT_NAME's Account of $CURRENT_USER..._

   Make sure $CURRENT_USER is as expected.

5. Initialize host:
   - prod: `ibmcloud ks init --host=https://containers.cloud.ibm.com`
   - stage: `ibmcloud ks init --host https://containers.test.cloud.ibm.com`
   - prestage: `ibmcloud ks init --host https://origin.containers.pretest.cloud.ibm.com`
   - dev: `ibmcloud ks init --host=https://containers.test.cloud.ibm.com`

6. Check that the hardware you see is expected. (You can see the intended Datacenter in the names of vlan)
   - `ibmcloud ks vlans --zone <intended-datacenter>` 
     - example: `ibmcloud ks vlans --zone fra02`
   - if you do not see expected hardware, Do the following:

     `export USERNAME=<desired-iam-user>`

     `export KEY=<user-api-key-from-secret-server>`

     `ibmcloud ks credential set classic --infrastructure-api-key $KEY --infrastructure-username $USERNAME` 

7. Get required parameters `ibmcloud ks -h`
   The help lists the parameters required for Step 10

8. Select vlans:
   - dev: _Devpa/Cruiser|Patrol_
   - prestage: _Prepa/Cruiser|Patrol_
   - stage: _Stagepa/Cruiser|Patrol_
   - prod: _Prodpa/Cruiser|Patrol_

   You should select the vlan ids based on your requirement. 1 public and 1 private.

   _Note: Tugboat/Carrier vlans are dedicated for infra machines. They should not be used when ordering clusters manually._

9. Set your variables. 
   - Zone = <_intended-datacenter_>, 
   - PUBLIC_VLAN and PRIVATE_VLAN are from step 8. 
   - MACHINE_TYPE based on your requirement.
   - VERSION=<_version-as-per-requirement_>
     - You can list the versions using the command `ibmcloud ks versions` and choose from the output.
   - NAME should follow a naming convention. 
     - A support cluster like bootstrap(for example) or any other micro-service, then the naming convention is $ENV-$REGION-$MICROSERVICE 
       - example: prod-eu-central-conductor-tools
     - A standard cluster will have a naming convention of $ENV-$REGION-CARRIER#
       - example: prestage-us-south-carrier1

   _$ENV is dev/prod/stage/prestage (based on requirement)_

   _$MICROSERVICE is name of the service_

10. Order Cluster by using one of the below commands suitable for your requirement

    Patrol: `ibmcloud ks cluster create classic --name $NAME --location $ZONE --public-vlan $PUBLIC_VLAN --private-vlan $PRIVATE_VLAN --workers 1`

    Cruiser: `ibmcloud ks cluster create classic --name $NAME --location $ZONE --public-vlan $PUBLIC_VLAN --private-vlan $PRIVATE_VLAN --machine-type $MACHINE_TYPE --workers 1`

    Roks: `ibmcloud ks cluster create classic --name $NAME --location $ZONE --public-vlan $PUBLIC_VLAN --private-vlan $PRIVATE_VLAN --machine-type $MACHINE_TYPE --workers 1 --kube-version $VERSION`

    Private Service Endpoint Cluster: append `--private-service-endpoint` to either the Cruiser or Roks cmd above.

    _Note: Private clusters are not supported for patrols_


    Additionally, if you are setting up a multizone cluster, The additional zones are set up via `zone add`.

    `ibmcloud ks zone add classic --zone <zone> --cluster <cluster_name_or_ID> --worker-pool <pool_name> --private-vlan <private_VLAN_ID> --public-vlan <public_VLAN_ID>`

    _Note: Choose the required worker-pool name from the output of the below command:_ 

    ` ibmcloud ks worker-pool ls --cluster <cluster_name_or_ID>`


## Using functional IDs

- To get the password(API key) login to [secret server](https://pimconsole.sos.ibm.com/) using your SSO account.
- Search for the IAM user you need, on the top right corner and select appropriate user and copy the password(API key)
