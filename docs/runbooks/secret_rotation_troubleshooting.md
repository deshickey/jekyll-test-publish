---
layout: default
description: How to troubleshoot secret rotation automation
service: "Conductors"
title: Troubleshooting secret rotation automation
runbook-name: Troubleshoot secret rotation automation
link: /secret_rotation_troubleshoot.html
type: Informational
failure: ["Runbook needs to be updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook explains how to troubleshoot failures in secret rotation that is triggered by automation.

## Detailed Information

Secret rotation automation might fail for many reasons. It's important to verify all the steps starting from the GHE Watcher which generates the metadata used by the JJ for the actual executation of the rotation. 

### Secret-rotation GHE Watcher issue investigation and action

GHE Watcher is hosted on bots (`d34580e8ca3a47939515766ff7d9d515`) cluster in `278445 - Alchemy Support` account.

In case the JJ is not triggered, it means that the GHE watcher is having issues generating the metadata file which might be due to a typo in the original issue or missing API Key. You can retrigger the GHE watcher by adding the `ready-to-rotate` label to the issue and trace the logs as below:

1. Login to ibmcloud cli  
   `ibmcloud login --sso -c 800fae7a41e7d4a1ec1658cc0892d233`
2. Target bots cluster  
   `ibmcloud ks cluster config --cluster bots`
3. Check if ghe-watcher pod is running  
   `kubectl get pods -n dashboard -o wide`
4. If ghe-watcher pod is not running check troubling container  
   `kubectl describe pod -n dashboard <pod>`
5. Check troubling pod logs
   `kubectl -n dashboard logs <pod> -c ghe-watcher`
6. Restart the pod
   `kubectl -n dashboard delete pod <pod>`

### Secret-rotation Jenkins Job investigation and action

Sometimes JJ might also fail due to many reasons e.g. wrong destination provided in the request, insufficient access to the IBM Cloud account or rotation destination. The JJ build logs will be the best place to find out more about the root cause of the issue. The JJ will post the link of actual job being executed along with the result of job. You can find an example [here](https://github.ibm.com/alchemy-containers/secret-rotate-metadata/issues/278)

## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors` (For users outside the SRE squad) or in `#conductors-for-life` or `#sre-cfs` if you have access to these private channels.

There is no formal call out process for this issue.
