---
layout: default
title: Neuvector Runbook
type: Informational
runbook-name: Neuvector Runbook
description: How to investigate issues with Neuvector and escalate to SUSE support if required.
service: armada
ownership-details:
  escalation: "Alchemy - Network Intel 24x7"
  owner-link: "https://ibm-cloudplatform.slack.com/messages/netint"
  corehours: "UK"
  owner-notification: False
  group-for-rtc-ticket: Runbook needs to be Updated with group-for-rtc-ticket
  owner: "Network Intelligence [#netint]"
  owner-approval: False
link: /runbooks/armada/neuvector.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
How to handle issues with Neuvector.

### Background
Neuvector is a container security platform which runs on all nodes in IKS microservices tugboats. It performs web application firewalling (WAF) and denial of service (DOS) protection on the istio ingress pods.

At the time of writing, the configuration should raise informational alerts only, so if any traffic is being blocked, it is likely the result of a bug or instability. This runbook describes how to investigate Neuvector's health, and also how to escalate via SUSE support if needed.

## Detailed Information

### Examples of PagerDuty alerts
Example:

    - `NeuvectorEnforcerDaemonsetsNotAllRunning`
    - `NeuvectorControllerDeploymentReplicasNotAllRunning`
    - `NeuvectorManagerDeploymentReplicasNotAllRunning`

### Actions to take

1. Gain access to run `kubectl` commands on the corresponding cluster in the user's preferred manner. Some options may include Bastion/ssh via OpenVPN for carriers, and `invoke-tugboat` from the carrier or `ibmcloud ks cluster config -c <cluster-id>` for tugboats.

2. Check the status of the corresponding resource, i.e.:

- For `NeuvectorEnforcerDaemonsetsNotAllRunning` run `kubectl get ds -n neuvector neuvector-enforcer-pod`.
- For `NeuvectorControllerDeploymentReplicasNotAllRunning` run `kubectl get deployment -n neuvector -o wide neuvector-controller-pod`.
- For `NeuvectorManagerDeploymentReplicasNotAllRunning` run `kubectl get deployment -n -o wide neuvector neuvector-manager-pod`.

3. If the command output above matches the details in the alert (i.e. there are instances/replicas unavailable), then investigate the failing pods, e.g.:

- For `NeuvectorEnforcerDaemonsetsNotAllRunning` run `kubectl get po -n neuvector -l app=neuvector-enforcer-pod --field-selector=status.phase!=Running`.
- For `NeuvectorControllerDeploymentReplicasNotAllRunning` run `kubectl get po -n neuvector -l app=neuvector-controller-pod --field-selector=status.phase!=Running`.
- For `NeuvectorManagerDeploymentReplicasNotAllRunning` run `kubectl get po -n neuvector -l app=neuvector-manager-pod --field-selector=status.phase!=Running`.

4. Investigate any pods returned by the above commands using normal pod debugging strategies, specific example included below.  If the alert is `NeuvectorEnforcerDaemonsetsNotAllRunning` please also investigate node stability for the daemonset pods that are failing to schedule.

```
kubectl describe po -n neuvector neuvector-controller-pod-b69d48db7-rn2wx
kubectl logs -n neuvector neuvector-controller-pod-b69d48db7-rn2wx
```

5. If the remediation is unclear, please page `Alchemy - Network Intel 24x7`.


### Further Debugging/Monitoring=

This section is designed to be performed by Netint following a page-out.

1. Gather the data described in the `Actions to take` section if not already supplied.

2. If the controller is available (i.e. 2/3 replicas or better are available) then access the dashboard as follows:

a. Download Firefox if you don't have it.
b. Connect to the correct OpenVPN for the cluster in question if you are not already.
c. On carrier ssh to the carrier master, or on a tugboat ssh to a worker on the regional carrier and `invoke-tugboat`.
d. `nohup kubectl port-forward svc/neuvector-service-webui -n neuvector 8443 &`.
e. On your local machine initiate a socks proxy session to the machine you started the port-forward on in the previous step, e.g. `ssh -f -N -D 0.0.0.0:443 alexkell@10.130.231.16`.
f. Open Firefox proxy settings (open Settings, search for "Proxy") and configure a Socks5 proxy on `localhost` port `443`.
g. Navigate to `about:config` in Firefox and flip `network.proxy.allow_hijacking_localhost` to true.
h. Navigate to `https://localhost:8443`.
i. Log in with either your SOS credentials or if unavailable with the default admin account (credentials in Thycotic).

3. Navigate to the [Security Events](https://localhost:8443/index.html?v=88c70254a4#/app/security-event) view and see if there are any unexpected events with "Action: Block" (currently any events with an Action other than Alert are unexpected).

4. If the remediation path is unclear or you do not feel confident debugging further please escalate to Neuvector via the [SUSE Customer Center](https://scc.suse.com/) out of hours, or both the SCC and the [#neuvector-poc](https://ibm-argonauts.slack.com/archives/C01CP25F8R2) Slack channel during US office hours.

### RCA and pCIEs

These alerts alone should not be cause for a pCIE and will not affect customers directly. If traffic is unexpectedly being dropped by the WAF or another Neuvector problem then this should be clear from existing API monitoring.

### Components and Understanding

For more information on Neuvector see the following sources:

- [armada-envy repo](https://github.ibm.com/alchemy-netint/armada-envy) for our configuration of Neuvector
- [Neuvector docs](https://open-docs.neuvector.com/)

### Escalation Policy

Escalate the issue to the Netint squad via `Alchemy - Network Intel 24x7`.

Slack Channel: [#netint](https://ibm-argonauts.slack.com/archives/C53PUD2TE)
GitHub Issues: https://github.ibm.com/alchemy-netint/team/issues
