---
layout: default
description: How to handle akamai failures for ingress and nlb-dns subdomains
title: armada-ingress - failure to complete a akamai operation for a cluster
service: armada
runbook-name: "armada-ingress - failure to complete akamai operation for cluster"
tags: alchemy, armada, ingress, controller, ingress-controller, deployment, subdomain, domain, akamai
link: /armada/armada-ingress-akamai-failure.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to handle Akamai failures for IBM assigned ingress/nlb-dns subdomains.

## Example alerts which would have brought you here

- ArmadaDNSAkamaiFailureRateShortWindow
- ArmadaDNSAkamaiFailureRateSLongWindow

## When are these alerts triggered

Akamai failure alert is triggered when armada-dns-microservice fails to register/unregister IBM assigned ingress/nlb-dns hostnames in akamai or create/modify/delete GTM in akamai.

## Customer impact

If there are outages in akamai, then until the outage is resolved most or all of the new clusters ordered will not get a ingress subdomain and ingress certificate, and users will not be able to create nlb-dns subdomains and certificates. Once the outage is resolved, the retry logic in the dns-microservice will ensure all those clusters that were impacted will get the ingress/nlb-dns subdomain and certificate.

## Investigation and Action

1. Check the [Akamai status page](https://edgedns.status.akamai.com/) to see if there are any outages. If there are current outages, no further investigation is required. Snooze the alert and inform the frontdoor team. Jump to [`Escalation Policy`](#escalation-policy) section.

1. Check the status of armada-dns-microservice pods to ensure they are running  
    `kubectl get pods -n armada -l app=armada-dns-microservice`
1. Get the errors from armada-dns-microservice pods  
   -  Select the correct regional IBM Cloud Logs instance in [Alchemy Production's Account 1185207](https://cloud.ibm.com/observe/logging)
   - Select armada-dns-microservice from the app list
   - Select `ERROR` from the `Levels` drop down
   - Find and analyze as many unique recent errors as you can 
1. If you see network related failures, but Akamai seems healthy based on their status page and you don't see `ArmadaDNSNameserverError`, then it is possible that the issue is with one or more _armada-dns-microservice_ pods on a carrier.
  1. Restart all _armada-dns-microservice_ pods and monitor the failed requests.
  1. If you still see failures after restarting the pods, try reloading the worker nodes that are hosting the failing _armada-dns-microservice_ pods.
  1. If the issue is still persist, page armada-ingress to perform further investigation, see [Escalation Policy](#escalation-policy).

1. If you usure what can be the problem or the root cause, page armada-ingress to perform further investigation, see [Escalation Policy](#escalation-policy).

## Escalation Policy

1. Create a GHE Issue against [armada-frontdoor](https://github.ibm.com/alchemy-containers/armada-frontdoor/issues/) and provide results from the investigation.
1. Also, inform the armada-ingress squad about the problem via slack in [#armada-ingress](https://ibm-containers.slack.com/archives/armada-ingress) with the GHE issue link.
1. It may be necessary to raise an [Akamai support ticket](https://github.ibm.com/alchemy-containers/armada-frontdoor/blob/master/wiki/Important-Contacts/README.md#support-cases) and reach out to [Akamai contacts](https://github.ibm.com/alchemy-containers/armada-frontdoor/blob/master/wiki/Important-Contacts/README.md#akamai). This is likely something that the ingress team will do after an initial investigation, and the info is only included here for completeness.

If the above steps said to page armada-ingress, then please escalate the PagerDuty alert  [Armada - containers tribe - Ingress](https://ibm.pagerduty.com/escalation_policies#PPDGLNB), including details of the GHE ticket raised.