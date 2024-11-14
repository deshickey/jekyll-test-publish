---
layout: default
description: How to resolve etcd cluster defrag related alerts
title: armada-etcd-defrag-failing - How to resolve etcd cluster defrag related alerts
service: armada-etcd-defrag-failing
runbook-name: "armada-etcd-defrag-failing"
tags:  armada, etcd, defrag
link: /armada/armada-etcd-defrag-failing.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `ArmadaEtcdDefragHasNotRunInAWeek` | The armada etcd defrag cronjob has not successfully ran in a week | [weekly-defrag](#failed-weekly-etcd-defrag) |
| `armada_etcd_defrag_failed` | The armada etcd auto defrag failed for a member | [auto-defrag](#auto-defrag-failed) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~text
Labels:
 - alertname = armada_etcd_defrag_has_not_run_in_week
 - alert_situation = armada_etcd_defrag_has_not_run_in_week
 - service = armada-etcd
 - severity = warning
 - namespace = armada
Annotations:
 - summary = "The armada etcd defrag cronjob has not successfully ran in a week."
 - description = "The armada etcd defrag cronjob has not successfully ran in a week."
~~~~

Armada etcd defrags should be taken every week per region.  You can see the current defrag cron job
status using the [Get ETCD Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-info/).
Search the logs for section "DEFRAG"

## Actions to take

### Failed Weekly Etcd Defrag

This means that the etcd defrag job for the armada etcd cluster did not complete

To debug:

1. Find and login into the tugboat (carrier100+) having issues. To access a tugboat you can find detailed instructions here: [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats).

1. Look to see the cron job status
   `kubectl get cronjob -n armada armada-tugboat-etcd-defrag`

   ~~~bash
    kubectl get cronjob -n armada armada-tugboat-etcd-defrag
    NAME                         SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
    armada-tugboat-etcd-defrag   0 8 * * 0   False     0        3d16h           2y231d
   ~~~

The LAST SCHEDULE should be less than 7 days.

1. Look to see the failed jobs that have been happening
   `kubectl get job -n armada | grep armada-tugboat-etcd-defrag`

   ~~~bash
    kubectl get job -n armada | grep armada-tugboat-etcd-defrag
    armada-tugboat-etcd-defrag-1589184000        0/1           11h        11h
   ~~~

Where the column names are `NAME`, `COMPLETIONS`, `DURATION`, and `AGE`. The failed job will show as 0/1 in the `COMPLETIONS` column.

1. Try and find the failed pod, where job name is retrieved from the previous step.
    `kubectl get pods -n armada -l job-name=$JOB_NAME`

    ~~~bash
    kubectl get pods -n armada -l job-name=armada-tugboat-etcd-defrag-1589184000
    NAME                                          READY   STATUS      RESTARTS   AGE
    armada-tugboat-etcd-defrag-1589184000-9q2br   0/2     DeadlineExceeded   0          11h
    armada-tugboat-etcd-defrag-1589184000-lqjbn   0/2     DeadlineExceeded   0          10h
    ~~~

1. Grab the pod logs, where job name is retrieved from the previous step. You need to specify that you want the logs from the `-c armada-tugboat-etcd-defrag` container.
   `kubectl logs -n armada -l job-name=$JOB_NAME -c armada-tugboat-etcd-defrag`

1. If there aren't any immediately obvious and fixable errors then create an issue and wait until the Devs come back online to page out to determine next steps. [escalate](#escalation-policy)

#### Run a manual etcd defrag

1. After escalation to Ballast squad, a manual etcd defrag may be required.  The ballast squad will ask a conductor to run these steps if needed.

1. Targeting the tugboat run the command `kubectl create -n armada job manual-defrag-$(date +%s) --from=cronjob/armada-tugboat-etcd-defrag`

1. Verify the defrag job ran successfully `kubectl get pods -n armada | grep manual-defrag` example output: ```kubectl get pods -n armada | grep manual-defrag
manual-defrag-1605037683-m9djb                    0/1     Completed                    0          4m44s```

1. Delete the manual defrag job when it is done `kubectl delete job -n armada <manual-defrag-1605037683>`

### Auto Defrag Failed

This means that the automatic etcd defrag failed for a member of the etcd cluster.  The reason is given in the metric.

To debug:

1. Confirm the member name
   `kubectl -n armada get etcdcluster -o yaml`
   Look for the **status.DefragStatus.LastDefragFailedMember** to see the member name that failed.

1. Review the `Carrier Etcd` dashboard for any issues with the member.

1. Review the etcd operator logs for any issues with the etcd cluster.
   `kubectl -n armada logs -l name=etcd-operator --tail=-1`

### Additional Information

More information can be found about our implementation and use of etcd-operator [here](armada-etcd-operator-information.html)

The [Get ETCD Info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-info/) can be run to see more detailed information about the etcd cluster.

## Escalation Policy

First open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.
