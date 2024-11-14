---
layout: default
title: Specification of infra-iemrelay machines
type: Informational
runbook-name: "Specification of infra-iemrelay machines"
description: "Specification of infra-iemrelay machines"
service: Conductors
link: /sre_infra-iemrelay_spec.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details information about all of the specification of `infra-iemrelay` machines 

## Detailed information

### Machine specification required 

Order a machine via [order server page](https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/verify_page) on the provisioning website

The order should use [template infra-iemrelay-ubuntu18-localdisk](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/config/templates.json) (This links to the saved GHE source which the provisioning interface is built from)

The template can be viewed on the [provisioning application template list](https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/templates/list)

Current specification is as follows:

```
"description": "2 x 2.0 GHz or higher Cores",
"ram_item": "RAM_4_GB",
"disks": {
    "guest_disk0": "GUEST_DISK_25_GB_LOCAL"
},
"core_item": "GUEST_CORES_2",
"port_speed_item": "1_GBPS_PRIVATE_NETWORK_UPLINK",
 "os_item": "OS_UBUNTU_18_04_LTS_BIONIC_BEAVER_MINIMAL_64_BIT",
"bandwidth_item": "BANDWIDTH_0_GB",
"machine_type": "virtual server"
```

The machine needs to be ordered onto the `CSMG` VLAN for the region it is being deployed to.

### Deployment / post ordering setup

The ordering of the machine should execute all the necessary ansible playbooks in bootstrap-one.

Once a full bootstrap has completed successfully, raise an [SOS ticket](https://ibm.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D45ef56a7db7c4c10c717e9ec0b96193a%26sysparm_link_parent%3D109f0438c6112276003ae8ac13e7009d%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default%26sysparm_view%3Dcatalog_default) against `SOS bigfix` requesting that the server is promoted to be an iemrelay server.

## Escalation Policy

There is no formal escalation policy.

Reach out to SRE squad members in these channels to ask further questions about any of the machine types

- `#conductors` if you are not a member of the SRE Squad.
- `#sre-cfs` or `#conductors-for-life`  if you are a member of the SRE squad (these are internal private channels)


