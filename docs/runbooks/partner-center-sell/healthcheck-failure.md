---
layout: default
title: "Partner Center Sell - Synthetics healthcheck failure"
runbook-name: "Partner Center Sell - Synthetics healthcheck failure"
description: "Synthetics healthcheck failure"
category: Partner Center Sell
service: Partner Center Sell
tags: healthcheck failure, partner-center-sell, PCS, partner center sell health check
link: /partner-center-sell/healthcheck-failure.html
type: Informational
grand_parent: Armada Runbooks
parent: Partner Center Sell
---

Informational
{: .label }

## Overview
This describes the process how to handle Partner Center Sell synthetics healthcheck failures.

## Detailed Information

PCS service is deployed in 3 regions ( `au-syd`, `eu-de`, `us-east`), there are 3 clusters in each region. There are total 9 synthetics healtchecks monitoring the service deployed in each cluster. The tests run every 5 minutes and if a healtcheck fails 3 times in a row it will trigger a PagerDuty alert.

## Debug steps

Healthcheck failures can occure due to multiple reasons. Most common reason is an issue with the infrastructure. (node, pod, istio failure).

### Issue with the service in 1 cluster only

If the synthetics test failure happens only in 1 cluster/zone the PCS service would be uninterrupted as CIS LoadBalancer would move traffic to other healthy region. This case please slack PCS SRE team - `#dn-product-lifecycle-alerts` - to look into it the next business day.

### Issue with a region

If healthchecks fail in multiple zones/regions please alert [PCS pagerduty](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/partner-center-sell/pcs-escalation.html){:target="_blank"}

## Further Information

Synthetics will not set `resolved` PagerDuty event so every incident has to be closed manually.