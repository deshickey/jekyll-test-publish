---
layout: default
description: Armada-Kedge is unable to retrieve valid key for a user
title: armada-kedge - Access Key Retrieval Failure
service: armada
runbook-name: "armada-kedge - Access Key Retrieval Failure"
tags: armada, kedge, logging, monitoring, carrier, metrics, cruiser, customer
link: /armada/armada-kedge-access-key-failure.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Armada Kedge Access Key Failure

## Overview
- The purpose of this runbook is to provide a user with the steps to get and use a valid access key, for either a LogDNA or Sysdig deployment.

## Example alert(s)
- None

## Investigation and Action

- ### LogDNA

   While running: `ibmcloud ob logging config create --cluster CLUSTER --instance INSTANCE`

   If the user received the error message:

   - Cannot find instance's ingestion key for resource key list, from the resource controller

   - Could not query resource keys for the provided instance, from the resource controller. Please wait a few minutes and try again. If you still encounter this problem, note the incident ID and contact IBM Cloud support.

   - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Log-Analysis-with-LogDNA?topic=LogDNA-ingestion_key">here for grabbing an ingestion key</a>

   - Once they have their ingestion key they can run: \
   `ibmcloud ob logging config create --cluster CLUSTER --instance INSTANCE --logdna-ingestion-key KEY`

  If the user successfully ran:  
   `ibmcloud ob logging config create --cluster CLUSTER --instance INSTANCE`
    - Ask them to verify that it is a key error by checking their pod logs
      ```
      kubectl get pods -n "ibm-observe"
      NAME                 READY   STATUS    RESTARTS   AGE
      logdna-agent-ktdcv   1/1     Running   0          22s
      ```
    - kubectl logs po/logdna-agent-ktdcv -n ibm-observe
      ```
      [200110 15:53:11] logdna-agent 1.5.6 started on test-bnjd0v020p8mk5h9aeq0-kedgetester-default-00000038.iks.ibm (172.30.233.206)
      [200110 15:53:12] Authenticating API Key with api.us-south.logging.test.cloud.ibm.com (SSL)...
      [200110 15:53:12] Error connecting to /var/run/docker.sock: Error: connect ECONNREFUSED /var/run/docker.sock
      [200110 15:53:12] Auth error: 401: {"error":"Unable to authenticate key: value","code":"Rejected","status":"error"}
      [200110 16:53:12] Authenticating API Key with api.us-south.logging.test.cloud.ibm.com (SSL)...
      ```
    - If they are willing to delete the current configuration, ask them to run:
      - `ibmcloud ob logging config delete --cluster CLUSTER --instance INSTANCE`
      - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Log-Analysis-with-LogDNA?topic=LogDNA-ingestion_key">here for grabbing an ingestion key</a>
      -  Once they have their ingestion key they can run the following to eliminate the auth error: \
      `ibmcloud ob logging config create --cluster CLUSTER --instance INSTANCE --logdna-ingestion-key KEY`
    - If they are NOT willing to delete the current configuration:
      - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Log-Analysis-with-LogDNA?topic=LogDNA-ingestion_key">here for grabbing an ingestion key</a>
      - Ask them to delete their LogDNA secret: \
      `kubectl delete secret/logdna-agent-key -n "ibm-observe"`
      - Ask them to recreate their LogDNA secret with the value from the step above: \
      `kubectl create secret generic logdna-agent-key --from-literal=logdna-agent-key=KEY`
      - Ask them to delete the pod: \
      `kubectl delete po/logdna-agent-ktdcv -n ibm-observe`
      - They should see a successful connection in the newly created pod.
      ```
      kubectl logs po/logdna-agent-bc5lw -n ibm-observe
      [200110 19:47:41] Connected to logs.us-south.logging.test.cloud.ibm.com:443 (169.61.22.220) (SSL)
      [200110 19:47:41] Streaming /var/log: 39 file(s)
      ```

