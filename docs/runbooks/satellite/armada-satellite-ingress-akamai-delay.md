---
layout: default
description: How to handle Akamai delays for ingress subdomains and secrets
title: armada-ingress - delay in completing ingress akamai operations for Satellite location
service: armada
runbook-name: "armada-ingress - delay in completing akamai operations for Satellite location"
tags: alchemy, armada, ingress, satellite, location, deployment, subdomain, domain, akamai
link: /satellite/armada-satellite-ingress-akamai-delay.html
type: Troubleshooting
grand_parent: Armada Runbooks
parent: Satellite
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to handle dns subdomain registration and secret generation delays with Akamai taking longer than expected in Satellite Location.

## Example alerts which would have brought you here

- armada-origin-cert-secret-not-found (dns subdomain secrets taking too long to generate)
- carrier-env-info-configmap-not-found (dns subdomains taking too long to generate)
- satellite/ingress-not-generated (dns subdomain certificates taking too long to generate)

## When are these alerts triggered

Akamai alert is triggered when it takes longer than expected to register the Satellite location DNS records, and generate the corresponding certificates and secrets.

## Customer impact

If there are outages in Akamai, then until the outage is resolved most or all of the new location ordered will not get dns subdomains and certificates, and users will not be able to create nlb-dns subdomains and certificates. Once the outage is resolved, the retry logic in the dns-microservice will ensure all those clusters that were impacted will get the ingress/nlb-dns subdomain and certificate.

## Investigation and Action

1. Check the [Akamai status page](https://cloudharmony.com/status-for-akamai) to see if there are any outages. If there are current outages, no further investigation is required. Snooze the alert and inform the frontdoor team. Jump to [`Escalation Policy`](#escalation-policy) section.

1. There may be Akamai nameserver failures. If you see this alert together with `ArmadaDNSNameserverError` alert, this alert is just a symptom of the Akamai nameserver failures, follow the steps in the following runbook: [Akamai nameserver failures](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/master/docs/runbooks/armada/armada-dns-nameserver-failures.md). Snooze the alert and inform the frontdoor team. Jump to [Escalation Policy](#escalation-policy) section.

1. If you see network related failures, but Akamai seems healthy based on their status page and you don't see `ArmadaDNSNameserverError`, then it is possible that the issue is with one or more _armada-dns-microservice_ pods on a carrier.
  1. Restart all _armada-dns-microservice_ pods and monitor the failed requests.
  1. If you still see failures after restarting the pods, try reloading the worker nodes that are hosting the failing _armada-dns-microservice_ pods.
  1. If the issue is still persist, page armada-ingress to perform further investigation, see [Escalation Policy](#escalation-policy).

1. Kubernetes checks:
    - Check the status of armada-dns-microservice pods on the carrier to ensure they are running  
    `kubectl get pods -n armada | grep armada-dns-microservice`
    - Get the logs from armada-dns-microservice pods  
    `kubectl logs -n armada <pod name>`

1. In armada-xo, run `@xo clusterSubdomains <locationID>` and `@xo clusterSecrets <locationID>`.

1. Put the logs, pod output, and xo command outputs from the above step into a GHE issue in the frontdoor repo. Jump to [`Escalation Policy`](#escalation-policy) section.

## Escalation Policy
Once the initial investigation is performed

- Notify `armada-ingress` squad `@ingress` on the slack channel with the corresponding GHE issue - [#armada-ingress](https://ibm-argonauts.slack.com/archives/armada-ingress) about the issue.
- Snooze the Pagerduty alert for 24 hours, it should resolve on its own within that time.
- __Do not escalate this Pagerduty Alert__ please just open an issue [armada-frontdoor](https://github.ibm.com/alchemy-containers/armada-frontdoor/issues/) and the team will work on it during their normal working hours. 
- It may be necessary to raise an [Akamai support ticket](https://github.ibm.com/alchemy-containers/armada-frontdoor/blob/master/wiki/Important-Contacts/README.md#support-cases) and reach out to [Akamai contacts](https://github.ibm.com/alchemy-containers/armada-frontdoor/blob/master/wiki/Important-Contacts/README.md#akamai). This is likely something that the ingress team will do after an initial investigation, and the info is only included here for completeness.

## Reference

- Slack channels: [#armada-ingress](https://ibm-containers.slack.com/archives/armada-ingress)
- GHE issues: [armada-frontdoor](https://github.ibm.com/alchemy-containers/armada-frontdoor/issues/)
