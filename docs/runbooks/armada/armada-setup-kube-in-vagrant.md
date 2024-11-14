---
layout: default
description: How to setup kubectl in your vagrant VM to access Armada environments
title: armada - How to setup kubectl in your vagrant VM to access Armada environments
service: armada
runbook-name: "armada - setup kubectl in vagrant"
tags: alchemy, armada, kubernetes, kube, kubectl
link: /armada/armada-setup-kube-in-vagrant.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

It is possible to setup kubernetes on a vagrant box to allow you to connect a locally installed kubectl to the various Armada environments. This means you don’t need to ssh into the masters and workers themselves to run kube commands which can be very useful e.g. kubectl proxy is now running on your vagrant box and therefore serving the UI on an address you can reach with a browser.

## Setup Process

1. Install kubectl onto your vagrant box from [here](https://kubernetes.io/docs/tasks/kubectl/install/)
2. Create a kubeconfigs directory in your /vagrant directory in your vagrant box. This means all of your config files and certs will be stored on the host machine i.e. your laptop
3. Copy this into a file called admin-kubeconfig in your kubeconfigs directory:

   ~~~~~
   current-context: dev-mex01-carrier5
   apiVersion: v1
   kind: Config
   contexts:
   - name: dev-mex01-carrier5
     context:
       cluster: local-dev-mex01-carrier5
       user: admin-dev-mex01-carrier5
       namespace: default
   - name: prestage-mon01-carrier0
     context:
       cluster: local-prestage-mon01-carrier0
       user: admin-prestage-mon01-carrier0
       namespace: default
   - name: prod-dal10-carrier1
     context:
       cluster: local-prod-dal10-carrier1
       user: admin-prod-dal10-carrier1
       namespace: default
   - name: stage-dal09-carrier0
     context:
       cluster: local-stage-dal09-carrier0
       user: admin-stage-dal09-carrier0
       namespace: default
   clusters:
   - name: local-dev-mex01-carrier5
     cluster:
       certificate-authority: /vagrant/kubeconfigs/dev-mex01-carrier5/cert/ca.pem
       apiVersion: v1
       server: https://10.130.231.164:443
   - name: local-prestage-mon01-carrier0
     cluster:
       certificate-authority: /vagrant/kubeconfigs/prestage-mon01-carrier0/cert/ca.pem
       apiVersion: v1
       server: https://10.130.231.164:443
   - name: local-prod-dal10-carrier1
     cluster:
       certificate-authority: /vagrant/kubeconfigs/prod-dal10-carrier1/cert/ca.pem
       apiVersion: v1
       server: https://10.130.231.164:443
   - name: local-stage-dal09-carrier0
     cluster:
       certificate-authority: /vagrant/kubeconfigs/stage-dal09-carrier0/cert/ca.pem
       apiVersion: v1
       server: https://10.130.231.164:443
   users:
   - name: admin-dev-mex01-carrier5
     user:
       client-certificate: /vagrant/kubeconfigs/dev-mex01-carrier5/cert/admin.pem
       client-key: /vagrant/kubeconfigs/dev-mex01-carrier5/cert/admin-key.pem
   - name: admin-prestage-mon01-carrier0
     user:
       client-certificate: /vagrant/kubeconfigs/prestage-mon01-carrier0/cert/admin.pem
       client-key: /vagrant/kubeconfigs/prestage-mon01-carrier0/cert/admin-key.pem
   - name: admin-prod-dal10-carrier1
     user:
       client-certificate: /vagrant/kubeconfigs/prod-dal10-carrier1/cert/admin.pem
       client-key: /vagrant/kubeconfigs/prod-dal10-carrier1/cert/admin-key.pem
   - name: admin-stage-dal09-carrier0
     user:
       client-certificate: /vagrant/kubeconfigs/stage-dal09-carrier0/cert/admin.pem
       client-key: /vagrant/kubeconfigs/stage-dal09-carrier0/cert/admin-key.pem
   ~~~~~

4. Create the cert directories for all four environments e.g.

   ~~~~~
   mkdir /vagrant/kubeconfigs/dev-mex01-carrier5
   mkdir /vagrant/kubeconfigs/dev-mex01-carrier5/cert
   ~~~~~

5. Copy the cert files from each master. Note that you will need the correct VPN to be active for each master you are copying from.

   ~~~~~
   scp garethbottomley@stage-dal09-carrier0-master-01:/etc/kubernetes/cert/ca.pem /vagrant/kubeconfigs/stage-dal09-carrier0/cert/ca.pem
   scp garethbottomley@stage-dal09-carrier0-master-01:/etc/kubernetes/cert/admin.pem /vagrant/kubeconfigs/stage-dal09-carrier0/cert/admin.pem
   scp garethbottomley@stage-dal09-carrier0-master-01:/etc/kubernetes/cert/admin-key.pem /vagrant/kubeconfigs/stage-dal09-carrier0/cert/admin-key.pem
   ~~~~~

6. Set your KUBECONFIG environment variable:

   ~~~~~
   export KUBECONFIG=/vagrant/kubeconfigs/admin-kubeconfig
   ~~~~~

7. Choose the context you want to use. Note that again you need the matching VPN running for it to work.

   ~~~~~
   vagrant@precise64:/vagrant/kubeconfigs$ kubectl config get-contexts
   CURRENT   NAME                      CLUSTER                         AUTHINFO                        NAMESPACE
             stage-dal09-carrier0      local-stage-dal09-carrier0      admin-stage-dal09-carrier0      default
   *         dev-mex01-carrier5        local-dev-mex01-carrier5        admin-dev-mex01-carrier5        default
             prestage-mon01-carrier0   local-prestage-mon01-carrier0   admin-prestage-mon01-carrier0   default
             prod-dal10-carrier1       local-prod-dal10-carrier1       admin-prod-dal10-carrier1       default
   vagrant@precise64:/vagrant/kubeconfigs$ kubectl config use-context dev-mex01-carrier5
   Switched to context "dev-mex01-carrier5".
   vagrant@precise64:/vagrant/kubeconfigs$ kubectl cluster-info
   Kubernetes master is running at https://10.130.231.164:443
   Heapster is running at https://10.130.231.164:443/api/v1/proxy/namespaces/kube-system/services/heapster
   KubeDNS is running at https://10.130.231.164:443/api/v1/proxy/namespaces/kube-system/services/kube-dns
   ~~~~~
   
8. You’re done! Now you can use kubectl on your local vagrant machine as if you were logged into one of the masters in dev/stage/prod etc