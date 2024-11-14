---
layout: default
description: How to solve ha master related alerts
title: armada-ha-cruiser-patrol-master - How to solve ha master related alerts
service: armada-deploy
runbook-name: "armada-ha-cruiser-patrol-master - master failures"
tags:  armada, ha, ha-masters
link: /armada/armada-ha-cruiser-patrol-master.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This runbook contains steps to take when debugging master pods in HA (High Availability) Masters.
**Make sure to note whether the cluster is Openshift4 or not!**
## Example Alerts
IKS/Openshift3
```
Labels:
 - alertname = <deploymentname>_ha_deployment_down_critical
 - alert_situation = <deploymentname>_ha_deployment_down_critical
 - service = armada-deploy
 - severity = critical
 - cluster_id = xxxxxxxxxxx
Annotations:
 - namespace = kubx-masters
```
Openshift4
```
labels:
 - alert_name = <deploymentname>__ha_deployment_down_unhealthy_long_openshift4
 - alert_situation = <deploymentname>_ha_deployment_down_unhealthy_long_openshift4
 - service = armada-deploy 
 - severity = critical
 - cluster_id = xxxxxxxxxxx
annotations:
 - namespace = master-xxxxxxxxxxx
```


### Before starting

For **tugboat** alerts, please consult this runbook: [How to access tugboats](./armada-tugboats.html#access-the-tugboats)  
_**NB.** Tugboats have a **carrier** number greater or equal to 100!_

**If this alert is triggering `high_percentage_cruiser_master_deployments_no_replicas_available` then follow this runbook
[high_percentage_high_availability_cluster_master_critical](armada-deploy-high-percentage-high-availability-cluster-master-critical.html), instead as it takes priority!**

If there are multiple clusters (e.g. more than 10) in trouble, it might be caused by some base infrastructure issues in the environment.

Run [analyze-bad-node-from-pagerduty](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/analyze-bad-node-from-pagerduty/) to analyze which worker nodes the issues come from

- For each node associated with not ready master pods, check its status. If the node is not ready, try hard reboot firstly. If nodes cannot be recovered or master pods are not recovered after reboot, try reload.
- If issues distribute across multiple nodes, and all nodes are ready, consider it's vyatta issue.
- Get the worker node ip from the output of [analyze-bad-node-from-pagerduty](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/analyze-bad-node-from-pagerduty/). Check gateway before a specific worker by using the netmax bot in slack.
    ```
    @nextmax 10.171.78.122
    prod-dal10-carrier2-worker-1030 (Virtual Server) - Dallas 10:02 - Acct531277
    Public: 169.46.30.142 169.46.30.128/26 (Prod/Carrier2) (1527 (fcr02a.dal10))
    Private: 10.171.78.122 10.171.78.64/26 (Prod/Carrier2) (879 (bcr02a.dal10))
    OS: UBUNTU_18_64
    Tags: imageid:5959464
    Gateway: prod-dal10-firewall-vyattaha0
    ```

    **!!! Get approval from Ralph before reboot Vyattas !!!**

    Check in slack channel #netint-status-updates to ensure the specific vyatta ha pair is not rebooting. Reboot the vyatta using following command in slack channel #sre-cfs. If the bot can not work, use [Das-reboot jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Network-Intelligence/job/Network-Intelligence/job/Das-reboot/)
    ```
    @netmax reboot prod-dal10-firewall-vyattaha0 via ssh
    ```

If alerts are still unresolved, follow below instructions to investigate each cluster one by one.

### Initial diagnosis via a Jenkins job
**Please note if cluster is on a Satellite location or a Carrier/Tugboat**
1. Run [get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/):

    - This can be done using the `Victory` bot in slack:

        1. `@victory analyze-cluster <clusterid>`
            - The above command will kick off a get-master-info job for the given cluster id and attempt to run some basic diagnostics on the results.
            - Please note the job takes on average 10-15 minutes to return and the analysis can take another 10-15 minutes after that.
        1. `IF` `Victory` bot is down:
            - The job can also be kicked off manually if needed.
            - Run [armada-deploy-get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) with the desired cluster id and leave all other parameters at their default values.

1. `IF` analyze-cluster was run from Victory and the analysis returned
    1. Check the results under `Scanning armada-deploy-get-master-info Jenkins job logs for runbook recommendations...` for any runbook recommendations.
        - If a specific runbook was returned, follow the link to the instructions provided.
        - Also check the output for open GHE issues at the bottom of the message.
    1. If no runbook recommendations or open GHE issues found, the results of the get-master-info job are available in the thread with your original query. Continue to [Investigation and action](#investigation-and-action).

1. `ELSE` if you have get-master-info results and no analysis from Victory
    1. Run the following using the `Victory` bot in slack:
        - `@victory analyze-master-info <gmi_jenkins_job_url>`
    1. `IF` Victory returns a runbook recommenation, follow the link to the instructions provided.
    1. `ELSE` Continue to [Investigation and action](#investigation-and-action).

**NOTE:** If Victory bot is offline or unresponsive, all runbooks normally available to the bot are found in the [armada-deploy gh-pages](https://pages.github.ibm.com/alchemy-containers/armada-deploy/index.html). The runbooks specific for get-master-info are available under the heading `Runbooks for searching the get-master-info results`.
## Investigation and Action

**Note for patrols the steps are the same but there is only one master pod**

1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region and then [invoke-tugboat](./armada-tugboats.html).  
_More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_

1. Check the master pod(s) as described below [check masters](#check-masters)

   1. If at least **one** master pod is running check [kubectl commands](#check-kubectl-commands-status) below.
      - If `kubectl` commands **are** running then try to recover the master by restarting the pod [restart pod](#actions-to-take).
      - If `kubectl` commands don't work continue to the next step
   
   1. If no masters are up, create a GHE issue in [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}), include any info gathered on the masters and put it into the issue, then escalate immediately [escalation policy](#escalation-policy)

2. Check the status of `etcdctl` commands to see if `etcd` is healthy [etcd commands](#check-etcdctl-commands). Check to see how many `etcd` pods are up, if not all pods are up a recovery is needed. To recover etcd pods use this runbook [etcd recovery run book](./armada-cluster-etcd-unhealthy.html)

### Check Masters

1. Set up the proper cluster id and namespace variables. 
   
   If the alert is for an IKS or Openshift3 cluster, the namespace should be kux-masters.
   
   **For IKS/Openshift3 clusters**
   ~~~
   export NAMESPACE=kubx-masters
   ~~~ 
   
   If the alert is for an Openshift4 cluster, the namespace should be `master-<clusterid>`.
  
    **For Openshift 4 clusters**
   ~~~ 
   export NAMESPACE=master-<clusterid>
   ~~~

2. Check the master pods

    ~~~~
    export CLUSTER_ID=<clusterid>
    kubectl get pods -n $NAMESPACE | grep -E "master-$CLUSTER_ID|kube-|openshift-|cloud-"
    ~~~~

    ~~~~
    kubectl get pods -n $NAMESPACE | grep -E "master-3aeb4818ee4743cbb993aa2eb0a3074f|kube-|openshift-|cloud-"

    cluster-updater-3aeb4818ee4743cbb993aa2eb0a3074f-679879674sldr9   1/1       Running            0          4d
    master-3aeb4818ee4743cbb993aa2eb0a3074f-546f79dd56-bf8nw          3/4       CrashLoopBackOff   399        4d
    master-3aeb4818ee4743cbb993aa2eb0a3074f-546f79dd56-lfrv4          3/4       CrashLoopBackOff   400        4d
    master-3aeb4818ee4743cbb993aa2eb0a3074f-546f79dd56-tdq4v          3/4       Running            402        4d
    openvpnserver-3aeb4818ee4743cbb993aa2eb0a3074f-8767b6b8b-xcdhp    1/1       Running            0          1d
    ~~~~

    In this example all of the masters pods are in a bad state.
    Try [restarting the bad master pods](./armada-ha-cruiser-patrol-master.html#restart-the-bad-master-pods) if no further investigation is required, else continue below.

3. Are the Control plane pods in ImagePullBackoff or CreateContainerError?
​
   ```
   pod/cluster-policy-controller-c57979db4-rd69r     0/1     ImagePullBackOff            0     139m   172.18.85.204    10.74.253.133   <none>           <none>
   pod/kube-apiserver-6b8fb9d456-mvt6m               0/3     Init:ImagePullBackOff       0     138m   172.18.85.216    10.74.253.133   <none>           <none>
   pod/cluster-version-operator-b574b9bdd-4htn2      1/2     CreateContainerError        0     101m   172.18.16.153    10.209.189.26   <none>           <none>
   pod/cluster-version-operator-dc6957b54-fv2tt      0/2     Init:CreateContainerError   0     102m   172.18.67.248    10.73.232.149   <none>           <none>
   ```

   If you see control plane pods in one of those states, this might be due to a CRIO problem that results in missing image / container overlay directories and is fixed by reloading the node.  We have premium support case open with Red Hat - see [tracking issue](https://github.ibm.com/alchemy-containers/kubernetes-pipeline/issues/5592).
   
   - This situation should be limited to a small number of nodes at any given time. `IF` you see wide-spread image pull problems, or consistent failures with a specific image, `THEN` skip the rest of this step.  That would indicate a different problem and we don't want to be reloading a lot of nodes.
   - See if someone has already started a reload since the time of the issue you are investigating. Since a reload drains the pods, if you are looking at an old list of pods you might find that new pods are healthy.
   - `IF` a reload has not already been started `THEN` reload the problem worker node.
   - `IF` this is associated with a Master Operation failure (deploy, refresh_update, etc), `THEN` after the drain has completed - i.e. node is cordoned and the pod(s) have been deleted - retrigger the failed operation. You should be done with this runbook.
   - `IF` this not a failed Master Operation, `THEN` the control plane should recover and the alert resolve once the drain has completed - i.e. node is cordoned and the pod(s) have been deleted.


4. Describe master pods that are in a bad state

    ~~~~
    export MASTER_POD=<master_pod>
    kubectl describe pod -n $NAMESPACE $MASTER_POD
    ~~~~

    Make a copy of the events section

    ~~~~
    kubectl describe pods -n $NAMESPACE master-3aeb4818ee4743cbb993aa2eb0a3074f-546f79dd56-bf8nw
    ...
    Events:
      Type     Reason      Age                  From                     Message
      ----     ------      ----                 ----                     -------
      Normal   Pulled      46m (x389 over 1d)   kubelet, 10.130.231.211  Container image "registry.ng.bluemix.net/armada-master/hyperkube-amd64:armada_18-207-v1.8.15-base" already present on machine
      Warning  BackOff     11m (x9150 over 1d)  kubelet, 10.130.231.211  Back-off restarting failed container
      Warning  FailedSync  1m (x9189 over 1d)   kubelet, 10.130.231.211  Error syncing pod

    ~~~~

    In this example a container failed

    Identify the failed container (scroll up in the pod description)

    ~~~~
    apiserver:
        Container ID:  docker://878a33aa8427d94a83fa1b54ed5d554841b4afe89ef83975027ada211495d7bc
        ...
        State:          Waiting
          Reason:       CrashLoopBackOff
        Last State:     Terminated
          Reason:       Error
          Exit Code:    255
          Started:      Mon, 30 Jul 2018 20:11:31 0000
          Finished:     Mon, 30 Jul 2018 20:12:18 0000
        Ready:          False
    ~~~~

    For this master it was the apiserver
5. Look up logs for the failed container

    ~~~~
    export CONTAINER=<container>
    kubectl logs -n $NAMESPACE $MASTER_POD -p -c $CONTAINER
    ~~~~

    ~~~~
    kubectl logs -n $NAMESPACE master-3aeb4818ee4743cbb993aa2eb0a3074f-546f79dd56-tdq4v -p -c apiserver
    ...
    k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/server/filters.WithMaxInFlightLimit.func1(0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /go/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/server/filters/maxinflight.go:167 0x6b8
    net/http.HandlerFunc.ServeHTTP(0xc427f6df40, 0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /usr/local/go/src/net/http/server.go:1942 0x44
    k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/endpoints/filters.WithImpersonation.func1(0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /go/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/endpoints/filters/impersonation.go:49 0x21b2
    net/http.HandlerFunc.ServeHTTP(0xc4219d2320, 0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /usr/local/go/src/net/http/server.go:1942 0x44
    k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/endpoints/filters.WithAuthentication.func1(0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /go/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/endpoints/filters/authentication.go:79 0x2b0
    net/http.HandlerFunc.ServeHTTP(0xc4219d2370, 0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /usr/local/go/src/net/http/server.go:1942 0x44
    k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/endpoints/request.WithRequestContext.func1(0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /go/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/endpoints/request/requestcontext.go:110 0xef
    net/http.HandlerFunc.ServeHTTP(0xc4269c0620, 0x2ae938b58528, 0xc4281ce648, 0xc42849f800)
        /usr/local/go/src/net/http/server.go:1942 0x44
    k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/server/filters.(*timeoutHandler).ServeHTTP.func1(0xc4269c06a0, 0x9ba3680, 0xc4281ce648, 0xc42849f800, 0xc4250ff440)
        /go/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/server/filters/timeout.go:106 0x8d
    created by k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/server/filters.(*timeoutHandler).ServeHTTP
        /go/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/apiserver/pkg/server/filters/timeout.go:108 0x1ca

    logging error output: "k8s\x00\n\f\n\x02v1\x12\x06Status\x12\xb6\x03\n\x06\n\x00\x12\x00\x1a\x00\x12\aFailure\x1a\xc9\x01Unable to refresh the initializer configuration: Get https://127.0.0.1:1000/apis/admissionregistration.k8s.io/v1alpha1/initializerconfigurations: dial tcp 127.0.0.1:1000: getsockopt: connection refused\"\x14LoadingConfiguration*\xbd\x01\n\x06create\x12\x00\x1a\nnamespaces\"\xa0\x01\n\x1fInitializerConfigurationFailure\x12{An error has occurred while refreshing the initializer configuration, no resources can be created until a refresh succeeds.\x1a\x00(\x012\x000\xf4\x03\x1a\x00\"\x00"
     [[hyperkube/v1.8.15IKS (linux/amd64) kubernetes/59b9933] 127.0.0.1:54826]
    E0730 20:29:55.248117       1 client_ca_hook.go:78] Unable to refresh the initializer configuration: Get https://127.0.0.1:1000/apis/admissionregistration.k8s.io/v1alpha1/initializerconfigurations: dial tcp 127.0.0.1:1000: getsockopt: connection refused
    F0730 20:29:55.248134       1 hooks.go:133] PostStartHook "ca-registration" failed: unable to initialize client CA configmap: timed out waiting for the condition
    ~~~~

    Save the output of the log for the ticket

    Check on a specific worker by using the `Victory` bot in slack

    `@victory validate-worker <carrier worker node ip>`

    Victory will validate your worker nodes and return a status

    ~~~~
    @victory validate-worker 10.131.16.55

    HMS Victory APP [2:56 PM]
    Verifying that `10.131.16.55` is a functional worker node. Just a second!

    All vital worker services are found to be up and running on: dev-mex01-carrier5-worker-06.alchemy.ibm.com
    ~~~~
    
### Check kubectl commands status

on the Carrier run

~~~~
export CLUSTER_ID=<cluster id>
kubx-kubectl $CLUSTER_ID get nodes
~~~~

~~~~
kubx-kubectl 3aeb4818ee4743cbb993aa2eb0a3074f get nodes
Unable to connect to the server: dial tcp 169.57.40.183:22703: i/o timeout
~~~~
Save status of the kubectl command

### check etcdctl commands
check the status of the etcd pods

~~~~
export CLUSTER_ID=<cluster id>
kubectl get pods --all-namespaces | grep etcd-$CLUSTER_ID
~~~~

~~~~
kubectl get pods --all-namespaces | grep etcd-4b7bc74866fe478dbe14405caed850c1
kubx-etcd-05    etcd-4b7bc74866fe478dbe14405caed850c1-69br9pf59f                  1/1       Running             0          3h
kubx-etcd-05    etcd-4b7bc74866fe478dbe14405caed850c1-sm9bglkwv7                  1/1       Running             0          3h
kubx-etcd-05    etcd-4b7bc74866fe478dbe14405caed850c1-zvl62c7c9z                  1/1       Running             0          3h
~~~~
Make a note of which namespace the etcd pods are in

Run a test etcdctl command against one of the pods

**CAUTION DO NOT MODIFY THIS COMMAND it is a readonly command, but changing the command in any way could break ETCD**

~~~~
export POD_ID=<podID>
export NAMESPACE=<namespace>
kubectl exec $POD_ID -n $NAMESPACE -- /bin/sh -ec "ETCDCTL_API=3 etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt get foo"
~~~~

~~~~
kubectl exec etcd-4b7bc74866fe478dbe14405caed850c1-zvl62c7c9z -n kubx-etcd-05 -- /bin/sh -ec "ETCDCTL_API=3 etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt get foo"
~~~~

If nothing is returned then the command was successful.

## Actions to take

##### IKS/Openshift3
###### Restart the bad master pods
If etcd pods are down or etcdtl commands are not working follow this etcd specific run book [etcd recovery run book](./armada-cluster-etcd-unhealthy.html)

1. Set up the proper cluster id and namespace variables once again. 
   
   If the alert is for an IKS or Openshift3 cluster, the namespace should be kux-masters.
   
   **For IKS/Openshift3 clusters**
   ~~~
   export NAMESPACE=kubx-masters
   ~~~ 
   
   If the alert is for an Openshift4 cluster, the namespace should be `master-<clusterid>`.
  
    **For Openshift 4 clusters**
   ~~~ 
   export NAMESPACE=master-<clusterid>
   ~~~
2. Before starting, take note of the nodes that the master pods are on.  
_The problem could lie with the node, so this is important info to make note of before continuing._  
`kubectl get pods -n $NAMESPACE -o wide | grep -E "master-$CLUSTER_ID|kube-|openshift-|openvpn-|cloud-"`

3. Delete the bad pod or pods - though we must do this **one at a time!**  
_Deleting the pod may not resolve the issue, so we must focus on getting a single pod Running first._

    ~~~ sh
    export POD_ID=<podID>
    export NODE=$(kubectl get po -n $NAMESPACE -o wide | grep $POD_ID | awk '{print $7}')
    kubectl delete pod $POD_ID -n $NAMESPACE
    ~~~

4. Wait a minute or so and check if the newly created pod is Running.  
_Again, take note of which node that new master was created on._  
`kubectl get pods -n $NAMESPACE -o wide | grep -E "master-$CLUSTER_ID|kube-|openshift-|oauth-|cloud-"`

5. Checking the result of the pod:
   - **Running and on the same node**  
   Great, it seems there are no issues with the pod or the worker node that it lives on.  
   **The alert should resolve, and no further action is required.**
   
   - **Running but on a different node**  
   Good, it seems there are no issues with the pod and the alert should resolve.  
   However, the **node** may have issues, therefore...  
   **Check other master pods running on that node.**  
   `kubectl get pods -n $NAMESPACE -o wide | grep $NODE`
    
     Restart this runbook for any other master deployments with issues. You may also want to:  
     - consult the [node-troubled](./armada-carrier-node-troubled.html) rb for further troubleshooting of the suspect node
     - [reload the node](./armada-carrier-node-troubled.html#reloading-worker-node)

   - **Not Running and on the same node?**  
   There are problems here, so continue below
   
   1. Cordon the node the pod is on and delete the pod. This will prevent the new pod from being recreated on the same node.

       ~~~ sh
       kubectl cordon node $NODE
       kubectl delete pod $POD_ID -n $NAMESPACE
       ~~~
    
    1. Wait a minute and check the status of the newly created master (see above).
    
    1. Is the pod Running and on a new node?  
    Great, the alert should resolve.  
    **Check other master pods running on that node (see above)**

6. If these steps have not resolved the issue, see [escalation policy](#escalation-policy)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up including all information collection during the steps above.
