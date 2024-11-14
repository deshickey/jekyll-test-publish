---
layout: default
description: armada-global-api is experiencing GHoST failures
title: armada-global-api GHoST failures
service: armada
runbook-name: "armada-global-api ghost trouble shooting"
tags: armada, global-api, carrier, ghost
link: /armada/armada-global-api-ghost-error-code.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Global-API GHoST troubleshooting

## Overview

armada-global-api is experiencing HTTP failures when communicating with GHoST.

## Example alert
{% capture example_alert %}
- `ArmadaGlobalAPIGHoSTFailure`
{% endcapture %}
{{ example_alert }}

## Action to take

### Verify that GHoST is healthy

1. Use this curl locally from your laptop, `curl https://api.global-search-tagging.cloud.ibm.com/health` to get a good sample size run the command 10 times. You should get back multiple 400 errors. This verifies that GHOST is reachable. If GHoST is not reachable or the return code is 5XX escalate the page to this team <https://ibm.pagerduty.com/escalation_policies#PIIBNSN>.

If a page out to the GHoST team is needed, please ensure we turn off the data route to GHoST.

To turn off the data route to GHoST, go here <https://app.launchdarkly.com/armada-users/production/features/armada-global-api.data-route/targeting>. With
prod train approval switch all targets to use the *regional* variation. Make sure to get an approved prod train first!
Also send a message tagged with `@ironsides` in the Slack channel `#armada-api`, letting them know the global API data route was changed in production. This way the team is made aware of the FF change and can take further action at a later date.

Once GHoST is healthy again, we need to turn the GHoST data route on again so users can have faster response times. Navigate to <https://app.launchdarkly.com/armada-users/production/features/armada-global-api.data-route/targeting>
and switch all targets to the *both-with-cancelation* variation. This also requires a prod train.

2. If the /health endpoint returns that GHoST is up, follow the escalation policy.

## Escalation Policy
Please notify {{ site.data.teams.armada-api.comm.name }} and create an issue here {{ site.data.teams.armada-api.link }}.  

- Escalate to [{{ site.data.teams.armada-api.escalate.name }}]({{ site.data.teams.armada-api.escalate.link }})

## Automation
None
