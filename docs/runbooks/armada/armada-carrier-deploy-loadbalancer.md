---
layout: default
description: Instructions for deploying armada carrier LoadBalancer
title: Carrier LoadBalancer Deployment
service: armada-carrier
runbook-name: "Carrier LoadBalancer Deployment"
tags: armada-carrier, carrier, loadbalancer
link: /armada/armada-carrier-deploy-loadbalancer.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

# Overview
This runbook provides steps for deploying armada carrier loadbalancer

## Background
In order to try and resolve stability problems with the **HA proxy servers**, we are going to need to deploy public & private LoadBalancers to **carriers** using the armada-deploy Jenkins job to run an ansible playbook to complete this task. 

**Note**: 
- This runbook only for Carrier, not any tugboat type cluster.
- Due to public endpoint issues, currently only private LB is enabled. Once netint team addresses the issues, both public & private LB should be enabled.
## Pre-requirement
- Check if the configmap of carrier-van-ip-config is deployed in target carrier, the configmap is stored in [repos](https://github.ibm.com/alchemy-netint/carrier-vlan-ip-config). 
- Verify the configmap "**ibm-cloud-provider-vlan-ip-config**"  in namespace "**kube-system**" with correct configuration.
- Deploy edge nodes to carriers (2 per zone for MZR, 1 per zone of SZR) -- [example link](https://github.ibm.com/alchemy-conductors/team/issues/20810)
- Open [Jenkins Job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/build?delay=0sec) to run playbook
- Go to **How to start Jenkins job to run playbook** step

## Supported input Carrier list
As data source from repos https://github.ibm.com/alchemy-netint/carrier-vlan-ip-config/tree/main/deployment/overlays. So this playbook support all carrier name with the directory.

## How to start Jenkins job to run playbook
- Open [Jenkins Job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/build?delay=0sec)
- Input carrier's Environment and select carrier number in Carrier
- Check "SKIP_WORKERS" checkbox
- Input '**carrier_lb_setup.yml**' in CUSTOM_PLAYBOOK

[example Jenkins Job link](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-carrier-deploy/467556/rebuild/parameterized)

**Note** if deploy in prod/stage env, need input train ID in CFS_TRAIN_ID

## Post-check after Jenkins Job successfully completed
- login Carrier cluster check ibm-ip-provider-<VIPs> pods up and running
```
kubectl get pods -n ibm-system
```
- check loadbalancer services in kube-sytem namespace
```
kubectl get services -n kube-system
```
- stop keepalived in two [env]-[carrier_name]-haproxy-[01|02] host
login into haproxy host run below commands
```
sudo systemctl disable keepalived --now
```
- check whether Carrier's alchemy-dashboard page good to open or not.


## Troubleshooting
If Carrier's alchemy-dashboard page is not good to open, enable keepalived in two [env]-[carrier_name]-haproxy-[01|02] again,
let traffic go back to haproxy.
ask netint and SRE team for help in #conductor-for-life
## Feedback
If there is any questions about Jenkins job run the playbook, please create an issue in https://github.ibm.com/alchemy-conductors/team/issues, and then post notice in slack channel #conductor-for-life.



