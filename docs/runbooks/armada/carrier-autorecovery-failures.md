---
layout: default
description: Investigate extended autorecovery action times
title: carrier-autorecovery - investigate timeouts
service: ibm-worker-autorecovery
runbook-name: "carrier-autorecovery - investigating extended action times"
tags: alchemy, armada, bootstrap, autorecovery,
link: /armada/carrier-autorecovery-failures.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

Carrier Autorecovery will alert if a corrective action takes longer than 5 hours to complete. When autorecovery starts a corrective action, it generates a custom resource (`correctiveaction`) in the kube-system namespace with the name : `action-label-<node-ip-address>`. This is how we know how long the corrective action is taking.

Example [PD alert](https://ibm.pagerduty.com/alerts/PFYH2AM)

## Detailed Information
Run the [carrier deploy job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/) with the following parameters:
- `Environment` - the datacenter from the alert, e.g `prod-wdc06`
- `Carrier` - the carrier from the alert, e.g. `carrier1`
- `BRANCH` - set as `master`
- `WORKERS` - leave blank
- `SKIP_WORKERS` - check the box so that it only runs on masters
- `CUSTOM_PLAYBOOK` - use `reset-autorecovery.yml`

This job will check if the correctiveaction is > 5 hrs old. If it is, it will check the node that is listed in the correctiveaction.

The job can take around 10 minutes to run. When it finishes, check the console output and look for the `Get node status` sections (there may be more than one if multiple nodes are being checked):
- If the node is `Ready`, it will delete the correctiveaction, allowing autorecovery to continue.
- If the node is `NotReady` the correctiveaction will not continue and manual intervention is required.

**PLEASE NOTE:**
- The node needing intervention is the one attached to the `action-label` correctiveaction, for eg :  
  `correctiveaction = action-label-10.127.177.189`
- and **NOT** the one attached to the label.  
  `hostname = 10.x.x.x`


### Find where AR is stuck
We need to find which step in the recovery process is preventing the node from being re-added to the cluster in a Ready state. We can check this via [kubectl](#kubectl) cmds, [#bot-chlorine-logging](https://ibm-argonauts.slack.com/archives/CDG1R2D5Y) channel or via prometheus.

#### Prometheus
Login to the appropriate prometheus and run the query for `nurse_correct_carrier_node_count` [example](https://alchemy-dashboard.containers.cloud.ibm.com/prod-che01/carrier5/prometheus/graph?g0.range_input=1h&g0.expr=nurse_correct_carrier_node_count&g0.tab=1).

Take note of `carrier_action_status` and continue to [Fixing Failures](#fixing-failures)

#### Kubectl
`kubectl get correctiveaction -n kube-system -o yaml action-label-<node-ip-address>`


Example output:
~~~~~
kubectl get correctiveaction -n kube-system -o yaml action-label-10.130.231.175

action_request_id: CHG1268158
apiVersion: workerrecovery.stable/v1
carrier_action_status: bootstrap_successful
check_name: worker-config.json
data_ip: 10.130.231.175
data_unique_identifier: "8"
kind: CorrectiveAction
last_fix_timestamp: ""
metadata:
  creationTimestamp: "2021-02-28T14:33:49Z"
  generation: 4
  labels:
    labelSelector: action-label
  managedFields:
  - apiVersion: workerrecovery.stable/v1
    fieldsType: FieldsV1
    fieldsV1:
      f:action_request_id: {}
      f:carrier_action_status: {}
      f:check_name: {}
      f:data_ip: {}
      f:data_unique_identifier: {}
      f:last_fix_timestamp: {}
      f:metadata:
        f:labels:
          .: {}
          f:labelSelector: {}
      f:requested_action: {}
      f:requested_provider_id: {}
    manager: ibm-worker-recovery
    operation: Update
    time: "2021-02-28T14:33:49Z"
  name: action-label-10.130.231.175
  namespace: kube-system
  resourceVersion: "2586929592"
  selfLink: /apis/workerrecovery.stable/v1/namespaces/kube-system/correctiveactions/action-label-10.130.231.175
  uid: 15c78ce0-6378-4ef3-b678-b1fbe30990c4
requested_action: CARRIERRELOAD
requested_provider_id: ibm://///carrier5/dev-mex01-carrier5-worker-30.alchemy.ibm.com
~~~~~

Search in the slack channel [#bot-chlorine-logging](https://ibm-argonauts.slack.com/archives/CDG1R2D5Y) for the full chlorine output


Find the standard-out for the request:
~~~~~
CHG0192926 *carrier autorecovery*: (prod-par01-carrier5-worker-1021) Master, I failed to reload node `prod-par01-carrier5-worker-1021`. Status: adding node to cluster failed. Error is: request to url <url> fail. Error connect: connection timed out, aborting...
~~~~~

#### Other reload failures

Also check if there are any other correctiveaction that are older than 5 hours. The PD shows only one IP, but will not resolve if there are other failures:

~~~~~
kubectl get correctiveaction -n kube-system | grep action
~~~~~

Example output, showing 2 nodes which were attempted 2 days ago and which need to be investigated:

~~~~~
action-label-10.190.96.197                                   7      2d5h
action-label-10.190.96.204                                   7      74m
action-label-10.191.215.21                                   7      2d4h
~~~~~


### Fixing Failures

If the `carrier_action_status` from the above correctiveaction is `bootstrap_failure` `patching_failure` `drain failure` or `deploy_failure` manual steps will need to be taken.

#### Bootstrap Failure
If the `carrier_action_status` is `bootstrap_failure` check the IaaS console for the host to verify the reload was successful. If not, reach out to IaaS for an explanation.

If the reload was successful re-run [alchemy-bootstrap Jenkins Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/alchemy-bootstrap/).

The bootstrap job will bootstrap and patch the worker. Once the worker is done patching you will need to manually deploy the carrier worker. More information on bootstrap can be found here [Bootstrap Info](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bootstrap_contents.html).

#### Patching Failure
If the `carrier_action_status` is `patching_failure` re-run the patching command for the worker `smith-patch <BuildNumber> machines: <machine1> outage:<outage duration>`

Once the patching is completed successfully run the carrier deploy job to redeploy the worker

#### Deploy Failure
If the `carrier_action_status` from the above correctiveaction is `deploy_failure`
Re-run [Carrier Deploy Job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/) for the worker. If the job fails ask in the [armada-runtime channel](https://ibm-argonauts.slack.com/archives/C52JJA0EP) about the failure.

#### Drain Failure
If the carrier_action_status is drain_failure, reboot the node using chlorine bot, adding the flag `ignoredrainerror`. If reboot fails, reload the worker node with the same flag as given above.

#### Error: jenkins add node to bastion timeout
```
Example error: carrier autorecovery: (prod-syd01-carrier2-worker-1022) I failed to add prod-syd01-carrier2-worker-1022 (10.139.48.3) to bastion. Error: jenkins add node to bastion timeout, stop here, URL: https://alchemy-containers-jenkins.swg-devops.com/job/armada-ops/job/bastion-register-nodes-ww/, aborting...
```

 1. Go to this job [bastion-register-nodes-ww](https://alchemy-containers-jenkins.swg-devops.com/job/armada-ops/job/bastion-register-nodes-ww/) and `Build with parameters`

 2. Enter `TARGET_HOSTS_IP` as the node IP(s) which need to be registered to bastion.

 3. Enter `TARGET_HOSTNAME` as one hostname from the same region. Example: if the node region is `prod-wdc06` then pick one of worker of that region ie `prod-wdc04-carrier1-worker-1001`. This is used to figure out which bastion to add the target node to.

 4. Leave `Branch` field unselected, default is `master`

Monitor the output of jenkins job and make sure it is success. If it failes for some reason, open a [conductors team issue](https://github.ibm.com/alchemy-conductors/team/issues) with output of jenkins job and label the issue as `bastion`.

### Cleanup
Once the failures have been corrected, validate the worker is successfully running in the cluster.

The node should return a Ready status and the kube-system pods should be running.
~~~~~
node=<node>
kubectl get node $node
kubectl get pods -n kube-system --field-selector spec.nodeName=$node
~~~~~

If the node is `Ready` and the `kube-system` pods are running, then:
- uncordon the node using  
  `armada-uncordon-node $node`
- and delete the action-label correctiveaction  
  `kubectl delete correctiveaction -n kube-system action-label-$node`

## Escalation Policy
Carrier Autorecovery is owned by the carrier-runtime squad. [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }})
