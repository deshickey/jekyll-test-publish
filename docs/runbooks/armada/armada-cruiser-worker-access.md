---
layout: default
description: "Armada - Access Cruiser Worker Nodes"
title: "Armada - Access Cruiser Worker Nodes"
runbook-name: "Armada - Access Cruiser Worker Nodes"
service: armada
tags: ssh, block, cruiser, worker, node, access, login, logon, alchemy, armada, calico, connect, containers, kubernetes, pod
link: /armada/armada-cruiser-worker-access.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes how to get full SSH access to a worker node

## Detailed Information

### Access Kubernetes Worker Node Via Privileged Pod

SSH (and most other traffic) is blocked by default over the public IP of Cruiser worker nodes to protect these customer worker nodes.  The following instructions, pulled from various contributors, describe how to get full access to a cruiser kubernetes worker node even with public SSH blocked.  This requires access to kubectl admin authority for the cruiser cluster in order to create a privileged pod and exec into it.  These instructions will also work for carrier worker nodes, although for carrier the preferred option is to SSH to the node's private IP address using a VPN.

1. Run the following and find the Name of the worker node you want access to: `kubectl get nodes -o wide`
2. Create the following pod running on that node.  Replace ```<NODE_NAME_HERE>``` in the command below with the node name from the above command (usually that node's IP address):

~~~
export WORKER=<NODE_NAME_HERE>

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: worker-${WORKER}
spec:
  hostNetwork: true
  containers:
    - name: worker
      securityContext:
        privileged: true
      image: kitch/sshdaemonset
      volumeMounts:
      - mountPath: /host
        name: host-root
  tolerations:
  - operator: "Exists"
  volumes:
  - name: host-root
    hostPath:
      # directory location on host
      path: /
  nodeSelector:
    kubernetes.io/hostname: ${WORKER}
EOF
~~~
3. Ensure the pod is created successfully, and get the pod name: `kubectl get pods -o wide`
4. Exec into the pod: `kubectl exec -it worker-${WORKER} sh`
5. SSH into the host: `ssh localhost`
6. When you are done on the node, please remove the SSH key from the node and delete the worker-${WORKER} pod.
    - From inside the worker node SSH session, delete the ssh key line from the ~/.ssh/authorized_keys file using vi or similar text editor.  The key will probably be the last line in the file, and the end of that line should look something like this: ```root@kube-<XXXX><cluster-ID>-<NNN>.cloud.ibm```
    - Log out of the ssh session and the kubectl exec session, then run: ```kubectl delete pod worker-${WORKER}```

Note: Image `kitch/sshdaemonset` does not support LinuxONE Worker Node, please refer alternatives below.

### Alternative Access To Kubernetes Worker Node Via `agnhost`

1. Run the following and find the Name of the worker node you want access to: `kubectl get nodes -o wide`
2. Create the following pod running on that node.  Replace ```<NODE_NAME_HERE>``` in the command below with the node name from the above command (usually that node's IP address):
```
kubectl debug node/<NODE_NAME_HERE> -it --image=us.icr.io/armada-test/agnhost:2.43 -- sh
chroot /host
```

### Alternative Access To Kubernetes Worker Node Via Generic Privileged Pod

If you don't have access to kitch/sshdaemonset or the above pod yaml isn't working for you for whatever reason, you can do something similar, but with more manual steps.  The following solution is like the steps above, but uses the plain "alpine" container, and requires more steps once you have exec'd into the container

1. Run the following and find the Name of the worker node you want access to: `kubectl get nodes -o wide`
2. Create the following pod running on that node.  Replace ```<NODE_NAME_HERE>``` in the command below with the node name from the above command (usually that node's IP address):

~~~
export worker_name=<NODE_NAME_HERE>

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: privileged
spec:
  hostNetwork: true
  containers:
    - name: privileged
      # The container definition
      # ...
      securityContext:
        privileged: true
      image: alpine
      command: ["sleep"]
      args: ["600000"]
      volumeMounts:
      - mountPath: /host
        name: host-root
  volumes:
  - name: host-root
    hostPath:
      # directory location on host
      path: /
  nodeSelector:
    kubernetes.io/hostname: ${worker_name}
EOF
~~~

3. Ensure the pod is created successfully, and get the pod name: `kubectl get pods -o wide`
4. Exec into the pod: `kubectl exec -it privileged sh`
5. Change to /root: `cd`
6. Install ssh tools: `apk update;apk add openssh`
7. Create new ssh key: `ssh-keygen -N "" -f /root/.ssh/id_rsa`
8. Copy the public ssh key to the host authorized_keys list: `cat .ssh/id_rsa.pub >> /host/home/armada/.ssh/authorized_keys`
    - NOTE: If for some reason the armada user isn't on the cruiser worker, this command and the ssh command next should be run replacing "armada" with a user that is on the system
9. SSH into the host: ```ssh armada@$(ip a | grep "scope global eth0" | awk '{print $2}' | cut -d/ -f1)```
10. When you are done on the node, please remove the SSH key from the node and delete the privileged pod.
    - From inside the worker node SSH session, delete the ssh key line from the ~/.ssh/authorized_keys file using vi or similar text editor.  The key will probably be the last line in the file, and the end of that line should look something like this: ```root@kube-<XXXX><cluster-ID>-<NNN>.cloud.ibm```
    - Log out of the ssh session and the kubectl exec session, then run: ```kubectl delete pod privileged```

### Access Kubernetes Worker Node Via Calico Policy

While public SSH is blocked by default, an administrator may choose to enable public SSH with the following Calico policy. This is also useful for development purposes.

 - Calico v2 command (for kube 1.9 and earlier clusters)

~~~
kubx-calicoctl <clusterID> apply -f - <<EOF
apiVersion: v1
kind: policy
metadata:
  name: open-ssh-port
spec:
  selector: ibm.role in { 'worker_public', 'master_public' }
  ingress:
  - action: allow
    protocol: tcp
    destination:
      ports:
      - 22
  - action: allow
    protocol: udp
    destination:
      ports:
      - 22
  order: 1500
EOF
~~~

- Calico v3 command (for kube 1.10 and newer clusters)

~~~
kubx-calicoctl <clusterID> apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: open-ssh-port
spec:
  selector: ibm.role in { 'worker_public', 'master_public' }
  ingress:
  - action: Allow
    protocol: TCP
    destination:
      ports:
      - 22
  - action: Allow
    protocol: UDP
    destination:
      ports:
      - 22
  order: 1500
EOF
~~~

## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [Calico Architecture](https://docs.projectcalico.org/v3.1/reference/architecture/)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
