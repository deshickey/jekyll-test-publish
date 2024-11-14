---
layout: default
description: Schematics - Steps for investigating schematics end point down
title: Schematics - Investigate Endpoint Down
service: schematics
runbook-name: "Schematics - Investigate Endpoint Down"
tags: schematics, endpoint down
link: /schematics/schematics-endpoint-down.html
type: Alert
grand_parent: Armada Runbooks
parent: Schematics
---

Alert
{: .label .label-purple}

## Overview

The test for schematics endpoint availability is configured via sysdig agents to connect to the `/v1/version` endpoint of the various schematics domains.
CIS also does a health check by connect to the `/v1/version` endpoint for the configured origin pools.
When the response code is not '200' from these health checks, an alert is triggered.

**Permission required**: Please follow [schematics access runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/schematics/Introduction_to_Schematics_Infrastructure.html) to get the required permission to access Schematics Environment.


## Example Alerts

##### 1. Triggered by Sysdig

- **Source**: Sysdig
- **Alert Name**: `"[Schematics] Endpoint down is Triggered`
- **Alert condition**: `"avg(max(http.can_connect))"` less than `1` <br>
Example: [https://ibm.pagerduty.com/incidents/PTHWIHO](https://ibm.pagerduty.com/incidents/PTHWIHO)

##### 2. Triggered by CIS

- **Source**: CIS
- **Alert Name**: `"DOWN | Origin <origin name> | Pool <orgin pool name>" | <Reason>`
Example: [https://ibm.pagerduty.com/alerts/PJR7M7K](https://ibm.pagerduty.com/alerts/PJR7M7K)

## Actions to take

### Investigation

If the alert has the prefix `*EU*` then it means the alert is triggered from one of the EU clusters or if the prefix is `*BNPP*` then the alert is triggered from the BNPP/eu-fr2 cluster. Otherwise, it is from one of the US-South/US-East clusters.


#### Steps
##### If the alert is from Sysdig, check the description of the alert in the PD incident
For Example :
`Description: Endpoint down Entity:url = 'https://eu-de.schematics.cloud.ibm.com/v1/version' Condition: avg(max(http.can_connect)) < 1 Value: [{aggregation:max,groupAggregation:avg,metric:http.can_connect,value:0.6666666666666667}]`

The description specifies the endpoint that is currently not available at the moment.

##### If the alert is from CIS, check the PD incident title
For Example:
`DOWN | Origin - schematics-prod.eu-gb | Pool - schematics-prod-eu-pool | HTTP timeout occurred`
Note down the origin value. The region name in the origin specifies the endpoint that is down.
In the above alert, the eu-gb regional endpoint `https://eu-gb.schematics.cloud.ibm.com/v1/version` is not reachable.

The possible values for url are

-  eu-de  <br>
   [https://eu-de.schematics.cloud.ibm.com/v1/version](https://eu-de.schematics.cloud.ibm.com/v1/version)

-  eu-gb  <br>
   [https://eu-gb.schematics.cloud.ibm.com/v1/version](https://eu-gb.schematics.cloud.ibm.com/v1/version)

-  eu-de and/or eu-gb  <br>
   [https://eu.schematics.cloud.ibm.com/v1/version](https://eu.schematics.cloud.ibm.com/v1/version)

-  us-east <br>
   [https://us-east.schematics.cloud.ibm.com/v1/version](https://us-east.schematics.cloud.ibm.com/v1/version)

-  us-south <br>
   [https://us-south.schematics.cloud.ibm.com/v1/version](https://us-south.schematics.cloud.ibm.com/v1/version)


### Check if the endpoint is reachable

Try to access the endpoint manually from browser or curl command. If it returns a proper response without any error, the issue is resolved.

<a href="images/Schematics-EndpointDown-Pic1.png">
<img src="images/Schematics-EndpointDown-Pic1.png " alt="Schematics-EndpointDown-Pic1" style="width: 300px;"/></a>

##### If the alert is from Sysdig
The PD Incident will auto resolve if access to endpoint url is successful. Otherwise proceed to next steps.

##### If the alert is from CIS
The PD Incident `DOWN | Pool - schematics-prod-eu-de-pool` will be triggered when the schematics-prod-eu-de-pool is down. If it is back up again then `UP | Pool - schematics-prod-eu-de-pool` will be triggered. At this point these two PD Incidents need to be MANUALLY resolved. If `UP | Pool - schematics-prod-eu-de-pool` is not received even after endpoint url successuflly responded, proceed to next steps below.
 
### Explore other PD Incidents 

1. In the pagerduty check for other alerts that are triggered around the same time.
  If there are alerts like 'API Pods Available less than desired' or multiple 'Node down' alerts,
  then follow the related runbooks for those alerts.

2. If there are no other alerts identified in pagerduty, check for the general network availability of wider IBM cloud services. Check the [IBM cloud status page](https://cloud.ibm.com/status) for any downtime announced.

3. Follow the escalation step if the issue is not resolved.

## Automation

None

## Escalation Policy
- Slack channel - [#schematics-dev](https://ibm-argonauts.slack.com/archives/GHFT8J7CJ)
- PD escalation policy : [schematics-prod-sev1](https://ibm.pagerduty.com/escalation_policies#PNZJB5U)

