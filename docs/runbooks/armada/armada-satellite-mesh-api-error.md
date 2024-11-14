---
layout: default
description: How to troubleshoot errors thrown by armada-satellite-mesh-api microservice.
title: armada-satellite-mesh-api - How to troubleshoot errors thrown by armada-satellite-mesh-api microservice.
service: armada
runbook-name: "armada-satellite-mesh-api - How to troubleshoot errors thrown by armada-satellite-mesh-api microservice"
tags: satellite-mesh, microservice
link: /armada/armada-satellite-mesh-api-error.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to troubleshoot errors thrown by the armada-satellite-mesh-api microservice. Alerts are triggered when specific errors are generated and aggregated across nodes. Too many errors generated over a minute will trigger the alert. The service is currently in BETA state. The API is currently deployed only to location us-south both on prod and stage.

## Example alert

```
summary = "too many ETCD write errors have occurred over the last minute"
description = "5 ETCD write errors have occurred over the last minute. Dependency marked as etcd"
```

## Investigation and Action

Alerts in the armada-satellite-mesh-api microservice are composed of two important pieces of information- the error description and the dependency associated with the error.

## Where to Find Logs (Initial Troubleshooting)

Logs for the satellite mesh microservice are published to Slack (similar to the way the armada-deploy squad posts their log messages):

- Pre-Production Successes [here](https://app.slack.com/client/T4LT36D1N/C02KZHZ5JSG)
- Pre-Production Failures [here](https://app.slack.com/client/T4LT36D1N/C02KXBMNK8A)
- Production Successes [here](https://app.slack.com/client/T4LT36D1N/C02KZHRFW6Q)
- Production Failures [here](https://app.slack.com/client/T4LT36D1N/C02KXBXRK27)

Visiting one of the above channels and searching for the Cluster ID will provide links to logs that can be vital in searching what happened to cause this failure.

## Possible Common Error Scenarios

- ETCD store initialization fails
- ETCD read and write operation fails
- ETCD completely unreachable

### ETCD store initialization fails

This kind of error means that the backend ETCD server is not available or the credentials are wrong. Connection details are comming from armada secure as secrets. To detect the root cause of this type of error need to go through on the following list:

 * Check the logs of service to identify the reason of the error.
 * Make sure the network between service and ETCD is working properly.
 * Ensure that the given ETCD connection details are valid and up to date. You can use `env` command inside the service container to list all the variables.
 * Check ETCD server logs for connection and credential errors.

### ETCD read and write operation fails

Read and write operation errors can occure many times and they have several reasons like:

 * ETCD didn't responsed in time
 * ETCD server has some serious issue
 * Data is not available
 * Data is locked by one other process
 * Network error between the service and ETCD server

To identify the problem please follow the list below:

 * Check the logs of service to identify the reason of the error.
 * Make sure the network between service and ETCD is working properly.
 * Check ETCD server logs for any kind of error.
 * Check if the increase of the number of error responses correlates in time with any similar errors of other services.

### HTTP error 500
#### ETCD completely unreachable

If the ETCD servers are completely unreachable, the API returns an error message with error code 500, because it fails to authenticate the user.

To check manually, run the following command from your own PC. The URL should target the endpoint where the error is present.
```
curl --location --request GET 'https://api.us-south.mesh.satellite.cloud.ibm.com/v1/mesh/asd'  --header "Authorization: Bearer asd"
```
Example error response:
```
{"incidentID":"c82acab7-6e58-4b79-aa6d-5c4b857bb0a7","code":"A0002","description":"Could not connect to a backend service. Try again later.","type":"Authentication"}
```

If the ETCD connectivity is up, you should receive the following user error message because of the dummy token.
```
{"incidentID":"00426a14-c976-46d7-934e-c766156e073e","code":"A0003","description":"Your IAM token could not be verified. To retrieve your access tokens, run 'ibmcloud iam oauth-tokens'. Then use the IAM token for the Authorization header.","type":"Authentication","recoveryCLI":"To log in to IBM Cloud, run 'ibmcloud login'."}
```

To identify the problem please follow the list below:

 * Identify which carrier is hosting the failing API pod. The regional API is hosted on the carrier that has the type ```LinkApiSatellite```.

 * Check the logs of the ```satellite-mesh-api``` pods in ```armada``` ns to identify the reason of the error. Example:
```
kubectl -n armada logs satellite-mesh-api-5cfbbb986b-xgcxb -c satellite-mesh-api
```
 * Logs are also visible in LogDNA in the Satellite Production account.
 * Make sure the network connectivity between the API and ETCD is healthy. ETCD is running on the hub/microservices tugboat in the IKS production account. In order to have access to it from the Satellite Production account, Satellite Link API tugboat private subnets are allowlisted in the appropriate CSEs. If the tugboat was scaled out recently, it might happen that not all the private IP subnets are present in the CSE allowlist.
 * Create a pod in the same namespace as the SatMesh API, and ping the ETCD URL
  ```
      kubectl -n armada run --rm -it --image ubuntu debug-pod
      # Install ping
      (pod)# apt update; apt install inetutils-ping
      #Ping ETCD (Current ETCD endpoint available in the configmap armada-etcd-configmap)
      kubectl -n armada get cm armada-etcd-configmap -o json | jq '.data.ETCD_ENDPOINTS_OPERATOR'
      (pod)# ping etcd-103-1-e.us-south.containers.test.cloud.ibm.com
  ```
    * If the connectivity is up, while the alert is still active, then please contact the SatMesh team
 * Check ETCD server logs for any kind of error.
 * Check if the increase of the number of error responses correlates in time with any similar errors of other services.

If it is determined that the connectivity error is not specific to the SatMesh API service, please contact the appropriate team.

### Catch-All

For all other failures please reach out to the armada-satmesh squad directly via Slack or create a new issue [here](https://github.ibm.com/alchemy-containers/satellite-mesh/issues/new).  Satmesh squad will add more scenarios to this runbook to help facilitate SRE debugging.

## Escalation Policy

Use the escalation steps below to involve the `armada-satmesh` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-satmesh](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-satmesh](https://ibm-argonauts.slack.com/messages/satellite-mesh)
  * GHE issues: [satellite-mesh](https://github.ibm.com/alchemy-containers/satellite-mesh/issues/)
