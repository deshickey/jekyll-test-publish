---
layout: default
description: armada-log-collector high cluster store request failure rate
title: armada-log-collector high cluster store request failure rate
service: armada
runbook-name: "armada-log-collector high cluster store request failure rate"
tags: wanda, armada, log-collector, logging, carrier, cluster-stire, metrics, razee
link: /armada/armada-log-collector-cluster-store-errors.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# armada-log-collector High cluster store request failure rate

## Overview

armada-log-collector is unable to make API requests to cluster store. 

## Example alerts

Following pages are associated with this error
{% capture example_alert %}
  - `LogCollectorClusterStoreErrors`
{% endcapture %}
{{ example_alert }}
## Action to take

### Verify that COS is healthy

There is currently no status page for Cluster Store. Cluster Store relies heavily on COS (Cloud 
Object Storage) and there is currently no status page for them either. We've created an admin API 
that can be run on a carrier to check the status of both COS and Cluster Store. 
Steps to run:
1. From the pager duty alert gather the COS endpoint that is being called. This can be found under
`Labels` and is called `cos_endpoint`.
2. ssh into the master for a carrier within the region the page was triggered from. 
The list of carriers with their masters can be found in the [{{ site.data.monitoring.cfs-inventory.name }}]({{ site.data.monitoring.cfs-inventory.link }})
3. Find the names of the armada-log-collector pods by running `kubectl -n armada get pods -l app=armada-log-collector`.
4. Get the IP of one of the armada-log-collector pods: `kubectl -n armada describe pod aramda-log-collector-xxx-xxx | grep IP` 
5. Run the following command: `curl -X GET -w "%{http_code}\n" <POD_IP>:6969/admin/dependencies/cluster-store`. Look at the http status code 
for cluster store and COS and verify that they're both 200. If a services doesn't have
a status code of 200 then there is an issue with that service. Check the error you get back to 
see if the issue is with Cloud Object Store or Cluster Store.

An error message with Cluster Store will look like:

```
{"incidentID":"9bf07f19-231e-46c3-b1ba-6bdd4cd1262f","code":"E0018","description":"Error connecting with Cluster Store. Try again later.","type":"General"}500
```

An error message with Cluster Object Storage will look like:

```
{"incidentID":"8fdb8832-f457-4247-975f-0400394830ed","code":"E0017","description":"Error connecting with Cloud Object Storage. Try again later.","type":"General"}500
```

## Automation
None

## Escalation Policy

If COS appears to be:
- **unhealthy**
  1. Ask for support for the issue in [{{ site.data.teams.cloud-object-storage.comm.name }}]({{ site.data.teams.cloud-object-storage.comm.link }}). COS
    does not have an official escalation policy through Pager Duty and requested that support be asked for 
    in their slack channel. When reaching out for help tell them what endpoint you were trying to reach 
    and tell them you were unable to create a new bucket using that endpoint. Confirm that there is an 
    outage for that endpoint and that they're working to resolve it. 
  2. If you're unable to reach the COS team then escalate by paging [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}).
  
If Cluster Store appears to be:
- **unhealthy**
  1. Follow the runbook [armada-cluster-store - Cluster Store is Down](../armada/armada-cluster-store.html)  
  
If both COS and Cluster Store appear to be:
- **healthy**
  1. Open an issue against [{{ site.data.teams.armada-api.name }}]({{ site.data.teams.armada-api.issue }})
  1. Post in [{{ site.data.teams.armada-api.comm.name }}]({{ site.data.teams.armada-api.comm.link }})
  1. Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})
