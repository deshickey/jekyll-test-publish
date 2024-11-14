---
layout: default
title: IKS/ROKS Retrieve and Analyze Bootstrap Logs
runbook-name: "IKS/ROKS Retrieve and Analyze Bootstrap Logs"
tags: network troubleshooting retrieve analyze bootstrap logs jenkins job
description: "IKS/ROKS Retrieve and Analyze Bootstrap Logs"
service: armada-bootstrap
link: /armada/armada-bootstrap-retrieve-analyze-bootstrap-logs.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}


## Overview

This runbook describes how to retrieve and analyze bootstrap logs.  This is most useful for when a worker fails to deploy, especially when the error is `Worker unable to talk to IBM Cloud Kubernetes Service servers. Please verify your firewall setup is allowing traffic from this worker`  This error can be caused by many different things, and the bootstrap logs are a great way to narrow down the issue.

## Example Alerts

Worker deploy fails with `Worker unable to talk to IBM Cloud Kubernetes Service servers. Please verify your firewall setup is allowing traffic from this worker`

## Investigation and Action

The following sections describe how to try to retrieve bootstrap logs and then how to analyze them.

## Retrieve Bootstrap Logs

Use the first part of the [Collecting info to escalate to the bootstrap squad runbook](./armada-bootstrap-collect-info-before-escalation.html) to try to get the worker bootstrap logs via a jenkins job.

## Analyze Bootstrap Logs

This is meant to be used by developers, we do not expect ACS team members to do this level of troubleshooting.

If you do get the bootstrap logs, it is usually a good idea to start at the bottom of the log and work your way up to the place where the deploy failed.  Usually it is an ansible task that failed, and when you find that ansible task you can try to correlate the task with the bootstrap code which is in:

- IKS
    - Ubuntu: [https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal.yml](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal.yml)
    - Ubuntu LinuxONE: [https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal-s390x.yml](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal-s390x.yml)
    - RHEL7 (is this used anymore?): [https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal-rhel-iks.yml](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal.yml)
    - RHEL8 (Tugboat and Satellite Location workers): [https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal-rhel8-iks.yml](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal.yml)
