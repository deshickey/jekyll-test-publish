---
layout: default
description: How to handle node exporter problem on a master node.
title: armada-ops - How to handle node exporter problem on a master node.
service: armada
runbook-name: "armada-ops - How to handle node exporter problem on a master node"
tags: alchemy, armada, master, node-exporter
link: /armada/armada-ops-node-exporter-on-carrier-master-troubled.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with a node exporter problem on a master node.

## Example alerts

Example PD title:

- `#3474841: dev.containers-kubernetes.10.130.231.176_carrier-master_node-exporter_scrape_failure.mex01`


## Investigation and Action

Node exporter on a carrier master runs as a Docker container.  Usually the fastest way to resolve scrape failures is to restart the container.

`docker ps | grep node-exporter`

Find the hash from the above output eg. `b0b06ec77dc2`.

`docker restart b0b06ec77dc2`

If you can not find the container on the carrier master, go to section `Deploy node exporter to carrier master`

## Follow-up actions

Make the sure the Docker container is running with `docker ps | grep node-exporter` after the restart.

If the container can not be started correctly, check the log of the container. 

`docker logs b0b06ec77dc2`

Check the image used by the container.

`docker inspect b0b06ec77dc2`

Find the image info from above output, e.g.

`"Image": "sha256:188af75e2de0203eac7c6e982feff45f9c340eaac4c7a0f59129712524fa2984"`

Check if the image version is out of sync, compare it with other carriers without the alert

```bash
root@prod-dal12-carrier4-master-01:~# docker images | grep 188af75e2de0
registry.ng.bluemix.net/armada-master/node-exporter     668                        188af75e2de0        3 months ago        22.9MB
```

If the image version is outdated，follow the instructions in `Deploy node exporter to carrier master`

## Deploy node exporter to carrier master

We need to run this jenkins job [armada-carrier-deploy](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/) with tag node-exporter to deploy the node-exporter to the carrier master.

Before you run, please ask in the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) channel to make sure that the certain BOM levels or tags are ready to run against production. Please do not run the job if you are not sure.

Raise a prod train if you are going to do the deployment on production environments.

After the prod train get approved, run the job. Refer to [this job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/2593/parameters/) about how to fill in the parameters.

## Escalation Policy

Node exporter is managed by the [armada-ops escalation policy](https://ibm.pagerduty.com/escalation_policies#PL6OBVK).

[Create an issue for armada-ops](https://github.ibm.com/alchemy-containers/armada-ops/issues/new) to track.  
