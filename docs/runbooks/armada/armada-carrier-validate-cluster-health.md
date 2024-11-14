---
layout: default
description: How to check and validate the health of an armada cluster.
title: armada-carrier - How to validate the health of an armada cluster.
service: armada-carrier
runbook-name: "armada-carrier - How to validate the health of an armada cluster"
tags: alchemy, armada, kubernetes, runtime, validate, health
link: /armada/armada-carrier-validate-cluster-health.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

This runbook describes how to check and validate the health of an armada cluster. This will cover checking the status of all kube-system services, creating services and checking connectivity, as well as some other items.

## Detailed Information
### Check services on kube-system

The easiest way to validate an armada cluster is to check if all the kube-system services are deployed and running. To do this, either log on to the cluster master directly (for dev or vagrant systems) or point kubectl to the customer's cruiser. Below is an example from a Vagrant cluster showing a healthy cluster:

```
Welcome to Ubuntu 16.04.2 LTS (GNU/Linux 4.4.0-62-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Fri Mar 17 17:34:54 2017 from 10.0.2.2
vagrant@carrier0-master-1:~$ kubectl -n kube-system get pods
NAME                                        READY     STATUS    RESTARTS   AGE
calico-policy-controller-3575334706-79wzm   1/1       Running   1          7d
heapster-3531423569-vrwzp                   2/2       Running   2          7d
kube-dns-v20-5cc14                          3/3       Running   3          7d
kube-dns-v20-8kq6t                          3/3       Running   3          7d
kubernetes-dashboard-3406536787-rd390       1/1       Running   1          7d
vagrant@carrier0-master-1:~$
```

## Detailed Procedure
### Check connectivity of a cluster


1. Create deployment and expose service

```
rmolina@richards-mbp-3:~$ kubectl run test --image=nginx --replicas=2 --port=80
deployment "test" created

rmolina@richards-mbp-3:~$ kubectl expose deployment test --target-port=80 --type=NodePort
service "test" exposed
```

1. Get the NodePort and use the worker VIP to curl to test connectivity

```
rmolina@richards-mbp-3:~$ kubectl get service test --no-headers -o custom-columns=:.spec.ports[0].nodePort
32507

rmolina@richards-mbp-3:~$ curl 169.47.211.86:32507
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
rmolina@richards-mbp-3:~$
```

1. Test connectivity between pods

To test connectivity between pods, you will need the name and podIPs of the two pods that were created.  Once you have those, you can kubectl exec into one of the names and run ping tests against the other pods ip  

```
rmolina@richards-mbp-3:~$ kubectl get pods --no-headers -l run=test -o custom-columns=:.metadata.name
test-141932798-2wkp1
test-141932798-723b5

rmolina@richards-mbp-3:~$ kubectl get pods --no-headers -l run=test -o custom-columns=:.status.podIP
172.30.91.131
172.30.91.132

rmolina@richards-mbp-3:~$ kubectl exec test-141932798-2wkp1 -- ping -c3 172.30.91.132
PING 172.30.91.131 (172.30.91.131): 56 data bytes
64 bytes from 172.30.91.131: icmp_seq=0 ttl=64 time=0.079 ms
64 bytes from 172.30.91.131: icmp_seq=1 ttl=64 time=0.071 ms
64 bytes from 172.30.91.131: icmp_seq=2 ttl=64 time=0.059 ms
--- 172.30.91.131 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.059/0.070/0.079/0.000 ms

rmolina@richards-mbp-3:~$ kubectl exec test-141932798-723b5 -- ping -c3 172.30.91.131
PING 172.30.91.132 (172.30.91.132): 56 data bytes
64 bytes from 172.30.91.132: icmp_seq=0 ttl=63 time=0.150 ms
64 bytes from 172.30.91.132: icmp_seq=1 ttl=63 time=0.096 ms
64 bytes from 172.30.91.132: icmp_seq=2 ttl=63 time=0.097 ms
--- 172.30.91.132 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.096/0.114/0.150/0.025 ms
rmolina@richards-mbp-3:~$
```

1. Cleanup test pods

```
rmolina@richards-mbp-3:~$ kubectl delete deployment,service test
deployment "test" deleted
service "test" deleted
rmolina@richards-mbp-3:~$
```

## Escalation Policy

If you have additional questions on this or believe there is something further going on that needs to be investigated, please involve the `armada-carrier` squad via Slack [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) or [create an issue for armada-carrier](https://github.ibm.com/alchemy-containers/armada-carrier/issues/new) to track.
