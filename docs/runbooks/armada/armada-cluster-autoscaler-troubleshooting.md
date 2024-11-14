---
layout: default
description: How to troubleshoot cluster-autoscaler issues.
title: armada-cluster-autoscaler -  How to debug the issue with cluster-autoscaler 
service: armada-cluster-autoscaler
category: cluster-autoscaler
runbook-name: "How to debug the issue with cluster-autoscaler on IKS or ROKS clusters"
tags: alchemy, armada, kubernetes, kube, kubectl, cluster-autoscaler, CA
link: /armada/armada-cluster-autoscaler-troubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to debug the issue with IBM-IKS-Cluster-Autoscaler.

## Example Alert(s)
None

## Must gather info and triaging issue:
For any issue related to cluster-autoscaler on IKS/ROKS clusters, the customer ticket should have following details:

1. Cluster autoscaler pod details. <br>
	```
	$kubectl get pods -n kube-system | grep cluster-autoscaler
	$kubectl describe pod -n kube-system <cluster-autoscaler pod name>
	```
2. Cluster autoscaler logs at the time of incident. (Note: atleast 4 hours continous logs for RCA) <br>
	```
	$kubectl logs  -n kube-system <cluster-autoscaler pod name>
	```
3. Configmaps <br>
	```
	$kubectl get cm -n kube-system iks-ca-configmap -o yaml
	$kubectl get cm -n kube-system cluster-autoscaler-status -o yaml
	```
4. Enabled Worker-pool details (all the enabled worker-pool) <br>
	```
	$ibmcloud ks worker-pool get -c <cluster-name> --worker-pool <pool name>
	```
5. List of current workers <br>
	```
	$ibmcloud ks workers  -c <cluster-name>
	```
Additional information <br>
6. If cluster-autoscaler pod is restarting continuosly, then collect the below details as well <br>
	```
	$kubectl describe nodes (all the nodes in enabled pool)
	$kubectl get nodes --show-labels
	```
7. If scale-up does not work, then describe output of functional pod stuck in pending state. <br>
	```
	$kubectl describe pod <functional pod name> -n <functional pod namespace>
	```
8. Addon details. <br>
	```
	$ibmcloud ks cluster addon ls -c <cluster-name>
	```

## Image mapping of Cluster-Autoscaler:

Cluster-autoscaler is tightly coupled with Kube version of the cluster, so the version of cluster and cluster autoscaler image tag should always be the same.

Support Addon versions: <br>
- 1.0.5 (default)
- 1.1.0

Below is the mapping of images: <br>

Image name fomat: kubeVersion-addon-version-subtag
| IKS Version | IKS-CA Image Tag            |
| ------------| ----------------------------|
| 1.19        |  1.19.1-105-0 |
| 1.20        |  1.20.0-105-0    |
| 1.21        |  1.21.0-105-0    |
| 1.22        |  1.22.0-105-0         |
| 1.23        |  1.23.0-105-0        |


| Openshift Version | IKS-CA Image Tag           |
| ----------------- | ---------------------------|
| 3.11              |  1.11.0-x |
| 4.7               |  1.20.0-105- 0       |
| 4.8               |  1.21.0-105-0        |
| 4.9               |  1.22.0-105-0        |
| 4.10              | 1.23.0-105-0        |

So if there are issues in the cluster-autoscaler due to mismatch of cluster version and cluster-autoscaler version, then customer has to make sure, both of them are in sync and retry autoscaler operations.

## Investigation and Action

### I. Issues while Addon enablement.

