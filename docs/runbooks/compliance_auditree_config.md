---
layout: default
title: Setting up travis for auditree
type: Informational
runbook-name: "compliance_auditree_config"
description: "This runbook describes the values set in auditree travis"
service: Conductors
link: /compliance_auditree_config.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Documents the variables used in the travis configuration for auditree builds

## Detailed information

Documents what variables and values to set, where you generate them from or find them, when setting up travis auditree builds

## Parameters to set

Example travis setup for [non-prod auditree](https://travis.ibm.com/alchemy-auditree/auditree_config_non-prod)

Under `More options -> Settings` the following environment variables are set.  This is where you either find the values when setting up a new auditree instance, or generate the values from

| Variable name | Value to set | 
| ------- | -------------- | 
| `ARTIFACTORY_API_KEY` | Value is stored in [Thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/42577/general)  | 
| `ARTIFACTORY_USER`  | Use `conauto@uk.ibm.com` |
| `GITHUB_ENTERPRISE_TOKEN` | Log into github.ibm.com as `conauto@uk.ibm.com` and generate a Github token |
| `GITHUB_ENTERPRISE_USERNAME` | `conauto@uk.ibm.com` |
| `IBM_CLOUD_ARGO_DEV_API_KEY` | This is an IBM Cloud APIKey and used to log into the Cloud account to perform an IKS cross check.  Log into the desired cloud account as `conauto@uk.ibm.com` and generate a new Cloud APIKey.  The variable name is made up of `IBM_CLOUD` followed by the name given in the config - an example is `ARGO_DEV` [here](https://github.ibm.com/alchemy-auditree/auditree_config_non-prod/blob/master/auditree.json#L66) - followed by `_API_KEY` <p> Sometimes, the Compliance team may need this API key restricted to just see a subset of clusters.  In the Dev Containers 1186049 account, they have a `service-id` named `compliance-vuln-check-auditree
` where the API key should be created - this gives access to just the `vuln-check` clusters they own - discuss this with the Compliance team if necessary |
| `SLACK_WEBHOOK` | Get from Tim Kelsey | 
| `SOS_INVENTORY_API_KEY` | Use the value stored in [thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/28231/general) | 
| `SOS_INVENTORY_EMAIL` | `conauto@uk.ibm.com` |
| `IBM_CLOUD_SOSIMAGES_API_KEY` | Use the value stored in [thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/58263/general) |
| `SOS_REPORTS_API_KEY` | Use the value stored in [thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/42585/general) |
| `XFORCE_KEY` and `XFORCE_PWD` | Go to [xforce](https://exchange.xforce.ibmcloud.com/settings/api), login as `conauto` and generate a new APIKEY/PWD pair |
| `IBM_CLOUD_REGISTRY_API_KEY` | Create a new Cloud APIKEY as conauto in 1185207 Alchemy Production account - Give it a sensible name that makes it identifiable to where it is used - i.e. `registry-access-iks-dev-auditree` |


## Escalation Policy
SRE or compliance squad

Paul Cullen and Tim Kelsey have most knowledge in this area
