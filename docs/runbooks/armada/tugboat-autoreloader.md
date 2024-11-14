---
layout: default
description: "Tugboat Auto Reloader Information"
title: "Tugboat Auto Reloader Information"
runbook-name: Tugboat Auto Reloader Information"
service: armada
tags: armada, tugboat, auto-reload, tugboat-automation
link: /armada/tugboat-autoreloadeer.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
Contains info for managing the tugboat auto reloader and ensuring workers are up to date

## Detailed Information

### Disable all tugboat automation
1. Run [update-jenkins-jobs](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/update-jenkins-jobs/) with paramaters
```
branch_update: disable-all-tugboat-automation
JOB_NAME: all
```
1. disable the above job, so that any pushes to master do not re-enable the jobs you have disabled
1. browse the following folders [auto-reloads](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/automated-worker-reloads/) and [auto-replaces](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/automated-worker-replaces/). Make sure all jobs are disabled. Manually disable any that are not. New tugboats are not auto added to `disable-all-tugboat-automation`, so they may be skipped
1. When you are ready to re enable, run [update-jenkins-jobs](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/update-jenkins-jobs/) with paramaters
```
branch_update: master
JOB_NAME: all
```

### Change frequency of automation job
Frequency of the jobs are on a per tugboat basis. Each job has its own frequency.
1. Navigate to the jjb for the respective [automated-worker-replace](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/automated-worker-replaces/) or [automated-worker-reload](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/automated-worker-reloads/) job
1. Search for the line `<parameterizedSpecification>H/`, and update the number following `/`. This number dicates the number of minutes between jobs
1. Merge changes to master, which should trigger [this job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/tugboat/job/tugboat/job/update-jenkins-jobs/), which will update the jenkins job.

### Change number of concurrent auto reloads
Automation is only enabled only when all workers in a cluster are healthy. Concurrent reloads are enabled only when the automation is working on a customer-workload worker pool in an MZR cluster. All other reloads are max 1 at a time.
1. Update `CONCURRENT_RELOAD_LIMIT` in [utils.sh](https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/utils.sh#L5)
1. Merge to master
1. Automation jobs use master branch so changes are picked up automatically

### Check how many workers still need to update to specific version
Run the following script to check how many workers are not up to date
```
clusters=$(ibmcloud ks clusters --json | jq -r .[].name)
for elem in ${clusters[@]}
do
  total=$(ibmcloud ks workers -c $elem --json | jq '[.[] | select(.kubeVersion!=.targetVersion)] | length')
  if [ $total -gt 0 ]; then
    echo $elem
    echo $total
    echo "****"
  fi
done
```
Jenkins implementation is in the works. See [this branch](https://github.ibm.com/alchemy-containers/armada-cruiser-automated-recovery/tree/check-version) for details

## Escalation Policy

- @interrupt in #conductors
