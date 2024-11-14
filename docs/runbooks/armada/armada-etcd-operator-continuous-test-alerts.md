---
layout: default
description: How to resolve etcd operator continuous tests related alerts
title: armada-etcd-operator-continuous-test-alerts - How to resolve etcd operator continuous tests related alerts
service: armada-etcd-operator-continuous-tests
runbook-name: "armada-etcd-operator-continuous-tests - How to resolve etcd operator continuous tests related alerts"
tags:  armada, etcd, etcd-operator, etcd-operator-continuous-tests
link: /armada/armada-etcd-operator-continuous-test-alerts.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `ArmadaDeployEtcdOperatorContinuousTestsFailedInNamespace`| Etcd operator continuous tests failed at least once in the namespace. There could be an issue with etcd-operator in namespace {% raw %}{{ $labels.namespace }}{% endraw %} | [Continuous Test failures](#continuous-failures-tests) |
| `ArmadaDeployEtcdOperatorContinuousTestsFailedInNamespaceMultiple`| Etcd operator continuous tests failed 3 or more times. There could be an issue with etcd-operator in namespace {% raw %}{{ $labels.namespace }}{% endraw %} | [Continuous Test failures](#continuous-failures-tests) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = etcd_operator_continuous_tests_failed_in_namespace_kubx-etcd-18
 - alert_situation = "etcd_operator_continuous_tests_failed_in_namespace_kubx-etcd-18"
 - service = armada-deploy
 - severity = critical
 - namespace= kubx-etcd-18
Annotations:
 - summary = "Etcd operator continuous tests failed at least once in the namespace. There could be an issue with etcd-operator in namespace {% raw %}{{ $labels.namespace }}{% endraw %}"
 - description = "Etcd operator continuous tests failed at least once in the namespace. There could be an issue with etcd-operator in namespace {% raw %}{{ $labels.namespace }}{% endraw %}"
~~~~

## Actions to take

### Continuous Failures Tests
This alert is for continuous tests around etcd-operator in the kubx-etcd-(01-18) namespaces. It will detect problems in specific namespaces. 
A low priority alert will trigger if 3 or more test are failing in a specific namespace or one or more tests have failed.

To debug:

1. Lets check prometheus and see all the failures on the carrier. `kube_job_status_failed{namespace=~"kubx-etcd-.*", exported_job=~"job-etcd-op-cont-.*"} > 0`
    * More info on how to find prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)
    * See if there are any jobs failing in other namespaces and add it to the issue.
    * If only this one namespace is failing continue on to the next steps
1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region..
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert) 
1. Once on the carrier, find the failing jobs pods. 
    ```
    export NAMESPACE=<namespace>
    kubectl get po -n $NAMESPACE -o wide | grep job-
    ```
    
    ~~~~
    kubectl get po -n kubx-etcd-01 -o wide | grep job-
    job-etcd-op-cont-dev-mex01-carrier5-01-1539100800-cphg2           0/1       Completed          0          22h       172.16.54.96     10.130.231.136
    job-etcd-op-cont-dev-mex01-carrier5-01-1539115200-nmtg9           0/1       Completed          0          18h       172.16.40.143    10.131.16.79
    job-etcd-op-cont-dev-mex01-carrier5-01-1539144000-wm2mf           0/1       DeadlineExceeded   0          10h       <none>           10.130.231.132
    ~~~~

1. If there are pods that are **not** `0/1 Completed`. Grab the logs to see what is going on. `kubectl logs -n $NAMESPACE $POD`, add this output to a ticket for investigation.
    * If unable to view logs through `kubectl`, please see this on ways to [show logs without using kubectl](./armada-general-debugging-info.html#view-container-logs-without-kubectl)
1. Once all the information is gathered open an issue against [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}), and ping `@deploy` in `#armada-deploy` on slack. 
1. If there are been three `Completed` jobs after the failure we can consider etcd-operator has hit a stable state. After gathering information delete the job associated to this pod. 
    * To find the job: `kubectl get po -n kubx-etcd-01 job-etcd-op-cont-dev-mex01-carrier5-01-1539144000-wm2mf -o jsonpath='{.metadata.labels.job-name}'`

### Additional Information

More information can be found about our implementation and use of etcd-operator [here](armada-etcd-operator-information.html)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
