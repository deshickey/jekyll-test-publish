---
layout: default
title: Details about infra machines owned by the SRE Squad
type: Informational
runbook-name: "Details about infra machines owned by the SRE Squad"
description: "Details about infra machines owned by the SRE Squad"
service: Conductors
link: /sre_infra_machines_overview.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details information about all of the `infra` servers SRE are responsible for.  It links off to further runbooks which 

## Detailed information

Generic information about ordering machines in IaaS is detailed in the [SL Provisioning runbook](./sl_provisioning.html)

### infra-apt-repo-mirror

- [Machine specification and ordering](./sre_infra-apt-repo-mirror_spec.html)
- [How to reload and deploy the infra-apt-repo-mirror](./reloading_apt_repo_mirror_server.html)
- [Link apt-repo-mirror deployment code](https://github.ibm.com/alchemy-conductors/smith-packages/tree/master/scripts/jenkins/setupAptRepoMirror)

### infra-iemrelay

We use the SOS healthcheck and patching service.  A pre-req to using this requires us to setup a `relay` server in our local environment.  
The following [SOS docs](https://pages.github.ibm.com/SOSTeam/SOS-Docs/bigfix/BigFix_Health_Patch.html) detail all the setup required to use their service.

With regards to machine specification, the following links can be reviewed to see the specs we use for our orders

- [Machine specification and ordering](./sre_infra-iemrelay_spec.html)
- Deploying of an iemrelay server is performed via our standard bootstrap code - this occurs immediately after a machine is ordered.  This is a link to the [iemagent playbook](https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/roles/iemagent)

### infra-nessus

We use the SOS vulnerability scanning service.  A pre-req to using this requires us to setup a `nessus scanner` server in our local environment.  
The following [SOS docs](https://pages.github.ibm.com/SOSTeam/SOS-Docs/sca/Security-Vulnerability-Scanning.html) detail all the setup required to use their service.  
With regards to machine specification, the following links can be reviewed to see the specs we use for our orders and how to enable a new scanner.

- [Ordering and setting up a nessus scanner](./sre_nessus_scanner.html)


### infra-qradar

- [Ordering and setting up a qradar server](./qradar_ep_deploy.html)

### infra-sensu

- [Sensu server ordering and deployment steps](https://github.ibm.com/alchemy-conductors/sensu-uptime-deploy)

### infra-syslog

- [syslog server ordering and deployment steps](./syslog_server_deploy.html)

### infra-test-08

The `infra-test-08` machine is just a basic Ubuntu 18 VSI with a standard bootstrap executed against it and deployed to the `CSMG` VLAN

### infra-vpn

- [Machine specification and ordering](./sre_infra-vpn_spec.html)
- [Reload and deployment process detailed here](./reloading_infra_vpn_server.html)

## Escalation Policy

There is no formal escalation policy.

Reach out to SRE squad members in these channels to ask further questions about any of the machine types

- `#conductors` if you are not a member of the SRE Squad.
- `#sre-cfs` or `#conductors-for-life`  if you are a member of the SRE squad (these are internal private channels