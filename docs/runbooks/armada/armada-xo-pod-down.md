---
layout: default
title: "Armada Xo pod is down"
description: "The Armada Xo pod is down"
type: Alert
runbook-name: "Armada Xo pod is down"
service: armada-ballast
tags: armada-xo, armada-ballast
link: /armada/armada-xo-pod-down.html
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

The Armada Xo pod is down.
The Armada Xo pod is responsible for responding to commands in the Xo Slack channels.

## Example Alerts

~~~text
Labels:
 - alertname = armada_xo_restarting
 - alert_situation = "armada_xo_restarting"
 - service = armada-ballast
 - severity = warning
 - namespace = armada
Annotations:
 - summary = "Armada Xo pod is restarting."
 - description = "Armada Xo pod has restarted more than 3 times in the past 15 minutes"
~~~

~~~text
Labels:
 - alertname = armada_xo_cos_push_errors
 - alert_situation = "armada_xo_cos_push_errors"
 - service = armada-xo
 - severity = warning
 - namespace = armada
Annotations:
 - summary = "Armada XO COS push errors."
 - description = "The rate of armada Xo cos push errors has errored more than once in the past 5 minutes"
~~~

## Automation

None

## Actions to take

1. Find and login into the carrier master having issues.  Identification differs depending on whether a tugboat is involved. Look at the `carrier_name` field in the alert.
   - If the `...-carrier` number is 100 or great then log onto the hub in the region
_More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_
   - Else, logon to the `...-carrierX-master-xx`
   _e.g. `prod-ams03-carrier1-master-03`_

1. Determine the state of the pod

   ~~~sh
   kubectl get pod -n armada -l app=armada-xo -o wide
   ~~~

   Should be a single pod running.

1. Can try to delete the pod to see if it comes back up

   ~~~sh
   kubectl delete pod -n armada -l app=armada-xo
   ~~~

    if stays running for 15 minutes, PD will resolve automatically.

1. If pod is stuck in state `Unknown` the Kubernetes Worker Node may be in a bad state
_usually charactarized by the inability to run any action against the pod_
   - Follow [runbook to debug troubled node](./armada-carrier-node-troubled.html#debugging-the-troubled-node)

1. If none of the above steps resulted in a running cluster-health pod
   - Escalate [escalation policy](#escalation-policy).

## Armada Xo Cos Push Error

  The Armada Xo service queries ETCD periodically and creates SQL tables with the field information.

  There are Xo SQL commands that can then query the tables. The SQL database is backed up to COS. The backup will retry if failures. If all retries fail, this error metric is incremented.

  The COS credentials, bucket, endpoint and location are stored in Armada-Secure repo:

- COS Bucket: <https://github.ibm.com/alchemy-containers/armada-secure/search?q=COS_ANALYTICS_BUCKET>
- COS Endpoint: <https://github.ibm.com/alchemy-containers/armada-secure/search?q=COS_ANALYTICS_ENDPOINT>
- COS Location <https://github.ibm.com/alchemy-containers/armada-secure/search?q=COS_ANALYTICS_LOCATION>
- COS Creds <https://github.ibm.com/alchemy-containers/armada-secure/search?q=COS_ACCESS_KEY_ID>

1. Check IBM Cloud Logs in the region for the error message using `app:armada-xo` and `query: "COS PutObject Error"`.
   If the error is related to COS bucket or location, need to verify those exist and have proper access.
   If the error is related to COS credentials, need to verify the Key and Secret or have them rotated.

2. Check network stability to ensure that the COS endpoint is reachable from armada-xo pod.
   The COS Endpoint listed for this region should be tested for proper network access from the microservice tugboat and even from the XO pod.

3. Restart the XO pod and wait for 1 hour to see if the alert and log message clears.

4. Escalate to Ballast squad using the slack channel ({{ site.data.teams.armada-ballast.comm.link }}) during business hours.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-ballast.comm.name }}]({{ site.data.teams.armada-ballast.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-ballast.name }}]({{ site.data.teams.armada-ballast.issue }}) Github repository for later follow-up.
