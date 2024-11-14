---
layout: default
description: General troubleshooting tips for etcd within Armada
title: armada-etcd - General Troubleshooting
service: armada-etcd
runbook-name: "armada-etcd - general troubleshooting"
tags: alchemy, armada, etcd, armada-etcd
link: /armada/armada-etcd-general-troubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains some useful methods for troubleshooting etcd within Armada.

## Example Alerts

None

## Investigation and Action

The following sections will assist with troubleshooting etcd

## Finding a running etcd

Finding the instance of etcd you want to look at will vary depending upon it's type:

| Type | Description | Count |
|-----:|:------------|:------|
| armada-etcd  | Used by armada services to communicate and store state | 1 per carrier |
| carrier-etcd | Used by carrier Kubernetes to store state              | 1 per carrier |
| cruiser-etcd | Used by cruiser Kubernetes to store state              | 1 per cruiser, many per carrier |

### Armada-etcd

**Armada-etcd** instances are run as etcd-operator clusters (5 pods per cluster) in one tugboat per region. The tugboats are:

| Region | Tugboat Name | Tugboat Cluster ID | Prometheus Alerts |
| ------ | ------------ | ------------------ | ----------------- |
| ap-north   | prod-tok02-carrier105 | bn0733jt0p3fgejujklg | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-tok02/carrier105/prometheus/alerts)
| ap-south   | prod-syd01-carrier102 | bn072ggs072s3ea1mhi0 | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-syd01/carrier102/prometheus/alerts)
| br-sao   | prod-sao01-carrier102 | c2879vlz0ncvtu3gisog | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-sao01/carrier102/prometheus/alerts)
| ca-tor   | prod-tor01-carrier102 | c07lvumr0h1vglsr9250 | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-tor01/carrier102/prometheus/alerts)
| eu-central | prod-fra02-carrier105 | bn071nff0eb05td6lpig | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/carrier105/prometheus/alerts)
| eu-es | prod-mad02-carrier100 | bn071nff0eb05td6lpig | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-mad02/carrier100/prometheus/alerts)
| eu-fr2   | prodfr2-par04-carrier100 | bs4hlktb0tnpmsfuravg | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prodfr2-par04/carrier100/prometheus/alerts)
| jp-osa   | prod-osa21-carrier100 | bug6qunt0schhqhd2ep0 | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-osa21/carrier100/prometheus/alerts)
| uk-south   | prod-lon04-carrier101 | bn08oj3l01cgaq3g8jtg | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon04/carrier101/prometheus/alerts)
| us-east    | prod-wdc04-carrier103 | bn072ecw0iumlund3g60 | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-wdc04/carrier103/prometheus/alerts)
| us-south   | prod-dal10-carrier105 | bn08l8td0bfjd8d8kqkg | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier105/prometheus/alerts)
| stage   | stage-dal10-carrier103 | bmmq687d05d0dcs3d4q0 | [link](https://alchemy-dashboard.containers.cloud.ibm.com/stage-dal10/carrier103/prometheus/alerts)
| prestage   | prestage-dal10-carrier101 | bmjn7o1d0b8f993oo7hg | [link](https://alchemy-dashboard.containers.cloud.ibm.com/prestage-dal10/carrier101/prometheus/alerts)
| dev   | dev-dal10-carrier104 | bm2170gd060v5sou9f30 | [link](https://alchemy-dashboard.containers.cloud.ibm.com/dev-dal10/carrier104/prometheus/alerts)

To access some basic stats/metrics about the load on an etcd cluster, you should use the `Carrier Etcd` or `Microservice Etcd Metrics` Grafana dashboards for either of the hub carriers in the region. This can give you a broad view of the state of the etcd cluster.

The [Get Etcd Information job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-info/) can be run against the region
having issue.  Each section in the log contains annotations for what to look for.

Steps to take for the `CriticalArmadaDataEtcdErrorCount` alert:
- Review the `Microservice Etcd Metrics V2` Grafana dashboard for the armada etcd tugboat in the region. Check the `Etcd Data Errors by Service` for similar behavior.
- Review the  `Carrier Etcd` Grafana dashboard for the armada etcd tugboat in the region. Check for networking errors using the `RTT` and `Grpc` views. The [armada-etcd-info job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-info/) can help with determining pod and node health status.

Additionally, you should check for the following alerts in the prometheus instance for the region's etcd tugboat (see links above):
- `ArmadaEtcdClusterBrokeQuorum`
- `ArmadaEtcdClusterUnhealth`
If so, jump to [this runbook](./armada-etcd-unhealthy.html).

If neither of those alerts are present or if the prescribed steps in the provided runbook don't resolve the issue, escalate to the `armada-etcd` policy.

### Cruiser-etcd

Cruiser-etcd instances are run in a container as part of the master pod for a cruiser. To find the relevant master you will need the cluster id of the cruiser you are investigating. In the [#armada-xo channel](https://ibm-argonauts.slack.com/messages/G53AJ95TP) on Slack enter the following to find the relevant master location and ID:

~~~~~text
@xo cluster <cluster-id>
~~~~~

This should produce output similar to the following:

~~~~~text
              ClusterID: bnru95420i9lipjnek90
                   Name: pvg-93047-stage-classic-k8s-1.14
...
             Datacenter: mex01
ActualDatacenterCluster: stage-dal09.carrier0
...
~~~~~

The values for `Datacenter` and `ActualDatacenterCluster` let you know which carrier master you will need to ssh into in order to find the master pod for that cruiser. Once you have this information you can follow this process to find the etcd container for the cruiser you are investigating:

1. Log into the master for the carrier you are interested in

2. Find the master pod for the cruiser by running the following with the correct `<cluster-id>`:

   ~~~~~text
   kubectl -n kubx-masters get pods | grep <cluster-id>
   ~~~~~

   The output should look like this:

   ~~~~~text
   > kubectl -n kubx-masters get pods | grep c16c798fa4e9411caab16c14a2c85f1a
   master-c16c798fa4e9411caab16c14a2c85f1a-2351323345-1nk81   5/5       Running             0          6d
   ~~~~~

3. Within the master pod the etcd instance is running within the `etcd` container. You will need to specify this when running any `kubectl exec` commands. For example:

   ~~~~~text
   kubectl exec -it -n kubx-masters master-c16c798fa4e9411caab16c14a2c85f1a-2351323345-1nk81 -c etcd sh
   ~~~~~

   For cruiser-etcd any instances of `<pod-name>` in the entries below will need to be replaced by `<pod-name> -c etcd` as in the example above.

### Carrier-etcd: (TBD)

## Identifying an etcd instance

Sometimes it may be useful to know the name of an etcd instance running within a pod. e.g. to tie up etcdctl output with output from pods

To do this you can look at the start of the logs for a pod by executing the following:

~~~~~text
kubectl get logs -n <namespace> <pod-name> --limit-bytes 4096
~~~~~

This will get you the first 4096 bytes in the logs. Etcd outputs a lot of useful information when the process is started so viewing the start of the logs can be useful for various reasons. Obviously if 4096 bytes isn't enough to see everything you need just increase the number.

To find the name of the etcd member node find the line similar to this:

~~~~~text
2017-04-18 14:09:21.522947 I | etcdserver: name = armada-etcd-0
~~~~~

This pod for example is running node `armada-etcd-0`.

## Checking the etcd cluster health

One thing you can use to get the etcd clusters view of its own health is to ask it for the cluster health using etcdctl. You can use the etcdctl instance installed in the docker image running the pods to save you having to install it and run the following:

~~~~~text
kubectl exec -n <namespace> <pod-name> --- etcdctl cluster-health
~~~~~

**NOTE:** namespace and pod-name will vary depending on which etcd instance you are trying to troubleshoot.

Example output for a healthy single-node armada-etcd instance:

~~~~~text
garethbottomley@prod-dal10-carrier1-master-01:~$ kubectl exec -n armada armada-etcd-2063829098-vrdqc -- etcdctl cluster-health
member 7512f03a40a1bfab is healthy: got healthy result from http://armada-etcd:2379
cluster is healthy
~~~~~

Example output for an unhealthy single-node armada-etcd instance:

~~~~~text
garethbottomley@prod-dal10-carrier1-master-01:~$ kubectl exec -n armada armada-etcd-2063829098-vrdqc -- etcdctl cluster-health
cluster may be unhealthy: failed to list members
Error:  client: etcd cluster is unavailable or misconfigured; error #0: dial tcp armada-etcd:4001: getsockopt: connection refused
; error #1: dial tcp armada-etcd:2379: getsockopt: connection refused
~~~~~

**NOTE:** It may not be possible to exec the etcdctl command if the pod for the etcd instance is in an unhealthy state. This in itself however tells you a significant amount about the health, or lack of, of the etcd instance.

Example output for a healthy multi-node etcd instance:

~~~~~TEXT
garethbottomley@dev-mex01-carrier5-master-01:~$ kubectl exec armada-etcd-0 -- etcdctl --endpoints http://armada-etcd:2379 cluster-health
member a1ad1cd745497366 is healthy: got healthy result from http://armada-etcd-2.armada-etcd.default.svc.cluster.local:2379
member b896144a2c33e4d5 is healthy: got healthy result from http://armada-etcd-1.armada-etcd.default.svc.cluster.local:2379
member ea33ddb99d9e1282 is healthy: got healthy result from http://armada-etcd-0.armada-etcd.default.svc.cluster.local:2379
cluster is healthy
~~~~~

Example output for a partially healthy (Some failed member pods but still enough healthy left to continue) multi-node etcd instance:

~~~~~text
garethbottomley@dev-mex01-carrier5-master-01:~$ kubectl exec armada-etcd-0 -- etcdctl --endpoints http://armada-etcd:2379 cluster-health
failed to check the health of member a1ad1cd745497366 on http://armada-etcd-2.armada-etcd.default.svc.cluster.local:2379: Get http://armada-etcd-2.armada-etcd.default.svc.cluster.local:2379/health: dial tcp [::1]:2377: getsockopt: connection refused
member a1ad1cd745497366 is unreachable: [http://armada-etcd-2.armada-etcd.default.svc.cluster.local:2379] are all unreachable
member b896144a2c33e4d5 is healthy: got healthy result from http://armada-etcd-1.armada-etcd.default.svc.cluster.local:2379
member ea33ddb99d9e1282 is healthy: got healthy result from http://armada-etcd-0.armada-etcd.default.svc.cluster.local:2379
cluster is healthy
~~~~~

**NOTE:** If you are unlucky enough to pick the unreachable pod to exec the etcdctl command on you may get an exec failure instead of seeing this output. Try again on another member pod to get a better view of the cluster as a whole. If all pods fail then again you have your answer :)

Example output for an unhealthy (Not enough alive member pods for quorum) multi-node etcd instance:

~~~~~text
garethbottomley@dev-mex01-carrier5-master-01:~$ kubectl exec armada-etcd-0 -- etcdctl --endpoints http://armada-etcd:2379 cluster-health
failed to check the health of member a1ad1cd745497366 on http://armada-etcd-2.armada-etcd.default.svc.cluster.local:2379: Get http://armada-etcd-2.armada-etcd.default.svc.cluster.local:2379/health: dial tcp [::1]:2379: getsockopt: connection refused
member a1ad1cd745497366 is unreachable: [http://armada-etcd-2.armada-etcd.default.svc.cluster.local:2379] are all unreachable
member b896144a2c33e4d5 is unhealthy: got unhealthy result from http://armada-etcd-1.armada-etcd.default.svc.cluster.local:2379
failed to check the health of member ea33ddb99d9e1282 on http://armada-etcd-0.armada-etcd.default.svc.cluster.local:2379: Get http://armada-etcd-0.armada-etcd.default.svc.cluster.local:2379/health: dial tcp [::1]:2379: getsockopt: connection refused
member ea33ddb99d9e1282 is unreachable: [http://armada-etcd-0.armada-etcd.default.svc.cluster.local:2379] are all unreachable
cluster is unhealthy
~~~~~

## Checking the logs

After determining the health of the etcd cluster the next useful step is to check the logs for each instance. This can give you some clues to how a healthy etcd may be behaving.

To see the latest log output for an etcd pod use the following command:

~~~~~text
kubectl logs -n armada <pod-name>
~~~~~

Things you may see in the logs:

~~~~~text
2017-04-21 17:05:00.492917 W | wal: sync duration of 1.719859318s, expected less than 1s
2017-04-21 17:05:00.565767 I | pkg/fileutil: purged file /mnt/var/etcd/data/member/snap/0000000000000015-000000000b412eb4.snap successfully
2017-04-21 17:05:43.088034 W | etcdserver: apply entries took too long [221.680793ms for 1 entries] 2017-04-21 17:05:43.088071 W | etcdserver: avoid queries with large range/delete range!
~~~~~

This can be a symptom of a database with a large number of entries as some of the queries we run across our keyspace take a long time due to the shear number of keys they have to traverse.

## Connecting to an http endpoint within a pod

This is a useful method for testing an http endpoint in a pod in dev/stage/prod. You might need to use this if the docker image that kube is running for a pod does not have curl installed e.g. etcd

1. Port forward the pod port to a local port on the master/worker you are logged into:

   ~~~~~text
   kubectl port-forward -n armada armada-etcd-1030757139-gvkkp <local-port>:<pod-port>
   ~~~~~

2. Use curl on the master/worker to attach to the metrics endpoint:

   ~~~~~text
   curl localhost:<local-port>/metrics
   ~~~~~

## Useful metrics for debugging microservice ETCD

Using prometheus it is possible to show you the average time between visits of armada-cluster to workers currently being processed.
It's impacted by the etcd response time, but is not actually the etcd response time itself.
`avg(cluster_worker_inter_visit_time>0)`

This query shows you the average response time from etcd. If the value is above 300s this indicates that ETCD
is slow, then normal value is between 120s and 150s. See below for possible causes of ETCD being slow.

It is also possible to view Grafana (https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier3/grafana as an example)
to view ETCD performance characteristics. The dashboard of concern is *microservice-etcd-metrics*, all hub carriers will have this grafana
graph.

For general ETCD slowness, ETCD throughput and Microservice ETCD response times are the important graphs to pay attention to. If there is a single culprit (one service) that is slowing down ETCD, they can be identified through the per-app graphs at the bottom of the dashboard.

For ETCD problems, where ETCD is not returning data at all, pay attention to the Data Errors graph.

When the ETCD clusters performance is degraded it is useful to look at the network / disk / memory / CPU metrics to determine the root cause. All commands mentioned here should be ran on the etcd tugboat.

Find all nodes that can host ETCD:
`kubectl get nodes -l etcd=armada`

To view host performance metrics visit the `carrier-host-metrics-overview` grafana dashboard for the etcd tugboat.

To view ETCD network performance (p2p network latency): use this query on the etcd tugboat prometheus instance. `(sum by(To, instance) (rate(etcd_network_peer_round_trip_time_seconds_sum{etcd_cluster=~"etcd-\\d+-armada-.*"}[5m])) / sum by(To, instance) (rate(etcd_network_peer_round_trip_time_seconds_count{etcd_cluster=~"etcd-\\d+-armada-.*"}[5m]))) > 0.1`

This query shows all network p2p network latency is over 10ms. p2p latency over 10ms for a prolonged period of time is going tolead to degraded etcd performance.

## Quick fixes for ETCD CIEs (microservice ETCD)

Following on from the metrics gathered from (Useful metrics for debugging microservice ETCD). One of the first steps to attempting to recover the service is to move ETCD instances with high CPU usage to another node. This only be done one instance at a time, and only with etcd instances they have outlier CPU usage (think 20%+ more than next peer).

## Escalation policy

Consult the [escalation policy](./armada_pagerduty_escalation_policies.html) document to determine which squad to escalate to.
