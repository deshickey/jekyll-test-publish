---
layout: default
description: How to handle private dns alerts
title: private-dns-alerts
service: armada
runbook-name: "private-dns-alerts"
tags:  armada, pdns-monitoring
link: /armada/private-dns-alerts.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

All VPC Gen 2 clusters and workload running on them use IBM Cloud private DNS for DNS lookup. Hence we need to monitor private DNS to know when there is an outage. Private DNS monitoring components are deployed to hub carrier in each zone and notify us if DNS checks start to fail.

## Example Alert(s)

TBD

## Investigation and Action

### Actions to take

Determine the domain facing an outage. Check `job` field on alert. 

| job | Domain |
| -- | -- |
| containers_private-dns | `private.<region>.containers.cloud.ibm.com` |
| containers_origin-dns | `origin.<region>.containers.cloud.ibm.com` |
| containers_ingress-dns | `<region>.containers.cloud.ibm.com` |
| icr_registry-dns | `<geo>.icr.io` |


Check if there is any other alert for given domain. 
- If there are other alerts in addition to `PrivateDNSCheckFailing` for a domain for which alert is raised, a wider outage is suspected. Do not proceed further on this runbook. Please investigate further on other alerts.
- If there is no other alert for a domain, private DNS is facing an outage. Proceed to [Raise a pCIE](#raise-pcie).

### Raise pCIE

Raise a pCIE with following template:
```
TITLE: Customers might experience issues with DNS on VPC gen2 clusters

SERVICES/COMPONENTS AFFECTED:
- IBM Kubernetes Service
- OpenShift on IBM Cloud

IMPACT:
- IBM Kubernetes Service, using VPC Gen2 infrastructure
- Kubernetes workload in VPC Gen2 infrastructure

STATUS:
- 202X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
```

Check in [ibmcloud-private-dns](https://ibm-argonauts.slack.com/archives/CL3TZLJRH) for issue with private DNS.

### Test private dns yourself

We can test if private dns is functional for a domain. Login to one of carrier worker and perform `dig` command against private DNS servers. There are 6 IPs for private DNS we need to check. `161.26.0.7 161.26.0.8 161.26.0.10 161.26.0.11 10.0.80.11 10.0.80.12`.  
```
for ip in 161.26.0.7 161.26.0.8 161.26.0.10 161.26.0.11 10.0.80.11 10.0.80.12; do dig @$ip private.<region>.containers.cloud.ibm.com; done
```

## Escalation Policy

Private DNS monitoring is owned by SRE. If there is no issue with private DNS and alert found to be false positive, snooze the alert and contact EU squad in normal working hours. You can test yourself as described in [Test private dns yourself](#test-private-dns-yourself) section to confirm issue with private DNS. 
