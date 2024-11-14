---
layout: default
description: How to resolve armada master private service endpoint slow or failing alerts
title: armada-master-private-service-endpoint-slow - How to resolve armada master private service endpoint slow or failing alerts
service: armada-infra
runbook-name: "armada-master-private-service-endpoint-slow - How to resolve armada master private service endpoint slow or failing alerts"
tags:  armada, service-endpoint
link: /armada/armada-master-private-service-endpoint-slow.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This runbook contains steps to take when debugging slow or failing master private service endpoints
## Example Alert(s)
Example of a master private endpoint reporting slow
~~~~
labels:
 - alertname = MasterPrivateEndpointReportingSlow
 - alert_key = armada-infra/master_private_endpoint_reporting_slow
 - alert_situation = master_private_endpoint_reporting_slow
 - carrier_name = prod-dal10-carrier107
 - carrier_type = spoke-roks
 - crn_cname = bluemix
 - crn_ctype = public
 - crn_region = us-south
 - crn_servicename = containers-kubernetes
 - crn_version = v1
 - hostname = armada-ops-blackbox-exporter.monitoring
 - instance = armada-ops-blackbox-exporter.monitoring:9115
 - job = master-private-endpoint-c107-3-1.private.us-south.containers.cloud.ibm.com
annotations:
 - description = Armada master private service endpoint master-private-endpoint-c107-3-1.private.us-south.containers.cloud.ibm.com is reporting slow for the past 15 minutes.
  - summary = Armada master private service endpoint master-private-endpoint-c107-3-1.private.us-south.containers.cloud.ibm.com is reporting slow for the past 15 minutes.
~~~~
Example of a master private endpoint reporting failures
~~~
labels:
 - alertname =   - alert: MasterPrivateEndpointFailing
 - alert_key = armada-infra/master_private_endpoint_reporting_failing
 - alert_situation = master_private_endpoint_reporting_failing
 - carrier_name = prod-dal10-carrier107
 - carrier_type = spoke-roks
 - crn_cname = bluemix
 - crn_ctype = public
 - crn_region = us-south
 - crn_servicename = containers-kubernetes
 - crn_version = v1
 - hostname = armada-ops-blackbox-exporter.monitoring
 - instance = armada-ops-blackbox-exporter.monitoring:9115
 - job = master-private-endpoint-c107-3-1.private.us-south.containers.cloud.ibm.com
annotations:
 - description = Armada master private service endpoint master-private-endpoint-c107-3-1.private.us-south.containers.cloud.ibm.com is reporting failures for the past 20 minutes.
  - summary = Armada master private service endpoint master-private-endpoint-c107-3-1.private.us-south.containers.cloud.ibm.com is reporting failures for the past 20 minutes.
~~~


## Actions to take
   
### First: Locate the zone of the endpoint
This can be found in the `job` parameter value in the alert.

#### Example of *carrier* ,
1. `master-private-endpoint-c2-3-1.private.us-south.containers.cloud.ibm.com`, in this case `c2-3-1` which means it is third zone.

2. Use this format, `prod-[zone]-[carriername]-lb-private-vip` to get the device name, in this case `prod-dal13-carrier2-lb-private-vip`

3. Use `netmax` bot to get the VIP IP of the above device name

~~~
prod-dal10-carrier2-lb-private-vip - dal10 - 531277
Private: 10.171.57.40 10.171.57.32/28 (Prod/Carrier2) (bcr02a.dal10)

prod-dal12-carrier2-lb-private-vip - dal12 - 531277
Private: 10.184.250.24 10.184.250.16/28 (Prod/Carrier2) (bcr01a.dal12)

prod-dal13-carrier2-lb-private-vip - dal13 - 531277
Private: 10.209.50.72 10.209.50.64/28 (Prod/Carrier2) (bcr02a.dal13)
~~~

#### Example of *tugboat*,
1. `master-private-endpoint-c133-1-1.private.us-east.containers.cloud.ibm.com`, in this case `c133-1-1` which means it is first zone.

2. Use this format, `prod-[zone]-[tugboatname]-loadbalancer-private-vip` to get the device name, in this case `prod-wdc04-tugboat113-loadbalancer-private-vip`

3. Use `netmax` bot to get the VIP IP of the above device name

~~~
prod-wdc04-tugboat113-loadbalancer-private-vip - wdc04 - 2094928
Private: 10.65.84.146 10.65.84.144/29
~~~

 **Note:** The endpoint  for uk-south/eu-gb regions the zone will be change for carrier and tugboat. Depending on the alert type carrier or tugboat the first -1 or -2 or -3 will change the zone.
   ```
   eu-gb carriers - lon02, lon04, lon06
   eu-gb tugboats - lon04, lon05, lon06
   ```
   Example,\
   carrier endpoint `master-private-endpoint-c1-1-1.private.eu-gb.containers.cloud.ibm.com`\
   `prod-lon02-carrier1-loadbalancer-private-vip`\
   tugboat endpoint `master-private-endpoint-c100-1-1.private.eu-gb.containers.cloud.ibm.com`\
   `prod-lon04-tugboat100-loadbalancer-private-vip`


   **Note:** please check the prometheus query linked in alert, as there may be more than one endpoint firing.  Keep in mind that a single endpoint in one carrier can cause other alerts to fire in other carriers because they can no longer reach the troubled carrier.  This may give the impression of a catastrophic failure for the region.  Be sure to follow the guide below thoroughly in order to prevent calling a CIE when none is actually necessary.  For example, a private endpoint failure in SAO01 can cause alerts to fire across all US-South carriers.

### Second: Recycle resources:
   - For **Tugboats**, try deleting the corresponding `ibm-cloud-provider-ip-<IP>*` pods in the `ibm-system` namespace. Do this one at a time and wait for the new pod to be Running and Ready before deleting the next. `IP` is the ip of the problematic loadbalancer containing dashes instead of dots. e.g. `ibm-cloud-provider-ip-10-188-32-226-56b68f4f4c-r6vhr`. If problem still persists after pod recycling, please reload the edge node where the `ibm-cloud-provider-ip-<IP>*` pods are running on, do this one at a time.
   - For **Carrier**, try deleting the corresponding `ibm-cloud-provider-ip-<IP>*` pods in the `ibm-system` namespace. Do this one at a time and wait for the new pod to be Running and Ready before deleting the next. `IP` is the ip of the problematic loadbalancer containing dashes instead of dots. e.g. `ibm-cloud-provider-ip-10-171-57-40-5bcdc94ffd-n9qgs`. If problem still persists after pod recycling, please reload the edge node where the `ibm-cloud-provider-ip-<IP>*` pods are running on, do this one at a time.

#### Example of carrier2 in zone dal10 
~~~
[prod-dal12-carrier2] prod-dal10-carrier2-worker-1155:~$ kubectl -n ibm-system get po
NAME                         READY  STATUS  RESTARTS  AGE
ibm-cloud-provider-ip-10-171-57-40-5bcdc94ffd-n9qgs  1/1   Running  0     5d17h
ibm-cloud-provider-ip-10-171-57-40-5bcdc94ffd-q6wm8  1/1   Running  0     5d17h
~~~


## Escalation Policy
Document all actions taken before escalating and provide a link to the documentation in the escalation. Escalate to the armada-network squad. [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/service-directory/P2L36TN)

