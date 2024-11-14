---
layout: default
description: Scale Out Existing Carrier
title: armada-carrier - Scale Out Existing Carrier
service: armada-carrier
runbook-name: "Armada Runtime - Scale Out Existing Carrier"
tags: alchemy, armada-carrier, carrier, master, worker
link: /armada/armada-scale-out-existing-carriers.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook documents the steps for adding more workers to an existing production carrier.

## Detailed Information

### Background
You have reached your limits on the current hosts and you need to add more workers to add capacity.

### Steps

##### 1) Order Machines

Follow steps [here](../sl_provisioning.html#provisioning-machines-needed-for-a-carrier) and order machines via the [provisioning app](https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/).

##### 2) Validate Bootstrap and Smith have passed

Run [this job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/job/check-bootstrap-and-smith/build). If it passes, all machines passed to it are ready for deploy.

If bootstrap/smith have not passed after an hour, you may need to [re-excute bootstrap](../bootstrap_overview.html).

##### 3) Deploy to the Carrier Master and Workers

To perform this step, you must ask for permission by filling out the provided template in the cfs-prod-trains Slack channel.  From there, the oncall conductors will be able to approve your request for scale-out.

We deploy to carriers using the [Armada-Carrier-Deploy](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/view/Armada/job/armada-carrier-deploy/) Jenkins Job.

Select `Build With Parameters`.  All of the submodules needed will default to their `master` branches but the job also provides you a way to specify specific commit levels from each repository if you want to target a certain code level.  `Master` branch should be sufficient for the most part.

##### 4) Verify the New Workers

After the Jenkins job for deploying finishes, please check on the new nodes that you have added via the [Verify Carrier Worker Node Runbook](./armada-carrier-verify-carrier-worker-node.html).  

It is okay to cordon the new nodes while you verify them.  `armada-cordon-node --reason "Verifying new nodes" NODE_IP_ADDRESS`

Please uncordon them when you are done verifying they are ready to accept work.
