---
layout: default
title: How to request a new machine in Softlayer
type: Informational
runbook-name: "How to request a new machine in Softlayer"
description: "How to request Conductors to create a new machine in Softlayer"
service: Infrastructure
playbooks: [<NoPlayBooksSpecified>]
link: /conductors_requesting_softlayer_machine.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes how to request the Conductors squad to provision a new machine in Softlayer.

The stages of provisioning a new machine are:

1. Create a request against the conductors with the machine or machines you need.
2. The request will be reviewed and will be approved or rejected.
3. If the request is approved the machines will be provisioned in Softlayer and they will be *bootstrapped*.
4. If the machine does not follow an existing naming pattern that is serviced by an existing firewall rule then you will need to request a firewall change too.

## Detailed Information

### Template for the request

Please copy and paste the following text into the request so that we have all the details.

1. Requesting area:
1. [Type](#machinetype): Virtual Server Instance or Bare Metal
1. [Machine size template name](#machinetype):
1. Quantity:
1. [Hostname](#hostname):
1. [Public or private-only](#public):
1. Environment: dev-mon01/prestage-mon01/stage-dal09/prod-dal09/prod-lon02
1. [VLAN(s)](#vlan):
1. Purpose:
1. Business reason:

###  Where to create the request

[Create the request] as an issue in the alchemy-conductors/team Github Enterprise repository


## Details

### Requesting area {#requestarea}

Please provide the area or squad name making the request.

### Machine type and size {#machinetype}

To simplify the ordering and maintenance of the machines in Softlayer there are a few set sizes of machines you can order. If none of these fit your needs please talk to Conductors and we will try and accommodate your needs.

For more information about exactly the types of machines that will be ordered see the [list of machine templates][provisioning_api_templates].

#### Virtual server instance

It is faster to order and provision virtual servers and therefore it is preferable for squads to use virtual servers where possible.

| Type | Cores |  Memory | Storage | Template name |
|--
| Virtual server | 4 | 16GB | 100 GB SAN, 100GB SAN | small.small-storage |
| Virtual server | 4 | 16GB | 100 GB SAN, 2 TB SAN | small.big-storage |
| Virtual server | 8 | 64GB | 100 GB SAN, 200GB SAN | medium.small-storage |
| Virtual server | 8 | 64GB | 100 GB SAN, 2 TB SAN | medium.big-storage |
| Virtual server | 16 | 64GB | 100 GB SAN | large.small-storage |
| Virtual server | 16 | 64GB | 100 GB SAN, 2 TB SAN | large.big-storage |
{:.table .table-bordered .table-striped}

#### Bare metal

| Type | Cores |  Memory | Storage | Template name |
|--
| Bare metal | 4 | 32GB | 500 GB SATA, 500GB SATA | bm.small.small-storage |
| Bare metal | 4 | 32GB | 500 GB SATA, 2 TB SATA | bm.small.big-storage |
| Bare metal | 12 | 64GB | 1 TB SATA, 2 TB SATA |  bm.medium.big-storage |
| Bare metal | 48 | 256GB | 1 TB SATA, 1 TB SATA | bm.huge.small-storage |
{:.table .table-bordered .table-striped}

### Hostname {#hostname}

In consideration of past operating experience, this revised approach to host naming has 2 primary goals, a) make the hostnames more understandable by (mere) humans and b) reduce confusion about where each server is and its role.  It also takes into account the reality that the container infrastructure will need to span SoftLayer data centers.  The name is a 5 tuple, where tuples ,2, 3 and 5 are standardized, the fourth is mandatory but the content is requester defined. Tuple 5 was added to make clear to which service instance the server belongs.

hostname will be formed as

```
"environment-datacenter-component_service-{subcomponent}-occurrence_count "
 ----------- ---------- ----------------- -------------- -----------------
      1          2             3                4                5

1. environment ::= <prod | stage | dev | prestage> [mandatory]

2. datacenter ::= <softlayer datacenter>  e.g. dal05, wdc01> [mandatory]

3. component_service ::= <function | service> [mandatory]
       function ::= <ccs1 | firewall | registry | build | vuln | chaos | e2e > (10 chars max)
       service<n> ::= <carrier<n>  | infra <n>  (10 chars max)

4. subcomponent ::= <freeform for squads> (10 char max) [field mandatory, content decided by requesting squad]

5. occurrence_count := <number> [mandatory]
       number ::= <2 digit start at 1>

Footnote 1: ccs for cloud container service .
```

Notes:

The mandated names will be maintained by conductors squad, let us know if you need an addition.

1. dev, prestage, stage, prod

2. The SoftLayer datacenter abbreviation

3. The hostname tuple 3 can contain either a functional name or a service name, as shown above.  When service name is used, it may be optionally followed by a number to indicate service instance - this usage is used e.g. by carrier, as carrier1 or carrier2 etc.

4. Squads are expected to provide names, but conductors will provide if not provided by the squad, typically based on the functional description in the resource request. It is permissible to use a '-' separator in this field.

5. When you have a function being provided by more than one server, increment this value  e.g.  host-05  host-06

Examples:

|  1|2  |3 | 4| 5|
|--|--|--|--|--|
|prod- | lon02- | firewall-   | vyatta-      | 01|
|prod- | lon02- | firewall-   | fortigate-   | 01|
|prod- | lon02- | ccs-        | ccsapi-     | 01|
|prod- | lon02- | ccs-        | ccsapi-     | 02|
|prod- | lon02- | ccs-        | ccsapi-     | 03|
|prod- | lon02- | carrier2-    | master-         | 01|
|prod- | lon02- | carrier2-     | host-         | 03|
|prod- | lon02- | infra-       | elk-            | 01|
|prod- | lon02- | infra-       | elk-            | 02|
|prod- | lon02- | infra-       | deploy-      | 01|
|prod- | lon02- | infra-       | uptime-      | 01|

### Public or private IP addresses {#public}

You can order a machine with a private only address if no external access is required. This will be the default.

Alternatively you can request a public IP address for the machine. This will normally mean you will need a firewall change request to allow appropriate traffic to reach your machine.

### VLANs {#vlan}

It is important to make sure the machines are present on the right VLAN or VLANs.

See [the latest list of VLANS][provisioning_api_vlans].

### Operating system

The preferred operating system is Ubuntu 14.04 LTS. In some rare circumstances other operating systems are permitted in our environments. Please talk to conductors before ordering.

[create the request]: https://github.ibm.com/alchemy-conductors/team/issues/new?title=Request+for+softlayer+machine&body=Request+for+new+softlayer+machine%0A%0A-+Requesting+area:%0A-+Type:+Virtual+Server+Instance+or+Bare+Metal%0A-+Machine+size+template+name:%0A-+Quantity:%0A-+Hostname:%0A-+Public+or+private-only:%0A-+Environment:+dev-mon01/prestage-mon01/stage-dal09/prod-dal09/prod-lon02%0A-+VLAN(s):%0A-+Purpose:%0A-+Business+reason:&labels=machine+order

[provisioning_api_templates]: https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/templates

[provisioning_api_vlans]: https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/vlans
