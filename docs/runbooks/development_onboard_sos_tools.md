---
layout: default
description: Information how dev squads should manually onboard SOS tools
service: SOS onboarding
title: How to manually onboard the SOS tool to a cruiser cluster
runbook-name: "SOS onboarding"
tags: conductors support onboarding
playbooks: ["Runbook needs to be Updated with playbooks info (if applicable)"]
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
link: /development_onboard_sos_tools.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details how a cluster owner can manually install the SOS tools onto a kubernetes cluster.

**NB:** The SRE squad do not action this for the development squads but should be aware to provide assistance/guidance if needed.  Some squads have automation which does this for them

## Detailed information

To monitor IKS clusters for compliance, cluster owners need to deploy SOS tools to them if the cluster is over 6 days in age. 
Any clusters under this age do not require the tooling installed.
In most circumstances, cluster owners should look to remove clusters before they reach 7 days in age, however, there are cases where clusters need to stay in existence for longer periods of time.  If that is the case, `custil` must be installed.

## csutil deployment

The `csutil addon` is the recommended method to deploy csutil to an IKS or ROKS cluster.

Tooling has been created by the Compliance automation team which monitors `IKS.VPC.PROD Test account - 1984464`, `Dev Containers 1186049` and `Alchemy Staging Account in test.cloud.ibm.com` to will create GHE issues when gaps with compliance are spotted.  The automation supports automated cluster removal if csutil is not deployed after 7 days (an approval from the Complaince squad is required to drive this removal)

## Common/shared components.

The `csutil` tooling requires an ovpn certificate to communicate to SOS.  
SRE have bulk ordered certificates so individual squads do not need to manage these so please ignore any steps in the `csutil` documentation that involve ordering opvn files.

The `ovpn` certificates have been loaded into a `secrets-manager` instance in 1186049 Dev Containers.  
Please follow the below guidance to find, reserve and label a certificate for your usage.

## Obtaining a certificate

Please read [the certificate management runbook](./csutil_certificate_management.html) for details on how SOS VPN certificates are managed.

### Deploying the csutil addon

