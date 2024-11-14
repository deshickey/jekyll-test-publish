---
layout: default
title: armada-cluster-squad - ProviderRiaasAPIDownstreamProtocolError
type: Alert
runbook-name: "armada-cluster - ProviderRiaasAPIDownstreamProtocolError"
description: "armada-cluster - Provider RIAAS API Downstream Protocol Error 555"
service: armada-cluster
link: /cluster/cluster-squad-provider-riaas-api-downstream-protocol-error.html
playbooks: []
failure: []
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert means that URL mismatch failures have occured while paginating through a series of API operations.

## Example Alert

Example PD title:
- `#30960XXX: bluemix.containers-kubernetes.prod-wdc07-carrier2.armada-cluster_provider_apiclient_downstream_protocol_555_errors_g2_555`

## Actions to take

1. Raise issue against [troutbridge](https://github.ibm.com/alchemy-containers/troutbridge/issues/new) for tracking
    - Give the issue a clear title which suggest that an API pagination error has occured. Example: "Downstream protocol 555 errors in armada-provider-riaas"
    - Give the issue the "interrupt" label

2. Open the LogDNA instance for the region affected.
    - Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment
    - In the left hand pane under `CLUSTER-SQUAD` open the view called `555-status-codes`
    - Run the following query `"statusCode":"555"`
    - Capture the following fields: `caller`, `req-id`, `status`, `statusCode`, `url`

4. Discuss with troutbridge squad
    - Attach the collected logs to the created issue

3. Snooze further alerts
    - Snooze the alerts while the troutbridge squad investigates

## Escalation Policy

**Slack Channel**: You can contact the dev squad in the [#armada-cluster](https://ibm-argonauts.slack.com/archives/C54FV49RU) channel.
