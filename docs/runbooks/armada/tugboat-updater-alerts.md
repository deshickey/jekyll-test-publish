---
layout: default
description: How to resolve tugboat-updater alerts
title: tugboat-updater-alerts
service: armada
runbook-name: "tugboat-updater-alerts"
tags:  armada, tugboat-updater
link: /armada/tugboat-updater-alerts.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|---|---|---|
| `TugboatUpdatesFailing`| There are tugboat update failures with no success following for 6h | [Actions-to-take](#actions-to-take) |

More details on how the service operates can be viewed [here](./tugboat-updater-details.html)
## Example Alert(s)

[staging.containers-kubernetes.dev-dal10-carrier101.10.95.133.196_tugboat-updater_tugboat-updates-failing.us-south](https://ibm.pagerduty.com/incidents/Q35JLBBSZUHS7B)
~~~~
NodeIP = 10.95.133.196
Runbook = https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/tugboat-updater-alerts.html
Summary = There are tugboat update failures with no success following for 6h
Source: https://alchemy-dashboard.containers.cloud.ibm.com/dev-dal10/carrier101/prometheus/graph?g0.expr=sum+by%28nodeIP%2C+updateStep%29+%28tugboat_updater_update_failures%29+%2F+2+%3E+0&g0.tab=1
~~~~

## Investigation and Action

### Actions to take

A lot of times these alerts indicate that there is a problem with the underlying VSI/BM. This is always a good first thing to check.
1. find the node ip in the alert or by using this query in prometheus `sum by (nodeIP,updateStep)(tugboat_updater_update_failures)/2 > 0`. This query will show the number of times each node has failed on each step since the last success. Note: we divide by 2 because the alerts are counted twice. See [here](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/issues/626) for more details
1. If the failed step in the above query is `drainNode`, continue to [failed to drain node](#failed-to-drain-node)
1. Get the workerID from `@netmax $nodeIP`
1. Go to #xo-secure and type `@xo worker $workerID`
1. Review `ActualState`, `Status`, and `ErrorMessage`
1. If any of the above indicate an IaaS issue, continue to [IaaS related reload failure](#iaas-related-reload-failure)
1. Else if any of the fields indicate firewall issues such as, `Worker unable to talk to IKS servers. Please verify your firewall setup is allowing traffic from this worker`, continue to [firewall related reload failure](#firewall-related-reload-failure)
1. Else continue to [escalation policy](#escalation-policy)

### Failed to Drain Node
1. Navigate to [IBM CLoud Logs](https://cloud.ibm.com/observability/logging) then click on the `Cloud Logs' tab.  Select the Instance for the region and click on `Open Dashboard`.
1. select all tugboat-updater instances from the sources drop down
1. search for the IP of the failed worker
1. In the logs you should see the failed drain cmd along with likely an unhealthy etcd instance that is blocking the drain.
1. Follow steps [here](./armada-cluster-etcd-unhealthy.html) to recover the etcd that is blocking the drain

### IaaS Related Reload Failure

1. If a worker reload has been stuck on `Waiting for IBM Cloud infrastructure` for a long time, a ticket must be raised with IaaS to find the cause of the delay.
1. If the error message starts with something like `infrastructure exception` (e.g. `IBM Cloud infrastructure exception: Unable to reload operating system at this time. Please try again later.`)
    * This means that the cluster has received an error from IaaS. The machine will keep retrying to reload the machine until the message is marked as failed.
    * In order to find out more details from IaaS, raise a ticket with IaaS including the hostname details and the error message.
1. Once Resolved go to [resolution](#resolution)

### Firewall Related Reload Failure

#### Option 1 (preferred)

Use this option if there is not an immediate need to have the server back online, and the environment is capable of functioning for several hours or days without the worker(s).

1. Raise the following support ticket in the appropriate account:

```
Topic: Virtual Server for Classic OR Bare Metal Servers for Classic
Subtopic: Connectivity - Public
Title: [VSI|BM] has lost all public internet access
Description: Please send this ticket to Mark Price and team. Do not do anything to this machine until Mark Price has taken a look at it. This is to assist with the ongoing investigation related to https://internal-ibmcloud.ideas.aha.io/ideas/IDEAINT-I-6442.

I am raising this ticket on behalf of the IKS team. The following worker is unable to talk to IKS servers. This is a previously deployed worker on a previous configured subnet and the firewall rules have not changed. We have never had a regression in firewall rules. I suspect this machine has lost all public connectivity and cannot even ping its default gateway.

<<PASTE SERVER DETAILS HERE>>
```
Severity: sev 2. Use template in [Option 2](#option-2-emergency-migration) if this is a sev 1 issue

1. Ping Mark Price (@pricema) in #iks-iaas-public-network-investigation with the ticket number and request that he take a look. If possible, also provide an estimate of how long the machine can remain offline - patching deadlines are the primary concern here.

1. Once Resolved go to [resolution](#resolution)

#### Option 2 (emergency migration)

1. Raise the following support ticket in the appropriate account:
```
Topic: Virtual Server for Classic OR Bare Metal Servers for Classic
Subtopic: Connectivity - Public
Title: [VSI|BM] has lost all public internet access
Description: I am raising this ticket on behalf of the IKS team. The following worker is unable to talk to IKS servers. This is a previously deployed worker on a previous configured subnet and the firewall rules have not changed. We have never had a regression in firewall rules. I suspect this machine has lost all public connectivity and cannot even ping its default gateway. Please migrate this machine to a new hypervisor.

Previous related tickets: CS2435926 CS2399148 CS2324451 CS2439511 CS2675224 CS2749899 CS2743648 CS2783701 CS2893937 CS2927048 CS2950044 CS2968174 CS3002484 CS2970596

Please note that if the workers are on multiple hypervisors, the symptoms still indicate a problem with the hypervisors, and all will need to be migrated, as seen in CS2893937 CS2949592 CS3066275

Please also know that if the VSIs are migrated to another bad hypervisor, another migration will be requested, as seen in CS2951331

<<PASTE SERVER DETAILS HERE>>
```

Severity: sev 1. Only raise this ticket if we are close to missing a patching deadline, or several machines are down affecting, or potentially affecting, the stability of the tugboat. Otherwise, use template in [Option 1](#option-1-preferred) Use your best judgement.

1. Once Resolved go to [resolution](#resolution)

1. Bonus points: add resolved ticket to the appropriate list above. Ultimately, IaaS should not be providing 'provisioned' hosts without first checking public network connectivity. Feature request here: https://internal-ibmcloud.ideas.aha.io/ideas/IDEAINT-I-6442

## Resolution

1. Do not resolve the alert. If the underlying issue has been corrected, the tugboat-updater will reset the metrics that triggered the alert on the next operation success, which will allow the alert to autoresolve.

## Escalation Policy
This automation is owned by the SRE. If there is no issue with the underlying machine that triggered the alert, and the problem is believed to be with the tugboat-updater itself, please snooze alert and escalate to the US squad during normal working hours.
