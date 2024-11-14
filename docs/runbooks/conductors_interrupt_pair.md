---
layout: default
description: Expectations when working as the interrupt pair in conductors
service: Conductors
title: Expectations when working as the interrupt pair in conductors
runbook-name: "Expectations when working as the interrupt pair in conductors"
tags: conductors support interrupt pagerduty
playbooks: ["Runbook needs to be Updated with playbooks info (if applicable)"]
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
link: /conductors_interrupt_pair.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document has been created to detail the roles and responsibilities when you are tasked with being part of the interrupt pair.

The interrupt pair should **not** be involved with development activities for the days they are working in this role as there will always be work for them to complete on the team boards or related to improvements with activities undertaken in the interrupt role.

## Manual commands in production

SRE WILL NOT run manual commands against production during normal operations. Normal operations means no CIE or customer outage. If there is a CIE or a customer is down, SRE WILL be involved in troubleshooting to resolve the emergency.

SRE was previously able to handle requests from other teams to perform various operations such as upgrading deployments across the fleet, cleaning up deployments from a faulty cluster removal process or cleaning up after a bug caused pods to be left behind no longer maintained. These are all examples of bugs or gaps in the service and are required to be fixed by the product teams responsible for their own components.

Product development teams that need to run something against production for whatever reason 1) MUST store the source code for their scripts/programs in GHE, 2) MUST have a jenkins job or other form of automation to kick the job off, and 3) Have tested and verified the process works in pre-prod BEFORE running in production.

## Detailed Information

{% capture entire_document %}
The key tasks to cover are as follows and are further explained in the sections below.

