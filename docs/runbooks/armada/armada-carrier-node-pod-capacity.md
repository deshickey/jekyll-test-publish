---
layout: default
description: How to handle a worker node that is reaching pod capacity
title: armada-carrier - How to handle a worker node that is reaching pod capacity
service: armada
runbook-name: "armada-carrier - How to handle a worker node that is reaching pod capacity"
tags: armada, node, down, troubled, worker, az, availability zone, pod, capacity
link: /armada/armada-carrier-node-pod-capacity.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to deal with alerts reporting node has reached pod capacity.  


| Alert_Situation                                                                                                          | Info                                                                    | Start |
|--------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------| ----- |
| `ZoneIsReachingMaxPodCapacityOver70` or `ZoneIsReachingMaxPodCapacityOver70HyperShift`                                   | Zone is over 70 percent pod capacity (or HyperShift)                    | [Zone is reaching capacity](#zone-is-reaching-capacity) |
| `ZoneIsReachingMaxPodCapacityOver80` or `ZoneIsReachingMaxPodCapacityOver80HyperShift`                                   | Zone is over 80 percent pod capacity (or HyperShift)                    | [Zone is reaching capacity](#zone-is-reaching-capacity) |
| `TotalAvailableCustomerMasterCPUThresholdBreached` or `TotalAvailableCustomerHyperShiftMasterCPUThresholdBreached`       | Threshold for available Customer (or Hypershift) Master CPU breached    | [Customer Master Resource Threshold Breached](#customer-master-resource-threshold-breached) |
| `TotalAvailableCustomerMasterMemoryThresholdBreached` or `TotalAvailableCustomerHyperShiftMasterMemoryThresholdBreached` | Threshold for available Customer (or HyperShift) Master Memory breached | [Customer Master Resource Threshold Breached](#customer-master-resource-threshold-breached) |
| `NodeIsReachingMaxPodCapacityOver70` or `NodeIsReachingMaxPodCapacityOver70HyperShift`                                   | Node is over 70 percent pod capacity (or HyperShift)                    | [Node is reaching capacity](#node-is-reaching-capacity) |
| `NodeIsReachingMaxPodCapacityOver80` or `NodeIsReachingMaxPodCapacityOver80HyperShift`                                   | Node is over 80 percent pod capacity (or HyperShift)                    | [Node is reaching capacity](#node-is-reaching-capacity) |

### Zone is reaching capacity

#### Example alert(s)
                  
~~~~
Labels:
  - severity = "critical",
  - service = "armada-infra",
  - availability_zone = "dal12"
  - percentage = "85"
  - alert_situation = "az_dal12_has_zone_reaching_capacity_over_80"
Annotations:
  - summary = "Zone dal12 has pod capacity over 80 percent",
  - description = "Zone dal12 has pod capacity over 80 percent"
~~~~

#### Actions to take 

1. Go to prometheus and check if the issue is caused by incorrect label on nodes. More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)

1. Run the following query:
    
    For alert without `HyperShift` in the name:
    ~~~~
    avg by(label_failure_domain_beta_kubernetes_io_zone) (armada_infra:percent_usage_of_running_pods_on_node * 100)
    ~~~~
   
    For alert with `HyperShift` in the name:
    ~~~~
    avg by(label_failure_domain_beta_kubernetes_io_zone) (armada_infra:percent_usage_of_running_pods_on_node_hypershift * 100)
    ~~~~
   
    If there are more than 3 zones in the query result as below, the issue is caused by incorrect label on nodes.

    ~~~~
    {label_failure_domain_beta_kubernetes_io_zone="mil01"}	  26.613729508196712
    {label_failure_domain_beta_kubernetes_io_zone="mil01a"}	  99.58333333333333
    {label_failure_domain_beta_kubernetes_io_zone="mil01b"}	  96.25
    {label_failure_domain_beta_kubernetes_io_zone="mil01c"}	  87.91666666666667
    ~~~~

    This issue usually happens on tugboat, if it happens on legacy carrier, [escalate and work with devs to resolve issue](#escalation-policy). _Tugboats are carriers numbered 100 or greater while legacy carriers are numbered between 0 and 99._

    For tugboat, there should be 3 failure_domain_beta_kubernetes_io_zone named `<dcName>a`, `<dcName>b` and `<dcName>c`, `mil01` is the dcName in above example. If you see the fourth zone named `<dcName>`, we need to fix these nodes with incorrect label, go to [Correct node label](#correct-node-label), otherwise, go to [Scale up carrier](#scale-up-carrier)

#### Correct node label

1. Run the following query in prometheus to get the node list

    For alert without `HyperShift` in the name:
    ~~~~
    armada_infra:percent_usage_of_running_pods_on_node {label_failure_domain_beta_kubernetes_io_zone="<dcName>"}
    ~~~~

    For alert with `HyperShift` in the name:
    ~~~~
    armada_infra:percent_usage_of_running_pods_on_node_hypershift {label_failure_domain_beta_kubernetes_io_zone="<dcName>"}
    ~~~~

    Sample:

    ~~~~
    armada_infra:percent_usage_of_running_pods_on_node {label_failure_domain_beta_kubernetes_io_zone="mil01"}
    ~~~~

    Query result example:

    ~~~~
    armada_infra:percent_usage_of_running_pods_on_node{label_failure_domain_beta_kubernetes_io_zone="mil01",node="10.144.223.130"}	  0.2125
    armada_infra:percent_usage_of_running_pods_on_node{label_failure_domain_beta_kubernetes_io_zone="mil01",node="10.144.223.131"}	  0.23125
    armada_infra:percent_usage_of_running_pods_on_node{label_failure_domain_beta_kubernetes_io_zone="mil01",node="10.144.223.132"}	  0.2375
    ~~~~

1. For each node in the list, do the following:

  * query the worker name by IP using [netmax](https://ibm-argonauts.slack.com/archives/D5MNLN3PH)

    ~~~~
    chendil  10:17 AM
    10.144.223.143

    netmaxAPP  10:18 AM
    @chendil:
    kube-bqotlsff0ll55rhse4g0-prodeucentr-custome-00006c90 (Virtual Server) - Milan 1:01 - Acct531277
    Public: 169.51.202.168 169.51.202.128/26 (Prod/Tugboat109) (756 (fcr01a.mil01))
    Private: 10.144.223.143 10.144.223.128/25 (Prod/Tugboat109) (1106 (bcr01a.mil01))
    OS: REDHAT_7_64
    Tags: ibm-kubernetes-service
    ~~~~

  * query the correct label by worker name using [#armada-xo](https://ibm-argonauts.slack.com/archives/G53AJ95TP)

    ~~~~
    @xo worker kube-bqotlsff0ll55rhse4g0-prodeucentr-custome-00006c90 show=all
    ~~~~

    Check the DesiredLabels in the return message. In the following sample, `mil01a` should be the correct label set on the node, instead of `mil01`.
    ~~~~
     "DesiredLabels": "{\"failure-domain.beta.kubernetes.io/zone\":\"mil01a\",\"ibm-cloud.kubernetes.io/node-local-dns-enabled\":\"true\",\"ibm-cloud.kubernetes.io/worker-pool-id\":\"bqotlsff0ll55rhse4g0-067c780\"}",
    ~~~~

  * log in the tugboat, run the following commands to correct the label. [How to access tugboats](./armada-tugboats.html#access-the-tugboats).

    ~~~~bash
    kubectl label node <nodeIP> failure-domain.beta.kubernetes.io/zone=<desired-label> --overwrite
    kubectl label node <nodeIP> ibm-cloud.kubernetes.io/zone=<desired-label> --overwrite
    ~~~~

    Sample:

    ~~~~bash
    kubectl label node 10.144.223.143 failure-domain.beta.kubernetes.io/zone=mil01a --overwrite
    kubectl label node 10.144.223.143 ibm-cloud.kubernetes.io/zone=mil01a --overwrite
    ~~~~

3. Run the following query in prometheus again, you should see 3 zones and their value should be lower than 80. If the value of all the 3 zones are larger than or close to 80, consider to [Scale up carrier](#scale-up-carrier), otherwise, consider to balance workload between nodes, e.g. move pods from busy node to free node.

    For alert without `HyperShift` in the name:
    ~~~~
    avg by(label_failure_domain_beta_kubernetes_io_zone) (armada_infra:percent_usage_of_running_pods_on_node * 100)
    ~~~~

    For alert with `HyperShift` in the name:
    ~~~~
    avg by(label_failure_domain_beta_kubernetes_io_zone) (armada_infra:percent_usage_of_running_pods_on_node_hypershift * 100)
    ~~~~

4. [Escalate and work with devs](#escalation-policy) if the issue persists after trying the resolution above.

#### Scale up carrier

1. The carrier/tugboat in the alert needs to be scaled up as if we reach 100% new deploys/upgrades will fail in that region.  
_Tugboats are carriers numbered 100 or greater while legacy carriers are numbered between 0 and 99._
   - [Scale up a Carrier](../armada/armada-scale-carrier-up.html)
   - [Scale up a Tugboat](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/master/docs/runbooks/armada/scaling-tugboat-worker-pool.md)
1. If unable to scale up we will need to work with the Devs to find a solution to help alleviate capacity.  
[Escalate and work with devs to resolve issue](#escalation-policy)
1. Once workers are added the alert should resolve as long as the average load goes below 70% in that zone. If not we may need more workers added. 

### Customer Master Resource Threshold Breached

#### Example alert(s)
                  
~~~~
Labels:
  - severity = "critical",
  - service = "armada-infra",
  - alert_key: armada-infra/customer_master_mem_request_breached
  - alert_situation: armada-infra/customer_master_mem_request_breached
Annotations:
  - description: The carrier or tugboat has less than 96 GB of RAM available for scheduling customer masters in a zone across all zones. All zones need to be scaled to support more workload. Please scale the customer workload workerpool by at least 5 nodes in each zone.
  - summary: The carrier or tugboat has less than 96 GB of RAM available for scheduling customer masters in a zone across all zones. All zones need to be scaled to support more workload. Please scale the customer workload workerpool by at least 5 nodes in each zone.
~~~~

#### Actions to take 

1. The carrier/tugboat in the alert needs to be scaled up. If we reach 100%, then new deploys/upgrades will fail in that region. 
  - The description will say what worker-pool to scale up `Please scale the <workerpool> workerpool by at least 5 nodes in each zone.` It will either be `hypershift` or `customer-workload` 
1. Follow [this runbook](../armada/armada-scale-carrier-up.html) to scale up a carrier. Follow [this page](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/README.md#scaling-the-worker-pool) to scale up a tugboat. Tugboats are numbered 100 or greater while legacy carriers are numbered between 0 and 99. 
1. If unable to scale up we will need to work with the Devs to find a solution to help alleviate capacity. [Escalate and work with devs to resolve issue](#escalation-policy)
1. Once workers are added the alert should resolve as long as the pool of available CPU and MEM go above the threshold. If not we may need more workers added. 


### Node is reaching capacity

#### Example alert(s)
                  
~~~~
Labels:
  - severity = "critical",
  - service = "armada-infra",
  - availability_zone = "dal12"
  - node = "10.123.123.123"
  - percentage = "85"
  - alert_situation = "az_dal12_has_node_10.123.123.123_reaching_capacity_over_80"
Annotations:
  - summary = "Node 10.123.123.123 reaching pod capacity in zone dal12 over 80 percent",
  - description = "Node 10.123.123.123 reaching pod capacity in zone dal12 over 80 percent"
~~~~

#### Actions to take 

1. Check similar PagerDuty Alerts, if there are multiple nodes reporting pod capacity in a specific `availability zone`, [escalate immediately](#escalation-policy)
1. Cordon the node in question to prevent more load from being scheduled to it
   ~~~~
   armada-cordon-node --reason "Node is reaching pod capacity" <node>
   ~~~~
1. Create an issue against [conductors team issue](https://github.ibm.com/alchemy-conductors/team/issues), include the alert and any additional information
1. Check the tugboat scaling runbook mentioned here for further reference [tugboat scaling](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/scaling-tugboat-worker-pool.html).
1. Once issue is created ping `@interrupt` in [{{ site.data.teams.containers-sre.comm.name }}]({{ site.data.teams.containers-sre.comm.link }}). The team can look at it during their working hours as long as there are not multiple nodes reporting node capacity issues in a specific `availability zone`.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.containers-sre.escalate.name }}]({{ site.data.teams.containers-sre.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.containers-sre.comm.name }}]({{ site.data.teams.containers-sre.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.containers-sre.name }}]({{ site.data.teams.containers-sre.issue }}) Github repository for later follow-up.
