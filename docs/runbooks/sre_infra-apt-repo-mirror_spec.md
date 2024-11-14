---
layout: default
title: Specification of infra-apt-repo-mirror machines
type: Informational
runbook-name: "Specification of infra-apt-repo-mirror machines"
description: "Specification of infra-apt-repo-mirror machines"
service: Conductors
link: /sre_infra-apt-repo-mirror_spec.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details information about all of the specification of infra-apt-repo-mirror machines 

## Detailed information

### Machine specification required 

Order a machine via [order server page](https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/verify_page) on the provisioning website

The order should use [template infra-apt-repo-mirror-01](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/config/templates.json) (This links to the saved GHE source which the provisioning interface is built from)

The template can be viewed on the [provisioning application template list](https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/templates/list)

The current specification is as follows:

```
        "description": "2 x 2.0 GHz or higher Cores",
        "ram_item": "RAM_8_GB_BALANCED_2X8",
        "disks": {
            "guest_disk1": "GUEST_DISK_2000_GB_SAN",
            "guest_disk0": "GUEST_DISK_25_GB_SAN"
        },
        "core_item": "GUEST_CORES_2",
        "port_speed_item": "100_MBPS_PRIVATE_NETWORK_UPLINK",
        "os_item": "OS_UBUNTU_18_04_LTS_BIONIC_BEAVER_MINIMAL_64_BIT",
        "bandwidth_item": "BANDWIDTH_0_GB",
        "machine_type": "virtual server"
```

The machine needs to be ordered onto the `CSDP` VLAN for the region it is being deployed to.

### Additional information



After the machine is created by IaaS, it's likely the SAN Disk will need formatting. In the past we've used these instructions - [linux disk formatting](https://www.cyberciti.biz/faq/linux-disk-format/)

### Deployment / post ordering setup

The deployment of the server is covered by [the reloading an apt-repo mirror machine](./reloading_apt_repo_mirror_server.html)

## Escalation Policy

There is no formal escalation policy.

Reach out to SRE squad members in these channels to ask further questions about any of the machine types

- `#conductors` if you are not a member of the SRE Squad.
- `#sre-cfs` or `#conductors-for-life`  if you are a member of the SRE squad (these are internal private channels)