- ROKS: 
    - RHEL7: [https://github.ibm.com/alchemy-containers/openshift-4-worker-automation/blob/develop/ansible/managed-worker-minimal-openshift-4.yml](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal.yml)
    - RHEL8: [https://github.ibm.com/alchemy-containers/openshift-4-worker-automation/blob/develop/ansible/managed-worker-minimal-openshift-4-rhel8.yml](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/kubX/managed-worker-minimal.yml)

Look at the ansible task that failed and try to determine why.

### Common Errors in Ansible Bootstrap Logs


**DNS Resolution Failure of VPE DNS Name**
VPC worker deploy will fail if the worker can not resolve the VPE DNS name, which looks like: `<CLUSTER-ID>.vpe.private.<REGION>.containers.cloud.ibm.com`  Here is what we see in the logs when this is the case:

~~~~~
failed: [10.242.128.13] (item=haproxy.service) => {
    "ansible_loop_var": "item",
    "attempts": 10,
    "changed": false,
    "invocation": {
        "module_args": {
            "daemon_reexec": false,
            "daemon_reload": false,
            "enabled": true,
            "force": null,
            "masked": null,
            "name": "haproxy.service",
            "no_block": false,
            "scope": "system",
            "state": "started"
        }
    },
    "item": "haproxy.service",
    "msg": "Unable to start service haproxy.service: Job for haproxy.service failed because the control process exited with error code.\nSee \"systemctl status haproxy.service\" and \"journalctl -xe\" for details.\n"
}

...

========HAPROXY LOG START==========
+ tail -50 /var/log/haproxy.log
Jan 10 10:35:46 kube-ceulegsl0hcofugjob5g-imarketv11p-prodwor-00002309 haproxy[2964]: [ALERT] 009/103546 (2964) : parsing [/etc/haproxy/haproxy.cfg:49] : 'server ceulegsl0hcofugjob5g.vpe.private.eu-gb.containers.cloud.ibm.com' : could not resolve address 'ceulegsl0hcofugjob5g.vpe.private.eu-gb.containers.cloud.ibm.com'.
Jan 10 10:35:48 kube-ceulegsl0hcofugjob5g-imarketv11p-prodwor-00002309 haproxy[2964]: [ALERT] 009/103546 (2964) : Failed to initialize server(s) addr.
...
Jan 10 10:46:18 kube-ceulegsl0hcofugjob5g-imarketv11p-prodwor-00002309 haproxy[3438]: [ALERT] 009/104618 (3438) : parsing [/etc/haproxy/haproxy.cfg:49] : 'server ceulegsl0hcofugjob5g.vpe.private.eu-gb.containers.cloud.ibm.com' : could not resolve address 'ceulegsl0hcofugjob5g.vpe.private.eu-gb.containers.cloud.ibm.com'.
Jan 10 10:46:25 kube-ceulegsl0hcofugjob5g-imarketv11p-prodwor-00002309 haproxy[3438]: [ALERT] 009/104618 (3438) : Failed to initialize server(s) addr.
+ echo '========HAPROXY LOG END=========='
~~~~~

This is from Customer Ticket: [https://github.ibm.com/alchemy-containers/customer-tickets/issues/14397](https://github.ibm.com/alchemy-containers/customer-tickets/issues/14397).  The VPE Gateway and pDNS teams investigated and found it was a timing bug/race condition when creating the VPE Gateway and private DNS entries.  I followed up [in slack](https://ibm-cloudplatform.slack.com/archives/C015GTC7V62/p1677019671964819) and am waiting to hear if it was fixed.  So if we see something like this again, we can ask in the [#ibmcloud-vpe](https://ibm-cloudplatform.slack.com/archives/C015GTC7V62/p1677019671964819) slack channel and reference this specific conversation and issue.  Once this is resolved we should update this runbook with any steps we could do to more quickly triage this if something similar happens again.

**Certificate Created During Bootstrap Does Not Go To "Issued" State Soon Enough**
In one performance test scenario, a certificate that was created did not go to “Issued” state before the retries expired.  I don't have the exact error but the ansible failed in ansible task: `TASK [generate-worker-certs-csrv1 : Wait for cert to enter ready state]`,  [https://github.ibm.com/alchemy-containers/armada-ansible/blob/2437a3628c84dff65eda9e24deeb2b41e9b65d89/kubX/roles/generate-worker-certs-csrv1/tasks/main.yml#L48-L54](https://github.ibm.com/alchemy-containers/armada-ansible/blob/2437a3628c84dff65eda9e24deeb2b41e9b65d89/kubX/roles/generate-worker-certs-csrv1/tasks/main.yml#L48-L54)   This was improved in [https://github.ibm.com/alchemy-containers/armada-ansible/pull/11122](https://github.ibm.com/alchemy-containers/armada-ansible/pull/11122) by adding more retries.

We saw this again in customer ticket [https://github.ibm.com/alchemy-containers/customer-tickets/issues/14654#issuecomment-53264594](https://github.ibm.com/alchemy-containers/customer-tickets/issues/14654#issuecomment-53264594), this time the root cause was a Portworx component running in the customer cluster that was breaking leader-election of the kubernetes master kube-controller-manager (by modifying a configmap in the customer cluster that was used to record the leader), and this was preventing kubelet certs from being issued for new workers (hence the certificates not going to "Issued" state).  Portworx was putting in a fix for this, so I don't think we will see this exact thing again, but might see something similar if kube-controller-manager isn't functioning.

**Put Other Common Errors Here**
As we use this runbook and start to see common errors in these logs we should add them to the section below along with an explanation of what causes those errors and how to resolve the problem.  And more importantly try to improve our code, either the bootstrap code or the environment/account/VPC configuration that caused the bootstrap code to fail, so either the deploy doesn't fail the next time this situation is hit, or it fails with a message that makes it clear how to recover.

## Ask for Assistance

If you can not determine the problem, use the section **Collecting Worker Logs on the node** in [Collecting info to escalate to the bootstrap squad runbook](./armada-bootstrap-collect-info-before-escalation.html), to try to get more logs from the customer.  Evaluate those results as well.  If it looks like a general VPC or Classic IaaS network issue, ask @support in the ticket to transfer it to the ACS-VPC team or the Classic IaaS support teams to take a look.  If it doesn't look like an infrastructure network issue, then add an internal note in the customer ticket to ask the bootstrap team to look at these logs, add the squad-bootstrap label to the GHE issue, and ping the team in #armada-bootstrap.

## Escalation Policy

If the above steps don't resolve the issue, and the problem appears to be network related, use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channel: [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)

## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
