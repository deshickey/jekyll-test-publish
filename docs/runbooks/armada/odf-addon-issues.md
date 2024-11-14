---
layout: default
description: This runbook covers the issues with the ODF addon installation
title: odf-addon-odf_addon_issues
service: odf
category: armada
runbook-name: "addon-ocs_addon_issues"
tags: odf, odf-install, addon, managed add-on
link: /armada/odf_addon_issues.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains some useful trouble shooting tips to recover from the issues with ODF addon install.

## Example Alerts

None

## Investigation and Action

- To enable the ODF addon for your ROKS cluster
    - Installing the Red Hat OpenShift Data Foundation add-on from the console
      1. From the OpenShift clusters console, select the cluster for which you want to install the ODF add-on.
      2. On the cluster Overview page, click Add-ons.
      3. On the OpenShift Data Foundation card, input the parameters as required, and click Install.

    - Installing the OpenShift Data Foundation add-on from the CLI
       1. Run the following command to install the ODF add-on :
          `ibmcloud ks cluster addon enable openshift-data-foundation --cluster <cluster_name>` --param "odfDeploy=true"

- To see the information about failed install
    - View the Red Hat OpenShift Data Foundation add-on status
       1. From the console
       2. By listing the add-ons installed on the cluster
          `ibmcloud ks cluster addon ls --cluster <cluster_name>`
    - Check the `health state` and `Health status` of the ODF add-on      

## Issues covered by this runbook.

- ODF add-on installation fails.

  **Error:**
   ```
   "Error: Addon Not Ready (openshift-data-foundation not Running)."
   ```
   **Resolution:**
    1. The above error specifies that some or all of the add-on components are unhealthy.
    2. Use the following command to check if the ODF add-on deployment is running

     ```
     % oc get deploy -n kube-system           
      NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
      ibm-ocs-operator-controller-manager   1/1     1            1           11h
     ```

    3. If the deployment is running, then the add-on status update might be taking time and will get updated to `normal` eventually. The add-on is ready
    for use.

    4. If the `ibm-ocs-operator-controller-manager` deployment is not created on the cluster, then please look at the [LD rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/armada-cruisers/production/addon-openshift-data-foundation) and check if the specified ODF add-on version has been pushed to the region where its being deployed

- No ODF resources created on deploying the add-on

    **Error:**
      `oc get ocscluster` returns no resources

     **Resolution:**
      1. This means that the ocscluster resource was not created on enabling the add-on.
      2. Verify if the user set the value of `odfDeploy` to `false` while enabling the add-on, If so, ask them to disable and re-enable the addon with this value set to `true`
      3. If the user set the value to `true`, perform the following steps :

        a. Check the ibm-ocs-operator pod logs in kube-system namespace
        ```
        % kubectl logs ibm-ocs-operator-controller-manager-xxxx-yyyy -n kube-system    
        ```

        b. In the beginning of the logs, check if there was any error while creating the ocscluster resource
        ```
        I0112 09:57:36.685412       1 request.go:621] Throttling request took 1.015486279s, request: GET:https://172.21.0.1:443/apis/samples.operator.openshift.io/v1?timeout=32s
        2022-01-12T09:57:38.469Z	INFO	controller-runtime.metrics	metrics server is starting to listen	{"addr": ":8080"}
        2022-01-12T09:57:41.648Z	INFO	setup.createCRDFromConfigMap	Configmap not found. Waiting for user to create CR
        ```

        c. Verify if the configmap is present in the kube-system namespace and describe it to verify the value of `odfDeploy` [Should be true]
        ```
        % oc get cm -n kube-system | grep addon
        oc get cm -n kube-system
        NAME                                 DATA   AGE
        managed-addon-options-osc            12     15d
        ```

        d. If configmap is present, then, there might have been a timing issue. Restart the ibm-ocs-operator pod in kube-system namespace
        ```
        % kubectl delete pod ibm-ocs-operator-controller-manager-xxxx-yyyy -n kube-system    
        ```

        e. If configmap is not present, the issue has to be redirected to the armada-deploy team


## Escalation Policy

   For more help in searching the logs, please visit the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) channel.

   If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by
   using the [Alchemy - Containers Tribe - armada-storage](https://ibm.pagerduty.com/escalation_policies#P5B6A9G) PD
   escalation policy.

   If you run across any armada-storage problems during your search, you can open a GHE issue for [armada-storage issues](https://github.ibm.com/alchemy-containers/armada-storage/issues/new/choose).
