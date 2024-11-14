---
layout: default
description: Armada Common API degradation
title: armada-common - Service API failures
service: armada
runbook-name: "armada-common - Service API failures"
tags: alchemy, armada, api, short, long, dns, ingress, secret-mgr, storage, network
link: /armada/armada-common-api-failures.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Armada Common API Failures
## Overview
This runbook describes how to troubleshoot failure alerts for and API endpoints that emit metrics using the common armada-observability middleware. These failures indicate a regression, possible upstream/dependency error, or general degredation of the APIs.

The pager duty alert is triggered when an API is emitting a significantly high number of 5xx responses.

## Detailed Information
The alerts that use this runbook track the response codes returned from armada-alb-api, armada-ingress-secret-mgr, or armada-dns-microservice over a 5 minute and in some cases 1 hour window. Should a spike in error responses occur over the short duration or a large increase over the longer duration the alert will be triggered. There are many possible sources of the error ranging from dependencies having issues ie BSS, IAM, etc. to a regression in the code itself. This will warrant closer investigation of logs by the Ingress squad.

## Example Alerts
  
### APIErrorsShortWindow  
  ```
    alertname = APIErrorsShortWindow
    alert_situation =10.130.231.176_ingress_api_server_errors_short_window
    job = kubernetes-pods-mtls
    kubernetes_namespace = armada
    method = GET
    service = armada-ingress
    path = path=/regional/v1/nlb-dns/clusters/:idOrName/list
    service_name = armada-dns-microservice
    status_code = 504
    severity = critical
  ```
  
### APIErrorsLongWindow  
  ```
    alertname = APIErrorsLongWindow
    alert_situation =10.130.231.176_ingress_api_server_errors_long_window
    job = kubernetes-pods-mtls
    kubernetes_namespace = armada
    method = GET
    service = armada-ingress
    path = path=/regional/v1/nlb-dns/clusters/:idOrName/list
    service_name = armada-dns-microservice
    status_code = 504
    severity = critical
  ```

## Automation
n/a

## Investigation and Action:

### Determine Impact

The goal is to determine whether a single customer, cluster, or account is generating all of the failures; or whether the issue is widespread across customers. 

To view metrics for a service and request path, navigate to the grafana instance for the tugboat in the region. Choose Home -> Dashboards -> armada -> Armada Observability HTTP Path and fill in the variables from the alert for service and path. An example link can be found [here](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier105/grafana/d/observability-http-path/armada-observability-http-path?orgId=1).

To see details about specific requests you can use the logs from the middleware. Navigate to the correct IBM Cloud Logs instance for the region

Use the `status_code` and `request_path` keys to search for the offending requests. The values for status code and path can be found in the alert details. Filter the results by the app using the `service_name` in the alert. Example Lucene search query: `message.request_path:"/v2/alb/getStatus" message.status_code:500`

The resulting log output will look similar to the following:

```
{
...
message: {"level":"info","ts":"2023-09-11T09:14:27.618Z","caller":"gin@v0.2.2/metrics.go:107","msg":"","request_id":"a477354f-3bd5-44f9-9c94-ebd9af3b50c4","method":"github.ibm.com/alchemy-containers/armada-observability/integrations/gin.NewGinMiddleware.func2","status_code":500,"request_path":"/v2/alb/getStatus","request_query":"cluster=cjr3c7dd01gohgboknqg","latency":15.248707512,"method":"GET"}
}

{
...
message: {"level":"info","ts":"2023-09-11T17:23:26.923Z","caller":"gin@v0.2.2/metrics.go:107","msg":"","request_id":"141460b0-e499-42c9-9d75-e4dfeabd465e","method":"github.ibm.com/alchemy-containers/armada-observability/integrations/gin.NewGinMiddleware.func2","status_code":500,"request_path":"/v2/alb/getStatus","request_query":"cluster=cgvgio5d0t66fcsuvu0g","latency":15.01860084,"method":"GET"}
}
```

To check the number of clusters run the following `DataPrime` query:
```
source logs | filter message.request_path=='/v2/alb/getStatus' && message.status_code==500 | distinct message.cluster_id | count
```

If the number of clusters impacted is high, escalate to the development team that owns the API to perform further investigation, see [Escalation Policy](#escalation-policy). If the impact is low, snooze the alert, open a GHE issue with the team and include the details so they can investigate during working hours. 

### Investigate Specific Request

To find a specific request, replace the existing search query with the `message.request_id` value. Example log output containing the error for the request:

```
{
...
message: {"level":"error","ts":1694453006.9225342,"caller":"resourcegroup/manager.go:75","msg":"error retrieving resource group","request_id":"141460b0-e499-42c9-9d75-e4dfeabd465e","accountID":"c6ef77f820bd49b783095d9e04fdf4b7","error":"service-engine (resource-group.get_resource_group): Get \"https://resource-controller.cloud.ibm.com/v1/resource_groups/e71d899e5987437abe7fd9fb2942c7c5\": context deadline exceeded","errorVerbose":"Get \"https://resource-controller.cloud.ibm.com/v1/resource_groups/e71d899e5987437abe7fd9fb2942c7c5\": context deadline exceeded\nservice-engine (resource-group.get_resource_group)"}
}
```

The error could be from a dependency or an issue with a customer configuration.

### Additional Resources

1. Check the respecive query in prometheus to identify the endpoints that are currently exhibiting the problematic behavior.

1. The observability [grafana](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier105/grafana/d/armada-observ-http/armada-observability-http?from=now-24h&to=now) page may also be used via selecting the service and drilling down to identify specific error codes being returned.


## Escalation Policy

If the impact investigation from above shows high impact find the service escalation policy for the component owner and escalate the pagerduty alert. Otherwise, snooze the alert, create a GHE issue for the team, and notify them via their slack channel.