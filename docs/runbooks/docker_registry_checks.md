---
playbooks: [ "registry/recoveryTool/registry-resources.yml" , "registry/recoveryTool/reboot_scripted", "" ]
layout: default
title: Issue - Docker Registry Sensu Checks
type: Informational
runbook-name: "Issue - Docker Registry Sensu Checks"
description: Issue - Docker Registry Sensu Checks
link: /docker_registry_checks.html
service: "Containers Registry"
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Issue: 'registry hosts &lt;env&gt;' check is down

**Sensu is reporting that one of the Docker Registry Checks is down**

**Cause**: The consul container is not responding on more than one registry host.

## Detailed Information

### Background
Due to the way that our nginx works, when an individual machine's consul health goes red, requests will no longer be forwarded to that machine. Therefore as long as one of the hosts (there are 3 per env) is healthy we will not have an outage.

Each individual registry host has a Sensu check (e.g. *Docker Registry on prod-dal09-registry-docker-01*). These checks cause low severity pages, which go directly to the Registry and Build Squad.<br/>

These individual checks _roll up_ into *HA Service* Sensu checks. In each availability zone, there is a roll-up check called *'registry hosts &lt;env&gt;'*.

These roll-up *HA Service* checks will fail if we are down to 0 or 1 of the contributing machines still being healthy. i.e. they will fail if we have an outage or a single point of failure.

If you are reading this, it is because this state has occurred. 2 or 3 registry hosts in the availability zone are down or unhealthy.

#### How to resolve:

##### If this is in office hours for the UK
- Please reassign the page to so that we can gather more root cause analysis information on the failure.  
Reassign to [`Alchemy - Containers - Registry and Build (High Priority)`](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)

##### Outside of UK office hours :
1. Check Sensu for the environment (from the [Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) > [Carrier](https://alchemy-dashboard.containers.cloud.ibm.com/carrier)  > Service Health > Sensu-Uptime). Find the check that caused the PD. If it is green, then the problem has resolved.
2. Find the contributing Sensu checks for the individual hosts (e.g. *Docker Registry on prod-dal09-registry-docker-01*), and identify which of these are failing (there must be at least two).
3. Only proceed with the next step if the **hosts** have been up for _**more than 10 mins**_  
_If the hosts have been up for less than 10 minutes, then it is possible both may be on their way back up following reboots_

   To determine uptime, run the following command on the host `uptime`

2. If the hosts have been up for 10 minutes or more, then reboot the hosts.  
_We have written upstart config for all our containers so they should all come back succesfully after a reboot._  

   Before you do the reboot (step 2.2) we would like you to collect some information from the hosts.  

   _**NB.** When running the 2 steps below you will need to select the appropriate properties for the machine that is having the issue :  
   ~ **Jenkins** jobs (on Public) : **TARGET_ENV** and **HOSTS**  
   ~ **Ansible** jobs (on Dedicated and Local) : **-l &lt;hostname&gt;**_

   Here are the steps to follow :

    1. **Collect information**  
    Run the following to issue a series of commands that will gather data such as free memory, disk space etc about the machine in question :
        * **Public**  
        Run the Jenkins job: [registry-resources](https://alchemy-conductors-jenkins.swg-devops.com/job/Containers-Registry/view/Playbooks/job/RecoveryTool/job/registry-resources/)
        * **Dedicated or Local**  
        Run the playbook `registry/recoveryTool/registry-resources.yml`

    1. **Reboot the host**  
    Once that resources gathering job is complete, you can perform a reboot :
        * _**Public**_  
        Run the Jenkins job : [reboot_scripted](https://alchemy-conductors-jenkins.swg-devops.com/job/Containers-Registry/view/Playbooks/job/RecoveryTool/job/reboot_scripted/)
        * _**Dedicated or Local**_  
        Run the playbook `registry/recoveryTool/reboot_scripted.yml`

1. If the reboot does not fix the issue then please forward the page to the Registry team.  
Reassign to [`Alchemy - Containers - Registry and Build (High Priority)`](https://ibm.pagerduty.com/escalation_policies#PVHCBN9)

---



========================================================================

### Details of Automated Runbooks:

========================================================================


#### docker_registry_checks
  A pair of automation scripts have been implemented to assist with the situations listed in this runbook :

#####   [**dr_agent_controller.py** [ver. 2016.12.14]"](https://github.ibm.com/cloud-sre/automation/blob/master/cfs-auto-runbooks/python/docker_registry_checks/dr_agent_controller.py)

#####   [**target_machine_determine_action.py**](https://github.ibm.com/cloud-sre/automation/blob/master/cfs-auto-runbooks/python/docker_registry_checks/target_machine_determine_action.py)


The automation executes if the appropriate [**Doctor**](https://doctor.bluemix.net) environment has a rule implemented.


| Doctor    | | Live  | Service |
|---------- |-|:----: |----: |
| Dev       | |  No   | n/a |
| Prestage  | |  No   | n/a |
| Stage     | |  **YES**   | Alchem - Registry - stage-dal09 |
| Prod      | |  No   | n/a |



##### The automation executes as follows :

1. **dr_agent_controller.py** calls the python program **target_machine_determine_action.py**
1. Executes an R&B ansible playbook to return diagnostics about the registry machine ('lite' version)
1. [Optionally] Executes an R&B ansible playbook to reboot the machine
