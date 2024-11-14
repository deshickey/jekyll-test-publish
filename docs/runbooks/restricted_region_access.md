---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Explains the process required to add accounts to the feature flag for restricted regions.
title: How to provide an account access to a Restricted Region
runbook-name: "How to provide an account access to a Restricted Region"
link: /restricted_region_access.html
service: Conductors
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

A restricted region is a region in which only specified accounts are permitted to make API calls. For this reason, even API calls that do not require credentials in other regions will require them in a restricted region. Access is controlled through a LaunchDarkly feature flag. This runbook describes how to add accounts to that feature flag.


## Access Required

Editing the feature flag requires a prod-trains request and only certain people have access to make LaunchDarkly feature flag edits for production.

## Detailed Information

1. Collect the BSS Account IDs for those to be added.
2. Create a prod-trains request in the cfs-prod-trains channel in Slack.
3. Once the train is approved, run `start train <ticketID>`. See the example prod-train below. 
4. Edit the configuration for the appropriate region. At the time of this writing there is a single restricted region:
    [eu-fr2](https://app.launchdarkly.com/armada-users/production/features/armada-api.eu-fr2/targeting)
5. Verify that the feature flag is set according to the example feature flag below (should only need to be done the first time).
6. Add the BSS account IDs to the text box in "Target users who match these rules".
7. Click the green Save Changes buttton at the upper right.
8. Complete the train with, `complete train <ticketID>`.

## Example prod train

~~~
Squad: operations
Title: Add BSS accounts to eu-fr2 region
Environment: eu-fr2
Details: |
 https://github.ibm.com/alchemy-conductors/team/issues/8023
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 30m
Ops: true
BackoutPlan: remove the accounts
~~~

## If this is a new region, refer to the example configuration

[Here](https://app.launchdarkly.com/armada-users/preprod/features/armada-api.eu-fr2/targeting) is example configuration.

The following attributes are the important ones for setting up access to a restricted region. These attributes should only need to be set the first time when creating a new restricted region. Subsequent edits (to add new users) should not need to reference this section.
* Targeting is on.
* Under "Target users who match these rules", serve True if bssAccountID "is one of" with the set of permitted bss account IDs in the text box. 
* The default rule is serve False
* If targeting is off serve False, targeting is On. 
