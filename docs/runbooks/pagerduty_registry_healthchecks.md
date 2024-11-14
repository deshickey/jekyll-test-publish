---
layout: default
description: Runbook for pagerduty incidents raised by the Containers Registry service healthchecks.
service: "Containers Registry "
title: Registry Healthcheck PagerDuty Guide
runbook-name: Registry Healthcheck PagerDuty Guide
playbooks: [ "registry/recoveryTool/upstart-restart.yml" , "registry/recoveryTool/reboot_scripted" ]
failure: ["Sensu DOWN: Registry-Pull-Check on _host_", "Sensu DOWN: Registry-Push-Check on _host_", "Sensu DOWN: Registry-image-list on _host_", "Sensu DOWN: Notary-GetRole on _host_", "Sensu DOWN: Notary-Rotate on _host_",  "Sensu DOWN: Registry-Oauth on _host_", "Sensu DOWN: Helm _repo_ Index on _host_", "Sensu DOWN: Helm _repo_ Chart on _host_", "Sensu DOWN: Helm _repo_ README on _host_"]
ownership-details:
  escalation: " Alchemy - Registry and Build "
  owner-link: "https://ibm-argonauts.slack.com/messages/registry/"
  corehours: " UK "
  owner-notification: False
  owner: " R&B Squad [#registry]"
  owner-approval: False
link: /pagerduty_registry_healthchecks.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
The healthchecks are designed to test that the main customer actions are working as expected, ie Docker pull/push are working against an instance of the customer IBM Cloud Container Registry. If any of these checks has raised a page, 3 or more requests in a row to the service have failed. This indicates an issue that is affecting customers.

## Example alert(s)
    * Registry Pull Check on <machine-name>
    * Registry Push Check on <machine-name>
    * Registry image list on <machine-name>
    * Registry public image on <machine-name>
    * Registry OAuth on <machine-name>
    * Notary GetRole on <machine-name>
    * Notary Rotate on <machine-name>
    * Helm <repo> Index on <machine-name>
    * Helm <repo> Chart on <machine-name>
    * Helm <repo> README on <machine-name>

## Automation
Automation is available for a specific scenario, please refer to the Actions section.

## Actions to take
If you've got both a Registry-Bluemix page and a Registry Health page, follow this guide first.

Conversely, if you've got both a Docker Registry or Registry Endpoint page and a Registry Health page, follow the guide for [`Docker Registry`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/docker_registry_checks.html) first. In many cases, resolving the [`Docker Registry`](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/docker_registry_checks.html) page will also resolve the Registry Health alert.

1. Check Consul for the environment (from the [Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) > [View](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) > Consul) for any failing services. If everything is green, the issue requires investigation by a member of the Registry squad. Forward the page to the Registry squad.
2. If anything is red (except any ccsapi or VA services), click it to view which machine's service instance is failing. If it's the "Serf Health status" check on the service, you need to restart consul. Use the [upstart-restart job](https://alchemy-conductors-jenkins.swg-devops.com/job/Containers-Registry/view/Playbooks/job/RecoveryTool/job/upstart-restart/) to perform an upstart-restart on Consul or the failing service.  
Set the following parameters:  
    * `TARGET_ENV`: Select the environment from the drop-down.  
    * `HOSTS`: Specify the affected host(s). This is an ansible limit string. An example value is: `prod-dal09-registry-docker-01`
    * `CONTAINER`: Type the name of the service as it is displayed in Consul.
<br/>If the issue is in a dedicated or local environment, run the playbook `registry/recoveryTool/upstart-restart.yml`. Ensure that the `HOSTS` value described above is passed in as the ansible limit (`-l`) parameter. Pass in the extra value `-e container=CONTAINER`, where CONTAINER is as described above.<br/>
3. The page should resolve in about 5 minutes from you resolving the issue. If it does not resolve automatically, reboot the machine with the most failing services using the [reboot_scripted job](https://alchemy-conductors-jenkins.swg-devops.com/job/Containers-Registry/view/Playbooks/job/RecoveryTool/job/reboot_scripted/), and forward the page to the Registry team to ensure that service is restored properly.
Set the following parameters on the tool:  
    * `TARGET_ENV`: Select the environment from the drop-down.  
    * `HOSTS`: Specify the affected host(s). This is an ansible limit string. An example value is: `prod-dal09-registry-docker-01`.), and forward the page to the Registry team to ensure that service is restored properly.
<br>If running in a dedicated or local environment, run the playbook `registry/recoveryTool/reboot_scripted.yml`, and ensure that the `HOSTS` value described above is passed in as the ansible limit (`-l`) parameter.

## Escalation Policy
 * PagerDuty Escalation Policy: [Alchemy - Containers - Registry and Build (High Priority)
](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)
  * Slack channel: [Argonauts - registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE)
  * GHE repo link for issues with runbook or PD: [alchemy-registry/registry-build-squad](https://github.ibm.com/alchemy-registry/registry-build-squad/issues/new)
