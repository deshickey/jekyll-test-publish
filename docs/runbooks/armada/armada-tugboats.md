---
layout: default
description: General debugging info for armada tugboat carriers
title: General debugging info for armada tugboat carriers
service: armada-carrier
runbook-name: "General debugging info for armada tugboat carriers"
tags:  armada, carrier, runtime, debug, debugging, general, tugboat, invoke
link: /armada/armada-tugboats.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This information runbook is used to detail information the infrastructure tugboats.

## Detailed Information

### Access the tugboats
To know if the alert is coming from a tugboat, look at the `carrier_name` field and see if the number is 100+, if so it is a tugboat.
Example PagerDuty is [https://ibm.pagerduty.com/alerts/PER1SZW](https://ibm.pagerduty.com/alerts/PER1SZW)

You have two options to access a tugboat:

- Use Igorina interactive mode for tugboat
To start interactive mode for tugboat in your Igorina slack channel or send a DM with the command to Igorina type :
`interactive-tugboat $tugboatName outage:0`
_NB. Use the carrier name from the alert as `$tugboatName`_
_You can now run `kubectl` commands on the tugboat_

- Follow instructions below

1. First, find the hub in the region. Look at the `crn_region` and `crn_cname`. The map below will say what hubs are in that region. Pick any one.

   | Pipeline env | crn_region | crn_cname | Hub1 | Hub2 |
   |-----------|-----------|-----------|-----------|-----------|
   | dev | `us-south`| `staging` | [dev-sjc04-carrier12](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/dev-sjc04/carrier12.hosts) |  |
   | prestage | `us-south`| `staging` | [prestage-mon01-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prestage-mon01/carrier1.hosts) |  |
   | stage | `us-south`| `staging` | [stgiks-dal10-carrier0](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/stage-dal10/carrier0.hosts) |  |
   | **prod** | `us-south`| `bluemix`/`prod` | [prod-dal12-carrier2](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-dal12/carrier2.hosts) | [prod-dal10-carrier3](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-dal10/carrier3.hosts) |
   | **prod** | `us-east`| `bluemix`/`prod` | [prod-wdc06-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-wdc06/carrier1.hosts) | [prod-wdc07-carrier2](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-wdc07/carrier2.hosts) |
   | **prod** | `eu-gb`/`uk-south`| `bluemix`/`prod` | [prod-lon02-carrier2](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-lon02/carrier2.hosts) | [prod-lon04-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-lon04/carrier1.hosts) |
   | **prod** | `eu-de`/`eu-central` | `bluemix`/`prod` | [prod-ams03-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-ams03/carrier1.hosts) | [prod-fra02-carrier2](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-fra02/carrier2.hosts) |
   | **prod** | `au-syd`/`ap-south` | `bluemix`/`prod` | [prod-syd01-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-syd01/carrier1.hosts) | [prod-syd04-carrier2](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-syd04/carrier2.hosts) |
   | **prod** | `jp-tok`/`ap-north` | `bluemix`/`prod` | [prod-tok02-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-tok02/carrier1.hosts) |  |
   | **prod** | `jp-osa` | `bluemix`/`prod` | [prod-osa21-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-osa21/carrier1.hosts) |  |
   | **prod** | `ca-tor` | `bluemix`/`prod` | [prod-tor01-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-tor01/carrier1.hosts) |  |
   | **prod** | `br-sao` | `bluemix`/`prod` | [prod-sao01-carrier1](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prod-sao01/carrier1.hosts) |  |

2. Next go to the link above and find a worker node to ssh to.
3. Once on the worker node, invoke the tugboat doing the following `invoke-tugboat $carrier_name`, where $carrier_name is listed in the alert.
```bash
➜  vagrant ssh krglosse@stage-dal09-carrier0-worker-10
krglosse@stage-dal09-carrier0-worker-10:/home/SSO/krglosse# invoke-tugboat stage-dal10-carrier100
Network call kubeconfigsCarrier was successful
Now pointing to /home/SSO/krglosse/stage-dal10-carrier100.yaml, type exit to leave this subshell
krglosse@stage-dal09-carrier0-worker-10:/home/SSO/krglosse#
```
4. Now `kubectl` commands or scripts that use `kubectl` commands will target the tugboat.

### Access tugboats via ibmcloud cli

> Note: Tugboat Public Service Endpoints are currently being disabled. So logging in to IBM Cloud and fetching the Kubeconfig of the tugboat is now restricted to Private Network only. [More info here](https://github.ibm.com/alchemy-conductors/team/issues/23271). As of Sept 2024 Public endpoints are disabled up until Stage Env.

1. Connect to OpenVPN or Tunnelblick VPN based on the tugboat you want to access. Refer to [OpenVPN Setup Guide](https://pages.github.ibm.com/alchemy-conductors/documentation-pages//docs/runbooks/vpn.html#vpn-client-options) if setting up for the first time.

* For example, trying to access stage-dal10-carrier112 would require you to connect to OpenVPN or Tunnelblick Config for [`stgiks-dal10`](https://github.ibm.com/alchemy-conductors/openvpn-clients/tree/static/final-dst-automation)

* Similarly trying to access prod-dal10-carrier128 requires connection to `prod-dal09` (Prod tugboat public endpoints are NOT disabled yet).


2. Login to ibmcloud infra account where the tugboat lives with the [admin creds](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/28248/general). Admin Creds are only needed for SRE Administration, Use `ibmcloud login --sso` See below for what resources are where:

Legacy carriers and tugboats live in: 531277, 1858147, 659397

Satellite tugboats and location controllers live in: 2094928 and 2146126.

Below are their respective pipelines:

`Prod:`
```
Argonauts Production 531277 (e223e119c9be31669e5688bb376411f7) <-> 531277
Argo Staging (5e2ebb950cd045148325abafde80593a) <-> 1858147
Argonauts Dev 659437 (dd8764ef7e84d59c23228ee806ecffd2) <-> 659397
```
`Stage:`
```
Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928
Satellite Stage (a8fd5d2f57b240f9b276a254c0fcb8a1) <-> 2146126
```
One thing to note is that all tugboat masters live on production legacy carriers. They break the pipeline in that regard.

3. Once you login, you can use the following command to get the Kubeconfig of the tugboat.
```
ibmcloud ks cluster config -c <tugboat_name/cluster_id>
```

### Alternate methods of accessing a Tugboat Kubeconfig
* CloudShell (Needs GPVPN connection to be active. Can be accessed in IBM Cloud UI)
* Invoke-tugboat

## Escalation Policy

### For worker node problems
Please follow the [escalation guidelines](./armada-bootstrap-collect-info-before-escalation.html) to engage the bootstrap development squads.

### For master problems

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
