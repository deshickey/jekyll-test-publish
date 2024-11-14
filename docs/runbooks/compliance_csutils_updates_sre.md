---
layout: default
title: Automation of Csutils update in SRE owned accounts
type: Informational
runbook-name: "compliance_csutils_updates_sre"
description: "This runbook describes about csutil installation to clusters SRE own and manage"
service: Conductors
link: /doc_updates/compliance_csutils_updates_sre.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
The `csutil` install on clusters in the following accounts gets updated automatically every week.  This is executed by a Jenkins jobs

1. Alchemy Support account (278445) 
2. Dev containers (1186049)
3. Prod EU-FR2 (2051458)

## Detailed information

csutil version needs to be updated regularly. For that instead of manually updating csutil for all clusters, Jenkins jobs have been created which periodically updates csutil.

- [`csutils-support-acct-278445`](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/Compliance/job/csutils-support-acct-278445/)
- [`csutils-devcontainers-acct-1186049`](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/Compliance/job/csutils-devcontainers-acct-1186049/) 
- [`csutils-iks-eufr2-prod-2051458`](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/Compliance/job/csutils-iks-eufr2-prod-2051458/)

### GHE Code

Ghe Repo Link for source code - [cstuils-supportacct-updates](https://github.ibm.com/alchemy-conductors/cstuils-supportacct-updates)

### How it works

Jenkins job is written in a way that it triggers automatically on weekly basis.  It goes through all the clusters based on the account name set in the Jenkins job variable `ACCOUNT` - this should match a json file name in the GHE source.  i.e.

- [`278445 support account cluster info`](https://github.ibm.com/alchemy-conductors/cstuils-supportacct-updates/blob/master/SupportAccount.json)
- [`1186049 dev containers cluster info`](https://github.ibm.com/alchemy-conductors/cstuils-supportacct-updates/blob/master/devContainersAccount.json)
- [`2051458 eu-fr2 cluster info`](https://github.ibm.com/alchemy-conductors/cstuils-supportacct-updates/blob/master/eufr2Account.json)


Once update is completed for a cluster, it waits for all Containers in the Pods to come up. If they come up successfully it proceeds with next cluster or else it waits for 15 min for the containers to come up. If they dont come up, a pagerduy duty incident is raised with the failed cluster details in it.

### Managing the clusters SRE look after

These repos are designed to look after the long term clusters that the SRE squad own and have to look after and keep patched and compliant.  
Maintaining these repositories in the responsbility of SRE and any new clusters needing managing need to be added to the config.


An example entry in the account .json file:
```
    {
      "cluster_name": "bots",
      "pipeline_env": "prod",
      "region": "us-east",
      "crn_service_name": "containers-kubernetes",
      "cluster_id": "d34580e8ca3a47939515766ff7d9d515",
      "csutil_update": "auto",
      "worker_update": "auto"
    },
```

The values and options are as follows:
- `cluster_name` - Name of the cluster
- `pipeline_env` - `prod` or `stage` depending on what the cluster is used for, prod is only used for clusters that have access to production IKS environments 
- `region` - IKS region
- `crn_service_name` - the service name to register the cluster against, 
- `cluster_id` - numerical clusterid
- `csutil_update` - auto or manual - depends whether you want automation to re-install csutil or not - usually set it to auto unless the cluster is part of csutil development then it might be set to manual and the owner will need to manually manage the csutil insall.
- `worker_update` - these config files are also used to reload worker nodes.  Set to auto or manual depending whether automation should manage the worker reloads.


### Running the jenkins jobs manually

Jenkins job can also be triggered manually by providing cluster id parameter. In that case it updates csutils only on provided cluster id.

## What actions needs to be taken If pagerduty incident is created ?
### Check Pods status of Cluster by logging into support account 
#### Steps to login
     - ibmcloud login
     - Select 'Alchemy Support' Account 278445
     - Fetch the kubectl config of cluster using 'ibmcloud ks cluster config --cluster <Cluster-id>' 
     - Get the csutils pods status using 'kubectl get pods -n ibm-services-system'

Check the Pods status of the cluster 

```
kubectl get pods -n ibm-services-system
NAME                                       READY   STATUS    RESTARTS   AGE
bes-local-client-f47np                     1/1     Running   1          6m52s
bes-local-client-gs29r                     1/1     Running   0          6m52s
bes-local-client-xtrrh                     1/1     Running   0          6m52s
kube-auditlog-forwarder-6f46bd9944-b9wtg   1/1     Running   0          6m48s
sos-tools-7dfd6c5c8b-wj72v                 3/3     Running   0          6m57s
syslog-configurator-2bxjw                  1/1     Running   0          6m52s
syslog-configurator-5fmzm                  1/1     Running   0          6m52s
syslog-configurator-hhmc6                  1/1     Running   0          6m52s
tiller-deploy-5d5b44cdf8-zthkw             1/1     Running   0          7m22s
```
check if all containers in those pods are up and running. If all pods are up and their containers are also up, resolve the pd incident .If not retriger the Jenkins Job by providing the cluster id as input.

## Escalation Policy
SRE