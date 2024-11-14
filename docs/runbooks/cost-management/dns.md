---
service: Cost Management
title: "Cost Management DNS"
runbook-name: "Cost Management DNS"
description: "Information on Cost Management DNS set up"
category: Cost Management
type: Informational # Alert, Troubleshooting, Operations, Informational
tags: cost, cost management, cost-management, dreadnought, service team, service, dns
link: /cost-management/cost-dns.html
failure: []
playbooks: []
layout: default
grand_parent: Armada Runbooks
parent: Cost Management
---

Informational
{: .label }

## Overview

DNS names for the service are hosted by CPUX in Akamai and CIS.

There are 3 DNS names for the service, one for each environment: dev, stage, and production.

The DNS names point to the global load balancers that have origins from the Dreadnought clusters in different regions.

> Note: The service APIs are all available under a "context url"; a root path called `iam-proxy`. E.g., the service's graphql API is available at https://cost-management-dreadnought.api.cloud.ibm.com`/iam-proxy/graphql.

## Detailed Information

### DNS Names

#### Global

The following table list the DNS names for the Cost Management service which are global endpoints.

| Environment | Endpoint                                             |
| ----------- | ---------------------------------------------------- |
| dev         | `cost-management-dev.api.test.cloud.ibm.com`         |
| stage       | `cost-management-dreadnought.api.test.cloud.ibm.com` |
| prod        | `cost-management-dreadnought.api.cloud.ibm.com`      |

#### Regional

Regional endpoints are also available, which allow for testing the service in a specific region by bypassing the global load balancer.

| Environment | Region     | Endpoint(s)                                                       |
| ----------- | ---------- | ----------------------------------------------------------------- |
| dev         | `us-south` | `cost-management-dev-us-south-dreadnought.api.test.cloud.ibm.com` |
|             |
| stage       | `au-syd`   | `cost-management-dreadnought-au-syd.api.test.cloud.ibm.com`       |
|             | `eu-de`    | `cost-management-dreadnought-eu-de.api.test.cloud.ibm.com`        |
|             | `eu-gb`    | `cost-management-dreadnought-eu-gb.api.test.cloud.ibm.com`        |
|             |
| prod        | `au-syd`   | `cost-management-dreadnought-au-syd-syd05.api.cloud.ibm.com`      |
|             |            | `cost-management-dreadnought-au-syd-syd04.api.cloud.ibm.com`      |
|             |            | `cost-management-dreadnought-au-syd-syd01.api.cloud.ibm.com`      |
|             | `us-east`  | `cost-management-dreadnought-us-east-wdc04.api.cloud.ibm.com`     |
|             |            | `cost-management-dreadnought-us-east-wdc06.api.cloud.ibm.com`     |
|             |            | `cost-management-dreadnought-us-east-wdc07.api.cloud.ibm.com`     |
|             | `eu-de`    | `cost-management-dreadnought-eu-de-fra02.api.cloud.ibm.com`       |
|             |            | `cost-management-dreadnought-eu-de-fra04.api.cloud.ibm.com`       |
|             |            | `cost-management-dreadnought-eu-de-fra05.api.cloud.ibm.com`       |

### Disabling a Region

Disabling and Enabling an origin in CIS is handled by the CPUX team. Please refer to the runbook for [Disabling a region in CIS](./disable-region-cis.html){:target="_blank"}.

For any DNS related issues, contact the CPUX team ([Brad Blondin](https://ibm.enterprise.slack.com/team/W4UJW5EKE){:target="_blank"}).

## Further Information

* [Cost Management internal team documentation](https://github.ibm.com/dataops/cost-management-docs-internal){:target="_blank"}