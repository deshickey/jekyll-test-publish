---
layout: default
title: armada-deploy - Etcd operator component down
type: Troubleshooting
runbook-name: "armada-deploy - Etcd operator component down"
description: "armada-deploy - Etcd operator component down"
service: armada
link: /armada/armada-deploy-etcd-operator-component-down.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# HA Master Etcd Operator Component Down runbook

## Overview

This alert fires when a etcd operator component (backup-operator, restore-operator, or etcd-operator) has no available replicas for an extended period of time. If these components are down for an extended period of time, it can impact management of etcd clusters for the
customer clusters. For example, if the backup operator is down backups of customer data will not be able to occur until the operator is in `Running` state again. The restore operator handles restoring the etcd cluster from a backup in failure scenarios. Etcd operator handles
provisioning new etcd clusters and also handles monitoring the health state of existing etcd clusters.

| Alert_Situation | Info | Start |
|--
| `EtcdOperatorComponentDown`| Etcd-operator component deployment in namespace has had no available replicas for 10 minutes | [actions-to-take](#investigation-and-action) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = deployment_xxxx_down
 - alert_situation =deployment_xxxx_down
 - service = armada-deploy
 - severity = critical
 - namespace = kubx-etcd-xx
 - deployment = deployment_xxxx
~~~~

## Investigation and Action

In the alerts section pull the following values:

1. `deployment`
1. `namespace`

### Check Etcd Component Pods
1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region..
    * More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert) 
1. check to see if any of the etcd component pods are in running state with the following command subbing the labels pulled from above in the `<>` below.
    ~~~~
    export NAMESPACE=<namespace>
    export DEPLOYMENT_NAME=<deployment>
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME
    ~~~~
* example:
    ~~~~
    NAMESPACE=kubx-etcd-18
    DEPLOYMENT_NAME=etcd-operator
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME
    etcd-operator-ff9f7d45c-4xp9z                                     1/1       Running            15         20d
    ~~~~
2. If there is a running pod that is in ready state, this alert will auto-resolve and can be ignored. <br>
An example of a pod not in ready state is shown below
    ~~~~
    etcd-operator-ff9f7d45c-qw2v7                                     0/1       CrashLoopBackOff   105          1d
    ~~~~
3. Check the logs of the `haproxy` container inside the `etcd-operator` pods. If you see errors similar to the following, run the [update-restore-operator-cert](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/update-restore-operator-cert/) Jenkins job to correct the issue. If the job completes successfully, the PD alert should auto-resolve within 15 minutes. If these errors do not appear in the `haproxy` logs, or if the alert does not auto-resolve after running the Jenkins job, continue to the next step.
    ~~~~
    [ALERT] 340/163702 (1) : parsing [/usr/local/etc/haproxy/haproxy.conf:25] : 'bind :19999' : unable to load SSL certificate file '/usr/local/haproxycerts/tlsinfo.pem' file does not exist.
    [ALERT] 340/163702 (1) : Error(s) found in configuration file : /usr/local/etc/haproxy/haproxy.conf
    [ALERT] 340/163702 (1) : Fatal errors found in configuration.    
    ~~~~
