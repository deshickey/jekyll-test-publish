---
layout: default
description: Procedure to debug armada-satellite-storage netapp template issues.
title: armada-storage -  Procedure to debug armada-satellite-storage netapp template issues.
service: armada-storage, satellite-storage
runbook-name: "armada - armada-satellite-storage netapp-trident, netapp-ontap-nas and netapp-ontap-san issues."
tags: armada, satellite, armada-satellite-storage, armada-satellite, armada-storage, armada-storage-api, satellite-templates, configuration, assignment, subscription
link: /armada/armada-sat-storage-netapp-troubleshooting.html
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

This runbook describes how to debug issues related to satellite storage templates - 'netapp-trident, netapp-ontap-nas and netapp-ontap-san' and fix those issues.

Please refer to the template specific readme for assignment creation / template install steps -
https://github.com/IBM/ibm-satellite-storage/tree/develop/config-templates


## Example Alert(s)

   None

## Investigation and Action

### install issues

1. Trident pod stuck in `ContainerCreating` status <br>

    1. Describe the trident deployments by running below command and review the command output.<br>
    `oc describe deployment trident -n trident `

    2. Describe the trident pod by running below command and review the command output.<br>
    `oc describe pod trident-xxx-xxx -n trident `

    3. You can also use tridentctl, Trident's binary tool, to obtain logs and pinpoint the source of the problem. You can download tridentctl from Trident's GitHub repo - https://github.com/NetApp/trident/releases, for the appropriate version of Trident. <br>
    Run the following command and look for problems in the logs for the trident-main and CSI containers.
    `tridentctl logs -l all -n trident`

    4. Retrieve the logs for trident pods and check for any error messages.
    `oc logs trident-xxx-xxx`

### Troubleshooting netapp-ontap-san

[netapp-ontap-san runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-netapp-ontap-san-troubleshooting.html)


### Troubleshooting netapp-ontap-nas

[netapp-ontap-nas runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-sat-storage-netapp-ontap-nas-troubleshooting.html)


### Debug checks for common expected issues
(pvc issues, volume mount issues etc)


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
