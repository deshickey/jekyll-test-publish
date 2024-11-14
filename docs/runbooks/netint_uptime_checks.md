---
layout: default
description: Runbook needs to be updated with description
service: " Network Intelligence "
title: Network Intelligence checks are down in Sensu-Uptime
runbook-name: Network Intelligence checks are down in Sensu-Uptime
playbooks: ["Runbook needs to be updated with playbooks"]
failure: [" Uptime down: Netint arp table check/netint-uptime-service "]
ownership-details:
  escalation: " Alchemy - Network Intel 24x7
"
  owner-link: "https://ibm-cloudplatform.slack.com/messages/netint"
  corehours: " UK "
  owner-notification: False
  group-for-rtc-ticket: Runbook needs to be Updated with group-for-rtc-ticket
  owner: " Network Intelligence [#netint]"
  owner-approval: False
link: /netint_uptime_checks.html
type: Troubleshooting
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

Most monitoring of vyatta health and tunnels is done using AlertManager and Prometheus, these services page out separately (see [Netint AlertManager Runbook](./netint_alertmanager_checks.html)). When Prometheus itself goes down, this is monitered in Sensu and will generate a page.

Netint Prometheis all run in the `infra-accessallareas` cruiser cluster in sup-fra02. There is one per core environment (e.g. `dev-mon01`, `prod-dal09`, `prod-lon02`, etc).

## Example Alert

There is only one type of alert currently possible:

### "Netint Prometheus monitoring <core-env>" is indicated as down

This means that the Prometheus monitoring container for the particular core env is not contactable.

## Investigation and Action:

1. Ensure there are no other wider connectivity issues that would affect Sensu contacting the Prometheus server in the `infra-accessallareas` cluster.
   * Check that OpenVPN to the `sup-wdc04` environment works and can connect.
   * Check the state of pager duty, if there is an environment wide networking outage then multiple services will be reporting as down in the corresponding environment.
   * Check softlayer for unplanned events that might be affecting the environment [softlayer unplanned events](https://control.softlayer.com/event/unplanned).
   * Check the `#netint` slack channel for any issues with vyattas in `sup-fra02`, this is the vyatta pair in front of the `infra-accessallareas` cluster.
   * Check other services in the `infra-accessallareas` cluster such as any of the bots (Igorina, Netmax, etc) or [Elba](https://elba.cont.bluemix.net). If they are also down then the cluster may be having problems.
2. If no other causes are found, then re-deploy prometheus to our environment. 
   * Go the prometheus build job [here](https://alchemy-containers-jenkins.swg-devops.com/job/Network-Intelligence/job/prometheus-stack-build/), on the left-hand navigation bar click on the latest succesful build, and then navigate to "Promotion Status" for this build.
   * Re-execute the promotion for the core environment indicated in the page title (having raised appropriate trains if required).
3. The page should auto-resolve once prometheus has been re-deployed, but if the re-deploy was not succesful then page out the netint team and notify them that further investigation is required.

## Escalation Policy

If unable to resolve the issues above using the steps documented, and this is a production environment, then the Netint team can be paged using the [Alchemy - Network Intel 24x7](https://ibm.pagerduty.com/escalation_policies#PSB1EKU) escalation policy.

For non-production environments please raise a GHE ticket in the [firewall-requests](https://github.ibm.com/alchemy-netint/firewall-requests/issues/new) repo, with details on which prometheis are having issues and any steps already taken to attempt resolution.
