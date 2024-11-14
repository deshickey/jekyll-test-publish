---
layout: default
description: How to resolve etcd database space exceeded error
title: armada-etcd - how to resolve etcd database space exceeded error
service: armada-etcd-operator
runbook-name: "armada-etcd - etcd database space exceeded"
tags: alchemy, armada, etcd, space, size, exceeded
link: /armada/armada-etcd-db-space-exceeded.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

This runbook describes how to handle etcd database space exceeded errors.

## Example Alerts

`CarrierETCDSizeCriticalEtcdOperator`
`CarrierETCDSizeWarningEtcdOperator`

## Detailed Information

### ETCD Size Warning

The first step is to determine if the etcd db growth is gradual or sudden.
1. Navigate to prometheus to find the graph for historical etcd size
    * More info on how to get to prometheus can be found [here](./armada-general-debugging-info.html#general-prometheus-usage)
1. Run the following query and go to the graph:
    ~~~~
    avg(etcd_debugging_mvcc_db_total_size_in_bytes{etcd_cluster=~"etcd-\\d+-armada.*"})/1000000000
    ~~~~
1. If the growth is slow and steady continue with collecting data, if the growth is an extreme jump go to [Confirm the CIE](#confirm-the-cie) below
1. Verify the etcd defrag job has run successfully in the last 24 hours [ETCD defrag job](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-carrier-component-troubled.html#etcd-defrag)
1. Open an issue in [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast/issues/new) and reach out to the @ballast team in the armada-ballast slack channel

### ETCD Size Critical

When the etcd DB runs out of space you will see the following failures when trying cli commands against clusters (except for cluster list which uses GHoST):

```
FAILED
Could not connect to a backend service. Try again later. (E0004)
```

In the armada-api logs (or any other service that uses etcd operator) you will see logs similar to

```
"key":"/armada-api/us-south/account_lock_xxx","error":"etcdserver: mvcc: database space exceeded"
```

or

```
{"level":"warn","ts":"2020-03-20T09:46:04.082Z","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"endpoint://client-110026eb-d42b-4b92-a1d8-181b8ebc18f4/etcd-104-1.us-south.containers.dev.cloud.ibm.com:31579","attempt":0,"error":"rpc error: code = ResourceExhausted desc = etcdserver: mvcc: database space exceeded"}
```

The specific log to be looking out for is something along the lines of "etcdserver: mvcc: database space exceeded"

#### Confirm the CIE
Confirm the CIE ([SRE - raising a CIE](../sre_raising_cie.html)) with the following text in the notice:

   ```txt
   TITLE:   Delay with IBM Kubernetes cluster provisioning and worker node operations

   SERVICES/COMPONENTS AFFECTED:
   - IBM Kubernetes Service

   IMPACT:
   - IBM Kubernetes Service, using classic infrastructure
   - IBM Kubernetes Service, using VPC on Classic infrastructure
   - IBM Kubernetes Service, using VPC on Gen2 infrastructure
   - Users may see delays in provisioning workers for new or existing clusters
   - Users may see failures in provisioning portable subnets for new or existing clusters
   - Users may see delays in provisioning persistent volume claims for existing clusters
   - Users may see delays in reloading, rebooting or deleting existing workers of clusters
   - Kubernetes workloads otherwise using previously provisioned infrastructure resources are unaffected

   STATUS:
   - 201X-XX-XX XX:XX UTC - INVESTIGATING - The SRE team is aware and investigating.
   ```

#### Detailed Procedure

You will need to temporarily increase etcd database size, perform a restore to make use of the new size, then run a defrag to reclaim space.

1. Increase etcd quota by modifying the `ETCD_QUOTA_BACKEND_BYTES` property in the etcd operator service descriptor: [https://github.ibm.com/alchemy-containers/armada-etcd-operator/blob/master/services/armada-etcd-operator/deployment.yaml](https://github.ibm.com/alchemy-containers/armada-etcd-operator/blob/master/services/armada-etcd-operator/deployment.yaml)
Change the value to `"16000000000"`
2. Create a git commit then a dev tag using the command `git tag dev-<DESCRIPTIVE_NAME>` and push your commit.
3. Create a prod trains to promote the dev variation to the affected region. When the travis build succeeds promote the dev tag.
4. Apply the new quota by performing a backup and restore of etcd for the affected region by following the directions here: [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-cluster-etcd-unhealthy.html#armada-etcd-restore](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-cluster-etcd-unhealthy.html#armada-etcd-restore)
5. Once the restore job completes you'll need to disable the size alarms by exec'ing into an etcd pod and running the following:
etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt --command-timeout=5000000s alarm disarm

example:

```
[prod-dal10-carrier105] root@prod-dal12-carrier2-worker-1010:~# kubectl exec -it -n armada etcd-105-armada-us-south-kfmmrl98cj -c etcd -- etcdctl --endpoints=https://localhost:2379 --cert=/etc/etcdtls/operator/etcd-tls/etcd-client.crt --key=/etc/etcdtls/operator/etcd-tls/etcd-client.key --cacert=/etc/etcdtls/operator/etcd-tls/etcd-client-ca.crt --command-timeout=5000000s alarm disarm
memberID:12362047916703754097 alarm:NOSPACE
memberID:4048441469556378289 alarm:NOSPACE
```

6. Now run a defrag on the cluster: [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-carrier-component-troubled.html#etcd-defrag](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-carrier-carrier-component-troubled.html#etcd-defrag)
7. Once the defrag is complete verify that the ETCD DB size has gone down. You can do this by viewing the `DB Size` table in the Carrier Etcd dashboard in grafana. If the size has gone down you can remove the dev tag from prod so that the etcd DB quota size is back to normal.

## Escalation Policy

Reach out to the @ballast handle in #armada-ballast or escalate to [Alchemy - Containers Tribe - Ballast](https://ibm.pagerduty.com/schedules#PP1MP9Q)
