---
layout: default
description: How to handle a high percentage of high availability cluster masters not in ready state.
title: armada-deploy - How to handle a high percentage of high availability cluster masters not in ready state.
service: armada-carrier
runbook-name: "armada-carrier - How to handle a high percentage of high availability cluster masters not in ready state."
tags: alchemy, armada-carrier, cruiser, master, high availability
link: /armada/armada-deploy-high-percentage-high-availability-cluster-master-critical.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to handle alerts which report a high percentage of high availability cluster master deployment which have hit critical levels, less than 2 replicas available.
kubx-masters are the master node for a customers cruiser.  They run as 3 pods in the kubx-masters namespace and will be located on a carrier-worker host spread across 3 Availablity Zones

## Example Alerts

~~~~
Labels:
  - severity = "critical",
  - service = "armada-deploy",
  - environment = "#ENVIRONMENT#",
  - alert_situation = "high_percentage_cruiser_master_deployments_no_replicas_available"
Annotations:
  - summary = "pCIE situation - over 1% AND over 50 high availability cluster master pods reporting critical state",
  - description = "There are {% raw %}{{ $value }}{% endraw %}% and over 50 high availability master pods reporting critical state - this is over our thresholds and a pCIE should be raised.",
~~~~

~~~~
Labels:
  - severity = "warning",
  - service = "armada-ops",
  - environment = "#ENVIRONMENT#",
  - alert_situation = "high_percentage_high_availability_master_in_unhealthy_state"
Annotations:
 - summary = "Over ~~SUB:"HighPercentageMasterInUnhealthyState%"~~% AND over ~~SUB:"HighPercentageMasterInUnhealthyCOUNT"~~ High Availability master pods are in unhealthy state",
~~~~

## Investigation and Action

### Understanding the impact

If, in a production environment, any of the alerts above are triggering, then a [pCIE may be required](#discussions-to-have-in-the-cie-channel).

When this alert triggers, we have to monitor the situation in more detail as kubernetes may well be working to resolve the issue automatically.

### Review other alerts at this time

This alert usually triggers when a carrier-worker node has gone into a `Not Ready` state and the cruiser-master deployments on that worker node are being re-scheduled onto other worker node(s).

Look for other alerts triggering at the same time as this alert which may hold a clue as to what has occurred to cause this alert to trigger.

- Node or service `scrape failures`
- `bluemix.containers-kubernetes.prod-dal10-carrier1.az_{% raw %}{{ $labels.label_failure_domain_beta_kubernetes_io_zone }}{% endraw %}_has_multiple_node_status_ready_false.us-south`
- `bluemix.containers-kubernetes.prod-dal10-carrier1.{% raw %}{{ $labels.node }}{% endraw %}_in_az_{% raw %}{{ $labels.label_failure_domain_beta_kubernetes_io_zone }}{% endraw %}_has_node_status_ready_false.us-south`

When a node enters a `Not Ready` state, kubernetes reschedules the cruiser-master deployment PODs on other worker nodes. Follow the runbooks for the [node not ready](armada-carrier-node-troubled.html) to resolve issues there

### Discussions to have in the cie channel

First, start a discussion in the `#containers-cie` channel stating this alert has triggered and investigation is under way.


Key information we are after to understand if this is a CIE is. We can use prometheus for that carrier queries to figure out this information.
More info on how to find prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)

- The percentage of high availability cluster masters unavailable and unhealthy
  ~~~~
  (count(armada_master{desired_or_actual="actual",state="deployed",master_health=~"error|unavailable"} and on (deployment) kube_deployment_status_replicas_available{namespace="kubx-masters",deployment=~"master-.*"} == 3 and on (deployment) kube_deployment_status_replicas{namespace="kubx-masters",deployment=~"master-.*"} <  2 or count(kube_deployment_status_replicas_available{namespace="kubx-masters",deployment=~"master-.*"} == 2 and kube_deployment_status_replicas{deployment=~"master-.*", namespace="kubx-masters"} == 3)) / count(kube_deployment_status_replicas{deployment=~"master-.*", namespace="kubx-masters"} == 3)) * 100
  ~~~~
- The number of high availability clusters masters unavailable or unhealthy
  ~~~~
  count(armada_master{desired_or_actual="actual",state="deployed",master_health=~"error|unavailable"} and on (deployment) kube_deployment_status_replicas_available{namespace="kubx-masters",deployment=~"master-.*"} == 3 and on (deployment) kube_deployment_status_replicas{namespace="kubx-masters",deployment=~"master-.*"} <  2 or count(kube_deployment_status_replicas_available{namespace="kubx-masters",deployment=~"master-.*"} == 2 and kube_deployment_status_replicas{deployment=~"master-.*", namespace="kubx-masters"} == 3))
  ~~~~
- The trend of these figures - are they increasing or decreasing and what is the rate of the increase/decrease.
  - Look at the above two queries and hit the `Graph` section

If the numbers have plateaued above 1% and over 50 high availability cluster masters are affected, or the numbers are increasing then invoke the CIE process.  The pCIE process is [documented here](../clm-incidents.html) - CIEs are not required for staging environments.

If the numbers are decreasing then discuss further in the CIE channel as a CIE may not be required.  Try and work out the rate of decrease and how long it is estimated to be until the figures reach under 50 high availability cluster masters being unavailable.

### Actions to take

If the number of high availability cluster masters not in ready state is not reducing, follow the steps in [high availability cluster masters not in ready state](armada-ha-cruiser-patrol-master.html) runbook.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
