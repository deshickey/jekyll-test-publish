---
layout: default
description: How to use local kube CLI to interact with remote carrier clusters.
title: How to use local kube CLI to interact with remote carrier clusters
service: armada
runbook-name: "How to use local kube CLI to interact with remote carrier clusters"
tags: alchemy, armada, kubernetes, kube, kubectl
link: /armada/armada-local-kube-cli-usage.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes how to interact with a particular carrier kube cluster from the comfort of your local machine.

## Prerequisites
In order to complete the following steps, you will need VPN/SSH access for the systems you are trying to interact with.

## Step 1 - Install kubernetes kubectl CLI
The easiest way to get kubectl is to download the latest release with one of the following commands, depending on your local system's OS:

~~~
# OS X
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl

# Linux
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

# Windows
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/windows/amd64/kubectl.ex
~~~

See the official kubernetes [docs](https://kubernetes.io/docs/tasks/kubectl/install/) for even more ways to install kubectl.

Make sure it installed correctly by listing the version.  It should look something like the following:

~~~
kubectl version

Client Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.2", GitCommit:"08e099554f3c31f6e6f07b448ab3ed78d0520507", GitTreeState:"clean", BuildDate:"2017-01-12T04:57:25Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"darwin/amd64"}
~~~

## Step 2 - Copy kubeconfig and cert files from carrier master
In order for your local kubectl to know how to talk with the remote carrier cluster, you must have the correct kubeconfig and certification/key files on your system.

The following files on the carrier-master node must have their contents copied and moved to your local system.

- admin-kubeconfig (`/etc/kubernetes/admin-kubeconfig`)
- admin-key.pem (`/etc/kubernetes/cert/admin-key.pem`)
- admin.pem (`/etc/kubernetes/cert/admin.pem`)
- ca.pem (`/etc/kubernetes/cert/ca.pem`)

The files do not have to be in the same location on your local system.  But what is important is that the following lines in your local version of `admin-kubeconfig` accurately map to where you have created the local version of the cert files:

- `certificate-authority: /etc/kubernetes/cert/ca.pem`
- `client-certificate: /etc/kubernetes/cert/admin.pem`
- `client-key: /etc/kubernetes/cert/admin-key.pem`

If you created all of the cert files in the same locations as they were on the master, you shouldn't have to make any changes.

## Step 3 - Set KUBECONFIG env variable
Once you have all the files in place on your system, you need to then set the KUBECONFIG env variable to tell the kubectl CLI which cluster you are trying to talk to.

(Note: The following command assumes you have created your local version of the `admin-kubeconfig` file in `/etc/kubernetes/`.  Use whatever path you have chosen for your kubeconfig file.)

~~~
export KUBECONFIG=/etc/kubernetes/admin-kubeconfig
~~~

## Step 4 - Done.  Test it out!
Your local system should now be setup to interact with the carrier kube cluster as if you were on the remote system itself.

Try it out!

~~~
kubectl get nodes
~~~

See the official kubernetes kubectl [docs](https://kubernetes.io/docs/user-guide/kubectl/) for all of the available commands you can use.
