---
layout: default
title: How to set up armada-etcd in a new region
type: Informational
runbook-name: "How to set up armada-etcd in a new region"
description: "How to set up the etcd used by IKS microservices in a new region"
service: Conductors
link: /etcd-setup-new-region.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The process to setup armada-etcd in a new region consists of two main steps. Both are described in detail below.

1. Setup temporary ICD etcd
1. migrate etcd from ICD to armada-etcd-operator cluster hosted in microservice tugboat

## Prereqs

1. Need to have Ballast squad add new region to their Jenkins jobs and check etcd version in migration script
1. Make sure COS credentials are setup in region.

   - Example: [armada-cos-secrets](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/us-east/armada-cos-secrets.yaml)

1. Make sure KP is setup in region.

   - Example: [kp-secrets](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/ap-north/kp.yaml)
   - Example: [kp-configmap](https://github.ibm.com/alchemy-containers/service-engine/blob/master/deployment/base/kp-configmap.yaml)
   - Example: [kp-configmap](https://github.ibm.com/alchemy-containers/service-engine/blob/master/deployment/overlays/ap-north/kp-configmap.yaml)

1. clone [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure) repo
1. `ibmcloud plugin install cloud-databases`

## Detailed information

### Create ICD instance

1. Log in to infrastructure account where the carrier workers are located. For prod, this is 531277.
1. Catalog -> Databases for etcd
1. Update the following fields, and leave all else as default:
   - Select a location - Select closest location to the new region
   - Service Name - Call this "Databases for $REGION-etcd"
   - Endpoints - select "Private only"
1. click Create

### Configure ICD instance

In order for the new region to be able to access this ICD etcd we need to add some secrets to armada-secure

1. ETCD_ROOT_PASSWORD
   - `openssl rand -base64 32 # delete any non-alphanumeric characters (there is no requirement for length of this string)`
   - Use above string to set the password `ibmcloud cdb user-password 'Databases for $ENV_PREFIX-$REGION-etcd' root xxx`
   - save above password in ./build-env-vars/etcd/$ENV_PREFIX_$REGION_ETCD_PASSWORD_$DATE.txt
   - [create ETCD_PASSWORD_$REGION.gpg](https://github.ibm.com/alchemy-containers/armada-secure#defining-a-new-secure-environment-variable)
1. ETCD_COMPOSE_CA
   - cloud.ibm.com -> search 'Databases for $ENV_PREFIX-$REGION-etcd' -> Overview -> Endpoints -> Quick start -> copy the TLS Certificate
   - save TLS certificate in file ./build-env-vars/etcd/$ENV_PREFIX_$REGION_ETCD_COMPOSE_CA_$DATE.txt
   - [create ETCD_COMPOSE_CA_$REGION.gpg](https://github.ibm.com/alchemy-containers/armada-secure#defining-a-new-secure-environment-variable)
1. ETCD_SECRET
   - `openssl rand -base64 20`
   - replace any non-alphanumeric chars in above string with random alphanumeric ones. This string is used as a cipher by armada-data and must be 20 alphanumeric chars.
   - save string in file ./build-env-vars/etcd/$ENV_PREFIX_$REGION_ETCD_SECRET_$DATE.txt
   - [create ETCD_SECRET_$REGION.gpg](https://github.ibm.com/alchemy-containers/armada-secure#defining-a-new-secure-environment-variable)
1. etcd.yaml
   - copy existing `etcd.yaml` from another [region](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/us-east/etcd.yaml)
   - update the following fields:
      - Note: ETCD_CLUSTER_NUMBER may be different

   ```yaml
   ETCD_PASSWORD: (( grab $$ENV_PREFIX_$REGION_ETCD_PASSWORD_$DATE_64 ))
   ETCD_SECRET: (( grab $$ENV_PREFIX_$REGION_ETCD_SECRET_$DATE_64 ))
   compose-ca.pem: (( grab $$ENV_PREFIX_$REGION_ETCD_COMPOSE_CA_$DATE_64 ))
   ETCD_ENDPOINTS: # cloud.ibm.com -> search 'Databases for $REGION-etcd' -> Overview -> Endpoints -> CLI -> Arguments. Copy everything to the right of '--endpoints='. Refer below screenshot.
   ETCD_AUTH: "true"
   ETCD_USER: "root"
   ETCD_V3: "true"
   ETCD_USE_OPERATOR: "false"
   ETCD_ENDPOINTS_OPERATOR: ""
   ETCD_OPERATOR_NODEPORT: ""
   ETCD_READ_ONLY: "false"
   ETCD_CLUSTER_NUMBER: "101"
   ETCD_RULES_DISABLED: "false"
   ETCD_MIGRATION_ENABLED: "true"
   ETCD_CLUSTER_NUMBER: set to the tugboat number
   ```

   [Example](https://github.ibm.com/alchemy-containers/armada-secure/pull/2690)

   <br />
   <img src="images/etcd_endpoint.png" style="width: 800px;"/></a>
   <br />

1. create file `secure/armada/$REGION/armada-etcd-operator-secrets.yaml` as a placeholder for the microservices that require it. The contents of the file can be found at at this [example PR](https://github.ibm.com/alchemy-containers/armada-secure/pull/3005)

1. Promote this to the region to allow services to run on the carrier
1. Verify services are running on the carrier and have access to ICD etcd
   - Check the logs for a pod like armada-reaper, should not see any etcd errors.

## Migrate carrier etcd to tugboat armada etcd operator

### Migration Secure Branches Summary

1. 3 different armada-secure branches are needed for this process:
   - baseline branch - This will be done with the initial setup branch automation.
     - **etcd.yaml at region level**
     - ETCD_ENDPOINTS_OPERATOR set to the 3 etcd endpoints
     - ETCD_OPERATOR_NODEPORT set to 31579
   - read-only branch
     - **etcd.yaml at region level**
     - This is need right before the migration job is run
     - ETCD_READ_ONLY set to true
   - post-migration branch
     - **etcd.yaml at region level**
     - [example](https://github.ibm.com/alchemy-containers/armada-secure/blob/dev-us-south/secure/armada/br-sao/etcd.yaml)
     - finalizes migration and turns on armada etcd operator
     - ETCD_USE_OPERATOR: "true"
     - ETCD_READ_ONLY: "false"
     - ETCD_ENDPOINTS: ""
     - ETCD_RULES_DISABLED: "false"
     - **etcd.yaml at hub carrier/barge level**
     - [example](https://github.ibm.com/alchemy-containers/armada-secure/blob/dev-us-south/secure/armada/br-sao/hubs/prod-sao01-carrier1/etcd.yaml)
     - ETCD_RULES_DISABLED: "true"
     - **There should not be an etcd.yaml at the hub tugboat level**

### Migration Process

1. The tugboat is up and it's kubeconfig and vpn config SM IDs have been updated in Jenkins
   - Ballast squad will handle this once this information is known.
1. promote baseline pr
   - The cert gen job requires this to be active on the tugboat
1. Run the [Armada ETCD Certificate Generation job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-cert-regeneration/).
   - This will create a Secure branch with new ETCD certificates for the tugboat.
   - Provide a Ballast issue link: `BALLAST_ISSUE`
   - Uncheck the `CERT_REGENERATE`
   - Verify branch, create and promote PR
   - `kubectl -n armada get secret | grep etcd`

    ```text
    armada-etcd-secrets                              Opaque                                3      3y144d
    etcd-1-armada-dev-south-ca-tls                   Opaque                                2      504d
    etcd-1-armada-dev-south-client-tls               Opaque                                3      504d
    etcd-104-armada-dev-south-ca-tls                 Opaque                                2      504d
    etcd-104-armada-dev-south-client-tls             Opaque                                3      504d
    etcd-104-armada-dev-south-peer-tls               Opaque                                3      504d
    etcd-104-armada-dev-south-server-tls             Opaque                                3      504d
    ```

1. promote read-only pr
   - Ensure region is read only `ibmcloud ks cluster master refresh -c $tugboat`. You should see a message similar to `The backend service is currently updating and cannot create or modify resources`
1. [scale down microservices](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-scale-region/)
   - Ensure non-api microservices are scaled down `kubectl get deploy -n armada`
1. Run the migration job: [armada-etcd-migration](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-migration/)
   - First run in DRY_RUN to double check the carrier and tugboat are ready.
   - The following is a high level description of what the above job does:
      - backups existing ICD etcd cluster data to COS
      - restore the COS etcd cluster data into tugboat armada etcd operator cluster (5 pods)
      - verifies the armada etcd operator cluster is available to microservice clients
1. Review the migration job log for any issues.
1. Review the tugboat for any issues with the [Get ETCD Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-info/)

   ```text
   kubectl -n armada get pod -l app=etcd

   NAME                                   READY   STATUS    RESTARTS   AGE
   etcd-104-armada-dev-south-5wtsgpql6m   2/2     Running   0          12d
   etcd-104-armada-dev-south-6gsxgz6d4g   2/2     Running   0          11d
   etcd-104-armada-dev-south-7jvlbgskst   2/2     Running   0          11d
   etcd-104-armada-dev-south-c5zlfcvv2d   2/2     Running   0          11d
   etcd-104-armada-dev-south-vqxr8t9m4t   2/2     Running   0          11d

   kubectl -n armada get etcdcluster -o=jsonpath='{.items[0].status.phase}'

   Running
   ```

1. promote armada-secure post-migration branch
1. [scale up microservices](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-scale-region/)
   - Ensure microservices are scaled up `kubectl get deploy -n armada`

## Post Migration Jobs

1. [backup new etcd](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-backup/)
1. [backup certs to local region](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-operator-cert-ops/)

    Run this job to backup the certs within the region itself.

    - Run first with region specified and list option to see current list of secrets:

    ```text
    NAME                                             TYPE                                  DATA   AGE
    armada-etcd-secrets                              Opaque                                3      3y144d
    etcd-1-armada-dev-south-ca-tls                   Opaque                                2      504d
    etcd-1-armada-dev-south-client-tls               Opaque                                3      504d
    etcd-104-armada-dev-south-ca-tls                 Opaque                                2      504d
    etcd-104-armada-dev-south-client-tls             Opaque                                3      504d
    etcd-104-armada-dev-south-peer-tls               Opaque                                3      504d
    etcd-104-armada-dev-south-server-tls             Opaque                                3      504d
    ```

    - Run with region specified and backup option

    ```text
    NAME                                             TYPE                                  DATA   AGE
    armada-etcd-secrets                              Opaque                                3      3y144d
    etcd-1-armada-dev-south-ca-tls                   Opaque                                2      504d
    etcd-1-armada-dev-south-ca-tls-backup            Opaque                                2      1s
    etcd-1-armada-dev-south-client-tls               Opaque                                3      504d
    etcd-1-armada-dev-south-client-tls-backup        Opaque                                3      0s
    etcd-104-armada-dev-south-ca-tls                 Opaque                                2      504d
    etcd-104-armada-dev-south-ca-tls-backup          Opaque                                2      5s
    etcd-104-armada-dev-south-client-tls             Opaque                                3      504d
    etcd-104-armada-dev-south-client-tls-backup      Opaque                                3      4s
    etcd-104-armada-dev-south-peer-tls               Opaque                                3      504d
    etcd-104-armada-dev-south-peer-tls-backup        Opaque                                3      3s
    etcd-104-armada-dev-south-server-tls             Opaque                                3      504d
    etcd-104-armada-dev-south-server-tls-backup      Opaque                                3      2s
    ```

1. [backup certs to Secret Manager](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-cert-to-sm/)

## Cleanup

- After the etcd is migrated from ICD to etcd tugboat, delete the temporary ICD instance created in the first step of this runbook.

## Escalation Policy

- @Ballast in #armada-ballast
