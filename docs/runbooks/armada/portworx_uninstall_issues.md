---
layout: default
description: This runbook covers the portworx un-installation issues
title: portworx-uninstall-portworx_uninstall_issues
service: portworx
category: armada
runbook-name: "uninstall-portworx_uninstall_issues"
tags: portworx, portworx-uninstall, catalog, portworx enterprise, licence,cleanup
link: /armada/portworx_uninstall_issues.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains some useful trouble shooting tips to recover from the portworx uninstallation issues.

## Example Alerts

None

## Investigation and Action

- To access the portworx services from catalog, click the below link.

   https://cloud.ibm.com/resources
   1. Click on **services** tab to access the installed portworx services.

- How to uninstall the portworx service from the catalog

  1. Open the service list.
  2. Click on the 3 dots next to the service status.
  3. In the opened popup click on delete.

  Clearing the helm chart release from the cluster
  1. Access the cluster from CLI.
  2. Use the following command to see the existing helm release.
  ```
   root@muraliVM1:~/portworx# helm ls
   NAME            NAMESPACE       REVISION        UPDATED                                 STATUS  CHART           APP VERSION
   portworx        default         1               2021-01-20 01:13:29.825491447 +0000 UTC failed  portworx-1.0.22 2.6.1
   root@muraliVM1:~/portworx#`
   ```
    Use the following command to remove the portworx helm release.
   ```
   helm delete portworx
   ```

  Alternately use the following cleanup script

  https://github.com/IBM/ibmcloud-storage-utilities/tree/master/px-utils/px_cleanup


## Issues covered by this runbook

- Failed to delete the helm release from the cluster

  **Error:**
    ```
    "Error: timed out condition "
    ```
  **Resolution:**

    Use the following command to remove the portworx helm release.
   ```
   helm delete portworx
   ```

   Alternately use the following cleanup script

   https://github.com/IBM/ibmcloud-storage-utilities/tree/master/px-utils/px_cleanup


###  NOTE: If  the issue is not listed above or the issue is not resolved, please contact portworx support

   Please access the Portworx Service Portal here:

   https://pure1.purestorage.com/

   You can also reach them by phone at : 1-866-244-7121
   For a complete list of the Pure support phone numbers follow this link https://support.purestorage.com/Pure1/Support
   You can also submit a request via e-mail by mailing to mailto:support@purestorage.com
   
   For the sev1 and critical issues raise the **prodoutage request** and other issues raise problem report


## Escalation Policy

   For more help in searching the logs, please visit the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) channel.

   If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by
   using the [Alchemy - Containers Tribe - armada-storage](https://ibm.pagerduty.com/escalation_policies#P5B6A9G) PD
   escalation policy.

   If you run across any armada-storage problems during your search, you can open a GHE issue for armada-storage [issues].
   (https://github.ibm.com/alchemy-containers/armada-storage/issues/new/choose)
