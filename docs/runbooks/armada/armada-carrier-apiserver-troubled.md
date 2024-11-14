---
layout: default
description: How to handle an apiserver which is troubled.
title: armada-carrier - How to handle an apiserver which is troubled.
service: armada
runbook-name: "armada-carrier - How to handle an apiserver which is troubled"
tags: alchemy, armada, node, down, troubled, apiserver
link: /armada/armada-carrier-apiserver-troubled.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to deal with alerts reporting that the armada carrier-master apiserver is troubled.

The apiserver runs on the carrier-master server.

## Example alerts which would have brought you here

- `bluemix.containers-kubernetes.carrier-master_apiserver_scrape_failure.us-south`
- `ibmcloud.CloudFunctions.functions-prod-us-east-02.10.188.165.173_carrier-master_apiserver_scrape_failure.us-east`

This alert means that prometheus has been unable to scrape metrics from the apiserver metrics endpoint for over 5 minutes.

## Investigation and Action

#### Checklist:

- Go to [Alchemy Dashoard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and access prometheus for the environment

- If you see `kubernetes-apiservers` showing `down` scraping of the node is failing.

##### Action to take

- Attempt to ssh to the `carrier-master-01` for the environment mentioned in the alert.

  For example:
  ~~~
  ssh user@prod-dal12-carrier2-master-01
  ~~~

- If the master cannot be accessed, then use the Softlayer portal to reboot the server to bring it back online.  

  _NB: Only Conductors have access to do this so engage the SRE squad if this is required_

- If the carrier master can be accessed check the health of the server by executing these commands.

  1. `sudo crictl ps` - shows if containerd is running
    - If this hangs or returns an error, restart the containerd process using `sudo service containerd restart`
  1. `top -b -c -n 1 -o %CPU` - check for any processes consuming high percentage of CPU.
    - TODO: Define what should be done with a high `/hyperkube apiserver` or other processes
  1. `service kubelet status` - verify that the kubelet is running


## Escalation Policy

If the machine is in-accessible and reboots or power cycles from Softlayer portal fail to bring the machine back, or if the Softlayer portal displays errors stopping you from performing these actions, then raise a ticket against Softlayer to assist bringing the machine back online.

If the scrape failure does not resolve and a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-carrier.escalate.name }}]({{ site.data.teams.armada-carrier.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.issue }}) Github repository for later follow-up.
