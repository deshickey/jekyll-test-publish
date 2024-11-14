---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Bastion kubernetes deployment on IKS cluster
type: Informational
runbook-name: "Bastion kubernetes deployment on IKS cluster"
description: "Bastion kubernetes deployment on IKS cluster"
service: Conductors
link: /docs/runbooks/bastion_iks_deployment.html
parent: Bastion
grand_parent: Armada Runbooks
---

Informational
{: .label }

# Bastion kubernetes deployment on IKS cluster

## Overview

This document describe the procedure to deploy bastion kubernetes deployment onto a IKS cluster or a tugboat.

## Detailed Information

### OnBoard cluster on BastionX

Craete a service now ticket by following guideline provided at [Open an IBM Bastion Host Deployment ticket](https://test.cloud.ibm.com/docs/bastionx?topic=bastionx-open-an-ibm-bastion-host-deployment-ticket)  

**NOTE:** Make sure you put following things right and remember them, as these will be used in further process.
- `____Namespace (teleport)__ `: We will use same namespace that provided in this ticket when we create teleport deployment.  
   _It is recommended to use `bastion` namespace_

### Deployment pre-requisites

- Bastion deployment package.  
   _You will get the package when service now ticket is finished by bastion team_

(Needs a functional user, and needs to find out a function user id which can be used for bastion deployment)

### Deployment process

1. Log into `ibmcloud` cli with function user id (Yet to find out correct function user id)  
   `ibmcloud login --sso`  
   _Pick correct account and region_

1. Target correct resource group  
   `ibmcloud target -g <resource group>`  
   _You can find correct resource group by looking at cluster_  
   `ibmcloud ks cluster get --cluster <cluster id>`

1. Configure cluster with `kubectl` cli  
   `ibmcloud ks cluster config --cluster <cluster id>`

1. Craete `bastion` namespace on cluster  
   Create `bastion-namespace.yaml` file  
   ```
   cat <<'EOF' >> bastion-namespace.yaml
   apiVersion: v1
   kind: Namespace
   metadata:
     name: bastion
     labels:
       name: bastion
       app: teleport
   EOF
   ```
   Apply `bastion-namespace.yaml` on cluster  
   `kubectl apply -f bastion-namespace.yaml`

1. Create the service account for tiller  
   `kubectl create serviceaccount tiller --namespace bastion`

1. Initialise helm 2 in the cluster  
   `helm init --service-account tiller --tiller-namespace bastion`

1. Create cluster role binding to `cluster-admin` role  
   `kubectl create clusterrolebinding tiller-ibm-cluster-admin-binding --clusterrole=cluster-admin --serviceaccount=bastion:tiller -n bastion`

1. Patch tiller to specify service account  
   `kubectl patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n bastion`

1. Create cluster bining role for teleport pod  
   Create `teleport-ibm-privileged-user.yaml` file  
   ```
   cat <<'EOF' >> teleport-ibm-privileged-user.yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     annotations:
     name: teleport-ibm-privileged-psp-user
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: ibm-privileged-psp-user
   subjects:
   - apiGroup: rbac.authorization.k8s.io
     kind: Group
     name: system:serviceaccounts:bastion
   EOF
   ```
   Apply `teleport-ibm-privileged-user.yaml` on cluster  
   `kubectl apply -f teleport-ibm-privileged-user.yaml`

1. Execute bastion deployment  
   Set up required variables  
   ```
   export VAULT_ROLE=<vault role>
   export VAULT_SECRET=<vault secret>
   export TILLER_NAMESPACE=bastion
   export CLUSTER_ID=<cluster id>
   export NAMESPACE=bastion
   export TELEPORT_IMAGE_VERSION=4.3.5
   export SERVICE_NAME=containers-kubernetes
   ```
   Execute deployment  
   `./iks_deploy.sh -vr $VAULT_ROLE -vs $VAULT_SECRET -sn $SERVICE_NAME -v $TELEPORT_IMAGE_VERSION -n $NAMESPACE`

### Post Deployment process to disable public endpoint

 - #### Pre-requisite
   - VRF on your account should be enabled
   - Service Point for the account should be enabled
   
   `ibmcloud account show` command will help you get these details of your account
   
 - #### Enable private endpoint
   Once the pre-requisites are met run the below command to enable private end point
   - command to run to enable private endpoint
   ```
   ibmcloud ks cluster feature enable private-service-endpoint --cluster $CLUSTER_ID
   ```
   - refresh the master using the command below
   ```
   ibmcloud ks cluster master refresh --cluster $CLUSTER_ID
   ```
   - verify the private service endpoint is available using the command below
   ```
   ibmcloud ks cluster get --cluster $CLUSTER_ID
   ```
   - reload the workers one by one using the following command after making sure private service endpoint is available
   ```
   ibmcloud ks worker update --cluster $CLUSTER_ID --worker $WORKER_ID
   ```
   - verify the status of worker update by listing
   ```
   ibmcloud ks worker ls --cluster $CLUSTER_ID
   ```
   
 - #### Disable public endpoint
   Once the private end point is available. Go ahead and disable the public endpoint
   - command to run to disable public endpoint
   ```
   ibmcloud ks cluster master public-service-endpoint disable --cluster $CLUSTER_ID
   ```
   - refresh the master using the command below
   ```
   ibmcloud ks cluster master refresh --cluster $CLUSTER_ID
   ```
   - verify the public service endpoint is disabled using the command below
   ```
   ibmcloud ks cluster get --cluster $CLUSTER_ID
   ```
   - reload the workers one by one using the following command after making sure public service endpoint is disabled
   ```
   ibmcloud ks worker update --cluster $CLUSTER_ID --worker $WORKER_ID
   ```
   - verify the status of worker update by listing
   ```
   ibmcloud ks worker ls --cluster $CLUSTER_ID
   ```