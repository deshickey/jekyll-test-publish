---
layout: default
description: How to troubleshoot errors thrown by armada-storage microservice.
title: armada-storage - How to troubleshoot errors thrown by armada-storage microservice.
service: armada-storage
runbook-name: "armada-storage - How to troubleshoot errors thrown by armada-storage microservice"
tags: alchemy, armada, storage, error
link: /armada/armada-storage-error.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to troubleshoot errors thrown by armada-storage microservice. Too many errors generated over a minute will trigger the alert.

## Prerequisites
If the depolyment is failed and compare the [#storage_build](https://github.ibm.com/alchemy-containers/armada-storage-microservice/blob/develop/deployment/storage.toml) with [#storage_file_plugin_image] in the [armada-ansible BOM](https://github.ibm.com/alchemy-containers/armada-ansible/blob/dev/common/bom/) location used by cluster. The bom file name has your cluster version. Ex: if cluster version is `1.5.6_1501*` the bom file can be `armada-ansible-bom-1.5.yml`. If both builds are same, that is not an issue and it will be resolved in next iteration. If versions are different escalate to `#armada-storage` channel.


## Actions to take

Alerts in armada-storage microservice are composed of two important pieces of information- the error description and the dependency associated with the error. Currently there are two  possible dependencies associated with an alert

* chief
* storage

This information is provided to help guide you in the right direction while troubleshooting because all of the alerts triggered by armada-storage microservice will have been caused by an underlying dependency.

Begin troubleshooting by SSHing into the appropriate Armada carrier worker node and check the status of pods by running appropriate commands. Use this Pod status information to assist you on the next steps.

Refer the github.ibm.com/alchemy-containers/armada-chief/README.md and run Curl command `curl http://armada-chief:6969/v1/addons` to get the registred addons with chief and Check the whether expected addons 'customer-storage-pod' and 'storage-watcher-pod' registered or not.

If the 'customer-storage-pod' and 'storage-watcher-pod' addons are not enabled, follow the steps to resolve the issue.

### For chief errors

* Check the status of chief pods by running ```kubectl get pod -n armada | grep chief```. If more than a few are down or having issues contact `#armada-chief` slack channel.

* Check the status of chief services by running ```kubectl get services -n armada | grep chief```.


### For storage errors

* Check the status of storage pods by running ```kubectl get pod -n armada | grep storage```. If the pods are not in running state, delete the problematic pod and it will redeploy automatically.If more than a few are down or having issues contact `#armada-storage` slack channel.

* Check the status of storage services by running ```kubectl get services -n armada | grep storage```.

* Check the logs of storage pods by running ```kubectl logs <pod name> -n armada```.



### **Escalation**:

Contact the volumes squad (`#armada-storage`) if issue still exists. Reassign the PD incident to `Alchemy - Containers Tribe - armada-storage` if no response in storage channel.
