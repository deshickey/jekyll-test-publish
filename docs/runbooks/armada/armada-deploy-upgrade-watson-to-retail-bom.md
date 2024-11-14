---
layout: default
description: Procedure for upgrading a cluster from Watson to retail BOM
title: "armada-deploy: Upgrade cluster from Watson to Retail BOM"
runbook-name: "armada-deploy: Upgrade cluster from Watson to Retail BOM"
service: armada-deploy
tags: armada-deploy, cruiser, master, watson, retail, BOM
link: /armada/armada-deploy-upgrade-watson-to-retail-bom.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

This runbook details the operations procedure for upgrading a cluster master
from a Watson 1.10 BOM to a retail 1.12 BOM.

## Detailed Information

Before going further you **MUST** have permission from Rober K. Steinhilber (@rsteinhi),
Ketan Jani (@ketanjani), or Watson management to upgrade a Watson cluster.
Also, Surya Penumatcha (@surya.penumatcha) is able to approve, but only for the following clusters:

```txt
01184860e7f949858455c16dba568a71
dce71c3859cc41b589a3df52134e3322
24164dfe5c7842c98de431e53b6111d9
51e64e742f674320909c55488c3332c1    
91bc05bcb83c4e7693c775e8c8adcd82
```

Furthermore, this process is **ONLY** approved from upgrading the cluster
master from a Watson 1.10 BOM to a retail 1.12 BOM.

For examples of this procedure in action, see [armada-update issue 604](https://github.ibm.com/alchemy-containers/armada-update/issues/604).

## Detailed Procedure

Skip to Automation section for jenkins job. Below are manual steps.

1. One of the Watson approvers list above opens a [GHE issue](https://github.ibm.com/alchemy-conductors/team/issues/new)
   containing the `ClusterID` of the cluster to upgrade and a link to this
   runbook. Once opened, the Watson team sends a message to `!oncall` on the
   [#conductors](https://ibm-argonauts.slack.com/messages/C54H08JSK) slack
   channel. The conductor handing the request must ensure the GHE issue was
   opened by a valid Watson approver before continuing.

1. Get the `published_ansible_bom_version`
   1. Go to [armada-ansible-bom-1.12.yml](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/common/bom/armada-ansible-bom-1.12.yml)
   and search for `published_ansible_bom_version` to get the latest retail 1.12
   BOM version.
   1. **Ensure the version found is documented** at [Version 1.12 changelog](https://cloud.ibm.com/docs/containers?topic=containers-changelog#112_changelog).  
   **If not documented**:  
      - send a message to `@update` on the
   [#armada-update](https://ibm-argonauts.slack.com/messages/C6WTRUSCB) slack
   channel asking for the latest retail 1.12 BOM available in production.

1. Use `@xo cluster <ClusterID>` to get the cluster's `Region`, `ActualMasterID`s
   (there should only be one) and `ActualDatacenterCluster`.

1. Obtain prod-train approval to complete the upgrade on behalf of Watson.

1. Log into the carrier master for `ActualDatacenterCluster` and run the
   following commands. Ensure that `DesiredAnsibleBomVersion` is for
   a Watson 1.10 BOM before changing the value to the latest retail 1.12 BOM.

   ```shell
   armada-data get Master -pathvar MasterID=<MasterID> -field DesiredAnsibleBomVersion
   armada-data set Master -field DesiredAnsibleBomVersion -value <published_ansible_bom_version> -pathvar MasterID=<MasterID>
   armada-data get Master -pathvar MasterID=<MasterID> -field DesiredAnsibleBomVersion
   ```

1. Use `@victory logs <ClusterID>` and `@xo master <MasterID>` to monitor the
   upgrade. Eventually `@victory` should indicate the upgrade was successful
   and `@xo` should show `AnsibleBomVersion` equal to `DesiredAnsibleBomVersion`
   and `published_ansible_bom_version`. If the upgrade fails, a PD alert should
   be generated with further instructions on how to resolve.

1. Notify the Watson team that the master upgrade is complete and that they may
   now upgrade their worker nodes.

## Automation

Jenkins job: https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Jenkins/job/Watson_Cluster_Upgrades/

## Escalation Policy

For general questions or problems with this runbook, create a GHE issue in the
[armada-update](https://github.ibm.com/alchemy-containers/armada-update/issues)
repository.

For cluster upgrade problems escalate directly to the squad by using the
armada-deploy PD [escalation policy](https://ibm.pagerduty.com/escalation_policies#PT2ZIIQ).
