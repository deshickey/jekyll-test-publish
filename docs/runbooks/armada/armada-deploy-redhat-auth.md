---
layout: default
description: How to handle RedHat authorization failures for ROKS cluster creation and deletion.
title: armada-deploy - Resolving RedHat Authorization Failures
category: armada
service: armada-kubx-deployer
runbook-name: "armada-deploy - Resolving RedHat Authorization Failures"
tags: alchemy, armada-deploy, armada-kubx-deployer, RedHat, ROKS, OpenShift
link: /armada/armada-deploy-redhat-auth.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to handle alerts when `armada-kubx-deployer` is having issues authenticating to RedHat during either creation or deletion of a ROKS cluster. The authorization is used to create pull secrets during cluster creation and delete pull secrets during cluster deletion.

## Example Alerts

~~~~
Labels:
 - alertname = armada-deploy/armada_kubx_deployer_redhat_auth
 - alert_situation = armada-deploy/armada_kubx_deployer_redhat_auth
 - service = armada-kubx-deployer
 - severity = critical
Annotations:
 - summary = armada-kubx-deployer is experiencing consistent failures while attempting to process RedHat authentication requests.
 - description = armada-kubx-deployer has experienced 10 failures processing RedHat authentication requests over the last 15 minutes.
~~~~

## Automation (Required)
None

## Actions to take
1. Determine if the [accounts api endpoint](https://api.openshift.com/api/accounts_mgmt/v1/) is functional.
   - Go to the url and ensure you see a valid response.
   - If you do not get a valid response, visit https://status.quay.io/ to see if any additional information is available.
   - If the endpoint is down, a CIE will need to be created.
1. Determine if the one or both `methods` of authentication are failing. The first method is `jwt`, if that fails the service attempts to use the `token` method.
   - Go to prometheus for the region where the alert is being generated.
   - Run the prometheus query: `(sum by (status,method) (count_over_time(armada_kubx_deployer_redhat_auth{}[1h])))`.
   - Identify the `method` of the failures. You should either see `jwt` or both `jwt` and `token`. See the examples below.
   - Switch to the table view in Prometheus to see the timeline view to determine if the failures are recent or are no longer occurring.
   - If the `method` of `token` is actively failing, then a CIE will need to be created as both authentication methods are failing.
1. If a CIE is required, create one with the title: `The creation and deletion of OpenShift clusters is currently impacted`
1. Contact [RedHat support](https://access.redhat.com/support) by either opening a ticket or through live chatting if available.
   - Indicate that the RedHat OpenShift on IBM Cloud service cannot authenticate to RedHat and the creation and deletion of clusters is impacted.
   - Indicate if the endpoint is working: https://api.openshift.com/api/accounts_mgmt/v1/
   - Indicate if the `jwt` method of authentication is failing. We use a JWT token signed with a private key `PROD_GLOBAL_REDHAT_SERVICE_ACCOUNT_KEY` in [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/tree/master/build-env-vars/openshift) to authenticate to RedHat for the service account `2AtM67Ysf2lSXSQZIejS4LLhOfI` with the username `ibmcloud-rhoic-prod2`. Note this service account is linked to the IBM RedHat account `6525254`.
   - Indicate if the `token` method of authentication is failing. This is a backup method of authentication. We use a static refresh token  `PROD_GLOBAL_REDHAT_OCM_API_ENDPOINT_AUTH` in [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/tree/master/build-env-vars/openshift) to authenticate to RedHat for the account `6525254`.
1. Once proper support contact is made, continue to monitor the prometheus query for updates.


### Example prometheus query results
Results indicating no issues.
```
{method="jwt", status="success"}     94
```

Results indicating only the `jwt` method of authentication is failing (no CIE):
```
{method="jwt", status="success"}     34
{method="jwt", status="failed"}      14
{method="token", status="success"}   14
```

Results indicating both the `jwt` and `token` methods of authentication are failing (CIE):
```
{method="jwt", status="success"}      5
{method="jwt", status="failed"}     311
{method="token", status="failed"}   311
```

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
