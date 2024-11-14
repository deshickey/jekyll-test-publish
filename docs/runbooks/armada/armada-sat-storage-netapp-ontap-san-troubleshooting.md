---
layout: default
description: Procedure to debug armada-satellite-storage netapp template issues.
title: armada-storage -  Procedure to debug armada-satellite-storage netapp-ontap-san template issues.
service: armada-storage, satellite-storage
runbook-name: "armada - armada-satellite-storage netapp-trident, netapp-ontap-san and netapp-ontap-san issues."
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/armada-sat-storage-netapp-ontap-san-troubleshooting.html
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

This runbook describes how to debug issues related to satellite storage templates - 'netapp-ontap-san' and fix those issues.

Please refer to the template specific readme for assignment creation / template install steps - <br>
https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates/netapp/netapp-ontap-san/21.04#creating-the-netapp-ontap-san-driver-storage-configuration


## Example Alert(s)

   None

## Investigation and Action

Please refer this [link](https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates/netapp/netapp-ontap-san/21.04#prerequisites) for the pre-requisites of netapp ontap san driver deploy on satellite cluster.

### install issues

1. Check weather all the template specific Remote resources got created on creating the assignment.<br>
   Run below command and verify all the respective remote resources got created and are up and running.
   
   ```
   $ oc -n trident get all  | grep 'trident-kubectl-san'
   pod/trident-kubectl-san                 1/1     Running   0          48s
   ```
   ```
   $ oc get sc | grep 'ntap-block'
   ntap-block-bronze    csi.trident.netapp.io          Delete          Immediate              false                  2m36s
   ntap-block-gold      csi.trident.netapp.io          Delete          Immediate              false                  2m37s
   ntap-block-silver    csi.trident.netapp.io          Delete          Immediate              false                  2m37s
   ntap-block-default    csi.trident.netapp.io         Delete          Immediate              false                  2m37s
   ```
   

### Debug checks for common expected issues 

1. PVC creation failure -<br>
If PVC creation fails, complete the following troubleshooting steps
    1. Rreview the input parameters values and verify the managementLIF, dataLIF, svm, username, password. Gete the logs of the trident-kubectl-san POD's log.
    ```
    oc -n trident logs trident-kubectl-san
    ```
    
2. To recreate your configuration, complete the following steps.
   1. Delete the assignment by running command `ibmcloud sat storage assignment rm --assignment <assignmnet name>`
   2. Delete the configuration by running command `ibmcloud sat storage config rm --config <config name>`
   3. Recreate the configuration with the correct parameters and recreate the assignment.
   
3. For the functionality specific issues follow the provider links for more debug steps

    *NetApp docs*: https://netapp-trident.readthedocs.io/en/stable-v21.04/kubernetes/operations/tasks/backends/ontap/ontap-san/index.html
    
    *Netapp Support*:  https://netapp-trident.readthedocs.io/en/stable-v21.04/support/support.html
    
### uninstall issues

  

### Must Gather tool for armada-storage-api - TODO

1. Pull the cluster KUBECONFIG
   ```
   ibmcloud ks cluster config -c <cluster_name/cluster_id> --admin
   ```
2. Clone the must gather repo   
`git clone <repo_link>`
    
3. Follow the readme as below to run the must gather tool
   https://<repo_link>


### Other issues and recovery


## Escalation Policy
If you have any problems with the above steps, feel free to talk to anyone from the [#armada-storage](https://ibm-argonauts.slack.com/archives/C53P14PFE) on Slack.