- ### Sysdig

  While running: `ibmcloud ob monitoring config create --cluster CLUSTER --instance INSTANCE`

  If the user received the error message:

  - Cannot find instance's ingestion key for resource key list, from the resource controller

  - Could not query resource keys for the provided instance, from the resource controller. Please wait a few minutes and try again. If you still encounter this problem, note the incident ID and contact IBM Cloud support.

  - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Monitoring-with-Sysdig?topic=Sysdig-access_key#access_key_ibm_cloud_ui">here for grabbing an access key</a>

  - Once they have their ingestion key they can run: \
  `ibmcloud ob monitoring config create --cluster CLUSTER --instance INSTANCE --sysdig-access-key KEY`

  If the user successfully ran:  
  `ibmcloud ob monitoring config create --cluster CLUSTER --instance INSTANCE`
   - Ask them to verify that it is a key error by checking their pod logs
    ```
    kubectl get po -n ibm-observe
    NAME                 READY   STATUS             RESTARTS   AGE
    sysdig-agent-wbdsq   1/1     READY              3          107s
    ```

   -   kubectl logs po/sysdig-agent-wbdsq -n ibm-observe
   ```
    2020-01-10 20:05:30.558, 1789.1872, Error, error_message_handler:63: received ERR_INVALID_CUSTOMER_KEY (Unauthorized agent access key.), terminating the agent
    2020-01-10 20:05:30.558, 1789.1884, Information, sinsp_worker: Terminating
    2020-01-10 20:05:30.610, 1789.1883, Information, capture_job_handler: cleaning up, force=no
    2020-01-10 20:05:30.610, 1789.1883, Information, watchdog_runnable:140: capture_job_manager terminating
    2020-01-10 20:05:30.617, 1789.1871, Information, watchdog_runnable:140: subprocesses_logger terminating
    2020-01-10 20:05:30.858, 1789.1881, Information, watchdog_runnable:140: serializer terminating
    2020-01-10 20:05:30.858, 1789.1872, Information, watchdog_runnable:140: connection_manager terminating
    2020-01-10 20:05:31.210, 1789.1789, Information, dragent:1158: Application::EXIT_OK
    2020-01-10 20:05:31.211, 1789.1789, Information, dragent:1182: Terminating
    ```

  - If they are willing to delete the current configuration, ask them to run:
    - `ibmcloud ob monitoring config delete --cluster CLUSTER --instance INSTANCE`
    - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Monitoring-with-Sysdig?topic=Sysdig-access_key#access_key_ibm_cloud_ui">here for grabbing an access key</a>
    -  Once they have their access key they can run the following to eliminate the auth error: \
    `ibmcloud ob monitoring config create --cluster CLUSTER --instance INSTANCE --sysdig-access-key KEY`
  - If they are NOT willing to delete the current configuration:
    - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Monitoring-with-Sysdig?topic=Sysdig-access_key#access_key_ibm_cloud_ui">here for grabbing an access key</a>
    - Ask them to delete their Sysdig secret: \
    `kubectl delete secret/sysdig-agent -n "ibm-observe"`
    - Ask them to recreate their Sysdig secret with the value from the step above: \
    `kubectl create secret generic sysdig-agent --from-literal=access-key=KEY -n ibm-observe`
    - Ask them to delete the pod: \
    `kubectl delete po/sysdig-agent-wbdsq -n ibm-observe`
    - They should see a successful connection in the newly created pod.
    ```
    kubectl logs po/sysdig-agent-vg6xf -n ibm-observe
    2020-01-10 20:35:07.039, 30192.30229, Information, Added 15 statsd metrics for host=test-bnjd0v020p8mk5h9aeq0-kedgetester-default-00000038.iks.ibm
    2020-01-10 20:35:07.040, 30192.30229, Information, ts=1578688507, ne=7026, de=0, c=2.79, fp=0.55, sr=1, st=0, fl=21
    2020-01-10 20:35:07.041, 30192.30221, Information, connection_manager:667: Sent msgtype=1 len=9666 to collector
    ```

## Automation
- None
- Manual key replacement will later be replaced by an API


## Escalation Policy

Please notify {{ site.data.teams.armada-kedge.comm.name }} on Argonauts and create an issue [here]({{ site.data.teams.armada-kedge.link }})
