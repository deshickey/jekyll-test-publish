---
layout: default
description: "Informational Runbook for Private Service Endpoint"
title: "Private Service Endpoint"
service: armada
category: armada
runbook-name: "Common SRE Steps for troubleshooting Armada in IBM Cloud - Dedicated"
tags: armada, kubernetes, private, service endpoint
link: /armada/armada_service_endpoint_overview.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook provides information for private service endpoints and how armada utilizes them.

## Detailed Information

There are two types of endpoints that we monitor. Customer facing endpoints and monitoring endpoints.
[Examples of both](https://github.ibm.com/alchemy-containers/armada-secure/blob/a853626538a110ab0ca47a38aa8beab17a180c8a/secure/armada/us-east/spokes/prod-wdc04-carrier100/armada-info.yaml#L37):
Monitoring only: c100-[1,2,3]-1.private.us-east.containers.cloud.ibm.com
Customer facing: c100.private.us-east.containers.cloud.ibm.com

Lets look at c2.private.us-south.containers.cloud.ibm.com more closly and see what that resolves too:

~~~
$ nslookup c100.private.us-east.containers.cloud.ibm.com

Name:	prod-us-east-tugboat.us-east.serviceendpoint.cloud.ibm.com
Address: 166.9.22.26
Name:	prod-us-east-tugboat.us-east.serviceendpoint.cloud.ibm.com
Address: 166.9.24.19
Name:	prod-us-east-tugboat.us-east.serviceendpoint.cloud.ibm.com
Address: 166.9.20.38
~~~

Note that this DNS entry maps to 3 endpoints, all of which are managed by the service endpoint team. To see which backends these map to, we will need to use service ep api, and the corresponding key from [Thycotic](https://pim.sos.ibm.com/app/#/home/folders/4250).

~~~
$ apikey=XXX
$ serviceAccessToken=`curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json" -d "grant_type=urn%3Aibm%3Aparams%3Aoauth%3Agrant-type%3Aapikey&apikey=$apikey" "https://iam.bluemix.net/identity/token" | jq -r .access_token`
$  curl "https://api.serviceendpoint.cloud.ibm.com/v2/serviceendpoints" -H "Authorization: Bearer $serviceAccessToken" | jq | grep tugboat100 -A 35 | grep -E 'static|address' #changed order below for readability
"staticAddress": "166.9.22.25",
    "address": "10.188.32.226",
"staticAddress": "166.9.24.18",
    "address": "10.190.79.162",
"staticAddress": "166.9.20.37",
    "address": "10.211.40.194",
"staticAddress": "166.9.22.26",
    "address": "10.211.40.194",
    "address": "10.188.32.226",
    "address": "10.190.79.162",
"staticAddress": "166.9.24.19",
    "address": "10.211.40.194",
    "address": "10.188.32.226",
    "address": "10.190.79.162",
"staticAddress": "166.9.20.38",
    "address": "10.211.40.194",
    "address": "10.188.32.226",
    "address": "10.190.79.162",
~~~

In the above output there are 6 service eps (166.9 adresses). 3 of them map to the customer facing DNS entry and all 3 backends. The other 3 are strictly for monitoring and map to a single backend.
The config for the monitoring can be found [here](https://github.ibm.com/alchemy-containers/armada-secure/blob/a853626538a110ab0ca47a38aa8beab17a180c8a/secure/armada/us-east/spokes/prod-wdc04-carrier100/armada-info.yaml#L37). The armada-ops-blackbox-exporter pod checks the health by performing a wget on http://MASTER_PRIVATE_ENDPOINT:MASTER_PRIVATE_ENDPOINT_PORT

eg:
~~~
$ curl http://c100.private.us-east.containers.cloud.ibm.com:30000
<html><body><h1>200 OK</h1>
Service ready.
</body></html>
~~~
or
~~~
$ curl http://10.211.40.194:30000
<html><body><h1>200 OK</h1>
Service ready.
</body></html>
~~~
You can also curl the service ep address and you should get the same response. If there is an issue with an endpoint, it is important to know where the breakage is.

## Rotate apikeys

1. login to appropriate account with the [admin creds](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/28248/general). See [here])(./armada-tugboats.html#access-tugboats-via-ibmcloud-cli) for our infrastructure accounts
2. Manage -> IAM -> Service IDs -> API keys -> Create
3. Name: "containers-${PIPELINE}-${REGION}-MIS-${YYYYMMDD}". YYYYMMDD is date of creation
4. Description: "cse key used for manual SRE operations"
5. Upload key to [thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/folders/9888)
6. No further action is needed because no automation uses this key
