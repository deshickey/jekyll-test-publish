---
layout: default
description: How to resolve invalid bootstrap metadata alerts
title: armada-bootstrap-metadata-alert - How to resolve invalid bootstrap metadata alerts
service: armada-bootstrap
runbook-name: "armada-bootstrap-metadata-alert - How to resolve invalid bootstrap metadata alerts"
tags:  armada, armada-bootstrap
link: /armada/armada-bootstrap-metadata-alert.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This runbook contains steps to take when debugging bootstrap metadata alerts

## Example Alert(s)

~~~~
labels:
  alert_key: armada-infra/armada-bootstrap-metadata-alert
  alert_situation: armada_bootstrap_metadata_alert
  service: armada-bootstrap
  severity: warning
annotations:
  description: Armada bootstrap metadata alert firing
~~~~

## Actions to take

1. Get the list of worker ids that are having problems...
Access LogDNA via the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) and navigate to the `CLUSTER-SQUAD` -> `ErrorUnreconciledBootstrapMetadata` view. This will provide you with the reason code and worker id(s) experiencing the issue.

2. For each worker id, trigger a build of this jenkins job: https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/bootstrap-metadata-job/ . Make sure
WORKERID is the worker ID and that you select the proper region the worker is in. This can be found using `@xo worker WORKERID`

3. If the job completes successfully (green) that means the alert has successfully been handled. These alerts do still have to be resolved manually though so go ahead and click `Resolved` to resolve it.

4. If the job does not complete successfully, double check that you entered the workerid and region correct. If you have and it still failed see the Escalation section.


## Escalation Policy
First open an issue against [armada-bootstrap](https://github.ibm.com/alchemy-containers/armada-bootstrap) with all the debugging steps and information done to get to this point.

Please follow the [escalation guidelines](./armada-bootstrap-collect-info-before-escalation.html) to engage the bootstrap development squads.
