---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Explains how Conductors handle support tickets.
service: Conductors
title: Handling IBM Cloud Support Tickets
runbook-name: "Handling IBM Cloud Support Tickets"
link: /conductors_support_tickets.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Content

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

---

## Overview

This runbook describes the process for handling IBM Cloud support tickets.  SRE ONLY deals with Sev1 EMERGENCY tickets and any other ticket that absolutely requires an SRE such as a quota limit increase in production.  Please see (this Box note)[https://ibm.box.com/s/9nz5m1ofh81f7e7hecza8aynfhov85r2] for more information on prioritization.

## Related runbooks

The following [hints and tips runbook] provides hints and tips to help the actual investigation of an Armada customer ticket.

## Detailed Information

Make sure you have access to the following.
To request access talk to your Squad lead.

- The the Github repositories that hold
the customer support tickets.

  - Containers: [Container support tickets]

- [ServiceNow]

  ServiceNow access is only needed by conductors to see any extra relevant
  information that has been provided.
  You should not update the ServiceNow case directly.

## Detailed Procedure

{% capture support_tickets_procedure %}  
1. Customer will raise a support ticket.

   The support ticket will appear in ServiceNow as a _case_

   The DSET support team will provide initial triage and request extra customer details.

2. If the DSET team need to involve the Containers Tribe, the DSET team will create a GHE issue.

   If the _case_ is high severity then a PagerDuty alert will also be created.

3. Conductors will provide first response on new Sev1 Emergency cases assigned to our GHE repo.

   - Verify the customer's cluster is healthy on our control plane (Carriers & tugboats) -- if it's not, work to fix that.  If it is healthy, determine which team owns the component or codebase in question and escalate to them immediately.
   - assign the GHE issue to yourself.
   - work on the problem, making notes as you go.
   - Move the work item to pipeline __With SRE__
   - To contact support, use _@support_ in a comment to request extra information or when a resolution is provided.
   - Close the GHE issue when the problem is solved or a question is answered. If you were alerted to the issue via a PagerDuty alert, resolve the pagerduty alert, ensuring you've added a note with actions taken.
   - If more information is requested, keep the GHE open and add the _waiting on response_ label. If you were alerted to the issue via a PagerDuty alert - keep the alert open incase escalation is required.

5. Ignore all Sev2, Sev3 and Sev4 issues unless they absolutely require an SRE such as a quota limit increase in production.
   - SRE does not have the bandwidth to work support for other product teams.
   - SRE is not second level support or "go-between" for support and product development squads.
   - SRE is responsible for 1) Production operational readiness and 2) Emergency Response.

## Listing Support Tickets

- [Dashboard for all Support tickets]

[General Troubleshooting]: ./sre_contents.html

[ServiceNow]: https://watson.service-now.com/

[Container support tickets]: https://github.ibm.com/alchemy-containers/customer-tickets

[Dashboard for all Support tickets]: https://github.ibm.com/alchemy-containers/customer-tickets/issues#boards?repos=256465

[hints and tips runbook]: ./conductors_support_tickets_hints_and_tips.html

{% endcapture %}  
{{ support_tickets_procedure }}
