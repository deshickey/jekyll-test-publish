---
layout: default
title: Repairing cluster etcd database entries
type: Informational
runbook-name: "Repairing cluster etcd database entries"
description: Repairing cluster etcd database entries
category: armada
service: armada-carrier
tags: alchemy, armada, kubernetes, etcd
link: /armada/armada-carrier-cluster-etcd-repair.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook documents an exercise in fixing a cluster etcd database that
had a corrupted key.  It intended for use under guidance of development and
could require a bit of research to fix anything much different than the case
described here.

## Detailed Information

### Background

The situation that this runbook is based on involved a k8s 1.9 cluster that suddenly
started seeing huge memory use in the etcd container and master pod evictions.

Restoring etcd did not fix the problem.  In fact, the `cruiser-etcd-restore.sh`
script failed trying to delete calico-node pods with an error like:
```
$ kubectl delete pod -n kube-system -l k8s-app=calico-node
Error from server: proto: Unknown: illegal tag 0 (wire type 0)
```
`kubectl get pods -n kube-system` failed with the same error.

Yet other operations worked:
- `kubectl get nodes`
- `kubectl get pod -n ibm-system`
- `kubectl get deploy -n kube-system`

And we found an error in the apiserver log:
```
E0201 17:29:30.145869       1 status.go:64] apiserver received an error that is not an metav1.Status: proto: Unknown: illegal tag 0 (wire type 0)
```

All that suggested that there was one or more pods with corrupt data in the etcd database,
possibly due to a pod status update that went awry.
`etcd` was happy with the backup, but the `apiserver` could not handle the stored value for some pod.

So we looked at etcd database - something none of us had done before.

### What does a Kubernetes etcd look like?

We'd love a link to a kubernetes design doc or similar, but we did find some helpful
docs. See [Further Information](#further-information).

For this problem, the takeaway was that Kubernetes stores pods with etcd keys like
`/registry/pods/NAMESPACE/POD`.

For example, here are keys for some pods in the `kube-system` namespace:
```
/registry/pods/kube-system/calico-kube-controllers-f766cd977-phvcw
/registry/pods/kube-system/calico-node-8x5j9
/registry/pods/kube-system/calico-node-v8vgh
/registry/pods/kube-system/calico-node-zsggj
/registry/pods/kube-system/heapster-58f85f96d4-rz8g2
/registry/pods/kube-system/ibm-file-plugin-795c78c8fb-jh77v
/registry/pods/kube-system/ibm-keepalived-watcher-cs729
/registry/pods/kube-system/ibm-keepalived-watcher-db788
```

### How do I access etcd?

We were able to keep etcd running (at least for a while) after a restore, so I exec'd
into the etcd container for the cluster master.  You can do this via `kubectl exec` or
(since I happened to be on the carrier worker node) `docker exec`:
- `kubectl -n kubx-masters exec -it master-2e862d0a77e140aeb51199aaa2d76f81-6d46d4bbc-hsnbd -c etcd -- sh`
or
- Find docker container via `sudo docker ps | grep CLUSTERID | grep etcd`
- `sudo docker exec -it CONTAINER sh`

If you cannot keep the etcd container running long enough, there should be other options
- (non-HA): restore backup to a stand-alone etcd database
- (HA) perhaps scale down the master or disable the k8s service for the cluster so that nothing is
hitting etcd

Assuming you exec into the container, set up the options for accessing the etcd server:
```
OPTIONS="--cacert=/mnt/etc/kubernetes-cert/ca.pem --cert=/mnt/etc/kubernetes-cert/etcd.pem --key=/mnt/etc/kubernetes-cert/etcd-key.pem --endpoints=https://127.0.0.1:4001"
```
You can then run `etcdctl` commands using:
```
ETCDCTL_API=3 etcdctl $OPTIONS get /registry/pods/kube-system --prefix --keys-only
```

### Finding the broken pod

Again, this is specific to this problem, but we were able to use `etcdctl` output in conjunction with
`kubx-kubectl` to find the broken pod.
- Get a list of pods in the `kube-system` NAMESPACE:<br>
`ETCDCTL_API=3 etcdctl $OPTIONS get /registry/pods/kube-system --prefix --keys-only`
- Paste that output into a file on the carrier master - `etcd.pods.txt`
- On the carrier master, use that list to run `kubectl get pod` pod by pod:<br>
`grep registry etcd.pods.txt | awk -F/ '{print $5}' | xargs -trn1 kubx-kubectl $c -n kube-system get pod`

That produced output like this (we had since tried scaling down replicas):
```
kubx-kubectl 2e862d0a77e140aeb51199aaa2d76f81 -n kube-system get pod calico-kube-controllers-f766cd977-phvcw
NAME                                      READY     STATUS        RESTARTS   AGE
calico-kube-controllers-f766cd977-phvcw   1/1       Terminating   0          73d
kubx-kubectl 2e862d0a77e140aeb51199aaa2d76f81 -n kube-system get pod calico-node-8x5j9
Error from server (NotFound): pods "calico-node-8x5j9" not found
kubx-kubectl 2e862d0a77e140aeb51199aaa2d76f81 -n kube-system get pod calico-node-v8vgh
Error from server (NotFound): pods "calico-node-v8vgh" not found

blah blah

kubx-kubectl 2e862d0a77e140aeb51199aaa2d76f81 -n kube-system get pod kube-dns-amd64-6d94d697d6-b6rjh
Error from server: proto: Unknown: illegal tag 0 (wire type 0)
```

We now knew the broken pod!

### Delete the pod from etcd

Deleting the pod turned out to be easy - after several failed attempts to delete the pod via
kubectl and curl.

```
/ # ETCDCTL_API=3 etcdctl $OPTIONS del /registry/pods/kube-system/kube-dns-amd64-6d94d697d6-b6rjh
1
```

We went back to the carrier master, and `kubx-kubectl $cluster get pods -n kube-system` now worked!

As luck would have it, that appeared to be the only problem in the `etcd` database.

### Cleanup and check out the rest of the cluster

If you scaled down deployments or took similar actions, don't forget to put everything back!

Check out the cluster as best you can to see if everything is working.
We had to reboot one worker because of pod sandbox problems.

## Further Information

We'd love some more.  These are the docs I found at the time:
- https://jakubbujny.com/2018/09/02/what-stores-kubernetes-in-etcd/
- https://github.com/rootsongjc/kubernetes-handbook/blob/master/guide/using-etcdctl-to-access-kubernetes-data.md