1. High Urgency Pager Duty & Environment stability
1. Prioritized interrupt work from the [SRE team repo](https://github.ibm.com/alchemy-conductors/team/issues?q=is%3Aopen+is%3Aissue+label%3Ainterrupt)
1. Production trains approvals in [#cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ)
1. Monitoring of slack for emergencies in [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK) and [#containers-cie](https://ibm-argonauts.slack.com/archives/C4SN1JNG5)
1. Sev1 Emergency customer tickets in the "New Issues" or "With SRE" columns in [Zenhub](https://github.ibm.com/alchemy-containers/customer-tickets/issues#workspaces/customer-tickets-5a0a9223132a1305413e5530/board?labels=severity%3A%201&repos=256465)

## Interrupt pair - split of responsibilities

The interrupt pair should work as a primary and secondary.  
Taking the EU SRE interrupt pair as an example, we treat the person on:

- [EU 1 PD schedule](https://ibm.pagerduty.com/schedules#PI7H0O6) as the **primary**
- [EU 2 PD schedule](https://ibm.pagerduty.com/schedules#PAM7LJT) as the **secondary**

## Main responsibilities

### Primary 

| Steps | Tasks  |
|---|---|
| Handover **Receipt** |**1.** Notify the previous shift you are ready for handover in [#sre-cfs](https://slack.com/app_redirect?channel=G542S3W1L)<br>**2.** When received, check the handover report from the previous team<br>**3.** Review the **Action Required** section especially!<br>**4.** Check for any on going maintenance<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_(posted by the `pdbuddy` bot in the Slack channel [#sre-cfs](https://slack.com/app_redirect?channel=G542S3W1L))_<br>**5.** Copy the handover into the [IKS-SRE-handover boxnote](https://ibm.ent.box.com/notes/428243739378?v=IKS-SRE-Handover) <br>&nbsp;&nbsp;&nbsp;&nbsp;_For subsequent editing as required - ready for handover transfer at shift end_<br>|
| Daily Duties |**- Respond** to [PagerDuty Alerts](https://ibm.pagerduty.com)<br>**- Monitor slack channels** for requests for assistance:<br>&nbsp;&nbsp;&nbsp;&nbsp;[#conductors](https://slack.com/app_redirect?channel=C54H08JSK) [#containers-cie](https://slack.com/app_redirect?channel=C4SN1JNG5)<br>**- Work on team tickets** which are tagged with the "interrupt" label in the [Team Board](https://github.ibm.com/alchemy-conductors/team#boards)<br>**- Bastion Connection** Create a new Service Now Incident to provide an access justification for the duration of shift. Close the INC at shift end|
| Handover **Transfer** |**1.** Post the handover report in the Slack channel [#sre-cfs](https://slack.com/app_redirect?channel=G542S3W1L)<br>**2.** Ask the next shift if they have any questions regarding the handover [#sre-cfs](https://slack.com/app_redirect?channel=G542S3W1L)<br>**3.** Reassign all [PagerDuty](https://ibm.pagerduty.com) alerts to the `Alchemy - Conductors Production (24x7)` team|

### Secondary 

| Precedence | Tasks  |
|---|---|
| 1.| Back up primary if assistance handling [PagerDuty Alerts](https://ibm.pagerduty.com) is required<br>_(only if requested by primary)_ |
| 2.| Work on ONLY Sev1 Emergency customer tickets in the "New Issues" or "With SRE" columns in [Zenhub](https://github.ibm.com/alchemy-containers/customer-tickets/issues#workspaces/customer-tickets-5a0a9223132a1305413e5530/board?labels=severity%3A%201&repos=256465) See https://ibm.ent.box.com/notes/725406982664 for more guidance.|
| 3.| Work on [compliance issues](https://github.ibm.com/alchemy-conductors/team/issues?q=is%3Aissue+is%3Aopen+label%3ACOMPLIANCE) with an approaching deadline, specifically scan failures.  Restore downed machines to health and restart agents if needed.|
| 4.| Review Change Management requests in prod ([#cfs-prod-trains](https://slack.com/app_redirect?channel=C529CCTTQ)) and monitor, if able,  stage trains ([#cfs-stage-trains](https://slack.com/app_redirect?channel=C529QD0QP)) |
| 5.| In the beginning of the week, team tickets would be reviewed. Work on team tickets which are tagged with the "interrupt" label in the [Team Board](https://github.ibm.com/alchemy-conductors/team/issues?q=is%3Aopen+is%3Aissue+label%3Ainterrupt) |

## PagerDuty / Environment monitoring responsibilities

Your main responsibilities are to respond to pagerduty alerts for the duration of your shift and ensure the stability of our production environments, and paging out the relevant development teams when assistance is required to resolve issues raised by our monitoring.  
These alerts will be triggered from the various systems we are responsible for and should all have corresponding [runbooks](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/) which detail how to deal with alerts.

Ignore low urgency alerts.  If you get any, we need to adjust the escalation policy to point to a product development team responsible for the component.  If you get any false alerts that are either too sensitive or useless, we can delete adjust the thresholds or delete them.  [SRE owns the alert configuration and is encouraged to make updates here](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/).

If you get a non-actionable alert or an alert that says "gather information and then create a GHE issue in our repo here for the team to look at later", that is clearly not urgent or an emergency, so please take time to update [armada-ops-alert-conf](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/) to set these as low urgency so they get routed to the product development team instead of SRE.  Non-actionable alerts contribute to alert fatigue.  SRE will not "gather information" for an alert that is not high urgency / emergency.

## Monitor slack

This is a joint responsibility.  Monitor slack for requests for help, or information about issues in our environments.  
[Guideline](https://ibm-argonauts.slack.com/archives/C54H08JSK/p1614039608345900) to deal requests from #conductors

The key channels to monitor are:

- [#sre-cfs](https://slack.com/app_redirect?channel=G542S3W1L) 
- [#conductors](https://slack.com/app_redirect?channel=C54H08JSK)
- [#containers-cie](https://slack.com/app_redirect?channel=C4SN1JNG5)
- [#platform-cie](https://ibm.enterprise.slack.com/archives/C073H0ZF2PQ)
- [#dreadnought-support-cie](https://ibm.enterprise.slack.com/archives/C04U1E4VDQA)

If necessary, if requests do appear here, request that a GHE issue is raised to document what has occurred and the actions taken to resolve.

Dreadnought channels to monitor for cluster update processing ([sample](https://ibm-cloudplatform.slack.com/archives/C06DEFEU21Z/p1728921957255109)):

- [#dn-s-bluefringe-compliance-monitoring](https://ibm.enterprise.slack.com/archives/C06DH2GDV1A)
- [#dn-s-cpapi-extended-compliance-monitoring](https://ibm.enterprise.slack.com/archives/C06DEFEU21Z)

## Stage & Prod train approvals

This is usually a responsibility of the secondary on-call.
Please monitor these slack channels for requests to promote code to production:

- [#cfs-prod-trains](https://slack.com/app_redirect?channel=C529CCTTQ)
- [#dn-sre-prod-trains](https://ibm.enterprise.slack.com/archives/C07A7TM0WNN)

[Learn the basics about fat-controller and train management](https://github.ibm.com/sre-bots/fat-controller/blob/master/README.md#basics-about-how-to-use-fat-controller).

### How to decide what trains to approve and trains policies and Service Level Agreements (SLAs)

[Learn some details about trains policies](https://github.ibm.com/sre-bots/fat-controller/blob/master/README.md#trains-policies-and-service-level-agreements-slas).

The trains that we receive in [#cfs-prod-trains](https://slack.com/app_redirect?channel=C529CCTTQ) do not satisfy one or more of these policies and they will have to be examined and manually approved or rejected by the conductor on-call. After issuing a `describe <CH...>` the output will show a list of the failed policies at the top with ⚠️ (warning) signs, [see an example](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1712294087521119?thread_ts=1712294086.869749&cid=C529CCTTQ):

<img src="https://media.github.ibm.com/user/371567/files/f31f066b-473c-4573-89c0-afe571ac18f1" width="700">

**Follow the table below to know how to action trains in [#cfs-prod-trains](https://slack.com/app_redirect?channel=C529CCTTQ), the table contains failed policies in descending order according to the level of priority, being the top (1.) the most critical policy failure**:

| Priority | Failed policy | Exceptions | Default action |
|---|---|---|---|
|1.| `cie` | [If `ExceptionJustification` to fix a CIE problem is provided](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/trains-sla-policies/docs/runbooks/conductors_interrupt_pair.md#refer-teams-for-approval), review and approve the train. | Wait until CIE is resolved and then, [re-evaluate trains](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/trains-sla-policies/docs/runbooks/conductors_interrupt_pair.md#re-evaluating-trains) if needed.|
|2.| `change_freeze` | [If `ExceptionJustification` provided](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/trains-sla-policies/docs/runbooks/conductors_interrupt_pair.md#refer-teams-for-approval), review and approve the train. | Reject the train.|
|3.| [`business_hours`](https://github.ibm.com/alchemy-conductors/change-management/blob/2c6dcec01ca5bf762b5b71725f5c4956d11bb54d/policy/global/helpers/helpers.rego#L34) | [If `ExceptionJustification` provided](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/trains-sla-policies/docs/runbooks/conductors_interrupt_pair.md#refer-teams-for-approval), review and approve the train. | Reject the train.|
|4.| `stage_bake` | [If `ExceptionJustification` provided](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/trains-sla-policies/docs/runbooks/conductors_interrupt_pair.md#refer-teams-for-approval), review and approve the train. | Reject the train.|
|5.| `on_hold` | If train has CRB approval, review and approve the train. | Reject the train.|
|6.| `global/sla` | `ExceptionJustification` is typically not required. | Review and approve. [Procedure for phased deployment rollout](https://ibm-argonauts.slack.com/archives/C05LAG8A3AL/p1692717328861899).|

#### Key things to notice

- **It is up to the team raising the change request (train) to make sure that their processes fit with policy.** If they really need the train, they can re-raise it.

- The trains that we will receive more frequently in [#cfs-prod-trains](https://slack.com/app_redirect?channel=C529CCTTQ) will have a policy result of `manual => global/sla: no SLA defined` which means there has not been an SLA defined to auto-approve this train. Note that this means that all of the other checks have passed (24h stage bake, CIE, business hours etc). The goal is to encourage squads to onboard to auto-approval via SLA as much as possible, to reduce the number of `manual => global/sla: no SLA defined` down to only those changes which cannot be managed via SLA.

- The `ExceptionJustification` field can be used when raising a train to preemptively tell Conductors that they already have approval and give a link to the approval.

- A `describe <CHG...>` will highlight the `ExceptionJustification`:

<img src="https://media.github.ibm.com/user/371567/files/c4238e95-a39c-4ae7-8d71-df2ed3381358" width="600">

### Temporary exceptions

Temporary exceptions can be added to trains for a specified amount of time up to 6 hours, some commands for managing exceptions are:

- `create exception <result>(approved|rejected|manual) <path> lasting <duration> [for <configuration item> [<squad> [<service>]]] because <justification>`: create an exception with the supplied parameters. See some examples below on how to use this command in #cfs-prod-trains:

   [`create exception approved global.business_hours lasting 4h for containers-kubernetes tugboat-updater auto-update because tugboat-updater was approved by Ralph to deploy during US-South hours for patch updates only`](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1710963389892759)

   [`create exception approved global.stage_bake lasting 40m for containers-kubernetes va-reload va-reload because worker reload fall under operations exceptions`](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1711556623847129)

- `list exceptions`: list exceptions. See an example of [how to use it in #cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1712746815537129) and the [result](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1712746817063079).

- `delete exception <id>`: delete an exception by ID. See an example of [how to use it in #cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1711454838694629) and the [result](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1711454840166539).

### Re-evaluating trains

- After a `start trains` is issued, pending trains are automatically re-evaluated. The `start_time` policy then comes into play (e.g. what about a 6h CIE).
- After a conductor creates a temporary exception trains created previous to the creation of the exeption will not be affected by such exception (e.g. tugboat-updater is doing something unexpected and there are 80 pending trains), to apply the temporary exception retoractively to these pending trains, the conductor can issue the command 

   `reevaluate <TRAIN_ID> <TRAIN_ID> <TRAIN_ID>...`
   
   to have them re-evaluated, including the new exception that's in place. See this example [`reevaluate CHG7687021`](https://ibm-argonauts.slack.com/archives/C529CCTTQ/p1711452404313609).

### Refer teams for approval

If trains from a particular team need approval from world wide leads, refer the team to this channel [#bluemix-cr-exped-reqs](https://ibm.enterprise.slack.com/archives/C2H02RLN5). Once they create a thread in that channel and get approval in it, they are allowed to provide a link to said thread to the field `ExceptionJustification` in their trains as a valid form of an exception justification.

### Train stoppage and management during CIE

When a CIE is raised via `ciebot`, CIEbot will send an API call to stop the trains.

We can also `stop trains all MESSAGE` manually if needed.

Once the CIE is over, we must manually start trains again via `start trains all`.

CIEbot will not automatically start trains, in case the Interrupt pair need to triage pending
trains and for example reject any known bad changes which are pending.

After trains are started, fat-controller will automatically re-evaluate the pending trains.
If for example, a train would have been auto-approved except for the CIE, then the re-evaluation
may result in the auto-approval. Or, if it was a long CIE, the train may be auto-rejected
because it can no longer be fulfilled within its designated Start and End times.

### Train stoppage and management during Cloud Freezes

Previously we would issue `stop trains all ...` to indicate a Cloud Freeze. This is no longer required.

The Freeze calendar is defined in the [charts](https://github.ibm.com/alchemy-conductors/charts/blob/master/change-management/templates/config.yaml#L10-L68) repo. This is manually copied from the [Freeze Calendar](https://ibm.ent.box.com/notes/363418901050?v=FreezeCalendar). A future [enhancement](https://github.ibm.com/alchemy-conductors/elba/issues/575) will be to read directly from the ServiceNow Freeze API.

`stop trains` and `start trains` should only be used for CIE stoppages now.

The policy evaluation for trains treats CIE stoppages and Cloud Freezes separately. The policies are defined in the [change-management](https://github.ibm.com/alchemy-conductors/change-management) repo.

#### Should we reject during a freeze?

Referring to the table above, if the policy decision includes `change_freeze` then unless there is an `ExceptionJustification` the train should be rejected.

**Train with exception justification - `describe` the train to see the details**
```
Train      Who                   State     Env       Title                              Policy
CHG8144173 containers-kubernetes Pending   us-east   Deploy razeeapi (e1176f to 81ed70) manual => global/sla: no SLA defined; scheduling.change_freeze: there is a scheduled change freeze
```

**Train with NO exception justification**
```
Train      Who                   State     Env       Title                              Policy
CHG8147162 iks sre   Pending   ap-north  Deploy addon-csutil-experimental ([1]: 1991 -> 2001) manual => global/sla: no SLA defined; scheduling.change_freeze: there is a scheduled change freeze and no exception justification supplied
```


Trains which do not violate the freeze policy would have a different policy decision. In particular, if the result is `global/sla: no SLA defined` then the train can be approved if there are no other reasons to stop it.

```
Train      Who       State     Env        Title                  Policy
CHG8144949 netint    Pending   us-south   CBR Subnet Deploy 3660 manual => global/sla: no SLA defined
```

## External Customer tickets

SRE is not support and should not work any customer ticket other than Sev1 EMERGENCIES and anything that REQUIRES an SRE such as a quota limit increase.  The Sev1 issues are [here](https://github.ibm.com/alchemy-containers/customer-tickets/issues#workspaces/customer-tickets-5a0a9223132a1305413e5530/board?labels=severity%3A%201&repos=256465)

Please see [SRE customer ticket guidance boxnote](https://ibm.box.com/s/9nz5m1ofh81f7e7hecza8aynfhov85r2) for detailed guidance on handling customer tickets.

- Do not work on Sev 2-4 tickets unless they absolutely require SRE (such as a quota limit increase).
- SRE will not troubleshoot a product/service issue beyond ensuring our control plane components are all healthy.
- SRE will not gather or provide "must gather" information to a product development team but can if the issue is a Sev1 Emergency.
- If the issue is for another product development team, verify the health of the customer's cluster in our control plane, and if that's healthy, immediately escalate to a product dev team and let them know via Slack so it is not ignored.

**NB:** Under no circumstances should updates be made directly into ServiceNow.

## Internal tickets / Team board

This is a joint responsibility of both SREs on-call.  
Internal teams will raise [GHE issues against conductors here](https://github.ibm.com/alchemy-conductors/team#boards?repos=61104).  
Please use the [readme](https://github.ibm.com/alchemy-conductors/team/blob/master/README.md) which details how to monitor and action the items raised against Conductors.  

## Runbook PR merges

This is a joint responsibility of both SREs on-call.  
Review PRs from other squads for runbooks [here](https://github.ibm.com/alchemy-conductors/documentation-pages/pulls)

## Runbook improvements

The interrupt pair should spend time reviewing at least one runbook each week.  
Base runbook reviews on:

- Issues raised in [GHE](https://github.ibm.com/alchemy-conductors/documentation-pages/issues)
- Experiences on handling PD alerts - what runbooks have caused you pain this week?  Go improve them!

All runbook reviews and PRs raised should be tracked in this [boxnote](https://ibm.box.com/s/903px294qgnr0s3ghoih3kkcz644is2u)

## Automation / process improvement candidates.

The interrupt pair is a crucial role which should lead to scope for automation and improvements.  
Please do try and identify automation candidates from pager duty incidents and flow tickets.  
You should try and spot trends and document ideas where you think processes can be improved, changed or automated.  
Any small pieces can be worked on during your interrupt shifts but do not let it impact other priorities.  
Please add any information relevant to this to the following [boxnote](https://ibm.box.com/s/oigk9zdbblbsh9l0iraderaan0nmdiqa).

## Useful links

- [Dealing with customer tickets](./conductors_support_tickets.html)
- [Conductors common tasks](./sre_contents.html){% endcapture %}

{{ entire_document }}
