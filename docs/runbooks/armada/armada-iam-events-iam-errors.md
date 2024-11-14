---
layout: default
description: armada-iam-events is experiencing failures interacting with IAM
title: armada-iam-events bss down
service: armada
runbook-name: "armada-iam-events iam trouble shooting"
tags: armada, iam, events
link: /armada/armada-iam-events-iam-issues.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# armada-iam-events iam debugging

## Overview

armada-iam-events interacts with IBM Cloud IAM to create and remove user roles inside of IKS clusters. If communication with
IAM is broken, then our service is also broken.

## Example alert
{% capture example_alert %}
- `ArmadaIAMEventsIAMError`
{% endcapture %}
{{ example_alert }}

## Action to take

### Verify BSS is up  
View the status of IAM via the IBM Cloud portal. It is also worth checking if there is an ongoing issues in #iam-issues and #iam-cie.

<br/>
_NOTE: Status and maintenance notifications for IAM and BSS components show up under the generic component name "Cloud Platform".  You will often need to read the notification for more context to determine whether or not it is relevant.  Here is an example maintenance notification for GHoST:_
<p align="center">
    <a href="images/example-ghost-maintenance.png">
        <img src="images/example-ghost-maintenance.png" alt="example_ghost_mainteance_notification" style="width: 640px;"/>
    </a>
</p>


### Mitigation

### BSS Down

If there is an on going IAM CIE, there's nothing else to be done. If IAM is down without a cie, then engage the team in #iam-cie
to get a CIE started.

## Escalation Policy

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}) in the event that this alert fires
and there is no on going IAM outage.

## Automation
None