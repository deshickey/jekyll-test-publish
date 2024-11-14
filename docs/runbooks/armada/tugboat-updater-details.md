---
layout: default
description: Details how tugboat-updater functions
title: Tugboat-updater details
service: conductors
runbook-name: "Tugboat-updater details"
tags: alchemy, tugboat-updater, tugboat, updater, disable, tugboat updater
link: /tugboat-updater-details.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
- This runbook details how tugboat-updater works

## Detailed Information
Tugboat-updater is the tool that manages tugboat worker updates.

### Updates
Every two weeks a new bom is released, for compliance reasons, this bom must be rolled out to every tugboat worker within two weeks. As soon as the bom is released, preprod updates begin. Once all of stage-us-south-carrier100's workers are updated, and that information is recorded in the [version file](https://github.ibm.com/alchemy-conductors/tugboat-updater/blob/master/versions.json), prod updates will start 24h from that time.

### Config
The instructions for how tugboat-updater operates are stored in a config map.
- MZR example: https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/dev-south/spokes/dev-dal10-carrier100/tugboat-updater-config.yaml#L18-L82
- SZR example: https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/dev-south/spokes/dev-dal10-carrier101/tugboat-updater-config.yaml#L18-L105

Fields in configmap:
- group: For SZRs we simulate 3 zones with 3 different workerpools. This is the reason for the `group` structure. All worker pools in a single group will be treated as a single worker pool.
- name: Arbitrary name which is likely the name of the workerpool(s) contained in that group
- update_limit: Number of workers contained within that group which can be updated in //.
- zone_label: This is the label used by SZRs to simulate 3 zones. It is used the same way in prod, except with real zones. This label is used to determine which workers can be safely reloaded in //.

### Pause tugboat-updater
If a train is rejected the tugboat-updater will pause for 6h before raising a new train.
This is defined by `RejectedTrainPauseDuration` [here](https://github.ibm.com/alchemy-conductors/tugboat-updater/blob/5a7881b241295de7da3760f10db0107cee73298a/updater/updater.go#L33). This is on a per tugboat basis. Upon approvel, the regular frequrency will resume. Currenly 30m, with a long term target of 10m. This is controled by [MainLoopFreq](https://github.ibm.com/alchemy-conductors/tugboat-updater/blob/5a7881b241295de7da3760f10db0107cee73298a/main.go#L31)

### Turn off tugboat-updater

**Note: It is critical to re-enable tugboat-updater in the case it is disabled for a CIE, once the CIE has been resolved, to maintain our compliance posture**

In the situation (such as a CIE to prevent workers from being updated) where you may need to disable tugboat-updater you can follow these steps to disable the automation. 

The feature flag [tugboat-updater-enabled](https://app.launchdarkly.com/armada-control-plane/production/features/tugboat-updater-enabled/targeting) manages tugboat-updater enablement across all regions.
- The first rule is `global`. If this is disabled, all tugboat-updater instances across all preprod and prod will be disabled.
- The other rules are for individual regions. Use these flags to disable a single region only.

When tugboat-updater is in a 'disabled' state, It will query LaunchDarkly ever 10 minutes to check if the flag has been enabled. If so, updates will resume.

### Alerts

The alert runbook can be viewed [here](./tugboat-updater-alerts.html)

## Further Information
- Slack [#conductors](https://ibm-argonauts.slack.com/messages/C54H08JSK) for further info on this topic
