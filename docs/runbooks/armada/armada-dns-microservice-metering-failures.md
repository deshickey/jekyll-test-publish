---
layout: default
description: DNS Microservice Metering Failures 
title: armada-dns-microservice - Metering Failures
service: armada
runbook-name: "armada-dns-microservice - Metering Failures"
tags: alchemy, armada, dns, billing, metering
link: /armada/armada-dns-microservice-metering-failures.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# DNS Microservice Metering Failures
## Overview
This runbook describes how to troubleshoot metering response errors in the armada-dns-microservice. The armada-dns-microservice will attempt to submit metering on a monthly basis for every subdomain that has a healthcheck enabled.

The pager duty alert is triggered when any subdomain fails to meter 3 times within a period of 3 hours.

## Example Alerts
PagerDuty would have created an alert with info similar to the following:

### Critical Alert:
```
alertname = ArmadaDNSMeteringFailuresBySubdomain
alert_situation = dns_metering_request_failed
app = armada-dns
clusterID = prod-test-cluster-01
dnsSubdomain = prod-test-cluster-01-accountuuid-0001.zone.appdomain.cloud
hostname = 10.130.231.176
instance = 72.16.235.190:8888
job = kubernetes-service-endpoints
kubernetes_namespace = armada
operation = `start_metering`
service = armada-dns
service_name = armada-dns
severity = critical
```

Expression:
```
expr: changes(armada_ingress:dns_metering_fail_count[3h]) > 3 and changes(armada_ingress:dns_metering_success_count[3h]) <= 0
for: 15m
```

## Investigation and Action:
### Possible causes for the alert:
1. BSS Outage
1. There may be network or credential errors when communicating with the metering endpoints.
1. The account for the cluster may have been suspended or revoked

### Check if BSS is having an outage
- Check the slack channel [#metering-adopters](https://ibm-containers.slack.com/archives/metering-adopters) for issues being reported
- If issues being reported, raise an incident with BSS [metering service](https://ibm.pagerduty.com/escalation_policies#PICP7UN)
- Snooze the alert and inform the frontdoor team. Jump to [Escalation Policy](#escalation-policy) section.

### Collect Logs
1. From the [alchemy dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/), navigate to the IBM Cloud Logs instance for the affected tugboat
1. Select armada-dns-microservice from the app list
1. Search for the dns subdomain from the alert and the keyword `metering`
1. If you see network related failures, then it is possible that the issue is with one or more _armada-dns-microservice_ pods on a carrier.
  1. Restart all _armada-dns-microservice_ pods and monitor the failed requests.
  1. If you still see failures after restarting the pods, try reloading the worker nodes that are hosting the failing _armada-dns-microservice_ pods.
  1. If the issue is still persist, page armada-ingress to perform further investigation, see [Escalation Policy](#escalation-policy).

## Escalation Policy

1. Create a GHE Issue against [armada-frontdoor](https://github.ibm.com/alchemy-containers/armada-frontdoor/issues/) and provide results from the investigation.
1. Also, inform the armada-ingress squad about the problem via slack in [#armada-ingress](https://ibm-containers.slack.com/archives/armada-ingress) with the GHE issue link.

If the above steps said to page armada-ingress, then please escalate the PagerDuty alert  [Armada - containers tribe - Ingress](https://ibm.pagerduty.com/escalation_policies#PPDGLNB), including details of the GHE ticket raised.