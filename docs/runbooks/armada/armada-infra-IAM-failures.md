---
layout: default
title: How to deal with IAM errors
type: Alert
runbook-name: "armada-infra - IAM service reporting errors"
description: "IAM login service is failing - customers are not able to log into containers-kubernetes"
category: Armada
service: Containers
tags: armada, IAM, containers
link: /armada/armada-infra-IAM-failures.html
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
IAM is reporting `500` errors to customers who are trying to use armada.  This may mean those users will be having difficulty logging in (a small number of errors from a very large number of requests doesn't necessarily mean users are prevented from accessing).

## Example alert(s)
- A list of all possible alerts which could bring the user to this runbook

## Actions to take
General text

### Verify the issue

{% capture capture_example %}
To verify, point your browser to the prometheus front end for the relevant datacenter, eg:

 > `https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier1/prometheus`  
   (use the links below and replace `RegionXXX` and `carrierXXX` appropriately)

The alert is triggered on the query:
* `sum(delta(api_response_codes{method=~'(?i).*iam.*', rc=~"5.."}[10m]))`  
  https://alchemy-dashboard.containers.cloud.ibm.com/RegionXXX/carrierXXX/prometheus/graph?g0.range_input=1h&g0.expr=sum(delta(api_response_codes%7Bmethod%3D~%27(%3Fi).*iam.*%27%2C%20rc%3D~%225..%22%7D%5B10m%5D))&g0.tab=0

to get more information, run with:
* `delta(api_response_codes{method=~'(?i).*iam.*', rc=~"5.."}[10m])`  
  https://alchemy-dashboard.containers.cloud.ibm.com/RegionXXX/carrierXXX/prometheus/graph?g0.range_input=1h&g0.expr=delta(api_response_codes%7Bmethod%3D~%27(%3Fi).*iam.*%27%2C%20rc%3D~%225..%22%7D%5B10m%5D)&g0.tab=0  
  _that gives the number of 5xx error codes returned by IAM in the last 10 minutes_
{% endcapture %}  
{{ capture_example }}  

### Corrective actions

{% capture capture_example %}
There is little that we can do here - determine whether the issue is coming from the identity or access-management portion of IAM and escalate to the appropriate team.

Query for identity issues:
* `delta(api_response_codes{method=~'(?i).*NewUserAPIKey.*|(?i).*IsUserAPIKeyNotFound.*', rc=~"5.."}[10m])`

Query for access-management issues:
* `delta(api_response_codes{method=~'(?i).*IsAuthorized.*|(?i).*CreateUserPolicy.*|(?i).*DeleteResourcePolicies.*|(?i).*ResourceRoles.*', rc=~"5.."}[10m])`
{% endcapture %}  
{{ capture_example }}  



## Automation
- Point out any automation scripts or Jenkins jobs that can be used to either
  fix the alert or at least collect important information

- Put None if there is no automation available yet

## Escalation Policy
General text

{% capture capture_example %}
For identity issues escalate in Pager Duty to:
* `Duty Manager - Germany - Policy`

For access-management issues escalate in Pager Duty to:
* `IAM - Access Management - Sev1`

Slack channels which are monitored by the IAM team are:

- [#iam-issues](https://ibm-argonauts.slack.com/messages/C3C46LY7N)

{% endcapture %}  
{{ capture_example }}  


## Reference






