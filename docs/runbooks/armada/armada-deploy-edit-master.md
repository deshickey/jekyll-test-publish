---
layout: default
title: Manually editing a cluster master deployment
type: Informational
runbook-name: "Manually editing a cluster master deployment"
description: How to edit a cluster master deployment
category: armada
service: armada-deploy
tags: alchemy, armada, kubernetes, cluster-master
link: /armada/armada-deploy-edit-master.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to edit a cluster master deployment for
approved manual customizations of cluster masters.

## Detailed Information

The following sections document how to customize a cluster master deployment,
e.g. the the Kubernetes `master-xxxx` `deployment` resource for a cluster.

If you are customizing an ICD cluster (the only known use of this), you should
be able to use the `armada-update-patch-icd-cluster` Jenkins job described in the
[armada-update-patch-icd-cluster job](#armada-update-patch-icd-cluster-job) section.
Later sections describe how to make these changes via `kubectl edit` and can
be used if you are more comfortable with that approach or are concerned that the
script did not work properly.

**NOTES:**

1. When using `kubectl edit`, you will get `vim` (aka `vi`) by default.
It is possible to use an alternate edit, e.g. `nano`, by using this
form of the `kubectl edit` command:<br>
`KUBE_EDITOR=nano kubectl -n kubx-masters edit deployment master-xxxx`

1. In general, such changes do not survive patch updates, upgrades, etc, and must be redone after such operations.
However, the patch update process has code to handle these special cases.

### armada-update-patch-icd-cluster job
**Note:** To run this job for a cluster its cluster-id must first be added to [armada-update-patch-icd-cluster](https://github.ibm.com/alchemy-containers/pd-tools/blob/master/allowlist-jenkins/armada-update-patch-icd-cluster.txt). 
Ping `@jmcmeek` or `@rtheis` to review and merge the PR for ICD clusters.

There is a Jenkins [armada-update-patch-icd-cluster job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-update-patch-icd-cluster/)
that automates checking or setting the master apiserver options that ICD modifies.
It support these apiserver options:
```
--service-account-lookup=
--default-not-ready-toleration-seconds=
--default-unreachable-toleration-seconds=
```

To run this job you need to provide:
- The CLUSTER (cluster id)
- The ACTION (show, patch, or reset)

The job will determine the carrier or tugboat hosting the cluster.

`show` displays the current values for the related apiserver options.

`patch` sets the values as requested by ICD:
```
--service-account-lookup=false
--default-not-ready-toleration-seconds=43200
--default-unreachable-toleration-seconds=43200
```

`reset` restores the values to the standard cluster values:
```
--service-account-lookup=true
--default-not-ready-toleration-seconds=600
--default-unreachable-toleration-seconds=600
```

The `patch` and `reset` actions modify the master deployment spec, then wait for the
rolling update to finish.

If the job is successful all should be good, but we recommend checking the console output
to make sure an unexpected error did not escape undetected.

If the job fails review the console output and the remainder of this document for possible solutions.

Successful output for patching an ICD cluster will look like:
```
----------------------------------------------------------------

Patching cluster to use
        - --service-account-lookup=false
        - --default-not-ready-toleration-seconds=43200
        - --default-unreachable-toleration-seconds=43200
deployment.extensions/master-bo51e6nd0ska4jvhha00 configured
Waiting for rollout to complete (checks every 60 secs)...
Waiting for deployment "master-bo51e6nd0ska4jvhha00" rollout to finish: 0 out of 3 new replicas have been updated...

[some output skipped]

deployment "master-bo51e6nd0ska4jvhha00" successfully rolled out
$ ssh-agent -k
unset SSH_AUTH_SOCK;
unset SSH_AGENT_PID;
echo Agent pid 370 killed;
[ssh-agent] Stopped.
Finished: SUCCESS
```

### Disable apiserver Service Account Lookup (for ICD)

This section describes how to change or add the `--service-account-lookup` parameter
to the `apiserver` in the cluster master.

1. Get the current value of the `service-account-lookup` parameter:

  `CLUSTERID=xxxx`<br>
  `kubectl -n kubx-masters describe deployment master-$CLUSTERID | grep "\--service-account-lookup="`

  For clusters at 1.14 and later the parameter should be present, but we ship it
  with the value `true`.

  If the desired value for ICD - `--service-account-lookup=false` - is already present
  you are done.

1. Edit the deployment master.  This uses `vim` (aka `vi`) as its editor.<br>
`CLUSTERID=xxxx`<br>
`kubectl -n kubx-masters edit deployment master-$CLUSTERID`

1. Search for `- apiserver`.  You should find yourself in a section looking like this:<br>
```
  - command:
    - /hyperkube
    - apiserver
    - --service-account-lookup=true
    - --default-not-ready-toleration-seconds=600
    - --default-unreachable-toleration-seconds=600
    - --bind-address=0.0.0.0
```

1. Insert this line after `- apiserver`, aligning the text with the rest of the command,
or change the value from `true` to `false`:<br>
```
         - --service-account-lookup=false
```

1. Save the deployment by saving the editor buffer and exiting the editor.

1. Monitor the deployment pods to be sure you did not introduce an error:<br>
`kubectl -n kubx-masters get pod -l app=master-$CLUSTERID`

1. Once you have seen one pod updated, you can wait for the update to roll out to
all pods using:<br>
`kubectl -n kubx-masters rollout status deployment/master-$CLUSTERID`

### Change apiserver default toleration seconds (for ICD)

This section describes how to change or add these parameters for the `apiserver`
in the cluster master:
```
--default-not-ready-toleration-seconds={{ default_not_ready_toleration_seconds }}
--default-unreachable-toleration-seconds={{ default_unreachable_toleration_seconds }}
```

ICD would like these values changed to `43200` (12 hours).

A forthcoming BOM (January 2020 patches) will persist this change across master updates.
Until the cluster master is updated to those BOMs, a change will be reverted by
a patch update, apiserver refresh, etc.

1. Get the current value of the parameters:

  `CLUSTERID=xxxx`<br>
  `kubectl -n kubx-masters describe deployment master-$CLUSTERID | grep "\-toleration-seconds="`

  This should return these lines:
  ```
  --default-not-ready-toleration-seconds=600
  --default-unreachable-toleration-seconds=600
  ```

  If the values are `43200` you are done. Exit this runbook.

1. Edit the deployment master.  This uses `vim` (aka `vi`) as its editor.<br>
`CLUSTERID=xxxx`<br>
`kubectl -n kubx-masters edit deployment master-$CLUSTERID`

1. Search for `- apiserver`.  You should find yourself in a section looking like this:<br>
```
  - command:
    - /hyperkube
    - apiserver
    - --service-account-lookup=true
    - --default-not-ready-toleration-seconds=600
    - --default-unreachable-toleration-seconds=600
    - --bind-address=0.0.0.0
```

1. Look for `--default-not-ready-toleration-seconds=`.
Our default value is `600` seconds. Change it to `43200`.

1. Look for `--default-unreachable-toleration-seconds=` (ought to be the next line).
Our default value is `600` seconds. Change it to `43200`.

1. Save the deployment by saving the editor buffer and exiting.

1. Monitor the deployment pods to be sure you did not introduce an error:<br>
`kubectl -n kubx-masters get pod -l app=master-$CLUSTERID`

1. Once you have seen one pod updated, you can wait for the update to roll out to
all pods using:<br>
`kubectl -n kubx-masters rollout status deployment/master-$CLUSTERID`

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
