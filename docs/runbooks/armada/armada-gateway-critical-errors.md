---
layout: default
title: Troubleshooting API Gateway Critical Errors - armada-gateway
type: Troubleshooting
runbook-name: "Troubleshooting API Gateway Critical Errors - armada-gateway"
description: "Troubleshooting API Gateway Critical Errors - armada-gateway"
service: armada-gateway
link: /armada/armada-gateway-critical-errors.html
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

### Overview

This runbook describes how to troubleshoot critical errors as reported by the API Gateway (armada-gateway). Critical errors may appear to users as REST API 5xx status codes or GraphQL API error messages.

The gateway is a proxy to other backend microservices, so most critical errors reported here come from different microservices. Further, errors can be reported in any region they pass through. They do not necessarily indicate outages in each reported region.

**NOTE:** For now, all alerts should go to the armada-api team immediately. If SRE is paged, that is a mistake the armada-api team will correct. This runbook will be updated as this service matures, post-GA.

### Example Alerts (required)

- `bluemix.containers-kubernetes.prod-dal10-carrier1.gateway_critical_failures.us-south`

### Investigation and Action

1. Escalate the page to the [armada-api](./armada_pagerduty_escalation_policies.html) escalation policy so the squad can start working the issue.

### Further Debugging/Monitoring

The alert contains a highlight of the top error counts by service_url and path.
Check this list as a quick reference for which microservices should be investigated next.

Here's an example PagerDuty alert `description`. Refer to `Unhealthy Services` and investigate those microservices further.
```
Labels:
 - alertname = ArmadaGatewayCriticalErrors
 - alert_key = armada-gateway/gateway_critical_failures
 ...
 - description = The API Gateway is consistently returning critical failures to users.

Unhealthy Services:

 - http://satellite-connector-api.armada.svc:8080/graphql @ satelliteConnectors: 446.85929802075975
 - http://armada-api.armada.svc:6969/graphql @ supportedLocations: 446.85929802075975

Unhealthy Dependencies:
```

#### Prometheus checks to determine the rate of critical errors

Use the [alchemy-prod dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and navigate to `View` -> `Prometheus` for the carrier the alert is triggering for.

Enter the following query and select Graph to view the failures by service URL and query path:

```
sum by(service_url, path) (rate(armada_gateway_operations_error_count{critical="true",job="kubernetes-pods-mtls"}[1m]))
```

Refer to the legend below the graph to identify the impacted services and their failing query paths.
Each query path reports the specific API feature that is failing.

For example:
```
{path="satelliteConnectors", service_url="http://satellite-connector-api.armada.svc:8080/graphql"}
{path="supportedLocations", service_url="http://armada-api.armada.svc:6969/graphql"}
```
In this graph's legend, there are 2 impacted microservices: `armada-api` and `satellite-connector-api`. Use each entry to assess the severity.

Other things to consider:
* If a path like `satelliteConnectors` or `node` is reported, then viewing those resources is impacted.
* If a path like `createSatelliteConnector` is reported, then modifying or creating that resource is impacted.

##### Further troubleshooting

To understand these further, each of those fields correspond to specific microservice. At the time of writing, that is only armada-api and satellite-connector-api. Identify the appropriate microservice and find logs in LogDNA matching those query names.

### RCA and pCIEs

Escalate immediately.

This service is brand new and still experimental, so we should not open CIEs at this time. This runbook will change as the service matures.

### Escalation Policy (required)

Escalate the issue to the armada-api squad as per their [escalation policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada_pagerduty_escalation_policies.html)

Slack Channel: https://ibm-argonauts.slack.com/archives/C53NQCME0 (#armada-ironsides)
GitHub Issues: https://github.ibm.com/alchemy-containers/armada-ironsides/issues
