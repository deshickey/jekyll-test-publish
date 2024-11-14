---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Investigating carrier configuration"
type: Informational
runbook-name: "armada-secure-configuration"
description: "Investigating issues with carrier configuration."
service: Razee
tags: razee, armada
link: /armada/armada-secure-configuration.html
failure: ""
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

---
## Overview
The armada-secure [repository](https://github.ibm.com/alchemy-containers/armada-secure/) contains operational configuration for all carriers.
Its deployment is controlled by a set of LaunchDarkly rules managed through [razeeflags](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-secure).
Stage and production deployments are regulated by train requests which can be reviewed under **Recent Requests**.


## Detailed Information
The following examples demonstrate diagnosing an issue with dev-mex01-carrier5. To diagnose any other carrier,
use the razeedash clusters view to find it first by [searching](https://razeedash.oneibmcloud.com/v2/alchemy-containers/clusters?q=dev-mex%20carrier).

### Identifying the configuration version on a specific carrier
1. Open the razeedash resources [view](https://razeedash.oneibmcloud.com/v2/alchemy-containers/clusters/db52c361-c015-5c58-a9d6-ccb71c655299/resources).
1. Note the **Configuration** version on the far right.
1. Click the link to go to the deployed github commit level.

### Identifying issues with applying configuration
1. Open the **Updater messages** tab for the [carrier](https://razeedash.oneibmcloud.com/v2/alchemy-containers/clusters/db52c361-c015-5c58-a9d6-ccb71c655299/updaterMessages).
1. Review any messages posted there by cluster-updater for errors applying configuration to the cluster.
1. Check  the running version on the carrier having problems against the version running on other carriers without issues.

### Identifying configuration changes in a given deployment
1. Review the **Recent Requests** table of the armada-secure [rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-secure) page.
1. Note any recent deployments that may have introduced issues in the problematic carrier.
1. Select the comparison link from the **Changes** column to see the difference between what was previously deployed on the carrier and what is currently deployed.


1. Log into the Bluemix [console](http://console.bluemix.net) with the <conductors id> and find the service in the *Services* table.
1. Ensure that the buckets exist and contain objects. If not, escalate to the appropriate armada team.
1. Ensure you can ping the endpoint at `s3-api.us-geo.objectstorage.softlayer.net`. If not [escalate](#escalation-policy).

## Escalation Policy
Contact the @razee-pipeline team in the [#razee](https://ibm-argonauts.slack.com/messages/C5X987RU0/) channel for assistance in identifying .
Page `Alchemy - Containers Tribe - Pipeline` for assistance with assistance diagnosing configuration inconsistencies and identifying the team(s) needed to troubleshoot the issue.
