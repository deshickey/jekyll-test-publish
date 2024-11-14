---
layout: default
description: How to debug the issue when PVC deletion is failed.
title: armada-storage -  How to debug the issue when PVC deletion is failed.
service: armada-storage
runbook-name: "How to debug the issue when PVC deletion is failed."
tags: alchemy, armada, kubernetes, kube, kubectl
link: /armada/armada-storage-pvc-deletion-fail.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to debug the issue when PVC deletion is failed.

## Example Alert

This runbook is used when a customer reports a problem with PVC deletion. There are no alerts.

## Investigation and Action
The owner of the cluster can execute the following steps and provide the output of step 4 and step 5.


### Steps:

1.      Check whether cluster is created successfully and worker nodes are deployed successfully.<br>
        `bx cs clusters.`<br>
        `bx cs workers <clustername | cluster-id>`

1.      Export the kubeconfig by running the below commands<br>
        `bx cs cluster-config <cluster ID>` <br>
        `export KUBECONFIG=<path>`

1.      Check whether storage and watcher pods are running or not.<br>
        `kubectl get pod -n kube-system | grep -E 'ibm-storage-watcher|ibm-file-plugin'`.

1.      Get the details for PVC <br>
        `kubectl describe PVC <PVC name> -n <namespace>`

1.      check the logs of storage pod with the following command.<br>
        `kubectl logs <storagepod> -n kube-system` <br>
        `ex: kubectl logs ibm-file-plugin-4119949005-h822f -n kube-system.`

#### Possible storage plugin which can be identified from logs and their solutions

1. Error Type: Last Day Deletion Failure.<br>

   Error Message: {"This cancellation could not be processed please contact support.This cancellation could not be processed please contact support. You cannot cancel the selected billing items immediately.  Please choose your next billing anniversary date for cancellation date."} <br>

   Resolution: It is limitation from SoftLayer to delete the PV at the end of the Month. IBM Storage plugin pod keep retries and PV will be be automatically deleted on next billing cycle (i.e usually the First day of the Month).
    

2. Error Type: Authorization Failure. <br>

   Error Message:

    1. {———With invalid SL user/api key———— <br>
         "msg":"Error occurred","error":"Access Denied. "}
    1. {———With Invalid API Key———- <br>
         "msg":"Error occurred","error":"Provided API key could not be found" }
    1. {———With Invalid Refresh Token——— <br>
         "msg":"Error occurred","error":"Provided refresh token is invalid" }<br>


   Resolution:
     Need to check the credentials correct or not. To verify the credentials, Run the below steps and correct It. <br>
     1. `kubectl get secret storage-secret-store -n kube-system -o yaml`. <br>
     2. Get the key value of `slclient.toml` under data and echo it to decode the secret information. <br>
        ex: `data: `<br>
            `slclient.toml: W2JsdWVtaXhdCmlhbV91cmwgPSAiIgpp` <br>
            `echo “W2JsdWVtaXhdCmlhbV91cmwgPSAiIgpp” | base64 --decode` <br>
     3. verify `softlayer_username` and `softlayer_api_key` values. If values are incorrect, `run bx cs credentials-set --infrastructure-username <softlayer_username> --infrastructure-api-key <softlayer_api_key>` and Retry and wait for one or two minutes. 

3. Error Type: Networking Failure. <br>
   
   Error Message: {"msg":"Error occurred","error":"Get https://1186049_contdep%40us.ibm.com:XXXXX@api.softlayer.com/rest/v3/SoftLayer_Location_Datacenter/getDatacenters: dial tcp: lookup api.softlayer.com on 10.10.10.10:53: dial udp 10.10.10.10:53: i/o timeout"} <br> <!-- pragma: whitelist secret -->
   
   Resolution: It is issue with Softlayer API server is down temporarily and check `kubectl get pv` after 15 minutes interval or Post the error in `#armada-network channel`.


### Escalation Policy

Contact the volumes squad (`#armada-storage`) if issue still exists. Reassign the PD incident to `Alchemy - Containers Tribe - armada-storage` if no response in storage channel.
