---
layout: default
title: "Satellite autoresolver client is unhealthy"
type: Troubleshooting
runbook-name: "Satellite autoresolver client is unhealthy"
description: "The satellite autoresolver client running inside the location customer hosts is not reporting properly. Without proper reports from the client the location is marked unhealthy and is disabled from doing operations"
service: Armada-bootstrap
tags: satellite, armada, autoresolver, autoresolver-client, client
link: /satellite/armada-satellite-autoresolver-client-unhealthy.html
grand_parent: Armada Runbooks
parent: Satellite
---

Troubleshooting
{: .label .label-red}

## Overview

**THIS alert should no longer be firing, go directly to [escalation policy](#escalation-policy) if getting this specific alert.**

There is a satellite-autoresolver-client deployment pod that runs inside of the location in the monitoring namespace for every satellite location master. Without proper reports from the client the location is marked unhealthy and is disabled from doing operations. 
[General Satellite runbook](./armada-satellite.html)

**It is important to note, that we have determined the customer hosts to be in a healthy and ready state.** 

**Reference the alert to find the error and where to start in the runbook from the table below**

| Error | Info | Start |
|--
| R0006: The autoresolver has not started running yet. | The autoresolver client running inside the location is not running and has never initialized | [Autoresolver Client Not Running](#r0004-r0006-autoresolver-client-not-running) |
| R0004: The autoresolver on the location control plane hosts took too long to report back to the server. | The autoresolver client running inside the location is not running | [Autoresolver Client Not Running](#r0004-r0006-autoresolver-client-not-running) |
| R0008: Prometheus stopped running, so the autoresolver cannot send alerts for the Satellite location. | Prometheus has stopped running inside the location | [Prometheus Not Running](#r0007r0008-prometheus-not-running) |
| R0007: Waiting for Prometheus to start sending alerts for the Satellite location. | Prometheus has not started sending alerts to the satellite location | [Prometheus Not Running](#r0007r0008-prometheus-not-running) |

## Example Alerts

https://ibm.pagerduty.com/incidents/P1YNR89

~~~~
runbook: https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/satellite/armada-satellite-autoresolver-client-unhealthy.html
previous_pd_incident: N/A        
location_clusterId: bstbh9000jln1cu3mne0
error: R0006: The autoresolver has not started running yet.   
General Satellite Runbook: https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/satellite/armada-satellite.html
~~~~

## Investigation and Action
Follow the table above to know which steps to take

## R0007,R0008 Prometheus Not Running

1. Log onto the hub in the region for the tugboat  
_More info on how to do this step can be found in [armada-general-debugging-info --> finding-the-carrier-to-log-into-from-pagerduty-alert](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_  
_**NB. Ensure that you use a valid tugboat name, which should include hyphens and no "." periods**_
1. Let's first check the overall health of the monitoring stack
    * Export variables. Replace the `<>` values with what is in the alert
      ```sh
      export LOCATION_CLUSTERID=<location_clusterId>
      export MONITORING_PODS=$(kubx-kubectl $LOCATION_CLUSTERID get pod -n monitoring -o wide --no-headers)
      echo "$MONITORING_PODS"
      ```    
    * Make a note for what nodes the `armada-ops-alert-job`/`armada-ops-alertmanager`/`armada-ops-prometheus` pods are scheduled to, if at all.
1. Now let's check to see what node that the monitoring stack should be running on.
   - Let's pull the node name first
      - `NODE_NAME=$(kubx-kubectl $LOCATION_CLUSTERID get cm -n monitoring armada-ops-configmap -o jsonpath='{.data.armada_ops_nfs_zone}'); echo "NODE_NAME=$NODE_NAME"`  
      **if `NODE_NAME` is empty follow [escalation policy](#escalation-policy)!**
      
   - Let's find the node in kube
      - `EXPECTED_NODE=$(kubx-kubectl $LOCATION_CLUSTERID get nodes --show-labels | grep $NODE_NAME); echo "EXPECTED_NODE=$EXPECTED_NODE"`
      
1. Make sure that the monitoring stack pods `armada-ops-alert-job`/`armada-ops-alertmanager`/`armada-ops-prometheus` are on that node.
   - **armada-ops-alert-job**:  
   `kubx-kubectl $LOCATION_CLUSTERID get pods -n monitoring -l job-name=armada-ops-alert-job -o wide`
   
      - the pod needs to be in a `completed` state and on the node the monitoring stack should be running on (`EXPECTED_NODE`)
      - if those are not met, gather more info and follow [escalation policy](#escalation-policy):
         1. `kubx-kubectl $LOCATION_CLUSTERID describe pod -n monitoring -l job-name=armada-ops-alert-job`
         1. `kubx-kubectl $LOCATION_CLUSTERID logs -n monitoring -l job-name=armada-ops-alert-job`
         1. Escalate!
            
    - **armada-ops-prometheus**:  
    `kubx-kubectl $LOCATION_CLUSTERID get pods -n monitoring -l app=armada-ops-prometheus -o wide`
    
       - the pod needs to be in a `running` state and on the node the monitoring stack should be running on (`EXPECTED_NODE`)
       - if those are not met, gather more info and follow [escalation policy](#escalation-policy):
         1. `kubx-kubectl $LOCATION_CLUSTERID describe pod -n monitoring -l app=armada-ops-prometheus`
         1. `kubx-kubectl $LOCATION_CLUSTERID logs -n monitoring -l app=armada-ops-prometheus`
         1. Escalate
            
    - **armada-ops-alertmanager**:  
    `kubx-kubectl $LOCATION_CLUSTERID get pods -n monitoring -l app=armada-ops-alertmanager -o wide`
    
       - the pod needs to be in a `running` state and on the node the monitoring stack should be running on (`EXPECTED_NODE`)
       - if those are not met, gather more info and follow [escalation policy](#escalation-policy)
          1. `kubx-kubectl $LOCATION_CLUSTERID describe pod -n monitoring -l app=armada-ops-alertmanager`
          1. `kubx-kubectl $LOCATION_CLUSTERID logs -n monitoring -l app=armada-ops-alertmanager`
          1. Escalate!

## R0004, R0006 Autoresolver Client Not Running

1. Log onto the hub in the region for the tugboat  
_More info on how to do this step can be found in [armada-general-debugging-info --> finding-the-carrier-to-log-into-from-pagerduty-alert](../armada/armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_  
_**NB. Ensure that you use a valid tugboat name, which should include hyphens and no "." periods**_
    * Export variables. Replace the `<>` values with what is in the alert
      ```sh
      export LOCATION_CLUSTERID=<location_clusterId>
      export TROUBLED_POD=$(kubx-kubectl $LOCATION_CLUSTERID get pod -n monitoring -l app=autoresolver-client --no-headers)
      echo $TROUBLED_POD
      export TROUBLED_POD_ID=$(echo ${TROUBLED_POD} | awk '{print $1}')
      ```
1. If the TROUBLED_POD **is not** in a `Running` state, gather more information on why
    - Describe pod  
    `kubx-kubectl $LOCATION_CLUSTERID describe pod -n monitoring $TROUBLED_POD_ID`
    
    - Get logs (with and without `-p`)  
    `kubx-kubectl $LOCATION_CLUSTERID logs -n monitoring $TROUBLED_POD_ID`
    
    - Delete the pod to see if it comes up...  
    `kubx-kubectl $LOCATION_CLUSTERID delete pod -n monitoring $TROUBLED_POD_ID`
    
    - If unable to get the pod running follow [escalation policy](#escalation-policy).
    - If able to get the pod running, wait ~10 minutes. If alert does not resolve, proceed to next section
1. If the TROUBLED_POD **is** in a running state, lets gather more info
    - Get logs  
    `kubx-kubectl $LOCATION_CLUSTERID logs -n monitoring $TROUBLED_POD_ID`
    
    - Check to see if the satelliteAlert custom resource is there and posting a heartbeat  
    `kubx-kubectl $LOCATION_CLUSTERID get sata -n monitoring autoresolver-client-health -o yaml`  
    _there is a heartbeat field, is the time since last heartbeat >10 minutes?_
    
    - If alert does not resolve after the pod running for ~10 minutes follow [escalation policy](#escalation-policy).

## Escalation Policy

First open an issue against [alert-autoresolver-server](https://github.ibm.com/alchemy-containers/armada-satellite-alert-autoresolver-server/issues/new) with all the debugging steps and information done to get to this point.

Contact the @bootstrap team in the [#armada-bootstrap](https://ibm-argonauts.slack.com/archives/C531WT4AC) channel for help.

Escalate to the armada-bootstrap squad. [Alchemy - Containers Tribe - armada-bootstrap](https://ibm.pagerduty.com/escalation_policies#P42TSXQ)
