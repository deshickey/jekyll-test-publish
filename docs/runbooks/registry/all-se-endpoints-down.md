---
layout: default
title: All SE endpoints down
type: Troubleshooting
runbook-name: 'All SE endpoints down'
description: How to handle reporting of all SE endpoints down in a registry region
service: Registry
link: registry/all-se-endpoints-down.html
grand_parent: Armada Runbooks
parent: Registry
---

Troubleshooting
{: .label .label-red}

# All SE endpoints down

## Overview

How to handle reporting of all SE endpoints down in a registry region

### Background

The Service Endpoints (SE) are registry endpoints on the private network, they offer the same functionality as the public endpoints but are used by IKS private clusters.

They are monitored by prometheus & blackbox-exporter from registry's healthcheck cluster (located in eu-central), this check has not received 200 OK from the /status endpoint in any zone and so registry may be down for IKS private users.

## Example Alerts

- `All SE endpoints down in prod-us-south`

## Investigation and Action

### Determine if this issue isolated to SE endpoints

This page will also fire if registry is down for everyone, look for these other pages:

- `All Public endpoints down in <region>` -> deal with this PD first and see if this resolves.
- `DOWN | Origin - reg-glob-<zone>-endpoint-<xx> | Pool - reg-glob | Response code mismatch error` -> deal with this/these PD/s first and see if this resolves.

If none of these PDs are triggered then this is an issue with the SE endpoint and you should continue following this runbook.

### Determine if this issue is with Registry or Service Endpoint

Run the [ServiceEndPointStatus](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Registry/view/All/job/ServiceEndpointStatus/) Jenkins job with CLUSTER set to the cluster name of one of the registry clusters, eg `registry-prod-us-south-az1`. The output will contain many SE endpoint statuses in a section like this (other regions may also be displayed):

```json
...
[
  "registry-prod-us-south-az1-1",
  "us-south-dal10-container-registry-registry-prod-us-south-az1-1-vm-d4533b5e",
  "Ready",
  "10.94.143.238:1:1",
  "166.9.12.114/23"
]
[
  "registry-prod-global-az2-1",
  "us-east-wdc06-container-registry-registry-prod-global-az2-1-vm-efd79a11",
  "Ready",
  "10.188.123.182:0:0",
  "166.9.22.3/23"
]
...
```

These are the Magic Boxes - a Magic Box is a reverse proxy used to get from the IKS private cluster (or other clients) to a registry over the private network. They are operated by the Service Endpoint team.

The first line in each element (eg: "registry-prod-us-south-az1-1") is the associated registry cluster (zone), the second (eg: "us-south-dal10-container-registry-registry-prod-us-south-az1-1-vm-d4533b5e") is the "Magic Box ID", the fourth (eg: "10.188.123.182:0:0") contains the status after the colons:  
`:<se_status>:<downstream_status>`  
Where the numbers are:

- SE status:
  - 1 accepting connections
  - 0 rejecting connections
- Upstream status (reigistry status):
  - 1 returning 200 OK
  - 0 returning non-200 status code
  - -1 rejecting connections or timing out

This means:

- If all zones in the region have SE status of `1` then this is probably a registry problem.
- If all zones in the region have SE status of `0` AND at all three zone have an upstream_status of `0` or `-1` then this is probably a registry problem.
- If all zones in the region have SE status of `0` and at least one has an upstream_status of `1` then this can be a transient state, re-run the job. If this condition persists then this is an SE problem and you should page the Service Endpoint team (details below).
- If there is a mix of statuses you should focus on zones with status of `:0:1` first, then look at zones with `1:x`, then other statuses.

### Paging the Service Endpoint team

If the previous steps show this is probably an SE issue, you can page them, they will need to know the Magic Box ID/s you're working with. Their PD service is called `Cloud Service Endpoint` and they are in [#private-marketplace](https://ibm-cloudplatform.slack.com/messages/C88C6N338) on IBM Watson Cloud Platform Slack.

### Debugging Registry's Private Ingress

If the previous steps show this is probably a registry issue, then follow these steps.

1. Select a zone to debug first, you may find best results by choosing clusters that had higher upstreram statuses first.

2. Connect kubectl to that registry cluster and run  
   `kubectl get cm konicle -o yaml`  
   If the `data` section contains `ready: false` or `private-override: false` then this zone has been deliberately disabled by the registry squad, go back to step 1 and pick the next zone.

3. Establish if the private ingress is accepting connections. If the upstream status is `0` or `1` it is accepting connections, if not it's worth looking at the ingress controllers. You can check if the ingress is at least up:  
   `kubectl -n kube-system get po`  
   will show pods like:

   ```txt
   kubernetes-dashboard-7b545fbb4d-v2j29                             1/1     Running   0          8d
   private-cr386b5d5d469f49eeb991164e1b848a4a-alb1-74b7f95d595lqsr   4/4     Running   0          5d
   private-cr386b5d5d469f49eeb991164e1b848a4a-alb1-74b7f95d597xtp8   4/4     Running   0          5d
   public-cr386b5d5d469f49eeb991164e1b848a4a-alb1-84c489c89c-7shp6   4/4     Running   0          5d
   public-cr386b5d5d469f49eeb991164e1b848a4a-alb1-84c489c89c-jnd24   4/4     Running   0          5d
   tiller-deploy-775c6b488f-6lghv                                    1/1     Running   0          8d
   ```

   The ones that begin with "private" are the private ingress controllers and pertain to SE, at least one and ideally both should be "Running". If they're not up you can try to work out why and make them be up, or you can page Registry.

4. Determine if the private ingress is returning 200 OK from it's status check.  
   Pick one of the private ingress controllers and run this command on it:  
   `kubectl -n kube-system exec -it <ingress_pod_name> -c nginx-ingress -- curl -D- http://localhost:10443/status`

   Given the result:

   - 200 OK - Evertything is fine but SE beleive it is not, probably something is stopping SE from making requests to registry over the private network on port 10443. Or there is a problem getting from the `registry-healthcheck` cluster to the Magic Box on it's front end IP (the one from the jenkins output that isn't a '10.').
   - 404 Not Found - The zone is unhealthy and has been automaticallty disabled, there should be one or more pages in Registry's PD related to microservices beong down or not working in this zone, deal with that/those pages.
   - Other HTTP status code or transport fault - Probably the "konicle" registry microservice is not working. Look for PDs in registry about konicle in this zone, or look at the konicle pods in the dafault kube namespace. If you can't fix it, page registry.

   NB: The private endpoits are only reachable from machines in accounts with VRF enabled that have static routes to get to 166.8.0.0/14 over the private network.

### Further Debugging/Monitoring

The PD is driven by an end-to-end test from registry's healthcheck-prod cluster through SE to the registry clusters in this region. It will auto-resolve when the issue is fixed. No further monitoring is required.

### RCA and pCIEs

This page is at least a pCIE. If the problem was not with the healthcheck-prod cluster (the client in the end-to-end test) then this probably is a CIE.

## Escalation Policy

- PagerDuty Escalation Policy: [Alchemy - Containers - Registry and Build (High Priority)
](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)
  - Slack channel: [Argonauts - registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE)
  - GHE repo link for issues with runbook or PD: [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)
