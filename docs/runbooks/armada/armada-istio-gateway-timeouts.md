---
layout: default
description: How to deal with 503 timeout errors returned by the istio gateway.
title: armada - dealing with 503 timeout errors returned by the istio gateway.
service: armada
runbook-name: "Dealing with 503 timeout errors returned by the istio gateway"
tags: alchemy, armada, 503, ingress, armada-api, istio
link: /armada/armada-istio-gateway-timeouts.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with the istio gateways returning timeouts.

## Example Alerts

`armada-istio/critical_number_of_istio_gateway_timeouts`

## Investigation and Action

1. Identify the failing components:

    1. Begin by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `Prometheus` icon in the alerted environment.

    2. Click on the `Alerts` tab in Prometheus, it should show an active alert (indicated in red) for the corresponding failure and a value.  This value will show the number of occurrences in the past 30 minute window.

    3. To see which routes are returning the most errors, on the prometheus Graph page, execute the query: `sort_desc(sum by(request_path)(delta(istio_requests_total{kubernetes_pod_name=~"istio-ingressgateway.+",response_code=~"503",source_workload=~"istio-ingressgateway.+"}[2m]))>0)`

        - If you see an outstanding number for a specific set of routes, it is possible that the microservice that would handle the requests is unhealthy.
        - Check [the istio configuration](https://github.ibm.com/alchemy-containers/armada-istio-config/blob/master/config-src/armada-istio-config/istio_ingress.yaml) to see which microservice exposes this.
        - [Access the tugboat](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats) and investigate if the microservice is running.
        - If the corresponding microservice down, investigate and resolve the issue if you can, otherwise reach out to the team that owns the corresponding microservice. See the [Escalation Section](#in-case-of-an-unhealthy-microservice).

    4. To see which gateways are timing out, on the prometheus Graph page, execute the query: `sum by(response_code,kubernetes_pod_name)(istio_requests_total{source_workload=~"istio-ingressgateway.+",response_code=~"503",kubernetes_pod_name=~"istio-ingressgateway.+"})`

        - If you see that the failures are coming from a specific set of pods, it is possible that the pods or the hosting node is unhealthy.
        - Check the health of the node. If it is unhealthy cordon and drain, then try restarting.

2. Run the [Istio Jenkins Job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-istio-status/build?delay=0sec), with parameters `OPERATION` at `status` and `TUGBOAT` at the `carrier_name` listed in the alert, to get the status of the istio gateways.

    1. Review the output.
    2. Look for [gateway timeouts](https://github.ibm.com/alchemy-containers/armada-istio-config/blob/master/scripts/istio_status.sh#L94).
    3. Check [pod statuses](https://github.ibm.com/alchemy-containers/armada-istio-config/blob/master/scripts/istio_status.sh#L68-L77).

### Useful Prometheus Queries

To determine the rate of 503 status codes over a 2min delta period, click on `Graph` in the navigation bar, then execute the query: `sum(delta(istio_requests_total{source_workload=~"istio-ingressgateway.+",response_code=~"503",kubernetes_pod_name=~"istio-ingressgateway.+"}[2m]))`

To determine the rate of 503 status codes compared to 2xx status codes over a 2min delta period, on the prometheus Graph page, execute the query: `sum(delta(istio_requests_total{source_workload=~"istio-ingressgateway.+",response_code=~"503|2..",kubernetes_pod_name=~"istio-ingressgateway.+"}[2m]))`

### Guidelines

If the rate is below 40 in a 2min delta period and has since dropped, then it is likely a short lived issue but will still need investigation, so please run the istio jenkins job using parameter `OPERATION` = `status` pointing at the corresponding tugboat.

If the rate is below 40 but is climbing, then the problem may potentially escalate and should be investigated.

## Escalation Policy

### In case of an unhealthy microservice

If you need assistance fixing an unhealthy microservice, reach out to the owner squad. If you do not know which squad owns the corresponding microservice, [this box note](https://ibm.ent.box.com/notes/141718696958) might help.

If in the event further assistance is needed, please tag the corresponding squad in the conductors channel. If there is no response, then escalate on PagerDuty to the team.

### In case of an Istio issue

After completing the above steps, raise a [GHE](https://github.ibm.com/alchemy-containers/satellite-network) issue against the satellite network squad, and tag `@cp-istio` in [Carrier Istio](https://ibm.pagerduty.com/escalation_policies#PKXCMU3) to inform the team that an issue was created. Add any jenkins jobs that were run, and the results from the Prometheus queries run (if done), along with the corresponding PagerDuty alert for reference.

If in the event further assistance is needed, please tag the `@cp-istio` in [armada-control-plane-istio](https://ibm.enterprise.slack.com/archives/C072XHMACTY). If there is no response, then escalate on PagerDuty to: [Carrier Istio](https://ibm.pagerduty.com/escalation_policies#PKXCMU3).
