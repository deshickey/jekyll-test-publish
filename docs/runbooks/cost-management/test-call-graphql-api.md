---
service: Cost Management
title: "Cost Management call to /graphQL API"
runbook-name: "Cost Management call to /graphQL API"
description: "How to make a call to the /graphQL API for pricing services"
category: Cost Management
type: Operations # Alert, Troubleshooting, Operations, Informational
tags: cost, cost management, cost-management, dreadnought, service team, service, graphql, api, test, pricing
link: /cost-management/cost-test-graphql-api.html
failure: []
playbooks: []
layout: default
grand_parent: Armada Runbooks
parent: Cost Management
---

Ops
{: .label .label-green}

## Overview

Making a call to the `/graphQL` pricing API is a good way to check whether the service is up and running as intended.

## Detailed Information

The Infracost CLI communicates with a graphQL server to retrieve pricing for products found in the Terraform. However, queries can be made directly to the server.

## Detailed Procedure

### Generate an IAM API Key

To query the graphQL server API endpoint an API key needs to be generated.

1. Log into an IBM Cloud account
	* Production: [https://cloud.ibm.com](https://cloud.ibm.com){:target="_blank"}
	* Staging: [https://test.cloud.ibm.com](https://test.cloud.ibm.com){:target="_blank"}
1. Click on "Manage"
1. Click on Access (IAM)
1. Click on "API Keys" and generate an API key with any name and description that you want. Note down the API key, since you will not have access to this once the modal closes.

### Generate an IAM Access Token

Generate an identity token against the appropriate IAM endpoint:
* Production: [https://iam.cloud.ibm.com/identity/token](https://iam.cloud.ibm.com/identity/token){:target="_blank"}
* Staging: [https://iam.test.cloud.ibm.com/identity/token](https://iam.test.cloud.ibm.com/identity/token){:target="_blank"}

```sh
curl -X POST '<IDENTITY_TOKEN_ENDPOINT>' -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=<IBM_CLOUD_API_KEY>'
```

### Run Sample graphQL query

> Important: If queries are made against the **staging** graphQL endpoint, then use a **staging** IBM Cloud account to create the API Key to generate the IAM token. If queries are made against the **production** graphQL endpoint, use a **production** IBM Cloud account to create the API key to generate the IAM token.

Run a sample graphQL query using the access token in the Authorization header.

The query below query against the pricing server in production for the Cloudant service in `us-south`:

```sh
curl https://<COST_URL>/iam-proxy/graphql -H 'Authorization: Bearer <IBM_CLOUD_ACCESS_TOKEN>' -H 'x-api-key:SELF_HOSTED' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection:keep-alive' -H 'DNT: 1' --data-binary '{"query":"query { products(filter: {\n vendorName: \"ibm\"\n service: \"cloudantnosqldb\"\n region: \"us-south\"\n})\n {\n attributes{ \n key \n \tvalue\n }\n service\n sku\n region\n prices {\n\t\t\tunit\n USD\n effectiveDateStart\n effectiveDateEnd\n startUsageAmount\n endUsageAmount\n termLength\n }\n }\n}\n\n"}' --compressed
```

Where the `COST_URL` can be any one of the Cost Management DNS endpoints specified in the [DNS runbook]().

## Further Information

* [GitHub repository `cloud-pricing-api`](https://github.ibm.com/dataops/cloud-pricing-api){:target="_blank"}
* [GitHub repository `cloud-pricing-api-iam-proxy`](https://github.ibm.com/dataops/cloud-pricing-api-iam-proxy){:target="_blank"}
* [GitHub repository `infracost-cli`](https://github.ibm.com/dataops/infracost-cli){:target="_blank"}
* [Cost Management internal team documentation](https://github.ibm.com/dataops/cost-management-docs-internal){:target="_blank"}
