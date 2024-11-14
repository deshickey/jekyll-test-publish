---
layout: default
description: General information around etcd-operator and its purpose in armada
title: General information around etcd-operator and its purpose in armada
service: armada-deploy
runbook-name: "General information around etcd-operator and its purpose in armada"
tags:  armada, etcd-operator
link: /armada/armada-etcd-operator-information.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes in further detail the purpose of etcd-operator and how it is used in armada.

## Detailed Information

### Background of etcd-operator

Etcd-operator is an open source tool from the community. General information can be found [here](https://github.com/coreos/etcd-operator). An internal [fork](https://github.ibm.com/alchemy-containers/etcd-operator) is used.

### Overview

The etcd operator manages etcd clusters deployed to [Kubernetes](http://kubernetes.io) and automates tasks related to operating an etcd cluster.
The following operations are done to manage etcd clusters, and explain more into detail in the following sections:

- [Create and Destroy](#create-and-destroy)
- [Failover](#failover)
- [Backup and Restore](#backup-and-restore)

#### Create and Destroy

##### Create

During a deploy of a customer master, a custom resource definition is created called `etcdcluster`. Along with it, it creates:
* [nodeport service](#nodeport-service)
* [client service](#client-service)
* [server service](#server-service)
* [continuous backup cronjob](#continuous-backup-cronjob)
* [client-tls secret](#client-tls-secret)
* [server-tls secret](#server-tls-secret)
* [peer-tls secret](#peer-tls-secret)

See below for an example of what that would look like on the carrier:
~~~~
kubectl get etcdcluster,po,svc,cronjob,job,secret -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d

etcdclusters/etcd-1927b9f56bc841c2a913e2a9cc19f16d   11h

po/etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s   1/1       Running   0          11h
po/etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx   1/1       Running   0          11h
po/etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4   1/1       Running   0          11h

svc/etcd-1927b9f56bc841c2a913e2a9cc19f16d                     ClusterIP   None             <none>        2379/TCP,2380/TCP   11h
svc/etcd-1927b9f56bc841c2a913e2a9cc19f16d-client              ClusterIP   172.20.48.237    <none>        2379/TCP            11h
svc/etcd-1927b9f56bc841c2a913e2a9cc19f16d-client-service-np   NodePort    172.20.145.76    <none>        2379:20458/TCP      11h

cronjobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d   3 3,11,19 * * *    False     0         Mon, 10 Sep 2018 19:03:00 +0000

jobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-1536577380   1         1            9h
jobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-1536606180   1         1            1h
jobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-update       1         1            11h

secrets/etcd-1927b9f56bc841c2a913e2a9cc19f16d-client-tls   Opaque                                3         11h
secrets/etcd-1927b9f56bc841c2a913e2a9cc19f16d-peer-tls     Opaque                                3         11h
secrets/etcd-1927b9f56bc841c2a913e2a9cc19f16d-server-tls   Opaque                                3         11h
~~~~

All of theses resources are created in one of the `kubx-etcd-(01-18)` namespaces.
There are 18 total namespaces that the resources can go into. The namespace is picked based on the least used namespace. That namespace will stay the same for the life
of a specific cluster. Our performance team was able to scale out these resources and figure out the best cap for these resources per namespace.
That number came out to ~100 clusters per namespace, which would allow us to fit ~1800 `etcdclusters` per carrier.

Create logic can be found here: [initialize_etcd_cluster](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/create-etcd/tasks/initalize_etcd_cluster.yml)

##### Destroy

Once the customer issues a delete on their cluster the `etcdcluster` resource along with its nodeport service, all secrets (peer, client, server), all services (client, server, nodeport), cronjobs, and all existing backups will be deleted.

Delete logic found here: [Delete the etcdcluster](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/remove-cluster/tasks/main.yml#L136)

##### Nodeport service

~~~~
kubectl get svc -n kubx-etcd-01 | grep NodePort | grep 1927b9f56bc841c2a913e2a9cc19f16d
etcd-1927b9f56bc841c2a913e2a9cc19f16d-client-service-np   NodePort    172.20.145.76    <none>        2379:20458/TCP      11h
~~~~

The nodeport service is used by the clients running on the customers workers to be able to talk to etcd directly. The most common use would be the use of calico.
To see how a pod can talk to etcd, we can log into one of the cruiser workers and look at `/etc/haproxy/haproxy.cfg`

~~~~
root@dev-mex01-pa1927b9f56bc841c2a913e2a9cc19f16d-w1:~# cat /etc/haproxy/haproxy.cfg
----
frontend masteretcdfrontend
    bind 172.20.0.1:2041
    mode tcp
    log global
    option tcplog
    default_backend masteretcdbackend
----
backend masteretcdbackend
    mode tcp
    balance roundrobin
    log global
    option tcp-check
    option log-health-checks
    default-server inter 60s  fall 3 rise 1
    server dev.cont.bluemix.net  dev.cont.bluemix.net:20458 check
~~~~

This shows that when a pod talks on the kubernetes service endpoint `172.20.0.1` on port `2041` it will be forwarded to `dev.cont.bluemix.net:20458`. The port `20458` is the same
nodeport value as seen above describe in the service `etcd-1927b9f56bc841c2a913e2a9cc19f16d-client-service-np`.

We can see calico talking to this endpoint by viewing the `calico-config` configmap in the `kube-system` namespace

~~~~
kubx-kubectl 1927b9f56bc841c2a913e2a9cc19f16d get cm -n kube-system -o yaml calico-config
----
  etcd_endpoints: https://172.20.0.1:2041
----
~~~~

##### Client service

~~~~
kubectl get service -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d | grep ClusterIP | grep client
etcd-1927b9f56bc841c2a913e2a9cc19f16d-client              ClusterIP   172.20.48.237    <none>        2379/TCP            11h
~~~~

The client service is used by the cruiser apiserver to load balance requests between all the etcd pod instances. The client service is also used by the backup operator to take backups of the cluster.

##### Server service

~~~~
kubectl get service -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d | grep ClusterIP | grep -v client
etcd-1927b9f56bc841c2a913e2a9cc19f16d                     ClusterIP   None             <none>        2379/TCP,2380/TCP   11h
~~~~

Headless service used to get a unique DNS entry for each pod. It allows pods that form the etcd cluster to communicate directly with each other using DNS instead of using IP addresses.

##### Continuous Backup Cronjob

~~~~
kubectl get cronjob,job,po -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d
cronjobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d   3 3,11,19 * * *    False     0         Mon, 10 Sep 2018 19:03:00 +0000

jobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-1536577380   1         1            10h
jobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-1536606180   1         1            2h
jobs/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-update       1         1            11h

po/etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s                  1/1       Running     0          11h
po/etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx                  1/1       Running     0          11h
po/etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4                  1/1       Running     0          11h
po/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-153657736bbjl   0/1       Completed   0          10h
po/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-15366061k5r4n   0/1       Completed   0          2h
po/kubx-etcd-backup-1927b9f56bc841c2a913e2a9cc19f16d-update-g4pt8    0/1       Completed   0          11h
~~~~

This cronjob will run three times a day, every 8 hours and do a backup of the current state of the `etcdcluster`. More details on the backup can be found here: [Backup](#backup)

##### client-tls Secret

~~~~
kubectl get secret -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d | grep client
etcd-1927b9f56bc841c2a913e2a9cc19f16d-client-tls   Opaque                                3         12h
~~~~

The client-tls secret is used for clients like the apiserver and backup operator to connect to etcd.
The certs are signed using the `cfssl-tls-generation` role in armada-ansible. [here](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/cfssl-tls-generation/tasks/etcd-tls-generation.yml)

Signing details found [here](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/cfssl-tls-generation/templates/etcd-client-csr.json.j2)

##### server-tls Secret

~~~~
kubectl get secret -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d | grep server
etcd-1927b9f56bc841c2a913e2a9cc19f16d-server-tls   Opaque                                3         12h
~~~~

The server-tls secret is used in the etcd cluster to provide server authentication for clients connecting to the etcd cluster. Armada's etcd setup uses mutual TLS and these certs provide authentication on the server side. These certs **must be valid for every DNS and IP the server will be contacted over** including the individual carrier load balancer instances and the reserved IP address in the cluster.
The certs are signed using the `cfssl-tls-generation` role in armada-ansible. [here](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/cfssl-tls-generation/tasks/etcd-tls-generation.yml)

Signing details found [here](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/cfssl-tls-generation/templates/etcd-server-csr.json.j2)

##### peer-tls Secret

~~~~
kubectl get secret -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d | grep peer
etcd-1927b9f56bc841c2a913e2a9cc19f16d-peer-tls     Opaque                                3         12h
~~~~

The peer-tls secret is used for intra cluster communication between etcd pods. ETCD pods use the raft protocol to participate in consensus protocols that require all replicas to talk to one another. These certs are used for those types of communications. The certs should be signed in the same way as the server certs for safe measures.
The certs are signed using the `cfssl-tls-generation` role in armada-ansible. [here](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/cfssl-tls-generation/tasks/etcd-tls-generation.yml)

Signing details found [here](https://github.ibm.com/alchemy-containers/armada-ansible/blob/ha-master-tyler/kubX/roles/cfssl-tls-generation/templates/etcd-peer-csr.json.j2)

#### Failover
If the **minority** of etcd members crash, the etcd operator will automatically recover the failure. In our case, the minority it just 1 single etcd pod. Let's walk through this in the following steps

1. View a healthy running etcd cluster
    ~~~~
    kubectl get po -n kubx-etcd-01 -o wide | grep 1927b9f56bc841c2a913e2a9cc19f16d
    etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s   1/1       Running   0          12h       172.16.92.155    10.130.231.144
    etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx   1/1       Running   0          12h       172.16.117.14    10.131.16.67
    etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4   1/1       Running   0          12h       172.16.236.154   10.130.231.207
    ~~~~

1. Delete a single pod
    ~~~~
    kubectl delete po -n kubx-etcd-01 etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s
    pod "etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s" deleted
    ~~~~

1. Wait a few minutes for it to come back, etcd-operator does reconciliation loops every minute, so after ~1 minute it will detect a dead member and attempt to spin up a new one.
    ~~~~
    kubectl get po -n kubx-etcd-01 -o wide -a | grep 1927b9f56bc841c2a913e2a9cc19f16d
    etcd-1927b9f56bc841c2a913e2a9cc19f16d-9cmg6vzsfp                  1/1       Running     0          1m        172.16.169.59    10.131.16.5
    etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx                  1/1       Running     0          12h       172.16.117.14    10.131.16.67
    etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4                  1/1       Running     0          12h       172.16.236.154   10.130.231.207
    ~~~~

1. Now we can look at the etcd-operator logs for this specific cluster to see how it removed the dead member and added back one
    ~~~~
    kubectl logs -n kubx-etcd-01 etcd-operator-f7d6fb688-625t6 | grep 1927b9f56bc841c2a913e2a9cc19f16d
    -------
    time="2018-09-10T21:31:11Z" level=info msg="running members: etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx,etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:31:11Z" level=info msg="cluster membership: etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s,etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx,etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:31:11Z" level=info msg="removing one dead member" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:31:11Z" level=info msg="removing dead member \"etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s\"" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:31:11Z" level=info msg="removed member (etcd-1927b9f56bc841c2a913e2a9cc19f16d-cwjtnnc59s) with ID (11129993800628859921)" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:31:11Z" level=info msg="Finish reconciling" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:32:11Z" level=info msg="Start reconciling" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:32:11Z" level=info msg="running members: etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx,etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:32:11Z" level=info msg="cluster membership: etcd-1927b9f56bc841c2a913e2a9cc19f16d-lqrjz4mhvx,etcd-1927b9f56bc841c2a913e2a9cc19f16d-ns2gsl8kb4" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:32:11Z" level=info msg="added member (etcd-1927b9f56bc841c2a913e2a9cc19f16d-9cmg6vzsfp)" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    time="2018-09-10T21:32:11Z" level=info msg="Finish reconciling" cluster-name=etcd-1927b9f56bc841c2a913e2a9cc19f16d pkg=cluster
    ~~~~

1. For cases of `etcdcluster` losing the **majority** of its members see [Backup and Restore](#backup-and-restore)

#### Backup and Restore

##### Backup

Note: For clusters that are 1.9 or less, v2 backup is done by extracting the v2 data from the etcdcluster and pushing it to COS. V2 data is used for calico, but calico in
version 1.10 above use v3 etcd.

All v3 data is backed up using the etcd backup operator. Backups are done 3 times a day (every 8 hours), and we keep a single backup on the 1st and 15th of the previous month.
Additionally, if a customer did an update on their master, an additional backup will be done that day. At most there will be `5 + (master update count that day)` backups stored in COS.
A backup has no impact on the customer cluster, and pod state does not change whatsoever. A backup can be done if at **least one** `etcdcluster` pod is running. The etcdcluster is
inoperable when the pod count is 1 or less. A backup can be done against the 1 pod and restored to prevent data loss. More info can be found in [restore](#restore)

Everything discussed below in this section is done using a cronjob deployed when the cluster is created. To see the workings of the cronjob take a look at [armada-etcd-recovery backup](https://github.ibm.com/alchemy-containers/armada-etcd-recovery/tree/master/backup)

Etcd backup operator backups the data of a etcdcluster running on [Kubernetes](https://github.com/kubernetes/kubernetes) to a remote storage COS [S3](https://aws.amazon.com/s3/).

Each `kubx-etcd` namespace has an etcd backup operator running in it.

~~~~
kubectl get po -n kubx-etcd-01 | grep backup
etcd-backup-operator-698cb8496f-q9c74              1/1       Running   2          12d
~~~~

The backup operator looks for custom resource definitions called `etcdbackup`, and uses the info provided in the resource to do a backup of the customers etcdcluster.

~~~~
kubectl get etcdbackup -n kubx-etcd-01 | grep 1927b9f56bc841c2a913e2a9cc19f16d
1927b9f56bc841c2a913e2a9cc19f16d         2h
~~~~

There are cos credentials in each `kubx-etcd` namespace. These credentials are used by the etcd backup operator to authenticate with our COS to store data. COS credentials
are deployed using [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/us-south/armada-cos-secrets.yaml)

~~~~
kubectl get secrets -n kubx-etcd-01  | grep cos
cos-credentials                                    Opaque                                2         124d
~~~~

##### Restore

Note: For clusters that are 1.9 or less, v2 restore is done by downloading the v2 data from cos and injecting it into a healthy etcdcluster. V2 data is used for calico, but calico in
version 1.10 above use v3 etcd.

Currently all restores of an etcdcluster are done manually. There are runbooks on how to recover using tools provided on the carrier to restore a customers etcdcluster.
[Restore Runbook](./armada-etcd-unhealthy.html). Using the tools, we are able to restore using the most recent backup taken for that specific cluster.

Everything discussed below in this section is done using tools provided on the carrier, to see the workings of the tools take a look at [armada-etcd-recovery restore](https://github.ibm.com/alchemy-containers/armada-etcd-recovery/tree/master/restore)

Each `kubx-etcd` namespace has an etcd restore operator running in it.

~~~~
kubectl get po -n kubx-etcd-01 | grep restore
etcd-restore-operator-66b4cf7b49-rnpdp             1/1       Running   72         43d
~~~~

The restore operator looks for custom resource definitions called `etcdrestore`, and uses the info provided in the resource to do a restore of the customers etcdcluster.

~~~~
kubectl get etcdrestore -n kubx-etcd-17 | grep ffa1c8dc0df9447a9c05748d2a3eecba
etcd-ffa1c8dc0df9447a9c05748d2a3eecba         4d
~~~~

The restore operator can restore an etcdcluster on [Kubernetes](https://github.com/kubernetes/kubernetes) from the backup provided.
Etcd operator will then take over the management of the restored cluster.
