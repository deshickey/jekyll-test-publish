---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Armada PD services and their development escalation policies.
service: armada
title: Armada PD services and their development escalation policies.
runbook-name: "Conductors: Armada PD services and their development escalation policies."
link: /armada/armada_pagerduty_escalation_policies.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

The table details the armada {{ site.data.teams.alert-service.name }} services, the escalation policies that should be used by the Containers SRE team and the scope/remint of each escalation policy.

Reference:

- Armada {{ site.data.teams.alert-service.name }} service = The service name defined in {{ site.data.teams.alert-service.name }}
- Scope / Remit = The types of issues that would be escalated to the escalation policy.
- Dev Team escalation Policy  = The name of the escalation policy to use in {{ site.data.teams.alert-service.name }}.

## Detailed Information

| Armada PD service | Scope /  remit | Dev Team escalation Policy  | Slack channel(s) |
| ----------------- | -------------- | ----------------------------| ---------------- |
| armada-api - prod | Problems with customer facing API (i.e. `ibmcloud ks`) | [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}) | [{{ site.data.teams.armada-api.comm.name }}]({{ site.data.teams.armada-api.comm.link }}) |
| armada-ballast - prod | Armada Etcd specific issues | [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) | [{{ site.data.teams.armada-ballast.comm.name }}]({{ site.data.teams.armada-ballast.comm.link }}) |
| armada-bootstrap - prod | Problems bootstrapping cruiser/patrol workers | [{{ site.data.teams.armada-bootstrap.escalate.name }}]({{ site.data.teams.armada-bootstrap.escalate.link }}) | [{{ site.data.teams.armada-bootstrap.comm.name }}]({{ site.data.teams.armada-bootstrap.comm.link }}) |
| armada-carrier - prod | Carrier specific issues | [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) | [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) |
| armada-chief - prod | Problems with add-on manager | [{{ site.data.teams.armada-chief.escalate.name }}]({{ site.data.teams.armada-chief.escalate.link }}) | [{{ site.data.teams.armada-chief.comm.name }}]({{ site.data.teams.armada-chief.comm.link }}) |
| armada-cluster - prod | Problems provisioning and managing infrastructure Resources for the Kubeernetes cluster. | [{{ site.data.teams.armada-cluster.escalate.name }}]({{ site.data.teams.armada-cluster.escalate.link }}) | [{{ site.data.teams.armada-cluster.comm.name }}]({{ site.data.teams.armada-cluster.comm.link }}) |
| armada-deploy - prod | Deployment microservice for deploying and deleting cruiser/patrols | [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) | [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) |
| armada-events - prod | define scope here | [{{ site.data.teams.armada-events.escalate.name }}]({{ site.data.teams.armada-events.escalate.link }}) | [{{ site.data.teams.armada-events.comm.name }}]({{ site.data.teams.armada-events.comm.link }}) |
| armada-health - prod | define scope here | [{{ site.data.teams.armada-health.escalate.name }}]({{ site.data.teams.armada-health.escalate.link }}) | [{{ site.data.teams.armada-health.comm.name }}]({{ site.data.teams.armada-health.comm.link }}) |
| armada-infra - prod | Infrastructure related issues on a carrier (High CPU, Disk space issues) | [{{ site.data.teams.containers-sre.escalate.name }}]({{ site.data.teams.containers-sre.escalate.link }}) | [{{ site.data.teams.containers-sre.comm.name }}]({{ site.data.teams.containers-sre.comm.link }}) |
| armada-ingress - prod | armada-ingress-microservice GHE repo - discussion in #armada-network | [{{ site.data.teams.armada-ingress.escalate.name }}]({{ site.data.teams.armada-ingress.escalate.link }}) | [{{ site.data.teams.armada-ingress.comm.name }}]({{ site.data.teams.armada-ingress.comm.link }}) |
| armada-metrics - prod | Problems in the armada-metrics microservice |  [{{ site.data.teams.armada-metrics.escalate.name }}]({{ site.data.teams.armada-metrics.escalate.link }}) | [{{ site.data.teams.armada-metrics.comm.name }}]({{ site.data.teams.armada-metrics.comm.link }}) |
| armada-network - prod | armada-network microservice, kubernetes and calico networking | [{{ site.data.teams.armada-network.escalate.name }}]({{ site.data.teams.armada-network.escalate.link }}) | [{{ site.data.teams.armada-network.comm.name }}]({{ site.data.teams.armada-network.comm.link }}) |
| armada-ops - prod | Problems with management of the health of armada Carrier and customer (Cruiser / Patrol) instances (Monitoring, Alerting, Prometheus, AlertManager, Grafana) | [{{ site.data.teams.containers-sre.escalate.name }}]({{ site.data.teams.containers-sre.escalate.link }}) | [{{ site.data.teams.armada-ops.comm.name }}]({{ site.data.teams.armada-ops.comm.link }}) |
| armada-ui - prod | Problems with UI functionality and feature access | [{{ site.data.teams.armada-ui.escalate.name }}]({{ site.data.teams.armada-ui.escalate.link }}) | [{{ site.data.teams.armada-ui.comm.name }}]({{ site.data.teams.armada-ui.comm.link }}) |
| armada-storage - prod | Armada Storage | [{{ site.data.teams.armada-storage.escalate.name }}]({{ site.data.teams.armada-storage.escalate.link }}) | [{{ site.data.teams.armada-storage.comm.name }}]({{ site.data.teams.armada-storage.comm.link }}) |
| armada-docker - prod | Armada Docker | [{{ site.data.teams.armada-docker.escalate.name }}]({{ site.data.teams.armada-docker.escalate.link }}) | [{{ site.data.teams.armada-docker.comm.name }}]({{ site.data.teams.armada-docker.comm.link }}) |
| armada-ICE - prod | Problems with logging and metrics (fluentd) |  [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}) | [{{ site.data.teams.armada-api.comm.name }}]({{ site.data.teams.armada-api.comm.link }}) |
| satellite-config - prod | Problems with customer facing Satellite config API (i.e. `ibmcloud sat config`, `ibmcloud sat cluster`) | [{{ site.data.teams.satellite-config.escalate.name }}]({{ site.data.teams.satellite-config.escalate.link }}) | [{{ site.data.teams.satellite-config.comm.name }}]({{ site.data.teams.satellite-config.comm.link }}) |
| satellite-link - prod | Problems with Satellite link connectivity | [{{ site.data.teams.satellite-link.escalate.name }}]({{ site.data.teams.satellite-link.escalate.link }}) | [{{ site.data.teams.satellite-link.comm.name }}]({{ site.data.teams.satellite-link.comm.link }}) |
| satellite-location - prod | Problems with customer facing Satellite location API (i.e. `ibmcloud sat location`, `ibmcloud sat host`). Hosted by the `armada-api` microservice and supported by `armada-satellite-alert-autoresolver-server` microservice. | [{{ site.data.teams.satellite-location.escalate.name }}]({{ site.data.teams.satellite-location.escalate.link }}) | [{{ site.data.teams.satellite-location.comm.name }}]({{ site.data.teams.satellite-location.comm.link }}) |


