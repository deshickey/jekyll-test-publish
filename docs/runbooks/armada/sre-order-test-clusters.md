---
layout: default
description: This runbook includes information on how to order test clusters
runbook-name: "order-test-clusters"
title: "How to Order Test Clusters"
service: armada
link: /armada/sre-order-test-clusters.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook includes information on how to order test clusters in pre-prod and prod

For tugboat Go Live testing please see [Tugboat Test Cluster Requirements for Go Live](#tugboat-test-cluster-requirements-for-go-live)

## Pre-Req
- The IAM user should have a necessary permission to create clusters
- The IAM user's Infrastsructure API key 
- **ibmcloud cli** and **iks plugin** [installed](https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install
)

## Tugboat Test Cluster Requirements for Go Live
1. Make sure that the tugboat has been set to `"enabled": "alpha"` in armada-config-pusher and the PR has been merged and promoted.
2. Login to dev-containers as [conauto](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/42514/general).  
` ibmcloud login -a cloud.ibm.com --apikey <apikey> --no-region`
4. Select the correct resource group
` ibmcloud target -g sre-test`
4. The cluster name must begin with _`alpha-target`_.   For example: `alpha-target-dal10-c130`
5. Check with @xo in #armada-xo to ensure the cluster was created on the correct tugboat carrier.
`@xo cluster <clusterID>`

## Detailed Information

1. Login to the Use [admin creds (from pim.sos.ibm.com)](https://pim.sos.ibm.com/app/#/secret/980/general) or personal account with necessary permissions 

1. Login to the correct IBM cloud api endpoint:  
_NB. Do not open the URL in the default browser. Instead, open in private/incognito browser with above creds._  
**pre-prod**:  
`ibmcloud login -a test.cloud.ibm.com --sso --no-region`  
**prod**:  
`ibmcloud login -a cloud.ibm.com --sso --no-region`

1. Select account  
**prod and pre-prod**: `Dev Containers (47998ac029ed4ca69cf807338b7dbd2e) <-> 1186049`

1. Ensure credentials are correct:  
`ibmcloud account show`  
will provide output similar to: `Retrieving account $ACCOUNT_NAME's Account of $CURRENT_USER...`  
_NB. Make sure $CURRENT_USER is as expected_

1. Initialize host:  
**dev**:  
`ibmcloud ks init --host https://origin.containers.dev.cloud.ibm.com`  
**prestage**:  
`ibmcloud ks init --host https://origin.containers.pretest.cloud.ibm.com`  
**stage**:  
`ibmcloud ks init --host https://containers.test.cloud.ibm.com`  
**prodfr2**:  
`ibmcloud ks init --host=https://origin.eu-fr2.containers.cloud.ibm.com`  
**prod**:  
`ibmcloud ks init --host=https://containers.cloud.ibm.com`

1. Check that the hardware you see is expected

   - `ibmcloud ks vlans --zone che01`   
   ```
    OK
    ID        Name   Number   Type      Router         Supports Virtual Workers   
    3234148          971      private   bcr01a.che01   true   
    3234146          907      public    fcr01a.che01   true 
  ```  

NOTE:  If there are no vlans listed, but you are in the correct account, you can create the test cluster without specifying the private and public vlans.  The vlans will be created and attached to your cluster.
   
1. select vlans:  
**dev**: `Devpa/Cruiser|Patrol`  
**prestage**: `Prepa/Cruiser|Patrol`  
**stage**: `Stagepa/Cruiser|Patrol`  
**prod**: `Prodpa/Cruiser|Patrol`

1. Order Cluster  
_To list all the parameters required to execute the commands below use :_  
_`ibmcloud ks -h`_  
NB. For Private Service Endpoint Cluster on either the **Cruiser** or **Roks**, append the follow to the cmd below:  
`--private-service-endpoint`

- Patrol:  
`ibmcloud ks cluster create classic --name $NAME --location $ZONE --public-vlan $PUBLIC_VLAN --private-vlan $PRIVATE_VLAN --workers 1`

- Cruiser:  
`ibmcloud ks cluster create classic --name $NAME --location $ZONE --public-vlan $PUBLIC_VLAN --private-vlan $PRIVATE_VLAN --flavor $flavor --workers 1`

- Roks:  
`ibmcloud ks cluster create classic --name $NAME --location $ZONE --public-vlan $PUBLIC_VLAN --private-vlan $PRIVATE_VLAN --flavor $flavor --workers 1 --kube-version $VERSION`
