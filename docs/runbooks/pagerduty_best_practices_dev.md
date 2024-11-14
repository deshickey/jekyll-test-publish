---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: A quick guide for DevOps team members who are on Pager Duty
service: Runbook needs to be updated with service
title: Pager Duty for DevOps Squad Members Best Practices
runbook-name: "Pager Duty for DevOps Squad Members: Best Practices"
link: /pagerduty_best_practices_dev.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

Are you nervous about your upcoming Pager Duty on-call rotation? Don't be! Follow this simple guidance to get set up and prepare yourself for the fun.

## Request access to Pager Duty

1. Log in to the [USAM request page](https://usam.svl.ibm.com:9443/AM/idman/AddSystemAccess) with your intranet ID.
1. Search for system: "USAM-PIM1-BMX".
1. Select the "bluemix  >  bluemix-pager-duty-user" group.
1. Specify your intranet id as user id in the request.
1. Click **Submit**.
1. Follow up with your team lead to be added to a Pager Duty on-call schedule.

## Getting ready

1. **Know your schedule:** Know when you are on call:
  * [Alchemy Escalation Policies](https://ibm.pagerduty.com/escalation_policies#?query=Alchemy)
  * [Alchemy on-call schedules](https://ibm.pagerduty.com/schedules#?query=Alchemy)
1. **Configure your profile:**
  * In Pager Duty, set up your **User Profile > Notification Rules** to configure how you are notified.
  * Choose a target device or alerting method that will certainly be successful at alerting you during all hours.
  * Android and iOS apps are very nice to use and have great push notifications!
1. **Make it loud!** Configure your  device with adequate notification sound to wake you up.
1. **Keep it nearby!** Place device in a place where you will hear notification while you are asleep
1. **Be mentally ready!** If you are on call, be aware that you may receive an alert or a direct phone call at any time, including the middle of the night.
1. **Do NOT watch the system!** Just wait!

## Handling Pager Duty incidents
1. Initial triage: Is the incident relevant to your squad?
  * Yes - Acknowledge
  * No - Reassign
1. Communicate:
  * Log on to Slack and notify your channels and #conductors that you are online and investigating.
  * Pair with a conductor.
Investigate. Research and find solution.
1. Fix problem
  * Find a [*Runbook*](./runbooks.html)
    * *Note:* If you find a Runbook, ask Conductors to run it, as they shouldn't have paged you.
  * Call in your Level 2 backup or squad lead or a peer from your squad for additional support
1. Document
  * Communicate your fix in Slack.
  * Open any required work items in [RTC](https://jazzop27.rtp.raleigh.ibm.com:9443/ccm/web/projects/Alchemy) for avoiding same issue in the future.
  * Write [new Runbook](./runbooks.html) as needed.


## Change log
* 16-Oct-2015 published by Seth Packham