Detailed instructions are available in the [ArmadaCsutil repository](https://github.ibm.com/ibmcloud/ArmadaCSutil)
Review the details in the README to understand all the options available to you

Example steps to deploy are as follows:

1. Log into IBM Cloud and target the IBM Account where the cluster is located.

1. Clone the `ArmadaCSutil` repo, or download the `install.sh` script.

1. Deploy the SOS tooling to the cluster using the options below. Values to use are specified alongside the option  
    - `--crn-service-name=containers-kubernetes-dev`
    - `--cluster=yourClusterName or id`
    - `--crowdstrike=true` 
    - `--change-tracker=true` 
    - `--nessus=true`

    - An example is:
       >`./install.sh --cluster=<CLUSTER NAME> --crn-service-name=containers-kubernetes-dev --crn-cname=staging --sos-config-path=<OVPN FILE>.ovpn --crowdstrike=true --change-tracker=true --nessus=true`

1. Review the output and investigate and fix any errors that occur.
Example output is
```
<-----Checking ibmcloud login....----->
User is currently LoggedIn to account.

<-----Setting kubectl context for vulnerability-check-1....----->
OK
The configuration for vulnerability-check-1 was downloaded successfully.

Added context for vulnerability-check-1 to the current kubeconfig file.
You can now execute 'kubectl' commands against your cluster. For example, run 'kubectl get nodes'.
If you are accessing the cluster for the first time, 'kubectl' commands might fail for a few seconds while RBAC synchronizes.

<-----Creating ibm-services-system namespace and required configmaps....----->
namespace/ibm-services-system unchanged
configmap/crn-info-services unchanged
configmap/csutil-ports unchanged
configmap/csutil-cpu-memory configured

<-----Creating sos-vpn-secret from a given ovpn file....----->
secret/sos-vpn-secret created

<-----Checking for sos-vpn-secret existance in the cluster....----->
sos-vpn-secret exists under ibm-services-system namespace.

<-----Checking if add-on is already enabled or not. If not, then enabling it....----->
csutil-experimental add-on is already enabled.

<-----Waiting for kube-auditlog-forwarder service to come in a Running state....----->
kube-auditlog-forwarder service is Running now.

<-----Setting Kubernetes API server audit-webhook....----->
Kubernetes API server audit-webhook is already configured for vulnerability-check-1.


INSTALLATION COMPLETE

INSTALLATION SUMMARY:
Add-on csutil-experimental is enabled in the cluster vulnerability-check-1 now.
INSTALLED_VERSION: 1.0.0_945_iks_exp
However, it may take time to update the Addon status as Addon Ready. Please refer to below CHECK HEALTH-STATUS section for more.

CHECK HEALTH-STATUS:
PODs may take upto 15 to 20 mins to be in a Running state. When all mandatory PODS are Running that indicates the VPN connectivity is established and reports are successfully being published.

Once PODs are Running, Please wait for atleast 10 to 15 mins before checking for Health Status of the add-on.
    ...

    To see the resources created:
    $ kubectl get all --namespace ibm-services-system
    PODs may take up to 15 minutes to be READY.  When all PODS are ready that indicates that VPN connectivity is established and reports are successfully being published

    Next steps:
    Customizing Prometheus Alerts refer to: https://github.ibm.com/ibmcloud/PrometheusAutomationPrototype
    For more information on QRadar and BigFix Console for IKS see: https://github.ibm.com/ibmcloud/ArmadaKubProfiles/blob/master/documentation/ops/sos.md

    Getting help:
    For help or questions use slack channel #sos-armada and users @richmole
```

## Verify the install

Run `kubectl get po -n ibm-services-system` - this will show all the PODs in the namespace where csutil gets deployed to.   Verify they enter into a running state.
```
% kubectl get po -n ibm-services-system -owide
NAME                                       READY   STATUS    RESTARTS   AGE   IP               NODE             NOMINATED NODE   READINESS GATES
change-tracker-69rdh                       1/1     Running   0          24d   10.185.251.89    10.185.251.89    <none>           <none>
change-tracker-fkjjf                       1/1     Running   0          24d   10.185.251.102   10.185.251.102   <none>           <none>
change-tracker-stdwc                       1/1     Running   0          24d   10.241.170.188   10.241.170.188   <none>           <none>
change-tracker-vtqxr                       1/1     Running   0          24d   10.185.251.82    10.185.251.82    <none>           <none>
crowdstrike-5lz2f                          1/1     Running   0          13d   172.30.37.211    10.241.170.188   <none>           <none>
crowdstrike-htp4t                          1/1     Running   0          13d   172.30.111.35    10.185.251.82    <none>           <none>
crowdstrike-twhd4                          1/1     Running   0          13d   172.30.120.207   10.185.251.102   <none>           <none>
crowdstrike-vnj67                          1/1     Running   0          13d   172.30.246.102   10.185.251.89    <none>           <none>
kube-auditlog-forwarder-57df879886-npkng   1/1     Running   0          10d   172.30.37.207    10.241.170.188   <none>           <none>
sos-nessus-agent-2px2g                     1/1     Running   0          22h   10.241.170.188   10.241.170.188   <none>           <none>
sos-nessus-agent-6qgcm                     1/1     Running   0          22h   10.185.251.89    10.185.251.89    <none>           <none>
sos-nessus-agent-9fdqk                     1/1     Running   0          22h   10.185.251.82    10.185.251.82    <none>           <none>
sos-nessus-agent-tmm6k                     1/1     Running   0          22h   10.185.251.102   10.185.251.102   <none>           <none>
sos-tools-7577f76b96-jzxv8                 5/5     Running   0          22h   172.30.246.93    10.185.251.89    <none>           <none>
syslog-configurator-6gjdr                  1/1     Running   0          24d   172.30.120.219   10.185.251.102   <none>           <none>
syslog-configurator-fwwz8                  1/1     Running   0          24d   172.30.37.235    10.241.170.188   <none>           <none>
syslog-configurator-r8dsw                  1/1     Running   0          24d   172.30.246.98    10.185.251.89    <none>           <none>
syslog-configurator-zq9x5                  1/1     Running   0          24d   172.30.111.26    10.185.251.82    <none>           <none>
```

## Decommission a cluster

If you remove a cluster, please remember to release the ovpn certificate so others can use it.  It's a simple as removing the labels on the certificate in the secrets manager instance.

## Getting access to the SOS portal for containers-kubernetes-dev

Anyone installing csutil to clusters will need to order extra access via Access Hub so they can access the ARMADA inventory and monitor the compliance status of their clusters.
The AccessHub group is under `SOS ID Mgmt` and under `BU203` and is called `BU203-ARMADA-containers-kubernetes-dev-SOS-Inventory-Reader`

Once ordered and approved, raise a [conductors team ticket](https://github.ibm.com/alchemy-conductors/team/issues/new) requesting that you are added to the security focal list for [containers-kubernetes-dev](https://w3.sos.ibm.com/inventory.nsf/application.xsp?c_code=armada&documentId=C254A&action=openDocument) in SOS.  All SRE squad leads should be able to action this request.  If any issues are seen, please tag `Paul Cullen - @cullepl` in the request.

## Responsibilities once csutil is installed

Any clusters you order are your responsibility.
Please ensure you regularly perform these actions

- Pull the latest csutil updates and re-install (Only needed for old helm csutil deployment process)
- Perform master and worker updates to install worker node patches and updates.
- Keep compliant with supported kubernetes/ROKS versions

If you are having issues with any of the compliance, reach out to the SRE team for guidance

## Automation

There isn't any automation for this.  None is planned as effort is being made by SRE to turn csutil into a addon, making it easier to install and update.

If you want to automate things rather than running it manually, other teams have created scripts and processes for this which I've provided examples below.

The SRE squad have some automation they use for clusters in 278445
- [GHE Code is available here](https://github.ibm.com/alchemy-conductors/cstuils-supportacct-updates)

The VA Squad have automated this through jenkins. 

- [Jenkins job details are - here](https://alchemy-containers-jenkins.swg-devops.com/view/Vulnerability-Advisor/job/Vulnerability-Advisor/job/build/job/Promote-Armada/job/_manual-promote/)

- [Ansible details are here](https://github.ibm.com/alchemy-va/armada-va/blob/master/roles/bootstrap/sos/tasks/main.yml)


## Escalation and assistance

There is no formal escalation policy for this. If in doubt with any of these steps, please speak to the SRE Squad  
_Some of the US & UK Squad members have experience with csutil so best to start with there._

If assistance is needed from the SOS Team, questions can be asked in the [#sos-armada](https://ibm-argonauts.slack.com/messages/C7H1HAXT3) slack channel
