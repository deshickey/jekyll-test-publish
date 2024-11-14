---
layout: default
description: How to handle kube-proxy hangs alert sent from logDNA
title: Handle kube-proxy hangs alert
service: armada-deploy
runbook-name: "Handle kube-proxy hangs alert"
tags: armada, kubernetes, armada-deploy, kube-proxy, tugboat, carrier
link: /armada/armada-deploy-kube-proxy-hangs.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This runbook describes the process to handle kube-proxy hangs alert sent from logDNA

### Background

There is a problem with the `kube-proxy` systemd service running on workers where it effectively "hangs" - it logs errors like

```
E0718 11:52:02.953513    6384 reflector.go:123] k8s.io/client-go/informers/factory.go:134: Failed to list *v1.Endpoints: the server could not find the requested resource (get endpoints)
```

and stops updating iptables with service and endpoint changes.

When this happens kube-proxy needs to be restarted, which can require a worker reload for tugboat workers.

### Enable alerting from logDNA

Currently, the detection of such issue is to monitor kube-proxy.log file, and see if there are multiple lines of errors indicated as above. Therefore, we enabled the logDNA alerting to alert such situation immediately when error logs are spotted.

You can go to corresponding logDNA instance to check View -> kube-proxy hangs and see logs growing.

## Example Alert(s)

https://ibm.pagerduty.com/incidents/PB8YYHG

```
kube-proxy hangs detected in prod.us-south

region: us-south,
...
...
host: Run https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/kube-proxy-hang-host-extractor/ to get the full list
```

At the meantime, you may get other alerts which is a result of service communication failure. For example, master pods crashing: https://ibm.pagerduty.com/incidents/PVILJLI

## Actions to take

- **Run Jenkins job** [kube-proxy-hang-host-extractor](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/kube-proxy-hang-host-extractor/) with the `REGION` found in Pagerduty alert and keep the `QUERY_TIME` as `NOW` to get the full list of affected worker nodes. Depending on the types of workers, we can take following actions to recover

- **Restart kube-proxy** on carrier workers

   Conductors can log into traditional carrier workers, the worker IP and associated carrier name can be found in the output of the above Jenkins job result.

   1. Log into the problem worker(s)
   1. Run following command
      ```
      sudo systemctl restart kube-proxy
      ```
   1. Make sure kube-proxy is up and running
      ```
      sudo systemctl status kube-proxy
      ```
   1. Repeat for the whole list of workers in the output of Jenkins job

- **Reload** tugboat workers

   The only way to recovery kube-proxy on tugboat workers is to reload the worker node. You can find the complete list of affected workers under the tugboat name. Just issue a `reload` to Chlorine (former Igorina). And it will reload the workers one by one.

- **Verify** if all the kube-proxy error logs are cleared

   After all the workers have been handled (restart kube-proxy or reload). Re-run the [Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/kube-proxy-hang-host-extractor/) with the same `REGION` and `QUERY_TIME=NOW`. Make sure that this time Jenkins job reports `CLEAN`.

- **Manually resolve** the Pagerduty alert with the above Jenkins build run URL as resolution note.

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.armada-deploy.escalate.name }}]({{ site.data.teams.armada-deploy.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.issue }}) Github repository for later follow-up.
