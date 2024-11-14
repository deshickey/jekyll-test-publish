---
layout: default
description: How to edit the armada-deploy microservice configuration at runtime
title: Editing the armada-deploy microservice configuration at runtime
service: armada-deploy
runbook-name: "Editing the armada-deploy microservice configuration at runtime"
tags: alchemy, armada, kubernetes, armada-deploy, microservice, config
link: /armada/armada-deploy-modify-config.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes how to modify the configuration settings of the armada-deploy microservice at runtime.

Changing a config setting at runtime may be necessary to enable/disable something that isnt working right, or tweak a setting based on current environemnt needs.

Modifying the armada-deploy configuration involves editing the corresponding armada-deploy configmap.  The configmap is where all of the current config settings that armada-deploy uses are read from.  They are read in and stored at pod start-up time.  Thus in order for change to the configmap to take affect, the armada-deploy pods will all need to be restarted.  The steps in the section below outline how to do this.

## Detailed Information

The following sections detail how to perform the actions.

## Modifying the Config Map
To make a change to the configmap and have the running deploy pods pick it up, you'll need to take the following actions:

* SSH to the desired carrier master

* Edit the armada-deploy configmap

~~~
kubectl -n armada edit cm armada-deploy-config
~~~

This will open the default shell editor and show you all of the config values that deploy uses.

Find the key setting you wish to change, modify it to your desired value, and save that file.  You should see a message like `configmap "armada-deploy-config" edited` if you have successfully made changes to the configmap.

* Restart all deploy pods
In order for the config change to take affect, all pods must be restarted.  You can do this with the following command, which will delete all the deploy pods and have kube recreate them:

~~~
kubectl -n armada delete pod -l app=armada-deploy
~~~

After a few minutes, all pods will be back up and running with your new config change!

## Common Config Modification Scenarios

#### Enable/Disable automatic master updates
The config option to turn on/off automatic master updates is `enable_master_auto_updates`.  Just follow the steps above to set this value to true/false.

#### Tweak automatic master update pod threshold
The config option to update the automatic master update pod threshold is `pod_in_use_update_threshold`.  Follow the steps outlined above to modify this threshold to your desired value.

This setting controls how many deploy pods will be consumed with auto-update operations at peak auto-update times.  The higher the %, the more pods that will be allowed to perform auto-updates at the same time.  Using 30% as an example, and assuming there are 10 deploy pods running, it would mean that, at most, 3 deploy pods will be performing auto-updates at the same time.  This ensures that we have at least 7 pods available to perform other deploy operations at any point in time.

## More Help
If you need any further instruction on this topic, please visit the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel.
