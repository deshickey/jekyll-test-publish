---
layout: default
description: How to Contact IBM Cloud Infra during a CIE
title: How to Contact IBM Cloud Infra
service: Conductors
runbook-name: "How to Contact IBM Cloud Infra"
link: /sre_cie_contact_ibm_infra.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# How to Contact IBM Cloud Infra

## Overview

This runbook details how to contact IBM Cloud Infrastructure/IaaS during CIEs

## Detailed Information

### Raise a sev1 ticket

1. Choose account
- 531277 - Account that holds production IKS infra
    - For outages caused by many nodes NotReady, or similar
- 1185207 - Account that patrol workers are provisioned in
    - For outages where customers are unable to manage clusters, but our infra appears intact.

note: There may be some overlap between the two accounts. This is alright. Use your best judgement where to raise the ticket.

1. Raise a sev1 ticket https://cloud.ibm.com/unifiedsupport/cases/form

1. Choose category
- For network issues:
    - Virtual Router Appliance (use this one for region/zone wide outages)
    - VLAN
    - Subnet/IPs

note: the above 3 categories should all be routed to the same group, NRE (Network Reliability Engineering). If you are unsure which to use, use Virtual Router Appliance (vyattas). This is highest level.

- For Issues with VMs:
    - Bare Metals (This will get routed to ACS Compute, the team we need to investigate VM issues. Use this category until VM is an option)
    - Virtual Machines (This is not yet an option. Sarah is working with SNow to get it added)

### Ensure correct routing and request escalation of ticket

Ensure that NRE is investigating network issues, or ACS Compute is investigating issues with VMs, and that both are aware of the seriousness of the ticket.
1. If during US hours, ping our TAM in #containers-cie. Currently Sarah Sandel (@Sarah). If Sarah is not availible, try our backup. Currently Brian Fleming (@Brian), also US hours.
2. If after hours or our TAM is not online, ping the AVM. The AVM will join #containers-cie once the incident status is moved from `normal` state to `potential cie`

### Other channels to request support

1. If no one is responding you can also try contacting IBM Infra in the following channels:
- `#cloud-support` - general IaaS issues
- `@acs-compute-team` in `#sl-compute-sre` - For issues with BMs or VMs
- `@acs-network-team` in `#iaas-nre` - For networking issues

Note: you must be in ibm-cloudplatform slack in order to be able to find the above group names
