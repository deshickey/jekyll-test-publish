---
layout: default
description: Runbook for fixing whole Sensu uptime-client has been silenced issue
service: "Infrastructure"
title: the whole uptime-client has been silenced
runbook-name: Sensu-Uptime stashes check
failure: [" the whole uptime-client has been silenced on <environment> "]
link: /sensu_uptime_stashescheck_issue.html
type: Troubleshooting
playbooks:  [<add Ansible-playbook command to automate Runbook. Separate each Playbook with a comma and surround with inverted commas>]
ownership-details:
- owner: <replace with squad that owns the service/group that owns this pager. Surround with inverted commas>
  owner-link: <replace with link to access the owner. Surround with inverted commas>
  corehours: <replace with core hours, e.g. US. Surround with inverted commas>
  escalation: <replace with details of which group to escalate issue to. Surround with inverted commas>
  owner-approval: <Mark as 'true' if owner approval is required for runbook/ansible-playbook actions. Otherwise mark as 'false'>
  owner-notification: <Mark as 'true' if owner should be notified of runbook/ansible-playbook results. Otherwise mark as 'false'>
  group-for-rtc-ticket: <replace with group for RTC ticket info. Surround with inverted commas>
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

## Example Alerts

Issue: "sensu uptime stashes check on **: the whole uptime-client has been silenced"


PD looks like: `sensu uptime stashes check on prod-dal09: The whole uptime-client has been silenced on prod-dal09`.

## Investigation and Action

The `<environment>` in this PD is `prod-dal09`

This PD alert reports that the whole uptime-client has been silenced. This [test job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/job/sensu-uptime-stash-clients-monitor/)
runs every 10mins to check whether the whole uptime-client has been silenced.

If the PD looks like this, go to the uchiwa section in the PD details to find out the related uchiwa link for the sensu-uptime. eg: https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon02/prod/sensu-uptime
. Then click 'CLIENTS' in left side to go to https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon02/prod/sensu-uptime/#/clients  and unslienced the uptime-client immediatelly.

## Escalation Policy

Try  to Find out  who did that and open an issue to the corresponding squad
