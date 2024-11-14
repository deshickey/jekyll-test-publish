---
layout: default
description: This runbook covers the issues with the Openshift AI addon installation
title: openshiftai-addon-openshiftai_addon_issues
service: openshift-ai
category: armada
runbook-name: openshiftai_addon_issues"
tags: rhoai, openshiftai-install, addon, managed add-on
link: /armada/openshiftai_addon_issues.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains some useful troubleshooting tips to recover from the issues with Openshift AI addon install.

## Example Alerts

None

## Investigation and Action

- To see the information about failed install
    - View the OpenShift AI add-on status
       1. From the console
       2. By listing the add-ons installed on the cluster
          `ibmcloud ks cluster addon ls --cluster <cluster_name>`
    - Check the `health state` and `Health status` of the openshift-ai add-on

## Issues covered by this runbook.

- Openshift add-on installation fails.

  **Error:**
   ```
   "Error: Not Ready or Critical in addon helath status."
   ```
   **Resolution:**
    1. The above error specifies that some or all of the add-on components are unhealthy.
    2. Use the following command to check if the openshift-ai add-on deployment is running

     ```
     % oc get deploy -n ibm-rhoai-operato
      ❯ oc get deploy -n ibm-rhoai-operator
        NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
        ibm-rhoai-operator   3/3     3            3           44h
     ```

    3. If the deployment is running, then the add-on status update might be taking time and will get updated to `normal` eventually. The add-on is ready
    for use.

    4. If the deployment is running, and the add-on is not ready for more than 30 mins, then run the following command and look for error conditions in status and events.
    ```
    oc describe oc describe ibmopenshiftai ibmopenshiftai-auto
    ```


    5. If the `ibm-rhoai-operator` deployment is not created on the cluster, then please look at the [LD rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/armada-cruisers/production/addon-openshift-ai) and check if the specified openshift-ai add-on version has been pushed to the region where its being deployed

- No resources created on deploying the add-on and addon getting into critical state

    **Error:**
      `oc get ibmopenshiftai ibmopenshiftai-auto` returns no resources
      `oc get deploy -n ibm-rhoai-operator` returns no resource.

     **Resolution:**
      This means that the cluster updater could not apply the add-on to the cluster.


        Check the razeedash for updater log. Provide the correct cluster id in razeedash and see if any error is shown there.
        razeedash: https://razeedash.containers.cloud.ibm.com/v2/alchemy-containers/clusters/<cluster-id>/updaterMessages

- After waiting for 30 mins since the add-on was enabled and you observe `datascience cluster is not ready` for more than 30 mins

    **Error:**
        `oc describe oc describe ibmopenshiftai ibmopenshiftai-auto` datascience cluster is not ready

    **Resolution**
    This means that some of the resources were not created for redhat openshift ai operator

    `oc describe subs -n redhat-ods-operator` look for errors in conditions.

- In operator log if see the

    **Errors:**
    1. `nodes are not on same worker version.` : make sure all the nodes in the cluster are at the same version.
    2. `cluster version is less than required value: <ROKS-version>`: make sure that the cluster is supported for the addon version you are enabling for. The required value can be seen in the log as mentioned.


## Escalation Policy

For more help, please ping in #armada-rhoai slack channel.

To open an issue against the openshif-ai addon team, please visit [addon-openshift-ai](https://github.ibm.com/alchemy-containers/addon-openshift-ai/issues)