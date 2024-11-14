---
layout: default
description: General runbook for pagerduty incidents related to the Containers Registry service.
service: "Containers Registry "
title: Registry PagerDuty Guide
runbook-name: Registry PagerDuty Guide
playbooks: [ "registry/recoveryTool/upstart-restart.yml" , "registry/recoveryTool/reboot_scripted" ]
failure: ["Sensu DOWN: Registry-Pull-Check on _host_", "Sensu DOWN: Registry-Push-Check on _host_", "Sensu DOWN: Registry-cf-ic-login on _host_", "Sensu DOWN: Registry-bx-cr-login on _host_", "Sensu DOWN: Registry-image-list on _host_", "Sensu DOWN: Docker-Registry on _host_", "Sensu DOWN: Registry-Endpoint on _host_" , "Sensu DOWN: CCS-Endpoint on _host_" , "Sensu DOWN: Registry-Bluemix on _host_" , "Sensu DOWN: registry endpoints _env_" , "Sensu DOWN: ccs endpoints _env_" , "Sensu DOWN: registry hosts _env_" ]
ownership-details:
  escalation: " Alchemy - Registry and Build "
  owner-link: "https://ibm-argonauts.slack.com/messages/registry/"
  corehours: " UK "
  owner-notification: False
  owner: " R&B Squad [#registry]"
  owner-approval: False
link: /pagerduty_registry.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
This is the main starting point for Registry Alerts that will help you make the decision on what runbook to follow next. 
Please follow these guides immediately upon receiving a page for the Registry service, to restore the service or notify the Registry squad as quickly as possible.

Over the next few months, we will be migrating our production environments to run on top of Armada clusters. Over this migration period, we will be running in various hybrid architectures which will involve traffic going to both Armada clusters and our classic deployments. Due to this added complexity, we will be forwarding some alerts direct to our squad as we feel the complexity will mean that it will be difficult for us to write runbooks that Conductors will be able to easily follow. 

We will, however, keep some alerts going to conductors where we can still have clear easy to follow instructions that will add value. If you have arrived here you will have received one of those alerts or an alert for an environment that has not been migrated to Armada and can follow the instructions below. 

**In this document, 'Registry Health' means any of healthchecks for Registry-Pull-Check, Registry-Push-Check, Registry-image-list, Registry OAuth, Notary GetRole, Notary Rotate, Helm `<repo>` Index, Helm `<repo>` Chart or Helm `<repo>` README.**

**In this document, 'Registry Login Health' means any of healthchecks for , 'Registry-docker-login', 'Registry-bx-cr-login' or 'registry-bmuaa'**

**In this document, 'Registry Endpoint' means any of the healthchecks starting with 'Registry-Endpoint-on-' or 'registry endpoints '**


## Example alert(s)
    * Registry bx cr login on <machine-name>
    * Registry docker login on <machine-name>
    * Registry bmuaa on <machine-name>
    * Registry Pull Check on <machine-name>
    * Registry Push Check on <machine-name>
    * Registry image list on <machine-name>
    * Registry public image on <machine-name>
    * Registry OAuth on <machine-name>
    * Notary GetRole on <machine-name>
    * Notary Rotate on <machine-name>
    * Registry-Endpoint on <machine-name>
    * Helm <repo> Index on <machine-name>
    * Helm <repo> Chart on <machine-name>
    * Helm <repo> README on <machine-name>

## Automation
Not applicable as this run book fans out to other ones

## Short-term exceptions
22-July-2018: If you have pages for `Notary-GetRole-Check-on-prod-dal09-registry-health-01` and `Notary-GetRole-prod-dal10p01-registry-health-01`, please wait 15-20 mins to see if they auto-resolve before escalating. 
These are caused by a slow-down, generally at 00:30, 06:30, 12:30 and 18:30 UTC, as a result of inefficient Cloudant search logic in Notary open source code. A fix for this is in progress [in issue 1704](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/1704). The symptom for end-users is a slow response to Notary actions for a short while.

## Actions to take

If the alert is for one of the hybrid Armada + Classic environments (Currently Stage-Dal09) follow the hybrid section immediately below. For all other environments jump to the classic section.

**Hybrid Armada** 

If you have Registry Health alerts but not a corresponding Registry Login Health please forward the page to registry squad. 
If you have just a Registry Login Health or Registry Login Health and Registry Health please follow the guide for [`Registry Login Health`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pagerduty_registry_login_healthchecks.html)


**Classic Environments**
 
If you've got both a Registry-Bluemix page and a Registry Health page, follow the guide for [`Registry Health`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pagerduty_registry_healthchecks.html) first.


Conversely, if you've got both a Docker Registry or Registry Endpoint page and a Registry Health page, follow the guide for [Docker Registry](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/docker_registry_checks.html) first. In many cases, resolving the Docker Registry page will also resolve the Registry Health alert.

If you have got both a Registry Login Health and Registry Health please follow the guide for [`Registry Login Health`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pagerduty_registry_login_healthchecks.html)

If you the above does not apply and you only have one type of alert follow the following links: 

* [`Registry Health`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pagerduty_registry_healthchecks.html)
* [`Registry-Bluemix`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pagerduty_registry_bluemix.html)
* [`Registry Login Health`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pagerduty_registry_login_healthchecks.html)
* [`Registry Endpoint`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/pagerduty_registry_endpoints.html)
* [`Docker Registry`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/docker_registry_checks.html)


__NB__: Please remember to notify the Registry and Build squad with what happened and what you did to resolve the issue, so that we can prevent it from happening again. Raise a [GHE issue](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new?labels[]=outage&labels[]=bug&title=Outage:), filed against Containers/Registry, containing the title of the alert and the steps you took to resolve it.

## Escalation Policy
 * PagerDuty Escalation Policy: [Alchemy - Containers - Registry and Build (High Priority)
](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)
  * Slack channel: [Argonauts - registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE)
  * GHE repo link for issues with runbook or PD: [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)
