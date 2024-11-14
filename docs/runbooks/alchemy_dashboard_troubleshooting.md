---
layout: default
description: What to do when the functionality on the dashboard is not working or otherwise down
service: Runbook needs to be updated with service
title: Alchemy-Dashboard troubleshooting
runbook-name: "Alchemy Dashboard Troubleshooting"
tags: dashboard, alchemy, production, staging, dev
playbooks: ["Runbook needs to be Updated with playbooks info (if applicable)"]
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
link: /alchemy_dashboard_troubleshooting.html
type: Troubleshooting
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

What to do when the functionality on the dashboard is not working or otherwise down

## Example Alerts

There are none

## Investigation and Action

Alchemy-dashboard is hosted on bots (d34580e8ca3a47939515766ff7d9d515) cluster in `278445 - Alchemy Support` account.

1. Login to ibmcloud cli  
   `ibmcloud login --sso -c 800fae7a41e7d4a1ec1658cc0892d233`
1. Target bots cluster  
   `ibmcloud ks cluster config --cluster bots`
1. Check if alchemy-dashboard pod is running  
   `kubectl get pods -n dashboard -o wide`
1. If alchemy-dashboard pod is not running `10/10` check troubling container  
   `kubectl describe pod -n dashboard <pod>`
1. Check troubling pod logs  
   `kubectl -n dashboard logs <pod> -c <container>`
1. Restart the pod  
   `kubectl -n dashboard delete pod <pod>`

## Escalation Policy

Contact conductors in [#conductors](https://ibm-argonauts.slack.com/messages/C54H08JSK) slack channel