4. Before moving onto [Etcd Component Pod is not in running state](#etcd-component-pod-is-not-in-running-state) please gather logs using the following commands first and add them to a new issue in [armada-deploy](https://github.ibm.com/alchemy-containers/armada-deploy-squad/issues) titled "ETCD operator component failure: NAMESPACE DEPLOYMENT_NAME"
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME  |  awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000 -p > initial-pod-$NAMESPACE-$DEPLOYMENT_NAME-previouslogs.txt
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME  |  awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000  > initial-pod-$NAMESPACE-$DEPLOYMENT_NAME-currentlogs.txt
    ~~~~
* example. Title: "ETCD operator component failure: kubx-etcd-18 etcd-operator"
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000 -p > initial-pod-$NAMESPACE-$DEPLOYMENT_NAME-previouslogs.txt
    cat initial-pod-$NAMESPACE-$DEPLOYMENT_NAME-previouslogs.txt
        time="2018-07-28T20:18:41Z" level=info msg="etcd-operator Version: 0.9.2+git"
        time="2018-07-28T20:18:41Z" level=info msg="Git SHA: 56ac36f"
        time="2018-07-28T20:18:41Z" level=info msg="Go Version: go1.10"
        time="2018-07-28T20:18:41Z" level=info msg="Go OS/Arch: linux/amd64"
        time="2018-07-28T20:18:59Z" level=info msg="Event(v1.ObjectReference{Kind:\"Endpoints\", Namespace:\"kubx-etcd-18\", Name:\"etcd-operator\", UID:\"61f5e9f0-6360-11e8-b964-0689a6c6ce3a\", APIVersion:\"v1\", ResourceVersion:\"330538044\", FieldPath:\"\"}): type: 'Normal' reason: 'LeaderElection' etcd-operator-ff9f7d45c-qgc9t became leader"
        time="2018-07-28T20:18:59Z" level=warning msg="fail to handle event: ignore failed cluster (etcd-operator-continuous-tests-dev-18). Please delete its CR" pkg=controller
        time="2018-07-28T20:19:01Z" level=info msg="start running..." cluster-name=etcd-8d9bbb558eb84c559202bcddffddbea9 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-52895a98133c4d9c9e1499856e6885c6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-ecef9e714f78404a8018422807ceb9f6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-66e750157039418eb065e4f0d4a5bf9a pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-654feeaf59d74703856058e9214f0e62 pkg=cluster
        ...
    NAMESPACE=kubx-etcd-18
    DEPLOYMENT_NAME=etcd-operator
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000  > initial-pod-$NAMESPACE-$DEPLOYMENT_NAME-currentlogs.txt
    cat initial-pod-$NAMESPACE-$DEPLOYMENT_NAME-currentlogs.txt
        time="2018-07-28T20:18:41Z" level=info msg="etcd-operator Version: 0.9.2+git"
        time="2018-07-28T20:18:41Z" level=info msg="Git SHA: 56ac36f"
        time="2018-07-28T20:18:41Z" level=info msg="Go Version: go1.10"
        time="2018-07-28T20:18:41Z" level=info msg="Go OS/Arch: linux/amd64"
        time="2018-07-28T20:18:59Z" level=info msg="Event(v1.ObjectReference{Kind:\"Endpoints\", Namespace:\"kubx-etcd-18\", Name:\"etcd-operator\", UID:\"61f5e9f0-6360-11e8-b964-0689a6c6ce3a\", APIVersion:\"v1\", ResourceVersion:\"330538044\", FieldPath:\"\"}): type: 'Normal' reason: 'LeaderElection' etcd-operator-ff9f7d45c-qgc9t became leader"
        time="2018-07-28T20:18:59Z" level=warning msg="fail to handle event: ignore failed cluster (etcd-operator-continuous-tests-dev-18). Please delete its CR" pkg=controller
        time="2018-07-28T20:19:01Z" level=info msg="start running..." cluster-name=etcd-8d9bbb558eb84c559202bcddffddbea9 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-52895a98133c4d9c9e1499856e6885c6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-ecef9e714f78404a8018422807ceb9f6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-66e750157039418eb065e4f0d4a5bf9a pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-654feeaf59d74703856058e9214f0e62 pkg=cluster
        ...
    ~~~~

### Etcd Component Pod is not in running state
1. If the pod is not in ready state, try to delete the pod and let it re-spin up to see if that will resolve the problem. That will be done by deleting the pod and waiting for a new one to spin up (commands below)
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME | awk '{print $1}' > podtodelete  && cat podtodelete
    ~~~~
* example
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME | awk '{print $1}' > podtodelete  && cat podtodelete
    etcd-operator-ff9f7d45c-qw2v7
    ~~~~
2. ASSERT That the above command only has pods associated with this deployment (should all have the the deployment label as the start of the pod name. Using the example, notice how the pod starts with `etcd-operator`. If it does not, the deployment label was not substituted in properly.
* If the output looks right, proceed to delete the pod with the following command    
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME | awk '{print $1}' > podtodelete && kubectl -n $NAMESPACE delete pod --grace-period=1 $(cat podtodelete) && rm podtodelete
    ~~~~ 
* Example:  
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME | awk '{print $1}' > podtodelete && kubectl -n $NAMESPACE delete pod --grace-period=1 $(cat podtodelete) && rm podtodelete
    pod "etcd-operator-ff9f7d45c-qw2v7" deleted
    ~~~~
* Now that the pod is deleted  wait for the pod to come back up by running the following command every 10 seconds for 4 minutes.  
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME
    ~~~~ 
* example:  
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME
    etcd-operator-ff9f7d45c-qgc9t                                     1/1       Running            0          1m
    ~~~~  
3. In the example above, the pod went back to `Running` state and is `1/1 Ready`. That means that the pod is Running and the alert should resolve itself the next time prometheus scrapes for available replicas (happens about every 5 minutes). Continue to monitor periodically to ensure it stays in `Running` state till the alert resolves.
4. If deleting the pod does not resolve the situation, gather logs on the new pod.
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000 -p > restarted-pod-$NAMESPACE-$DEPLOYMENT_NAME-previouslogs.txt
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000  > restarted-pod-$NAMESPACE-$DEPLOYMENT_NAME-currentlogs.txt
    ~~~~  
* example:
    ~~~~
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000 -p > restarted-pod-$NAMESPACE-$DEPLOYMENT_NAME-previouslogs.txt
    cat restarted-pod-$NAMESPACE-$DEPLOYMENT_NAME-previouslogs.txt
        time="2018-07-28T20:18:41Z" level=info msg="etcd-operator Version: 0.9.2+git"
        time="2018-07-28T20:18:41Z" level=info msg="Git SHA: 56ac36f"
        time="2018-07-28T20:18:41Z" level=info msg="Go Version: go1.10"
        time="2018-07-28T20:18:41Z" level=info msg="Go OS/Arch: linux/amd64"
        time="2018-07-28T20:18:59Z" level=info msg="Event(v1.ObjectReference{Kind:\"Endpoints\", Namespace:\"kubx-etcd-18\", Name:\"etcd-operator\", UID:\"61f5e9f0-6360-11e8-b964-0689a6c6ce3a\", APIVersion:\"v1\", ResourceVersion:\"330538044\", FieldPath:\"\"}): type: 'Normal' reason: 'LeaderElection' etcd-operator-ff9f7d45c-qgc9t became leader"
        time="2018-07-28T20:18:59Z" level=warning msg="fail to handle event: ignore failed cluster (etcd-operator-continuous-tests-dev-18). Please delete its CR" pkg=controller
        time="2018-07-28T20:19:01Z" level=info msg="start running..." cluster-name=etcd-8d9bbb558eb84c559202bcddffddbea9 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-52895a98133c4d9c9e1499856e6885c6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-ecef9e714f78404a8018422807ceb9f6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-66e750157039418eb065e4f0d4a5bf9a pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-654feeaf59d74703856058e9214f0e62 pkg=cluster
        ...
    kubectl get pods -n $NAMESPACE | grep $DEPLOYMENT_NAME | awk '{print $1}' > podforlogs && kubectl -n $NAMESPACE logs $(cat podforlogs) --tail=4000  > restarted-pod-$NAMESPACE-$DEPLOYMENT_NAME-currentlogs.txt
    cat restarted-pod-$NAMESPACE-$DEPLOYMENT_NAME-currentlogs.txt
        time="2018-07-28T20:18:41Z" level=info msg="etcd-operator Version: 0.9.2+git"
        time="2018-07-28T20:18:41Z" level=info msg="Git SHA: 56ac36f"
        time="2018-07-28T20:18:41Z" level=info msg="Go Version: go1.10"
        time="2018-07-28T20:18:41Z" level=info msg="Go OS/Arch: linux/amd64"
        time="2018-07-28T20:18:59Z" level=info msg="Event(v1.ObjectReference{Kind:\"Endpoints\", Namespace:\"kubx-etcd-18\", Name:\"etcd-operator\", UID:\"61f5e9f0-6360-11e8-b964-0689a6c6ce3a\", APIVersion:\"v1\", ResourceVersion:\"330538044\", FieldPath:\"\"}): type: 'Normal' reason: 'LeaderElection' etcd-operator-ff9f7d45c-qgc9t became leader"
        time="2018-07-28T20:18:59Z" level=warning msg="fail to handle event: ignore failed cluster (etcd-operator-continuous-tests-dev-18). Please delete its CR" pkg=controller
        time="2018-07-28T20:19:01Z" level=info msg="start running..." cluster-name=etcd-8d9bbb558eb84c559202bcddffddbea9 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-52895a98133c4d9c9e1499856e6885c6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-ecef9e714f78404a8018422807ceb9f6 pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-66e750157039418eb065e4f0d4a5bf9a pkg=cluster
        time="2018-07-28T20:19:02Z" level=info msg="start running..." cluster-name=etcd-654feeaf59d74703856058e9214f0e62 pkg=cluster
        ...
    ~~~~

5. Add them to the same issue you opened up previously and state that these logs are from after you deleted the initial pod. Link the issue in the armada-deploy Slack channel when escalating if restarting the pod did not fix the alert.

### Additional Information

More information can be found about our implementation and use of etcd-operator [here](armada-etcd-operator-information.html)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
