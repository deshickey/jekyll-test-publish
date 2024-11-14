---
layout: default
description: Procedure to debug armada-satellite-storage template issues.
title: armada-storage -  Procedure to debug armada-satellite-storage template issues.
service: armada-storage, satellite-storage
runbook-name: "Basic checks - armada-satellite-storage template issues."
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/armada-satellite-storage-troubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Content
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

---

## Overview
The armada-storage-api is a carrier deployment service which handles satellite storage and vpc storage apis.
satellite-storage also supports a set of cli commands to manage satellite storage templates and their configurations and assignments.
For more details please refer to the [architecture](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/satellite-storage.md).<br>
armada-storage-api microservice is deployed on carrier cluster as a deployment under `armada` namespace. 

This runbook describes how to debug the satellite storage related issues and fix those issues.


## Example Alert(s)

   None

## Investigation and Action


### Must-gather and basic checks
1. Location ID and the Cluster ID
   ```
   ibmcloud sat location ls
   ibmcloud sat service ls --location <location_name>
   ```  
1. Check satellite location health. <br>
   ```
   ibmcloud sat location get --location <location_name>
   ```
   i. check the `location State` it should be  `normal`

1. Check the config template with required version is available.<br>
   ```
   ibmcloud sat storage template ls
   ```

1. Fetch the storage configuration details, one with user having issue.<br>
   ```
   ibmcloud sat storage config ls
   ibmcloud sat storage config get --config <config_name_or_id> --json
   ```

1. Fetch the assignment details for the assignment created for the storage config.<br>
   ```
   ibmcloud sat storage assignment ls
   ibmcloud sat storage assignment get --assignment <assignment_id> --json
   ```

### Possible Common Issues
1. After creating the assignment, the K8S resources are not getting created as per storage template

    **Possible causes:**
    1. Cluster Admin access not provided to the Staellite Config.
    In the assignment detailed output, yout will get the error message something like
        ```
        users “IAM#xyz@abc.com” is forbidden:
        User “system:serviceaccount:razeedeploy:razee-editor” cannot impersonate resource “users” in API group
        ```
        **Solution:** Provide admin access
    https://cloud.ibm.com/docs/satellite?topic=satellite-setup-clusters-satconfig#cluster-admin-access

    1. The assignment might be created for a cluster group and the cluster may not be added to the group.

        **Solution:** Add the cluster to cluster group.


2. CLI command for upgrading Satellite storage configuration and assignment `ibmcloud sat storage config upgrade --config <config_name_or_ID> --include-assignments ` is successful, but K8S resources on the cluster are not upgraded.
    ```
    $ ibmcloud sat storage config upgrade --config test-config --include-assignments
    Are you sure you want to upgrade your storage configuration test-config to use the latest storage template revision? Template revisions, if available, include the latest storage driver patch updates. [y/N]> y
    OK
    Storage configuration test-config was successfully upgraded to the latest storage configuration version.
    ```
    **Solution:**
    - Get storage configuration details using command `ibmcloud sat storage config get --config <config_name_or_ID> --json` and check `config-version` field.
    - Get storage assignment details using command `ibmcloud sat storage assignment get --assignment <assignment_ID> --json` and check `version` field.
    - If both are different, then upgrade the storage assignment explicitely using command `ibmcloud sat storage assignment upgrade --assignment <assignment_ID> -f`



### Template specific checks -
Refer template specific runbooks for the detailed debug steps for each template
1.  [aws ebs and efs csi driver](https://pagesgithub.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-aws-ebs-efs-troubleshooting.html)

2. [redhat local-volume-file and local-volume-block](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-redhat-local-volume-troubleshooting.html)

3. [netapp trident, netapp-ontap-san and netapp-ontap-nas](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-netapp-troubleshooting.html)

4. [redhat odf-local and odf-remote](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/odf-issues.html)

5. [azure-disk-csi-driver](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-azure-troubleshooting.html)

6. [gcp-compute-persistent-disk](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-gcp-disk-troubleshooting.html)


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
