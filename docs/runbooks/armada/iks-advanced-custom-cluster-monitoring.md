---
layout: default
description: How to handle IKS advanced customer cluster monitoring alert
title: armada-ops - How to handle advanced customer cluster issue
service: armada
runbook-name: "armada-ops - How to handle advanced customer cluster issue"
tags: armada, advanced, customer, cluster
link: /armada/iks-advanced-custom-cluster-monitoring.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes how to deal with alerts reporting a **cluster** or **worker** on a cluster is unhealthy.

We're watching closely on the health of some important clusters, the list is recorded in [GHE Repo `alchemy-conductors/advanced-customer-cluster-monitor`](https://github.ibm.com/alchemy-conductors/advanced-customer-cluster-monitor/blob/master/targets)

If a cluster (listed in the repo linked to above) has any issues described in the list below, a PagerDuty alert will be triggered - notifications will be sent to `IKS SRE` and Ralph Bateman.

One or more:
- **pods** (e.g. master pod, etcd pod and cluster-health) associated with the cluster show NOT Running in carriers/tugboats
- **pods** do not have all the containers Ready in the above pods (e.g. etcd pod shows 1/2 for status)
- **worker nodes** of the cluster show NotReady in the result of `kubectl get node`

This monitoring is currently performed by [Jenkins job `advanced-customer-cluster-monitor`](https://alchemy-containers-jenkins.swg-devops.com/job/armada-ops/job/advanced-customer-cluster-monitor/) and it will be integrated into armada-ops Prometheus/Alertmanager monitoring later.

To avoid blip of the cluster status (in `advanced-customer-cluster-monitor`) a re-check will be performed 5 minutes later if issue was found during the first check. PagerDuty alert will be triggered only if the issue persists. And the above job runs every 10 minutes.

## Example Alerts

All the alerts will be triggered against [IKS Advanced Customer Cluster Monitoring](https://ibm.pagerduty.com/services/P1RAN7T)

- [Cluster cgliksp01_bnkjtdvd03sqjar31uhg is not healthy](https://ibm.pagerduty.com/incidents/PAOP187)

   In this alert, `cluster_status` shows one etcd pod with 1/2 readiness status:

   ```
   kubx-etcd-07  etcd-bnkjtdvd03sqjar31uhg-ccr8mls7xl                    1/2  Running    0  5d8h   10.184.8.132
   ```

   In the `jenkins_job` field, you will find the Jenkins job url which triggered this alert.

- [Cluster cgliksnp01_bn43q61d0s8reagq93t0 has 1 worker(s) NotReady](https://ibm.pagerduty.com/incidents/P3GRRDN)

   This is the alert for worker unhealthy, in the `failed_worker` field, it shows which worker in NotReady, with the worker ID listed:

   ```
   172.16.208.64    NotReady,SchedulingDisabled   <none>   30d   v1.16.7+IKS   kube-bn43q61d0s8reagq93t0-cgliksnp01-cgliksn-000048c3
   ```

## Actions to take

The goal is to take these alerts as priority and make sure we put the cluster back to healthy as soon as possible.
Please log into the carrier/tugboat indicated in the Pagerduty alert to get the latest cluster status first.

### Check related alerts on the same carrier/tugboat

Check the `failed_reason` field of the alert and find cluster running carrier/tugboat from the field `carrier` or `tugboat` of the triggered alert. Check if there is any alerts related to the cluster status.
Sometimes, one node unhealthy could cause the master/etcd pods running on it not functioning correctly. Try to check the existing alerts and find out if it is the case.

Follow the same runbook to fix the master pods issues

- [master pods unhealthy](./armada-ha-cruiser-patrol-master.html)
- [etcd pods unhealthy](./armada-cluster-etcd-unhealthy.html)
- [openvpn pods unhealthy](./armada-network-openvpn-server-troubleshooting.html)
- [cluster-health pod unhealthy](./armada-cluster-health-pod-down.html)
- [cluster-updater pod unhealthy](./armada-customer-cluster-updater-down.html)
- [etcd-backup pod unhealthy](./armada-etcd-backup-failing.html)

### Fix cluster worker NotReady issue

- Check if the cluster apiserver is working fine by invoking kubx-kubectl against the cluster, e.g. `get node`, `get pods`. You can find the running carrier/tugboat from the field `carrier` or `tugboat` of the triggered alert
- Review if there is any existing infrastructure network outage or degrade
- Check with armada-xo to see if there is any on-going task on the specific worker, you can find the worker id from the `failed_worker` field in the alert
- [Public doc on debugging worker nodes](https://console.bluemix.net/docs/containers/cs_troubleshoot.html#debug_worker_nodes)
- [Cruiser worker troubleshooting tips](../cluster/cluster-squad-common-troubleshooting-issues.html)
- If a support ticket has been opened regarding worker health, suggesting a worker reload can serve as a fast and effective means to mitigate the issue.

#### VPC Worker

If this cluster is on VPC, we need to reach out to VPC team for further assistance. Following steps need to be taken.

- If the cluster is in the eu-fr2 region, please contact the @ipops-bnpp squad directly via the [#ipops-classic-bnpp](https://ibm-cloudplatform.slack.com/archives/C016TA21P5X) Slack Channel and provide the details of the troubled production customer cluster worker on VPC for investigation.

- Open a support ticket to VPC team by following the instruction in [this runbook](./armada-vpc-raise-support-ticket-for-worker.html). There is an example ticket:

   ```
   title: logs needed for customer RCA node: <VPC worker node ID>
   description:
     VPC VSI ID - <get VSI ID from result of ibmcloud is instances>
     VPC VSI Hostname - <VPC worker node ID>
     Account: <customer account ID>

     A customer experienced issues with their IKS worker. It would have been in the IKS Service Account (detailed above). IKS would like to know if there are issues with the VSI at any point.

     The customer is requesting an RCA as to what caused the problems and we'd like to rule out underlying issues in the IaaS with the VSI.
   ```
- Follow up with VPC SRE team in the slack channel [#ipops-cases](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD) in workspace `ibm-cloudplatform` for the support ticket
- Open a linked GHE issue in https://github.ibm.com/riaas/defects/, which will draw VPC team's attention and involve them more actively.
   - This should be done by opening the support ticket in [ServiceNow](https://watson.service-now.com/). Scroll down to the `Related Links` part, click the `Github Issues` tab, click `New`, put `https://github.ibm.com/riaas/defects/` into the `Repository URL` field, and then click `Submit`. There will be a GHE issue link created, and follow up in the issue.
   - Here is an [example GHE issue](https://github.ibm.com/riaas/defects/issues/4355)

## Escalation Policy

### For master pods related issues

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.

### For cluster worker bootstrap related issues

Please follow the [escalation guidelines](./armada-bootstrap-collect-info-before-escalation.html) to engage the bootstrap development squads.

### For cluster worker network related issues

Involve **armada-network** ([#slack](https://ibm-argonauts.slack.com/archives/C53P0HNDS) [PagerDuty](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)) team for investigation

General questions can be ased in slack [#armada-dev](https://ibm-argonauts.slack.com/archives/C56K90989)