1. **Cluster autoscaler pod not coming up after enabling** 
     Dev/SRE can check that cluster updater is functional and/or check the CU log for errors such as an issue applying the deployment file (I check https://razeedash.oneibmcloud.com/v2/alchemy-containers/clusters/<CLUSTER_ID>/updaterMessages)

2. **Cluster autoscaler pod is struggling to pull the image**
    1. Get the image used by cluster autoscaler.

       `kubectl -n kube-system get deploy ibm-iks-cluster-autoscaler -o yaml`

    2. Check if image is available in the icr.io registry.

       `ibmcloud cr images --include-ibm --restrict ibm | grep <IMAGE> | grep <TAG>`

    3. If image is not available, 
      Err:

       `ibm-iks-cluster-autoscaler-6c8d684475-w7tqf           0/1     ErrImagePull   0          10s`

     Resolution:

       - Ensure cluster version and cluster-autscaler image tag is of same version(ignore the subversion).

       - Ensure the cluster has registry pull secrets in the kube-system namespace.

       - If the keys are in place, check the image is available in registry.

       - If keys , image are available try re-starting the pod i.e delete the autoscaler pod.

       - Try to disable the addon and re-enable.

       - If nothing works, then ask in public channel, specified below.


### II. Cannot enable worker-pool for scaling.

  Resolution:

      - The format in which worker-pool is enabled in `iks-ca-configmap` could be wrong, any extra ',' or <space> might cause issues.

        `kubectl get cm iks-ca-configmap -n kube-system -o yaml `

        sample o/p: ` {"name": "default","minSize": 1,"maxSize": 2,"enabled":false}`

      - Some issues at API end, try checking pod events / logs.

        ```
        $kubectl logs -n kube-system ibm-iks-cluster-autoscaler-<SUFFIX>
        $kubectl describe pod -n kube-system ibm-iks-cluster-autoscaler-<SUFFIX>
        ```


### III. Scale Up does not trigger even when pods are in pending state:

  Resolution:

      - If tainiting is enabled make sure the pods have proper tolerations.

      - Make sure autoscaling is enabled for that worker-pool, by check CA pod events

        `{"name": "default","minSize": 1,"maxSize": 2,"enabled": true}` in iks-ca-configmap [OR]

        ```
        $kubectl get pods -n kube-system | grep autoscaler
        $kubectl describe pod -n kube-system ibm-iks-cluster-autoscaler-<SUFFIX>
        ```

        The iks-ca-configmap or pod events should not have any recent errors. Make sure the configmap annotations looks similar to this.

       ```
        annotations:
          ContainerApiStatus: '{}'
          InvalidSecret: '{}'
          SessionStatus: '{}'
          workerPoolsConfigStatus: '{"1:3:default":"SUCCESS"}'
       ```

      - Check if the worker pool has reached maximum number of nodes.

      - Check the CA pod logs for container-api issues example quota or IAM etc, incase of quota issue please check with SRE team and for all other issues reach out to our public channel.

        `$kubectl logs -n kube-system ibm-iks-cluster-autoscaler-<SUFFIX>`


### IV. Scale down does not trigger even when there is no payload.

  Resolution:

      - Make sure autoscaling is enabled for that worker-pool.

        ` {"name": "default","minSize": 1,"maxSize": 2,"enabled": true}` in iks-ca-configmap

      - Scaling down < 2 nodes is not possible due to ALB pods.

      - Check the CA pod logs for any errors and paste in our public channel.

        `$kubectl logs -n kube-system ibm-iks-cluster-autoscaler-<SUFFIX>`


### V. Issues while addon Disabling:
  Update in slack channel


### VI. Scaling happens even when the addon is disabled

   There are chances that the addon was disabled while a worker-pool was still enabled for scaling.

  Resolution:

      - Re-enable the addon.

      - Enable worker pool which is getting scaled.

      - Disble the worker pool.

      - Disable the addon


### VII. Unable to resize the worker-pool:

  Error: **Cannot resize or rebalance the worker pool because cluster autoscaling is enabled for this worker pool. You can update the iks-ca-configmap configmap to adjust the minimum and maximum sizes for the autoscaler to scale up or down the pool for you. Or if you want to manually resize or rebalance, remove cluster autoscaling for this pool and try again. (Effc0)**


  Resolution:

      - Enable the worker-pool, that needs to be resized, by editing ` workerPoolsConfig.json` secction of configmap

        ```
        $kubectl edit cm iks-ca-configmap -n kube-system
        {"name": "default","minSize": 1,"maxSize": 2,"enabled": true}
        ```

        save the changes and wait for worker pool to get enabled

      - Disbale the same worker-pool

        ` {"name": "default","minSize": 1,"maxSize": 2,"enabled":false}`

      - Retry the resize operation.


### Understanding sections in IKS-CA configmap and resolving errors:

  Each section in iks-ca-config reports errors as various levels. Below are few details about errors reported by the section and possible resolutions.

```
  annotations:
    ContainerApiStatus: '{"":""}'
    InvalidSecret: '{"Config validation":""}'
    SessionStatus: '{"Session":""}'
    workerPoolsConfigStatus: '{"1:3:pool2":"SUCCESS"}'
```

   ContainerApiStatus: Reports all the errors occured while executing container api /armada-api requests.

     Resolution:

        - Possible IAM outage need to wait until the outage is resolved

        - or issues with armada-api / cluster-autoscaler end, report in slack channel


   InvalidSecret: Issues with storage-secret-store secret contents.

      - Either API Key is invalid or missing

      - or other important details are missing.

      please ask customer to check if all the details are valid and report in slack channel.


   SessionStatus: Issues while trying to acquire armada-api session.

     Resolution:

        - Possible IAM outage, need to wait until the outage is resolved.

        - Invalid storage-secret-store secret contents, if everything if good and still issue persists report in slack channel.


   If you still face the issue reach out to us, through our public channel #armada-node-autoscale.

## Escalation Policy

For more help in searching the logs, please visit the [{{site.data.storage.armada-storage.block.name}}]({{site.data.storage.armada-storage.block.link}})  channel.

If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by using the [{{site.data.storage.armada-storage.escalate.name}}]({{site.data.storage.armada-storage.escalate.link}}) PD escalation policy.

If you run across any armada-storage problems during your search, you can open a GHE issue for armada-storage [{{site.data.storage.armada-storage.name}}]({{site.data.storage.armada-storage.issue}}).

## Automation

None
