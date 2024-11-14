---
layout: default
description: armada-log-collector high cos request failure rate
title: armada-log-collector high cos request failure rate
service: armada
runbook-name: "armada-log-collector high cos request failure rate"
tags: wanda, armada, log-collector, logging, carrier, cos, metrics
link: /armada/armada-log-collector-cos-errors.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# armada-log-collector High COS request failure rate

## Overview

armada-log-collector is unable to make API requests to COS (Cloud Object Storage). 

## Example alerts

Following pages are associated with this error
{% capture example_alert %}
  - `LogCollectorCosErrors`
{% endcapture %}
{{ example_alert }}
## Action to take

### Verify that COS is healthy

There is currently no status page for COS. We've created an admin API that can be run on a carrier to check the 
status of the COS endpoint. 
Steps to run:
1. From the pager duty alert gather the COS endpoint that is being called. This can be found under
`Labels` and is called `cos_endpoint`. 
2. ssh into the master for a carrier within the region the page was triggered from. 
The list of carriers with their masters can be found in the [{{ site.data.monitoring.cfs-inventory.name }}]({{ site.data.monitoring.cfs-inventory.link }})
3. Find the names of the armada-log-collector pods by running `kubectl -n armada get pods -l app=armada-log-collector`.
4. Get the IP of one of the armada-log-collector pods: `kubectl -n armada describe pod aramda-log-collector-xxx-xxx | grep IP` 
5. Run the following command: `curl -X GET -w "%{http_code}\n" <POD_IP>:6969/admin/dependencies/cos?endpoint=<cos-endpoint>`. Look at the http status code 
and verify that it's 200. If not then there is an issue with COS. 

An error message with Cluster Object Storage will look like:

```
{"incidentID":"8fdb8832-f457-4247-975f-0400394830ed","code":"E0017","description":"Error connecting with Cloud Object Storage. Try again later.","type":"General"}500
```

## Automation
None

## Escalation Policy

If COS appears to be :
- **healthy**
  1. Open an issue against [{{ site.data.teams.armada-api.name }}]({{ site.data.teams.armada-api.issue }})
  1. Post in [{{ site.data.teams.armada-api.comm.name }}]({{ site.data.teams.armada-api.comm.link }})
  1. Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})
- **unhealthy**
  1. Ask for support for the issue in [{{ site.data.teams.cloud-object-storage.comm.name }}]({{ site.data.teams.cloud-object-storage.comm.link }}). COS
  does not have an official escalation policy through Pager Duty and requested that support be asked for 
  in their slack channel. When reaching out for help tell them what endpoint you were trying to reach 
  and tell them you were unable to create a new bucket using that endpoint. Confirm that there is an 
  outage for that endpoint and that they're working to resolve it. 
  2. If you're unable to reach the COS team then escalate by paging [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}).