## Other escalation policies not directly tied to a {{ site.data.teams.alert-service.name }} service

There are some escalation policies that do not directly map to a {{ site.data.teams.alert-service.name }} service.
These are detailed below

| Scope /  remit | Dev Team escalation Policy  |
|--
| Urgent problems with etcd managed by Compose.io (BEFORE ETCD MIGRATION ONLY!)| In the event of an emergency send an email to `ibm-containers+911@support.compose.io`. Please note that use of this email will trigger alerts to the on-call pager as well as other escalations so only use it in the event there’s an actual emergency. All other requests should go to `support@compose.io` as usual (or as tickets opened from within the web UI. |
| Urgent problems with the armada gate (pvg) process | [{{ site.data.teams.armada-gates.escalate.name }}]({{ site.data.teams.armada-gates.escalate.link }}) |
| Urgent problems with the cli | [{{ site.data.teams.armada-cli.escalate.name }}]({{ site.data.teams.armada-cli.escalate.link }}) |
| Urgent problems with the config-pusher microservice | [{{ site.data.teams.armada-config-pusher.escalate.name }}]({{ site.data.teams.armada-config-pusher.escalate.link }}) |
| Urgent problems with IAM (Identity and Access Manager) | [{{ site.data.teams.IAM.escalate.name }}]({{ site.data.teams.IAM.escalate.link }}) or [IAM - Access Management Severity 1 Priority]({{ site.data.teams.IAM.alert_services.sev1 }}) or [IAM - Access Management - CIE]({{ site.data.teams.IAM.alert_services.cie }}) |
| Urgent problems with compose |  In the event of an emergency send an email to `ibm-containers+911@support.compose.io`. Please note that use of this email will trigger alerts to the on-call pager as well as other escalations so only use it in the event there’s an actual emergency. All other requests should go to support@compose.io as usual (or as tickets opened from within the web UI.
| BSS | use `Bluemix BSS Provisioning and Resource Controller` to escalate to the BSS Resource Controller team
use `Bluemix BSS Metering` to escalate to the BSS Metering team |


{:.table .table-bordered .table-striped}

## Detailed Procedure

## Useful links
{% capture useful_link %}
- Link to [pageduty services defined for armada](https://ibm.pagerduty.com/services#?query=armada)
- Search for escalation policies [here](https://ibm.pagerduty.com/escalation_policies#)
{% endcapture %}
{{ useful_link }}
