---
layout: default
description: How to change which carrier masters are deployed to by default.
title: Changing the default carrier for masters
service: armada-deploy
runbook-name: "Changing the default carrier for masters"
tags: alchemy, armada, kubernetes, armada-deploy, microservice, patrol, carrier
link: /armada/armada-deploy-update-patrol-carrier.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes the process for changing the default carrier for cruiser masters.

Note: patrol masters are currently selected round-robin among all the patrol carrier masters in a region.

## Detailed Information

Occasionally a carrier will reach it limit for number of pods, and it will be unable to create any new pods or cluster-masters will experience frequent evictions due to resource pressure.
This will cause master deploys to fail on that carrier or make existing cluster masters unstable.
This issue can be temporarily resolved by changing the default carrier that the masters are deployed to.

### Finding a Carrier with Capacity

First we have to find a carrier that can support the new masters.

* The number of pods per host can be queried for a region using the HMS Victory tool in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel.

* Type the following query `@victory pods-per-host <region>`.

* HMS Victory will display each carrier in that region, along with the number of pods running on each carrier. Note which carrier has the fewest pods.

Note that the limit for each carrier is around 1400 pods. If all the carriers in a region are at or near that limit, proceed to the [More Help](#more-help) section.

### Changing the Default Carrier

Once we know which carrier to route the masters to, we can set that carrier as the default for patrols.

* Locate the datacenters.json file in the armada-config-pusher repo for the region you are seeing the failures. i.e. https://github.ibm.com/alchemy-containers/armada-config-pusher/blob/master/json-templates/us-south/datacenters.json

* Locate the section of the file that defines the masterTargets for the failing carrier. It will look similar to this
   ```
   "type": "patrol",
   "masterTargets":[
     {
       "name":"prod-dal12.carrier2",
       "vip":"169.47.70.10",
       "enabled":"false"
     },
     {
       "name":"prod-dal12.carrier4",
       "vip":"169.47.104.210",
       "enabled":"true"
     },
     {
       "name":"prod-dal12.carrier5",
       "vip":"169.47.72.34",
       "enabled":"false"
     },
     {
       "name":"prod-hou02.carrier6",
       "vip":"184.173.44.62",
       "enabled":"false"
     }
   ]
   ```
   Set enabled to `"false"`.

* Locate the carrier found in [Finding a Carrier with Capacity](#finding-a-carrier-with-capacity) and set enabled to `"true"`.

* Check the other `masterTargets` stanzas and update as needed. There is one of these stanzas for each zone.
For us-south cruiser masters, you have to make this change in 3 places.
See this PR for an example: https://github.ibm.com/alchemy-containers/armada-config-pusher/pull/234

* Create a pull request in armada-config-pusher with this change, and ask for a review and merge in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel.

* Once the PR is merged, you have to wait for the travis build on the master branch to complete.
Go to https://travis.ibm.com/alchemy-containers/armada-config-pusher/builds and look for the `master` branch build with your PR #.
You'll see something like `#1307 passed` and a commit hash `71be5d0`

* Now go to the razeedash dashboard for the armada-config-pusher deployment (rules tab) - https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-config-pusher

* Look for the rules section for a carrier in the correct region.

* Click the rule dropdown, and look for something "1307-71be5d0...." using what you saw from the Travis build.  Select it.  Click the `Request change` button.

* This will take some time as it generates a prod-trains requests, etc.
The person making this runbook update didn't go through the rest of that process, but it should all happen without further action on your part.

## More Help
If you need any further instruction on this topic, please visit the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel.
