---
layout: default
description: Armada-Kedge is unable to create a new logging or monitoring configuration for the cluster
title: armada-kedge - Configuration Failure Due to a Previous Manually Deployed Observe Agent
service: armada
runbook-name: "armada-kedge - Remove Manually Deployed Logging or Monitoring Agent from the Cluster"
tags: armada, kedge, logging, monitoring, carrier, metrics, cruiser, customer
link: /armada/armada-kedge-remove-agent.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Armada Kedge Remove Manually-Deployed Agent

## Overview
- The purpose of this runbook is to provide a user with the steps to remove a previous manually-deployed LogDNA or Sysdig agent from the cluster.  Since it was not created, and therefore not recognized by IKS Observe as a logging or monitoring configuration, the LogDNA or Sysdig dashboard cannot be launched from the Cluster Overview page.  In addition, the IKS Observe service cannot create a new logging or monitoring configuration using either the Cluster UI or observe-service CLI.

## Example alert(s)
- None

## Investigation and Action

- ### LogDNA

   While running: `ibmcloud ob logging config create --cluster CLUSTER --instance INSTANCE`

   If the user received the error message:

   `The logging configuration could not be created because a daemonset for the LogDNA agent was found in a Kubernetes namespace other than 'ibm-observe'.`
   
   - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Log-Analysis-with-LogDNA?topic=LogDNA-detach_agent">here for detaching a manually-installed LogDNA agent</a>

   - Once they have detached their LogDNA agent, they can create a new logging configuration that is recognized by IKS Observe: 
   `ibmcloud ob logging config create --cluster CLUSTER --instance INSTANCE`

  The user should now be able to launch their LogDNA dashboard from the Cluster Overview page.  Please note that if the user previously made any customizations to original LogDNA agent deployment, they will have to carry them over to the new deployment created by IKS Observe.  The new LogDNA agent can be found in the `ibm-observe` namespace.
  

- ### Sysdig

  While running: `ibmcloud ob monitoring config create --cluster CLUSTER --instance INSTANCE`

  If the user received the error message:

  `The monitoring configuration could not be created because a daemonset for the Sysdig agent was found in a Kubernetes namespace other than 'ibm-observe'.`

  - Ask them to follow the steps <a href="https://cloud.ibm.com/docs/services/Monitoring-with-Sysdig?topic=Sysdig-remove_agent">here for detaching a manually-installed Sysdig agent</a>

  - Once they have detached their Sysdig agent, they can create a new monitoring configuration that is recognized by IKS Observe: \
  `ibmcloud ob monitoring config create --cluster CLUSTER --instance INSTANCE`

  The user should now be able to launch their Sysdig dashboard from the Cluster Overview page.  Please note that if the user previously made any customizations to original Sysdig agent deployment, they will have to carry them over to the new deployment created by IKS Observe.  The new Sysdig agent can be found in the `ibm-observe` namespace.


  
## Automation
- None
- In the future, manually-installed LogDNA/Sysdig agents will be discoverable by IKS Observe. 


## Escalation Policy

Please notify {{ site.data.teams.armada-kedge.comm.name }} on Argonauts and create an issue [here]({{ site.data.teams.armada-kedge.link }})
