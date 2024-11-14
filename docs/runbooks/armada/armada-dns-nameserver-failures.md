---
layout: default
description: Nameserver failures
title: armada-dns-microservice - Nameserver failures
service: armada
runbook-name: "armada-dns-microservice - Nameserver failure"
tags: alchemy, armada, dns, nameserver
link: /armada/armada-dns-nameserver-failures.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Nameserver Failure
## Overview
_armada-dns-microservice_ mesures the request latency with (IBM and Akamai) nameservers that are involved in serving the `*.containers.appdomain.cloud` and `*.satellite.appdomain.cloud` domains.

When _armada-dns-microservice_ has connectivity issues with a nameserver for a longer period an alert is fired. This runbook describes how to troubleshoot these failures.

## Example Alerts
```
alertname = ArmadaDNSNameserverErrorPreprod
alert_situation = a1-180.akam.net_nameserver_failure_count
app = armada-dns
nameserver = a1-180.akam.net
instance = 72.16.235.190:8888
job = kubernetes-service-endpoints
kubernetes_namespace = armada
service = armada-dns
service_name = armada-dns
severity = critical
env = prod
```

Expression:
```
sum by (nameserver)(increase(armada_dns_nameserver_error_count{env="preprod"}[20m])) > 6
for: 5m
```
- This alert will trigger when the armada-dns-microservice fails to reach one or more nameservers more than 6 times over a 20 minute period.


```
alertname = ArmadaDNSNameserverErrorProd
alert_situation = a1-207.akam.net_nameserver_failure_count
app = armada-dns
nameserver = a1-207.akam.net
instance = 72.16.235.190:8888
job = kubernetes-service-endpoints
kubernetes_namespace = armada
service = armada-dns
service_name = armada-dns
severity = critical
env = prod
```

Expression:
```
sum by (nameserver)(increase(armada_dns_nameserver_error_count{env="prod"}[20m])) > 6
for: 5m
```
- This alert will trigger when the armada-dns-microservice fails to reach one or more nameservers more than 6 times over a 20 minute period.


## Investigation and Action:
### Possible causes for the alert:

1. nameservers are overloaded and are dropping incoming requests
2. armada-dns-microservice pods have connectivity issues with nameservers

### Check Akamai status:

If the nameserver in the alert is `*.akam.net`, it is possible that Akamai has a known outage. Check the [Akamai status page](https://www.akamaistatus.com/) to see if there are any outages.

If there is an ongoing outage that is related to the Akamai EdgeDNS service, no further investigation is required. Snooze the alert and inform the armada-ingress team (no paging necessary). Jump to [Escalation Policy](#escalation-policy) section for more information.


### Collect data in prometheus:

1. Check the number of successful and failed requests in Prometheus by executing the following queries:
- to get the successful requests: `sum by (nameserver)(armada_dns_nameserver_latency_seconds_count)`
- to get the failed requests: `sum by (nameserver)(armada_dns_nameserver_error_count)`

1. Analyze the output:
- If you see failures only for a subset of the nameservers, then the issue is likely with those nameservers or a networking issue that is limited to the connectivity with these nameservers. 
- Check the queries above for longer time window. If the errors didn't really increase in the last few hours, the error is just reach the threshold but we can live with that, since our checks are using UDP, we can see some packet drops. You can snooze the alert and inform the armada-ingress team (no paging necessary). Jump to [Escalation Policy](#escalation-policy) section for more information.
- If you see the increase is agressive for one or more nameservers, than we need to continue the investigation.
    1. Execute the above Prometheus queries in another regions on microservice carriers:
        - ap-north: prod-tok02-carrier105
        - ap-south: prod-syd01-carrier102
        - br-sao: prod-sao01-carrier102
        - ca-tor: prod-tor01-carrier102
        - eu-central: prod-fra02-carrier105
        - eu-fr2: prodfr2-par04-arrier100
        - eu-es: prod-mad02-carrier100
        - jp-osa: prod-osa21-carrier100
        - uk-south: prod-lon04-carrier101
        - us-east: prod-wdc04-carrier103
        - us-south: prod-dal10-carrier105
    1. If you see similar failures for the same nameserver(s) from more than one region, then we need to open a ticket to Akamai (see [Opening a ticket to Akamai](#opening-a-ticket-to-akamai)).
    1. Inform the armada-ingress team (no paging necessary), see [Escalation Policy](#escalation-policy).
- If you see failues for all nameservers, then it is possible that the issue is with one or more _armada-dns-microservice_ pods on a carrier.
  1. Restart all _armada-dns-microservice_ pods and monitor the failed requests.
  1. If you still see failures after restarting the pods, try reloading the worker nodes that are hosting the failing _armada-dns-microservice_ pods.
  1. If the issue is still persist, page armada-ingress to perform further investigation, see [Escalation Policy](#escalation-policy).

## Opening a ticket to Akamai

In case you need to open a ticket for the Akamai please do the following: 
1. Navigate to the [Akamai Control Center](https://control.akamai.com/) page
2. Under the `Support` section you can create a new ticket. In the ticket you need to describe the connectivity issue and list the nameservers with high failure requests. Here you can find two example tickets from the past: [F-CS-8410324](https://control.akamai.com/apps/case-management/#/cases/F-CS-8410324/view) [F-CS-8324074](https://control.akamai.com/apps/case-management/#/cases/F-CS-8324074/view)
3. Inform the armada-ingress squad. Check the [Escalation Policy](#escalation-policy)

Note: if you usure if we need to open a ticket to Akamai or you don't have the right permissions, page the armada-ingress squad, check the [Escalation Policy](#escalation-policy) for more details. 

## Escalation Policy

1. Create a GHE Issue against [armada-frontdoor](https://github.ibm.com/alchemy-containers/armada-frontdoor/issues/) and provide results from the investigation.
2. Also, inform the armada-ingress squad about the problem via slack in [#armada-ingress](https://ibm-containers.slack.com/archives/armada-ingress) with the GHE issue link.

If the above steps said to page armada-ingress, then please escalate the PagerDuty alert  [Armada - containers tribe - Ingress](https://ibm.pagerduty.com/escalation_policies#PPDGLNB), including details of the GHE ticket raised.
