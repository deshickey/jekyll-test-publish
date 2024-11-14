---
layout: default
description: armada-iam-events is experiencing failures interacting with BSS
title: armada-iam-events BSS down
service: armada
runbook-name: "armada-iam-events BSS trouble shooting"
tags: armada, iam, events, BSS
link: /armada/armada-iam-events-BSS-issues.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# armada-iam-events BSS debugging

## Overview

armada-iam-events interacts with IBM Cloud BSS to create and remove user roles inside of IKS clusters. If communication with
BSS is broken, then our service is also broken.

## Example alert
{% capture example_alert %}
- `ArmadaIAMEventsBSSError`
{% endcapture %}
{{ example_alert }}

## Action to take

### Verify BSS is up  
View the status of BSS (Business Support Service) via the [IBM Cloud portal](https://cloud.ibm.com/status). It is also worth checking if there is an ongoing cie in [#BSS-cie](https://ibm-argonauts.slack.com/archives/CE8C0C9GS).

<br/>
_NOTE: Status and maintenance notifications for IAM and BSS components show up under the generic component name "Cloud Platform".  You will often need to read the notification for more context to determine whether or not it is relevant.  Here is an example maintenance notification for GHoST:_
<p align="center">
    <a href="images/example-ghost-maintenance.png">
        <img src="images/example-ghost-maintenance.png" alt="example_ghost_mainteance_notification" style="width: 640px;"/>
    </a>
</p>


### Mitigation

### BSS Down

If there is an on going BSS CIE, there's nothing else to be done. If BSS is down without a cie, then engage the team in #BSS-cie
to get a CIE started.

## Escalation Policy

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }}) in the event that this alert fires
and there is no on going BSS outage.

## Automation
None
