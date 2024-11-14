---
layout: default
description: How to respond to tripped circuit breakers.
title: armada - responding to tripped circuit breakers.
service: armada
runbook-name: "Responding to tripped circuit breakers"
tags: alchemy, circuit breaker
link: /armada/circuit_breaker.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to respond to alerts triggered by open circuit breakers. A circuit breaker monitors the number of errors received from a service armada depends on (IAM, BSS, etc.) per unit of time. The circuit "opens" when the number of errors per unit of time exceeds a threshold. An open circuit means any attempt to contact the dependency service results in an immediate error, without attempting to contact the service.

This is done to provide faster responses to clients and to keep from overloading a dependency that is not functioning properly, which can be especially problematic if automatic retry mechanisms are in place, as is the case in armada. While a circuit breaker is open, at specified intervals one request (known as a "trial" request) will be allowed to contact the dependency to check whether the dependency has recovered.  If no error is returned, the circuit breaker is "closed" and requests once again flow to the dependency service.


## Investigation and Action
This alert can be triggered for a variety of reasons. Here are some good places to start:
1. Search logs for errors which may contain clues for the root cause.
    - Search using the key words `circuit is open`.
    - Errors should be visible from the unhealthy service/dependency that can tell you exactly what endpoint isn't working correctly.
        - i.e. `service-engine (iam_identity.service_token_get): circuit is open: Post "https://foo/identity/token": dial tcp: lookup foo on 172.19.0.10:53: no such host`
    - The errors found in the logs using the key terms above will also include helpful information like
        - request id
        - trace
        - caller

## Escalation Policy
Here are the different paths for addressing the situation:  
1. If **only one** unhealthy **service** and **one or more** unhealthy **dependency**
    - check if a new version of the service has recently been promoted
    - escalate to `app_owner` (found under Pager Duty alert labels)

2. If **only one** unhealthy **dependency** and **more than one** unhealthy **service**
    - check [IBMCloud Status](https://cloud.ibm.com/status/) to see if the outage is already being worked on
    - escalate to team responsible for the dependency (see table below)


3. If **multiple** unhealthy **services** and **multiple** unhealthy **dependencies**
    - escalate to all `app_owners` involved

External = This is a team outside our org, and there is no way to escalate via Pager Duty. Try the Slack channel instead.

| Name                                     | Slack                  | Escalation Policy                                     |
|:-----------------------------------------|:-----------------------|:------------------------------------------------------|
| Bootstrap                                | #armada-bootstrap      | https://ibm.pagerduty.com/escalation_policies#P42TSXQ |
| Resource Controller                      | #rc-adopters           | https://ibm.pagerduty.com/escalation_policies#PGPNMQI |
| MCCP (Manage Cloud Foundry Service Keys) | #mccp_dev              | https://ibm.pagerduty.com/escalation_policies#P7JAK7E |
| IAM Service IDs                          | #iam-issues            | External                                              |
| IAM ACMS                                 | #iam-issues            | https://ibm.pagerduty.com/escalation_policies#PSTWGB2 |
| IAM API Keys                             | #iam-issues            | External                                              |
| IAM Identity                             | #iam-issues            | External                                              |
| Ghost                                    | #global-search-tagging | https://ibm.pagerduty.com/escalation_policies#PIIBNSN |
| Key Protect                              | #key-protect           | https://ibm.pagerduty.com/service-directory/PABIH2D   |
| Billing                                  | #bss                   | https://ibm.pagerduty.com/escalation_policies#PICP7UN |
| Cloud Object Storage                     | #object-storage        | https://ibm.pagerduty.com/escalation_policies#P92X9R0 |
| Satellite Config                         | #razee                 | https://ibm.pagerduty.com/escalation_policies#PPNN2DT |
| OIDC                                     | #iam-issues            | External                                              |
| IAM PDP                                  | #iam-issues            | External                                              |
| OICD Keys                                | #iam-issues            | External                                              |
| BSS Account                              | #bss                   | https://ibm.pagerduty.com/escalation_policies#PICP7UN |
| IAM Clients                              | #iam-issues            | External                                              |
